<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Ценовые категории — Панель администратора</title>
    <link href="../media/css/styles.css" rel="stylesheet" media="all">
    <script type="text/javascript" src="../media/js/jquery.js"></script>
    
    <script type="text/javascript">
    
    function onSaveClicked() {
    	$('.error_block').hide();
        var id = $('#categories').val();
        var price = $('#price').val();
        var name = $('#name').val();
        $.ajax({
            url: 'prices/' + id,
            type: 'POST',
            data: {
                'name': name,
                'price': price
            },
            success: function(result) {
            	var category = eval(result);
                if (!(category instanceof Document)) {
                	var index = $('#categories option:selected ').prop('index');
                	if ($('#categories').val() === "new") {
                		$("#categories option").eq(index).before(
                				$("<option></option>")
	                		  .val(category.id)
	                		  .text(category.name + " ($" + category.price + ")")
	                		  .attr('name', category.name)
	                		  .attr('price', category.price));
                	} else {
                        $("#categories option:selected")
	                        .val(category.id)
	                        .text(category.name + " ($" + category.price + ")")
	                        .attr('name', category.name)
	                        .attr('price', category.price);                		
                	}
                }
           }
        });
    }
    
    function onDeleteClicked() {
    	$('.error_block').hide();
        var answer = confirm("Вы действительно хотите удалить выбранную категорию?");
        if (answer) {
            var id = $('#categories').val();
            $.ajax({
                url: 'prices/' + id,
                type: 'DELETE',
                success: function(result) {
                    if (result === "success") {
                    	$("#categories option:selected").remove();
                    	$('#price').val('');
                    	$('#name').val('');
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
    
    function updateUi() {
    	var id = $('#categories').val();
    	if (id === null) {
    		$('#delCat').attr("disabled", "disabled");
    		$('#saveCat').attr("disabled", "disabled");
    	} else {
            if (id === 'new') {
                $('#delCat').attr("disabled", "disabled");
            } else {
            	$('#delCat').removeAttr("disabled");
            }
            var name = $('#name').val();
            var price = $('#price').val();
            var enabled = name.length > 0 && price.length > 0;
            if (price[0]=='.' || price[price.length - 1] == '.') {
            	enabled = false;
            }
            if (enabled) {
                $('#saveCat').removeAttr("disabled");
            } else {
                $('#saveCat').attr("disabled", "disabled");
            }            
    	}
    }
    
    function onCategoryChanged() {
    	var id = $('#categories').val();
    	if (id === 'new') {
    		 $('#name').val('');
    		 $('#price').val('');
    	} else {
            $('#name').val($('#categories option:selected').attr('name'));
            $('#price').val($('#categories option:selected ').attr('price'));
    	}
    	updateUi();
    }
    
    function checkPrice(evt) {
        var theEvent = evt || window.event;
        if (theEvent.charCode !== 0) {
            var key = theEvent.keyCode || theEvent.which;
            key = String.fromCharCode( key );
            var regex = /[0-9]/;
            if (!regex.test(key) && !(key == '.' && $('#price').val().indexOf('.') == -1)) {
                  theEvent.returnValue = false;
                  if (theEvent.preventDefault) {
                	  theEvent.preventDefault();
                  }
            }
        }
    }
    
    $(document).ready(function() {
        $("#delCat").click(onDeleteClicked);
        $("#saveCat").click(onSaveClicked);
        $("#categories").change(onCategoryChanged);
        
        $('#name').bind("keyup input paste", updateUi);
        $('#price').bind("keyup input paste", updateUi);
        
        $('#categories option:last-child').attr('selected', 'selected');
        updateUi();
    });
    
    </script>
    
</head>
<body>

<%@ include file="header.jsp" %>

<div class="content">

<h2>Ценовые категории</h2>

<div class="error_block" style="display:none">
    Невозможно удалить ценовую категорию, которая указана хотя бы у одной книги.<br />
    Только неиспользуемая категория может быть удалена.
</div>

<table>
	<tr>
	   <td width="250"><b>Ценовые категории</b></td>
	   <td width="250"><b>Добавить категорию</b></td>
	</tr>
    <tr>
       <td>
            <select name="categories" id="categories" size="10" style="width: 230px">
            <c:forEach items="${categories}" var="category">
                <option value="<c:out value="${category.id}" />" 
                    price="<c:out value="${category.price}" />"
                    name="<c:out value="${category.name}" />">
                    
                    <c:out value="${category.name}" /> ($<c:out value="${category.price}" />)
                    
                    </option>
            </c:forEach>
                <option value="new">[Новая категория]</option>
            </select>
       </td>
       <td>
            <table>
                <tr>
                    <td>Идентификатор</td>
                    <td><input type="text" id="name" maxlength="254" /></td>
                </tr>
                <tr>
                    <td>Цена, $</td>
                    <td><input type="text" id="price"  maxlength="7" onkeypress='checkPrice(event)'  /></td>
                </tr>
            </table>
       </td>
    </tr>
    <tr>
        <td>
            <input type="button" id="delCat" value="Удалить" />
        </td>
        <td>
            <input type="button" id="saveCat" value="Сохранить" />
        </td>
    </tr>
</table>

</div>

<%@ include file="footer.jsp" %>
</body>
</html>