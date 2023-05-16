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
	
	//요청값 유효성 검사: 요청값들이 null이거나 공백이면 home.jsp로 리다이렉션
	if(request.getParameter("commentNo") == null 
			|| request.getParameter("commentNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	} 
	
	//요청값 변수에 저장
	int	commentNo = Integer.parseInt(request.getParameter("commentNo"));
	//디버깅
	System.out.println(PURPLE + commentNo + " <--updateComment commentNo" + RESET);
	
	//DB연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/*
		SELECT 
			comment_no commentNo
			, board_no boardNo
			, member_id memberId
			, comment_content commentContent
			, createdate
			, updatedate
		FROM comment
		WHERE comment_no = ?
	*/
	String sql ="SELECT comment_no commentNo, board_no boardNo, member_id memberId, comment_content commentContent, createdate, updatedate FROM comment WHERE comment_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,commentNo);
	//디버깅
	System.out.println(PURPLE + stmt + " <--updateComment stmt" + RESET);
	
	ResultSet rs = stmt.executeQuery();
	ArrayList<Comment> commentList = new ArrayList<Comment>();
	while(rs.next()){
		Comment c = new Comment();
		c.setCommentNo(rs.getInt("commentNo"));
		c.setBoardNo(rs.getInt("boardNo"));
		c.setCommentContent(rs.getString("commentContent"));
		c.setMemberId(rs.getString("memberId"));
		c.setCreatedate(rs.getString("createdate"));
		c.setUpdatedate(rs.getString("updatedate"));
		commentList.add(c);
	}	
	//디버깅
	System.out.println(PURPLE + commentList.size() +RESET);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateComment.jsp</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container">
	<!-- 메인메뉴 페이지 include -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<h1 class="table-secondary">댓글 수정</h1>
	
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
	
	<!-- 댓글 수정 입력폼 -->
	<form action="<%=request.getContextPath()%>/board/updateCommentAction.jsp" method="post">
		<%
			for(Comment c : commentList) {
		%>
				<!-- commentNo와 boardNo는 입력값이 없기 때문에 hidden으로 넘긴다 -->
				<input type="hidden" name="commentNo" value="<%=c.getCommentNo()%>">
				<input type="hidden" name="boardNo" value="<%=c.getBoardNo()%>">
				<table class="table table-bordered">
					<tr>
						<th class="text-center">댓글</th>
						<td>
							<input type="text" name="commentContent" value="<%=c.getCommentContent()%>" style="width:600px">
						</td>
					</tr>
					<tr>
						<th class="text-center">작성자</th>
						<td>
							<input type="text" name="memberId" value="<%=c.getMemberId()%>" style="border:none" readonly="readonly">
						</td>
					</tr>
					<tr>
						<th class="text-center">작성일</th>
						<td>
							<%=c.getCreatedate()%>
						</td>
					</tr>
					<tr>
						<th class="text-center">수정일</th>
						<td>
							<%=c.getUpdatedate()%>
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