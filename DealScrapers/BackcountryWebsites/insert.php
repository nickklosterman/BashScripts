<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
{
die('Could not connect:'.mysql_error());
}

mysql_select_db("djinnius_BackCountryAlerts",$con);

$sql="INSERT INTO SearchTermsAndContactAddress (searchterms, contactaddress, ImageAttachment)
VALUES
('$_POST[SearchTerms]','$_POST[ContactAddress]', '$_POST[ImageAttachment]')";

if (!mysql_query($sql,$con))
{
die('Error:'.mysql_error());
}
echo "<html><body>";
echo "<meta http-equiv=\"refresh\" content=\"5; url=PHPInsert.html\">";
echo "1 record added: SearchTerm: $_POST[SearchTerms] Address: $_POST[ContactAddress] ";
echo "<br>";
echo "Click here to go back to the <a href=\"http://www.djinnius.com/Deals/\">Main Page</a> otherwise you will be redirected to the <a href=\"PHPInsert.html\">alert creation page</a> in 5 seconds ";
echo "</body></html>";
mysql_close($con)
?>
