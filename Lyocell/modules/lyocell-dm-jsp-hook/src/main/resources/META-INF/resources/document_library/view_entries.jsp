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
<%-- <%@page import="com.liferay.dynamic.data.mapping.kernel.DDMStructure" %> --%>
<%@page import="com.liferay.dynamic.data.mapping.kernel.StorageEngineManagerUtil" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.Date" %>
 <%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.rge.lyocell.workspace.model.LyocellWorkspaceTree"%>
<%@page import="com.rge.lyocell.workspace.model.TreeState"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.liferay.portal.kernel.portlet.LiferayWindowState" %>
<%@page import="com.liferay.portal.kernel.portlet.LiferayPortletMode" %>
<%@page import="com.liferay.portal.kernel.service.LayoutLocalServiceUtil" %>
<%@page import="com.liferay.portal.kernel.model.Portlet" %>
<%
System.out.println("Tiger@@@@@@@@@@@@@@@@ Current URL is ::"+themeDisplay.getURLCurrent());
System.out.println("Tiger@@@@@@@@@@@@@@@@ currentURL  URL is ::"+currentURL);
%>
 <%!				
	public static String createJsonTree(List<LyocellWorkspaceTree> lodestarWorkspaceTreeList) {
		// create a map to form a tree view
		Map<Long, LyocellWorkspaceTree> kmDLFolderMap = new HashMap<>();

		// Push all LyocellWorkspaceTree objects to a map without any parent child
		// relation
		for (LyocellWorkspaceTree lodestarWorkspaceTreeObj : lodestarWorkspaceTreeList) {
			kmDLFolderMap.put(lodestarWorkspaceTreeObj.getId(), lodestarWorkspaceTreeObj);
		}
		// loop and assign parent/child relationships
		kmDLFolderMap.forEach((key, value) -> {
			Long parentId = value.getParentId();
			if (parentId != null) {
				LyocellWorkspaceTree parent = kmDLFolderMap.get(parentId);
				if (parent != null) {
					// current.setParent(parent);
					// set node false to remove operations
					value.setNode(false);
					parent.addChild(value);
					kmDLFolderMap.put(parentId, parent);
					kmDLFolderMap.put(value.getId(), value);
				}
			}
		});
		System.out.println("kmDLFolderMap:" + kmDLFolderMap.toString());
	 	// remove associated child to parent elements from map through iterator to avoid conncurent modification err.
		Iterator<Map.Entry<Long, LyocellWorkspaceTree>> kmDLFolderMapIterator = kmDLFolderMap.entrySet().iterator();
		 while (kmDLFolderMapIterator.hasNext()) {
			Map.Entry<Long, LyocellWorkspaceTree> kmDLFolderItem = kmDLFolderMapIterator.next();
			// look for false nodes which are child to other nodes and delete it.
			if (null != kmDLFolderItem.getValue().getNode() && !kmDLFolderItem.getValue().getNode()) {
				kmDLFolderMapIterator.remove();
			}
		} 
		// form a json from LyocellWorkspaceTree collection values
		String lodestarDLFolderJsonTree = new Gson().toJson(kmDLFolderMap.values());
		System.out.println("lodestarDLFolderJsonTree : " + lodestarDLFolderJsonTree);
		return lodestarDLFolderJsonTree;
	}
%>	

	

<%
String navigation = ParamUtil.getString(request, "navigation", "home");

String currentFolder = ParamUtil.getString(request, "curFolder");
String deltaFolder = ParamUtil.getString(request, "deltaFolder");
long folderId = GetterUtil.getLong((String)request.getAttribute("view.jsp-folderId"));

long repositoryId = GetterUtil.getLong((String)request.getAttribute("view.jsp-repositoryId"));

DLPortletInstanceSettingsHelper dlPortletInstanceSettingsHelper = new DLPortletInstanceSettingsHelper(dlRequestHelper);

String displayStyle = GetterUtil.getString((String)request.getAttribute("view.jsp-displayStyle"));
PortletURL portletURL = liferayPortletResponse.createRenderURL();

portletURL.setParameter("mvcRenderCommandName", (folderId == DLFolderConstants.DEFAULT_PARENT_FOLDER_ID) ? "/document_library/view" : "/document_library/view_folder");
portletURL.setParameter("navigation", navigation);
portletURL.setParameter("curFolder", currentFolder);
portletURL.setParameter("deltaFolder", deltaFolder);
portletURL.setParameter("folderId", String.valueOf(folderId));

EntriesChecker entriesChecker = new EntriesChecker(liferayPortletRequest, liferayPortletResponse);

entriesChecker.setCssClass("entry-selector");
entriesChecker.setRememberCheckBoxStateURLRegex("^(?!.*" + liferayPortletResponse.getNamespace() + "redirect).*(folderId=" + String.valueOf(folderId) + ")");

EntriesMover entriesMover = new EntriesMover(dlTrashUtil.isTrashEnabled(scopeGroupId, repositoryId));

String[] entryColumns = dlPortletInstanceSettingsHelper.getEntryColumns();



boolean portletTitleBasedNavigation = GetterUtil.getBoolean(portletConfig.getInitParameter("portlet-title-based-navigation"));

if (portletTitleBasedNavigation && (folderId != DLFolderConstants.DEFAULT_PARENT_FOLDER_ID) && (folderId != rootFolderId)) {
	String redirect = ParamUtil.getString(request, "redirect");

	if (Validator.isNotNull(redirect)) {
		portletDisplay.setShowBackIcon(true);
		portletDisplay.setURLBack(redirect);
	}

	Folder folder = DLAppServiceUtil.getFolder(folderId);

	renderResponse.setTitle(folder.getName());
}

    //naveen changes	
	String fid= request.getParameter("folderId");
	List<Long> folderIds;
	Long defaultViewFolderId = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
	folderIds = DLAppServiceUtil.getSubfolderIds(repositoryId, defaultViewFolderId, true);
	List<LyocellWorkspaceTree> lyocellWorkspaceTreeList = new ArrayList<LyocellWorkspaceTree>();
	 folderIds.forEach(kmFolderId -> {
		try {
			Folder kmFolder = DLAppServiceUtil.getFolder(kmFolderId);
			// construct a LyocellWorkspaceTree object based on retrieved folder values
			//System.out.println("Tiger@@@@@@@@@@@kmFolder.getName is:"+kmFolder.getName());
			//System.out.println("Tiger@@@@@@@@@@@kmFolder.getName().length() is:"+kmFolder.getName().length());
			String fname=kmFolder.getName();
			/* if(kmFolder.getName().length()>10){
				 fname=kmFolder.getName().substring(0,9).concat(".."); 
				System.out.println("Tiger@@@@@@@@@@@fname is:"+fname);
			}  */
			
			LyocellWorkspaceTree lyocellWorkspaceTree = new LyocellWorkspaceTree(/* kmFolder.getName() */fname,
					kmFolder.getFolderId(), false, "dir", false, true, kmFolder.getParentFolderId());
			TreeState state = new TreeState(false, false);
			if(fid!=null && kmFolder!=null ){
				if(fid.equals(Long.toString(kmFolder.getFolderId()))){
					state = new TreeState(true, true);
				}
			}
			lyocellWorkspaceTree.setState(state);
			// }
			// add object to list
			lyocellWorkspaceTreeList.add(lyocellWorkspaceTree);			
			
		} catch (PortalException e) {
			e.printStackTrace();
		}
	}); 
	 String jsonData=createJsonTree(lyocellWorkspaceTreeList);	 	
%>	

 <portlet:renderURL  var="viewFolderURL" >
	<!--  <portlet:param name="mvcRenderCommandName" value="/document_library/view_folder"/> -->
	 <portlet:param name="mvcRenderCommandName" value=" /document_library/view"/>	
	 <portlet:param name="redirect" value="<%=currentURL %>"/>
	<portlet:param name="displayStyle" value="<%=displayStyle%>"/> 
 </portlet:renderURL>
 
<div class="document-container" id="<portlet:namespace />entriesContainer">

	<%
	SearchContainer dlSearchContainer = dlAdminDisplayContext.getSearchContainer();	
	%>

<aui:row cssClass="search-layout">
  <aui:col id="docs" span="<%= 2 %>">
  <div class="JsonTree" style="overflow-y: scroll;"> 
  </div>
  </aui:col>
  <aui:col id="docs" span="<%= 10 %>">
    		
	<liferay-ui:search-container
		id="entries"
		searchContainer="<%= dlSearchContainer %>"
		total="<%= dlSearchContainer.getTotal() %>"
	>
		<liferay-ui:search-container-row
			className="Object"
			modelVar="result"
		>
			<%@ include file="/document_library/cast_result.jspf" %>			
			<c:choose>			
				<c:when test="<%= fileEntry != null %>">

					<%
					FileVersion latestFileVersion = fileEntry.getFileVersion();
					
					if ((user.getUserId() == fileEntry.getUserId()) || permissionChecker.isContentReviewer(user.getCompanyId(), scopeGroupId) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE)) {
						latestFileVersion = fileEntry.getLatestFileVersion();
					}

					DLViewFileVersionDisplayContext dlViewFileVersionDisplayContext = null;

					if (fileShortcut == null) {
						dlViewFileVersionDisplayContext = dlDisplayContextProvider.getDLViewFileVersionDisplayContext(request, response, fileEntry.getFileVersion());

						row.setPrimaryKey(String.valueOf(fileEntry.getFileEntryId()));
					}
					else {
						dlViewFileVersionDisplayContext = dlDisplayContextProvider.getDLViewFileVersionDisplayContext(request, response, fileShortcut);

						row.setPrimaryKey(String.valueOf(fileShortcut.getFileShortcutId()));
					}
					boolean draggable = false;

					if (!BrowserSnifferUtil.isMobile(request) && (DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.DELETE) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE))) {
						draggable = true;

						if (dlSearchContainer.getRowMover() == null) {
							dlSearchContainer.setRowMover(entriesMover);
						}
					}

					if (dlSearchContainer.getRowChecker() == null) {
						dlSearchContainer.setRowChecker(entriesChecker);
					}

					Map<String, Object> rowData = new HashMap<String, Object>();

					rowData.put("draggable", draggable);
					rowData.put("title", fileEntry.getTitle());

					row.setData(rowData);

					String thumbnailSrc = DLUtil.getThumbnailSrc(fileEntry, latestFileVersion, themeDisplay);
					%>

					<c:choose>
						<c:when test='<%= displayStyle.equals("descriptive") %>'>
							<c:choose>
								<c:when test="<%= fileShortcut != null %>">
									<liferay-ui:search-container-column-icon
										icon="shortcut"
										toggleRowChecker="<%= true %>"
									/>
								</c:when>
								<c:when test="<%= Validator.isNotNull(thumbnailSrc) %>">
									<liferay-ui:search-container-column-image
										src="<%= thumbnailSrc %>"
										toggleRowChecker="<%= true %>"
									/>
								</c:when>
								<c:when test="<%= Validator.isNotNull(latestFileVersion.getExtension()) %>">
									<liferay-ui:search-container-column-text>
										<div class="sticker sticker-secondary <%= dlViewFileVersionDisplayContext.getCssClassFileMimeType() %>">
											<%= StringUtil.shorten(StringUtil.upperCase(latestFileVersion.getExtension()), 3, StringPool.BLANK) %>
										</div>
									</liferay-ui:search-container-column-text>
								</c:when>
								<c:otherwise>
									<liferay-ui:search-container-column-icon
										icon="documents-and-media"
										toggleRowChecker="<%= true %>"
									/>
								</c:otherwise>
							</c:choose>

							<liferay-ui:search-container-column-jsp
								colspan="<%= 2 %>"
								path="/document_library/view_file_entry_descriptive.jsp"
							/>

							<liferay-ui:search-container-column-jsp
								path="/document_library/file_entry_action.jsp"
							/>
						</c:when>
						<c:when test='<%= displayStyle.equals("icon") %>'>
							<%
							row.setCssClass("entry-card lfr-asset-item");
							%>

							<liferay-ui:search-container-column-text>

								<%
								PortletURL rowURL = liferayPortletResponse.createRenderURL();

								rowURL.setParameter("mvcRenderCommandName", "/document_library/view_file_entry");
								rowURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));
								rowURL.setParameter("fileEntryId", String.valueOf(fileEntry.getFileEntryId()));
								// Custmization start for replacing the above url into WAB url
								String _downloadWABURL=DLUtil.getWebDavURL(themeDisplay, fileEntry.getFolder(), fileEntry); 
								System.out.println("icon _downloadWABURL: "+_downloadWABURL);								
								%>

								<c:choose>
									<c:when test="<%= Validator.isNull(thumbnailSrc) %>">
										<liferay-frontend:icon-vertical-card
											actionJsp="/document_library/file_entry_action.jsp"
											actionJspServletContext="<%= application %>"
											cssClass="entry-display-style doc-new-tab"
											icon="documents-and-media"
											resultRow="<%= row %>"
											rowChecker="<%= entriesChecker %>"
											title="<%= latestFileVersion.getTitle() %>"
											url="<%= (_downloadWABURL != null) ? _downloadWABURL : null %>"
										>
										
											<%@ include file="/document_library/file_entry_vertical_card.jspf" %>
										</liferay-frontend:icon-vertical-card>
									</c:when>
									<c:otherwise>
										<liferay-frontend:vertical-card
											actionJsp="/document_library/file_entry_action.jsp"
											actionJspServletContext="<%= application %>"
											cssClass="entry-display-style doc-new-tab"
											imageUrl="<%= thumbnailSrc %>"
											resultRow="<%= row %>"
											rowChecker="<%= entriesChecker %>"
											title="<%= latestFileVersion.getTitle() %>"
											url="<%= (_downloadWABURL != null) ? _downloadWABURL : null %>"
										>
										
											<%@ include file="/document_library/file_entry_vertical_card.jspf" %>
										</liferay-frontend:vertical-card>
									</c:otherwise>
									
								</c:choose>
							</liferay-ui:search-container-column-text>										
						</c:when>
						<c:otherwise>						
						<div class="container">     					
							<c:if test='<%= ArrayUtil.contains(entryColumns, "name") %>'>
								
								<%								
								PortletURL rowURL = liferayPortletResponse.createRenderURL();
								rowURL.setParameter("mvcRenderCommandName", "/document_library/view_file_entry");
								rowURL.setParameter("redirect", HttpUtil.removeParameter(currentURL, liferayPortletResponse.getNamespace() + "ajax"));
								rowURL.setParameter("fileEntryId", String.valueOf(fileEntry.getFileEntryId()));
								String _downloadWABURL=DLUtil.getWebDavURL(themeDisplay, fileEntry.getFolder(), fileEntry); 
								//System.out.println("name _downloadWABURL: "+_downloadWABURL);
								
								%>

								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand table-cell-minw-200 table-title doc-new-tab"
									name="Name"
								>
									<aui:a href="<%= _downloadWABURL %>"><%= latestFileVersion.getTitle() %></aui:a>

									<c:if test="<%= fileEntry.hasLock() || fileEntry.isCheckedOut() %>">
										<aui:icon cssClass="inline-item inline-item-after" image="lock" markupView="lexicon" message="locked" />
									</c:if>

									<c:if test="<%= fileShortcut != null %>">
										<aui:icon cssClass="inline-item inline-item-after" image="shortcut" markupView="lexicon" message="shortcut" />
									</c:if>
								</liferay-ui:search-container-column-text>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "description") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand table-cell-minw-200"
									name="description"
									value="<%= StringUtil.shorten(fileEntry.getDescription(), 100) %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "document-type") %>'>
								<c:choose>
									<c:when test="<%= latestFileVersion.getModel() instanceof DLFileVersion %>">

										<%
										DLFileVersion latestDLFileVersion = (DLFileVersion)latestFileVersion.getModel();
										DLFileEntryType dlFileEntryType = latestDLFileVersion.getDLFileEntryType();
										//Custom code for showing Document NO
										String documentNum="";
										String subject="";
										String dateReceipt="";
										String fileModify="";
										String revision="";
										
										List<DDMStructure> ddmStructures=dlFileEntryType.getDDMStructures();
										if(ddmStructures!=null &&ddmStructures.size()>0){
										for(DDMStructure ddmStructure: ddmStructures){
											if(ddmStructure!=null){
											DLFileEntryMetadata fileEntryMetadata=DLFileEntryMetadataLocalServiceUtil.getFileEntryMetadata(ddmStructure.getStructureId(), latestDLFileVersion.getFileVersionId());
											if(fileEntryMetadata!=null){
												com.liferay.dynamic.data.mapping.kernel.DDMFormValues vals = StorageEngineManagerUtil.getDDMFormValues(fileEntryMetadata.getDDMStorageId());
												if(vals!=null){
												List<com.liferay.dynamic.data.mapping.kernel.DDMFormFieldValue> fieldValueList = vals.getDDMFormFieldValues();
													if(fieldValueList !=null && fieldValueList.size()>0){
														for(com.liferay.dynamic.data.mapping.kernel.DDMFormFieldValue ddmFormField: fieldValueList){
															if(ddmFormField!=null){
																if(ddmFormField.getName().equalsIgnoreCase("DocumentNo")){
																	documentNum=ddmFormField.getValue().getString(locale);	
																}
																if(ddmFormField.getName().equalsIgnoreCase("Subject")){
																	subject=ddmFormField.getValue().getString(locale);	
																}
																if(ddmFormField.getName().equalsIgnoreCase("DateReceipt")){																	
																	SimpleDateFormat simpleDateParse = new SimpleDateFormat("yyyy-MM-dd");																	
																	SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd MMM yyyy");
																	dateReceipt=simpleDateFormat.format(simpleDateParse.parse(ddmFormField.getValue().getString(locale)));								
																} 
																if(ddmFormField.getName().equalsIgnoreCase("FileModified")){																		
																	SimpleDateFormat simpleDateParse = new SimpleDateFormat("yyyy-MM-dd");
																	SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd MMM yyyy");
																	fileModify=simpleDateFormat.format(simpleDateParse.parse(ddmFormField.getValue().getString(locale)));																	
																} 
																if(ddmFormField.getName().equalsIgnoreCase("Revision")){
																	revision=ddmFormField.getValue().getString(locale).replaceAll("[\\[\\]\"]", "");
																}
															}
														}
													}
												}
											}
										}
										}
										}	
										
										
										%>
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Document Number"
											value="<%=documentNum!=""? HtmlUtil.escape(documentNum) :"--"%>"
										/>

										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand table-cell-minw-200"
											name="Subject"
											value="<%=subject!=""? HtmlUtil.escape(subject) :"--"%>" />										
										
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="document-type"
											value="<%= HtmlUtil.escape(dlFileEntryType.getName(locale)) %>"
										/>
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Date Receipt"
											value="<%=dateReceipt!=""? HtmlUtil.escape(dateReceipt) :"--"%>"
										/>
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Date Modified"
											value="<%=fileModify!=""? HtmlUtil.escape(fileModify) :"--"%>"
										/>
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Revision"
											value="<%=revision!=""? HtmlUtil.escape(revision) :"--"%>"
										/>
									</c:when>
									<c:otherwise>
									<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Document Number"
											value="--"
										/>
										
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand table-cell-minw-200"
											name="Subject"
											value="--" />									
										
										
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="document-type"
											value="--"
										/>
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Date Receipt"
											value="--"
										/>
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Date Modified"
											value="--"
										/>
										<liferay-ui:search-container-column-text
											cssClass="table-cell-expand-smaller table-cell-minw-150"
											name="Revision"
											value="--"
										/>
									</c:otherwise>
								</c:choose>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "size") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest"
									name="size"
									value="<%= TextFormatter.formatStorageSize(latestFileVersion.getSize(), locale) %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "status") %>'>
								<liferay-ui:search-container-column-status
									cssClass="table-cell-expand-smallest"
									name="status"
									status="<%= latestFileVersion.getStatus() %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "downloads") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest"
									name="downloads"
									value="<%= String.valueOf(fileEntry.getReadCount()) %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "create-date") %>'>							
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest table-cell-ws-nowrap"
									name="create-date"
									value="<%= new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(fileEntry.getCreateDate()) %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "modified-date") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest table-cell-ws-nowrap"
									name="modified-date"
									value="<%= new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(latestFileVersion.getModifiedDate())  %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "action") %>'>
								<liferay-ui:search-container-column-jsp
									path="/document_library/file_entry_action.jsp"
								/>
							</c:if>
						</c:otherwise>
					</c:choose>
				</c:when>
				<c:otherwise>				
					<%					
					if (dlSearchContainer.getRowChecker() == null) {
						dlSearchContainer.setRowChecker(entriesChecker);
					}

					Map<String, Object> rowData = new HashMap<String, Object>();

					boolean draggable = false;

					if (!BrowserSnifferUtil.isMobile(request) && (DLFolderPermission.contains(permissionChecker, curFolder, ActionKeys.DELETE) || DLFolderPermission.contains(permissionChecker, curFolder, ActionKeys.UPDATE))) {
						draggable = true;

						if (dlSearchContainer.getRowMover() == null) {
							dlSearchContainer.setRowMover(entriesMover);
						}
					}

					rowData.put("draggable", draggable);

					rowData.put("folder", true);
					rowData.put("folder-id", curFolder.getFolderId());
					rowData.put("title", curFolder.getName());

					row.setData(rowData);

					row.setPrimaryKey(String.valueOf(curFolder.getPrimaryKey()));
					%>

					<c:choose>
						<c:when test='<%= displayStyle.equals("descriptive") %>'>
							<liferay-ui:search-container-column-icon
								icon='<%= curFolder.isMountPoint() ? "repository" : "folder" %>'
								toggleRowChecker="<%= true %>"
							/>

							<liferay-ui:search-container-column-jsp
								colspan="<%= 2 %>"
								path="/document_library/view_folder_descriptive.jsp"
							/>

							<liferay-ui:search-container-column-jsp
								path="/document_library/folder_action.jsp"
							/>
						</c:when>
						<c:when test='<%= displayStyle.equals("icon") %>'>
							<%
							row.setCssClass("entry-card lfr-asset-folder");

							PortletURL rowURL = liferayPortletResponse.createRenderURL();

							rowURL.setParameter("mvcRenderCommandName", "/document_library/view_folder");
							rowURL.setParameter("redirect", currentURL);
							rowURL.setParameter("folderId", String.valueOf(curFolder.getFolderId()));
							%>							
							<liferay-ui:search-container-column-text
								colspan="<%= 2 %>"
							>
								<liferay-frontend:horizontal-card
									actionJsp="/document_library/folder_action.jsp"
									actionJspServletContext="<%= application %>"
									resultRow="<%= row %>"
									rowChecker="<%= entriesChecker %>"
									text="<%= curFolder.getName() %>"
									url="<%= rowURL.toString() %>"
								>
									<liferay-frontend:horizontal-card-col>
										<liferay-frontend:horizontal-card-icon
											icon='<%= curFolder.isMountPoint() ? "repository" : "folder" %>'
										/>
									</liferay-frontend:horizontal-card-col>
								</liferay-frontend:horizontal-card>
							</liferay-ui:search-container-column-text>	
							
						</c:when>
						<c:otherwise>
							<c:if test='<%= ArrayUtil.contains(entryColumns, "name") %>'>

								<%
								System.out.println("Tiger@@@@@@@@@@@@@ IN otherwise II");
								PortletURL rowURL = liferayPortletResponse.createRenderURL();

								rowURL.setParameter("mvcRenderCommandName", "/document_library/view_folder");
								rowURL.setParameter("redirect", currentURL);
								rowURL.setParameter("folderId", String.valueOf(curFolder.getFolderId()));
								//System.out.println("name folder ");
								%>

								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand table-cell-minw-200 table-title"
									href="<%= rowURL %>"
									name="Name"
									value="<%= curFolder.getName() %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "description") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand table-cell-minw-200"
									name="description"
									value="<%= StringUtil.shorten(curFolder.getDescription(), 100) %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "document-type") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smaller"
									name="Document Number"
									value="--"
								/>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand table-cell-minw-200"
									name="Subject"
									value="--"
								/>								
								
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smaller"
									name="document-type"
									value="--"
								/>								
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smaller"
									name="Date Receipt"
									value="--"
								/>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smaller"
									name="Date Modified"
									value="--"
								/>	
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smaller"
									name="Revision"
									value="--"
								/>								
								
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "size") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest"
									name="size"
									value="--"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "status") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest"
									name="status"
									value="--"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "downloads") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest"
									name="downloads"
									value="--"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "create-date") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest table-cell-ws-nowrap"
									name="create-date"
									value="<%= new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(curFolder.getCreateDate()) %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "modified-date") %>'>
								<liferay-ui:search-container-column-text
									cssClass="table-cell-expand-smallest table-cell-ws-nowrap"
									name="modified-date"
									value="<%= new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(curFolder.getLastPostDate()) %>"
								/>
							</c:if>

							<c:if test='<%= ArrayUtil.contains(entryColumns, "action") %>'>
								<liferay-ui:search-container-column-jsp
									path="/document_library/folder_action.jsp"
								/>
							</c:if>
						</c:otherwise>
					</c:choose>					
				</c:otherwise>				
			</c:choose>		
		</liferay-ui:search-container-row>

		<liferay-ui:search-iterator
			displayStyle="<%= displayStyle %>"
			markupView="lexicon"
			resultRowSplitter="<%= new DLResultRowSplitter() %>"
			searchContainer="<%= dlSearchContainer %>"
		/>
	</liferay-ui:search-container>
  </aui:col>  					
</aui:row>
</div>

<%
request.setAttribute("edit_file_entry.jsp-checkedOut", true);
%>

<liferay-util:include page="/document_library/version_details.jsp" servletContext="<%= application %>" />

<%!
%>

 <!-- <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">    -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.8/themes/default/style.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.8/jstree.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>



<script type="text/javascript">
$(document).ready(function(){
	  $("div.doc-new-tab .lfr-card-title-text a,td.doc-new-tab a, h4.doc-new-tab a").each(function(){
		$(this).attr("target","_blank");
		//var _hrefCust=/* "ms-excel:ofe|u|"+ */$(this).attr("href");
		//$(this).attr("href",_hrefCust);
		//<a href="ms-word:ofe|u|">Open Document in Word</a>
	});  
	
	var jsonData = <%=jsonData%>;
	
	$(document).ready(function() {
		   var wsFolderID ='';
		//tree view generation		
		$('.JsonTree').jstree({
			'core' : {
				'data' : jsonData				
			}
		});
		
	});

});

$('.JsonTree').bind('select_node.jstree', function(e,data) {
	 var viewFolderURL = "${viewFolderURL}&<portlet:namespace/>folderId="+data.node.id;		
     window.location.href = viewFolderURL;    
});

// on click of tree nodes ajax fired to load the content of the folders.
 $('.JsonTree').on("changed.jstree", function(e, data) {
}); 

$('.JsonTree').bind('loaded.jstree', function(e, data){	
	
}); 

</script>