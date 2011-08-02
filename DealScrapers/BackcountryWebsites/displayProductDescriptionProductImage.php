<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
{
die('Could not connect:'.mysql_error());
}

mysql_select_db("djinnius_BackCountryAlerts",$con);

$sql="SELECT * FROM ProductImages order by filename desc";
//$sql="SELECT * FROM ProductImages where filename like \"I%\" order by filename desc";

if (!mysql_query($sql,$con))
{
die('Error:'.mysql_error());
}
else
{
$result=mysql_query($sql);
}
//creating the table /w headers
echo "<html><body>\n";
echo "<table><tr><td>ID</td><td>Product Description</td><td>Number of Times Seen</td><td>Last Seen</td></tr>\n";

//row for each record
while ($row = mysql_fetch_array($result)) {
  //  $Filename=str_replace("\/","\\",$row['filename']); // single quotes not double and had to escape the backslash
  $Filename=str_replace('/','\\',$row['filename']);
  echo"<tr><td>" . $row['image_id'] . "</td><td>" . $row['filename'] . " <img src=\"ProductImages/" . $Filename . ".jpg\" alt=" . $row['filename'] . " </td><td>" . $row['number_of_times_seen'] . "</td><td>" . $row['last_seen'] . "</td></tr>\n";
}

echo "</table>\n";
echo "</body></html>\n";


//free memory
mysql_free_result($result);

//close the db

mysql_close($con)
?>
