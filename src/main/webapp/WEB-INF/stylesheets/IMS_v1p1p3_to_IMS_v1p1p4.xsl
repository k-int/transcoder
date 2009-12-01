<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:imscp="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_v1p2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="imscp xml">

<xsl:include href="shared_templates.xsl"/>    

<xsl:output indent="yes" method="xml"/>
<xsl:strip-space elements="*"/>

<xsl:template match="imscp:manifest">
	<!-- Parsing original xsi:schemaLocation attribute and remove unnecessary schemas -->	
        <xsl:variable name="schema">
			<xsl:if test="@xsi:schemaLocation">
				<xsl:call-template name="schemaLocationParsing">
						<xsl:with-param name="original" select="normalize-space(@xsi:schemaLocation)" />
				</xsl:call-template>
			</xsl:if>
			</xsl:variable>

      <xsl:variable name="schemaLocation">
	 	<xsl:variable name="requiredSchema">
			http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd
                </xsl:variable>
		<xsl:value-of select="normalize-space(concat($schema,' ',$requiredSchema))"/>	
     </xsl:variable>		
	
     <xsl:comment>*Transcoder Comment*: This file has transformed by Transcoder service.</xsl:comment>
     <xsl:comment>*Transcoder Comment*: Namespace definition and schema location changed.</xsl:comment>
     <xsl:comment>*Transcoder Comment*: Attributte 'version' set to 'IMS CP 1.1.4'</xsl:comment>
     
     
    <manifest identifier="{@identifier}" 
          xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	  	  xsi:schemaLocation="{$schemaLocation}" 
	  version="IMS CP 1.1.4">
	  
	    <xsl:if test="@xml:base">
		      <xsl:attribute name="xml:base">
			<xsl:value-of select="@xml:base"/>
		      </xsl:attribute>
	    </xsl:if>
	    
	   <metadata>
	    	<schema>IMS Content</schema>
		<schemaversion>1.1</schemaversion>
		<xsl:apply-templates select="imscp:metadata/*"/>
	    </metadata>
	    <xsl:apply-templates select="comment()"/>
            <xsl:for-each select="*">
	    	<xsl:if test="local-name()!='metadata'">
	    		<xsl:apply-templates select="."/>
		</xsl:if>
	    </xsl:for-each>
        </manifest>
    </xsl:template>
    
    
  
  
   
   <xsl:template match="imscp:*">
      	<xsl:element  name="{local-name()}"> 
		<xsl:apply-templates select="@*"/>
		  <xsl:for-each select="text()">
			<xsl:value-of select="."/>
		  </xsl:for-each>
		  <xsl:apply-templates select="comment()"/>
		  <xsl:apply-templates select="*"/>
	</xsl:element>
    </xsl:template>
   
     <xsl:template match="@*">
     	<xsl:if test=".!=''">	
    	 <xsl:choose>
		<xsl:when test="local-name()='base'">
			<xsl:attribute name = "xml:base">
				<xsl:call-template  name="XMLBaseCheck">
					<xsl:with-param name="base" select="."/>
				</xsl:call-template>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="local-name()='lang'">
			<xsl:attribute name = "xml:lang">
				<xsl:value-of select = "."/>
			</xsl:attribute>
		</xsl:when>
	 	<xsl:when test = "namespace-uri()!='' and namespace-uri() != 'http://www.imsglobal.org/xsd/imscp_v1p1'">
			<xsl:attribute name = "{local-name()}" namespace = "{namespace-uri()}">
				<xsl:value-of select = "."/>
			</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="{local-name()}"> 
			<xsl:choose>
				<xsl:when test="local-name()='href'">
					<xsl:call-template name="checkHref">
						<xsl:with-param name="href" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>	
			</xsl:choose>		
                </xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:if>	
    </xsl:template>
   
   <!-- generic template for elements that are not from imscp namespace -->
<!--
   <xsl:template match="*">
       <xsl:if test = "namespace-uri() != $imsmdNamespacev1p2p4">
		<xsl:copy-of select = "."/>
	</xsl:if>
    </xsl:template>
-->

   <xsl:template match="*">
       	<xsl:copy-of select = "."/>
    </xsl:template>
  
   
    
    <xsl:template match="imscp:schema"/>
    <xsl:template match="imscp:schemaversion"/>
  
    
  
    <!-- Template for parsing xsi:schemaLocation attribute and remove unnecessary schemas -->
    <xsl:template name="schemaLocationParsing">
    	<xsl:param name="original"/>
	<xsl:variable name="namespace" select="substring-before($original, ' ')"/>
	<xsl:variable name="schema">
		<xsl:variable name="rest" select="normalize-space(substring-after($original,$namespace))"/>
		<xsl:choose>
			<xsl:when test="contains($rest,' ')">
				<xsl:value-of select="substring-before($rest,' ')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$rest"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>
	<xsl:variable name="remainder" select="normalize-space(substring-after($original,$schema))"/>
	<!-- exluding unnecessary schemas, requiered ones will be added later, so not to have them twice -->
	<xsl:if test="$namespace!='http://www.imsglobal.org/xsd/imscp_v1p1'">
	<xsl:value-of select="concat($namespace, ' ', $schema, ' ')"/>
	</xsl:if>
	<xsl:if test="contains($remainder,' ') ">
		<xsl:call-template name="schemaLocationParsing">
			<xsl:with-param name="original" select="$remainder"/>
		</xsl:call-template>
	</xsl:if>  
    </xsl:template>
    
  
</xsl:stylesheet>
