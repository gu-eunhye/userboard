<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<% 
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	
	//1. 컨트롤러계층
	//요청분석: 로그인 여부 관계 없이 상세페이지 read가능
	//1) 요청값 확인
	System.out.println(request.getParameter("boardNo") + " <--boardOne param boardNo"); 
	System.out.println(request.getParameter("currentPage") + " <--boardOne currentPage"); 
	
	//2) 요청값 유효성 검사: null이거나 공백이면 home으로 리다이렉션 후 코드진행 종료
	if(request.getParameter("boardNo") == null 
			|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//유효성 검사 완료 후 변수에 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	
	//현재페이지 - comment(댓글) 페이징에 필요한 변수
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 2;
	int startRow = (currentPage -1)*rowPerPage;;
	
	//2. 모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//2-1) board one 결과셋
	/*
		SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate
		FROM board
		WHERE board_no = ?
	*/
	String boardSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate FROM board WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	//디버깅
	System.out.println(PURPLE + boardStmt + " <--boardOne boardStmt" + RESET);
	
	ResultSet boardRs = boardStmt.executeQuery();
	//모델: 게시글 상세내용->1개->ArrayList가 아닌 Board타입으로 저장
	Board board = null; // Board는 있으면 만들기 때문에 new연산자로 만들어놓지 않는다
	if(boardRs.next()){
		board = new Board();
		board.setBoardNo(boardRs.getInt("boardNo"));
		board.setLocalName(boardRs.getString("localName"));
		board.setBoardTitle(boardRs.getString("boardTitle"));
		board.setBoardContent(boardRs.getString("boardContent"));
		board.setMemberId(boardRs.getString("memberId"));
		board.setCreatedate(boardRs.getString("createdate"));
		board.setUpdatedate(boardRs.getString("updatedate"));
	}
	//디버깅
	System.out.println(PURPLE + board + " <-- boardOne board" + RESET);
	
	
	// 2-2) comment list결과셋
	/*
		SELECT comment_no commentNo, board_no boardNo, comment_content commentContent
		FROM comment
		WHERE board_no = ?
		ORDER BY createdate DESC
		LIMIT ?, ?
	*/
	String commentListSql = "SELECT comment_no commentNo, board_no boardNo, comment_content commentContent, member_id memberId, createdate, updatedate FROM comment WHERE board_no = ? ORDER BY createdate DESC LIMIT ?, ?";
	PreparedStatement commentListStmt = conn.prepareStatement(commentListSql);
	commentListStmt.setInt(1, boardNo);
	commentListStmt.setInt(2, startRow);
	commentListStmt.setInt(3, rowPerPage);
	//디버깅
	System.out.println(PURPLE + commentListStmt + " <-- boardOne commentListStmt" + RESET); 
	
	ResultSet commentListRs = commentListStmt.executeQuery(); //최대 10개 예상(rowPerPage= 10)
	// ArrayList 
	ArrayList<Comment> commentList = new ArrayList<Comment>();
	while(commentListRs.next()){
		Comment c = new Comment();
		c.setCommentNo(commentListRs.getInt("commentNo"));
		c.setBoardNo(commentListRs.getInt("boardNo"));
		c.setCommentContent(commentListRs.getString("commentContent"));
		c.setMemberId(commentListRs.getString("memberId"));
		c.setCreatedate(commentListRs.getString("createdate"));
		c.setUpdatedate(commentListRs.getString("updatedate"));
		commentList.add(c);
	}
	//디버깅
	System.out.println(PURPLE + commentList.size() + " <--boardOne commentList.size()" + RESET); //rowPerPage= 10 값과 동일
	
	//마지막페이지
	PreparedStatement stmt2 = conn.prepareStatement("SELECT COUNT(*) FROM comment WHERE board_no = ?");
	stmt2.setInt(1, boardNo);
	ResultSet rs2 = stmt2.executeQuery();
	
	int totalRow = 0; //전체 행
	if(rs2.next()){
		totalRow = rs2.getInt("COUNT(*)");
	}
	//디버깅
	System.out.println(PURPLE + totalRow + " <--boardOne totalRow" + RESET); 
	
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage + 1;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>boardOne.jsp</title>
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
	
	<!-- 3-1) board one 결과셋 -->
	<div>
	<h1 class="table-secondary">상세내용</h1>
		<table class="table table-bordered ">
			<tr>
				<th class="text-center">번호</th>
				<td><%=board.getBoardNo()%></td>
			</tr>
			<tr>
				<th class="text-center">지역</th>
				<td><%=board.getLocalName()%></td>
			</tr>
			<tr>
				<th class="text-center">제목</th>
				<td><%=board.getBoardTitle()%></td>
			</tr>
			<tr>
				<th class="text-center">본문</th>
				<td><%=board.getBoardContent()%></td>
			</tr>
			<tr>
				<th class="text-center">작성자</th>
				<td><%=board.getMemberId()%></td>
			</tr>
			<tr>
				<th class="text-center">작성일</th>
				<td><%=board.getCreatedate()%></td>
			</tr>
			<tr>
				<th class="text-center">수정일</th>
				<td><%=board.getUpdatedate()%></td>
			</tr>
		</table>
	</div>
	<!-- board one 수정, 삭제 버튼 -->
<%
	if(session.getAttribute("loginMemberId") != null){
		if(session.getAttribute("loginMemberId").equals(board.getMemberId())){	
%>			<!-- 로그인된 사용자와 게시글입력한 사용자가 일치하면 수정,삭제 가능 -->
			<div>
				<a href="<%=request.getContextPath()%>/board/updateBoard.jsp?boardNo=<%=boardNo%>" class="btn btn-secondary">수정</a>
				<a href="<%=request.getContextPath()%>/board/deleteBoardAction.jsp?boardNo=<%=boardNo%>" class="btn btn-secondary">삭제</a>
			</div>
			<br>
<%
		}
	}
%>
	<br>
	<!-- 3-2) comment(댓글) 입력 : 세션유무에 따른 분기 -->
	<h1 class="table-secondary">댓글</h1>
	
	<!--  리다이렉션 메시지 -->
	<div class="bg-warning">
	<%
		if(request.getParameter("msg2") != null){
	%>
			<%=request.getParameter("msg2")%>
	<%
		}
	%>
	</div>
	
	<%
		// 로그인 사용자만 댓글 입력 허용
		if(session.getAttribute("loginMemberId") != null){
			// 현재 로그인 사용자의 ID
			String loginMemberId = (String)session.getAttribute("loginMemberId");
	%>
			<form class="form-inline" action="<%=request.getContextPath()%>/board/insertCommentAction.jsp" method="post">
				<!-- boardNo와 memberId는 입력값이 없기 때문에 hidden으로 넘긴다 -->
				<input type="hidden" name="boardNo" value="<%=board.getBoardNo()%>">
				<input type="hidden" name="memberId" value="<%=loginMemberId%>">
				
				<textarea rows="2" cols="80" class="form-control mb-2 mr-sm-2" placeholder="Enter comment" name="commentContent"></textarea>
				<button type="submit" class="btn btn-secondary">댓글입력</button>
			</form>
				
				
				
		
	<%
		}
	%>
	<br>
	
	<!-- 3-3) comment list 결과셋 -->	
	<table class="table table-sm">
		<thead class="text-center">
			<tr>
				<th>내용</th>
				<th>작성자</th>
				<th>작성일</th>
				<th>수정일</th>
				<th>&nbsp;</th>
				<th>&nbsp;</th>
			</tr>
		</thead>
	<%
		for(Comment c : commentList){
	%>
			<tr class = "text-center">
				<td><%=c.getCommentContent()%></td>
				<td><%=c.getMemberId()%></td>
				<td><%=c.getCreatedate()%></td>
				<td><%=c.getUpdatedate()%></td>
	<%
			if(session.getAttribute("loginMemberId") != null){ 
				if(session.getAttribute("loginMemberId").equals(c.getMemberId())){	
	%>				<!-- 로그인된 사용자와 댓글입력한 사용자가 일치하면 수정,삭제 가능 -->
					<td><a href="<%=request.getContextPath()%>/board/updateComment.jsp?commentNo=<%=c.getCommentNo()%>">수정</a></td>
					<td><a href="<%=request.getContextPath()%>/board/deleteCommentAction.jsp?commentNo=<%=c.getCommentNo()%>&boardNo=<%=boardNo%>">삭제</a></td>
	<%
				}else{
	%>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
	<%
				}
			}
	%>
			</tr>
	<%
		}
	%>
	</table>
	<!-- comment 페이징 -->
	<ul class="pagination justify-content-center" style="margin:20px 0">
		<%
			if(currentPage > 1){
		%>
		  		<li class="page-item">
		  			<a class="page-link text-dark" href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>&currentPage=<%=currentPage-1%>">
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
			  		<a class="page-link text-dark" href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>&currentPage=<%=currentPage+1%>">
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
		
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div>
	&nbsp;
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</div>
</body>
</html>