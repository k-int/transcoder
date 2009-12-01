<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Collection, com.k_int.transcoder.transform.PackageVersion"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
 
<link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/style.css" />
  
<s:head/> 

<body>
<div class="main">

<h2>Transcoder acknowledgement</h2>

<hr/>


	<h3>Thank you for your cooperation!</h3>
	

<% 
int packages = Integer.valueOf(request.getParameter("packages"));
int people = Integer.valueOf(request.getParameter("people"));
int feedback = Integer.valueOf(request.getParameter("feedback"));
String uploadId = request.getParameter("uploadId");
String peopleStr = people == 1 ? " 1 person " : (" " + people + " people ");
String packagesStr = packages == 1 ? " 1 package " : (" " + packages + " packages ");
String feedbackStr = feedback == 1 ? " 1 feedback form" : (" " + feedback + " feedback forms");

%>

<div class="acknowledgement">
By now <%= peopleStr  %> have sent <%= packagesStr %> and we have received <%= feedbackStr %>.    
</div>  


<% if (uploadId!=null) { %>
<div class="download">
<ul class="download_list">        
	<li>
		Download the <a href="<s:url action="download" includeParams="none"/>?upload_id=<%= uploadId %>">converted package</a>.
	</li>
	<li>
		Download the <a href="<s:url action="download" includeParams="none"/>?what=log&upload_id=<%= uploadId %>">log file</a> with details of the conversion. 
	</li>
	<li>
		Please fill in <a href="<s:url action="form" includeParams="none"/>?upload_id=<%= uploadId %>">feedback form</a> where you can specify any problems or suggestions.
	</li>
</ul>	
</div>
<% } %>



<div class="link"><a href="<s:url action="home" includeParams="none"/>">Upload new package </a></div>
</div>
</body>