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
	
	//1. 컨트롤러 계층
	//post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	//요청값 확인
	System.out.println(request.getParameter("localName") + " <--updateLocalAction param localName");
	System.out.println(request.getParameter("updateLocalName") + " <--updateLocalAction param updateLocalName");
	
	//요청값 유효성 검사 : 요청값이 공백이거나 null이면 리다이렉션
	String msg = null;
	if(request.getParameter("updateLocalName") == null
			|| request.getParameter("updateLocalName").equals("")){
		msg = URLEncoder.encode("카테고리를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/local/updateLocalForm.jsp?msg="+msg+"&localName="+URLEncoder.encode(request.getParameter("localName"), "utf-8"));
		return;
	}
	
	//요청값 변수에 저장
	String localName = request.getParameter("localName");
	String updateLocalName = request.getParameter("updateLocalName");
	//디버깅
	System.out.println(PURPLE + localName + " <--updateLocalAction localName" + RESET);
	System.out.println(PURPLE + updateLocalName + " <--updateLocalAction updateLocalName" + RESET);
		
	// 2. 모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//중복 검사
	/*
		SELECT count(*)
		from local 
		where local_name = ?
	*/
	String sql = "select count(*) from local where local_name = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, updateLocalName);
	
	ResultSet rs = stmt.executeQuery();
	int cnt = 0;
	if(rs.next()){
		cnt = rs.getInt("count(*)");
	}
	
	//cnt가 0이 아니면 페이지 반환
	if(cnt != 0){
		msg = URLEncoder.encode("중복된 카테고리입니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/local/updateLocalForm.jsp?msg="+msg+"&localName="+URLEncoder.encode(localName, "utf-8"));
		return;
	}

	/* 수정쿼리 
		update local 
		set local_name = ?, updatedate = now()
		where local_name = ? 
	*/
	String sql1 = "update local set local_name = ?, updatedate = now() where local_name = ?";
	PreparedStatement stmt1 = conn.prepareStatement(sql1);
	stmt1.setString(1, updateLocalName);
	stmt1.setString(2, localName);
	System.out.println(PURPLE + stmt1 + " <--updateLocalAction stmt1" + RESET);
	
	int row = stmt1.executeUpdate();
	System.out.println(PURPLE + row + " <--updateLocalAction row" + RESET);
	
	if(row == 1){ 
		msg = URLEncoder.encode("카테고리가 수정되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/local/localList.jsp?msg="+msg);
	} else { 
		msg = URLEncoder.encode("카테고리 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/local/updateLocalForm.jsp?msg="+msg+"&localName="+URLEncoder.encode(localName, "utf-8"));
	}
%>