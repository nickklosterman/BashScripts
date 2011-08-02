############### Code

<?php
$host="localhost"; // Host name
$username="BCA"; // Mysql username
$password="backcountryalerts"; // Mysql password
$db_name="djinnius_BackCountryAlerts"; // Database name
$tbl_name="SearchTermsAndContactAddress"; // Table name
//this works with SearchTermsAndContactAddress2 which is MyISAM
// Connect to server and select databse.
mysql_connect("$host", "$username", "$password")or die("cannot connect");
mysql_select_db("$db_name")or die("cannot select DB");
$address=mysql_real_escape_string($_POST['SearchAddress']);
$sql=sprintf( "SELECT * FROM $tbl_name WHERE contactaddress = '5079909052@tmomail.net' ORDER BY searchterms ASC"); //this does work
//$sql=sprintf( "SELECT * FROM $tbl_name WHERE contactaddress = '$address' ORDER BY searchterms ASC");
//$sql=sprintf( "SELECT * FROM $tbl_name WHERE contactaddress = '%s' ORDER BY searchterms DESC", mysql_real_escape_string($_POST['SearchAddress']) ); //this doesn't work either
echo $sql;
//$sql=sprintf( "SELECT * FROM $tbl_name WHERE contactaddress = '$_POST[SearchAddress]' ORDER BY searchterms DESC" ); // it doesn't work with this query
echo $sql;
//#$sql=sprintf( "SELECT * FROM $tbl_name  ORDER BY searchterms DESC" ); //it does work with this query 
echo $sql;
$result=mysql_query($sql);
$count=mysql_num_rows($result);

?>
<table width="400" border="0" cellspacing="1" cellpadding="0">
<tr>
<td><form name="form1" method="post" action="">
<table width="400" border="0" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC">
<tr>
  <td bgcolor="#FFFFFF">&nbsp;</td>
<td colspan="4" bgcolor="#FFFFFF"><strong>Delete multiple rows in mysql</strong> </td>
</tr>
<tr>
<td align="center" bgcolor="#FFFFFF">#</td>
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
<td bgcolor="#FFFFFF"><? echo $rows['ImageAttachment']; ?></td>
</tr>
<?php
  }
?>
<tr>
<td colspan="5" align="center" bgcolor="#FFFFFF"><input name="delete" type="submit" id="delete" value="Delete"></td>
</tr>
<?
  //try closing and starting a new connection
  /*  mysql_close();
mysql_connect("$host", "$username", "$password")or die("cannot connect");
mysql_select_db("$db_name")or die("cannot select DB"); // yeah this didn't work */

  // Check if delete button active, start this
  if($delete){
    for($i=0;$i<$count;$i++){
      $del_id = $checkbox[$i];
      $sql = "DELETE FROM $tbl_name WHERE prim_key='$del_id'";
      //      $sql = "SELECT COUNT(*) as num   FROM $tbl_name";
      //      $sql="UPDATE $tbl_name SET ImageAttachment='$del_id' WHERE prim_key='$del_id";
      //            $sql = "DELETE FROM $tbl_name WHERE id='10'"; //using a static query didn't solve the problem.
      $result = mysql_query($sql);
    }

    // if successful redirect to delete_multiple.php
    if($result){

      echo $result ;// this will return "Resource id #2" when it fails  or it will return the # of affected rows when it succeeds
      //      while($row = mysql_fetch_assoc($result)) {
      while($row = mysql_fetch_array($result)) {
	echo $row['num'];
	echo "fuck"; //this isn't being printed
      }

      echo "<meta http-equiv=\"refresh\" content=\"4;URL=delete_multiple3.php\">";
    }
  }
mysql_close();
?>
</table>
</form>
</td>
</tr>
</table>