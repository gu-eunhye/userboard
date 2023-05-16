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
	System.out.println(request.getParameter("commentNo") + " <--deleteCommentAction param commentNo");
	
	//요청값 유효성 검사 : 요청값이 공백이거나 null이면 리다이렉션
	if(request.getParameter("commentNo") == null 
			|| request.getParameter("commentNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//요청값 변수에 저장
	int	commentNo = Integer.parseInt(request.getParameter("commentNo"));
	//디버깅
	System.out.println(PURPLE + commentNo + " <--deleteCommentAction commentNo" + RESET);
	
	
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/* 삭제쿼리
		DELETE FROM comment
		WHERE comment_no = ?
	*/
	String sql = "DELETE FROM comment WHERE comment_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, commentNo);
	
	System.out.println(PURPLE + stmt + " <--deleteCommentAction stmt" + RESET);
	
	int row = stmt.executeUpdate();
	System.out.println(PURPLE + row + " <--deleteCommentAction row" + RESET);
	String msg = null;
	if(row == 1){ 
		msg = URLEncoder.encode("댓글이 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/board/boardOne.jsp?msg2="+msg+"&boardNo="+URLEncoder.encode(request.getParameter("boardNo"), "utf-8"));
	} else { 
		msg = URLEncoder.encode("댓글 삭제에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/board/boardOne.jsp?msg2="+msg+"&boardNo="+URLEncoder.encode(request.getParameter("boardNo"), "utf-8"));
	}
%>