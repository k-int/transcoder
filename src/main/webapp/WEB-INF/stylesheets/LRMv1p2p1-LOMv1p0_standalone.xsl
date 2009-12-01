<?xml version = "1.0" encoding = "UTF-8"?>
<xsl:transform version = "1.0" xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance" 
	 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method = "xml" indent="yes"/>
 <xsl:strip-space elements="*"/>
<xsl:include href="LRMv1p2p1-LOMv1p0.xsl"/>

   <!-- generic templates  -->
   <xsl:template name = "wildcard">
   	<xsl:for-each select = "*">
		<xsl:if test = "namespace-uri() != 'http://www.imsglobal.org/xsd/imsmd_rootv1p2p1'">
			<xsl:copy-of select = "."/>
		</xsl:if>	
	</xsl:for-each>
   </xsl:template>
  
   <xsl:template match="*">
       <xsl:if test = "namespace-uri() != 'http://www.imsglobal.org/xsd/imsmd_rootv1p2p1'">
			<xsl:copy-of select = "."/>
		</xsl:if>
    </xsl:template>
</xsl:transform>
