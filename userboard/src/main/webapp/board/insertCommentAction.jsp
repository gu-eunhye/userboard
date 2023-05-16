<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";	
	
	//1. 컨트롤러 계층
	//insertCommentAction: 댓글입력-> DB에 저장
	//세션 유효성 검사: 로그인이 되어있지 않으면 댓글입력은 불가하므로 홈으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//요청값: boardNo(int), memberId(String), commentContent(String)
	//post방식 요청값 인코딩
	request.setCharacterEncoding("utf-8");
	
	//요청값 확인
	System.out.println(request.getParameter("boardNo") + " <--insertCommentAction param boardNo"); 
	System.out.println(request.getParameter("memberId") + " <--insertCommentAction memberId"); 
	System.out.println(request.getParameter("commentContent") + " <--insertCommentAction commentContent"); 

	int boardNo = 0;
	String memberId = ""; // null이 넘어오는 경우 공백으로 처리하면 되기 때문에 공백으로 초기화한다
	String commentContent = "";
	
	// 요청값 유효성 검사: 요청값들이 null이거나 공백이면 home.jsp로 리다이렉션
	if(request.getParameter("boardNo") == null 
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId").equals("")
			|| request.getParameter("commentContent").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	} else{ //요청값 변수에 저장
		boardNo = Integer.parseInt(request.getParameter("boardNo"));
		memberId = request.getParameter("memberId");
		commentContent = request.getParameter("commentContent");
	}
	//디버깅
	System.out.println(PURPLE + boardNo + " <--insertCommentAction boardNo" + RESET);
	System.out.println(PURPLE + memberId + " <--insertCommentAction memberId" + RESET);
	System.out.println(PURPLE + commentContent + " <--insertCommentAction commentContent" + RESET);
	
	//2. 모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/*
		INSERT INTO COMMENT (board_no, comment_content, member_id, createdate, updatedate)
		VALUES(?, ?, ?, NOW(), NOW())
	*/
	String commentSql = "INSERT INTO COMMENT (board_no, comment_content, member_id, createdate, updatedate) VALUES(?, ?, ?, NOW(), NOW())";
	PreparedStatement commentStmt = conn.prepareStatement(commentSql);
	commentStmt.setInt(1, boardNo);
	commentStmt.setString(2, commentContent);
	commentStmt.setString(3, memberId);
	System.out.println(PURPLE + commentStmt + " <--insertCommentAction commentStmt" + RESET);
	
	int commentRow = commentStmt.executeUpdate(); // 영향받은 행의 개수(실행 후 결과값)
	if(commentRow == 1){
		System.out.println(commentRow + " <--insertCommentAction commentRow: 입력성공");
	} else{
		System.out.println(commentRow + " <--insertCommentAction commentRow: 입력실패");
	}
	
	// 입력이 완료되면(성공, 실패 여부 관계없이) boardOne.jsp로 되돌아간다
	response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+boardNo);
%>