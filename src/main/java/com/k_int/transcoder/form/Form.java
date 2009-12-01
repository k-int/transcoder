package com.k_int.transcoder.form;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

import com.opensymphony.xwork2.Action;

@Entity
@Table(name = "FORM")
public class Form implements ApplicationContextAware
{

  private Long id;
  private Long uploadId;
  private String success;
  private String lmsName;
  private String lmsVersion;
  private String errors;

  private ApplicationContext ctx;

  public String execute()
  {
    saveForm();
    return Action.SUCCESS;
  }

  
  public Form()
  {
  }
  
  private void saveForm()
  {
    Session sess = null;
    SessionFactory factory = (SessionFactory) ctx.getBean("TranscoderSessionFactory");
    try
    {
      sess = factory.openSession();
      Transaction tx = sess.beginTransaction();
      sess.saveOrUpdate(this);
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

  @Transient
  public ApplicationContext getApplicationContext()
  {
    return ctx;
  }

  public void setApplicationContext(ApplicationContext ctx) throws BeansException
  {
    this.ctx = ctx;
  }

  @Id
  @Column(name = "ID")
  @GeneratedValue(strategy = GenerationType.AUTO)
  public Long getId()
  {
    return id;
  }

  public void setId(Long id)
  {
    this.id = id;
  }

  @Column(name = "UPLOAD_ID")
  public Long getUploadId()
  {
    return uploadId;
  }

  public void setUploadId(Long uploadId)
  {
    this.uploadId = uploadId;
  }

  @Column(name = "SUCCESS")
  public String getSuccess()
  {
    return success;
  }

  public void setSuccess(String success)
  {
    this.success = success;
  }

  @Column(name = "LMS_NAME")
  public String getLmsName()
  {
    return lmsName;
  }

  public void setLmsName(String lmsName)
  {
    this.lmsName = lmsName;
  }

  @Column(name = "LMS_VERSION")
  public String getLmsVersion()
  {
    return lmsVersion;
  }

  public void setLmsVersion(String lmsVersion)
  {
    this.lmsVersion = lmsVersion;
  }

  @Column(name = "ERRORS")
  public String getErrors()
  {
    return errors;
  }

  public void setErrors(String errors)
  {
    this.errors = errors;
  }

}