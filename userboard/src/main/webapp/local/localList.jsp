<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	
	//1. 요청분석(컨트롤러 계층)
	//세션 유효성 검사
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//현재페이지 - 페이징에 필요한 변수
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	int startRow = (currentPage -1)*rowPerPage;
	
	//2. 모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//local 목록 결과셋(모델)
	/*
		SELECT 
			local_name localName,
			createdate,
			updatedate
		FROM local
		ORDER BY createdate DESC
		LIMIT ?, ?
	*/
	String sql = "SELECT local_name localName, createdate, updatedate FROM local ORDER BY createdate DESC LIMIT ?, ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, startRow);
	stmt.setInt(2, rowPerPage);
	
	ResultSet rs = stmt.executeQuery(); // DB쿼리 결과셋 모델
	ArrayList<Local> localList = new ArrayList<Local>();
		
	while(rs.next()) {
		Local l = new Local();
		l.setLocalName(rs.getString("localName"));
		l.setCreatedate(rs.getString("createdate"));
		l.setUpdatedate(rs.getString("updatedate"));
		localList.add(l);
	}
	//디버깅
	System.out.println(PURPLE + localList.size() + " <--localList.size" + RESET);
	
	//마지막페이지
	PreparedStatement stmt2 = conn.prepareStatement("SELECT count(*) FROM local");
	ResultSet rs2 = stmt2.executeQuery();
	
	int totalRow = 0; //전체 행
	if(rs2.next()){
		totalRow = rs2.getInt(1);
	}
	//디버깅
	System.out.println(PURPLE + totalRow + " <--localList totalRow" + RESET); 
	
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage + 1;
	}
	System.out.println(lastPage);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>localList.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container">
		<!-- 메인메뉴 페이지 include -->
		<div>
			<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
		</div>
		
		<h1 class="table-secondary">카테고리</h1>
	
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
		
		<!-- local list -->
		<table class="table table-sm text-center ">
			<tr>
				<th>localName</th>
				<th>createdate</th>
				<th>updatedate</th>
				<th>&nbsp;</th>
				<th>&nbsp;</th>
			</tr>
			<%
				for(Local l : localList) {
			%>
					<tr>
						<td><%=l.getLocalName()%></td>
						<td><%=l.getCreatedate()%></td>
						<td><%=l.getUpdatedate()%></td>
						<td>
							<a href="<%=request.getContextPath()%>/local/updateLocalForm.jsp?localName=<%=l.getLocalName() %>">
								수정
							</a>
						</td>
						<td>
							<a href="<%=request.getContextPath()%>/local/deleteLocalAction.jsp?localName=<%=l.getLocalName() %>">
								삭제
							</a>
						</td>
					</tr>
			<%
				}
			%>
		</table>
		<!-- local list 페이징 -->
		<ul class="pagination justify-content-center" style="margin:20px 0">
		<%
			if(currentPage > 1){
		%>
		  		<li class="page-item">
		  			<a class="page-link text-dark" href="<%=request.getContextPath()%>/local/localList.jsp?currentPage=<%=currentPage-1%>">
		  				Previous
		  			</a>
		  		</li>
		<%
			}
		%>
		  	<li class="page-item disabled"><a class="page-link" href="#"><%=currentPage %></a></li>
		<%
			if(currentPage < lastPage){
		%>
		  	<li class="page-item">
		  		<a class="page-link text-dark" href="<%=request.getContextPath()%>/local/localList.jsp?currentPage=<%=currentPage+1%>">
		  			Next
		  		</a>
		  	</li>
		<%
			}else{
		%>
				<li class="page-item disabled"><a class="page-link" href="#">Next</a></li>
		<%
			}
		%>
		</ul>
		
		<!-- insert local form  -->
		<h1 class="table-secondary">카테고리추가</h1>
			
		<!-- 리다이렉션 메시지 -->
		<div class="bg-warning">
		<%
			if(request.getParameter("msg2") != null){
		%>
				<%=request.getParameter("msg2")%>
		<%
			}
		%>
		</div>
			
		<div class="row">
			<div class="col-sm-6">
				<form action = "<%=request.getContextPath()%>/local/insertLocalAction.jsp" method="post">
					<table class="table table-borderless">
						<tr>
							<th>localName</th>
							<td>
								<input type="text" name="localName">
								<button type="submit" class="btn btn-secondary">추가</button>
							</td>
						</tr>
					</table>
				</form>
			</div>
		</div>
		
		<!-- copyright 페이지 include -->
		<div>
		&nbsp;
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
		</div>
	</div>
</body>
</html>