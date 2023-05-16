<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	final String CYAN = "\u001B[46m";
	
	//post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	//요청값 확인
	System.out.println(CYAN + request.getParameter("id") + " <--insertMemberAction param id" + RESET);
	System.out.println(CYAN + request.getParameter("pw") + " <--insertMemberAction param pw" + RESET); 
	
	//세션 유효성 검사: 로그인이 되어 있는 경우에는 이 페이지에 들어올 수 없다-> home.jsp로 리다이렉션 후 코드 진행 종료
	String msg = null;
	if(session.getAttribute("loginMemberId") != null) { // null인 경우는 세션에 정보가 저장되지 않은 경우
		response.sendRedirect(request.getContextPath() + "/home.jsp"); 
		return;
	}
	
	//요청값 유효성 검사: null 이거나 공백일 경우에는 회원가입폼으로 리다이렉션
	if(request.getParameter("id") == null 
		|| request.getParameter("id").equals("")
		|| request.getParameter("pw") == null
		|| request.getParameter("pw").equals("")){
		
		msg = URLEncoder.encode("ID 또는 PW를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg="+msg);
		return;
	}
	
	//요청값 변수에 저장
	String id = request.getParameter("id");
	String pw = request.getParameter("pw");
	//디버깅
	System.out.println(PURPLE + id + " <--insertMemberAction id" + RESET); 
	System.out.println(PURPLE + pw + " <--insertMemberAction pw" + RESET); 
	
	//변수에 저장한 요청값을 Member클래스로 묶는다
	Member signup = new Member();
	signup.setMemberId(id);
	signup.setMemberPw(pw);
	
	
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(CYAN + conn + " <--insertMemberAction conn : db접속성공" + RESET);
	
	/*
		INSERT INTO member (member_id, member_pw, createdate, updatedate)
		VALUES (?, PASSWORD(?), NOW(), NOW())
	*/
	String sql = "INSERT INTO member (member_id, member_pw, createdate, updatedate) VALUES (?, PASSWORD(?), NOW(), NOW())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, signup.getMemberId());
	stmt.setString(2, signup.getMemberPw());
	//디버깅
	System.out.println(PURPLE + stmt + " <--insertMemberAction stmt" + RESET);
	
	//id(기본키)가 중복되는 경우 에러 발생 -> select로 id먼저 비교한 후 중복값은 리다이렉션
	String sql2 = "SELECT member_id memberId from member where member_id = ?";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	stmt2.setString(1, signup.getMemberId());
	//디버깅
	System.out.println(PURPLE + stmt2 + " <--insertMemberAction stmt2" + RESET);
	
	ResultSet rs = stmt2.executeQuery();	
	if(rs.next()){ // 중복된 ID가 있는 경우
		msg = URLEncoder.encode("중복된 ID입니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg="+msg);
		return;
	}
	
	int row = stmt.executeUpdate(); // 영향받은 행의 수를 반환한다
	System.out.println(PURPLE + row + " <--insertMemberAction row" + RESET);
	
	if(row == 1){ 
		msg = URLEncoder.encode("회원가입 성공", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
	} else {
		msg = URLEncoder.encode("회원가입 실패", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
	}
%>