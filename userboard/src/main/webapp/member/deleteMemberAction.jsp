<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*"%>
<%
	//세션 유효성 검사 : 로그인이 되어있지 않으면 home으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	
	//1. 컨트롤러 계층
	//post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	//요청값 확인
	System.out.println(request.getParameter("memberPw") + " <--deleteMemberAction param memberPw");
	
	//요청값 유효성 검사
	if(request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")){
		response.sendRedirect(request.getContextPath()+"/member/deleteMemberForm.jsp");
		return;
	}
	
	//요청값 변수에 저장
	String memberPw = request.getParameter("memberPw");
	String memberId = (String)session.getAttribute("loginMemberId");
	
	//2. 모델계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/*
		delete 
		from member
		where member_id = ? and member_pw = password(?) 
	*/
	String sql = "delete from member where member_id = ? and member_pw = password(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberId);
	stmt.setString(2, memberPw);
	//디버깅
	System.out.println(PURPLE + stmt + " <--deleteMemberAction stmt" + RESET);
	
	int row = stmt.executeUpdate();
	//디버깅
	System.out.println(PURPLE + row + " <--deleteMemberAction row" + RESET);
	
	String msg = null;
	if (row == 1){
		msg = URLEncoder.encode("회원탈퇴되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		session.invalidate();
		return;
	} else {
		msg = URLEncoder.encode("비밀번호를 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/deleteMemberForm.jsp?msg="+msg);
	}
%>