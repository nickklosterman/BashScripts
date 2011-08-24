############### Code

<?php
$host="localhost"; // Host name
$username="BCA"; // Mysql username
$password="backcountryalerts"; // Mysql password
$db_name="djinnius_BackCountryAlerts"; // Database name
$tbl_name="SearchTermsAndContactAddress"; // Table name

// Connect to server and select databse.
mysql_connect("$host", "$username", "$password")or die("cannot connect");
mysql_select_db("$db_name")or die("cannot select DB");

$sql = 'SELECT * FROM `'.$tbl_name.'` WHERE contactaddress = \''.mysql_real_escape_string($_POST['SearchAddress']).'\' ORDER BY searchterms ASC';

$result=mysql_query($sql);
$count=mysql_num_rows($result);

?>
<html>
<body>
To delete an unwanted alert simply tick the checkbox in the far left column and click the delete button at the bottom of the page.
<form method="post" action="delete_checkboxed_items.php">
<table width="400" border="0" cellspacing="1" cellpadding="0">
<tr>
<td><form name="form1" method="post" action="">
<table width="400" border="0" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC">
<tr>
  <td bgcolor="#FFFFFF">&nbsp;</td>
<td colspan="4" bgcolor="#FFFFFF"><strong>Your Alerts</strong> </td>
</tr>
<tr>
<td align="center" bgcolor="#FFFFFF"><strong>Delete?<strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Id</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Search Term</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Address</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Attach Image</strong></td>
</tr>
<?php
  while($rows=mysql_fetch_array($result)){
?>
<tr>
<td align="center" bgcolor="#FFFFFF"><input name="checkbox[]" type="checkbox" id="checkbox[]" value="<? echo $rows['prim_key']; ?>"></td>
<td bgcolor="#FFFFFF"><? echo $rows['prim_key']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['searchterms']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['contactaddress']; ?></td>
<? 
$IA="no";
if ($rows['ImageAttachment']==1)
{
  $IA="yes";
}

?>
<td bgcolor="#FFFFFF"><? echo $IA; ?></td>
</tr>
<?php
  }
?>
<tr>
<td colspan="5" align="center" bgcolor="#FFFFFF"><input name="delete" type="submit" id="delete" value="Delete"></td>
</tr>

</form>

<?
mysql_close();
?>
</table>
</form>
</td>
</tr>
</table>
</body>
</html>