<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
  {
    die('Could not connect:'.mysql_error());
  }
else 
  {
    mysql_select_db("djinnius_BackCountryAlerts",$con);
    //there is no ProductImages only holds this data:image_id, filename, number_of_times_seen , last_seen
    $sql="SELECT filename from ProductImages ORDER BY  filename ASC";

    if (!mysql_query($sql,$con))
      {
	die('Error:'.mysql_error());
      }
    else
      {
	$result=mysql_query($sql);
  
	//creating the table /w headers
	echo "<html><body>";
	echo "<table>";

	//row for each record
	while ($row = mysql_fetch_array($result)) {
	  $Filename=str_replace('/','\\',$row['filename']);
	  echo"<tr><td>"  . $row['filename'] . "</td><td><a href=\"ProductImages/" . $Filename . "\">image</a></td></tr>";
	}

	echo "</table>";
	echo "</body></html>";
      }
  }
//free memory
mysql_free_result($result);

//close the db

mysql_close($con)
?>
