package com.k_int.transcoder.service;

import java.io.File;

import javax.servlet.ServletContext;

import com.k_int.transcoder.transform.TransformationException;


public interface Transcoder{

  void transcode(File file, String filename, String targetFormat, String email);
  
  //File transcode(File file, String filename,  String targetFormat, ServletContext servletContext) throws TransformationException;

  TranscoderResult transcode(File file, String filename,  String targetFormat, ServletContext servletContext) throws TransformationException;
  
}