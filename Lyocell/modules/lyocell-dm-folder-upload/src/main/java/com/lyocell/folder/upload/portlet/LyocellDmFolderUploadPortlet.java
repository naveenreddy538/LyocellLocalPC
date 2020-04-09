package com.lyocell.folder.upload.portlet;
import com.liferay.document.library.kernel.model.DLFolderConstants;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.util.ParamUtil;
import com.lyocell.folder.upload.constants.LyocellDmFolderUploadPortletKeys;

import java.io.IOException;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

/**
 * @author naveen_vanakuru
 */
@Component(
	immediate = true,
	property = {
		"com.liferay.portlet.display-category=category.sample",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=true",
		"javax.portlet.display-name=LyocellDmFolderUpload",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/view.jsp",
		"javax.portlet.name=" + LyocellDmFolderUploadPortletKeys.LYOCELLDMFOLDERUPLOAD,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class LyocellDmFolderUploadPortlet   extends MVCPortlet {
	private static String ROOT_FOLDER_NAME;
	private static String ROOT_FOLDER_DESCRIPTION = LyocellDmFolderUploadPortletKeys.FILEUPLOADFOLDERDESC;
	private static long PARENT_FOLDER_ID = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
	@Override
	public void doView(RenderRequest renderRequest, RenderResponse renderResponse) throws IOException, PortletException {
		_log.info("LyocellDmFolderUploadPortlet");
		String backURL=(String)	ParamUtil.getString(renderRequest, "backURL");
		_log.info("LyocellDmFolderUploadPortlet" +backURL);
		super.doView(renderRequest, renderResponse);
	}
	
	private static final Log _log=LogFactoryUtil.getLog(LyocellDmFolderUploadPortlet.class);
	
	/*
	 * public void uploadDocument(ActionRequest actionRequest, ActionResponse
	 * actionResponse) throws IOException, PortletException, PortalException,
	 * SystemException { ThemeDisplay themeDisplay = (ThemeDisplay)
	 * actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
	 * 
	 * for (Part part : actionRequest.getParts()) { String fileName =
	 * extractFileName(part); PARENT_FOLDER_ID =
	 * DLFolderConstants.DEFAULT_PARENT_FOLDER_ID; File file = new File(fileName);
	 * String strNew = fileName.replace("/" + file.getName(), ""); String[]
	 * folderNames = strNew.trim().split("/");
	 * 
	 * for (String folderName : folderNames) { ROOT_FOLDER_NAME = folderName;
	 * boolean folderExist = isFolderExist(themeDisplay); if (!folderExist) {
	 * createFolder(actionRequest, themeDisplay); } } InputStream is =
	 * part.getInputStream(); fileUpload(themeDisplay, actionRequest, is, part);
	 * PARENT_FOLDER_ID = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
	 * 
	 * } actionRequest.setAttribute("message",
	 * "Upload has been done successfully!"); }
	 * 
	 * public static void fileUpload(ThemeDisplay themeDisplay, ActionRequest
	 * actionRequest, InputStream is, Part part) { String title, description,
	 * mimeType; long repositoryId; String fileName = extractFileName(part); File
	 * file = new File(fileName); title = file.getName(); description = title;
	 * repositoryId = themeDisplay.getScopeGroupId(); mimeType =
	 * MimeTypesUtil.getContentType(file.getAbsoluteFile()); try { ServiceContext
	 * serviceContext =
	 * ServiceContextFactory.getInstance(DLFileEntry.class.getName(),
	 * actionRequest); List<FileEntry> files=
	 * DLAppServiceUtil.getFileEntries(repositoryId, PARENT_FOLDER_ID); boolean
	 * isFileExist=false; for(FileEntry fileEntry :files) {
	 * if(file.getName().equals(fileEntry.getFileName())) { isFileExist=true; break;
	 * }
	 * 
	 * } System.out.println("File:: "+file.getName()+ " is already Exist.");
	 * if(!isFileExist) { DLAppServiceUtil.addFileEntry(repositoryId,
	 * PARENT_FOLDER_ID, title, mimeType, title, description, "", is,
	 * part.getSize(), serviceContext); } } catch (PortalException e) {
	 * e.printStackTrace(); } catch (SystemException e) { e.printStackTrace(); }
	 * 
	 * }
	 * 
	 * public static Folder createFolder(ActionRequest actionRequest, ThemeDisplay
	 * themeDisplay) { Folder folder = null; long repositoryId =
	 * themeDisplay.getScopeGroupId(); try { ServiceContext serviceContext =
	 * ServiceContextFactory.getInstance(DLFolder.class.getName(), actionRequest);
	 * folder = DLAppServiceUtil.addFolder(repositoryId, PARENT_FOLDER_ID,
	 * ROOT_FOLDER_NAME, ROOT_FOLDER_DESCRIPTION, serviceContext); PARENT_FOLDER_ID
	 * = folder.getFolderId(); } catch (PortalException e1) { e1.printStackTrace();
	 * } catch (SystemException e1) { e1.printStackTrace(); } return folder; }
	 * 
	 * private static String extractFileName(Part part) { String contentDisp =
	 * part.getHeader("content-disposition"); String[] items =
	 * contentDisp.split(";"); for (String s : items) { if
	 * (s.trim().startsWith("filename")) { return s.substring(s.indexOf("=") + 2,
	 * s.length() - 1); } } return ""; }
	 * 
	 * public static boolean isFolderExist(ThemeDisplay themeDisplay) { boolean
	 * folderExist = false; try { Folder folder =
	 * DLAppServiceUtil.getFolder(themeDisplay.getScopeGroupId(), PARENT_FOLDER_ID,
	 * ROOT_FOLDER_NAME); folderExist = true; PARENT_FOLDER_ID =
	 * folder.getFolderId();
	 * System.out.println("Folder:: "+ROOT_FOLDER_NAME+" is already Exist."); }
	 * catch (Exception e) { System.out.println(e.getMessage()); } return
	 * folderExist; }
	 */
}