<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	//세션 유효성 검사 : 로그인되어있으면 회원가입폼에 들어올 수 없으므로 홈으로 리다이렉션
	if(session.getAttribute("loginMemberId") != null){
		//responses는 클라이언트에서 실행되기 때문에 request.getContextPath()해줘야 한다
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>insertMemberFrom.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container">
		<!-- 메인메뉴 페이지 include -->
		<div>
			<jsp:include page ="/inc/mainmenu.jsp"></jsp:include>
		</div>
		
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
		
		<!-- 회원가입 폼  -->
		<div>
	       <h1 class="table-secondary">회원가입</h1>
				<form action = "<%=request.getContextPath()%>/member/insertMemberAction.jsp" method="post"> 
				<!-- web프로젝트 기반 주소로 쓰기 // ContextPath : 전체프로젝트의 경로 //이름,위치 변경해도 메소드 사용해 불러올 수 있다 -->
					<table class="table table-bordered">
						<tr>
							<th>아이디</th>
							<td><input type="text" name="id"></td>
						</tr>
						<tr>
							<th>패스워드</th>
							<td><input type="password" name="pw"></td>
						</tr>
					</table>
					<button type="submit" class="btn btn-secondary">회원가입</button>
				</form>
		</div>
	
		<!-- copyright 페이지 include -->
		<div>
		&nbsp;
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
			<!-- include : 액션태그의 일종 : JSP페이지에서 페이지와 페이지 사이 제어 : 추후에 커스텀태그로 대체함 -->
		</div>
	</div>
</body>
</html>