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
	System.out.println(CYAN + request.getParameter("localName") + " <--insertLocalAction param localName" + RESET);
	
	//요청값 유효성 검사
	String msg2 = null;
	if(request.getParameter("localName") == null 
			|| request.getParameter("localName").equals("")){
			
		msg2 = URLEncoder.encode("카테고리를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/localList.jsp?msg2="+msg2);
		return;
	}
	
	//요청값 변수에 저장
	String localName = request.getParameter("localName");
	System.out.println(PURPLE + localName + " <--insertLocalAction localName" + RESET); 
	
	//2.모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(CYAN + conn + " <--insertLocalAction conn : db접속성공" + RESET);
	
	/*
		INSERT INTO local (local_name, createdate, updatedate)
		VALUES (?, NOW(), NOW())
	*/
	String sql = "INSERT INTO local (local_name, createdate, updatedate) VALUES (?, NOW(), NOW())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	//디버깅
	System.out.println(PURPLE + stmt + " <--insertLocalAction stmt" + RESET);
	
	// localName(기본키)가 중복되는 경우 에러 발생
	/*
		SELECT count(*)
		from local 
		where local_name = ?
	*/
	String sql2 = "SELECT count(*) from local where local_name = ?";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	stmt2.setString(1, localName);
	//디버깅
	System.out.println(PURPLE + stmt2 + " <--insertLocalAction stmt2" + RESET);
		
	ResultSet rs = stmt2.executeQuery();
	int cnt = 0;
	if(rs.next()){
		cnt = rs.getInt("count(*)");
	}
	//cnt가 0이 아니면 페이지 반환
	if(cnt !=0){
		msg2 = URLEncoder.encode("중복된 카테고리입니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/localList.jsp?msg2="+msg2);
		return;
	}
		
	int row = stmt.executeUpdate(); //영향받은 행의 수를 반환한다
	System.out.println(PURPLE + row + " <--insertLocalAction row" + RESET);
		
	if(row == 1){ 
		msg2 = URLEncoder.encode("카테고리추가 성공", "utf-8");
		response.sendRedirect(request.getContextPath()+"/local/localList.jsp?msg2="+msg2);
	} else {
		msg2 = URLEncoder.encode("카테고리추가 실패", "utf-8");
		response.sendRedirect(request.getContextPath()+"/local/localList.jsp?msg2="+msg2);
	}
%>
