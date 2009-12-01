<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Collection, com.k_int.transcoder.transform.PackageVersion"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
 
<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/style.css" />
  
<s:head/> 

<body>
<div class="main">

<h2>Transcoder Feedback form</h2>

<hr/>
<div class="form">
<form action="feedback" method="POST">
<input type="hidden" name="uploadId" value="<%= request.getParameter("upload_id")%>">

<table class="form">
<tr><td colspan="2" class="question">1. Was conversion suceessful?</td></tr>
<tr><td colspan="2"><input type="radio" name="success" value="yes"> Yes </td></tr>
<tr><td colspan="2"><input type="radio" name="success" value="partially"> Partially </td></tr>
<tr><td colspan="2"><input type="radio" name="success" value="no"> Not at all </td></tr>

<tr><td colspan="2"  class="question">2. Specify please LMS used (e.g. Moodle, Blackboard)</td></tr>
<tr><td width="100px">Name</td><td> <input type="textfield" name="lmsName" size="30"> </td></tr>
<tr><td width="100px">Version</td><td><input type="textfield" name="lmsVersion" size="10"> </td></tr>

<tr><td colspan="2" class="question">3. Note any problems or suggestions</td></tr>
<tr><td colspan="2"><textarea name="errors" rows="6" cols="70"></textarea></td></tr>
 
<tr><td colspan="2" class="question"><input type="submit" value="Send"></td></tr>

</table>
</form>
</div>
</div>
</body>