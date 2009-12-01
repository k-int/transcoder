<?xml version = "1.0" encoding = "UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
	xmlns = "http://www.imsglobal.org/xsd/imsmd_v1p2"
	xmlns:lom = "http://ltsc.ieee.org/xsd/LOM"
	xmlns:lomimscc = "http://ltsc.ieee.org/xsd/imscc/LOM"
	xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="lom lomimscc">
	
	<xsl:output method = "xml" encoding="utf-8" indent="yes"/> 
        
	<xsl:strip-space elements="*"/>
	<!-- Global Variables ****************************************************************  -->
	
	
	
	<xsl:variable name = "unknownSource" select = "'unknown'"/>							<!-- ##UnknownSource -->
	
	<xsl:variable name = "LOM_IMS_CC_Namespacev1p0" select = "'http://ltsc.ieee.org/xsd/imscc/LOM'"/>				<!-- ##Namespace for the LOM v1p0 -->
	<xsl:variable name = "LOMNamespacev1p0" select = "'http://ltsc.ieee.org/xsd/LOM'"/>	
	
	<!-- ==================================================================================  -->
	
	<!-- Top Level Template *************************************************************** -->
	
	<xsl:template match = "lomimscc:lom|lom:lom">
	
		<!-- Parsing original xsi:schemaLocation attribute and remove unnecessary schemas -->	
		<xsl:variable name="schema">
				<xsl:if test="@xsi:schemaLocation">
					<xsl:call-template name="schemaMetadataLocationParsing">
							<xsl:with-param name="original" select="normalize-space(@xsi:schemaLocation)" />
					</xsl:call-template>
				</xsl:if>
		</xsl:variable>
	
	       <!-- If neede adding http://www.imsglobal.org/xsd/imscp_v1p1 schema location  -->	
	       <xsl:variable name="schemaLocation">
			<xsl:value-of select="concat($schema,' http://www.imsglobal.org/xsd/imsmd_v1p2 imsmd_v1p2p4.xsd ')"/>	
	       </xsl:variable>	


		<lom xmlns = "http://www.imsglobal.org/xsd/imsmd_v1p2"
			xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="{$schemaLocation}" 	>  
			<xsl:apply-templates select = "*"/>
		</lom>
	</xsl:template>  
	
	
	<!-- ==================================================================================  -->

	<!-- Generic Templates **************************************************************** -->

	<!-- The following templates are to handle extensions. Their job is simply to recognize elements that
	     aren't in the LOM namespace, and copy them unchanged to the target document.
	     
	     It is called by name in places where the structure of the XSL prevents a generic apply-templates,
	     and referenced through the generic mechanism where possible. -->
	     
	 <!--     
	<xsl:template name = "wildcard">
		
		<xsl:if test = "*[namespace-uri() != $LOMNamespacev1p0]">
			<xsl:for-each select = "*[namespace-uri() != $LOMNamespacev1p0]">
				<xsl:copy-of select = "."/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match = "*">
		<xsl:if test = "namespace-uri() != $LOMNamespacev1p0">
			<xsl:copy-of select = "."/>
		</xsl:if>
	</xsl:template>
	
	
	
 -->
 
 
 
	<!-- ==================================================================================  -->
	
	<!-- This template copies comments from the source document to the target document. ***  -->
 <!-- 
	<xsl:template match ="comment()" name = "comment">
		
		<xsl:comment>
			<xsl:value-of select = "."/>
		</xsl:comment>
		
	</xsl:template>
-->
	<!-- ==================================================================================  -->

	<!-- This is the default template that does most of the work. It gets called when there is
	     no more specific template available. The logic is: 
	     Copy the element and all attributes from the LOM namespace,
	     and put them in the target document, in the same order with the same names, but in the
	     IMS namespace. If the element has attributes that are not from the LOM namespace, copy
	     them to the target element, leaving the namespace unchanged. If the node has text children,
	     copy them to the target element as well. 
	     
	     -->

	<xsl:template match = "lomimscc:*|lom:*">
		<xsl:element name = "{local-name()}">
			<xsl:for-each select ="@*">
				<xsl:choose>
					<xsl:when test = "namespace-uri() != 'http://ltsc.ieee.org/xsd/LOM' and namespace-uri() != 'http://ltsc.ieee.org/xsd/imscc/LOM'">
						<xsl:attribute name = "{local-name()}" namespace = "{namespace-uri()}">
							<xsl:value-of select = "."/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name = "{local-name()}"><xsl:value-of select = "."/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:for-each select = "text()">
				<xsl:value-of select = "."/>
			</xsl:for-each>
			<xsl:apply-templates select = "*"/>
			<xsl:apply-templates select = "comment()"/>
		</xsl:element>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- General Template and Children **************************************************** -->

	<xsl:template match = "lomimscc:general|lom:general">
		
		<general>
			
			<xsl:comment>General Section</xsl:comment>
			<xsl:call-template name = "identifier"/>
			<xsl:apply-templates select = "lomimscc:title|lom:title"/>
			<xsl:call-template name = "catalogentry"/>
			<xsl:apply-templates select = "lomimscc:language|lom:language"/>
			<xsl:apply-templates select = "lomimscc:description|lom:description"/>
			<xsl:apply-templates select = "lomimscc:keyword|lom:keyword"/>
			<xsl:apply-templates select = "lomimscc:coverage|lom:coveradge"/>
			<xsl:apply-templates select = "lomimscc:structure|lom:structure"/>
			<xsl:apply-templates select = "lomimscc:aggregationLevel|lom:aggregationLevel"/>
		        <xsl:call-template name = "wildcard"/>
			
		</general>
		
	</xsl:template>

	<xsl:template match = "lomimscc:aggregationLevel|lom:aggregationLevel">
		
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'aggregationlevel'"/>
		</xsl:call-template>
		
	</xsl:template>


	<!-- ##CatologEntry -->
	<!-- The logic of this is as follows. If there is a catalog element, create catalog
	entry. If there is no catalog element, create identifier elemenent from entry element. -->
	     
	
	<xsl:template name = "identifier">
		<xsl:for-each select = "lomimscc:identifier|lom:identifier">
			<xsl:choose>
				<xsl:when test = "lomimscc:catalog!='' or lom:catalog!=''"/>
				<xsl:when test = "lomimscc:entry or lom:entry">
					<identifier><xsl:value-of select = "."/></identifier>
					  <xsl:call-template name = "wildcard"/>
				</xsl:when>
			</xsl:choose>	
		</xsl:for-each>
	</xsl:template>     

	<xsl:template name = "catalogentry">
		<xsl:for-each select = "lomimscc:identifier|lom:identifier">
			<xsl:if test = "lomimscc:catalog!='' or lom:catalog!=''">
				<catalogentry>
					<xsl:apply-templates select = "*"/>
				       <xsl:call-template name = "wildcard"/>
				</catalogentry>		
			</xsl:if>
					
		</xsl:for-each>
	</xsl:template>     


	
	<xsl:template match="lomimscc:entry|lom:entry ">
		<entry>
		    <xsl:element name="langstring">	
			<xsl:attribute name = "lang" namespace="http://www.w3.org/XML/1998/namespace">x-none</xsl:attribute>
			<xsl:value-of select="."/>
		    </xsl:element>	
		</entry>
	</xsl:template>	
	
	<!-- These are here to block the IDENTIFIER element from being picked up
	     by the standard  template. -->
	
	<xsl:template match = "lomimscc:identifier|lom:identifier"/>
	
	
	<!-- ==================================================================================  -->
	     
	<!-- Lifecycle Template and Children ************************************************** -->

	<xsl:template match = "lomimscc:lifeCycle|lom:lifeCycle">    
		<lifecycle>
			<xsl:comment>Lifecycle Section</xsl:comment>
			<xsl:apply-templates select = "*"/>
		</lifecycle>
	</xsl:template>

	<xsl:template match="lomimscc:contribute|lom:contribute">
	     <contribute>	
		<xsl:apply-templates select = "lomimscc:role|lom:role"/>
		<xsl:call-template name = "centity"/>
		<xsl:apply-templates select = "lomimscc:date|lom:date"/>
	     </contribute>
	</xsl:template>
	
	<xsl:template match = "lomimscc:dateTime|lom:dateTime">
		<datetime>
			<xsl:value-of select = "."/>   
		</datetime>
	</xsl:template>
	
	<xsl:template match="lomimscc:entity|lom:entity"/>
	
	<xsl:template name = "centity">
		<xsl:for-each select="lomimscc:entity|lom:entity">
	        <centity>
			<vcard><xsl:value-of select = "."/></vcard>
		</centity>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match = "lomimscc:role|lom:role">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'role'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- Metametadata Template and Children  ********************************************** -->
	
	<xsl:template match = "lomimscc:metaMetadata|lom:metaMetadata">
		<metametadata>
			<xsl:comment>Metametadata Section</xsl:comment>
			<xsl:call-template name = "identifier"/>
			<xsl:call-template name = "catalogentry"/>
			<xsl:apply-templates select = "lomimscc:contribute|lom:contribute"/>
			<metadatascheme>IMS Metadata 1.2.4</metadatascheme>
			<xsl:apply-templates select = "lomimscc:metadataSchema|lom:metadataSchema"/>
			<xsl:apply-templates select = "lomimscc:language|lom:language"/>
			  <xsl:call-template name = "wildcard"/>
		</metametadata>
	</xsl:template>

	<xsl:template match = "lomimscc:metadataSchema|lom:metadataSchema">    
	   <xsl:if test="normalize-space(.)!='LOMv1.0' and normalize-space(.)!='IEEE LOM 1.0'">	
	        <metadatascheme>
			<xsl:value-of select = "."/>   
		</metadatascheme>
	   </xsl:if>	
	</xsl:template>  

	<!-- ==================================================================================  -->

	<!-- Technical Template and Children ************************************************** -->

	<xsl:template match = "lomimscc:technical|lom:technical">
		
		<technical>
			
			<xsl:comment>Technical Section</xsl:comment>
			<xsl:apply-templates select = "lomimscc:format|lom:format"/>
			<xsl:apply-templates select = "lomimscc:size|lom:size"/>
			<xsl:apply-templates select = "lomimscc:location|lom:location"/>
			<xsl:apply-templates select = "lomimscc:requirement|lom:requirement"/>
			<xsl:apply-templates select = "lomimscc:installationRemarks|lom:installationRemarks"/>
			<xsl:apply-templates select = "lomimscc:otherPlatformRequirements|lom:otherPlatformRequirements"/>
			<xsl:apply-templates select = "lomimscc:duration|lom:duration"/>
			
			  <xsl:call-template name = "wildcard"/>

		</technical>
		
	</xsl:template>  

	<xsl:template match = "lomimscc:installationRemarks|lom:instalationRemarks">
		<installationremarks>
			<xsl:apply-templates select = "*"/>
		</installationremarks>
	</xsl:template>

	<xsl:template match = "lomimscc:otherPlatformRequirements|lom:otherPlatformRequirements">
		<otherplatformrequirements>
			<xsl:apply-templates select = "*"/>
		</otherplatformrequirements>
	</xsl:template>

	<xsl:template match = "lomimscc:duration|lom:duration">
		<duration>
			<xsl:apply-templates select = "*" mode = "duration"/>
		</duration>
	</xsl:template>


	<xsl:template match = "lomimscc:requirement|lom:requirement">
		<xsl:for-each select="lomimscc:orComposite|lom:orComposite">
			<xsl:element name="requirement">
				<xsl:apply-templates select = "*"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>


	
	


	<xsl:template match = "lomimscc:type|lom:type">
		<xsl:param name = "typeName" select = "'type'"/>
		<xsl:param name = "source" select = "lomimscc:source|lom:source"/>
		<xsl:element name = "{$typeName}">
			<xsl:apply-templates select = "*">
				<xsl:with-param name = "source" select = "$source"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match = "lomimscc:name|lom:name">
		<xsl:param name = "nameName" select = "'name'"/>
		<xsl:param name = "source" select = "lomimscc:source|lom:source"/>
		<xsl:element name = "{$nameName}">
			<xsl:apply-templates select = "*">
				<xsl:with-param name = "source" select = "$source"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match = "lomimscc:minimumVersion|lom:minimumVersion">
		<minimumversion><xsl:value-of select = "."/></minimumversion>
	</xsl:template>

	<xsl:template match = "lomimscc:maximumVersion|lom:maximumVersion">
		<maximumversion><xsl:value-of select = "."/></maximumversion>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- Educational Template and Children ************************************************ -->
	
	<xsl:template match = "lomimscc:educational|lom:educational">    
		<educational>
			<xsl:comment>Educational Section</xsl:comment>
			<xsl:apply-templates select = "*" />
		</educational>
	</xsl:template>  

	<xsl:template match = "lomimscc:interactivityType|lom:interactivityType">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'interactivitytype'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:learningResourceType|lom:learningResourceType">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'learningresourcetype'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:interactivityLevel|lom:interactivityLevel">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'interactivitylevel'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:semanticDensity|lom:semanticDensity">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'semanticdensity'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:intendedEndUserRole|lom:intendedEndUserRole">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'intendedenduserrole'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:context|lom:context">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'context'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:difficulty|lom:difficulty">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'difficulty'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match = "lomimscc:typicalAgeRange|lom:typicalAgeRange">
		<typicalagerange>
			<xsl:apply-templates select = "*"/>
		</typicalagerange>
	</xsl:template>

	<xsl:template match = "lomimscc:typicalLearningTime|lom:typicalLearningTime">
		<typicallearningtime>
			<xsl:apply-templates select = "*" mode = "duration"/>
		</typicallearningtime>
	</xsl:template>

	<xsl:template match = "lomimscc:description|lom:description" mode = "duration">
		<description>
			<xsl:apply-templates select = "*"/>
		</description>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- Rights Template Children ********************************************************* -->
	
	<xsl:template match = "lomimscc:rights|lom:rights">    
		<rights>
			<xsl:comment>Rights Section</xsl:comment>
			<xsl:apply-templates select = "*" />
		</rights>
	</xsl:template>  

	<xsl:template match = "lomimscc:cost|lom:cost">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'cost'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:copyrightAndOtherRestrictions|lom:copyrightAndOtherRestrictions">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'copyrightandotherrestrictions'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- Relations Template Children ****************************************************** -->
	
	<xsl:template match = "lomimscc:relation|lom:relation">    
		<relation>
			<xsl:comment>Relations Section</xsl:comment>
			<xsl:apply-templates select = "*" />
		</relation>
	</xsl:template>  

	<xsl:template match = "lomimscc:kind|lom:kind">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'kind'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:resource|lom:resource">
		<resource>
			<xsl:call-template name = "identifier"/>
			<xsl:call-template name = "catalogentry"/>
			<xsl:apply-templates select = "lomimscc:description|lom:description"/>
			<xsl:call-template name = "wildcard"/>
		</resource>
	</xsl:template>

	<!-- ==================================================================================  -->
	
	<!-- Annotation Template and Children ************************************************* -->
	
	<xsl:template match = "lomimscc:annotation|lom:annotation">    
		<annotation>
			<xsl:comment>Annotation Section</xsl:comment>
			<xsl:call-template name="person"/>
			<xsl:apply-templates select = "*" />
		</annotation>
	</xsl:template>
	  
	
	<xsl:template name = "person">
		<xsl:for-each select="lomimscc:entity|lom:entity">
			<person>
				<vcard><xsl:value-of select = "."/></vcard>
			</person>
		</xsl:for-each>
	</xsl:template>

	<!-- ==================================================================================  -->
	
	<!-- Classification Template Children ************************************************* -->

	<xsl:template match = "lomimscc:classification|lom:classification">    
		<classification>
			<xsl:comment>Classification Section</xsl:comment>
			
			<xsl:apply-templates select = "*"/>
		</classification>  
	</xsl:template>

	<xsl:template match = "lomimscc:purpose|lom:purpose">
		<xsl:call-template name = "vocabularyOther">
			<xsl:with-param name = "source" select = "lomimscc:source|lom:source"/>
			<xsl:with-param name = "standardName" select = "'purpose'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "lomimscc:taxonPath|lom:taxonPath">
		<taxonpath>
			<xsl:apply-templates select = "lomimscc:source|lom:source" mode = "taxonpath"/>
			<xsl:apply-templates select = "lomimscc:taxon|lom:taxon" mode = "taxonpath"/>
		</taxonpath>
	</xsl:template>

	<xsl:template match = "lomimscc:taxon|lom:taxon" mode = "taxonpath">
		<taxon>
			<xsl:if test = "lomimscc:entry|lom:entry">
				<xsl:apply-templates select = "lomimscc:entry|lom:entry"/>
			</xsl:if>
		</taxon>
		<xsl:apply-templates select = "lomimscc:taxon|lom:taxon" mode = "taxonpath"/>
	</xsl:template>

	<xsl:template match = "lomimscc:source|lom:source" mode = "taxonpath">
		<source>
			<xsl:apply-templates select = "*"/>
		</source>
	</xsl:template>

	<!-- ==================================================================================  -->
	
	<!-- Utility Templates ****************************************************************  -->	
	<!-- These templates handle conversion of (possibly bogus) date and time data to the new
	     format. -->
	
	<xsl:template match = "lomimscc:duration|lom:duration">
		<duration>
		<xsl:call-template name = "datetimeConversion">
			<xsl:with-param name = "data" select = "."/>
		</xsl:call-template>
		</duration>
	</xsl:template>

	<xsl:template match = "lomimscc:duration|lom:duration" mode = "duration">
		<datetime>
			<xsl:call-template name = "durationConversion">
				<xsl:with-param name = "data" select = "."/>
			</xsl:call-template>
		</datetime>
	</xsl:template>

	<!-- The 'check' variable below handles checking to see what the format of the data is. 
	     The usage of 'translate()' is patterned after the examples on pages 561-562 of "XSLT 2nd Edition:
	     Programmer's Reference", by Michael Kay, published by Wrox Press, ISBN 1-861005-06-7. -->

	<xsl:template name = "datetimeConversion">
		<xsl:param name = "data"/>
		<xsl:variable name = "check"
		              select = "translate($data, '0123456789d', 'dddddddddd ')"/>
		
		<!-- First, just check to see if the data is correct as is -->
		
		<xsl:choose>
			<xsl:when test = "starts-with($check, 'dddd-dd-ddTdd:dd:dd.d') or
			                  $check = 'dddd-dd-ddTdd:dd:dd' or
			                  $check = 'dddd-dd-dd' or
			                  $check = 'dddd-dd' or
			                  $check = 'dddd'">
				<datetime>
					<xsl:value-of select = "$data"/>
				</datetime>
			</xsl:when>

			<!-- ##DateTimeConversion -->
			<!-- If we get here, it means we have data which is not correct as is; see if we can translate it.
			     Users may want to add (or remove) translation mechanisms below. -->
			
			<xsl:when test = "$check = 'dddddddd'">
				<datetime>
					<xsl:value-of select = "substring($data, 1, 4)"/>-<xsl:value-of select = "substring($data, 5, 2)"/>-<xsl:value-of select = "substring($data, 7, 2)"/>
				</datetime>
			</xsl:when>
			<xsl:otherwise>
				<datetime>
					<xsl:value-of select = "$data"/>
				</datetime>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
		
	<xsl:template name = "durationConversion">
		<xsl:param name = "data"/>
		<xsl:variable name = "check"
		              select = "translate($data, '0123456789d', 'dddddddddd ')"/>		
		<xsl:choose>
			<xsl:when test = "starts-with($check, 'dddd-dd-ddTdd:dd:dd')">
				<xsl:variable name = "yearsVal">
					<xsl:call-template name = "durationConversionUtil">
						<xsl:with-param name = "substring" select = "substring($data, 1, 4)"/>
						<xsl:with-param name = "ending" select = "'Y'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "monthsVal">
					<xsl:call-template name = "durationConversionUtil">
						<xsl:with-param name = "substring" select = "substring($data, 6, 2)"/>
						<xsl:with-param name = "ending" select = "'M'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "daysVal">
					<xsl:call-template name = "durationConversionUtil">
						<xsl:with-param name = "substring" select = "substring($data, 9, 2)"/>
						<xsl:with-param name = "ending" select = "'D'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "hoursVal">
					<xsl:call-template name = "durationConversionUtil">
						<xsl:with-param name = "substring" select = "substring($data, 12, 2)"/>
						<xsl:with-param name = "ending" select = "'H'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "minutesVal">
					<xsl:call-template name = "durationConversionUtil">
						<xsl:with-param name = "substring" select = "substring($data, 15, 2)"/>
						<xsl:with-param name = "ending" select = "'M'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "secondsVal">
					<xsl:call-template name = "durationConversionUtil">
						<xsl:with-param name = "substring" select = "substring($data, 18)"/>
						<xsl:with-param name = "ending" select = "'S'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "separatorVal">
					<xsl:if test = "string-length($hoursVal) > 0 or string-length($minutesVal) > 0 or
					                string-length($secondsVal) > 0">
						<xsl:value-of select = "'T'"/>
					</xsl:if>
				</xsl:variable>

				<!-- Finally, assemble the entire package -->
				
				<xsl:variable name = "res">
					P
					<xsl:value-of select = "$yearsVal"/>
					<xsl:value-of select = "$monthsVal"/>
					<xsl:value-of select = "$daysVal"/>
					<xsl:value-of select = "$separatorVal"/>
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

	<xsl:template name = "durationConversionUtil">
		<xsl:param name = "substring"/>
		<xsl:param name = "ending"/>
		<xsl:variable name = "check"
		              select = "translate($substring, '123456789z', 'zzzzzzzzz ')"/>
		<xsl:variable name = "val">
			<xsl:if test = "contains($check, 'z')">
				<xsl:value-of select = "concat($substring, $ending)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select = "$val"/>
	</xsl:template>

	<xsl:template match = "lomimscc:string|lom:string">    
		<xsl:param name = "lang" select = "@language"/>
		<langstring>
			<xsl:attribute name = "lang" namespace="http://www.w3.org/XML/1998/namespace">
				<xsl:choose>
					<xsl:when test = "$lang">
						<xsl:value-of select = "$lang"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select = "'x-none'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select = "."/>
		</langstring>    
	</xsl:template>

	<!-- This template handles the conversion of source/value vocabularies to the new binding
	     format. There are two sets of source/value child templates; one for LOM vocabularies,
	     and one for non-LOM vocabularies. -->

	<xsl:template name = "vocabularyOther">
		<xsl:param name = "source"/>
		<xsl:param name = "standardName"/>
		<xsl:choose>
			<xsl:when test = "$source != 'LOMv1.0'">
				<xsl:element name = "{$standardName}">
					<xsl:apply-templates select = "*" mode = "nonLOM"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name = "{$standardName}">
					<xsl:apply-templates select = "*"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match = "lomimscc:source|lom:source">
		<source>	  
			<xsl:element name="langstring">
		     		<xsl:attribute name = "lang" namespace="http://www.w3.org/XML/1998/namespace">x-none</xsl:attribute>
		  		<xsl:value-of select = "."/>
			</xsl:element>	
		</source>
	</xsl:template>
	
	
	<xsl:template match = "lomimscc:source|lom:source" mode = "nonLOM">
		<source>	  
			<xsl:element name="langstring">
		     		<xsl:attribute name = "lang" namespace="http://www.w3.org/XML/1998/namespace">x-none</xsl:attribute>
		  		<xsl:value-of select = "."/>
			</xsl:element>	
		</source>
	</xsl:template>

	<xsl:template match = "lomimscc:value|lom:value" mode = "nonLOM">
		<value>
			<xsl:element name="langstring">
		     		<xsl:attribute name = "lang" namespace="http://www.w3.org/XML/1998/namespace">x-none</xsl:attribute>
				<xsl:value-of select = "."/>
			</xsl:element>
		</value>
	</xsl:template>
	
	
	
	<!-- The following template does all of the conversion from the LOM binding's vocabulary to
	     the IMS binding's vocabulary. It is used only for LOM vocabularies. 
	 -->
	     
	<xsl:template match = "lomimscc:value|lom:value">
		<xsl:variable name = "val" select = "."/>
		<value>
		     
		     <xsl:element name="langstring">
		     	<xsl:attribute name = "lang" namespace="http://www.w3.org/XML/1998/namespace">x-none</xsl:attribute>
		     <xsl:choose>
			
			<!-- ##VocabularyTokenReplacement -->
			
				<xsl:when test = "$val = 'ms-internet explorer'">Microsoft Internet Explorer</xsl:when>
				<xsl:when test = "$val = 'ms-windows'">MS-Windows</xsl:when>
				<xsl:when test = "$val = 'other'">Continuous Formation</xsl:when>
			<!--	
				<xsl:when test = "$val = 'school'">Primary Education</xsl:when>
				<xsl:when test = "$val = 'school'">Secondary Education</xsl:when>
				<xsl:when test = "$val = 'higher education'">University First Cycle</xsl:when>
				<xsl:when test = "$val = 'higher education'">University Second Cycle</xsl:when>
				<xsl:when test = "$val = 'higher education'">University Postgrade</xsl:when>
				<xsl:when test = "$val = 'higher education'">Technical School First Cycle</xsl:when>
				<xsl:when test = "$val = 'higher education'">Technical School Second Cycle</xsl:when>
				<xsl:when test = "$val = 'training'">Professional Formation</xsl:when>
				<xsl:when test = "$val = 'training'">Vocational Training</xsl:when>  
			-->
				<!-- Possibly need to add tokens here. To add a new token, change the OLD and NEW below
				     to the values that you want, and then copy that text out of the comment into the
				     logic above.
				     
				<xsl:when test = "$val = 'OLD'">NEW</xsl:when>
				     -->
				
				<xsl:otherwise>
					<xsl:value-of select="$val"/>
				</xsl:otherwise>
			</xsl:choose>
			</xsl:element>
		</value>
	</xsl:template>

	

	<!-- ==================================================================================  -->
	
	<!-- Template for parsing xsi:schemaLocation attribute and remove unnecessary schemas -->
	<xsl:template name="schemaMetadataLocationParsing">
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
	<xsl:if test="$namespace!='http://ltsc.ieee.org/xsd/imscc/LOM'
		and $namespace!='http://www.imsglobal.org/xsd/imsmd_v1p2'">
		<xsl:value-of select="concat($namespace, ' ', $schema, ' ')"/>
	</xsl:if>
	<xsl:if test="contains($remainder,' ') ">
		<xsl:call-template name="schemaMetadataLocationParsing">
			<xsl:with-param name="original" select="$remainder"/>
		</xsl:call-template>
	</xsl:if>  
    </xsl:template>
	
	
</xsl:stylesheet>
