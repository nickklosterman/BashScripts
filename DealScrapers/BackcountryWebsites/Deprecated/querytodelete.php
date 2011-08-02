
<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
{
die('Could not connect:'.mysql_error());
}

mysql_select_db("djinnius_BackCountryAlerts",$con);

$sql="SELECT * FROM SearchTermsAndContactAddress WHERE contactaddress = ('$_POST[SearchAddress]')";

if (!mysql_query($sql,$con))
{
die('Error:'.mysql_error());
}
else
{
$result=mysql_query($sql);
}
//creating the table /w headers
echo "<html><body>";
echo "<table><tr><td>ID</td><td>Search Term</td><td>Contact Address</td><td>Attach Image&#63</td></tr>";

//row for each record
while ($row = mysql_fetch_array($result)) {
echo"<tr><td>" . $row['prim_key'] . "</td><td>" . $row['searchterms'] . "</td><td>" . $row['contactaddress'] . "</td><td>" . $row['ImageAttachment'] . "</td></tr>";
}

echo "</table>";
echo "</body></html>";


//free memory
mysql_free_result($result);

//close the db

mysql_close($con)
?>
