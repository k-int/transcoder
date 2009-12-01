<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:imscp="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_v1p3"
    xmlns:adlnav="http://www.adlnet.org/xsd/adlnav_v1p3"
    xmlns:imsss="http://www.imsglobal.org/xsd/imsss"
    xmlns:lom="http://ltsc.ieee.org/xsd/LOM"
    xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_v1p2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="imscp imsmd">

<xsl:include href="shared_templates.xsl"/>  
<xsl:include href="LRMv1p2p4-LOMv1p0.xsl"/>

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

       <!-- adding required schemas for SCORM 2004  -->	
	<xsl:variable name="schemaLocation">
	 	<xsl:variable name="requiredSchema">
			http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd
                        http://www.adlnet.org/xsd/adlcp_v1p3 adlcp_v1p3.xsd
                        http://www.adlnet.org/xsd/adlseq_v1p3 adlseq_v1p3.xsd
                        http://www.adlnet.org/xsd/adlnav_v1p3 adlnav_v1p3.xsd
                        http://www.imsglobal.org/xsd/imsss imsss_v1p0.xsd
		</xsl:variable>
		<xsl:value-of select="normalize-space(concat($schema,' ',$requiredSchema))"/>	
	 </xsl:variable>		
		
	 <xsl:comment>*Transcoder Comment*: This file has transformed by Transcoder service.</xsl:comment>
         <xsl:comment>*Transcoder Comment*: Namespace definition and schema location changed.</xsl:comment>
		
	  
	<manifest identifier="{@identifier}" 
           xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
              xmlns:adlcp = "http://www.adlnet.org/xsd/adlcp_v1p3"
	      xmlns:adlseq = "http://www.adlnet.org/xsd/adlseq_v1p3"
	      xmlns:adlnav = "http://www.adlnet.org/xsd/adlnav_v1p3"
	      xmlns:imsss = "http://www.imsglobal.org/xsd/imsss"
	      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	      xsi:schemaLocation="{$schemaLocation}">
	  
	      <xsl:if test="@xml:base">
		      <xsl:attribute name="xml:base">
			<xsl:call-template  name="XMLBaseCheck">
		      		<xsl:with-param name="base" select="@xml:base"/>
			</xsl:call-template>
		      </xsl:attribute>
	      </xsl:if>
	
	     <metadata>
	    	<schema>ADL SCORM</schema>
		<schemaversion>2004 3rd Edition</schemaversion>

		<!-- Converts metadata IMS MD v1.1.4 to LOMv1.0 using included stylesheet  -->
		 <xsl:if test="imscp:metadata/imsmd:lom">
		 	<xsl:comment>*Transcoder Comment*: Manifest metadata converted from IMS MD v1.1.4 to LOMv1.0.</xsl:comment>
	    		<xsl:apply-templates select="imscp:metadata/imsmd:lom"/>
		</xsl:if>
		
		
		<!-- In case that  metadata would have already been LOMv1.0 we just copy the metadata -->
		<xsl:if test="imscp:metadata/lom:lom">
	    		<xsl:copy-of select="imscp:metadata/lom:lom"/>
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
    
    
    
   <xsl:template match="imscp:metadata"> 
   	<metadata>
   	<xsl:if test="imsmd:lom">
	       <xsl:comment>*Transcoder Comment*: Manifest metadata converted from IMS MD v1.1.4 to LOMv1.0.</xsl:comment>
	       <xsl:apply-templates select="imsmd:lom"/>
        </xsl:if>
	<!-- In case that  metadata would have already been LOMv1.0 we just copy the metadata -->
	<xsl:if test="lom:lom">
		<xsl:copy-of select="lom:lom"/>
	</xsl:if>
	</metadata>
    </xsl:template> 
    
     <!-- If organizations are missing 'default' attribure, first organization 'identifier' attribute is used as default -->
     <xsl:template match="imscp:organizations"> 
   	<xsl:element name="organizations">
		<xsl:attribute name="default">
			<xsl:choose>
				<xsl:when test="not(@default) or @default=''">
					<xsl:value-of select="imscp:organization[1]/@identifier"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@default"/>
				</xsl:otherwise>
			</xsl:choose>	
		</xsl:attribute>
		
		<!-- handle the rest -->
		<xsl:for-each select="@*">
			<xsl:if test="local-name()!='default'">
				<xsl:apply-templates select="."/>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="text()">
			<xsl:value-of select="."/>
		</xsl:for-each>
		<xsl:apply-templates select="comment()"/>
		<xsl:apply-templates select="*"/>
	</xsl:element>
    </xsl:template> 
    
    
    <!-- If organization is missing title (which is mandatory in SCORM 2004 but not in IMS CP), we have to made one up.
    1) if organization have one root folder item we use this item's title and remove the item
    2) else if metadata/lom/general/title exists we use it
    3) else if there is no other way we use value of identifier attribute as a title 
    -->
    <xsl:template match="imscp:organization"> 
   	<xsl:element  name="organization"> 
		<xsl:apply-templates select="@*"/>
		<xsl:for-each select="text()">
			<xsl:value-of select="."/>
		 </xsl:for-each>
		 <xsl:apply-templates select="comment()"/>
		 <xsl:variable name="title">
		 <xsl:choose>
			  <xsl:when test="not(imscp:title!='')">
					<xsl:variable name="metadataTitle" select="/imscp:manifest/imscp:metadata/imsmd:lom/imsmd:general/imsmd:title/imsmd:langstring"/>
					<xsl:choose>
						<xsl:when test="count(imscp:item)=1 and (imscp:item/imscp:title)!=''">
							<xsl:value-of select="imscp:item/imscp:title"/>
						</xsl:when>
						<xsl:when test="count(/imscp:manifest/imscp:organizations/imscp:organization)=1 and $metadataTitle!=''">
							<xsl:value-of select="$metadataTitle"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@identifier"/>
						</xsl:otherwise>
					</xsl:choose>
			  </xsl:when>
			  <xsl:otherwise>
			  	<xsl:value-of select="imscp:title"/>
			  </xsl:otherwise>
		  </xsl:choose>
		  </xsl:variable>
		  
		<xsl:if test="not(imscp:title!='')">
			<xsl:comment>*Transcoder Comment*: Organization (identifier="<xsl:value-of select="@identifier"/>") is missing title. New title created "<xsl:value-of select="$title"/>"</xsl:comment>
	  	</xsl:if>
		  
		  <xsl:element name="title"><xsl:value-of select="$title"/></xsl:element>
		  <xsl:choose>
		  	<xsl:when test="count(imscp:item)=1 and (imscp:item/imscp:title)=$title and not(imscp:item/imscp:title/@identifierref)">
				<!-- we do not process theroot folder item whose title was used for the organization -->
				<xsl:apply-templates select="imscp:item/imscp:item"/>
				<xsl:apply-templates select="imscp:metadata"/>
				<xsl:call-template name="wildcard"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="*">
					<xsl:if test="'title'!=local-name(.)">
						<xsl:apply-templates select="."/>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		  </xsl:choose>
	</xsl:element>
    </xsl:template>
    
    
    
    <!-- Item non-leaf nodes can't reference a resource in SCORM 2004. So if there is such non-leaf item node with resource reference
    we create  new child item node, which will be leaf node and will hold the idententifierref attribute for the resource -->
    <xsl:template match="imscp:item"> 
   	<xsl:choose>
		<!-- leaf item node or item without resource reference -->	
		<xsl:when test="count(imscp:item)=0 or not(@identifierref)">
		<xsl:element  name="{name()}"> 
			  <xsl:apply-templates select="@*"/>
			  <xsl:for-each select="text()">
				<xsl:value-of select="."/>
			  </xsl:for-each>
			  <xsl:apply-templates select="comment()"/>
			  <xsl:apply-templates select="*"/>
		  </xsl:element>
		</xsl:when>
		<!-- non-leaf item node with resource reference -->
		<xsl:otherwise>
			<xsl:comment>*Transcoder Comment*: Creating element (identifier="<xsl:value-of select="concat('parent_',@identifier)"/>"), because non-leaf element can not reference resource.</xsl:comment>
			<xsl:element name="item">
				<xsl:attribute name="identifier">
					<xsl:value-of select="concat('parent_',@identifier)"/>
				</xsl:attribute>
				<xsl:element name="title"><xsl:value-of select="imscp:title"/></xsl:element>
				<!-- creating new child node item with the resource reference-->
				<xsl:element name="item">
					<xsl:attribute  name="identifier">
						<xsl:value-of select="@identifier"/>
					</xsl:attribute>
					<xsl:attribute name="identifierref">
						<xsl:value-of select="@identifierref"/>
					</xsl:attribute>
					<xsl:if test="@isvisible">
						<xsl:attribute name="isvisible">
							<xsl:value-of select="@isvisible"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@parameters and @parameters!=''">
						<xsl:attribute name="parameters">
							<xsl:value-of select="@parameters"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:element name="title"><xsl:value-of select="imscp:title"/></xsl:element>
				</xsl:element>
				<!-- here we handle rest of the children nodes, except title node which we have already processed -->
				<xsl:for-each select="*">
					<xsl:if test="name()!='title'">
						<xsl:apply-templates select="."/>
					</xsl:if>
				</xsl:for-each>
			</xsl:element>
			
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template> 
    
    
    
    <xsl:template match="imscp:resources">
    	<xsl:element name="resources">
		<xsl:if test="@xml:base">
		      <xsl:attribute name="xml:base">
			<xsl:call-template  name="XMLBaseCheck">
		      		<xsl:with-param name="base" select="@xml:base"/>
			</xsl:call-template>
		      </xsl:attribute>
	        </xsl:if>
		<xsl:comment>*Transcoder Comment*: Adding new resource - ADL SCORM API script.</xsl:comment>
		<xsl:element name="resource">
			<xsl:attribute name="identifier">
				<xsl:text>sco_api_script</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="scormType"  namespace="http://www.adlnet.org/xsd/adlcp_v1p3">
				<xsl:text>asset</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="type">
				<xsl:text>webcontent</xsl:text>
			</xsl:attribute>
			<xsl:element name="file">
				<xsl:attribute name="href">
					<xsl:text>Scorm_API_Scripts/APIWrapper.js</xsl:text>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
		<xsl:apply-templates select="*"/>
	</xsl:element>
    </xsl:template>
    
   <xsl:template match="imscp:resource">
    	<xsl:element  name="resource"> 
       
	  <xsl:variable name="href">
	  	<xsl:call-template name="checkHref">
			<xsl:with-param name="href" select="@href"/>
		</xsl:call-template>
	  </xsl:variable>
	  
	  <xsl:variable name="firstFile">
	  	<xsl:call-template name="checkHref">
			<xsl:with-param name="href" select="imscp:file[1]/@href"/>
		</xsl:call-template>
	  </xsl:variable>

	  <xsl:variable name="addHref">
		<xsl:choose>	
			<xsl:when test="@href">
				<xsl:text>false</xsl:text>
			</xsl:when>
			<xsl:when test="contains($firstFile,'.html') or contains($firstFile,'.htm') or contains($firstFile,'.xhtml')">
				<xsl:text>true</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>false</xsl:text>
			</xsl:otherwise>
		</xsl:choose>	
	 </xsl:variable>

	<xsl:if test="$addHref='true'">	 
		<xsl:attribute name="href">
			<xsl:value-of select="$firstFile"/>
		</xsl:attribute>
	</xsl:if>  
	  
	<xsl:variable name="scormType">
	 	<xsl:choose>	
			<xsl:when test="$addHref='true' or (@href!='' and (contains(@href,'.html') or contains(@href,'.htm') or contains(@href,'.xhtml')) ) ">
				<xsl:text>sco</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>asset</xsl:text>
			</xsl:otherwise>
	  	</xsl:choose>
	  </xsl:variable>
	  
	  <xsl:attribute name="scormType" namespace="http://www.adlnet.org/xsd/adlcp_v1p3">
	  	<xsl:value-of select="$scormType"/>
	  </xsl:attribute>
	  
	  <xsl:apply-templates select="@*"/>
	  
       	  <xsl:for-each select="text()">
	  	<xsl:value-of select="."/>
	  </xsl:for-each>
	  <xsl:apply-templates select="comment()"/>
	  
	  <xsl:apply-templates select="imscp:metadata"/>
	 
	  <xsl:if test="$href!='' and count(imscp:file[@href=$href])=0">
	  	<xsl:comment>*Transcoder Comment*: Adding missing file element (href="<xsl:value-of select="$href"/>") to resource (identifier="<xsl:value-of select="@identifier"/>").</xsl:comment>
	  	<xsl:element name="file">
			<xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute>
		</xsl:element>
	  </xsl:if>
	  <xsl:apply-templates select="imscp:file"/>
	  
	  <xsl:comment>*Transcoder Comment*: Adding dependency to SCORM API Script.</xsl:comment>
	  <xsl:if test="$scormType='sco'">
	  	<xsl:element name="dependency">
			<xsl:attribute name="identifierref">
				<xsl:text>sco_api_script</xsl:text>
			</xsl:attribute>
		</xsl:element>
	  </xsl:if>
	  
	  <xsl:apply-templates select="imscp:dependency"/>
	  <xsl:call-template name = "wildcard"/>
	</xsl:element>
    </xsl:template>
    
      
   
  
    
    <!-- The following templates are to handle extensions. 
         It is called by name in places where the structure of the XSL prevents a generic apply-templates,
	 and referenced through the generic mechanism where possible. --> 
    
   <xsl:template name = "wildcard">
	<xsl:for-each select = "*">
		<xsl:if test = "namespace-uri() != $imsmdNamespacev1p2p4 and  namespace-uri() != 'http://www.imsglobal.org/xsd/imscp_v1p1'">
			<xsl:copy-of select = "."/>
		</xsl:if>	
	</xsl:for-each>
   </xsl:template>

   <!-- recursive generic template for elements that are from imscp namespace -->
    <xsl:template match="imscp:*">
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
     	<xsl:if test=".!=''">	
    	<xsl:choose>
	      <xsl:when test="local-name()='isvisible'">
		<xsl:call-template name="booleanValue">
			<xsl:with-param name="value" select="."/>
		</xsl:call-template>
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
	</xsl:if>	
    </xsl:template>
   
   <!-- generic template for elements that are not from imscp namespace -->
   <xsl:template match="*">
       <xsl:if test = "namespace-uri() != $imsmdNamespacev1p2p4">
			<xsl:copy-of select = "."/>
		</xsl:if>
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
	<xsl:if test="$namespace!='http://www.imsglobal.org/xsd/imsmd_v1p2' and
			$namespace!='http://www.imsglobal.org/xsd/imscp_v1p1' and
                        $namespace!='http://www.adlnet.org/xsd/adlcp_v1p3' and
                        $namespace!='http://www.adlnet.org/xsd/adlseq_v1p3' and
                        $namespace!='http://www.adlnet.org/xsd/adlnav_v1p3' and
                        $namespace!='http://www.imsglobal.org/xsd/imsss imsss_v1p0.xsd' ">
	<xsl:value-of select="concat($namespace, ' ', $schema, ' ')"/>
	</xsl:if>
	<xsl:if test="contains($remainder,' ') ">
		<xsl:call-template name="schemaLocationParsing">
			<xsl:with-param name="original" select="$remainder"/>
		</xsl:call-template>
	</xsl:if>  
    </xsl:template>
    
    <!-- template that returns correct boolean value for input like 1/0 yes/no  -->
    <xsl:template name="booleanValue">
    	<xsl:param name="value"/>
	<xsl:choose> 
		<xsl:when test="$value='1' or $value='yes'">
			<xsl:value-of select="'true'"/>
		</xsl:when>
		<xsl:when test="$value='0' or $value='no'">
			<xsl:value-of select="'false'"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$value"/>
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template>
  
</xsl:stylesheet>
