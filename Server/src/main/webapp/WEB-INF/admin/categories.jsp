<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Жанры и категории — Панель администратора</title>
    <link href="../media/css/styles.css" rel="stylesheet" media="all">
    <script type="text/javascript" src="../media/js/jquery.js"></script>
    <script type="text/javascript">
    
    function genreAccept() {
    	$('.error_block').hide();
        var id = $('#genres').val();
        var name = $('#genre_name').val();
        $.ajax({
            url: 'categories/' + id,
            type: 'POST',
            data: {
                'name': name
            },
            success: function(result) {
                var category = eval(result);
                if (!(category instanceof Document)) {
                    var index = $('#genres option:selected ').prop('index');
                    if ($('#genres').val() === "new") {
                        $("#genres option").eq(index).before(
                                $("<option></option>")
                              .val(category.id)
                              .text(category.name));
                    } else {
                        $("#genres option:selected")
                            .val(category.id)
                            .text(category.name);                     
                    }
                }
           }
        });
    }
    
    function genreReject() {
    	$('.error_block').hide();
        var answer = confirm("Вы действительно хотите удалить выбранный жанр?");
        if (answer) {
        	var id = $('#genres').val();
	        $.ajax({
	            url: 'categories/' + id,
	            type: 'DELETE',
	            success: function(result) {
                    if (result === "success") {
                        $("#genres option:selected").remove();
                        $('#genres option:last-child').attr('selected', 'selected');
                        $('#genre_name').val('');
                        updateUi();
                    }
	           }
	        });
        }
    }
    
    function categoryAccept() {
    	$('.error_block').hide();
    	var genreId = $('#genres').val();
        var id = $('#categories').val();
        var name = $('#category_name').val();
        $.ajax({
            url: 'categories/' + id,
            type: 'POST',
            data: {
                'parentId': genreId,
                'name': name
            },
            success: function(result) {
                var category = eval(result);
                if (!(category instanceof Document)) {
                    var index = $('#categories option:selected ').prop('index');
                    if ($('#categories').val() === "new") {
                        $("#categories option").eq(index).before(
                                $("<option></option>")
                              .val(category.id)
                              .text(category.name));
                    } else {
                        $("#categories option:selected")
                            .val(category.id)
                            .text(category.name);
                    }
                }
           }
        });
    }
    
    function categoryReject() {
    	$('.error_block').hide();
        var answer = confirm("Вы действительно хотите удалить выбранную категорию?");
        if (answer) {
            var id = $('#categories').val();
            $.ajax({
                url: 'categories/' + id,
                type: 'DELETE',
                success: function(result) {
                    if (result === "success") {
                        $("#categories option:selected").remove();
                        $('#category_name').val('');
                        $('#categories option:last-child').attr('selected', 'selected');
                        updateUi();
                    }
               },
               error: function(result) {
            	   $('.error_block').show();
               }
            });
        }
    }
    
    function onGenreChanged() {
    	var id = $('#genres').val();
    	if (id === "new") {
    		$('#categories').find('option').remove();
    		$('#genre_name').val('');
    		updateUi();
    	} else {
    		if (id !== 'none') {
    			$('#genre_name').val($("#genres option:selected").text());
    		} else {
    			$('#genre_name').val('');
    		}
    		requestCategories(id);
    	}
    }
    
    function requestCategories(genreId) {
        $.ajax({
            url: 'categories/' + genreId + '/',
            type: 'GET',
            success: function(result) {
                var list = eval(result);
                $('#categories').find('option').remove();
                for (var i = 0; i < list.length; i++) {
                    var id = list[i].id;
                    var name = list[i].name;
                    $('#categories').append($("<option></option>").attr("value", id).text(name));
                    
                }
                $('#categories').append($("<option></option>").attr("value", "new").text("[Новая категория]"));
                $('#categories option:last-child').attr('selected', 'selected');
                $('#category_name').val('');
                updateUi();
           }
        });
    }
    
    function onCategoryChanged() {
    	var id = $('#categories').val();
    	if (id === "new") {
    		$('#category_name').val('');
    	} else {
    		$('#category_name').val($('#categories option:selected').text());
    	}
    	updateUi();
    }
    
    function updateUi() {
        var genreId = $('#genres').val();

       	if (genreId === "new") {
               $('#genre_name').removeAttr("disabled");
               $('#genre_reject').attr("disabled", "disabled");
               $('#genre_accept').attr("disabled", "disabled");
               $('#categories').find('option').remove();
               $('#categories').attr("disabled", "disabled");
               $('#category_reject').attr("disabled", "disabled");
               $('#category_accept').attr("disabled", "disabled");
               $('#category_name').attr("disabled", "disabled");
       	} else {
            if ($('#genre_name').attr('disabled') === 'disabled') {
                $('#genre_name').removeAttr("disabled");
             }

       		if (genreId === "none") {
                   $('#genre_reject').attr("disabled", "disabled");
                   $('#genre_accept').attr("disabled", "disabled");
       		} else {
                   if ($('#categories option').size() > 1) {
                	   $('#genre_reject').attr("disabled", "disabled");
                   } else {
                	   $('#genre_reject').removeAttr("disabled");   
                   }
       		}
       		$('#categories').removeAttr("disabled");
       		if ($('#category_name').attr('disabled') === 'disabled') {
       		   $('#category_name').removeAttr("disabled");
       		}
       	}
       	
       	var categoryId = $('#categories').val();
       	if (categoryId === 'new' || categoryId === null) {
       		$('#category_reject').attr("disabled", "disabled");
       	} else {
       		$('#category_reject').removeAttr("disabled");
       	}
       	
       	var genreName = $('#genre_name').val();
       	if (genreName.length == 0) {
       		$('#genre_accept').attr("disabled", "disabled");
       	} else {
       		$('#genre_accept').removeAttr("disabled");
       	}
       	
       	var categoryName = $('#category_name').val();
           if (categoryName.length == 0) {
               $('#category_accept').attr("disabled", "disabled");
           } else {
               $('#category_accept').removeAttr("disabled");
           }

    }
    
    $(document).ready(function() {
        
        $("#genre_accept").click(genreAccept);
        $("#genre_reject").click(genreReject);
        $("#category_accept").click(categoryAccept);
        $("#category_reject").click(categoryReject);
        $("#genres").change(onGenreChanged);
        $("#categories").change(onCategoryChanged);
        
        $('#genre_name').bind("keyup input paste", updateUi);
        $('#category_name').bind("keyup input paste", updateUi);
        
        $('#genres option:last-child').attr('selected', 'selected');
        updateUi();
    });
    
    </script>
    
</head>
<body>

<%@ include file="header.jsp" %>

<div class="content">

<h2>Жанры и категории</h2>

<div class="error_block" style="display:none">
    Невозможно удалить категорию, в которой присутствуют книги.<br />
    Только пустая категория может быть удалена.
</div>

<table>
    <tr>
        <td width="350"><b>Жанры</b></td>
        <td width="350"><b>Категории</b></td>
    </tr>
    <tr>
        <td>
            <select name="genres" size="18" id="genres" style="width:330px">
                <option value="none">[Без жанра]</option>
            <c:forEach items="${genres}" var="genre">
                <option value="<c:out value="${genre.id}" />"><c:out value="${genre.name}" /></option>
            </c:forEach>
                <option value="new">[Новый жанр]</option>
            </select>
        </td>
        <td>
            <select name="categories" size="18" id="categories" style="width:330px">
            </select>
        </td>    
    </tr>
    <tr>
        <td>
            <input type="text" id="genre_name" maxlength="254" />
            <input type="button" id="genre_accept" value="Сохранить" />
            <input type="button" id="genre_reject" value="Удалить" />
        </td>
        <td>
            <input type="text" id="category_name" maxlength="254" />
            <input type="button" id="category_accept" value="Сохранить" />
            <input type="button" id="category_reject" value="Удалить" />
        </td>
    </tr>
</table>

</div>

<%@ include file="footer.jsp" %>
</body>
</html>