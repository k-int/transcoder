package com.k_int.transcoder.transform.contentpackage;

import java.io.File;
import java.util.List;

public interface PackageFormat{
  
  List<File> unpack (File contentPackage, File outputDir);
  File pack (File[] files, File outputFile, File rootDir);
  
}