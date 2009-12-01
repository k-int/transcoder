<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.imsglobal.org/xsd/imscc/imscp_v1p1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:imscp="http://www.imsglobal.org/xsd/imscp_v1p1" 
    xmlns:lomimscc="http://ltsc.ieee.org/xsd/imscc/LOM"
    xmlns:lom="http://ltsc.ieee.org/xsd/LOM"
    xmlns:imsmd="http://www.imsglobal.org/xsd/imsmd_v1p2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="imscp imsmd">

<xsl:include href="shared_templates.xsl"/>    
<xsl:include href="LRMv1p2p4-LOMv1p0.xsl"/>
<xsl:include href="LRMv1p2p4-LOM_CC_v1p0.xsl"/>
<xsl:include href="LOMv1p0_to_LOM_CC_v1p0.xsl"/>
<xsl:output indent="yes" method="xml"/>
<xsl:strip-space elements="*"/>
     


<xsl:template match="imscp:manifest">
	
     <xsl:comment>*Transcoder Comment*: This file has transformed by Transcoder service.</xsl:comment>
     <xsl:comment>*Transcoder Comment*: Namespace definition and schema location changed.</xsl:comment>
     

	<manifest identifier="{@identifier}" 
           xmlns="http://www.imsglobal.org/xsd/imscc/imscp_v1p1"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	   <!--  xsi:schemaLocation="{$schemaLocation}" >  -->
	   
	      <xsl:if test="@xml:base">
		      <xsl:attribute name="xml:base">
			<xsl:call-template  name="XMLBaseCheck">
		      		<xsl:with-param name="base" select="@xml:base"/>
			</xsl:call-template>
		      </xsl:attribute>
	      </xsl:if>
	   
	   <metadata>
	     <schema>IMS Common Cartridge</schema>
	     <schemaversion>1.0.0</schemaversion>
	    
	    <!-- Converts metadata using included stylesheet  -->
	    <xsl:if test="imscp:metadata/lom:lom">
	    	<xsl:comment>*Transcoder Comment*: Manifest metadata converted from LOMv1.0 to CC profile of LOMv1.0.</xsl:comment>
	    	<xsl:apply-templates select="imscp:metadata/lom:lom" mode="lom_to_cc"/>
	    </xsl:if>
	    
	    <xsl:if test="imscp:metadata/imsmd:lom">
	    	<xsl:comment>*Transcoder Comment*: Manifest metadata converted from IMS metadata 1.2.4 to CC profile of LOMv1.0.</xsl:comment>
	    	<xsl:apply-templates select="imscp:metadata/imsmd:lom" mode="cc"/>
	    </xsl:if>
	    
	    </metadata>
	    <xsl:apply-templates select="comment()"/>
            <xsl:apply-templates select="imscp:organizations"/>
	    <xsl:apply-templates select="imscp:resources"/>
	    <xsl:apply-templates select="imscp:manifest" mode="comment"/>
		
	    
        </manifest>
    </xsl:template>
    
      
    <xsl:template match="imscp:manifest" mode="comment">
    	<xsl:comment>*Transcoder Comment*: Submanifest (identifier = "<xsl:value-of select="@identifier"/>") has been merged and removed. </xsl:comment>
    </xsl:template>
    
    
    
    <xsl:template match="imscp:resources">
    	<xsl:element  name="resources"> 
       	<xsl:apply-templates select="@*"/>
       	  <xsl:apply-templates select="comment()"/>
	  <xsl:apply-templates select="*"/>
	  <xsl:apply-templates select="/imscp:manifest/imscp:manifest//imscp:resources/imscp:resource" mode="submanifest"/>
	</xsl:element>
    </xsl:template>
    
    <xsl:template match="imscp:metadata"> 
   	<metadata>
   	<xsl:if test="imsmd:lom">
		<xsl:comment>*Transcoder Comment*: Metadata of <xsl:value-of select="local-name(..)"/> (identifier="<xsl:value-of select="../@identifier"/>") converted from IMS metadata 1.2.4 to CC profile of LOMv1.0.</xsl:comment>
	       <xsl:apply-templates select="imsmd:lom"/>
        </xsl:if>
	<xsl:if test="lom:lom">
		<xsl:comment>*Transcoder Comment*: Metadata of <xsl:value-of select="local-name(..)"/> (identifier="<xsl:value-of select="../@identifier"/>") converted from LOMv1.0 to CC profile of LOMv1.0.</xsl:comment>
	    	<xsl:copy-of select="lom:lom"/>
	    </xsl:if>
	</metadata>
    </xsl:template> 
    
    
    <xsl:template match="imscp:organizations"> 
   	<organizations>
		<xsl:variable name="default" select="@default"/>
		<xsl:choose>
			<xsl:when test="imscp:organization[@identifier=$default]">
				<xsl:if test="count(imscp:organization) > 1">
					<xsl:comment>*Transcoder Comment*: Because IMS CC support only single organization, only the organization (identifier="<xsl:value-of select="$default"/>") has transformed.</xsl:comment>	
				</xsl:if>
				<xsl:apply-templates select="imscp:organization[@identifier=$default]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(imscp:organization) > 1">
					<xsl:comment>*Transcoder Comment*: Because IMS CC support only single organization, only the organization (identifier="<xsl:value-of select="imscp:organization[1]/@identifier"/>") has transformed.</xsl:comment>	
				</xsl:if>
				<xsl:apply-templates select="imscp:organization[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</organizations>
    </xsl:template> 
    
    
    <xsl:template match="imscp:organization">
          <xsl:comment>*Transcoder Comment*: Organization (identifier="<xsl:value-of select="@identifier"/>") 'structure' attribute set to 'rooted-hierarchy'.</xsl:comment>		
    	  <organization identifier="{@identifier}" structure="rooted-hierarchy">
		<xsl:choose>
			<xsl:when test="imscp:title!='' ">
				<title><xsl:value-of select="imscp:title"/></title>
			</xsl:when>
			<xsl:when test="count(imscp:item)=1 and  imscp:item[1]/imscp:title!='' ">
				<xsl:comment>*Transcoder Comment*: Organization (identifier="<xsl:value-of select="@identifier"/>") title element as value of first root item title.</xsl:comment>
				<title><xsl:value-of select="imscp:item[1]/imscp:title"/></title>
			</xsl:when>
		</xsl:choose>
		
		<xsl:choose>
			<xsl:when test="count(imscp:item)=1 and not(imscp:item/imscp:title!='')">
				<xsl:apply-templates select="imscp:item"/>		
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>*Transcoder Comment*: Root item (identifier="rootItem") of organization was created.</xsl:comment>
				<item identifier="rootItem">
					<xsl:apply-templates select="imscp:item"/>
				</item>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="imscp:metadata">
			<metadata>
				<xsl:apply-templates select="imscp:metadata/*"/>
			</metadata>
		</xsl:if>
	</organization>
    </xsl:template>
       
    <!-- Item attribute 'identifierref' can point to resource in the main manifest
    or 'sub-manifest', 'organization','item' and 'resource' in submanifest. 
    So here we do all the merging of elements from submanifest. -->
    <xsl:template match="imscp:item">
    	<xsl:variable name="ref" select="@identifierref"/>
    	<xsl:choose>
		 <!-- when item points to 'item' elemenent in submanifest -->
		<xsl:when test="@identifierref and /imscp:manifest/imscp:manifest//imscp:item[@identifier=$ref]">
			<xsl:comment>*Transcoder Comment*: This submanifest item (identifier="<xsl:value-of select="$ref"/>") has been merged.</xsl:comment>
			<xsl:variable name="item_ref">
				<xsl:value-of select="/imscp:manifest/imscp:manifest//imscp:item[@identifier=$ref]/@identifierref"/>
			</xsl:variable>
			<item identifier="{@identifier}">
				<xsl:variable name="title">
					<xsl:variable name="item_title">
						<xsl:value-of select="/imscp:manifest/imscp:manifest//imscp:item[@identifier=$ref]/imscp:title"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$item_title!=''">
							<xsl:value-of select="$item_title"/>
						</xsl:when>
						<xsl:when test="imscp:title">
							<xsl:value-of select="imscp:title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@identifier"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>	
				<title><xsl:value-of select="$title"/></title>
				<xsl:apply-templates select="imscp:item" mode="classic"/>
				<!-- non-leaf item can not reference a resource, so we had created a new one -->
				<xsl:if test="$item_ref!=''">
					<xsl:comment>*Transcoder Comment*: Creating element (identifier="<xsl:value-of select="concat('child_',@identifier)"/>"), because non-leaf element can not reference resource.</xsl:comment>
					<item identifier="{concat('child_',@identifier)}" identifierref="{$item_ref}">
						<title><xsl:value-of select="$title"/></title>
					</item>
				</xsl:if>
				<xsl:apply-templates select="/imscp:manifest/imscp:manifest//imscp:item[@identifier=$ref]/imscp:item" mode="classic"/>
				<xsl:apply-templates select="imscp:metadata" />
				<xsl:apply-templates select="/imscp:manifest/imscp:manifest//imscp:item[@identifier=$ref]/imscp:metadata"/>
			</item>
		</xsl:when>
		<!-- when item points to 'submanifest' elemenent  -->
		<xsl:when test="@identifierref and /imscp:manifest//imscp:manifest[@identifier=$ref]">
			<xsl:comment>*Transcoder Comment*: This submanifest (identifier="<xsl:value-of select="$ref"/>") has been merged.</xsl:comment>
			<item identifier="{@identifier}">
				<title>
					<xsl:variable name="submanifest_title">
						<xsl:apply-templates select="/imscp:manifest//imscp:manifest[@identifier=$ref]" mode="title"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$submanifest_title!=''">
							<xsl:value-of select="$submanifest_title"/>
						</xsl:when>
						<xsl:when test="imscp:title">
							<xsl:value-of select="imscp:title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@identifier"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<xsl:apply-templates select="imscp:item" mode="classic"/>
				<xsl:apply-templates select="/imscp:manifest//imscp:manifest[@identifier=$ref]" mode="merging" />
				<xsl:apply-templates select="imscp:metadata" />
				<xsl:apply-templates select="/imscp:manifest//imscp:manifest[@identifier=$ref]/imscp:metadata"/>
			</item>
		</xsl:when>
		<!-- when item points to 'organization' elemenent element in submanifest  -->
		<xsl:when test="@identifierref and /imscp:manifest/imscp:manifest//imscp:organization[@identifier=$ref]">
			<xsl:comment>*Transcoder Comment*: This submanifest organization (identifier="<xsl:value-of select="$ref"/>") has been merged.</xsl:comment>
			<item identifier="{@identifier}">
				<title>
					<xsl:variable name="organization_title">
						<xsl:value-of select="/imscp:manifest/imscp:manifest//imscp:organization[@identifier=$ref]/imscp:title"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$organization_title!=''">
							<xsl:value-of select="$organization_title"/>
						</xsl:when>
						<xsl:when test="imscp:title">
							<xsl:value-of select="imscp:title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@identifier"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<xsl:apply-templates select="imscp:item" mode="classic"/>
				<xsl:apply-templates select="/imscp:manifest/imscp:manifest//imscp:organization[@identifier=$ref]/imscp:item" mode="classic"/>
				<xsl:apply-templates select="imscp:metadata" />
				<xsl:apply-templates select="/imscp:manifest/imscp:manifest//imscp:organization[@identifier=$ref]/imscp:metadata"/>
			</item>
		</xsl:when>
		<!-- classical item which doesn't point to submanifest  -->
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="classic"/>
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template>
    
    
     <xsl:template match="imscp:manifest" mode="title">
     	<xsl:variable name="default" select="imscp:organizations/@default"/>
    	<xsl:choose>
		<xsl:when test="$default and imscp:organizations/imscp:organization[@identifier=$default]/imscp:title">
			<xsl:value-of select="imscp:organizations/imscp:organization[@identifier=$default]/imscp:title"/>
		</xsl:when>
		<xsl:when test="imscp:organizations/imscp:organization[0]/imscp:title">
			<xsl:value-of select="imscp:organizations/imscp:organization[0]/imscp:title"/>
		</xsl:when>
	</xsl:choose>
     </xsl:template>
    
    
    <xsl:template match="imscp:manifest" mode="merging">
    	<xsl:variable name="default" select="imscp:organizations/@default"/>
    	<xsl:choose>
		<xsl:when test="$default and imscp:organizations/imscp:organization[@identifier=$default]">
			<xsl:apply-templates select="imscp:organizations/imscp:organization[@identifier=$default]/imscp:item" mode="classic"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="imscp:organizations/imscp:organization[0]/imscp:item" mode="classic"/>
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template>
    
    
    
    
    
    
    <!-- Item non-leaf nodes can't reference a resource in Common Cartridge. So if there is such non-leaf item node with resource reference
    we create  new child item node, which will be leaf node and will hold the idententifierref attribute for the resource -->
    <xsl:template match="imscp:item" mode="classic">
    		<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="imscp:title!=''">
						<xsl:value-of select="imscp:title"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@identifier"/>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:variable>
		<xsl:choose>
		<!-- leaf item node or item without resource reference -->	
			<xsl:when test="count(imscp:item)=0 or not(@identifierref)">
			<xsl:element  name="{name()}"> 
				  <xsl:apply-templates select="@*"/>
				  <xsl:for-each select="text()">
					<xsl:value-of select="."/>
				  </xsl:for-each>
				  <xsl:apply-templates select="comment()"/>
				  <xsl:if test="not(imscp:title!='')">
					<xsl:comment>*Transcoder Comment*: Creating title element for item identifier="<xsl:value-of select="@identifier"/>".</xsl:comment>
				  	<title><xsl:value-of select="$title"/></title>
				  </xsl:if>
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
						<xsl:element name="title"><xsl:value-of select="$title"/></xsl:element>
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
 	
    <xsl:template match="imscp:resource">
       	<xsl:element  name="resource"> 
       	<xsl:apply-templates select="@*"/>
       	  <xsl:for-each select="text()">
	  	<xsl:value-of select="."/>
	  </xsl:for-each>
	  <xsl:apply-templates select="comment()"/>
	  <xsl:if test="@href!='' and count(imscp:file)=0">
		<xsl:comment>*Transcoder Comment*: Creating missing file element of resource (identifier="<xsl:value-of select="@identifier"/>").</xsl:comment>
	  	<xsl:element name="file">
			<xsl:attribute name="href">
				<xsl:call-template name="checkHref">
					<xsl:with-param name="href" select="@href"/>
				</xsl:call-template>
			</xsl:attribute>
		</xsl:element>
	  	
	  </xsl:if>
	  <xsl:apply-templates select="*"/>
	</xsl:element>
    </xsl:template>
     
    
    
     <xsl:variable name="root_base">
		<xsl:call-template  name="XMLBaseCheck">
			<xsl:with-param name="base" select="/imscp:manifest/@xml:base"/>
		</xsl:call-template>
		<xsl:call-template  name="XMLBaseCheck">
			<xsl:with-param name="base" select="/imscp:manifest/imscp:resources/@xml:base"/>
		</xsl:call-template>
   </xsl:variable>
   
    
    <xsl:template match="imscp:resource" mode="submanifest">
    	<xsl:comment>*Transcoder Comment*: Submanifest resource (identifier="<xsl:value-of select="@identifier"/>") merged.</xsl:comment>
       	<xsl:element  name="resource"> 
	  <xsl:for-each select="@*">
	  	<xsl:if test="name()!='xml:base'">
	  		<xsl:apply-templates select="."/>
		</xsl:if>
	  </xsl:for-each>
       	  
       	  
	  <xsl:variable name="base">
	  	<xsl:if test="normalize-space($root_base)!=''">
			<xsl:call-template  name="pathRelReplace">
				<xsl:with-param name="path" select="normalize-space($root_base)"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template  name="XMLBaseCheck">
			<xsl:with-param name="base" select="../../@xml:base"/>
		</xsl:call-template>
		<xsl:call-template  name="XMLBaseCheck">
			<xsl:with-param name="base" select="../@xml:base"/>
		</xsl:call-template>
		<xsl:call-template  name="XMLBaseCheck">
			<xsl:with-param name="base" select="@xml:base"/>
		</xsl:call-template>
	  </xsl:variable>
	  
	  
	<xsl:if test="$base!=''">
		<xsl:attribute name="xml:base">
			<xsl:value-of select="$base"/>
		</xsl:attribute>
	</xsl:if>
	  
	  <xsl:for-each select="text()">
	  	<xsl:value-of select="."/>
	  </xsl:for-each>
	  <xsl:apply-templates select="comment()"/>
	  <xsl:if test="@href!='' and count(imscp:file)=0">
	  	<xsl:element name="file">
			<xsl:attribute name="href">
				<xsl:call-template name="checkHref">
					<xsl:with-param name="href" select="."/>
				</xsl:call-template>
			</xsl:attribute>
		</xsl:element>
	  	
	  </xsl:if>
	  <xsl:apply-templates select="*"/>
	</xsl:element>
    </xsl:template>
    
    
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
        <xsl:choose>
		<xsl:when test="local-name()='default' and local-name(..)='organizations'"/>
		<xsl:when test="local-name()='isvisible' and local-name(..)='item'"/>
		<xsl:when test="local-name()='parameters' and local-name(..)='item'"/>
		<xsl:when test="local-name()='structure' and local-name(..)='organization'">
			<xsl:attribute name="structure" namespace="">
				<xsl:value-of select="'rooted-hierarchy'"/>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="local-name()='type' and local-name(..)='resource'">
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
	</xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="pathRelReplace">
    	<xsl:param name="path"/>
	<xsl:choose>
		<xsl:when test = "contains($path, '/')">
			<xsl:variable name = "rest" select = "substring-after($path, '/')"/>
			<xsl:variable name = "translateRest">
				<xsl:call-template name = "pathRelReplace">
					<xsl:with-param name = "href" select = "$rest"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select = "concat('../', $translateRest)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="'../'"/>
		</xsl:otherwise>
	</xsl:choose>
    </xsl:template>
  
    <xsl:template name = "wildcard"/>
    <xsl:template match = "*"/>
    
    <xsl:template match="imscp:schema"/>
    <xsl:template match="imscp:schemaversion"/>
   
</xsl:stylesheet>
