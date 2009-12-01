package com.k_int.transcoder.transform;



public class PackageVersion{
  
  
  public static final String ZERO_CONVERSION = "Zero Conversion";
  public static final String SCORM_1_2 = "SCORM 1.2";
  public static final String SCORM_2004 = "SCORM 2004";
  public static final String IMS_CP_1_1_3 = "IMS CP 1.1.3";
  public static final String IMS_CP_1_1_4 = "IMS CP 1.1.4";
  public static final String IMS_CP_1_2 = "IMS CP 1.2";
  public static final String IMS_CC_1_0_0 = "IMS Common Cartridge 1.0";

    
  public static String[] getRequiredSchemas(String packageVersion)
  {
    if (IMS_CP_1_1_4.equals(packageVersion))
    {
      return new String[]{"imscp_v1p1.xsd",
                          "imsmd_v1p2p4.xsd",
                          "datatypes.dtd",
                          "XMLSchema.dtd",
                          "xml.xsd",};
    }
    if (IMS_CP_1_1_3.equals(packageVersion))
    {
      return new String[]{"imscp_v1p1.xsd",
                          "imsmd_v1p2p4.xsd",
                          "datatypes.dtd",
                          "XMLSchema.dtd",
                          "xml.xsd",};
    }
    else if (SCORM_2004.equals(packageVersion))
    {
      return new String[]{"imscp_v1p1.xsd",
                          "adlnav_v1p3.xsd",
                          "adlseq_v1p3.xsd",
                          "datatypes.dtd",
                          "adlcp_v1p3.xsd",
                          "XMLSchema.dtd",
                          "xml.xsd",
                          "lom","imss"};
    }
    else if (SCORM_1_2.equals(packageVersion))
    {
      return new String[]{"adlcp_rootv1p2.xsd",
                          "imsmd_rootv1p2p1.xsd",
                          "imscp_rootv1p1p2.xsd",
                          "ims_xml.xsd"};
    }
    else
    {  
      return new String[0];
    }  
  }
  
  public static boolean isSupportedSource(String version)
  {
    if (PackageVersion.IMS_CC_1_0_0.equals(version)
        || PackageVersion.IMS_CP_1_1_3.equals(version)
        || PackageVersion.IMS_CP_1_1_4.equals(version)
        || PackageVersion.SCORM_2004.equals(version)
        || PackageVersion.SCORM_1_2.equals(version)) 
        return true;
    else
      return false;
  }
  
  public static boolean isSupportedTarget(String version)
  {
    if (PackageVersion.IMS_CC_1_0_0.equals(version)
        || PackageVersion.IMS_CP_1_1_4.equals(version)
        || PackageVersion.SCORM_2004.equals(version))
      
        return true;
    else
      return false;
  }
  
  
}