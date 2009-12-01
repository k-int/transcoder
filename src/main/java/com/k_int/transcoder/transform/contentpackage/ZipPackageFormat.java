package com.k_int.transcoder.transform.contentpackage;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.Deflater;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

public class ZipPackageFormat implements PackageFormat
{

 
  public File pack(File[] files, File outputFile, File rootDir)
  {
    if (files == null)
    {
      return null;
    }
    try
    {

      ZipOutputStream out = new ZipOutputStream(new FileOutputStream(outputFile.getPath()));
      // Set the compression ratio
      out.setLevel(Deflater.DEFAULT_COMPRESSION);
      // iterate through the array of files, adding each to the zip file
      for (File f : files)
      {
        addEntry(out, f, rootDir);
      }
      // Close the ZipOutPutStream
      out.close();
    } catch (IllegalArgumentException iae)
    {
      outputFile = null;
      iae.printStackTrace();
    } catch (FileNotFoundException fnfe)
    {
      outputFile = null;
      fnfe.printStackTrace();
    } catch (IOException ioe)
    {
      outputFile = null;
      ioe.printStackTrace();
    }
    return outputFile;
  }

  private void addEntry(ZipOutputStream out, File f, File rootDir) throws IOException
  {

    String path = f.getCanonicalPath()
        .substring(rootDir.getCanonicalPath().length() + 1, f.getCanonicalPath().length());
    if (f.isFile())
    {
      out.putNextEntry(new ZipEntry(path));
      byte[] buffer = new byte[18024];
      FileInputStream in = new FileInputStream(f);
      int len;
      while ((len = in.read(buffer)) > 0)
      {
        out.write(buffer, 0, len);
      }
      in.close();
      out.closeEntry();
    } else if (f.isDirectory())
    {
      File[] list = f.listFiles();
      for (File l : list)
      {
        addEntry(out, l, rootDir);
      }
    }
  }

  public List<File> unpack(File contentPackage, File dir)
  {
    List<File> files = new ArrayList<File>();
    try
    {
      final int BUFFER = 2048;
      BufferedOutputStream dest = null;
      FileInputStream fis = new FileInputStream(contentPackage);
      ZipInputStream zis = new ZipInputStream(new BufferedInputStream(fis));
      ZipEntry entry;
      while ((entry = zis.getNextEntry()) != null)
      {
       
        int count;
        byte data[] = new byte[BUFFER];
        // write the files to the disk
        File f = new File(dir, entry.getName());
        if (entry.isDirectory())
        {
          f.mkdir();
        }
        else
        {  
          new File(f.getParent()).mkdirs();
          FileOutputStream fos = new FileOutputStream(f);
          dest = new BufferedOutputStream(fos, BUFFER);
          while ((count = zis.read(data, 0, BUFFER)) != -1)
          {
            dest.write(data, 0, count);
          }
          dest.flush();
          dest.close();
          files.add(f);
        }
      }
      zis.close();
    } catch (Exception e)
    {
      e.printStackTrace();
    }
    return files;
  }

  // main method only for testing purpose
  public static void main(String[] args)
  {
   
  }

}