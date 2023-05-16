<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.net.*" %>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";
	final String CYAN = "\u001B[46m";

	//1. 컨트롤러 계층
	//post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	//요청값 확인
	System.out.println(CYAN + request.getParameter("localName") + " <--deleteLocalAction param localName" + RESET);
	
	//요청값 유효성 검사 : null이나 공백이면 localList로 리다이렉션
	String msg = null;
	if(request.getParameter("localName") == null 
			|| request.getParameter("localName").equals("")){
		
		response.sendRedirect(request.getContextPath()+"/local/localList.jsp");
		return;
	} 
	
	//요청값 변수에 저장
	String localName = request.getParameter("localName");
	//디버깅
	System.out.println(PURPLE + localName + " <--deleteLocalAction localName" + RESET);
	
	//2. 모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	//외래키 위반 검사
	/*
		SELECT COUNT(*)
		FROM board 
		WHERE local_name = ?
	*/
	String sql = "SELECT COUNT(*) FROM board WHERE local_name = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	
	ResultSet rs = stmt.executeQuery();
	int cnt = 0;
	if(rs.next()){
		cnt = rs.getInt("count(*)");
	}
	
	//cnt가 0이 아니면 페이지 반환
	if(cnt != 0){
		msg = URLEncoder.encode("외래키 제약 조건에 위배되어 삭제할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/local/localList.jsp?msg="+msg);
		return;
	}
	
	//카테고리 삭제를 위한 sql 쿼리문 작성
	/*
		DELETE FROM local
		WHERE local_name = ?
	*/
	String sql2 = "DELETE FROM local WHERE local_name = ?";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	stmt2.setString(1,localName);
	//디버깅
	System.out.println(PURPLE + stmt2 + " <--deleteLocalAction stmt2" + RESET);
	
	int row = stmt2.executeUpdate();
	
	if(row==1){
		msg = URLEncoder.encode("카테고리가 삭제되었습니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/local/localList.jsp?msg="+msg);
		return;
	}else{
		msg = URLEncoder.encode("카테고리 삭제에 실패했습니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/local/localList.jsp?msg="+msg);
		return;
	}
%>