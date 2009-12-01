package com.k_int.transcoder.form;

import java.util.Date;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;

@Entity
@Table(name = "UPLOAD")
public class Upload
{

  private Long id;
  private Date uploadDate;
  private String path;
  private String filename;
  private String contenType;
  private String target;
  private String source;
  private String email;
  private String error;

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

  @Column(name = "UPLOAD_DATE")
  public Date getUploadDate()
  {
    return uploadDate;
  }

  public void setUploadDate(Date uploadDate)
  {
    this.uploadDate = uploadDate;
  }

  @Column(name = "PATH")
  public String getPath()
  {
    return path;
  }

  public void setPath(String path)
  {
    this.path = path;
  }

  @Column(name = "FILENAME")
  public String getFilename()
  {
    return filename;
  }

  public void setFilename(String filename)
  {
    this.filename = filename;
  }

  @Column(name = "TARGET")
  public String getTarget()
  {
    return target;
  }

  public void setTarget(String target)
  {
    this.target = target;
  }
  
  
  
  @Column(name = "EMAIL")
  public String getEmail()
  {
    return email;
  }

  public void setEmail(String email)
  {
    this.email = email;
  }

  
  @Column(name = "CONTENT_TYPE")
  public String getContenType()
  {
    return contenType;
  }

  public void setContenType(String contenType)
  {
    this.contenType = contenType;
  }
  
  @Column(name = "ERROR")
  public String getError()
  {
    return error;
  }

  public void setError(String error)
  {
    this.error = error;
  }

  @Column(name = "SOURCE")
  public String getSource()
  {
    return source;
  }

  public void setSource(String source)
  {
    this.source = source;
  }
  
}