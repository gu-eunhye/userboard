<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	
	//1. 컨트롤러 계층
	//세션 유효성 검사: 로그인이 되어있지 않으면 회원정보보기 불가하므로 home으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//세션정보 변수에 저장 -> 쿼리문 조건에 사용할 변수
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(PURPLE + memberId + " <--memberOne memberId" + RESET);
	
	//2. 모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/*
		select member_id memberId, member_pw memberPw, createdate, updatedate 
		from member
		where member_id = ?
	*/
	String sql = "select member_id memberId, member_pw memberPw, createdate, updatedate from member where member_id = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberId);
	//디버깅
	System.out.println(PURPLE + stmt + " <--memberOne Stmt" + RESET);
	
	ResultSet rs = stmt.executeQuery();
	//모델 : 회원정보가 1개 -> ArrayList가 아닌 Member타입으로 저장
	Member member = null; // Member는 있으면 만들기 때문에 new연산자로 만들어놓지 않는다
	if(rs.next()){
		member = new Member();
		member.setMemberId(rs.getString("memberId"));
		member.setMemberPw(rs.getString("memberPw"));
		member.setCreatedate(rs.getString("createdate"));
		member.setUpdatedate(rs.getString("updatedate"));
	}
	//디버깅
	System.out.println(PURPLE + member + " <-- memberOne member" + RESET); 
%>    
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>memberOne.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container">
		<!-- 메인메뉴 페이지 include -->
		<div>
			<jsp:include page ="/inc/mainmenu.jsp"></jsp:include>
		</div>
		
		<!-- 회원정보 -->
		<h1 class="table-secondary">회원정보</h1>
			<table class="table table-bordered">
				<tr>
					<th>아이디</th>
					<td><%=member.getMemberId() %></td>
				</tr>
				<tr>
					<th>가입일</th>
					<td><%=member.getCreatedate() %></td>
				</tr>
				<tr>
					<th>수정일</th>
					<td><%=member.getUpdatedate() %></td>
				</tr>
			</table>

			<!-- 비밀번호변경, 회원탈퇴 버튼 -->
			<div class="text-end">
				<a href="<%=request.getContextPath()%>/member/updateMemberForm.jsp" class="btn btn-secondary">비밀번호 변경</a>
				<a href="<%=request.getContextPath()%>/member/deleteMemberForm.jsp" class="btn btn-secondary">회원 탈퇴</a>
			</div>
			<br>
			
		<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
		<div>
			<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>