<%@ include file="/init.jsp" %>
<%@page import="com.liferay.portal.kernel.util.PortalUtil"%>  
<%@page import="com.liferay.portal.kernel.service.LayoutLocalServiceUtil" %>
<%@page import="com.liferay.portal.kernel.model.Layout" %>
<%@page import="com.liferay.portal.kernel.theme.ThemeDisplay" %>
 <input type="button" value="I accept" onclick="agree()">
 <input type="button" value="I reject" onclick="disAgree()">
  <%--  <a href="<%= PortalUtil.getPortalURL(request) %>/web/guest/upload-folder">Accept</a>
  <a href="<%= PortalUtil.getPortalURL(request) %>/c/portal/logout">Log Out</a> 
  --%>
  
<script>
 function disAgree() {  	
    window.location ="<%= PortalUtil.getPortalURL(request) %>/c/portal/logout";
} 
 function agree(){
	 window.location ="<%= PortalUtil.getLayoutFriendlyURL(LayoutLocalServiceUtil.getFriendlyURLLayout(themeDisplay.getScopeGroupId(), false, "/content"),themeDisplay)%>";
 }

</script>
