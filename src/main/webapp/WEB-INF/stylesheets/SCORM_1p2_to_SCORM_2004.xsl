<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cpin="http://www.imsproject.org/xsd/imscp_rootv1p1p2"
    xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_v1p3"
    xmlns:adlcpin="http://www.adlnet.org/xsd/adlcp_rootv1p2"
    xmlns:imsss="http://www.imsglobal.org/xsd/imsss"
    xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_rootv1p2p1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="imsmd adlcpin cpin">

<xsl:include href="shared_templates.xsl"/>  
<xsl:include href="LRMv1p2p1-LOMv1p0.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
   
     
    <xsl:template match="cpin:manifest">
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
	      xsi:schemaLocation="{$schemaLocation}" >
	   
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
		 <xsl:if test="cpin:metadata/imsmd:lom">
		 	<xsl:comment>*Transcoder Comment*: Manifest metadata converted from IMS metadata 1.2.4 to LOMv1.0.</xsl:comment>
			<xsl:apply-templates select="cpin:metadata/imsmd:lom"/>
		</xsl:if>
	    
		
		
		<xsl:apply-templates select="cpin:metadata/adlcpin:location"/>
	
	    </metadata>
	    <xsl:apply-templates select="comment()"/>
            <xsl:for-each select="*">
	    	<xsl:if test="local-name()!='metadata'">
	    		<xsl:apply-templates select="."/>
		</xsl:if>
	    </xsl:for-each>
        </manifest>
    </xsl:template>
    
    
    <!-- General Identity Transformation Templates -->
    <!-- Matches IMSCP nodes that are not covered by anything else -->
    
    
   <xsl:template name = "wildcard">
   	<xsl:for-each select = "*">
		<xsl:if test = "namespace-uri() != 'http://www.imsglobal.org/xsd/imsmd_rootv1p2p1' and  namespace-uri() != 'http://www.imsproject.org/xsd/imscp_rootv1p1p2'">
			<xsl:copy-of select = "."/>
		</xsl:if>	
	</xsl:for-each>
   </xsl:template>

 
   
   <!-- generic template for elements that are not from imscp namespace -->
   <xsl:template match="*">
       <xsl:if test = "namespace-uri() != 'http://www.imsglobal.org/xsd/imsmd_rootv1p2p1'">
			<xsl:copy-of select = "."/>
		</xsl:if>
    </xsl:template>
  
   
    <xsl:template match="cpin:*">
        <xsl:element name="{local-name()}"> 
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="text()">
                <xsl:value-of select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="*"/>
            <xsl:apply-templates select="comment()"/>
        </xsl:element>
    </xsl:template>
    
    
    <!-- Check whether location path doesn't start with xml:base attribute of parent resource, if yes, we use substring after this base -->
     <xsl:template match="adlcpin:location">
	<xsl:variable name="base">
	    <xsl:if test="parent::cpin:metadata/parent::cpin:resource/@xml:base">
	    	<xsl:call-template  name="XMLBaseCheck">
				<xsl:with-param name="base" select="parent::cpin:metadata/parent::cpin:resource/@xml:base"/>
                 </xsl:call-template>
	    </xsl:if>
	</xsl:variable>    
	<xsl:element name="adlcp:location">	    
		<xsl:choose>
			<xsl:when test="$base!='' and starts-with(.,$base)">
				<xsl:value-of select="substring-after(.,$base)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:element>
     </xsl:template>
    
    <!-- Matches ADLCP nodes that are not covered by anything else -->
    <xsl:template match="adlcpin:*">
    	<xsl:element name="{local-name()}" namespace="http://www.adlnet.org/xsd/adlcp_v1p3">
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="text()">
                <xsl:value-of select="."/>
            </xsl:for-each>
            <xsl:apply-templates select="*"/>
            <xsl:apply-templates select="comment()"/>
        </xsl:element>
    </xsl:template>
   
    <!-- Matches all attributes, switching namespaces appropriately -->
    <xsl:template match="@*">
        <xsl:choose>
            <xsl:when test="namespace-uri() = 'http://www.adlnet.org/xsd/adlcp_rootv1p2'">
                <xsl:choose>
			<xsl:when test="local-name()='scormtype'">
				<xsl:attribute name="scormType" namespace="http://www.adlnet.org/xsd/adlcp_v1p3">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="{local-name()}" namespace="http://www.adlnet.org/xsd/adlcp_v1p3">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:otherwise>
	    	</xsl:choose>
            </xsl:when>
            <xsl:when test="namespace-uri() = 'http://www.imsproject.org/xsd/imscp_rootv1p1p2' or namespace-uri()=''">
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
  
    <!-- This template removes the prerequisites from the source. -->
    <xsl:template match="adlcpin:prerequisites">
        <xsl:comment>*Transcoder Comment*: The following prerequisites has been remomved. A sequencing rule should be written to replace them.</xsl:comment>
        <xsl:comment>
            <xsl:value-of select="."/>
        </xsl:comment>
    </xsl:template>
    <!-- The following templates change the name of their elements -->
    <xsl:template match="adlcpin:timelimitaction">
        <xsl:comment>*Transcoder Comment*: Element timelimitaction changed to camelcase timeLimitAction.</xsl:comment>
    	<adlcp:timeLimitAction>
            <xsl:value-of select="."/>
        </adlcp:timeLimitAction>
    </xsl:template>
    <xsl:template match="adlcpin:datafromlms">
    	<xsl:comment>*Transcoder Comment*: Element datafromlms changed to camelcase dataFromLMS.</xsl:comment>
        <adlcp:dataFromLMS>
            <xsl:value-of select="."/>
        </adlcp:dataFromLMS>
    </xsl:template>
    
    
    <xsl:template match="cpin:organizations">
    	<xsl:element name="organizations" >
		<xsl:attribute name="default">
			<xsl:choose>
				<xsl:when test="not(@default) or @default=''">
					<xsl:value-of select="cpin:organization[1]/@identifier"/>
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
    
    
    
    
    <!-- Item non-leaf nodes can't reference a resource in SCORM 2004. So if there is such non-leaf item node with resource reference
    we create  new child item node, which will be leaf node and will hold the idententifierref attribute for the resource -->
    <xsl:template match="cpin:item"> 
	  <xsl:variable name="masteryScore">
		<xsl:if test="adlcpin:masteryscore">
			<xsl:value-of select="((number(adlcpin:masteryscore)) div 50) - 1"/>
		</xsl:if>
	    </xsl:variable>
	    <xsl:variable name="maxTime">
		<xsl:if test="adlcpin:maxtimeallowed">
		    <xsl:value-of select="adlcpin:maxtimeallowed"/>
		</xsl:if>
	    </xsl:variable>
    
    	<xsl:choose>
		<!-- leaf item node or item without resource reference -->	
		<xsl:when test="count(cpin:item)=0 or not(@identifierref)">
		<xsl:element  name="item"> 
			  <xsl:apply-templates select="@*"/>
			  <xsl:for-each select="text()">
				<xsl:value-of select="."/>
			  </xsl:for-each>
			  <xsl:apply-templates select="comment()"/>
			  <xsl:apply-templates select="*"/>
			  <xsl:if test="$maxTime != '' or $masteryScore != ''">
			  	<xsl:comment>*Transcoder Comment*: Sequencing rules for item (identifier="<xsl:value-of select="@identifier"/>") added to mimic maxTime and masteryScore.</xsl:comment>
			  </xsl:if>	
			  <xsl:call-template name="Sequencing">
			  	<xsl:with-param name="masteryScore" select="$masteryScore"/>
			  	<xsl:with-param name="maxTime" select="$maxTime"/>
			  </xsl:call-template>
		  </xsl:element>
		</xsl:when>
		<!-- non-leaf item node with resource reference -->
		<xsl:otherwise>
			<xsl:comment>*Transcoder Comment*: Creating element (identifier="<xsl:value-of select="concat('parent_',@identifier)"/>"), because non-leaf element can not reference resource.</xsl:comment>
			<xsl:element name="item">
				<xsl:attribute name="identifier">
					<xsl:value-of select="concat('parent_',@identifier)"/>
				</xsl:attribute>
				<xsl:element name="title"><xsl:value-of select="cpin:title"/></xsl:element>
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
					<xsl:element name="title"><xsl:value-of select="cpin:title"/></xsl:element>
				</xsl:element>
				<!-- here we handle rest of the children nodes, except title node which we have already processed -->
				<xsl:for-each select="*">
					<xsl:if test="local-name()!='title'">
						<xsl:apply-templates select="."/>
					</xsl:if>
				</xsl:for-each>
				 <xsl:if test="$maxTime != '' or $masteryScore != ''">
				 	<xsl:comment>*Transcoder Comment*: Sequencing rules for item (identifier="<xsl:value-of select="@identifier"/>") added to mimic maxTime and masteryScore.</xsl:comment>
				</xsl:if>
				<xsl:call-template name="Sequencing">
					<xsl:with-param name="masteryScore" select="$masteryScore"/>
					<xsl:with-param name="maxTime" select="$maxTime"/>
				</xsl:call-template>
			</xsl:element>
			
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template> 
    
    
    
    
    
    
    <xsl:template name="Sequencing">
    	<xsl:param name="maxTime"/>
	<xsl:param name="masteryScore"/>
        <xsl:if test="$maxTime != '' or $masteryScore != ''">
               <imsss:sequencing>
                    <xsl:if test="$maxTime != ''">
		       
		    	<imsss:limitConditions>
                            <xsl:attribute name="attemptAbsoluteDurationLimit">
                                <xsl:call-template name="durationConversionADL">
						<xsl:with-param name="data" select="$maxTime"/>
				</xsl:call-template>
                            </xsl:attribute>
                        </imsss:limitConditions>
                    </xsl:if>
                    <xsl:if test="$masteryScore != ''">
                        <imsss:objectives>
                            <imsss:primaryObjective>
                                <imsss:minNormalizedMeasure>
                                    <xsl:value-of select="$masteryScore"/>
                                </imsss:minNormalizedMeasure>
                            </imsss:primaryObjective>
                        </imsss:objectives>
                    </xsl:if>
                </imsss:sequencing>
            </xsl:if>
    </xsl:template>
 
    
    
    
    <!-- The following templates suppress items that do not appear in the result. -->
    <xsl:template match="cpin:schema"/>
    <xsl:template match="cpin:schemaversion"/>
    <xsl:template match="adlcpin:maxtimeallowed"/>
    <xsl:template match="adlcpin:masteryscore"/>
    <xsl:template match="cpin:metadata">
        <xsl:choose>
            <xsl:when test="../cpin:manifest"/>
            <xsl:when test="parent::cpin:manifest"/>
            <xsl:when test="not(child::node())"/>
            <xsl:otherwise>
                <metadata>
                    <xsl:apply-templates select="*"/>
                </metadata>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name = "durationConversionADL">
		<xsl:param name = "data"/>
		<xsl:variable name = "check"
		              select = "translate($data, '0123456789d', 'dddddddddd ')"/>
		<xsl:choose>
			<xsl:when test = "starts-with($check, 'dd:dd:dd')">
				<xsl:variable name = "hoursVal">
					<xsl:call-template name = "durationConversionUtilADL">
						<xsl:with-param name = "substring" select = "substring($data, 1, 2)"/>
						<xsl:with-param name = "ending" select = "'H'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "minutesVal">
					<xsl:call-template name = "durationConversionUtilADL">
						<xsl:with-param name = "substring" select = "substring($data, 4, 2)"/>
						<xsl:with-param name = "ending" select = "'M'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "secondsVal">
					<xsl:call-template name = "durationConversionUtilADL">
						<xsl:with-param name = "substring" select = "substring($data, 7, 2)"/>
						<xsl:with-param name = "ending" select = "'S'"/>
					</xsl:call-template>
				</xsl:variable>
				

				<!-- Finally, assemble the entire package -->
				
				<xsl:variable name = "res">
					PT
					<xsl:value-of select = "$hoursVal"/>
					<xsl:value-of select = "$minutesVal"/>
					<xsl:value-of select = "$secondsVal"/>
				</xsl:variable>
				<xsl:value-of select = "translate(normalize-space($res), ' ', '')"/>
			</xsl:when>
			<xsl:when test = "starts-with($check, 'dddd:dd:dd')">
				<xsl:variable name = "hoursVal">
					<xsl:call-template name = "durationConversionUtilADL">
						<xsl:with-param name = "substring" select = "substring($data, 1, 4)"/>
						<xsl:with-param name = "ending" select = "'H'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "minutesVal">
					<xsl:call-template name = "durationConversionUtilADL">
						<xsl:with-param name = "substring" select = "substring($data, 6, 2)"/>
						<xsl:with-param name = "ending" select = "'M'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "secondsVal">
					<xsl:call-template name = "durationConversionUtilADL">
						<xsl:with-param name = "substring" select = "substring($data, 9, 2)"/>
						<xsl:with-param name = "ending" select = "'S'"/>
					</xsl:call-template>
				</xsl:variable>
				

				<!-- Finally, assemble the entire package -->
				
				<xsl:variable name = "res">
					PT
					<xsl:value-of select = "$hoursVal"/>
					<xsl:value-of select = "$minutesVal"/>
					<xsl:value-of select = "$secondsVal"/>
				</xsl:variable>
				<xsl:value-of select = "translate(normalize-space($res), ' ', '')"/>
			</xsl:when>
			<xsl:otherwise>
					<xsl:value-of select = "$data"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name = "durationConversionUtilADL">
		<xsl:param name = "substring"/>
		<xsl:param name = "ending"/>
		<xsl:variable name = "check"
		              select = "translate($substring, '123456789z', 'zzzzzzzzz ')"/>
		<xsl:variable name = "val">
			<xsl:if test = "contains($check, 'z')">
				<xsl:value-of select = "concat(number($substring), $ending)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select = "$val"/>
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
	<!-- exluding unnecessary schemas, requiered ones will be added later, so not to have them twice -->
	<xsl:if test="$namespace!='http://www.imsproject.org/xsd/imscp_rootv1p1p2' and
			$namespace!='http://www.adlnet.org/xsd/adlcp_rootv1p2'">
	<xsl:value-of select="concat($namespace, ' ', $schema, ' ')"/>
	</xsl:if>
	<xsl:if test="contains($remainder,' ') ">
		<xsl:call-template name="schemaLocationParsing">
			<xsl:with-param name="original" select="$remainder"/>
		</xsl:call-template>
	</xsl:if>  
    </xsl:template>
    
  
</xsl:stylesheet>