<%@ include file="/init.jsp"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>
<portlet:defineObjects />
<portlet:actionURL var="uplaodURL" name="actionFolderUpload">
<portlet:param name ="mvcActionCommandName" value="actionFolderUpload"/>
</portlet:actionURL>
<b>Please Upload a Folder</b>
<br>
<%
String backURL=ParamUtil.getString(request,"backURL");
portletDisplay.setShowBackIcon(true);
portletDisplay.setURLBack(backURL);
%>
<head><base href="/"></head>
<form method="post" action="<%=uplaodURL%>"
	enctype="multipart/form-data">
	<input type="file" name="file" id="filepicker" name="uploadedFile"
		webkitdirectory mozdirectory
		msdirectory odirectory directory multiple> <br /> <br /> <input
		type="submit" value="Upload" />
		<input type="hidden" name="<portlet:namespace/>backURL"  value="<%=backURL %>"/>
</form>