<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<%@taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<liferay-theme:defineObjects />
<portlet:defineObjects />
<portlet:actionURL var="uplaodURL" name="actionFolderUpload">
<portlet:param name ="mvcActionCommandName" value="actionFolderUpload"/>
</portlet:actionURL>

<portlet:actionURL name="/document_library/folder_upload" var="folderUploadURL">
		<portlet:param name="mvcRenderCommandName" value="/document_library/folder_upload" />
</portlet:actionURL>
	
<b>Please Upload a Folder</b>
<br>
<form method="post" action="<%=uplaodURL%>"
	enctype="multipart/form-data">
	<input type="file" name="file" id="filepicker" name="uploadedFile"
		onchange="selectFolder(event);" webkitdirectory mozdirectory
		msdirectory odirectory directory multiple> <br /> <br /> <input
		type="submit" value="Upload" />
</form>