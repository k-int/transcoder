package com.k_int.transcoder.service;

import java.io.File;

import javax.servlet.ServletContext;

import com.k_int.transcoder.transform.PackageVersion;
import com.k_int.transcoder.transform.Transformation;
import com.k_int.transcoder.transform.TransformationException;

public class TranscoderImpl implements Transcoder
{
  public void transcode(File file, String filename, String targetFormat, String email)  
  {
      
  }

  
  public TranscoderResult transcode(File file, String filename, String targetFormat, ServletContext servletContext) throws TransformationException 
  {
    Transformation t = new Transformation(file, filename, targetFormat, servletContext);
    File convertedFile = t.transform();
    String sourceVersion = t.getSourceVersion();
    File logFile = t.getLogFile();
    TranscoderResult result = new TranscoderResult(convertedFile, logFile, sourceVersion);
    return result;   
  }
  
  
}