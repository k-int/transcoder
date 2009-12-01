package com.k_int.transcoder.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.util.Collection;
import java.util.Date;
import java.util.Properties;
import java.util.ResourceBundle;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.apache.struts2.interceptor.ServletResponseAware;
import org.apache.struts2.util.ServletContextAware;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

import com.k_int.transcoder.form.Upload;
import com.k_int.transcoder.service.Transcoder;
import com.k_int.transcoder.service.TranscoderResult;
import com.k_int.transcoder.transform.TransformationException;
import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

/*
 *  This action takes content package as an input, calls transformation for conversion package and
 *  return the converted package in response.
 *  It also save both uploaded and converted package on the disk and save info about upload in DB.
 *  It also send mail to user with link to feedback form.
 *   
 */

public class UploadFileAction extends ActionSupport implements ServletResponseAware, ApplicationContextAware,
    ServletContextAware
{

  private HttpServletResponse response;
  private ServletContext servletContext;
  private ApplicationContext ctx;

  private File upload;
  private Long uploadId;
  private String uploadFileName;
  private String uploadContentType;

  private String mail;
  private String targetFormat;
  private String uploadRepPath = "WEB-INF/upload-repository";

  private static org.apache.log4j.Logger log = Logger.getLogger(UploadFileAction.class);

  public String execute()
  {
    File convertedFile = null;
    File logFile = null;
    File subDir = null;
    String sourceVersion = null;
    if (!this.hasActionErrors() && !this.hasFieldErrors())
    {
      if (upload != null)
      {
        try
        {
          File rootDir = new File(this.getServletContext().getRealPath(uploadRepPath));
          if (!rootDir.exists())
            rootDir.mkdir();

          // name of sub directory is created as filename concatenate with time
          // in millis in hex form
          subDir = new File(rootDir, uploadFileName.substring(0, uploadFileName.lastIndexOf("."))
              + Long.toHexString((new Date()).getTime()));
          subDir.mkdir();

          File save_file = new File(subDir, uploadFileName);
          FileUtils.copyFile(upload, save_file);
          uploadId = saveUpload(subDir.getPath());

          if (!"upload".equals(targetFormat))
          {
            Transcoder t = (Transcoder) ctx.getBean("TranscoderService");
            TranscoderResult result = t.transcode(upload, uploadFileName, targetFormat, this.getServletContext());
            convertedFile = result.getConvertedPackage();
            logFile = result.getLogFile();
            sourceVersion = result.getSourceVersion();
          }
        } catch (TransformationException te)
        {
          this.addActionError(te.getMessage());
          log.error(te.getMessage());
        }
        catch (Exception e)
        {
          String exc = e.getMessage();
          if (exc==null)
          {
             exc = "Internal error.";
          }
          this.addActionError(exc);
          log.error(exc);
          e.printStackTrace();
        }

        if (convertedFile != null)
        {
          // save converted file on a disk
          File save_converted_file = new File(subDir, "converted_" + uploadFileName);
          String logName = "log_" + uploadFileName.substring(0, uploadFileName.indexOf(".")) + ".txt";
          File save_log_file = new File(subDir, logName);
          try
          {
            FileUtils.copyFile(convertedFile, save_converted_file);
            FileUtils.copyFile(logFile, save_log_file);
            convertedFile.delete();
            logFile.delete();
            File log_file_lock = new File(subDir, logName + ".lck");
            if (log_file_lock.exists())
              log_file_lock.delete();
           
          } catch (Exception e)
          {
            log.error(e.getMessage());
          }

          // send a mail to user
          if (uploadId != null && getMail()!=null && !"".equals(getMail()))
          {
            ResourceBundle bundle = ResourceBundle.getBundle("transcoder");
            String from = bundle.getString("mail.from.address");
            String smtp = bundle.getString("mail.smpt.server");
            String url = bundle.getString("web.url");
            String download, form;

            if (from == null || smtp == null || url == null)
            {
              log.error("Some of the requiered settings are not specified: from address " + from + ", smtp " + smtp
                  + " web app url " + url);
              this.addActionError("Sorry, Mail couldn't have been send.");
            } else
            {
              download = url.concat("/download?upload_id=" + uploadId);
              form = url.concat("/form?upload_id=" + uploadId);
              // set valid url from properties file
              String text = this.getText("transcoder.mail.text", new String[]{ download, form });
              if (text != null)
              {
                this.sendMail(smtp, new String[]
                { this.getMail() }, this.getText("transcoder.mail.subject"), text, from);
              }
            }
          }
          // downloadFile(convertedFile, uploadContentType);
        } else if (!"upload".equals(targetFormat))
        {
          this.addActionError("Transformation wasn't successful.");
        }
      } else
      {
        this.addActionError(this.getText("transcoder.upload.not.successful"));
        log.error("File upload failed.");
      }
    }
    if ( uploadId > 0)
    {
      updateRecord(uploadId, sourceVersion, getActionErrors());
    }
    if ("upload".equals(targetFormat) || convertedFile != null)
      return Action.SUCCESS;
    else
      return Action.ERROR;
      
  }

  /**
   * Save record in DB about uploaded file
   * 
   * @param subDir -
   *          path where is the uploaded file saved
   * @return
   */
  private Long saveUpload(String subDir)
  {
    Session sess = null;
    Long id = null;
    SessionFactory factory = (SessionFactory) ctx.getBean("TranscoderSessionFactory");
    try
    {
      sess = factory.openSession();
      Transaction tx = sess.beginTransaction();

      Upload record = new Upload();
      record.setFilename(this.getuploadFileName());
      record.setPath(subDir);
      record.setEmail(this.getMail());
      record.setUploadDate(new Date());
      record.setTarget(this.getTargetFormat());
      record.setContenType(this.getuploadContentType());
      sess.saveOrUpdate(record);
      sess.flush();
      tx.commit();
      id = record.getId();
    } catch (HibernateException he)
    {
      log.error(he.getMessage());
    } finally
    {
      if (sess != null)
        try
        {
          sess.close();
        } catch (Exception e)
        {
        }
    }
    return id;
  }

  private void updateRecord(Long recordId, String sourceVersion, Collection errors)
  {
    Session sess = null;
    SessionFactory factory = (SessionFactory) ctx.getBean("TranscoderSessionFactory");
    try
    {
      sess = factory.openSession();
      Transaction tx = sess.beginTransaction();
      Upload record = (Upload) sess.get(Upload.class, recordId);
      String error = "";
      for (Object e : errors)
      {
        if (e != null)
          error = error.concat((String) e);
      }
      if (!"".equals(error))
        record.setError(error==null?"null":error);
      if (sourceVersion!=null)
        record.setSource(sourceVersion);
      
      sess.saveOrUpdate(record);
      sess.flush();
      tx.commit();
      
    } catch (HibernateException he)
    {
      he.printStackTrace();
      log.error(he.getMessage());
    } finally
    {
      if (sess != null)
        try
        {
          sess.close();
        } catch (Exception e)
        {
          e.printStackTrace();
        }
    }
  }

  /**
   * Download of the converted package
   * 
   * @param file -
   *          converted package
   * @param contentType -
   *          content type of converted package
   */
  private void downloadFile(File file, String contentType)
  {
    try
    {

      FileInputStream fileIn = new FileInputStream(file);
      OutputStream out = response.getOutputStream();
      response.setContentType(contentType);
      response.setContentLength((int) file.length());
      response.addHeader("Content-Disposition", "attachment; filename=" + "converted_" + uploadFileName);
      byte[] buffer = new byte[2048];
      int bytesRead = fileIn.read(buffer);
      while (bytesRead >= 0)
      {
        if (bytesRead > 0)
          out.write(buffer, 0, bytesRead);
        bytesRead = fileIn.read(buffer);
      }
      out.flush();
      out.close();
      fileIn.close();
      file.delete();
    } catch (Exception e)
    {
      e.printStackTrace();
      this.addActionError("Sorry, downloading of the converted content package failed because of " + e.getMessage());
    }
  }

  public void sendMail(String smtpServer, String recipients[], String subject, String message,

  String from)
  {
    boolean debug = false;

    // Set the host smtp address
    Properties props = new Properties();
    props.put("mail.smtp.host", smtpServer);

    // create some properties and get the default Session
    javax.mail.Session session = javax.mail.Session.getDefaultInstance(props, null);
    session.setDebug(debug);

    try
    {
      // create a message
      Message msg = new MimeMessage(session);

      // set the from and to address
      InternetAddress addressFrom = new InternetAddress(from);
      msg.setFrom(addressFrom);

      InternetAddress[] addressTo = new InternetAddress[recipients.length];
      for (int i = 0; i < recipients.length; i++)
      {
        addressTo[i] = new InternetAddress(recipients[i]);
      }
      msg.setRecipients(Message.RecipientType.TO, addressTo);

      // Setting the Subject and Content Type
      msg.setSubject(subject);
      msg.setContent(message, "text/plain");

      // send message
      Transport.send(msg);
    } catch (MessagingException me)
    {
      log.error(me.getMessage());
      this.addActionError("Sorry, Mail couldn't have been send." + me.getMessage());
    }
  }

  public String getMail()
  {
    return mail;
  }

  public void setApplicationContext(ApplicationContext ctx) throws BeansException
  {
    this.ctx = ctx;
  }

  public void setMail(String mail)
  {
    this.mail = mail;
  }

  public File getupload()
  {
    return upload;
  }

  public void setupload(File upload)
  {
    this.upload = upload;
  }

  public String getuploadFileName()
  {
    return uploadFileName;
  }

  public void setuploadFileName(String uploadFileName)
  {
    this.uploadFileName = uploadFileName;
  }

  public String getuploadContentType()
  {
    return uploadContentType;
  }

  public void setuploadContentType(String uploadContentType)
  {
    this.uploadContentType = uploadContentType;
  }

  public String getTargetFormat()
  {
    return targetFormat;
  }

  public void setTargetFormat(String targetFormat)
  {
    this.targetFormat = targetFormat;
  }

  public void setServletResponse(HttpServletResponse response)
  {
    this.response = response;
  }

  public HttpServletResponse getServletResponse()
  {
    return response;
  }

  public ServletContext getServletContext()
  {
    return servletContext;
  }

  public void setServletContext(ServletContext servletContext)
  {
    this.servletContext = servletContext;
  }

  public Long getUploadId()
  {
    return uploadId;
  }

  public void setUploadId(Long uploadId)
  {
    this.uploadId = uploadId;
  }
  
  
  
  
}
