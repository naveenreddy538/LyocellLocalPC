package com.lyocell.folder.upload.portlet;

import com.liferay.document.library.kernel.model.DLFileEntry;
import com.liferay.document.library.kernel.model.DLFolder;
import com.liferay.document.library.kernel.model.DLFolderConstants;
import com.liferay.document.library.kernel.service.DLAppServiceUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.repository.model.Folder;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.MimeTypesUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.lyocell.folder.upload.constants.LyocellDmFolderUploadPortletKeys;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.servlet.http.Part;

import org.osgi.service.component.annotations.Component;

@Component(
	    immediate = true,
	    property = {
	       "javax.portlet.name="  + LyocellDmFolderUploadPortletKeys.LYOCELLDMFOLDERUPLOAD,
	       "mvc.command.name=actionFolderUpload"
	    },
	    service = MVCActionCommand.class
	)
public class LyocellDmFolderUploadMVCAction extends BaseMVCActionCommand  {
	private static String ROOT_FOLDER_NAME;
	private static long PARENT_FOLDER_ID = DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
	@Override
	public void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws PortletException {
		
		try {			
			_log.info("folder upload:::::::::::");
			ThemeDisplay themeDisplay = (ThemeDisplay) actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
			String backURL=ParamUtil.getString(actionRequest,"backURL");
			_log.info("Tiger@@@@@@@@@@@@:::::::::::backURL ***"+backURL);
			long folderId;
			boolean numeric = true;		    
			if(backURL.contains("folderId")) {
				int lastIndex=(backURL.lastIndexOf("="));
				String folderID=backURL.substring(lastIndex+1);
				numeric = folderID.matches("-?\\d+(\\.\\d+)?");
				 folderId=DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
				 _log.info("Tiger@@@@@@@@@@@@:::::::::::numeric ***"+numeric);
				if(folderID!=null && !folderID.equals("") && numeric)
					folderId=Long.valueOf(folderID);
			}
			else {
				folderId=DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
			}
			_log.info("Tiger@@@@@@@@@@@@:::::::::::folderId ***"+folderId);
			long parentFolderId=folderId;
			
			for (Part part : actionRequest.getParts()) {
				String fileName = extractFileName(part);
				PARENT_FOLDER_ID = parentFolderId;//DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
				File file = new File(fileName);
				String strNew = fileName.replace("/" + file.getName(), "");
				String[] folderNames = strNew.trim().split("/");

				for (String folderName : folderNames) {
					ROOT_FOLDER_NAME = folderName;
					boolean folderExist = isFolderExist(themeDisplay);
					if (!folderExist) {
						createFolder(actionRequest, themeDisplay);
					}
				}
				InputStream is = part.getInputStream();
				fileUpload(themeDisplay, actionRequest, is, part);
				PARENT_FOLDER_ID = parentFolderId;//DLFolderConstants.DEFAULT_PARENT_FOLDER_ID;
				actionRequest.setAttribute("backURL", backURL);
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		actionRequest.setAttribute("message", "Upload has been done successfully!");
	//	return false;
	}
	public static void fileUpload(ThemeDisplay themeDisplay, ActionRequest actionRequest, InputStream is, Part part) {
		String title, description, mimeType;
		long repositoryId;
		String fileName = extractFileName(part);
		File file = new File(fileName);
		title = file.getName();
		description = title;
		repositoryId = themeDisplay.getScopeGroupId();
		mimeType = MimeTypesUtil.getContentType(file.getAbsoluteFile());
		try {
			ServiceContext serviceContext = ServiceContextFactory.getInstance(DLFileEntry.class.getName(),
					actionRequest);
			List<FileEntry> files= DLAppServiceUtil.getFileEntries(repositoryId, PARENT_FOLDER_ID);
			boolean isFileExist=false;
			for(FileEntry fileEntry :files) {
				if(file.getName().equals(fileEntry.getFileName())) {
					isFileExist=true;
					break;
				}
				
			}
			System.out.println("File:: "+file.getName()+ " is already Exist.");
			if(!isFileExist) {
				DLAppServiceUtil.addFileEntry(repositoryId, PARENT_FOLDER_ID, title, mimeType, title, description, "", is,
						part.getSize(), serviceContext);
			}
		} catch (PortalException e) {
			e.printStackTrace();
		} catch (SystemException e) {
			e.printStackTrace();
		}

	}

	public static Folder createFolder(ActionRequest actionRequest, ThemeDisplay themeDisplay) {
		Folder folder = null;
		long repositoryId = themeDisplay.getScopeGroupId();
		try {
			ServiceContext serviceContext = ServiceContextFactory.getInstance(DLFolder.class.getName(), actionRequest);
			folder = DLAppServiceUtil.addFolder(repositoryId, PARENT_FOLDER_ID, ROOT_FOLDER_NAME,
					LyocellDmFolderUploadPortletKeys.FILEUPLOADFOLDERDESC, serviceContext);
			PARENT_FOLDER_ID = folder.getFolderId();
		} catch (PortalException e1) {
			e1.printStackTrace();
		} catch (SystemException e1) {
			e1.printStackTrace();
		}
		return folder;
	}

	private static String extractFileName(Part part) {
		String contentDisp = part.getHeader("content-disposition");
		String[] items = contentDisp.split(";");
		for (String s : items) {
			if (s.trim().startsWith("filename")) {
				return s.substring(s.indexOf("=") + 2, s.length() - 1);
			}
		}
		return "";
	}

	public static boolean isFolderExist(ThemeDisplay themeDisplay) {
		boolean folderExist = false;
		try {
			Folder folder = DLAppServiceUtil.getFolder(themeDisplay.getScopeGroupId(), PARENT_FOLDER_ID,
					ROOT_FOLDER_NAME);
			folderExist = true;
			PARENT_FOLDER_ID = folder.getFolderId();
			System.out.println("Folder:: "+ROOT_FOLDER_NAME+" is already Exist.");
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		return folderExist;
	}
	
	private static Log _log=LogFactoryUtil.getLog(LyocellDmFolderUploadMVCAction.class);
	/*
	 * @Override protected void doProcessAction(ActionRequest actionRequest,
	 * ActionResponse actionResponse) throws Exception { // TODO Auto-generated
	 * method stub
	 * 
	 * }
	 */
}
