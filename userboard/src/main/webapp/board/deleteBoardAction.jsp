<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*"%>
<%
	//세션 유효성 검사 : 로그인이 되어있지 않으면 home으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	
	//post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	//요청값 확인
	System.out.println(request.getParameter("boardNo") + " <--deleteBoardAction param boardNo");
	//System.out.println(request.getParameter("memberId") + " <--deleteBoardAction param memberId");
	
	//요청값 유효성 검사 : 요청값이 공백이거나 null이면 리다이렉션
	String msg = null;
	if(request.getParameter("boardNo") == null 
			|| request.getParameter("boardNo").equals("")){
			//|| request.getParameter("memberId") == null
			//|| request.getParameter("memberId").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//요청값 변수에 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	//String memberId = request.getParameter("memberId");
	
	//디버깅
	System.out.println(PURPLE + boardNo + " <--deleteBoardAction boardNo" + RESET);
	//System.out.println(PURPLE + memberId + " <--deleteBoardAction memberId" + RESET);
	
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//외래키 위반 검사
	/*
		SELECT COUNT(*)
		FROM comment
		WHERE board_no = ?
	*/
	String sql = "SELECT COUNT(*) FROM comment WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
		
	ResultSet rs = stmt.executeQuery();
	int cnt = 0;
		if(rs.next()){
		cnt = rs.getInt("count(*)");
	}
		
	//cnt가 0이 아니면 페이지 반환
	if(cnt != 0){
		msg = URLEncoder.encode("외래키 제약 조건에 위배되어 삭제할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/board/boardOne.jsp?boardNo="+ boardNo + "&msg="+msg);
		return;
	}
		
	/* 삭제쿼리
		DELETE FROM board
		WHERE board_no = ?
	*/
	String sql1 = "DELETE FROM board WHERE board_no = ?";
	PreparedStatement stmt1 = conn.prepareStatement(sql1);
	stmt1.setInt(1, boardNo);
	
	System.out.println(PURPLE + stmt1 + " <--deleteBoardAction stmt1" + RESET);
	
	int row = stmt1.executeUpdate();
	System.out.println(PURPLE + row + " <--deleteBoardAction row" + RESET);
	
	if(row == 1){ 
		msg = URLEncoder.encode("게시글이 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/home.jsp?msg="+msg);
	} else { 
		msg = URLEncoder.encode("게시글 삭제에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/home.jsp?msg="+msg);
	}
%>