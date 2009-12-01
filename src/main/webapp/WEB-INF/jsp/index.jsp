<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Collection, com.k_int.transcoder.transform.PackageVersion"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
 
<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/style.css" />
  
<s:head/> 

<body>
<div class="main">


<h2>Transcoder</h2>

<hr/>
<div class="description">
<s:text name="transcoder.web.description"/>
<div>
For more information look at <a href="about">Transcoder about page</a>. 
</div>
<br>
<div>
At the moment is available conversion between SCORM 1.2 (only as a source), SCORM 2004, IMS 1.1 and IMS Common Cartridge 1.0.
Service is under development and testing now, so it is not meant to be 100% working. Final version
will be available in spring 2009.
</div>
</div>
<hr/>

<div class="info"> 
	<s:fielderror/>
	<s:actionerror/>
	<s:actionmessage/>
</div>


<form action="upload" method="POST" enctype="multipart/form-data">

<div class="step">
	<h4><s:text name="transcoder.web.step1"/></h4>
	<div><s:text name="transcoder.web.field.file"/></div>
	<input type="file" name="upload" value="Browse ..." />
</div>

<div class="step">
	<h4><s:text name="transcoder.web.step2"/></h4>
    <div><s:text name="transcoder.web.field.format"/></div>
    <select name="targetFormat">
        <option value="<%= PackageVersion.IMS_CC_1_0_0 %>" >IMS Common Cartridge 1.0</option>
    	<option value="<%= PackageVersion.SCORM_2004 %>">SCORM 2004</option>
        <option value="<%= PackageVersion.IMS_CP_1_1_4 %>">IMS CP 1.1.4</option>
       <option value="upload">Only upload</option>
    	
    </select>
</div>

 
<div class="step">
	<h4><s:text name="transcoder.web.step3"/></h4>
	<div><s:text name="transcoder.web.field.email"/></div>
	<input type="textfield" name="mail" size="30"/>
</div>


<div class="step">
	<h4><s:text name="transcoder.web.step4"/></h4>
	<div><s:text name="transcoder.web.field.convert"/></div>
	<input type="submit" value="Convert" />
</div>

</form>
</div>
</body>