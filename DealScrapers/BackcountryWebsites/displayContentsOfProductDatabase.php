############### Code

<?php
$host="localhost"; // Host name
$username="BCA"; // Mysql username
$password="backcountryalerts"; // Mysql password
$db_name="djinnius_BackCountryAlerts"; // Database name
$tbl_name="Backcountrydeals"; // Table name

// Connect to server and select databse.
mysql_connect("$host", "$username", "$password")or die("cannot connect");
mysql_select_db("$db_name")or die("cannot select DB");

$sql = 'SELECT * FROM `'.$tbl_name.'`  ORDER BY product ASC';

$result=mysql_query($sql);
$count=mysql_num_rows($result);

?>
<html>
<body>


<table border="0" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC">
<tr>
  <td bgcolor="#FFFFFF">&nbsp;</td>
<td colspan="8" bgcolor="#FFFFFF"><strong>Product Database Contents</strong> </td>
</tr>
<tr>
<td align="center" bgcolor="#FFFFFF"><strong>Key</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Website</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Product</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Price</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Percent off MSRP</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Quantity </strong></td>
  <td align="center" bgcolor="#FFFFFF"><strong>Deal Duration (minutes)</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Time Deal Appeared</strong></td>
</tr>
<?php
  while($rows=mysql_fetch_array($result)){
    switch ($rows['websiteCode'])
      {
      case 0:
      $WebsiteCode="SC";
      break;
      case 1:
      $WebsiteCode="WM";
      break;
      case 2:
      $WebsiteCode="BT";
      break;
      case 3:
      $WebsiteCode="CL";
      break;
      }
?>
<tr>
<td bgcolor="#FFFFFF"><? echo $rows['Bkey']; ?></td>
<td bgcolor="#FFFFFF"><? echo $WebsiteCode; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['product']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['price']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['percentOffMSRP']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['quantity']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['dealdurationinminutes']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['timeEnter']; ?></td>

</tr>
<?php
  }
?>

<?
mysql_close();
?>

</table>
</body>
</html>