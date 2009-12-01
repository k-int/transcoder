package com.k_int.transcoder.action;

import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;

import org.apache.struts2.interceptor.ServletRequestAware;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

import com.opensymphony.xwork2.Action;
import com.opensymphony.xwork2.ActionSupport;

public class AcknowledgementAction extends ActionSupport implements ApplicationContextAware, ServletRequestAware
{

  private ApplicationContext ctx;
  private HttpServletRequest request;
  
  private long people = 0;
  private long packages = 0;
  private long feedback = 0;
  private String uploadId;
  
  public void setServletRequest(HttpServletRequest request)
  {
    this.request = request;
  }
  
  public String execute()
  {
    getStatistics();
    return Action.SUCCESS;
  }

  private void getStatistics()
  {
    Session sess = null;
    Long id = null;
    SessionFactory factory = (SessionFactory) ctx.getBean("TranscoderSessionFactory");
    try
    {
      sess = factory.openSession();
      Transaction tx = sess.beginTransaction();
      // sess.createSQLQuery("selec")

      String SQL_QUERY = "select count(distinct email) from Upload upload";
      Query query = sess.createQuery(SQL_QUERY);
      people = (Long)(query.list().get(0));
     
      SQL_QUERY = "select count(*) from Upload upload";
      query = sess.createQuery(SQL_QUERY);
      packages = (Long)(query.list().get(0));
      
      SQL_QUERY = "select count(*) from Form form";
      query = sess.createQuery(SQL_QUERY);
      feedback = (Long)(query.list().get(0));
      

      sess.flush();
      tx.commit();
    } catch (HibernateException he)
    {
      he.printStackTrace();

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

  }

  public void setApplicationContext(ApplicationContext ctx)
  {
    this.ctx = ctx;
  }

  public long getPeople()
  {
    return people;
  }

  public void setPeople(long people)
  {
    this.people = people;
  }

  public long getPackages()
  {
    return packages;
  }

  public void setPackages(long packages)
  {
    this.packages = packages;
  }

  public long getFeedback()
  {
    return feedback;
  }

  public void setFeedback(long feedback)
  {
    this.feedback = feedback;
  }

  public String getUploadId()
  {
    return uploadId;
  }

  public void setUploadId(String uploadId)
  {
    this.uploadId = uploadId;
  }
  
  
  
  
}