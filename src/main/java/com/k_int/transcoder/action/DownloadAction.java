package com.k_int.transcoder.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts2.interceptor.ServletRequestAware;
import org.apache.struts2.interceptor.ServletResponseAware;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

import com.k_int.transcoder.form.Upload;
import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;




public class DownloadAction extends ActionSupport implements ServletResponseAware, ServletRequestAware, ApplicationContextAware
    
{

  private HttpServletResponse response;
  private HttpServletRequest request;
  private ApplicationContext ctx;
 
  private String uploadRepPath = "WEB-INF/upload-repository";

  private static org.apache.log4j.Logger log = Logger.getLogger(UploadFileAction.class);

  public String execute()
  {
       long id = Long.valueOf(request.getParameter("upload_id"));
       String what = request.getParameter("what");

       Upload upload = getUploadRecord(id);
       String path = "";
       String contentType;
       if ("log".equals(what))
       {  
         String logName = "log_" + upload.getFilename().substring(0, upload.getFilename().indexOf(".")) + ".txt";
         path = upload.getPath() + File.separator + logName;
         contentType = "text/plain";
       }  
       else
       {  
         path = upload.getPath() + File.separator + "converted_" + upload.getFilename();
         contentType = upload.getContenType();
       }  
       File file = new File(path);
       if (file.exists())
       {  
         downloadFile(file, contentType);
         return Action.NONE;
       }
       else
       { 
         return Action.ERROR;
       }  
  }

  
  /** Save record in DB about uploaded file
   * 
   * @param subDir - path where is the uploaded file saved
   * @return
   */
  private Upload getUploadRecord(long id)
  {
    Session sess = null;
    Upload upload = null;
    SessionFactory factory = (SessionFactory) ctx.getBean("TranscoderSessionFactory");
    try
    {
      sess = factory.openSession();
      Transaction tx = sess.beginTransaction();

      String query = "from Upload u where u.id = " + id;
      Query q = sess.createQuery(query);
      if (!q.list().isEmpty())
        upload = (Upload)q.list().get(0);
      sess.flush();
      tx.commit();
    
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
    return upload;
  }

  /** Download of the converted package
   * 
   * @param file - converted package
   * @param contentType - content type of converted package
   */
  private void downloadFile(File file, String contentType)
  {
    try
    {

      FileInputStream fileIn = new FileInputStream(file);
      OutputStream out = response.getOutputStream();
      response.setContentType(contentType);
      response.setContentLength((int) file.length());
      response.addHeader("Content-Disposition", "attachment; filename=" + file.getName());
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
    } catch (Exception e)
    {
      e.printStackTrace();
      this.addActionError("Sorry, downloading of the converted content package failed because of " + e.getMessage());
    }
  }


  public void setApplicationContext(ApplicationContext ctx) throws BeansException
  {
    this.ctx = ctx;
  }


  public void setServletResponse(HttpServletResponse response)
  {
    this.response = response;
  }

  public HttpServletResponse getServletResponse()
  {
    return response;
  }

  
  public void setServletRequest(HttpServletRequest request)
  {
    this.request = request;
  }

  public HttpServletRequest getServletRequest()
  {
    return request;
  }


 
}
