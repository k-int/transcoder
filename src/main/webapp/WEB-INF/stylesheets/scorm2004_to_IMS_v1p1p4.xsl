<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:imscp="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_v1p3"
    xmlns:adlnav="http://www.adlnet.org/xsd/adlnav_v1p3"
    xmlns:imsss="http://www.imsglobal.org/xsd/imsss"
    xmlns:lom="http://ltsc.ieee.org/xsd/LOM"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="adlnav lom imscp">
    
<xsl:include href="shared_templates.xsl"/>    
<xsl:include href="transcoder_metadata_LOMv1p0_to_mdv1p2p4.xsl"/>
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

       <!-- If neede adding http://www.imsglobal.org/xsd/imscp_v1p1 schema location  -->	
	<xsl:variable name="schemaLocation">
	 	<xsl:choose>
			<xsl:when test="contains($schema,'http://www.imsglobal.org/xsd/imscp_v1p1')">
				<xsl:value-of select="$schema"/>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($schema,' http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd ')"/>	
			</xsl:otherwise>
		</xsl:choose>
	 </xsl:variable>		
		
		
	 <xsl:comment>*Transcoder Comment*: This file has transformed by Transcoder service.</xsl:comment>
         <xsl:comment>*Transcoder Comment*: Namespace definition and schema location changed.</xsl:comment>
	
	 
	<manifest identifier="{@identifier}" version="IMS CP 1.1.4"
           xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
            xmlns:imsss="http://www.imsglobal.org/xsd/imsss"
	    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	    xsi:schemaLocation="{$schemaLocation}" >
	    
	      <xsl:if test="@xml:base">
		      <xsl:attribute name="xml:base">
			<xsl:call-template  name="XMLBaseCheck">
		      		<xsl:with-param name="base" select="@xml:base"/>
			</xsl:call-template>
		      </xsl:attribute>
	      </xsl:if>
				 
	   <metadata>
	    	<schema>IMS CONTENT</schema>
		<schemaversion>1.1</schemaversion>

	    <!-- Converts metadata LOMv1.0 to IMS MD v1.2.4 using included stylesheet  -->
	    <xsl:if test="imscp:metadata/lom:lom">
	    	<xsl:comment>*Transcoder Comment*: Manifest metadata converted from LOMv1.0 to IMS MD v1.2.4 .</xsl:comment>
	    	<xsl:apply-templates select="imscp:metadata/lom:lom"/>
	    </xsl:if>
	    
	    
	    
	    
	    </metadata>
	    <xsl:apply-templates select="comment()"/>
            <xsl:for-each select="*">
	    	<xsl:if test="name()!='metadata'">
	    		<xsl:apply-templates select="."/>
		</xsl:if>
	    </xsl:for-each>
        </manifest>
    </xsl:template>
    
      
    <xsl:template match="imscp:metadata"> 
   	<metadata>
   	<xsl:if test="lom:lom">
	       <xsl:apply-templates select="lom:lom"/>
        </xsl:if>
	</metadata>
    </xsl:template> 
    
    
    <xsl:template match="imscp:*|imsss:*">
       	<xsl:element  name="{name()}"> 
       	<xsl:apply-templates select="@*"/>
       	  <xsl:for-each select="text()">
	  	<xsl:value-of select="."/>
	  </xsl:for-each>
	  <xsl:apply-templates select="comment()"/>
	  <xsl:apply-templates select="*"/>
	</xsl:element>
    </xsl:template>
   
    <xsl:template match="@*">
    	<xsl:choose>
        	<xsl:when test="namespace-uri() = 'http://www.adlnet.org/xsd/adlcp_v1p3'"/>
		<xsl:when test="namespace-uri() = 'http://www.imsglobal.org/xsd/imscc/imscp_v1p1' or namespace-uri()=''">
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
		</xsl:when>
		<xsl:when test="local-name()='base' and namespace-uri()='http://www.w3.org/XML/1998/namespace'">
			<xsl:attribute name="xml:base">
				<xsl:call-template  name="XMLBaseCheck">
					<xsl:with-param name="base" select="."/>
				</xsl:call-template>
			</xsl:attribute>
	       </xsl:when>
	       <xsl:otherwise>
	       		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}">
				<xsl:value-of select="."/>
			</xsl:attribute>	
	       </xsl:otherwise>
	</xsl:choose>
    </xsl:template>
  
    
    <!-- The following templates are to handle extensions. 
         It is called by name in places where the structure of the XSL prevents a generic apply-templates,
	 and referenced through the generic mechanism where possible. --> 
    
   <xsl:template name = "wildcard">
	<xsl:if test = "*[namespace-uri() != $LOMNamespacev1p0]">
			<xsl:for-each select = "*[namespace-uri() != $LOMNamespacev1p0]">
				<xsl:copy-of select = "."/>
			</xsl:for-each>
		</xsl:if>
   </xsl:template>

  <xsl:template match = "*">
  	<xsl:if test = "*[namespace-uri() != $LOMNamespacev1p0]">
  		<xsl:copy-of select = "."/>
	</xsl:if>
  </xsl:template>
    
   
    <xsl:template match="imscp:schema"/>
    <xsl:template match="imscp:schemaversion"/>
    <xsl:template match="adlnav:*">
  	<xsl:comment>*Transcoder Comment*: ADL navigation elements omitted.</xsl:comment>
    </xsl:template>
   
    
  
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
	<!-- exluding unnecessary schemas -->
	<xsl:if test="$namespace!='http://www.adlnet.org/xsd/adlnav_v1p3' 
		and $namespace!='http://ltsc.ieee.org/xsd/LOM'
		and $namespace!='http://www.imsglobal.org/xsd/imsmd_v1p2'">
		<xsl:value-of select="concat($namespace, ' ', $schema, ' ')"/>
	</xsl:if>
	<xsl:if test="contains($remainder,' ') ">
		<xsl:call-template name="schemaLocationParsing">
			<xsl:with-param name="original" select="$remainder"/>
		</xsl:call-template>
	</xsl:if>  
    </xsl:template>
  
</xsl:stylesheet>