<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Книги — Панель администратора</title>
    <link href="../media/css/styles.css" rel="stylesheet" media="all">
    <link href="../media/css/page.css" rel="stylesheet" media="all">
    <link href="../media/css/table.css" rel="stylesheet" media="all">
    <link href="../media/css/TableTools.css" rel="stylesheet" media="all">
    
    <style type="text/css">
    
        .dataTables_filter {
             display: none;
        }
 
    </style>
    
    <script type="text/javascript" src="../media/js/jquery.js"></script>
    <script type="text/javascript" src="../media/js/jquery.cookie.js"></script>
    <script type="text/javascript" src="../media/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="../media/js/TableTools.min.js"></script>
    <script type="text/javascript">
    
    var oTable;
    var asInitVals = new Array();
    
    function getBookId() {
        var table = TableTools.fnGetInstance('book_table');
        var selected = table.fnGetSelected();
        if (selected.length !== 0) {
        	return selected[0].cells[8].innerHTML;
        }
        return null;
    }
    
    function deleteBook() {
        var t = TableTools.fnGetInstance('book_table');
        var selected = t.fnGetSelected();
        var id = selected[0].cells[8].innerHTML;
        if (id.length > 0) {
            var answer = confirm("Вы действительно хотите удалить выбранную книгу?");
            if (answer) {
		        $.ajax({
		            url: 'books/' + id,
		            type: 'DELETE',
		            success: function(result) {
		                if (result == "success") {
		                    oTable.fnDeleteRow(selected);
		                }
		            }
		        });
            }
        }
    }
    
    function downloadBook() {
        var id = getBookId();
        if (id != null) {
            document.location.href="books/download/" + id + ".zip";
        }
    }
    
    function downloadDemo() {
        var id = getBookId();
        if (id != null) {
            $.ajax({
                url: 'books/check_demo/' + id,
                type: 'GET',
                success: function(result) {
                    if (result == "true") {
                    	document.location.href="books/demo/" + id + ".demo.zip";            
                    } else {
                    	alert("Демо версия выбранной книги отсутствует.")
                    }
                }
            });
            
        }
    }
    
    function updateButtons() {
        var t = TableTools.fnGetInstance('book_table');
        var selected = t.fnGetSelected();
    	if (selected.length == 0) {
            $('#edit_book').attr('disabled', 'disabled');
            $('#delete_book').attr('disabled', 'disabled');
            $('#download_book').attr('disabled', 'disabled');
            $('#download_demo').attr('disabled', 'disabled');
    	} else {
            $('#edit_book').removeAttr('disabled');
            $('#delete_book').removeAttr('disabled');
            $('#download_book').removeAttr('disabled');
            $('#download_demo').removeAttr('disabled');
    	}
    }
    
    $(document).ready(function() {

        oTable = $('#book_table').dataTable( {
            "bProcessing": true,
            "bServerSide": true,
            "aoColumnDefs" : [
                { 'bSortable': false, 'aTargets': [ 0, 8 ] }                 
             ],
            "sAjaxSource": "books/data_source",
            "sPaginationType": "full_numbers",
            "bStateSave": true, 
            "sDom": 'T<"clear">lfrtip',
            "oTableTools": {
                "aButtons": [],
                "sRowSelect": "single"
            }
        } );
        
        $("tfoot input").keyup( function () {
            oTable.fnFilter( this.value, $("tfoot input").index(this) );
            $.cookie(this.getAttribute('name'), this.value);
        } );
        
        $("tfoot input").each( function (i) {
            asInitVals[i] = this.value;
            
            var name = this.getAttribute('name');
            var cookie = $.cookie(name);
            if (cookie != null && cookie.length > 0) {
                $('input[name=' + name + ']').val(cookie);
                this.className = "";
            }

        } );
         
        $("tfoot input").focus( function () {
            if ( this.className == "search_init" )
            {
                this.className = "";
                this.value = "";
            }
        } );
         
        $("tfoot input").blur( function (i) {
            if ( this.value == "" )
            {
                this.className = "search_init";
                this.value = asInitVals[$("tfoot input").index(this)];
            }
        } );
        
        $('#add_book').click(function() {
        	document.location.href="new_book";
        });

        $('#edit_book').click(function() {
            var id = getBookId();
            if (id != null) {
                document.location.href="edit_book?id=" + id;
            }
        });
        
        $('#delete_book').click(deleteBook);
        $('#download_book').click(downloadBook);
        $('#download_demo').click(downloadDemo);
        
        $("#book_table tbody").delegate("tr", "click", updateButtons);
        
        updateButtons();
    } );
    </script>
    
</head>
<body>

<%@ include file="header.jsp" %>
<div class="content">
<h2>Книги</h2>

<input type="button" value="Добавить" id="add_book" />
<input type="button" value="Редактировать" id="edit_book" />
<input type="button" value="Удалить" id="delete_book" />
<input type="button" value="Скачать" id="download_book" />
<input type="button" value="Скачать демо" id="download_demo" />

<table id="book_table" class="display">
    <thead>
        <tr>
            <th>№</th>
            <th width="20%">Наименование</th>
            <th width="20%">Автор</th>
            <th width="20%">Категория</th>
            <th>Издательство</th>
            <th>Ценовая категория</th>
            <th width="5%">Просмотры</th>
            <th width="5%">Покупки</th>
            <th>&nbsp;</th>
        </tr>
    </thead>
    <tfoot>
        <tr>
            <th>&nbsp;</th>
            <th><input type="text" name="search_name" value="Поиск по названию" class="search_init" /></th>
            <th><input type="text" name="search_author" value="Поиск по автору" class="search_init" /></th>
            <th><input type="text" name="search_category" value="Поиск по категории" class="search_init" /></th>
            <th><input type="text" name="search_publisher" value="Поиск по издателю" class="search_init" /></th>
            <th><input type="text" name="search_price" value="Поиск по ценовой категории" class="search_init" /></th>
            <th><input type="text" name="search_views" value="Поиск по просмотрам" class="search_init" /></th>
            <th><input type="text" name="search_purchases" value="Поиск по покупкам" class="search_init" /></th>
            <th>&nbsp;</th>
        </tr>
    </tfoot>
</table>
<br />
<br />
* Просмотры — число скачиваний демо-версии книги.<br />
** Покупки — число покупок полной версии книги.

</div>
<%@ include file="footer.jsp" %>
</body>
</html>