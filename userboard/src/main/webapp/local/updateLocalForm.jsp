<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<%@ page import ="java.util.*" %>
<%@ page import ="vo.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	final String CYAN = "\u001B[46m";
	
	//로그인이 되어있지 않으면 home으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}

	//요청값 변수에 저장
	String localName = request.getParameter("localName");
	//디버깅
	System.out.println(localName + " <-- updateLocalForm localName");
	
	//DB연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//쿼리생성
	/*
		SELECT 
			local_name localName,
			createdate,
			updatedate
		FROM local
		WHERE local_name=?
	*/
	String sql ="SELECT local_name localName, createdate, updatedate FROM local WHERE local_name=?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1,localName);
	//디버깅
	System.out.println(PURPLE + stmt + " <--updateLocalForm stmt" + RESET);

	ResultSet rs = stmt.executeQuery(); 
	ArrayList<Local> localList = new ArrayList<Local>();
	while(rs.next()) {
		Local l = new Local();
		l.setLocalName(rs.getString("localName"));
		l.setCreatedate(rs.getString("createdate"));
		l.setUpdatedate(rs.getString("updatedate"));
		localList.add(l);
	}
	//디버깅
	System.out.println(PURPLE + localList.size() +RESET);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateLocalForm.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container">
	<!-- 메인메뉴 페이지 include -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<h1 class="table-secondary">카테고리 수정</h1>
	
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
	
	<!-- 카테고리 수정 입력폼 -->
	<form action="<%=request.getContextPath()%>/local/updateLocalAction.jsp" method="post">
		<%
			for(Local l : localList) {
		%>
		<table class="table table-bordered">
			<tr>
				<th>localName</th>
				<td>
					<input type="text" name="localName" value="<%=l.getLocalName()%>" style="border:none" readonly="readonly">
				</td>
			</tr>
			<tr>
				<th>updateLocalName</th>
				<td>
					<input type="text" name="updateLocalName">
				</td>
			</tr>
			<tr>
				<th>createdate</th>
				<td>
					<%=l.getCreatedate() %>
				</td>
			</tr>
			<tr>
				<th>updatedate</th>
				<td>
					<%=l.getUpdatedate() %>
				</td>
			</tr>
		</table>
		<%
			}
		%>
		<button type="submit" class="btn btn-secondary">수정하기</button>
	</form>
	
	<!-- copyright 페이지 include -->
	<div>
	&nbsp;
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>