<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">



  <!-- This template simply copies comments from the source document to the target document. -->
  <xsl:template match="comment()" name="comment">
	<xsl:comment>
	    <xsl:value-of select="."/>
	</xsl:comment>
  </xsl:template>

  <!-- This template checks whether attribute xml:base end with trailing slash. 
  In case that not the trailing slash is added. -->
  <xsl:template name="XMLBaseCheck">
    	<xsl:param name="base"/>
	<xsl:variable name="lastLetter" select="substring($base, string-length($base))"/>
	<xsl:choose>
		<xsl:when test="$lastLetter='/' or $lastLetter='\'">
			<xsl:value-of select="$base"/>
		</xsl:when>
		<xsl:when test="string-length(normalize-space($base))=0">
			<xsl:value-of select="''"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat($base,'/')"/>
		</xsl:otherwise>
	</xsl:choose>		 
    </xsl:template>
    
    
    <!-- This template encode all space in 'href' attributte by '%20'. -->
    <xsl:template name = "checkHref">
                <xsl:param name = "href"/>
                <xsl:choose>
                        <xsl:when test = "contains($href, ' ')">
                                <xsl:variable name = "first" select = "substring-before($href, ' ')"/>
                                <xsl:variable name = "rest" select = "substring-after($href, ' ')"/>
                                <xsl:variable name = "translateRest">
                                        <xsl:call-template name = "checkHref">
                                                <xsl:with-param name = "href" select = "$rest"/>
                                        </xsl:call-template>
                                </xsl:variable>
                                <xsl:value-of select = "concat($first, '%20', $translateRest)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:value-of select="$href"/>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
	
	
</xsl:stylesheet>	
