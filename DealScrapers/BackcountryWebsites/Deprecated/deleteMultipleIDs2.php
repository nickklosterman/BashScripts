############### Code

<?php
$host="localhost"; // Host name
$username="BCA"; // Mysql username
$password="backcountryalerts"; // Mysql password
$db_name="djinnius_BackCountryAlerts"; // Database name
$tbl_name="SearchTermsAndContactAddress"; // Table name

// BCA/backcountryalerts can deletee stuff

// Connect to server and select databse.
mysql_connect("$host", "$username", "$password")or die("cannot connect");
mysql_select_db("$db_name")or die("cannot select DB");

//$sql="SELECT * FROM $tbl_name where contactaddress = ('$_POST[SearchAddress]') order by searchterms desc";
//$sql="SELECT * FROM $tbl_name order by contactaddress desc";
$sql = "DELETE FROM $tbl_name WHERE prim_key='69'";
$result=mysql_query($sql);

$bob=mysql_affected_rows();
$bobo=mysql_info();
echo $bob . " : " . $bobo ;
//$count=mysql_num_rows($result);

mysql_close();
?>
