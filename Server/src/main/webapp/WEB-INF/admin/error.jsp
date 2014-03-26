<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Ошибка — Панель администратора</title>
    <link href="../media/css/styles.css" rel="stylesheet" media="all">
    <script type="text/javascript">
    
    </script>
    
</head>
<body>

<%@ include file="header.jsp" %>

<div class="content">
<h2>Ошибка</h2>

<div class="error_block">
    <c:out value="${msg}" />
</div>

<h2>Причина</h2>
<div class="stack_trace">
<c:forEach items="${ex.stackTrace}" var="element">
    <c:out value="${element}" /><br />
</c:forEach>
</div>

</div>

<%@ include file="footer.jsp" %>
</body>
</html>