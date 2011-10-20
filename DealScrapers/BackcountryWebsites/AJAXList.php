<?php
$host="localhost"; // Host name                                                                                                                                           
$username="BCA"; // Mysql username                                                                                                                                        
$password="backcountryalerts"; // Mysql password                                                                                                                          
$db_name="djinnius_BackCountryAlerts"; // Database name                                                                                                                   
$tbl_name="Backcountrydeals"; // Table name                                                                                                                               

// Connect to server and select databse.                                                                                                                                  
$con=mysql_connect("$host", "$username", "$password")or die("cannot connect");
if (!$con)
  {
    die('Could not connect'.mysql_error());
  }
else
  {
    mysql_select_db("$db_name")or die("cannot select DB");

    $sql = 'SELECT product,ProductEntrykey FROM BackcountryProducts ORDER BY product ASC';
    $result=mysql_query($sql);


    ?>

<html>
<head>
<script type="text/javascript">

   function showProductInfo(str)
   {
     if (str=="")
       {
	 document.getElementById("txtHint").innerHTML="";
	 return;
       }
     if (window.XMLHttpRequest)
       {// code for IE7+, Firefox, Chrome, Opera, Safari
	 xmlhttp=new XMLHttpRequest();
       }
else
  {// code for IE6, IE5
    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
     xmlhttp.onreadystatechange=function()
     {
       if (xmlhttp.readyState==4 && xmlhttp.status==200)
	 {
	   document.getElementById("txtHint").innerHTML=xmlhttp.responseText;
	 }
     }
     xmlhttp.open("GET","getproductinfo.php?q="+str,true);
     xmlhttp.send();
   }

</script>
</head>
<body>
<form>
<select name="product" onchange="showProductInfo(this.value)">
<option value="">Select a product:</option>
 <?php
    while($rows=mysql_fetch_array($result)){
      echo "<option value=\"" .  $rows['ProductEntrykey'] . " \">" .  $rows['product'] . " </option> \n";
    }
    mysql_close();
  }
 ?>
</select>
</form>
<br />
<div id="txtHint"><b>Product info will be listed below.</b></div>

</body>
</html> 