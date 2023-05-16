<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	//세션 유효성 검사 : 로그인이 되어있지 않으면 home으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>deleteMemberForm.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container">
	<!-- 메인메뉴 페이지 include -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<h1 class="table-secondary">회원탈퇴</h1>
	
	<!-- 리다이렉션 메시지 -->
	<div class="bg-warning">
	<%
		if(request.getParameter("msg") != null){
	%>
			<%=request.getParameter("msg")%>
	<%
		}
	%>
	</div>
	
	<!-- 회원탈퇴 비밀번호 확인 -->
	<form action="<%=request.getContextPath()%>/member/deleteMemberAction.jsp" method="post">
		<table class="table table-bordered">
			<tr>
				<th>비밀번호 확인</th>
				<td>
					<input type="password" name="memberPw">
				</td>
			</tr>
		</table>
		<button type="submit" class="btn btn-secondary">탈퇴하기</button>
	</form>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div>
	&nbsp;
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>