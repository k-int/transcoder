package com.k_int.transcoder.transform;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.logging.FileHandler;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.LogRecord;

import javax.servlet.ServletContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.XMLFilter;
import org.xml.sax.XMLReader;

import com.k_int.transcoder.transform.contentpackage.PackageFormat;
import com.k_int.transcoder.transform.contentpackage.ZipPackageFormat;
import com.sun.org.apache.xml.internal.serialize.OutputFormat;
import com.sun.org.apache.xml.internal.serialize.XMLSerializer;

public class Transformation
{
  private String targetVersion = "";
  private String sourceVersion = "";
  private File contentPackage;
  private String filename;
  private ServletContext servletContext;

  private String stylesheetDir = "WEB-INF/stylesheets";
  private String schemaDir = "WEB-INF/schemas";
  private String scriptsDir = "WEB-INF/scripts";
  private String tempDir = "WEB-INF/temp";
  private String scoDir = "Scorm_API_Scripts";

  private static org.apache.log4j.Logger log = Logger.getLogger(Transformation.class);
  private java.util.logging.Logger logger;
  private File logFile;

  public Transformation(File contentPackage, String filename, String target, ServletContext servletContext)
  {
    this.targetVersion = target;
    this.filename = filename;
    this.servletContext = servletContext;
    this.contentPackage = contentPackage;
    createLog();
  }

  private void createLog()
  {
    String name = "log_" + filename.substring(0, filename.lastIndexOf(".")) + Long.toHexString((new Date()).getTime());
    logger = java.util.logging.Logger.getLogger(name);
    String realTempPath = servletContext.getRealPath(tempDir);
    try
    {
      File rootDir = new File(realTempPath);
      if (!rootDir.exists())
        rootDir.mkdir();
      logFile = new File(rootDir, name + ".txt");
      FileHandler fh = new FileHandler(logFile.getPath());
      logger.addHandler(fh);
      fh.setFormatter(new Formatter() {
        public String format(LogRecord rec) {
           StringBuffer buf = new StringBuffer(1000);
           SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, HH:mm:ss.SSS");
           buf.append(sdf.format(new java.util.Date()));
           buf.append(' ');
           buf.append(rec.getLevel());
           buf.append('\t');
           buf.append(formatMessage(rec));
           buf.append('\n');
           return buf.toString();
           }
         });
    } catch (Exception e)
    {
      log.error(e.getMessage());
    }
    
  }

  /**
   * Guess archive file format depending on extension
   * 
   * @param fileName
   * @return
   * @throws TransformationException
   */
  private PackageFormat getPackageFormat() throws TransformationException
  {
    if (filename.endsWith(".zip"))
      return new ZipPackageFormat();
    else
    {
      String format = filename.substring(filename.lastIndexOf("."));
      throw new TransformationException("Content package archive format (" + format + ") not supported");
    }
  }

  /**
   * This method decompress the package, convert imsmanifest.xml files and
   * return compressed package back
   * 
   * @return
   * @throws TransformationException
   */

  public File transform() throws TransformationException
  {
    log.debug("transformation begin");
    logger.info("Transformation begins. \n");
    
    logger.info("File name: " + filename);
    logger.info("Target package version: " + targetVersion);
    File convertedPackage = null;
    PackageFormat format = getPackageFormat();
    String realTempPath = servletContext.getRealPath(tempDir);
    File rootDir = new File(realTempPath);
    if (!rootDir.exists())
      rootDir.mkdir();

    boolean manifest = false;
    if (format != null)
    {
      // dir name is create from current date to hexadecimal string and stored
      // in temp dir
      File dir = new File(rootDir, filename.substring(0, filename.lastIndexOf("."))
          + Long.toHexString((new Date()).getTime()));
      File rootManifest = null;
      try
      {
        dir.mkdir();
        format.unpack(contentPackage, dir);
        checkPackageStructure(dir);
        Collection<File> files = (Collection<File>) FileUtils.listFiles(dir, null, true);

        boolean success = false;
        String[] stylesheet = null;

        // first we search only for package version
        for (File f : files)
        {
          if ("imsmanifest.xml".equals(f.getName()) && dir.equals(f.getParentFile()))
          {
            sourceVersion = this.findPackageVersion(f);
            logger.info("Source version: " + sourceVersion + "\n");
            if ((PackageVersion.IMS_CC_1_0_0.equals(sourceVersion)) && isAuthorizationRequiered(f))
            {
              throw new TransformationException(
                  "This package can not be converted because of the authorization rules. For more the details about Common Cartridge authorization consult http://www.imsglobal.org.");
            }

            rootManifest = f;
            manifest = true;
            stylesheet = this.findStylesheet();
            if (stylesheet == null)
              throw new TransformationException("Sorry, transformation from " + sourceVersion + " to " + targetVersion
                  + " is not supported.");
            break;
          }
        }

        removeOldSchemas(files);
        // if target package is not Scorm, we merge external metadata
        if (!PackageVersion.SCORM_2004.equals(targetVersion))
          mergeMetadata(rootManifest);

        if (PackageVersion.SCORM_1_2.equals(sourceVersion) || PackageVersion.SCORM_2004.equals(sourceVersion))
          addScormWrapper(rootManifest);

        if (PackageVersion.SCORM_1_2.equals(sourceVersion) && PackageVersion.SCORM_2004.equals(targetVersion))
          transformExternalMetadata(rootManifest);

        files = (Collection<File>) FileUtils.listFiles(dir, null, true);

        // we convert all files
        for (File f : files)
        {
          String name = f.getName();
          if ("imsmanifest.xml".equals(f.getName()))
          {
            // transforming weblink and discussion topic of CC to html pages

            // if source version is IMS CP 1.1.3 or SCORM 1.2, check xml prefix
            // of
            // attributtes
            if (PackageVersion.IMS_CP_1_1_3.equals(sourceVersion) || PackageVersion.SCORM_1_2.equals(sourceVersion))
            {
              checkXMLNamespacePrefix(f);
            }

            success = convertManifest(f, stylesheet);

            copySchema(f.getParentFile());
            if (sourceVersion.contains("IMS") && targetVersion.equals(PackageVersion.SCORM_2004))
            {
              File jsDir = new File(f.getParentFile(), scoDir);
              if (!jsDir.exists())
                jsDir.mkdir();
              logger.info("Adding file " + scoDir + "/APIWrapper.js to the package content.");
              this.saveFile(jsDir, "APIWrapper.js", scriptsDir);
            }

            if ((sourceVersion.equals(PackageVersion.SCORM_1_2) || sourceVersion.equals(PackageVersion.SCORM_2004))
                && targetVersion.contains("IMS"))
            {
              logger.info("Adding file singleSCOminiRTE.htm (Scorm 2004 Runtime Enviroment by Claude Ostyn) to the package content.");
              this.saveFile(f.getParentFile(), "singleSCOminiRTE.htm", scriptsDir);
            }

            if (sourceVersion.equals(PackageVersion.SCORM_1_2))
            {
              logger.info("Adding file esas2004.htm (Scorm 1.2 to Scorm 2004 wrapper by Claude Ostyn) to the package content.");
              this.saveFile(f.getParentFile(), "esas2004.htm", scriptsDir);
            }

          } else if (name.endsWith("html") || name.endsWith("htm"))
          {
            if (targetVersion.contains("SCORM") && sourceVersion.contains("IMS"))
            {
              addSCORMApiCalls(f);
            }
          }
        }

        /*
         * Transformation of Common Cartridge web links and forum objects. This
         * should be called after the xslt transformation of manifest is done,
         * because html resources are treated in the stylesheet as a 'SCO'
         * object which is not desirable.
         */

        if (sourceVersion.equals(PackageVersion.IMS_CC_1_0_0))
        {
          parseLink(rootManifest);
        }

        addMissingReferences(rootManifest, (List<File>) files);

        if (success)
          convertedPackage = format.pack(dir.listFiles(), new File(realTempPath, "converted_" + filename), dir);
        if (manifest == false)
          throw new TransformationException("File imsmanifest.xml not found in the package.");
     
      } finally
      {
        closeLogFile();
        if (dir != null && dir.exists())
          deleteDirectory(dir);
      }
    }
    logger.info("Transformation ends.");
    return convertedPackage;
  }

  /**
   * Remove all mandatory schema files in the source package
   * 
   * @param files -
   *          list of all files in the package
   * 
   */
  private void removeOldSchemas(Collection<File> files)
  {

    List<String> schemas = this.getRequieredSchemaInList(sourceVersion);

    if (schemas.size() == 0)
      return;
    logger.info("Deleting old schema files: ");
    for (File f : files)
    {
      
      boolean delete = false;
      for (String s : schemas)
      {
        if (f.getName().equals(s))
        {
          delete = true;
          break;
        }
      }
      if (delete)
      {  
        logger.info("\t deleting: " + f.getName());
        f.delete();
      }  
    }
  }

  /**
   * @return Log File
   */
  public File getLogFile()
  {
    return logFile;
  }
  
  
  
  /**
   * Check the correct file structure of the unpacked content package. If all
   * the package content is packed in a one sub-directory, then this
   * sub-directory is removed.
   * 
   * @param dir
   */
  private void checkPackageStructure(File dir)
  {
    File[] content = dir.listFiles();
    // If all the package content is packed in a one sub-directory
    if (content.length == 1 && content[0].isDirectory())
    {
      try
      {
        logger.info("All content was packed in directory " + content[0].getName() + ". Removing this directory.");
        FileUtils.copyDirectory(content[0], dir);
        // sub-directory is removed
        deleteDirectory(content[0]);
      } catch (Exception e)
      {
        log.error(e.getMessage());
      }
    }
  }

  /**
   * This help function finds all filenames of the required schemas
   * 
   * @param packageVersion
   * @return
   */
  private List<String> getRequieredSchemaInList(String packageVersion)
  {

    String[] schemas = PackageVersion.getRequiredSchemas(packageVersion);
    ArrayList<String> list = new ArrayList<String>();
    for (String schema : schemas)
    {
      if (schema.endsWith(".xsd") || schema.endsWith(".dtd"))
      {
        list.add(schema);
      } else
      {
        String realSchemaDir = servletContext.getRealPath(schemaDir);
        File d = new File(realSchemaDir, schema);
        if (d.exists() && d.isDirectory())
        {
          File[] subFiles = d.listFiles();
          for (File f : subFiles)
          {
            list.add(f.getName());
          }
        }
      }
    }

    return list;
  }

  /**
   * Copy required schemas for the target package version
   * 
   * @param dir -
   *          root dir of the package
   */
  private void copySchema(File dir)
  {
    String[] schemas = PackageVersion.getRequiredSchemas(targetVersion);
    if (schemas != null)
    {
      if (schemas.length > 0)
        logger.info("Copying new schema files: ");
      for (String schema : schemas)
      {
        if (schema.endsWith(".xsd") || schema.endsWith(".dtd"))
        {
          logger.info("\t adding schema file: " + schema);
          saveFile(dir, schema, schemaDir);
        } else
        {
          String realSchemaDir = servletContext.getRealPath(schemaDir);
          File d = new File(realSchemaDir, schema);
          if (d.exists())
          {
            try
            {
              String[] list = d.list();
              for (String s: list)
                logger.info("\t adding new schema file: " + s);
              FileUtils.copyDirectory(d, dir);
            } catch (Exception e)
            {
              log.error(e.getMessage());
            }
          }
        }
      }
    }
  }

  /**
   * Save file relatively defined in servlet context to the destination dir
   * 
   * @param destDir -
   *          absolute destination dir
   * @param fileName -
   *          filename
   * @param srcDir -
   *          source dir relative to servlet context
   */
  private void saveFile(File destDir, String fileName, String srcDir)
  {
    File f = new File(destDir, fileName);
    if (!f.exists())
    {
      try
      {
        InputStream inp = servletContext.getResourceAsStream(srcDir + File.separator + fileName);
        FileOutputStream out = new FileOutputStream(f);
        byte[] buffer = new byte[2048];
        int bytesRead = inp.read(buffer);
        while (bytesRead >= 0)
        {
          if (bytesRead > 0)
            out.write(buffer, 0, bytesRead);
          bytesRead = inp.read(buffer);
        }
        out.flush();
        out.close();
        inp.close();
      } catch (Exception e)
      {
        log.error(e.getMessage());
      }
    }

  }

  /**
   * Deletes directory and its content
   * 
   * @param path -
   * @return
   */
  private boolean deleteDirectory(File dir)
  {
    if (dir.exists())
    {
      File[] files = dir.listFiles();
      for (int i = 0; i < files.length; i++)
      {
        if (files[i].isDirectory())
        {
          deleteDirectory(files[i]);
        } else
        {
          files[i].delete();
        }
      }
    }
    return (dir.delete());
  }

  /**
   * Finds appropriete stysheets for imsmanifest.xml transformation
   * 
   * @return
   * @throws TransformationException
   */
  private String[] findStylesheet() throws TransformationException
  {
    String[] stylesheet = null;
    if (targetVersion.equals(sourceVersion))
    {
      throw new TransformationException("You are trying to convert package to the same target version ("
          + sourceVersion + ").");
    } else if (sourceVersion == null || "".equals(sourceVersion))
    {
      throw new TransformationException(
          "Manifest schema version not specified. Check file imsmanifest.xml in your source package.");
    }

    if (PackageVersion.SCORM_2004.equals(sourceVersion) && PackageVersion.IMS_CP_1_1_4.equals(targetVersion))
    {
      stylesheet = new String[]
      { "scorm2004_to_IMS_v1p1p4.xsl" };
    } else if (PackageVersion.SCORM_2004.equals(sourceVersion) && PackageVersion.IMS_CP_1_1_3.equals(targetVersion))
    {
      stylesheet = new String[]
      { "scorm2004_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_IMS_v1p1p3.xsl" };
    } else if (PackageVersion.SCORM_2004.equals(sourceVersion) && PackageVersion.IMS_CC_1_0_0.equals(targetVersion))
    {
      stylesheet = new String[]
      { "scorm2004_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_CCv1p0p0.xsl" };
    } else if (PackageVersion.IMS_CC_1_0_0.equals(sourceVersion) && PackageVersion.IMS_CP_1_1_4.equals(targetVersion))
    {
      stylesheet = new String[]
      { "CCv1p0p0_to_IMS_v1p1p4.xsl" };
    } else if (PackageVersion.IMS_CC_1_0_0.equals(sourceVersion) && PackageVersion.IMS_CP_1_1_3.equals(targetVersion))
    {
      stylesheet = new String[]
      { "CCv1p0p0_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_IMS_v1p1p3.xsl" };
    } else if (PackageVersion.IMS_CC_1_0_0.equals(sourceVersion) && PackageVersion.SCORM_2004.equals(targetVersion))
    {
      stylesheet = new String[]
      { "CCv1p0p0_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_SCORM_2004.xsl" };
    } else if (PackageVersion.IMS_CP_1_1_4.equals(sourceVersion) && PackageVersion.IMS_CC_1_0_0.equals(targetVersion))
    {
      stylesheet = new String[]
      { "IMS_v1p1p4_to_CCv1p0p0.xsl" };
    } else if (PackageVersion.IMS_CP_1_1_4.equals(sourceVersion) && PackageVersion.IMS_CP_1_1_3.equals(targetVersion))
    {
      stylesheet = new String[]
      { "IMS_v1p1p4_to_IMS_v1p1p3.xsl" };
    } else if (PackageVersion.IMS_CP_1_1_4.equals(sourceVersion) && PackageVersion.SCORM_2004.equals(targetVersion))
    {
      stylesheet = new String[]
      { "IMS_v1p1p3_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_SCORM_2004.xsl" };
    } else if (PackageVersion.IMS_CP_1_1_3.equals(sourceVersion) && PackageVersion.IMS_CC_1_0_0.equals(targetVersion))
    {
      stylesheet = new String[]
      { "IMS_v1p1p3_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_CCv1p0p0.xsl" };
    } else if (PackageVersion.IMS_CP_1_1_3.equals(sourceVersion) && PackageVersion.IMS_CP_1_1_4.equals(targetVersion))
    {
      stylesheet = new String[]
      { "IMS_v1p1p3_to_IMS_v1p1p4.xsl" };
    } else if (PackageVersion.IMS_CP_1_1_3.equals(sourceVersion) && PackageVersion.SCORM_2004.equals(targetVersion))
    {
      stylesheet = new String[]
      { "IMS_v1p1p3_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_SCORM_2004.xsl" };
    }

    else if (PackageVersion.SCORM_1_2.equals(sourceVersion) && PackageVersion.SCORM_2004.equals(targetVersion))
    {
      stylesheet = new String[]
      { "SCORM_1p2_to_SCORM_2004.xsl" };
    } else if (PackageVersion.SCORM_1_2.equals(sourceVersion) && PackageVersion.IMS_CP_1_1_4.equals(targetVersion))
    {
      stylesheet = new String[]
      { "SCORM_1p2_to_SCORM_2004.xsl", "scorm2004_to_IMS_v1p1p4.xsl" };
    } else if (PackageVersion.SCORM_1_2.equals(sourceVersion) && PackageVersion.IMS_CC_1_0_0.equals(targetVersion))
    {
      stylesheet = new String[]
      { "SCORM_1p2_to_SCORM_2004.xsl", "scorm2004_to_IMS_v1p1p4.xsl", "IMS_v1p1p4_to_CCv1p0p0.xsl" };
    }

    else if (!PackageVersion.isSupportedSource(sourceVersion))
    {
      throw new TransformationException("Source package version (" + sourceVersion + ") not supported.");
    } else if (!PackageVersion.isSupportedTarget(targetVersion))
    {
      throw new TransformationException("Target package version (" + targetVersion + ") not supported.");
    }
    return stylesheet;
  }

  /**
   * Looks in the imsmanifest.xml file to dermine schema and version of the
   * content package
   * 
   * @param manifest -
   * @return
   */
  private String findPackageVersion(File manifest) throws TransformationException
  {
    String schema = "IMS Content";
    String schemaVersion = "1.1";
    String manifestVersion = null;
    try
    {

      DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
      fact.setNamespaceAware(false);
      DocumentBuilder builder = fact.newDocumentBuilder();
      Document doc = builder.parse(manifest);
      Element root = doc.getDocumentElement();
      manifestVersion = root.getAttribute("version");
      NodeList metadata = root.getElementsByTagName("metadata");

      if (metadata != null && metadata.getLength() > 0)
      {
        NodeList schemaNode = ((Element) (metadata.item(0))).getElementsByTagName("schema");
        NodeList schemaVersionNode = ((Element) (metadata.item(0))).getElementsByTagName("schemaversion");

        if (schemaNode != null && schemaNode.getLength() > 0)
        {
          schema = schemaNode.item(0).getTextContent();

          schemaVersion = schemaVersionNode.item(0).getTextContent();
        }
      }

    } catch (Exception e)
    {
      e.printStackTrace();
      log.error(e.getMessage());
      throw new TransformationException("Error while parsing imsmanifest.xml file. " + e.getMessage());
    }

    if ("ADL SCORM".equals(schema) && schemaVersion != null && schemaVersion.contains("2004"))
      return PackageVersion.SCORM_2004;
    if ("ADL SCORM".equals(schema) && schemaVersion != null && schemaVersion.contains("1.2"))
      return PackageVersion.SCORM_1_2;
    if ("IMS Common Cartridge".equals(schema) && schemaVersion != null && schemaVersion.contains("1.0.0"))
      return PackageVersion.IMS_CC_1_0_0;
    else if ("IMS Content".equalsIgnoreCase(schema)
        && (("1.1".equals(schemaVersion) && "IMS CP 1.1.3".equalsIgnoreCase(manifestVersion)) || "1.1.3"
            .equals(schemaVersion)))
      return PackageVersion.IMS_CP_1_1_3;
    else if ("IMS Content".equalsIgnoreCase(schema))
      return PackageVersion.IMS_CP_1_1_4;
    else
    {
      String v = "";
      if (schema != null)
        v = v.concat("Schema " + schema);
      if (schemaVersion != null)
        v = v.concat(" schema version " + schemaVersion);
      if (manifestVersion != null)
        v = v.concat(" manifest version " + manifestVersion);
      return v;
    }
  }

  private boolean isAuthorizationRequiered(File manifest) throws TransformationException
  {
    NodeList authorization = null;
    try
    {
      DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
      fact.setNamespaceAware(true);
      DocumentBuilder builder = fact.newDocumentBuilder();
      Document doc = builder.parse(manifest);
      Element root = doc.getDocumentElement();
      authorization = root.getElementsByTagNameNS("http://www.imsglobal.org/xsd/imsccauth_v1p0", "authorizations");
    } catch (Exception e)
    {
      e.printStackTrace();
      log.error(e.getMessage());
      throw new TransformationException("Error while parsing imsmanifest.xml file. " + e.getMessage());
    }
    return (authorization != null && authorization.getLength() > 0);
  }

  private void addMissingReferences(File manifest, List<File> files) throws TransformationException
  {
    try
    {
      DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
      fact.setNamespaceAware(true);

      DocumentBuilder builder = fact.newDocumentBuilder();
      Document doc = builder.parse(manifest);
      Element manifestEl = doc.getDocumentElement();

      HashSet<String> references = getHrefReferences(manifestEl);
      references.addAll(getLocations(manifestEl));

      String manifestPath = manifest.getParentFile().getCanonicalPath();
      int pathLength = manifestPath.length();
      int found = 0;
      int notFound = 0;
      ArrayList<String> missing = new ArrayList<String>();
      for (File f : files)
      {
        if (f.isFile())
        {
          String relPath = f.getCanonicalPath().substring(pathLength + 1);
          relPath = relPath.replaceAll(" ", "%20");
          if (references.contains(relPath))
          {
            found++;

          } else if (!"imsmanifest.xml".equals(f.getName()) && !f.getName().endsWith(".xsd")
              && !f.getName().endsWith(".dtd"))
          {
            notFound++;

            missing.add(relPath);
          }
        }
      }

      if (notFound > 0)
      {
        Element resources = (Element) (manifestEl.getElementsByTagName("resources").item(0));

        String xmlBase = findBase(resources);
        logger.info("Adding missing references to the manifest.");
        Element resource = doc.createElement("resource");
        resource.setAttribute("identifier", "missing_resource");
        resource.setAttribute("type", "webcontent");
        if (PackageVersion.SCORM_2004.equals(targetVersion))
          resource.setAttributeNS("http://www.adlnet.org/xsd/adlcp_v1p3", "adlcp:scormType", "asset");
        for (String m : missing)
        {
          Element file = doc.createElement("file");
          // if root manifest and resources have already xml:base attribute
          // defined
          // a) href starts with this base so we remove the beginning
          if (m.startsWith(xmlBase))
            m = m.substring(xmlBase.length());
          // b) href doesn't starts with this base so we have to build relative
          // path
          else if (xmlBase != null && !"".equals(xmlBase))
            m = replaceRelPath(xmlBase).concat(m);
          file.setAttribute("href", m);
          logger.info("\t Adding reference to: " + m);
          resource.appendChild(file);
        }
        resources.appendChild(resource);
      }

      writeOutputXML(manifestEl, manifest.getPath());

    } catch (Exception e)
    {
      e.printStackTrace();
      log.error(e.getMessage());
      throw new TransformationException("Error while parsing imsmanifest.xml file. " + e.getMessage());
    }
  }

  private void addScormWrapper(File manifest) throws TransformationException
  {
    boolean scorm2004 = PackageVersion.SCORM_2004.equals(sourceVersion);
    try
    {
      DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
      fact.setNamespaceAware(true);

      DocumentBuilder builder = fact.newDocumentBuilder();
      Document doc = builder.parse(manifest);
      Element manifestEl = doc.getDocumentElement();

      NodeList resourcesEl = manifestEl.getElementsByTagName("resources");
      for (int i = 0; i < resourcesEl.getLength(); i++)
      {
        Element rs = (Element) resourcesEl.item(i);
        Element res = doc.createElement("resource");
        res.setAttribute("identifier", "scorm_wrapper");
        res.setAttribute("type", "webcontent");
        logger.info("Adding new resource (identifier=scorm_wrapper) for the scorm wrapper file to the manifest.");
        if (scorm2004)
          res.setAttributeNS("http://www.adlnet.org/xsd/adlcp_v1p3", "adlcp:scormType", "asset");
        else
          res.setAttributeNS("http://www.adlnet.org/xsd/adlcp_rootv1p2", "adlcp:scormtype", "asset");

        if (PackageVersion.SCORM_1_2.equals(sourceVersion) && PackageVersion.SCORM_2004.equals(targetVersion))
        {
          Element file = doc.createElement("file");
          file.setAttribute("href", "esas2004.htm");
          res.appendChild(file);
          logger.info("\t Adding file esas2004.html - Scorm 1.2 to Scorm 2004 wrapper by Claude Ostyn to the manifest.");

        } else if (PackageVersion.SCORM_2004.equals(sourceVersion))
        {
          Element file = doc.createElement("file");
          file.setAttribute("href", "singleSCOminiRTE.htm");
          res.appendChild(file);
          logger.info("\t Adding file singleSCOminiRTE.htm - Scorm 2004 Runtime Enviroment by Claude Ostyn to the manifest.");

        } else
        {
          Element file = doc.createElement("file");
          file.setAttribute("href", "esas2004.htm");
          res.appendChild(file);
          logger.info("\t Adding file esas2004.html - Scorm 1.2 to Scorm 2004 wrapper by Claude Ostyn to the manifest.");
          
          Element file2 = doc.createElement("file");
          file2.setAttribute("href", "singleSCOminiRTE.htm");
          res.appendChild(file2);
          logger.info("\t Adding file singleSCOminiRTE.htm - Scorm 2004 Runtime Enviroment by Claude Ostyn to the manifest.");
        }
        
        if ("resource".equals(rs.getLastChild().getNodeName()))
          rs.appendChild(res);
        else
        {
          NodeList children = rs.getChildNodes();
          for (int j = 0; j < children.getLength(); j++)
          {
            if (!"resource".equals(children.item(j).getNodeName()))
            {
              rs.insertBefore(res, children.item(j));
              break;
            }
          }
        }
      }

      NodeList resources = manifestEl.getElementsByTagName("resource");

      for (int i = 0; i < resources.getLength(); i++)
      {
        Element resource = (Element) resources.item(i);
        String scoType = "";
        if (scorm2004)
          scoType = resource.getAttributeNS("http://www.adlnet.org/xsd/adlcp_v1p3", "scormType");
        else
          scoType = resource.getAttributeNS("http://www.adlnet.org/xsd/adlcp_rootv1p2", "scormtype");

        if ("sco".equals(scoType))
        {
          String href = resource.getAttribute("href");
          if (href == null || "".equals(href.trim()))
          {
            Element file = (Element) resource.getElementsByTagName("file").item(0);
            href = file.getAttribute("href");
          }
          String l = "\t Replacing href attribute " + href;
          String newHref = "";
          if (PackageVersion.SCORM_1_2.equals(sourceVersion) && PackageVersion.SCORM_2004.equals(targetVersion))
          {
            // href="mysco.html?a=foo&amp;b=2 will be
            // href="esas2004.htm?sco=mysco.html&amp;a=foo&amp;b=2
            href = href.replace("#", "%23").replace("?", "&amp;");
            newHref = "esas2004.htm?sco=" + href;
          } else if (PackageVersion.SCORM_2004.equals(sourceVersion))
          {
            href = href.replace("#", "%23").replace("?", "&amp;");
            newHref = "singleSCOminiRTE.htm?sco=" + href;
          } else
          {
            // needs to url encode (e.g
            // singleSCOminiRTE.htm?sco=esas2004.htm%3Fsco%3Dsco1%2Ehtm)
            newHref = "singleSCOminiRTE.htm?sco=esas2004.htm"
                + URLEncoder.encode("?sco=" + href.replace("&amp;", "&"), "UTF-8");
          }
          logger.info(l + " by " + newHref + ".");
          resource.setAttribute("href", newHref);
          logger.info("\t Adding dependency to scorm wrapper resource.");
          Element dependency = doc.createElement("dependency");
          dependency.setAttribute("identifierref", "scorm_wrapper");
          resource.appendChild(dependency);
        }
      }

      writeOutputXML(manifestEl, manifest.getPath());
    } catch (Exception e)
    {
      e.printStackTrace();
      log.error(e.getMessage());
      throw new TransformationException("Error while parsing imsmanifest.xml file. " + e.getMessage());
    }
  }

  private HashSet<String> getLocations(Element manifestEl)
  {
    NodeList metadataList = manifestEl.getElementsByTagName("metadata");
    HashSet<String> locations = new HashSet<String>();
    for (int i = 0; i < metadataList.getLength(); i++)
    {
      Element metadata = (Element) metadataList.item(i);
      NodeList children = metadata.getChildNodes();
      for (int j = 0; j < children.getLength(); j++)
      {
        Node n = children.item(j);

        if ("location".equals(n.getLocalName()) && ("http://www.adlnet.org/xsd/adlcp_v1p3".equals(n.getNamespaceURI()))
            || "http://www.adlnet.org/xsd/adlcp_rootv1p2".equals(n.getNamespaceURI()))
        {
          String location = n.getTextContent();
          String xmlBase = findBase(n);
          // we concatenate xmlBase with location, in case location already
          // starts with the xmlBase, we do nothing
          locations.add(location.startsWith(xmlBase) ? location : xmlBase + location);
        }
      }
    }
    return locations;
  }

  private String replaceRelPath(String path)
  {
    String[] dirs = path.split("/");
    String relPath = "";
    for (int i = 0; i < dirs.length; i++)
    {
      relPath += "../";
    }
    return relPath;
  }

  private void mergeMetadata(File manifest) throws TransformationException
  {
    try
    {
      DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
      fact.setNamespaceAware(true);

      DocumentBuilder builder = fact.newDocumentBuilder();
      Document doc = builder.parse(manifest);
      Element manifestEl = doc.getDocumentElement();

      NodeList metadataList = manifestEl.getElementsByTagName("metadata");
      for (int i = 0; i < metadataList.getLength(); i++)
      {
        Element metadata = (Element) metadataList.item(i);
        NodeList children = metadata.getChildNodes();
        for (int j = 0; j < children.getLength(); j++)
        {
          Node n = children.item(j);
          if ("location".equals(n.getLocalName())
              && ("http://www.adlnet.org/xsd/adlcp_v1p3".equals(n.getNamespaceURI()))
              || "http://www.adlnet.org/xsd/adlcp_rootv1p2".equals(n.getNamespaceURI()))
          {
            String location = n.getTextContent();
            String xmlBase = findBase(n);
            File f = new File(manifest.getParentFile(), xmlBase + location);
            if (f.exists())
            {
              logger.info("Adding metadata information from file " + f.getName() + " to the manifest file.");
              Document loc = builder.parse(f);
              Element metadataEl = loc.getDocumentElement();
              Node clone = doc.importNode(metadataEl, true);
              metadata.replaceChild(clone, n);
              logger.info("Deleting metadata file " + f.getName());
              f.delete();
            }
          }
        }
      }
      writeOutputXML(manifestEl, manifest.getPath());
    } catch (Exception e)
    {
      e.printStackTrace();
      log.error(e.getMessage());
      throw new TransformationException("Error while parsing imsmanifest.xml file. " + e.getMessage());
    }
  }

  private void transformExternalMetadata(File manifest)
  {
    try
    {
      DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
      fact.setNamespaceAware(true);
      DocumentBuilder builder = fact.newDocumentBuilder();
      Document doc = builder.parse(manifest);
      Element manifestEl = doc.getDocumentElement();
      HashSet<String> locations = getLocations(manifestEl);
      for (String location : locations)
      {
        File f = new File(manifest.getParentFile(), location);
        if (f.exists())
        {
          Document loc = builder.parse(f);
          Element metadataEl = loc.getDocumentElement();
          String uri = "http://www.imsglobal.org/xsd/imsmd_rootv1p2p1";
          if ("lom".equals(metadataEl.getLocalName()) && uri.equals(metadataEl.getNamespaceURI()))
          {  
            convertSingleStylesheets(f, "LRMv1p2p1-LOMv1p0_standalone.xsl");
            logger.info("Transforming external metadata file " + f.getName() + " from IMS Metadata 1.2.1 profile to LOMv1.0");
          }  
        }
      }
    } catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  private String findBase(Node node)
  {
    String name = "";
    String xmlBase = "";
    do
    {
      name = node.getLocalName();
      if ("manifest".equals(name) || "resources".equals(name) || "resource".equals(name))
      {
        String nodeBase = checkTrailingSlash(((Element) node).getAttributeNS("http://www.w3.org/XML/1998/namespace",
            "base"));
        xmlBase = nodeBase.concat(xmlBase);
      }
      node = node.getParentNode();
    } while (node != null && !"manifest".equals(name));
    return xmlBase;
  }

  private HashSet<String> getHrefReferences(Element manifestEl)
  {

    HashSet<String> references = new HashSet<String>();

    NodeList manifestChildren = manifestEl.getChildNodes();

    NodeList resources = null;

    for (int i = 0; i < manifestChildren.getLength(); i++)
    {
      Node node = manifestChildren.item(i);
      if ("resources".equals(node.getNodeName()))
      {
        resources = ((Element) node).getElementsByTagName("resource");
      }

      if ("manifest".equals(node.getNodeName()))
      {
        references.addAll(getHrefReferences((Element) node));
      }
    }

    NodeList files = null;
    if (resources != null)
      for (int i = 0; i < resources.getLength(); i++)
      {
        Element resource = ((Element) resources.item(i));
        String xmlBase = findBase(resource);

        String href = ((Element) resources.item(i)).getAttribute("href");
        if (href != null && !"".equals(href))
        {
          references.add(xmlBase + href);
        }
        files = resource.getElementsByTagName("file");
        for (int j = 0; j < files.getLength(); j++)
        {
          Element file = (Element) files.item(j);
          href = file.getAttribute("href");
          if (href != null && !"".equals(href))
          {
            references.add(xmlBase + href);
          }
        }
      }
    return references;
  }

  private String checkTrailingSlash(String path)
  {
    if (path == null || "".equals(path.trim()))
      return "";
    else if (path.endsWith("/") || path.endsWith("\\"))
      return path;
    else
      return path + "/";
  }

  /**
   * Finds in manifest all weblink and discussion topics .xml files and calls
   * transformation to .html. Note: Used only for Common Cartridge.
   * 
   * @param manifest
   * @throws TransformationException
   */
  private void parseLink(File manifest) throws TransformationException
  {
    try
    {
      DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
      fact.setNamespaceAware(true);
      DocumentBuilder builder = fact.newDocumentBuilder();
      Document doc = builder.parse(manifest);
      Element root = doc.getDocumentElement();
      NodeList files = root.getElementsByTagName("file");
      for (int i = 0; i < files.getLength(); i++)
      {
        Element file = (Element) files.item(i);
        Element resource = (Element) file.getParentNode();
        Element resources = (Element) resource.getParentNode();

        String xmlBase = checkTrailingSlash(root.getAttributeNS("http://www.w3.org/XML/1998/namespace", "base"));
        String resourcesXmlBase = checkTrailingSlash(resources.getAttributeNS("http://www.w3.org/XML/1998/namespace",
            "base"));
        String resourceXmlBase = checkTrailingSlash(resource.getAttributeNS("http://www.w3.org/XML/1998/namespace",
            "base"));
        xmlBase = xmlBase.concat(resourcesXmlBase).concat(resourceXmlBase);
        String type = resource.getAttribute("type");
        String href = file.getAttribute("href");

        if ("imsdt_xmlv1p0".equals(type))
        {
          convertAppObject(new File(manifest.getParent() + File.separator + xmlBase + href), servletContext,
              "imscc_dt.xsl");
          file.setAttribute("href", href.replace(".xml", ".html"));
          resource.setAttribute("type", "webcontent");
          resource.setAttribute("href", href.replace(".xml", ".html"));

        } else if ("imswl_xmlv1p0".equals(type))
        {
          convertAppObject(new File(manifest.getParent() + File.separator + xmlBase + href), servletContext,
              "imscc_wl.xsl");
          file.setAttribute("href", href.replace(".xml", ".html"));
          resource.setAttribute("type", "webcontent");
          resource.setAttribute("href", href.replace(".xml", ".html"));
        }
      }
      writeOutputXML(root, manifest.getPath());

    } catch (Exception e)
    {
      e.printStackTrace();
      log.error(e.getMessage());
      throw new TransformationException("Error while parsing imsmanifest.xml file. " + e.getMessage());
    }
  }

  /**
   * Calls transformation of weblink and discussion topic objects to .html
   * files. Note: Used only for Common Cartridge.
   * 
   * @param descriptor -
   *          CC application object (weblink or discussion topic)
   * @param servletContext
   * @param stylesheet
   * @return
   * @throws TransformationException
   */
  private boolean convertAppObject(File descriptor, ServletContext servletContext, String stylesheet)
      throws TransformationException
  {
    logger.info("Converting " + descriptor + " to HTML file");
    if (stylesheet != null)
    {
      try
      {
        TransformerFactory t_factory = TransformerFactory.newInstance();
        DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
        fact.setNamespaceAware(true);
        DocumentBuilder builder = fact.newDocumentBuilder();

        InputStream inp = servletContext.getResourceAsStream(stylesheetDir + File.separator + stylesheet);
        StreamSource source = new StreamSource(inp, servletContext.getRealPath(stylesheetDir) + File.separator);
        javax.xml.transform.Transformer transformer = t_factory.newTransformer(source);

        Document xml_doc = builder.parse(new FileInputStream(descriptor));
        DOMSource xml_dom_source = new DOMSource(xml_doc);

        String manifest_path = descriptor.getPath().replace(".xml", ".html");
        StreamResult result = new StreamResult();
        FileOutputStream fos = new FileOutputStream(manifest_path);
        result.setOutputStream(fos);
        transformer.transform(xml_dom_source, result);
        fos.flush();
        fos.close();
        descriptor.delete();

      } catch (Exception e)
      {
        e.printStackTrace();
        log.error(e.getMessage());
        throw new TransformationException("Xslt transformation of imsmanifest.xml failed. " + e.getMessage());
      }
      return true;
    } else
    {
      return false;
    }
  }

  /**
   * XSLT Transformation of imsmanifest.xml file.
   * 
   * @param manifest
   * @param stylesheets
   * @return
   * @throws TransformationException
   */
  private boolean convertManifest(File manifest, String[] stylesheets) throws TransformationException
  {
    if (stylesheets == null || stylesheets.length == 0)
      return false;
    logger.info("XSLT transformation of imsmanifest.xml");
    if (stylesheets.length == 1)
    {
      return convertSingleStylesheets(manifest, stylesheets[0]);
    } else
    {
      return convertMultipleStylesheets(manifest, stylesheets);
    }

  }

  /**
   * XSLT Transformation of imsmanifest.xml file using multiple stylesheets.
   * 
   * @param manifest
   * @param stylesheets
   * @return
   * @throws TransformationException
   */
  private boolean convertMultipleStylesheets(File manifest, String[] stylesheets) throws TransformationException
  {
    try
    {

      TransformerFactory t_factory = TransformerFactory.newInstance();
      /*
       * DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
       * fact.setNamespaceAware(true); DocumentBuilder builder =
       * fact.newDocumentBuilder();
       */

      SAXParserFactory spf = SAXParserFactory.newInstance();
      spf.setNamespaceAware(true);
      SAXParser parser = spf.newSAXParser();
      XMLReader reader = parser.getXMLReader();

      SAXTransformerFactory stf = (SAXTransformerFactory) TransformerFactory.newInstance();
      StreamSource source = new StreamSource(servletContext.getRealPath(stylesheetDir) + File.separator
          + stylesheets[0]);
      XMLFilter filter1 = stf.newXMLFilter(source);
      filter1.setParent(reader);
      XMLFilter parentFilter = filter1;

      for (int i = 1; i < stylesheets.length; i++)
      {
        StreamSource s = new StreamSource(servletContext.getRealPath(stylesheetDir) + File.separator + stylesheets[i]);
        XMLFilter filter = stf.newXMLFilter(s);
        filter.setParent(parentFilter);
        parentFilter = filter;
      }

      String manifest_path_tmp = manifest.getPath() + ".tmp";
      /*
       * StreamResult result = new StreamResult(); FileOutputStream fos = new
       * FileOutputStream(manifest_path_tmp); result.setOutputStream(fos);
       */
      // 
      DOMResult dom_result = new DOMResult();

      javax.xml.transform.Transformer transformer = t_factory.newTransformer();
      transformer.setOutputProperty(OutputKeys.INDENT, "yes");

      SAXSource transformSource = new SAXSource(parentFilter, new InputSource(new FileInputStream(manifest)));
      transformSource.setSystemId(servletContext.getRealPath(stylesheetDir) + File.separator);

      // transformer.transform(transformSource, result);
      transformer.transform(transformSource, dom_result);

      // fos.flush();
      // fos.close();
      Element result_element = ((Document) dom_result.getNode()).getDocumentElement();
      writeOutputXML(result_element, manifest_path_tmp);
      File tmp = new File(manifest_path_tmp);
      FileUtils.copyFile(tmp, manifest);

      tmp.delete();

    } catch (Exception e)
    {
      log.error(e.getMessage());
      e.printStackTrace();
      throw new TransformationException("Xslt transformation of imsmanifest.xml failed. " + e.getMessage());
    }
    return true;
  }

  /**
   * XSLT Transformation of imsmanifest.xml file using multiple stylesheets.
   * 
   * @param manifest
   * @param servletContext
   * @return
   * @throws TransformationException
   */
  private boolean convertSingleStylesheets(File manifest, String stylesheet) throws TransformationException
  {
    if (stylesheet != null)
    {
      try
      {
        TransformerFactory t_factory = TransformerFactory.newInstance();
        DocumentBuilderFactory fact = DocumentBuilderFactory.newInstance();
        fact.setNamespaceAware(true);
        DocumentBuilder builder = fact.newDocumentBuilder();

        InputStream inp = servletContext.getResourceAsStream(stylesheetDir + File.separator + stylesheet);
        StreamSource source = new StreamSource(inp, servletContext.getRealPath(stylesheetDir) + File.separator);
        javax.xml.transform.Transformer transformer = t_factory.newTransformer(source);

        Document xml_doc = builder.parse(new FileInputStream(manifest));
        DOMSource xml_dom_source = new DOMSource(xml_doc);
        DOMResult dom_result = new DOMResult();
        transformer.transform(xml_dom_source, dom_result);
        Element result_element = ((Document) dom_result.getNode()).getDocumentElement();
        String manifest_path = manifest.getPath();
        manifest.delete();
        writeOutputXML(result_element, manifest_path);

      } catch (Exception e)
      {
        log.error(e.getMessage());
        e.printStackTrace();
        throw new TransformationException("Xslt transformation of imsmanifest.xml failed. " + e.getMessage());
      }
      return true;
    } else
    {
      return false;
    }
  }

  /**
   * Save DOM element to the file.
   * 
   * @param result_element -
   *          DOM element
   * @param output -
   *          output file path
   * @throws Exception
   */
  protected void writeOutputXML(Element result_element, String output) throws Exception
  {
    FileOutputStream file_out_stream = new FileOutputStream(new File(output));
    OutputFormat outputFormat = new OutputFormat();
    String encoding = outputFormat.getEncoding();
    outputFormat.setIndenting(true);
    outputFormat.setIndent(2);
    Writer writer = new OutputStreamWriter(file_out_stream, encoding);
    XMLSerializer serializer = new XMLSerializer(writer, outputFormat);
    serializer.serialize(result_element);
    writer.flush();
    writer.close();
  }

  /**
   * javascript calls onLoad and onUnload in body tag are removed
   * 
   * @param file -
   *          html file
   */
  private void removeSCORMApiCalls(File file)
  {
    File temp = null;
    try
    {
      BufferedReader bf = new BufferedReader(new FileReader(file));
      // temporally file for output, is removed afterwards
      temp = new File(file.getCanonicalPath() + "_temp");
      BufferedWriter out = new BufferedWriter(new FileWriter(temp));
      String line = "";
      boolean found = false;

      // javascript calls onLoad and onUnload are removed.
      // <body onLoad="..." onUnload="..."> is replace by <body>
      // This calls usually initialize in SCORM package communication with LMS,
      // which throws
      // javascript error when content is not played in SCORM LMS

      while ((line = bf.readLine()) != null)
      {
        if (!found && line.matches(".*<\\s*[b|B][o|O][d|D][y|Y].*[o|O][n|N][l|L][o|O][a|A][d|D].*>.*"))
        {
          line = line.replaceFirst("<\\s*[b|B][o|O][d|D][y|Y].*[o|O][n|N][l|L][o|O][a|A][d|D].*>", "<body>");
          found = true;
        } else if (!found && line.matches(".*<\\s*[b|B][o|O][d|D][y|Y].*[o|O][n|N][u|U][n|N][l|L][o|O][a|A][d|D].*>.*"))
        {
          line = line.replaceFirst("<\\s*[b|B][o|O][d|D][y|Y].*[o|O][n|N][u|U][n|N][l|L][o|O][a|A][d|D].*>", "<body>");
          found = true;
        }

        out.write(line + "\n\r");
      }
      bf.close();
      out.close();
      FileUtils.copyFile(temp, file);
      temp.delete();
    } catch (Exception e)
    {
      log.error(e.getMessage());
      if (temp != null && temp.exists())
        temp.delete();
    }
  }

  /**
   * Add Scorm API calls to specified file.
   * 
   * @param file
   */
  private void addSCORMApiCalls(File file)
  {
    File temp = null;
    try
    {
      BufferedReader bf = new BufferedReader(new FileReader(file));
      // temporally file for output, is removed afterwards
      temp = new File(file.getCanonicalPath() + "_temp");
      BufferedWriter out = new BufferedWriter(new FileWriter(temp));
      String line = "";
      boolean foundBody = false;
      boolean foundHead = false;
      String scriptPath = findPathToScript(file, scoDir + "/APIWrapper.js");

      String script = "<script type='text/javascript' src='" + scriptPath + "'></script>";
      logger.info("Adding Scorm API calls to file " + file.getName());
      logger.info("\t 1) adding " + script);
      logger.info("\t 2) adding body onload initializeCommunication()");
      logger.info("\t 3) adding body onunload terminateCommunication()");
      String bodyElement = "<body onload='javascript:$onload$initializeCommunication();' onunload='javascript:$onunload$terminateCommunication();'>";
      while ((line = bf.readLine()) != null)
      {
        // add javascript file reference in head element
        if (!foundHead && line.matches(".*</\\s*[h|H][e|E][a|A][d|D].*>.*"))
        {

          line = line.replaceFirst("</\\s*[h|H][e|E][a|A][d|D].*>", script + "\n\r </head>");
          foundHead = true;
        }

        // add SCROM api calls as value in onload and onunload attributes of
        // body element
        if (!foundBody && line.matches(".*<\\s*[b|B][o|O][d|D][y|Y].*>.*"))
        {
          String onloadAttr = getOnloadAttribute(line);
          String onunloadAttr = getOnUnloadAttribute(line);
          bodyElement = bodyElement.replaceFirst("\\$onload\\$", onloadAttr).replaceFirst("\\$onunload\\$",
              onunloadAttr);
          line = line.replaceFirst("<\\s*[b|B][o|O][d|D][y|Y].*>", bodyElement);
          if (!foundHead)
            line = "<head>" + script + "</head>" + "\n\r" + line;
          foundBody = true;
        }
        out.write(line + "\n\r");
      }
      bf.close();
      out.close();
      FileUtils.copyFile(temp, file);
      temp.delete();
    } catch (Exception e)
    {
      log.error(e.getMessage());
      if (temp != null && temp.exists())
        temp.delete();
    }

  }

  /**
   * The prefix xml is by definition bound to the namespace name
   * http://www.w3.org/XML/1998/namespace In IMS CP 1.1.3 (possibly as well in
   * SCORM 1.2) was bug that the http://www.w3.org/XML/1998/namespace was bound
   * to prefix 'x'. This method fix the result file by replacing all x:base and
   * x:lang attributes by xml:base and xml:lang.
   * 
   * @param file
   *          manifest
   */
  private void checkXMLNamespacePrefix(File manifest)
  {
    File temp = null;
    try
    {
      BufferedReader bf = new BufferedReader(new FileReader(manifest));
      // temporally file for output, is removed afterwards
      temp = new File(manifest.getCanonicalPath() + "_temp");
      BufferedWriter out = new BufferedWriter(new FileWriter(temp));
      String line = "";

      while ((line = bf.readLine()) != null)
      {
        line = line.replaceAll(" x:base", " xml:base");
        line = line.replaceAll(" x:lang", " xml:lang");
        out.write(line + "\n\r");
      }
      bf.close();
      out.close();
      FileUtils.copyFile(temp, manifest);
      temp.delete();
    } catch (Exception e)
    {
      log.error(e.getMessage());
      if (temp != null && temp.exists())
        temp.delete();
    }
  }

  /**
   * Returns relative path from the file to the object specified by the path
   * 
   * @param file -
   *          current context for the relative path
   * @param path -
   *          path of the object which is located in root dir of imsmanifest.xml
   *          file
   * @return
   */
  private String findPathToScript(File file, String path)
  {

    File[] children = (file.getParentFile()).listFiles();
    boolean found = false;
    for (File f : children)
    {
      if ("imsmanifest.xml".equals(f.getName()))
      {
        found = true;
        break;
      }
    }
    // if found is true we are in root directory containing imsmanifest.xml
    if (found)
      return path;
    // otherwise we search recursively parent directory
    else
      return findPathToScript(file.getParentFile(), "../" + path);
  }

  /**
   * return value of onload attribute
   * 
   * @param line -
   *          html line
   * @return
   */
  private String getOnloadAttribute(String line)
  {
    String method = "";
    if (line.matches(".*<\\s*[b|B][o|O][d|D][y|Y].*[o|O][n|N][l|L][o|O][a|A][d|D]\\s*=.*>.*"))
    {
      line = line.replaceFirst("[o|O][n|N][l|L][o|O][a|A][d|D]\\s*=", "onload=");
      String rest = line.substring(line.indexOf("onload=") + 7).trim();
      char quot = rest.charAt(0);
      method = rest.substring(1, rest.indexOf(quot, 1)).trim();
      if (method.matches("javascript\\s*:.*"))
      {
        method = method.replaceFirst("javascript(\\s)*:", "");
      }
      method.concat(", ");
      method += "; ";
    }
    return method;
  }

  /**
   * return value of onUnload attribute
   * 
   * @param line -
   *          html line
   * @return
   */
  private String getOnUnloadAttribute(String line)
  {
    String method = "";
    if (line.matches(".*<\\s*[b|B][o|O][d|D][y|Y].*[o|O][n|N][u|U][n|N][l|L][o|O][a|A][d|D]\\s*=.*>.*"))
    {
      line = line.replaceFirst("[o|O][n|N][u|U][n|N][l|L][o|O][a|A][d|D]\\s*=", "onunload=");
      String rest = line.substring(line.indexOf("onunload=") + 9).trim();
      char quot = rest.charAt(0);
      method = rest.substring(1, rest.indexOf(quot, 1)).trim();
      if (method.matches("javascript\\s*:.*"))
      {
        method = method.replaceFirst("javascript(\\s)*:", "");
      }
      method += "; ";
    }
    return method;
  }

  public String getTargetVersion()
  {
    return targetVersion;
  }

  public void setTargetVersion(String targetVersion)
  {
    this.targetVersion = targetVersion;
  }

  public String getSourceVersion()
  {
    return sourceVersion;
  }

  public void setSourceVersion(String sourceVersion)
  {
    this.sourceVersion = sourceVersion;
  }

  public File getContentPackage()
  {
    return contentPackage;
  }

  public void setContentPackage(File contentPackage)
  {
    this.contentPackage = contentPackage;
  }

  public String getFilename()
  {
    return filename;
  }

  public void setFilename(String filename)
  {
    this.filename = filename;
  }

  public ServletContext getServletContext()
  {
    return servletContext;
  }

  public void setServletContext(ServletContext servletContext)
  {
    this.servletContext = servletContext;
  }

  
  private void closeLogFile() {
    Handler[] handlers = logger.getHandlers();
    for (Handler h: handlers)
    {  
      h.close();
      logger.removeHandler(h);
    }
 }
  
  
  // main method only for testing purpose
  public static void main(String[] args)
  {
  }

}