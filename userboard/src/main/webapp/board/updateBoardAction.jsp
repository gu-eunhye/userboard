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
	System.out.println(request.getParameter("boardNo") + " <--updateBoardAction param boardNo");
	System.out.println(request.getParameter("localName") + " <--updateBoardAction param localName");
	System.out.println(request.getParameter("boardTitle") + " <--updateBoardAction param boardTitle");
	System.out.println(request.getParameter("boardContent") + " <--updateBoardAction param boardContent");
	
	//요청값 유효성 검사 : 요청값이 공백이거나 null이면 리다이렉션
	String msg = null;
	if(request.getParameter("boardNo") == null 
			|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	if(request.getParameter("localName") == null
			|| request.getParameter("localName").equals("")
			|| request.getParameter("boardTitle") == null
			|| request.getParameter("boardTitle").equals("")
			|| request.getParameter("boardContent") == null
			|| request.getParameter("boardContent").equals("")){
		msg = URLEncoder.encode("정보를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/board/updateBoard.jsp?msg="+msg+"&boardNo="+URLEncoder.encode(request.getParameter("boardNo"), "utf-8"));
		return;
	}
	
	//요청값 변수에 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	
	//디버깅
	System.out.println(PURPLE + boardNo + " <--updateBoardAction boardNo" + RESET);
	System.out.println(PURPLE + localName + " <--updateBoardAction localName" + RESET);
	System.out.println(PURPLE + boardTitle + " <--updateBoardAction boardTitle" + RESET);
	System.out.println(PURPLE + boardContent + " <--updateBoardAction boardContent" + RESET);
	
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	/* 수정쿼리 
		update board 
		set local_name = ?, board_title = ?, board_content = ?, updatedate = now()
		where board_no = ? 
	*/
	String sql = "UPDATE board SET local_name = ?, board_title = ?, board_content = ?, updatedate = now() WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	stmt.setString(2, boardTitle);
	stmt.setString(3, boardContent);
	stmt.setInt(4, boardNo);
	
	System.out.println(PURPLE + stmt + " <--updateBoardAction stmt" + RESET);
	
	int row = stmt.executeUpdate();
	System.out.println(PURPLE + row + " <--updateBoardAction row" + RESET);
	
	if(row == 1){ 
		msg = URLEncoder.encode("게시글이 수정되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/board/boardOne.jsp?msg="+msg+"&boardNo="+URLEncoder.encode(request.getParameter("boardNo"), "utf-8"));
	} else { 
		msg = URLEncoder.encode("게시글 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+ "/board/boardOne.jsp?msg="+msg+"&boardNo="+URLEncoder.encode(request.getParameter("boardNo"), "utf-8"));
	}
%>