<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
{
die('Could not connect:'.mysql_error());
}

mysql_select_db("djinnius_BackCountryAlerts",$con);

$sql="DELETE FROM SearchTermsAndContactAddress WHERE prim_key = ('$_POST[DeleteID]')";

if (!mysql_query($sql,$con))
{
die('Error:'.mysql_error());
}
else
{
$result=mysql_query($sql);
}

echo "1 record removed";

//close the db
mysql_close($con)
?>
