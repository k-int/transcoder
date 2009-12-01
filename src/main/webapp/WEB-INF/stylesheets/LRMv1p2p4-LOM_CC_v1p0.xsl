<?xml version = "1.0" encoding = "UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
	xmlns = "http://ltsc.ieee.org/xsd/imscc/LOM"
	xmlns:md = "http://www.imsglobal.org/xsd/imsmd_v1p2"
	xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="md">
	
	<xsl:output method = "xml" encoding="utf-8" indent="yes"/> 
	
	<!-- ***********************************************************************************-->
	<!--                                                                                    -->
	<!-- Author:    Colin Smythe                                                            -->
	<!-- Version:   1.0                                                                     -->
	<!-- Date:      31st August, 2006                                                     	-->
	<!-- Comments:  This XSL transforms instances of IMS Metadata, version 1.2.4, into		-->
	<!--            instances of IEEE LOM, version 1.0.	The converted files are placed in	-->
	<!--            the same directory as the source instance.   	                        -->
	<!--                                                                                    -->
	<!--                                                                                    -->
	<!-- Processor: This transform uses standard XSL v1.0.  No extensions are used.         -->
	<!--                                                                                    -->
	<!-- History:   Draft v1.0 of the IMS Metadata version 1.2.4 to IEEE LOM version 1.0	-->
	<!--            transform was produced by Brendon Towle, Thomson NETg, on 16 September	-->
	<!--            2003.  It was based upon Thomas Dooley's LOM binding.					-->
	<!--                                                                                    -->
	<!-- Copyright: 2006 (c) IMS Global Learning Consortium Inc.  All Rights Reserved.      -->
	<!-- IMS Global Learning Consortium, Inc. (IMS/GLC) is publishing the information 		-->
	<!-- contained in this binding (“Specification”) for purposes of scientific,      		-->
	<!-- experimental and scholarly collaboration only.  IMS/GLC makes no warranty or    	-->
	<!-- representation regarding the accuracy or completeness of the Specification.  This	-->
	<!-- material is provided on an “As Is” and “As Available” basis.  The Specification is	-->
	<!-- at all times subject to change and revision without notice.  It is your sole		-->
	<!-- responsibility to evaluate the usefulness, accuracy and completeness of the		-->
	<!-- Specification as it relates to you.  IMS/GLC would appreciate receiving your		-->
	<!-- comments and suggestions.  Please contact IMS/GLC through our website at:			-->
	<!-- http://www.imsglobal.org.															-->
	<!--                                                                                    -->
	<!--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$-->


	<!-- ==================================================================================  -->
	
	<!-- Top Level Template *************************************************************** -->
	
	<xsl:template match = "md:lom" mode="cc">
		<lom xmlns = "http://ltsc.ieee.org/xsd/imscc/LOM"
			xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance">
			<xsl:apply-templates select = "*" mode="cc"/>
		</lom>
		
	</xsl:template>  
	
	
	<!-- ==================================================================================  -->

	<!-- This is the default template that does most of the work. It gets called when there is
	     no more specific template available. The logic is: 
	     Copy the element and all attributes from the IMS namespace,
	     and put them in the target document, in the same order with the same names, but in the
	     IEEE namespace. If the element has attributes that are not from the IMS namespace, copy
	     them to the target element, leaving the namespace unchanged. If the node has text children,
	     copy them to the target element as well. 
	     
	     Note the special-case structure to handle (i.e., remove) the 'type' attribute from the
	     IMS binding.  -->

	<xsl:template match = "md:*" mode="cc">
		
		<xsl:variable name = "name" select = "local-name()"/>
		<xsl:element name = "{local-name()}">
			<xsl:for-each select ="@*">
				<xsl:choose>
					<xsl:when test = "local-name() = 'type'"/>
					<xsl:when test = "namespace-uri() != 'http://www.imsglobal.org/xsd/imsmd_rootv1p2p1'">
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
			<xsl:apply-templates select = "*" mode="cc"/>
			<xsl:apply-templates select = "comment()"/>
		</xsl:element>
		<xsl:for-each select ="@*">
			<xsl:if test = "local-name() = 'type'">
				<xsl:comment>The following information was removed from a 'type' attribute:</xsl:comment>
				<xsl:comment><xsl:value-of select = "."/></xsl:comment>
			</xsl:if>
		</xsl:for-each>
		
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- General Template and Children **************************************************** -->

	<xsl:template match = "md:general" mode="cc">
		
		<general>
			
			<xsl:comment>General Section</xsl:comment>
			<xsl:call-template name = "catalogAndIdentifierCC"/>
			<xsl:apply-templates select = "md:title" mode="cc"/>
			<xsl:apply-templates select = "md:language" mode="cc"/>
			<xsl:apply-templates select = "md:description" mode="cc"/>
			<xsl:apply-templates select = "md:keyword" mode="cc"/>
			<xsl:apply-templates select = "md:coverage" mode="cc"/>
			<xsl:apply-templates select = "md:structure" mode="cc"/>
			<xsl:apply-templates select = "md:aggregationlevel" mode="cc"/>
		</general>
		
	</xsl:template>

	
	<xsl:template match = "md:language"  mode="cc">
		<xsl:if test="local-name(..)='general'">
			<language><xsl:value-of select="."/></language>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match = "md:structure"  mode="cc"/>
	
	<xsl:template match = "md:aggregationlevel"  mode="cc"/>
		
		


	<!-- ##CatologEntry -->
	<!-- The logic of this is as follows. If there is an identifier element, create a catalogentry in
	     the target, where the entry is the value of the identifier element and the catalog is blank.
	     Any catalogentry elements get copied into comments. If there is no identifier element,
	     copy catalogentry elements as is. -->
	     
	<xsl:template name = "catalogAndIdentifierCC">
		<xsl:choose>
			<xsl:when test = "md:identifier">
				<xsl:for-each select = "md:identifier">
					<identifier>
						<catalog/>
						<entry><xsl:value-of select = "."/></entry>
					</identifier>
				</xsl:for-each>
				<xsl:if test = "md:catalogentry">
					<xsl:comment>The following CATALOGENTRY elements were removed from the original source:</xsl:comment>
					<xsl:for-each select = "md:catalogentry">
						<xsl:comment>Catalog: <xsl:value-of select = "md:catalog"/>, Entry: <xsl:value-of select = "md:entry/md:langstring"/>
						</xsl:comment>
					</xsl:for-each>
				</xsl:if>
			</xsl:when>
			<xsl:when test = "md:catalogentry">
				<xsl:for-each select = "md:catalogentry">
					<xsl:call-template name = "catalogentry_cc"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<xsl:template match = "md:entry" mode="cc">
		<entry>
			<xsl:value-of select = "md:langstring"/>
		</entry>
	</xsl:template>
	
	<!-- Note that the following template is _named_ 'catalogentry'; it does not automatically
	     match 'md:catalogentry' elements. -->
	
	<xsl:template name = "catalogentry_cc">
		<identifier>
			<xsl:apply-templates select = "*" mode="cc"/>
		</identifier>
	</xsl:template>

	
	
	<xsl:template match = "md:identifier" mode="cc"/>
	<xsl:template match = "md:catalogentry" mode="cc"/>
	
	<!-- ==================================================================================  -->
	     
	<!-- Lifecycle Template and Children ************************************************** -->

	<xsl:template match = "md:lifecycle" mode="cc">    
		<lifeCycle>
			<xsl:comment>Lifecycle Section</xsl:comment>
			<xsl:apply-templates select = "*" mode="cc"/>
		</lifeCycle>
	</xsl:template>

	<xsl:template match = "md:centity" mode="cc">
		<entity>
			<xsl:value-of select = "md:vcard"/>
		</entity>
	</xsl:template>

	<xsl:template match = "md:role" mode="cc">
		<xsl:call-template name = "vocabularyOther_cc">
			<xsl:with-param name = "source" select = "md:source/md:langstring"/>
			<xsl:with-param name = "name" select = "'role'"/>
			
		</xsl:call-template>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- Metametadata Template and Children  ********************************************** -->
	
	<xsl:template match = "md:metametadata" mode="cc"/>

	<xsl:template match = "md:metadatascheme" mode="cc">     
		<metaDataSchema>
			<xsl:value-of select = "."/>   
		</metaDataSchema>
	</xsl:template>  

	<!-- ==================================================================================  -->

	<!-- Technical Template and Children ************************************************** -->

	<xsl:template match = "md:technical" mode="cc">
		
		<technical>
			<xsl:comment>Technical Section</xsl:comment>
			<xsl:apply-templates select = "*" mode="cc"/>
		</technical>
		
	</xsl:template>  

	
	
	<xsl:template match="md:requirement" mode="cc" />
	<xsl:template match = "md:installationremarks" mode="cc" />
	<xsl:template match = "md:otherplatformrequirements" mode="cc" />
	<xsl:template match = "md:duration" mode="cc" />
	<xsl:template match = "md:location" mode="cc" />




	<xsl:template match = "md:type" mode="cc">
		<xsl:param name = "typeName" select = "'type'"/>
		<xsl:param name = "source" select = "'LOMv1.0'"/>
		<xsl:element name = "{$typeName}">
			<xsl:apply-templates select = "*" mode="cc">
				<xsl:with-param name = "source" select = "$source"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match = "md:name" mode="cc">
		<xsl:param name = "nameName" select = "'name'"/>
		<xsl:param name = "source" select = "'LOMv1.0'"/>
		<xsl:element name = "{$nameName}">
			<xsl:apply-templates select = "*" mode="cc">
				<xsl:with-param name = "source" select = "$source"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match = "md:minimumversion" mode="cc">
		<minimumVersion><xsl:value-of select = "."/></minimumVersion>
	</xsl:template>

	<xsl:template match = "md:maximumversion" mode="cc">
		<maximumVersion><xsl:value-of select = "."/></maximumVersion>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- Educational Template and Children ************************************************ -->
	
	<xsl:template match = "md:educational" mode="cc">    
		<educational>
			<xsl:comment>Educational Section</xsl:comment>
			
			<xsl:apply-templates select = "*" mode="cc"/>
		</educational>
	</xsl:template>  

	<xsl:template match = "md:interactivitytype" mode="cc" />
	<xsl:template match = "md:version" mode="cc" />
	<xsl:template match = "md:status" mode="cc" />
		

	<xsl:template match = "md:learningresourcetype" mode="cc">
		<learningResourceType>
			<source>LOMv1.0</source>
			<value>IMS Common Cartridge</value>
		</learningResourceType>
	</xsl:template>

	<xsl:template match = "md:interactivitylevel" mode="cc"/>
	<xsl:template match = "md:semanticdensity" mode="cc"/>
	<xsl:template match = "md:intendedenduserrole" mode="cc"/>
	<xsl:template match = "md:context" mode="cc" />
	<xsl:template match = "md:difficulty" mode="cc"/>
	<xsl:template match = "md:typicalagerange" mode="cc" />
	<xsl:template match = "md:typicallearningtime" mode="cc" />
	
	<xsl:template match = "md:description" mode = "cc">
		<xsl:if test="local-name(..)!='educational'">
			<description><xsl:apply-templates select="*" mode="cc"/></description>
		</xsl:if>
	</xsl:template>	

	

	<!-- ==================================================================================  -->

	<!-- Rights Template Children ********************************************************* -->
	
	<xsl:template match = "md:rights" mode="cc">    
		<rights>
			<xsl:comment>Rights Section</xsl:comment>
			<xsl:apply-templates select = "*" mode="cc"/>
		</rights>
	</xsl:template>  

	<xsl:template match = "md:cost" mode="cc">
		<xsl:call-template name = "vocabularyOther_cc">
			<xsl:with-param name = "source" select = "md:source/md:langstring"/>
			<xsl:with-param name = "name" select = "'cost'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "md:copyrightandotherrestrictions" mode="cc">
		<xsl:call-template name = "vocabularyOther_cc">
			<xsl:with-param name = "source" select = "md:source/md:langstring"/>
			<xsl:with-param name = "name" select = "'copyrightAndOtherRestrictions'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- ==================================================================================  -->

	<!-- Relations Template Children ****************************************************** -->
	
	<xsl:template match = "md:relation" mode="cc">    
		<relation>
			<xsl:comment>Relations Section</xsl:comment>
			<xsl:apply-templates select = "*" mode="cc"/>
		</relation>
	</xsl:template>  

	<xsl:template match = "md:kind" mode="cc">
		<xsl:call-template name = "vocabularyOther_cc">
			<xsl:with-param name = "source" select = "md:source/md:langstring"/>
			<xsl:with-param name = "name" select = "'kind'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "md:resource" mode="cc">
		<resource>
			<xsl:call-template name = "catalogAndIdentifierCC"/>
			<xsl:apply-templates select = "md:description" mode="cc"/>
		</resource>
	</xsl:template>

	<!-- ==================================================================================  -->
	
	<!-- Annotation Template and Children ************************************************* -->
	
	<xsl:template match = "md:annotation" mode="cc"/>    
	<xsl:template match = "md:size" mode="cc"/>
	<xsl:template match = "md:lcoation" mode="cc"/>    	
	  
	<xsl:template match = "md:person" mode="cc">
		<entity>
			<xsl:value-of select = "md:vcard"/>
		</entity>
	</xsl:template>

	<!-- ==================================================================================  -->
	
	<!-- Classification Template Children ************************************************* -->

	<xsl:template match = "md:classification" mode="cc">    
		<classification>
			<xsl:comment>Classification Section</xsl:comment>
			
			<xsl:apply-templates select = "*" mode="cc"/>
		</classification>  
	</xsl:template>

	<xsl:template match = "md:purpose" mode="cc">
		<xsl:call-template name = "vocabularyOther_cc">
			<xsl:with-param name = "source" select = "md:source/md:langstring"/>
			<xsl:with-param name = "name" select = "'purpose'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match = "md:taxonpath" mode="cc">
		<taxonPath>
			<xsl:apply-templates select = "md:taxon" mode = "taxonpath_cc"/>
			<xsl:apply-templates select = "md:source" mode = "taxonpath_cc"/>
		</taxonPath>
	</xsl:template>

	<xsl:template match = "md:taxon" mode = "taxonpath_cc">
		<taxon>
			<xsl:apply-templates select = "md:id" mode="cc"/>
			<xsl:if test = "md:entry">
				<entry>
					<xsl:apply-templates select = "md:entry/md:langstring" mode="cc"/>
				</entry>
			</xsl:if>
		</taxon>
		<xsl:apply-templates select = "md:taxon" mode = "taxonpath_cc"/>
	</xsl:template>

	<xsl:template match = "md:source" mode = "taxonpath_cc">
		<source>
			<xsl:apply-templates select = "*" mode="cc"/>
		</source>
	</xsl:template>

	<!-- ==================================================================================  -->
	
	<!-- Utility Templates ****************************************************************  -->	
	<!-- These templates handle conversion of (possibly bogus) date and time data to the new
	     format. -->
	
	<xsl:template match = "md:datetime" mode="cc">
		<xsl:call-template name = "datetimeConversion_cc">
			<xsl:with-param name = "data" select = "."/>
		</xsl:call-template>
	</xsl:template>

	

	<!-- The 'check' variable below handles checking to see what the format of the data is. 
	     The usage of 'translate()' is patterned after the examples on pages 561-562 of "XSLT 2nd Edition:
	     Programmer's Reference", by Michael Kay, published by Wrox Press, ISBN 1-861005-06-7. -->

	<xsl:template name = "datetimeConversion_cc">
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
				<dateTime>
					<xsl:value-of select = "$data"/>
				</dateTime>
			</xsl:when>

			<!-- ##DateTimeConversion -->
			<!-- If we get here, it means we have data which is not correct as is; see if we can translate it.
			     Users may want to add (or remove) translation mechanisms below. -->
			
			<xsl:when test = "$check = 'dddddddd'">
				<dateTime>
					<xsl:value-of select = "substring($data, 1, 4)"/>-<xsl:value-of select = "substring($data, 5, 2)"/>-<xsl:value-of select = "substring($data, 7, 2)"/>
				</dateTime>
			</xsl:when>
			<xsl:otherwise>
				<!-- 
				<dateTime>
					<xsl:value-of select = "$data"/>
				</dateTime>
				 -->
				<xsl:comment>This dateTime value <xsl:value-of select="$data"/> was omitted because it is not valid with respect to "DateTimeString" pattern.</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<xsl:template match = "md:langstring" mode="cc">    
		<xsl:param name = "lang" select = "@xml:lang"/>
		<xsl:element name="string">
			<xsl:if test = "$lang">
				<xsl:attribute name = "language" namespace="">
					<xsl:value-of select = "$lang"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select = "."/>
		</xsl:element>
	</xsl:template>

	<!-- This template handles the conversion of source/value vocabularies to the new binding
	     format. There are two sets of source/value child templates; one for LOM vocabularies,
	     and one for non-LOM vocabularies. -->

	<xsl:template name = "vocabularyOther_cc">
		<xsl:param name = "source"/>
		<xsl:param name = "name"/>
		<xsl:element name = "{$name}">
			<xsl:apply-templates select = "*" mode = "cc"/>
		</xsl:element>
	</xsl:template>

	
	<xsl:template match = "md:source" mode="cc"> 
		<xsl:param name = "source" select = "md:langstring"/>
		<xsl:element name = "source">
			<xsl:value-of select = "$source"/>
		</xsl:element>
	</xsl:template>

	
	<!-- The following template does all of the conversion from the old binding's vocabulary to
	     the new binding's vocabulary. It is used only for LOM vocabularies. 
	     
	     The basic rule is that the first character of every word in the token is converted to
	     lower case. If the token is only one word, only the first character is converted.
	     
	     There are some exceptions which are handled by the individual 'when' elements; the 
	     'otherwise' element does the standard case conversion described above.
	     
	     Note that the bulk of the 'when' elements are used to handle the change in vocabulary
	     for element 5.6 Context from the IMS binding to the LOM binding. Users may want to check
	     to see that the choice of token translation agrees with their use. -->
	     
	<xsl:template match = "md:value" mode="cc">
		<xsl:variable name = "val" select = "md:langstring"/>
		<value>
			<xsl:choose>
			
			<!-- ##VocabularyTokenReplacement -->
			
				<xsl:when test = "$val = 'Microsoft Internet Explorer'">ms-internet explorer</xsl:when>
				<xsl:when test = "$val = 'MS-Windows'">ms-windows</xsl:when>
				<xsl:when test = "$val = 'Primary Education'">school</xsl:when>
				<xsl:when test = "$val = 'Secondary Education'">school</xsl:when>
				<xsl:when test = "$val = 'University First Cycle'">higher education</xsl:when>
				<xsl:when test = "$val = 'University Second Cycle'">higher education</xsl:when>
				<xsl:when test = "$val = 'University Postgrade'">higher education</xsl:when>
				<xsl:when test = "$val = 'Technical School First Cycle'">higher education</xsl:when>
				<xsl:when test = "$val = 'Technical School Second Cycle'">higher education</xsl:when>
				<xsl:when test = "$val = 'Professional Formation'">training</xsl:when>
				<xsl:when test = "$val = 'Continuous Formation'">other</xsl:when>
				<xsl:when test = "$val = 'Vocational Training'">training</xsl:when>
				
				<!-- Possibly need to add tokens here. To add a new token, change the OLD and NEW below
				     to the values that you want, and then copy that text out of the comment into the
				     logic above.
				     
				<xsl:when test = "$val = 'OLD'">NEW</xsl:when>
				     -->
				
				<xsl:otherwise>
					<xsl:call-template name = "translateToken_cc">
						<xsl:with-param name = "input" select = "$val"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</value>
	</xsl:template>

	<xsl:template name = "translateToken_cc">
		<xsl:param name = "input"/>
		<xsl:choose>
			<xsl:when test = "contains($input, ' ')">
				<xsl:variable name = "first" select = "substring-before($input, ' ')"/>
				<xsl:variable name = "rest" select = "substring-after($input, ' ')"/>
				<xsl:variable name = "translateFirst">
					<xsl:call-template name = "translateWord_cc">
						<xsl:with-param name = "word" select = "$first"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name = "translateRest">
					<xsl:call-template name = "translateToken_cc">
						<xsl:with-param name = "input" select = "$rest"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select = "concat($translateFirst, ' ', $translateRest)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name = "translateWord_cc">
					<xsl:with-param name = "word" select = "$input"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
<!--
	<xsl:template name = "translateWord">
		<xsl:param name = "word"/>
		<xsl:variable name = "char" select = "substring($word, 1, 1)"/>
		<xsl:variable name = "rest" select = "substring($word, 2)"/>
		<xsl:variable name = "translatedChar"
		              select = "translate($char, 
		                                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
		                                  'abcdefghijklmnopqrstuvwxyz')"/>
		<xsl:value-of select = "concat($translatedChar, $rest)"/>
	</xsl:template>

-->

	<xsl:template name = "translateWord_cc">
		<xsl:param name = "word"/>
		<xsl:value-of select = "translate($word, 
		                                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
		                                  'abcdefghijklmnopqrstuvwxyz')"/>
	</xsl:template>

	<!-- ==================================================================================  -->
	
	

	
</xsl:stylesheet>
