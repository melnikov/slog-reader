<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>
<c:choose>
    <c:when test="${book!=null}">
        Редактировать книгу — Панель администратора
    </c:when>
    <c:otherwise>
        Добавить книгу — Панель администратора
    </c:otherwise>
</c:choose>
     </title>
    <link href="../media/css/styles.css" rel="stylesheet" media="all">
    <script type="text/javascript" src="../media/js/jquery.js"></script>

    <script type="text/javascript">

    var init = false;
    var currentGenre = "<c:out value="${book.category.parent.id}" />";
    var currentCategory = "<c:out value="${book.category.id}" />";
    var currentPrice = "<c:out value="${book.price.id}" />";
    
    function requestGenres() {
        $.ajax({
            url: 'books/genres',
            type: 'GET',
            success: function(result) {
            	for (var i = 0; i < result.length; i++) {
            	    $('#genres').append($("<option></option>").attr("value", result[i].id).text(result[i].name));
            	}
                if (currentCategory !== '') {
                    $('#genres').val(currentGenre);
                    init = true;
                    onGenreChanged();
                }
           }
        });
    }
    
    function onGenreChanged() {
    	$('#categories').find('option').remove();
        $.ajax({
            url: 'books/genres/' + $('#genres').val(),
            type: 'GET',
            success: function(result) {
                for (var i = 0; i < result.length; i++) {
                    $('#categories').append($("<option></option>").attr("value", result[i].id).text(result[i].name));
                }
                if (init) {
                	init = false;
                    if (currentCategory !== '') {
                        $('#categories').val(currentCategory);
                    }
                    $("#genres").change(onGenreChanged);
                }
                checkForm();
           }
        });
    }
    
    function checkForm() {
    	
    	var enable = $('#bookName').val().length > 0 && 
    	   $('#authors').val().length > 0 &&
    	   $('#genres').val() != null &&
    	   $('#categories').val() != null &&
    	   $('#publisher').val().length > 0 &&
    	   $('#priceCategories').val().length > 0 &&
    	   $('#description').val().length > 0 &&
    	   $('#duration').val().length > 0;
    	   
    	   if (currentCategory === '') {
    		   enable = enable && 
                $('#file').val() != '' &&
                $('#cover').val() != '';
    	   }
    	   
    	if (enable) {
    		$(':submit').removeAttr('disabled');
    	} else {
    	    $(':submit').attr('disabled', 'disabled');
    	}
    }
    
    function deleteDemo() {
        var answer = confirm("Вы действительно хотите удалить демо-версию книги?");
        if (answer) {
            $.ajax({
                url: 'books/demo/' + $('#id').val(),
                type: 'DELETE',
                success: function(result) {
                	$('#demoblock').hide();
               }
            });
        }
    }
    
    function checkDuration(evt) {
		var theEvent = evt || window.event;
		if (theEvent.charCode !== 0) {
			var key = theEvent.keyCode || theEvent.which;
			key = String.fromCharCode( key );
			var regex = /[0-9]/;
			if( !regex.test(key) ) {
				  theEvent.returnValue = false;
				  if(theEvent.preventDefault) theEvent.preventDefault();
			}
		}
    }
    
    $(document).ready(function() {
    	requestGenres();
    	
    	if (currentCategory === '') {
    		$("#genres").change(onGenreChanged);
    		onGenreChanged();
    	}
    	
    	$('#bookName').bind("keyup input paste", checkForm);
    	$('#authors').bind("keyup input paste", checkForm);
    	$('#publisher').bind("keyup input paste", checkForm);
    	$('#priceCategories').bind("keyup input paste", checkForm);
    	$('#duration').bind("keyup input paste", checkForm);
    	$('#description').bind("keyup input paste", checkForm);
    	$('#file').change(checkForm);
    	$('#cover').change(checkForm);
    	
        if (currentPrice !== '') {
            $('#priceCategories').val(currentPrice);
        }
        
        $('#file').change(function() {
        	var fileName = $(this).val().toLowerCase();
        	var suffix = "fb2";
        	if (fileName.indexOf(suffix, fileName.length - suffix.length) === -1) {
        		$('#file').val('');
        		alert('Только файл в формате fb2 может быть выбран');
        	}
        });

        $('#demo').change(function() {
            var fileName = $(this).val().toLowerCase();
            var suffix = "fb2";
            if (fileName.indexOf(suffix, fileName.length - suffix.length) === -1) {
                $('#demo').val('');
                alert('Только файл в формате fb2 может быть выбран');
            }
        });
        
        $('#cover').change(function() {
            var fileName = $(this).val().toLowerCase();
            var suffixes = ["gif", "jpg", "jpeg", "png"];
            var allow = false;
            for (var i = 0; i < suffixes.length; i++) {
            	var suffix = suffixes[i];
                if (fileName.indexOf(suffix, fileName.length - suffix.length) !== -1) {
                	allow = true;
                	break;
                }
            }
            
            if (!allow) {
                $('#cover').val('');
                alert('В качестве обложки можно использовать только файлы jpg, jpeg, png или gif.');
            }
        });
        
    	checkForm();
    });
    
    </script>
    
</head>
<body>

<%@ include file="header.jsp" %>
<div class="content">

<c:choose>
    <c:when test="${book!=null}">
        <h2>Редактировать книгу</h2>
    </c:when>
    <c:otherwise>
        <h2>Добавить книгу</h2>
    </c:otherwise>
</c:choose>




<form method="POST" enctype="multipart/form-data" accept-charset="UTF-8" id="add_book_form">
    <input type="hidden" name="id" id="id" value="<c:out value="${book.id}" />" />
    <table>
        <tr>
            <td>Наименование</td>
            <td>
               <input type="text" name="name" value="<c:out value="${book.name}" />" id="bookName" maxlength="254" />
            </td>
        </tr>
        <tr>
            <td>Жанр</td>
            <td>
               <select name="genre" id="genres">
                   <option value="none">[Без жанра]</option>
               </select>
            </td>
        </tr>
        <tr>
            <td>Категория</td>
            <td>
               <select name="category" id="categories">
               </select>
            </td>
        </tr>
        <tr>
            <td>Автор</td>
            <td>
               <input type="text" name="authors" value="<c:out value="${book.authors}" />" id="authors" maxlength="254" />
            </td>
        </tr>
        <tr>
            <td>Ценовая категория</td>
            <td>
            <select name="priceCategory" id="priceCategories">
            <c:forEach items="${priceCategories}" var="category">
                <option value="<c:out value="${category.id}" />"><c:out value="${category.name}" /> ($<c:out value="${category.price}" />)</option>
            </c:forEach>
            </select>
            </td>
        </tr>
        <tr>
            <td>Издатель</td>
            <td>
               <input type="text" name="publisher" value="<c:out value="${book.publisher}" />" id="publisher" maxlength="254" />
            </td>
        </tr>
        <tr>
            <td>Время чтения (в часах)</td>
            <td>
               <input type="text" name="duration" value="<c:out value="${book.duration}" />" id="duration" maxlength="8" onkeypress='checkDuration(event)'  />
            </td>
        </tr>
        <tr>
            <td>Аннотация<br/>(не более 10.000 символов)</td>
            <td>
               <textarea name="description" rows="10" cols="50" id="description" maxlength="10000"><c:out value="${book.description}" /></textarea>
            </td>
        </tr>

        <tr>
            <td>Публикация (fb2):</td>
            <td>
               <input type="file" name="file" id="file"/>
            </td>
        </tr>
        <tr>
            <td>Демо-версия (fb2):</td>
            <td>
               <input type="file" name="demo" id="demo"/>
               <c:choose>
                <c:when test="${book!=null}">
                    <c:if test="${demoExists}"><span id="demoblock">— <a href="#" onclick="deleteDemo(); return false;" >Удалить демо</a></span></c:if>
                </c:when>
               </c:choose>
            </td>
        </tr>
        <tr>
            <td>Обложка</td>
            <td>
               <input type="file" name="cover" id="cover" />
            </td>
        </tr>
    </table>
    <input type="submit" value="Сохранить" />
</form>


<br />
<c:choose>
	<c:when test="${book!=null}">
		* — Все поля формы, за исключением файлов публикации, демо-версии и обложки, являются обязательными для заполнения.<br />
		* — Если файл публикации, демо-версии или обложки не выбран, то он существующий файл не будет изменён.
	</c:when>
	<c:otherwise>
		* — Все поля формы, за исключением демо-версии книги, являются обязательными для заполнения.
	</c:otherwise>
</c:choose>

</div>
<%@ include file="footer.jsp" %>
</body>
</html>