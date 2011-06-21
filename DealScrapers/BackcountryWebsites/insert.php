	<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
{
die('Could not connect:'.mysql_error());
}

mysql_select_db("djinnius_BackCountryAlerts",$con);

$sql="INSERT INTO SearchTermsAndContactAddress (searchterms, contactaddress)
VALUES
('$_POST[SearchTerms]','$_POST[ContactAddress]')";

if (!mysql_query($sql,$con))
{
die('Error:'.mysql_error());
}
echo "1 record added";
mysql_close($con)
?>
