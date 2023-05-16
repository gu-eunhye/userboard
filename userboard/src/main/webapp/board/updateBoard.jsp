<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<%@ page import ="java.util.*" %>
<%@ page import ="vo.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	final String CYAN = "\u001B[46m";
	
	//세션 유효성 검사 : 로그인이 되어있지 않으면 home으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//요청값 유효성 검사: null이거나 공백이면 홈으로 리다이렉션 후 코드진행 종료
	if(request.getParameter("boardNo") == null 
			|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}	

	//요청값 변수에 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	//디버깅
	System.out.println(boardNo + " <-- updateBoard boardNo");
	
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
			board_no boardNo
			, local_name localName
			, board_title boardTitle
			, board_content boardContent
			, member_id memberId
			, createdate
			, updatedate
		FROM board
		WHERE board_no = ?
	*/
	String sql ="SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate FROM board WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,boardNo);
	//디버깅
	System.out.println(PURPLE + stmt + " <--updateBoard stmt" + RESET);
	
	ResultSet rs = stmt.executeQuery();
	ArrayList<Board> boardList = new ArrayList<Board>();
	while(rs.next()) {
		Board b = new Board();
		b.setBoardNo(rs.getInt("boardNo"));
		b.setLocalName(rs.getString("localName"));
		b.setBoardTitle(rs.getString("boardTitle"));
		b.setBoardContent(rs.getString("boardContent"));
		b.setMemberId(rs.getString("memberId"));
		b.setCreatedate(rs.getString("createdate"));
		b.setUpdatedate(rs.getString("updatedate"));
		boardList.add(b);
	}	
	//디버깅
	System.out.println(PURPLE + boardList.size() +RESET);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateBoard.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container">
	<!-- 메인메뉴 페이지 include -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<h1 class="table-secondary">게시판 수정</h1>
	
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
	
	<!-- 게시판 수정 입력폼 -->
	<form action="<%=request.getContextPath()%>/board/updateBoardAction.jsp" method="post">
		<%
			for(Board b : boardList) {
		%>
		
		<table class="table table-bordered ">
			<tr>
				<th class="text-center">번호</th>
				<td>
					<input type="text" name="boardNo" value="<%=b.getBoardNo()%>" style="border:none" readonly="readonly">
				</td>
			</tr>
			<tr>
				<th class="text-center">지역</th>
				<td>
					<input type="text" name="localName" value="<%=b.getLocalName()%>">
				</td>
			</tr>
			<tr>
				<th class="text-center">제목</th>
				<td>
					<input type="text" name="boardTitle" value="<%=b.getBoardTitle()%>" style = "width : 600px">
				</td>
			</tr>
			<tr>
				<th class="text-center">본문</th>
				<td>
					<input type="text" name="boardContent" value="<%=b.getBoardContent()%>" style = "width : 600px">
				</td>
			</tr>
			<tr>
				<th class="text-center">작성자</th>
				<td>
					<input type="text" name="memberId" value="<%=b.getMemberId()%>" style="border:none"  readonly="readonly">
				</td>
			</tr>
			<tr>
				<th class="text-center">작성일</th>
				<td>
					<%=b.getCreatedate() %>
				</td>
			</tr>
			<tr>
				<th class="text-center">수정일</th>
				<td>
					<%=b.getUpdatedate() %>
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