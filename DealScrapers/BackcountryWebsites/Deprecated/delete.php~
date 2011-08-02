
<html>

<?php
 //mysql connection here
$host="localhost"; // Host name                                                                                              
$username="BCA"; // Mysql username                                                                           
$password="backcountryalerts"; // Mysql password                                                                                    
$db_name="djinnius_BackCountryAlerts"; // Database name                                                                                          
$tbl_name="SearchTermsAndContactAddress"; // Table name                                                                                 
// Connect to server and select databse.                                                                                                                     
mysql_connect("$host", "$username", "$password")or die("cannot connect");
mysql_select_db("$db_name")or die("cannot select DB");
 

if($_POST['delete']) // from button name="delete"
{
  $checkbox = $_POST['checkbox']; //from name="checkbox[]"
  $countCheck = count($_POST['checkbox']);

  for($i=0;$i<$countCheck;$i++)
  {
  $del_id = $checkbox[$i];
  $sql = "delete from $tbl_name where prim_key = $del_id";
  $result = mysql_query($sql);
  }
  if($result)
  {
  echo "successful delete";
  }
else
  {
  echo "Error: ".mysql_error();
  }
  }
mysql_close();
?>
</html>