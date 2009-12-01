<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wl="http://www.imsglobal.org/xsd/imswl_v1p0"
    exclude-result-prefixes="wl">
<xsl:output indent="yes" method="html" encoding="UTF-8"/>
<xsl:strip-space elements="*"/>

<xsl:template match="/">
	<xsl:apply-templates select="wl:webLink"/>
</xsl:template>

<xsl:template match="wl:webLink">
	<xsl:variable name="title" select="title"/>
	<html>
	<head>
		<title><xsl:value-of select="$title"/></title>
		
		<script language="javascript">
		function loadPage(url, target, window_properties)
		{
		 	window.open(url,target ,window_properties)
		}	
		</script>
		
	</head>
	
	<xsl:variable name="href" select="url/@href"/>
	<xsl:variable name="target" select="url/@target"/>
	<xsl:variable name="windowFeatures" select="url/@windowFeatures"/>
	<body onLoad="javascript:loadPage('{$href}','{$target}','{$windowFeatures}')">
		<h2><xsl:value-of select="$title"/></h2>
		<a href="{$href}"><xsl:value-of select="$href"/></a>
	</body>
	</html>
</xsl:template>
</xsl:stylesheet>
