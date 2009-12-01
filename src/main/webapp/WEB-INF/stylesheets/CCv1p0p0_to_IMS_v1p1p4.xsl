<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:imscc="http://www.imsglobal.org/xsd/imscc/imscp_v1p1" 
    xmlns:lomimscc="http://ltsc.ieee.org/xsd/imscc/LOM"
    xmlns:lom="http://ltsc.ieee.org/xsd/LOM"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="imscc lomimscc lom">

<xsl:include href="shared_templates.xsl"/>    
<xsl:include href="transcoder_metadata_imscc_LOM_to_mdv1p2p4.xsl"/>
<xsl:output indent="yes" method="xml"/>
<xsl:strip-space elements="*"/>
     


<xsl:template match="imscc:manifest">

	
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
	 	<xsl:value-of select="concat($schema,' http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd ')"/>	
	 </xsl:variable>		

     <xsl:comment>*Transcoder Comment*: This file has transformed by Transcoder service.</xsl:comment>
     <xsl:comment>*Transcoder Comment*: Namespace definition and schema location changed.</xsl:comment> 
	 
	<manifest identifier="{@identifier}" version="IMS CP 1.1.4"
           xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
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

	    <!-- Converts metadata LOMv1.0 to IMS MD v1.1.4 using included stylesheet  -->
	     <xsl:if test="imscc:metadata/lomimscc:lom">
	    	<xsl:comment>*Transcoder Comment*: Manifest metadata converted from CC profile of LOMv1.0 to IMS metadata 1.2.4 .</xsl:comment>
	    	<xsl:apply-templates select="imscc:metadata/lomimscc:lom"/>
	    </xsl:if>
	    
	    
	    </metadata>
	    <xsl:apply-templates select="comment()"/>
            <xsl:for-each select="*">
	    	<xsl:if test="local-name()!='metadata'">
	    		<xsl:apply-templates select="."/>
		</xsl:if>
	    </xsl:for-each>
        </manifest>
    </xsl:template>
    
      
    <xsl:template match="imscc:metadata"> 
   	<xsl:if test="lom:lom">
		<metadata>
			<xsl:comment>*Transcoder Comment*: Manifest metadata converted from LOMv1.0 to IMS metadata 1.2.4 .</xsl:comment>	 
			<xsl:apply-templates select="lom:lom"/>
	       </metadata>
        </xsl:if>
    </xsl:template> 
    
    
     <xsl:template match="imscc:item"> 
   	<xsl:choose>
		<xsl:when test="imscc:title">
			<xsl:element  name="{name()}"> 
				<xsl:apply-templates select="@*"/>
				<xsl:for-each select="text()">
					<xsl:value-of select="."/>
				</xsl:for-each>
				<xsl:apply-templates select="comment()"/>
				<xsl:apply-templates select="*"/>
			</xsl:element>	
		</xsl:when>
		<xsl:when test="not(imscc:title) and @identifierref!=''">
			<xsl:element  name="{name()}"> 
				<xsl:apply-templates select="@*"/>
				<xsl:for-each select="text()">
					<xsl:value-of select="."/>
				</xsl:for-each>
				<xsl:apply-templates select="comment()"/>
				<xsl:comment>*Transcoder Comment*: Item title (identifier="<xsl:value-of select="@identifier"/>") has been created.</xsl:comment>
				<xsl:element name="title">
					<xsl:value-of select="@identifier"/>
				</xsl:element>
				<xsl:apply-templates select="*"/>
			</xsl:element>	
		</xsl:when>
		<xsl:otherwise>
			<xsl:comment>*Transcoder Comment*: Item (identifier="<xsl:value-of select="@identifier"/>") has been removed.</xsl:comment>
			<xsl:apply-templates select="comment()"/>
			<xsl:apply-templates select="*"/>
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template>
    
    <xsl:template match="imscc:*">
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
		<xsl:when test="local-name()='structure' and local-name(..)='organization'">
			<xsl:attribute name="structure" namespace="">
				<xsl:value-of select="'hierarchical'"/>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="local-name()='type' and local-name(..)='resource' and ( .='associatedcontent/imscc_xmlv1p0/learning-application-resource')">
			<xsl:attribute name="type" namespace="">
				<xsl:value-of select="'webcontent'"/>
			</xsl:attribute>
		</xsl:when>
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
	<xsl:if test = "*[namespace-uri() != $LOMNamespacev1p0 and namespace-uri() != $LOM_IMS_CC_Namespacev1p0]">
			<xsl:for-each select = "*[namespace-uri() != $LOMNamespacev1p0 and namespace-uri() != $LOM_IMS_CC_Namespacev1p0]">
				<xsl:copy-of select = "."/>
			</xsl:for-each>
		</xsl:if>
   </xsl:template>

  <xsl:template match = "*">
  	<xsl:if test = "*[namespace-uri() != $LOMNamespacev1p0 and namespace-uri() != $LOM_IMS_CC_Namespacev1p0]">
  		<xsl:copy-of select = "."/>
	</xsl:if>
  </xsl:template>
    
    
    
    
  <xsl:template match="imscc:schema"/>
  <xsl:template match="imscc:schemaversion"/>
   
   
    
  
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
	<xsl:if test="$namespace!='http://www.imsglobal.org/xsd/imscc/imscp_v1p1' 
		and $namespace!='http://www.imsglobal.org/xsd/imscp_v1p1'	
		and $namespace!='http://ltsc.ieee.org/xsd/LOM'
		and $namespace!='http://ltsc.ieee.org/xsd/imscc/LOM'">
		<xsl:value-of select="concat($namespace, ' ', $schema, ' ')"/>
	</xsl:if>
	<xsl:if test="contains($remainder,' ') ">
		<xsl:call-template name="schemaLocationParsing">
			<xsl:with-param name="original" select="$remainder"/>
		</xsl:call-template>
	</xsl:if>  
    </xsl:template>
  
</xsl:stylesheet>
