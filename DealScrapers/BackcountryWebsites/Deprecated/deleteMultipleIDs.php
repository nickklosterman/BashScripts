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

//$sql="SELECT * FROM $tbl_name where contactaddress = ('$_POST[SearchAddress]') order by searchterms desc";
$sql="SELECT * FROM $tbl_name order by contactaddress desc";
$result=mysql_query($sql);

$count=mysql_num_rows($result);
$Address="$_POST[SearchAddress]";
?>
<table width="400" border="0" cellspacing="1" cellpadding="0">
<tr>
 <td><form name="form1" method="post" action="">
<table width="400" border="0" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC">
<tr>
  <td bgcolor="#FFFFFF">&nbsp;</td>
  <td colspan="4" bgcolor="#FFFFFF"><strong>Alerts for <? echo $Address; ?></strong> </td>
</tr>
<tr>
<td align="center" bgcolor="#FFFFFF">#</td>
<td align="center" bgcolor="#FFFFFF"><strong>ID</strong></td>
<td align="center" bgcolor="#FFFFFF"><strong>Search Term</strong></td>
</tr>
<?php
  while($rows=mysql_fetch_array($result)){
?>
<tr>
<td align="center" bgcolor="#FFFFFF"><input name="checkbox[]" type="checkbox" id="checkbox[]" value="<? echo $rows['prim_key']; ?>"></td>
<td bgcolor="#FFFFFF"><? echo $rows['prim_key']; ?></td>
<td bgcolor="#FFFFFF"><? echo $rows['searchterms']; ?></td>
</tr>
<?php
  }
?>
<tr>
<td colspan="5" align="center" bgcolor="#FFFFFF"><input name="delete" type="submit" id="delete" value="Delete"></td>
</tr>
<?
  // Check if delete button active, start this
  if($delete){
    for($i=0;$i<$count;$i++){
      $del_id = $checkbox[$i];
      //      $sql = "DELETE FROM $tbl_name WHERE prim_key='$del_id'";
      $sql = "DELETE FROM $tbl_name WHERE prim_key='74'";
      echo $sql;
      $result = mysql_query($sql);
    }
    
    // if successful redirect to delete_multiple.php
    if($result){
      $bob=mysql_affected_rows();
      $bobo=mysql_info();
      //      echo "<meta http-equiv=\"refresh\" content=\"0;URL=index.html\">"; //PHPQuerytodelete2.html
      echo "<meta http-equiv=\"refresh\" content=\"3;URL=PHPQuerytodelete2.html\">";
      echo "num affected rows " . $bob . " " . $bobo ;

      //      echo "<meta http-equiv=\"refresh\" content=\"5;URL=deleteMultipleIDs.php\">";
    }
  }
mysql_close();
?>
</table>
</form>
</td>
</tr>
</table>