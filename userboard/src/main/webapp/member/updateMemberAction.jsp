<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*"%>
<%
	//Ansi코드 //콘솔창에서 글자배경색지정
	final String RESET = "\u001B[0m";	
	final String PURPLE = "\u001B[45m";	

	// 1. 컨트롤러 계층
	//세션 유효성 검사: 로그인이 되어있지 않으면 home으로 리다이렉션
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	//post방식 요청값 인코딩하기
	request.setCharacterEncoding("utf-8");
	
	//요청값 확인
	System.out.println(request.getParameter("currentPw") + " <--updateMemberAction param currentPw");
	System.out.println(request.getParameter("changePw") + " <--updateMemberAction param changePw");
	System.out.println(request.getParameter("confirmPw") + " <--updateMemberAction param confirmPw");
	
	//요청값 유효성 검사 : 요청값이 공백이거나 null이면 리다이렉션
	String msg = null;
	if(request.getParameter("currentPw") == null
			|| request.getParameter("currentPw").equals("")
			|| request.getParameter("changePw") == null
			|| request.getParameter("changePw").equals("")
			|| request.getParameter("confirmPw") == null
			|| request.getParameter("confirmPw").equals("")){
		msg = URLEncoder.encode("현재 비밀번호 또는 변경할 비밀번호를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/updateMemberForm.jsp?msg="+msg);
		return;
	}
	
	//요청값 변수에 저장
	String currentPw = request.getParameter("currentPw");
	String changePw = request.getParameter("changePw");
	String confirmPw = request.getParameter("confirmPw");
	//디버깅
	System.out.println(PURPLE + currentPw + " <--updateMemberAction currentPw" + RESET);
	System.out.println(PURPLE + changePw + " <--updateMemberAction changePw" + RESET);
	System.out.println(PURPLE + confirmPw + " <--updateMemberAction confirmPw" + RESET);
	
	//변경비밀번호와 확인비밀번호가 일치하지 않으면 updateMemberForm으로 리다이렉션
	if(!changePw.equals(confirmPw)){
		msg = URLEncoder.encode("변경 비밀번호를 다시 확인해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/updateMemberForm.jsp?msg="+msg);
		return;
	}
	
	//세션정보 변수에 저장 -> 쿼리문 조건에 사용할 변수
	String memberId = (String)session.getAttribute("loginMemberId"); 
	System.out.println(PURPLE + memberId + " <--updateMemberAction memberId" + RESET);
	
	//2. 모델 계층
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/*
		update member 
		set member_pw = password(?)
		where member_id = ? and member_pw = password(?) 
	*/
	String sql = "update member set member_pw = password(?) where member_id = ? and member_pw = password(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, changePw);
	stmt.setString(2, memberId); 
	stmt.setString(3, currentPw);
	//디버깅
	System.out.println(PURPLE + stmt + " <--updateMemberAction stmt" + RESET);
	
	int row = stmt.executeUpdate(); // 영향받은 행의 수를 반환한다
	System.out.println(PURPLE + row + " <--updateMemberAction row" + RESET);
	
	if(row == 1){ //변경 성공한 경우
		msg = URLEncoder.encode("비밀번호가 변경되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/updateMemberForm.jsp?msg="+msg);
	} else { //변경 실패한 경우
		msg = URLEncoder.encode("비밀번호 변경에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/member/updateMemberForm.jsp?msg="+msg);
	}
%>