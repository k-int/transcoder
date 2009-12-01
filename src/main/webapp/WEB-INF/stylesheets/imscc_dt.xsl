<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dt="http://www.imsglobal.org/xsd/imsdt_v1p0"
    exclude-result-prefixes="dt">
<xsl:output indent="yes" method="html" encoding="UTF-8"/>
<xsl:strip-space elements="*"/>

<xsl:template match="/">
	<xsl:apply-templates select="dt:topic"/>
</xsl:template>

<xsl:template match="dt:topic">
	<xsl:variable name="title" select="title"/>
	<html>
	<head>
		<title><xsl:value-of select="$title"/></title>	
	</head>
	
	<body>
		<h2><xsl:value-of select="$title"/></h2>
		<div>
			<xsl:for-each select="text/* | text/text()">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</div>
		<xsl:if test="attachments">
			<div>
			<ul>
			<xsl:for-each select="attachments/attachment">
				<xsl:variable name="href">
					<xsl:call-template name="delete-substring">
						<xsl:with-param name="value" select="@href"/>
						<xsl:with-param name="from" select="'$IMS-CC-FILEBASE$'"/>
					</xsl:call-template>
				</xsl:variable>					
				<li>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:value-of select="$href"/>
						</xsl:attribute>
						<xsl:value-of select="$href"/>
					</xsl:element>
				</li>		
			</xsl:for-each>
			</ul>
			</div>
		</xsl:if>
	</body>
	</html>
</xsl:template>


<xsl:template match='text()'>
	<xsl:variable name="text">
	<xsl:call-template name="delete-substring">
		<xsl:with-param name="value" select="."/>
		<xsl:with-param name="from" select="'$IMS-CC-FILEBASE$'"/>
	</xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$text" disable-output-escaping="yes"/>
</xsl:template>

<xsl:template match='@*'>
	<xsl:variable name="text">
	<xsl:call-template name="delete-substring">
		<xsl:with-param name="value" select="."/>
		<xsl:with-param name="from" select="'$IMS-CC-FILEBASE$'"/>
	</xsl:call-template>
	</xsl:variable>
	<xsl:attribute name="{name()}">
		<xsl:value-of select="$text" disable-output-escaping="yes"/>
	</xsl:attribute>
</xsl:template>

<xsl:template match='*'>
      	<xsl:element name="{name()}">
		<xsl:for-each select="* | text() | @*">
				<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:element>
</xsl:template>

<xsl:template name="delete-substring">
      <xsl:param name="value" />
      <xsl:param name="from" />
      <xsl:choose>
         <xsl:when test="contains($value,$from)">
            <xsl:value-of select="substring-before($value,$from)" />
            <xsl:call-template name="delete-substring">
               <xsl:with-param name="value" select="substring-after($value,$from)" />
               <xsl:with-param name="from" select="$from" />
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$value" />
         </xsl:otherwise>
      </xsl:choose>
</xsl:template>

	
</xsl:stylesheet>
