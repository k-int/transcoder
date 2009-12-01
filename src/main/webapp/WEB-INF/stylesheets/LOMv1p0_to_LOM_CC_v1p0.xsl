<?xml version = "1.0" encoding = "UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
	xmlns = "http://ltsc.ieee.org/xsd/imscc/LOM"
	xmlns:lom = "http://ltsc.ieee.org/xsd/LOM"
	xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="lom">
	
	<xsl:output method = "xml" encoding="utf-8" indent="yes"/> 
	
	
	<!-- Top Level Template *************************************************************** -->
	
	<xsl:template match = "lom:lom" mode="lom_to_cc">
		<lom xmlns = "http://ltsc.ieee.org/xsd/imscc/LOM"
			xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">
			<xsl:apply-templates select = "*" mode="lom_to_cc"/>
		</lom>
	</xsl:template>  

	<xsl:template match = "lom:*" mode="lom_to_cc">
		<xsl:variable name = "name" select = "local-name()"/>
		<xsl:element name = "{local-name()}">
			<xsl:for-each select ="@*">
				<xsl:choose>
					<xsl:when test = "local-name() = 'type'"/>
					<xsl:when test = "namespace-uri() != 'http://ltsc.ieee.org/xsd/imscc/LOM'">
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
			<xsl:apply-templates select = "*" mode="lom_to_cc"/>
			<xsl:apply-templates select = "comment()"/>
		</xsl:element>
		<xsl:for-each select ="@*">
			<xsl:if test = "local-name() = 'type'">
				<xsl:comment>The following information was removed from a 'type' attribute:</xsl:comment>
				<xsl:comment><xsl:value-of select = "."/></xsl:comment>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<!-- Language is used only in general context -->
	<xsl:template match = "lom:language"  mode="lom_to_cc">
		<xsl:if test="local-name(..)='general'">
			<language><xsl:value-of select="."/></language>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Description in educational context is unused -->
	<xsl:template match = "lom:description"  mode="lom_to_cc">
		<xsl:if test="local-name(..)!='educational'">
			<description><xsl:value-of select="."/></description>
		</xsl:if>
	</xsl:template>
	
	
	<!-- These elements are unused and therefore prohibited -->
	<xsl:template match = "lom:interactivityLevel" mode="lom_to_cc"/>
	<xsl:template match = "lom:interactivityType" mode="lom_to_cc"/>
	<xsl:template match = "lom:semanticDensity" mode="lom_to_cc"/>
	<xsl:template match = "lom:intendedEndUserrole" mode="lom_to_cc"/>
	<xsl:template match = "lom:context" mode="lom_to_cc" />
	<xsl:template match = "lom:difficulty" mode="lom_to_cc"/>
	<xsl:template match = "lom:typicalAgeRange" mode="lom_to_cc" />
	<xsl:template match = "lom:typicalLearningTime" mode="lom_to_cc" />
	<xsl:template match = "lom:structure"  mode="lom_to_cc"/>
	<xsl:template match = "lom:aggregationLevel"  mode="lom_to_cc"/>
	<xsl:template match = "lom:aggregationlevel"  mode="lom_to_cc"/>
	<xsl:template match = "lom:version" mode="lom_to_cc" />
	<xsl:template match = "lom:status" mode="lom_to_cc" />
	<xsl:template match = "lom:metaMetadata" mode="lom_to_cc"/>
	<xsl:template match = "lom:size" mode="lom_to_cc"/>
	<xsl:template match = "lom:annotation" mode="lom_to_cc"/>
	<xsl:template match = "lom:location" mode="lom_to_cc"/>  
	<xsl:template match = "lom:requirements" mode="lom_to_cc" />
	<xsl:template match = "lom:installationRemarks" mode="lom_to_cc" />
	<xsl:template match = "lom:otherPlatformRequirements" mode="lom_to_cc" />
	<xsl:template match = "lom:duration" mode="lom_to_cc" />
	
</xsl:stylesheet>	

