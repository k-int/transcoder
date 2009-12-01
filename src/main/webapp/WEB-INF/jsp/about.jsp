<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Collection, com.k_int.transcoder.transform.PackageVersion"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
 
<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/style.css" />
  
<s:head/> 

<body>
<div class="main">


<h2>Transcoder - About</h2>



<div class="about">
<h4>Introduction</h4>
A number of different approaches have been taken to standardising eLearning content over the past 8 years, resulting in materials being created in a range of formats. Standards in this area continue to diverge, with the standardisation of SCORM progressing on the one hand, and on the other new initiatives such as Common Cartridge.
Rather than attempting to harmonize the various specifications, a pragmatic solution is to instead provide a service to easily convert content between the various available formats.
</div>

<div class="about">
<h4>Intended scope</h4>
The intended scope of this work is to address conversions between the most common eLearning content formats in use: IMS Content Packaging 1.1, IMS Content Packaging 1.2, SCORM 1.2, SCORM 2004, and IMS Common Cartridge 1.0. In the next phase of project we also plan to look at the most frequently used proprietary formats.
</div>

<div class="about">
<h4>Current state</h4>
At the moment is available conversion of SCORM 1.2(only as a source), SCORM 2004, IMS 1.1 and IMS Common Cartridge 1.0.
Transformation for  IMS 1.2  will be available in future.
Service is under development and testing now, so it is not meant to be 100% working. Final version
will be available in spring 2009. 
</div>

<div class="about">
<h4>Transformation details</h4>
<ul>
<li>Upload zip file</li>
<li>Unzip files</li>
<li>Merge metadata if the metadata are in external file and the target format is not Scorm</li>
<li>Use XSLT stylesheets to transform imsmanifest.xml file</li>
	<ul>
		<li>change metadata elements schema and schemaversion</li>
		<li>convert metadata IMS Metadata, version 1.2.4 to  instances of IEEE LOM, version 1.0 and vice versa</li>
		<li>merge submanifests in case of target package is IMS CC</li>
		<li>add/remove appropriate elements/attributes according schema (e.g. scormType) etc.</li>		
	</ul>
<li>Add in the package .xsd schemas according to package version</li>
<li>In case of conversion SCORM package to IMS we add  <a href="http://ostyn.com/standards/scorm/samples/singleSCOminiRTEwrap.htm">Single SCO Mini-Runtime</a>
	by Claude Ostyn. This wrapper emulates the SCORM runtime enviroment.</li>
<li>In case of conversion IMS package to SCORM we add to each html page initialization SCORM API calls and include APIWrapper.js which is available <a href="http://www.adlnet.gov/scorm/">http://www.adlnet.gov/scorm </a></li>
<li>In case of conversion SCOMR 1.2 package to SCORM 2004 we add <a href="http://www.ostyn.com/standards/demos/SCORM/wraps/easyscoadapterdoc.htm">Claude's Easy SCO Adapter for SCORM 1.2 to 2004</a>.</li>
<li>In case of IMS Common Cartridge as source package, we first check whether authorization is required. If yes we reject to transform the package. 
	Web link and forum application object are transformed to html pages.
</li>
<li>For missing references of files that are in the package but not declared in the manifest we add those.</li>
<li>Zip all files</li>
<li>Send email to user with link for download the converted package.</li>
</ul>
</div>



<div class="about">
<h4>Get involved</h4>
More information about the project and how to get involved is available <a href="http://www.jisc.ac.uk/whatwedo/projects/transcoder.aspx">http://www.jisc.ac.uk/whatwedo/projects/transcoder.aspx</a> and <a href="http://wiki.cetis.ac.uk/Get_Involved_with_Transcoder">http://wiki.cetis.ac.uk/Get_Involved_with_Transcoder</a>.
<a href="http://www.k-int.com">Knowledge Integration</a> provides software development and develop the design.
</div>

<div class="link"><a href="home">Upload package </a></div>

</div>

</body>