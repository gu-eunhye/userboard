<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	
	int currentPage = 1; //시작 페이지
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10; //한페이지에 출력할 게시물 수
	int startRow = (currentPage -1)*rowPerPage;
	
	int pageCount = 10; //한번에 출력될 페이징 버튼 수
	int startPage = ((currentPage - 1) / pageCount) * pageCount + 1; //페이징 버튼 시작 값
	int endPage = startPage + pageCount - 1; //페이징 버튼 종료 값

	
	String localName = "전체";
	if(request.getParameter("localName") != null) {
		localName = request.getParameter("localName");
	}
	
	//2. 모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//1) 서브메뉴 결과셋(모델)
	/*
	SELECT '전체' localName, COUNT(local_name) cnt FROM board
	UNION ALL 
	SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name
	UNION ALL
	SELECT local_name, 0 FROM local WHERE local_name NOT IN (SELECT local_name FROM board)
	*/
	String subMenuSql = "SELECT '전체' localName, COUNT(local_name) cnt FROM board UNION ALL SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name UNION ALL SELECT local_name, 0 FROM local WHERE local_name NOT IN (SELECT local_name FROM board)";
	PreparedStatement subMenuStmt = conn.prepareStatement(subMenuSql);
	ResultSet subMenuRs = subMenuStmt.executeQuery();
	ArrayList<HashMap<String, Object>> subMenuList = new ArrayList<HashMap<String, Object>>();
	while(subMenuRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", subMenuRs.getString("localName"));
		m.put("cnt", subMenuRs.getInt("cnt"));
		subMenuList.add(m);
	}
	
	//2) 게시판 목록 결과셋(모델)
	/*
		SELECT 
			board_no boardNo,
			local_name localName,
			board_title boardTitle,
			createdate
		FROM board
		WHERE local_name = ?
		ORDER BY createdate DESC
		LIMIT ?, ?
	*/
	String boardSql = "";
	PreparedStatement boardStmt = null;
	if(localName.equals("전체")) {
		boardSql = "SELECT board_no boardNo, local_name localName,board_title boardTitle,createdate FROM board ORDER BY createdate DESC LIMIT ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		boardStmt.setInt(1, startRow);
		boardStmt.setInt(2, rowPerPage);
	} else {
		boardSql = "SELECT board_no boardNo, local_name localName,board_title boardTitle,createdate FROM board WHERE local_name = ? ORDER BY createdate DESC LIMIT ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		boardStmt.setString(1, localName);
		boardStmt.setInt(2, startRow);
		boardStmt.setInt(3, rowPerPage);
	}
	
	ResultSet boardRs = boardStmt.executeQuery(); //DB쿼리 결과셋 모델
	ArrayList<Board> boardList = new ArrayList<Board>(); //애플케이션에서 사용할 모델(사이즈 0)
	//boardRs --> boardList
	while(boardRs.next()) {
		Board b = new Board();
		b.setBoardNo(boardRs.getInt("boardNo"));
		b.setLocalName(boardRs.getString("localName"));
		b.setBoardTitle(boardRs.getString("boardTitle"));
		b.setCreatedate(boardRs.getString("createdate"));
		boardList.add(b);
	}
	//디버깅
	System.out.println(PURPLE + boardList.size()+ "<--home boardList.size()" + RESET);
	

	//마지막페이지
	String pageSql = "";
	PreparedStatement pageStmt = null;
	if(localName.equals("전체")){
		pageSql = "SELECT COUNT(*) FROM board";
		pageStmt = conn.prepareStatement(pageSql);
	} else {
		pageSql = "SELECT COUNT(*) FROM board WHERE local_name = ?";
		pageStmt = conn.prepareStatement(pageSql);
		pageStmt.setString(1, localName);
	}
	ResultSet pageRs = pageStmt.executeQuery();
	
	int totalRow = 0; //전체 행 수
	if(pageRs.next()){
		totalRow = pageRs.getInt("COUNT(*)");
	}
	//디버깅
	System.out.println(PURPLE + totalRow + " <--home totalRow" + RESET); 
	
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage + 1;
	}
	
	if(totalRow < currentPage){
		currentPage = lastPage;
	}

	if(endPage > lastPage){
		endPage = lastPage;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>home.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container">
	<!-- 메인메뉴 페이지 include -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<!--  리다이렉션 메시지 -->
	<div class="bg-warning">
	<%
		if(request.getParameter("msg") != null){
	%>
			<%=request.getParameter("msg")%>
	<%
		}
	%>
	</div>
	
	<div class="row">
	<!-- 서브메뉴(카테고리항목) subMenuList모델을 세로로 출력 -->
		<div class="col-sm-6">
		<h3>카테고리</h3>
			<div style="overflow:auto; height:300px;">
				<ul class="list-group list-group-flush">
					<%
						for(HashMap<String, Object> m : subMenuList) {
					%>
							<li class="list-group-item">
								<a href="<%=request.getContextPath()%>/home.jsp?localName=<%=(String)m.get("localName")%>">
									<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)
								</a>
							</li>
					<%		
						}
					%>
				</ul>
			</div>
			<br>
		</div>

		<div class="col-sm-6">
			<!-- home 내용 : 로그인폼 / 카테고리별 게시글 5개씩 -->	
			<!-- 로그인 폼 -->
			<div class="container" style="border:1px">
			<%
				if(session.getAttribute("loginMemberId") == null) { // 로그인전이면 로그인폼출력, 로그인 후엔 로그인폼 사라짐 
			%>
					<h3>로그인</h3>
					<form action="<%=request.getContextPath()%>/member/loginAction.jsp" method="post">
						<div class="form-group">
							<label for="memberId">ID:</label>
							<input type="text" class="form-control" placeholder="Enter ID" name="memberId">
						</div>
						<div class="form-group">
							<label for="memberPw">Password:</label>
							<input type="password" class="form-control" placeholder="Enter Password" name="memberPw">
						</div>
						<div class="text-center "><button type="submit" class="btn btn-outline-secondary">Login</button></div>
					</form>
			<%	
				}
			%>
			</div>
		</div>
	</div>
	
	<!-- boardList : 카테고리별 게시글 5개씩 -->
	<div>
		<table class="table table-sm text-center ">
			<tr class="table-secondary">
				<th>localName</th>
				<th>boardTitle</th>
				<th>createdate</th>
			</tr>
			<%
				for(Board b : boardList) {
			%>
					<tr>
						<td><%=b.getLocalName()%></td>
						<td>
							<a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=b.getBoardNo()%>">
								<%=b.getBoardTitle()%>
							</a>
						</td>
						<td><%=b.getCreatedate()%></td>
					</tr>
			<%
				}
			%>
		</table>
		
		<!-- board list 페이징 -->
		<ul class="pagination justify-content-center" style="margin:20px 0">
			
				<%
					//이전 페이지 버튼
					if(currentPage > pageCount){
				%>
		    			<li class="page-item">
		    				<a class="page-link text-dark" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=startPage-10 %>&localName=<%=localName%>">
		    					이전
		    				</a>
		    			</li>
		    	<%
					}
			        for(int i = startPage; i <= endPage; i++){
			        	if(i==currentPage){
			    %>
			        		<li class="page-item active">
			        			<a class="page-link text-dark" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=i %>&localName=<%=localName%>">
			        				<%=i %>
			        			</a>
			        		</li>
			    <%
			        	}else{
		    	%>
		        		<li class="page-item">
		        			<a class="page-link text-dark" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=i %>&localName=<%=localName%>">
		        				<%=i %>
		        			</a>
		        		</li>
		        <%
		        		}
			        }
			    	//다음 페이지 버튼
			    	if(currentPage < (lastPage-pageCount+1)){
		        %>
					<li class="page-item">
						<a class="page-link text-dark" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=endPage+1 %>&localName=<%=localName%>">
							다음
						</a>
					</li>
				<%
					}
				%>
		</ul>
	</div>
</div>
</body>
</html>