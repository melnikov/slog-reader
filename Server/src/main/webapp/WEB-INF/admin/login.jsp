<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <link href="../media/css/styles.css" rel="stylesheet" media="all">
    <title>Вход — Панель администратора</title>
</head>
<body>

<div id="horizon">
<div id="login_content">
<form action="j_spring_security_check" method="POST">
<table>
    <tr>
        <td colspan="2" align="right"><b>Выполните вход</b></td>
    </tr>        
    <tr>
        <td>Логин</td>
        <td><input type="text" name="j_username" /></td>
    </tr>
    <tr>
        <td>Пароль</td>
        <td><input type="password" name="j_password" /></td>
    </tr>
    <tr>
        <td colspan="2" align="right"><input type="submit" value="Войти" /></td>
    </tr>        
</table>
    
</form>
</div>
</div>

</body>
</html>