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
<title>updateMemberForm.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container">
	<!-- 메인메뉴 페이지 include -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<h1 class="table-secondary">비밀번호 변경</h1>
		
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
	
	<!-- 비밀번호 변경 폼 : 현재 비밀번호 확인 및 변경 비밀번호 입력 -->
	<form action="<%=request.getContextPath()%>/member/updateMemberAction.jsp" method="post">
		<table class="table table-bordered">
			<tr>
				<th>현재 비밀번호</th>
				<td>
					<input type="password" name="currentPw">
				</td>
			</tr>
			<tr>
				<th>변경 비밀번호</th>
				<td>
					<input type="password" name="changePw">
				</td>
			</tr>
			<tr>
				<th>변경 비밀번호 확인</th>
				<td>
					<input type="password" name="confirmPw">
				</td>
			</tr>
		</table>
		<button type="submit" class="btn btn-secondary">변경하기</button>
	</form>
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div>
	&nbsp;
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>