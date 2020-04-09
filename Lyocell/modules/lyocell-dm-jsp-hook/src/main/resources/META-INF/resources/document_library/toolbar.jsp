<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/document_library/init.jsp" %>
<%@ taglib prefix="liferay-portlet" uri="http://liferay.com/tld/portlet" %>
<%@page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.DropdownItem" %>
<%@page import="com.liferay.portal.kernel.servlet.taglib.ui.Menu" %>
<%@page import="com.liferay.document.library.portlet.toolbar.contributor.DLPortletToolbarContributor" %>
<%@page import="com.liferay.portal.kernel.servlet.taglib.ui.MenuItem" %>
<%@page import="com.liferay.portal.kernel.servlet.taglib.ui.URLMenuItem" %>
<%@page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.ViewTypeItemList"%> 
<%@page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.ViewTypeItem"%>
<%@page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.CreationMenu"%>
<%@page import="com.liferay.portal.kernel.util.UnsafeConsumer" %>
<%@page import="com.liferay.frontend.taglib.clay.servlet.taglib.util.JSPCreationMenu" %>

<%@page import="com.liferay.portal.kernel.portlet.LiferayWindowState" %>
<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletMode" %>
<%@page import="com.liferay.portal.kernel.service.LayoutLocalServiceUtil" %>
<%@page import="com.liferay.portal.kernel.model.Portlet" %>
<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletURL"%>

<%-- <liferay-portlet:renderURL var="openFolderUploadURL" copyCurrentRenderParameters="true" plid="<%= LayoutLocalServiceUtil.getFriendlyURLLayout(themeDisplay.getScopeGroupId(), false, "/upload-folder").getPlid()%>"  portletName="com_lyocell_folder_upload_LyocellDmFolderUploadPortlet_INSTANCE_qsicsncrs14j" portletMode="<%=LiferayPortletMode.VIEW.toString() %>" 
  windowState="<%=LiferayWindowState.MAXIMIZED.toString()%>">
  <liferay-portlet:param  name="folderId" value="" />
  <liferay-portlet:param  name="backURL" value="<%= currentURL%>" />
</liferay-portlet:renderURL> --%>

<%
	DLAdminManagementToolbarDisplayContext dlAdminManagementToolbarDisplayContext = new DLAdminManagementToolbarDisplayContext(liferayPortletRequest, liferayPortletResponse, request, dlAdminDisplayContext);

		 List<DropdownItem> dropDownItems=dlAdminManagementToolbarDisplayContext.getActionDropdownItems();
		 //ViewTypeItemList  viewTypes=dlAdminManagementToolbarDisplayContext.getViewTypes();	
	
		PortletURL toolCopyURL = liferayPortletResponse.createRenderURL();
		toolCopyURL.setParameter("mvcRenderCommandName", "/document_library/move_entry");
		toolCopyURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));
	//	toolCopyURL.setParameter("rowIdsFolder", String.valueOf(folderId));
		//toolCopyURL.setParameter("repositoryId", String.valueOf(repositoryId));
		
		toolCopyURL.setParameter("fromCopyURL", "true");		
		if(dropDownItems!=null)	{
		 DropdownItem dropdownItem = new DropdownItem();
		 dropdownItem.setHref(toolCopyURL.toString());
		// dropdownItem.putData("action", "copy");
         dropdownItem.setIcon("copy");
         dropdownItem.setLabel("Copy");
         dropdownItem.setQuickAction(true);
		 dropDownItems.add(dropdownItem);
		} 
		 LiferayPortletURL renderUrl =  PortletURLFactoryUtil.create(request, LayoutLocalServiceUtil.getFriendlyURLLayout(themeDisplay.getScopeGroupId(), false, "/upload-folder").getTypeSettingsProperty("column-1").trim() , LayoutLocalServiceUtil.getFriendlyURLLayout(themeDisplay.getScopeGroupId(), false, "/upload-folder").getPlid(), PortletRequest.RENDER_PHASE);
		 renderUrl.setWindowState(LiferayWindowState.MAXIMIZED);
		 renderUrl.setPortletMode(LiferayPortletMode.VIEW);
		 //renderUrl.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));
		 renderUrl.setParameter("backURL", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));
		
		 CreationMenu creationMenu=dlAdminManagementToolbarDisplayContext.getCreationMenu();
		 if(creationMenu!=null)	{
		  creationMenu.addPrimaryDropdownItem(
					dropdownItem1 -> {
  						dropdownItem1.setHref(renderUrl.toString());
  						dropdownItem1.setIcon("Upload");
  						dropdownItem1.setLabel("Folder Upload");
  						dropdownItem1.setQuickAction(true);
  					});	
		 }
%>


<clay:management-toolbar
	actionDropdownItems="<%= dropDownItems %>"	
	clearResultsURL="<%= dlAdminManagementToolbarDisplayContext.getClearResultsURL() %>"	
	defaultEventHandler='<%= renderResponse.getNamespace() + "DocumentLibrary" %>'
	disabled="<%= dlAdminManagementToolbarDisplayContext.isDisabled() %>"
	filterDropdownItems="<%= dlAdminManagementToolbarDisplayContext.getFilterDropdownItems() %>" 
	infoPanelId="infoPanelId"
	itemsTotal="<%= dlAdminManagementToolbarDisplayContext.getTotalItems() %>"
	searchActionURL="<%= String.valueOf(dlAdminManagementToolbarDisplayContext.getSearchURL()) %>"
	searchContainerId="entries"
	selectable="<%= dlAdminManagementToolbarDisplayContext.isSelectable() %>"
	showInfoButton="<%= true %>"
	showSearch="<%= dlAdminManagementToolbarDisplayContext.isShowSearch() %>"
	sortingOrder="<%= dlAdminManagementToolbarDisplayContext.getSortingOrder() %>"
	sortingURL="<%= String.valueOf(dlAdminManagementToolbarDisplayContext.getSortingURL()) %>"
	viewTypeItems="<%= dlAdminManagementToolbarDisplayContext.getViewTypes() %>"	
	creationMenu="<%= creationMenu%>"
/>
<script type="text/javascript">

	$(document).ready( function () { 
	//alert(0);
	var selectedFolders = new Array();
	var selectedFileEntries= new Array();
	$("input.entry-selector, .custom-control-input").click(function (){
		 setTimeout(copyFilesAndFoldersURL,500);
		//calBackfun();
			 
	});
function copyFilesAndFoldersURL(){
	console.log("function calBackfun::")
	//Folders Selection loop  
		$('input:checkbox[name=<portlet:namespace />rowIdsFolder]').each(function() 
			    {
			if($(this).parent().parent().hasClass("active") || 
		    		  $(this).parent().parent().parent().hasClass("active") || 
		    		  $(this).parent().parent().parent().parent().hasClass("active")){
						if(selectedFolders.indexOf($(this).val())==-1){
					    	  selectedFolders.push($(this).val());  
					      }
					}else{
						var index = selectedFolders.indexOf($(this).val());
						if (index > -1) {
							selectedFolders.splice(index, 1);
						}
					}
			    });
		//File Entries selection loop
		$('input:checkbox[name=<portlet:namespace />rowIdsFileEntry]').each(function() 
			    {
			      if($(this).parent().parent().hasClass("active") || 
			    		  $(this).parent().parent().parent().hasClass("active") || 
			    		  $(this).parent().parent().parent().parent().hasClass("active")){
			    	  
						if(selectedFileEntries.indexOf($(this).val())==-1){
							selectedFileEntries.push($(this).val());  
					      }
					}else{
						var index = selectedFileEntries.indexOf($(this).val());
						if (index > -1) {
							//alert("unselect");
							selectedFileEntries.splice(index, 1);
						}
					}
			    });
		var _url='<%=toolCopyURL.toString()%>';
		var folderUrl="";
		var fileEntryUrl="";
		 
		 if (typeof selectedFolders != "undefined" && selectedFolders != null && selectedFolders.length != null && selectedFolders.length > 0) {
			 folderUrl="&<portlet:namespace />rowIdsFolder="+selectedFolders;
		 }
		 if (typeof selectedFileEntries != "undefined" && selectedFileEntries != null && selectedFileEntries.length != null && selectedFileEntries.length > 0) {
			fileEntryUrl="&<portlet:namespace />rowIdsFileEntry="+selectedFileEntries;
		 } 
		 
		 //Adding URL's to anchor tags
		 
		if(folderUrl !="" || fileEntryUrl !=""){
			$("a.nav-link-monospaced").addClass("icon-copy");
			$("a.nav-link-monospaced").attr("href",_url+folderUrl+fileEntryUrl);
			$(document).find("ul.list-unstyled a.dropdown-item").attr("href",_url+folderUrl+fileEntryUrl);
		}	 
		
}	
	 
});

	$(document).ready( function () {
		var nav = $("<nav></nav>");
        var ul = $("<ul></ul>").attr("id", "menu");
	});
</script>