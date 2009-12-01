package com.k_int.transcoder.service;

import java.io.File;

public class TranscoderResult{
  
  File convertedPackage;
  File logFile;
  String sourceVersion;
  
  TranscoderResult(File convertedPackage, File logFile, String sourceVersion)
  {
    this.convertedPackage = convertedPackage;
    this.sourceVersion = sourceVersion;
    this.logFile = logFile;
  }
  
  public File getConvertedPackage()
  {
    return convertedPackage;
  }
  
  public void setConvertedPackage(File convertedPackage)
  {
    this.convertedPackage = convertedPackage;
  }
  
  public String getSourceVersion()
  {
    return sourceVersion;
  }
  
  public void setSourceVersion(String sourceVersion)
  {
    this.sourceVersion = sourceVersion;
  }

  public File getLogFile()
  {
    return logFile;
  }

  public void setLogFile(File logFile)
  {
    this.logFile = logFile;
  }
  
}