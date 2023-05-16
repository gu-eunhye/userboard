<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	/*
		SELECT local_name localName, '대한민국' conuntry,'박성환' worker 
		FROM local 
		LIMIT 0, 1
	*/
	String sql = "SELECT local_name localName, '대한민국' conuntry,'박성환' worker FROM local LIMIT 0, 1";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs1 = stmt.executeQuery();
	
	//VO대신 HashMap타입을 사용 **************************************************************
	HashMap<String, Object> map = null;
	if(rs1.next()) {
		// 디버깅
		// System.out.println(rs.getString("localName"));
		// System.out.println(rs.getString("conuntry"));
		// System.out.println(rs.getString("worker"));
		map = new HashMap<String, Object>();
		map.put("localName", rs1.getString("localName")); // map.put(키이름, 값)
		map.put("conuntry", rs1.getString("conuntry"));
		map.put("worker", rs1.getString("worker"));
	}
	//디버깅
	System.out.println((String)map.get("localName"));
	System.out.println((String)map.get("conuntry"));
	System.out.println((String)map.get("worker"));
	
	
	String sql2 = "SELECT local_name localName, '대한민국' conuntry,'박성환' worker FROM local";
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	ResultSet rs2 = stmt2.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs2.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", rs2.getString("localName")); // map.put(키이름, 값)
		m.put("conuntry", rs2.getString("conuntry"));
		m.put("worker", rs2.getString("worker"));
		list.add(m);
	}
	
	
    // group by : 특정 컬럼값을 기준으로 행값의 집합을 만들어 집계함수(sum,avg,count,...)를 사용하는 sql명령어  
	String sql3 = "SELECT local_name localName, COUNT(local_name) cnt FROM board GROUP BY local_name";
	PreparedStatement stmt3 = conn.prepareStatement(sql3);
	ResultSet rs3 = stmt3.executeQuery();
	ArrayList<HashMap<String, Object>> list3 = new ArrayList<HashMap<String, Object>>();
	while(rs3.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", rs3.getString("localName")); // map.put(키이름, 값)
		m.put("cnt", rs3.getInt("cnt"));
		list3.add(m);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>localListByMap.jsp</title>
</head>
<body>
	<div>
		<h2>rs1 결과셋</h2>
		<%=map.get("localName")%>
		<%=map.get("conuntry")%>
		<%=map.get("worker")%>
	</div>

	<hr>
	<h2>rs2 결과셋</h2>
	<table>
		<tr>
			<th>localName</th>
			<th>conuntry</th>
			<th>worker</th>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=m.get("localName")%></td>
					<td><%=m.get("conuntry")%></td>
					<td><%=m.get("worker")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	
	<hr>
	<h2>rs3 결과셋</h2>
	<ul>
		<%
			for(HashMap<String, Object> m : list3) {
		%>
				<li>
					<a href="">
						<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)
					</a>
				</li>
		<%		
			}
		%>
	</ul>
</body>
</html>