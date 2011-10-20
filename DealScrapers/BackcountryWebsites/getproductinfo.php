<?php
$q=$_GET["q"];
$con = mysql_connect('localhost', 'BCA', 'backcountryalerts');
if (!$con)
  {
    die('Could not connect: ' . mysql_error());
  }

mysql_select_db("djinnius_BackCountryAlerts", $con);

$sql="SELECT product FROM BackcountryProducts WHERE ProductEntrykey = '".$q."'";

$result = mysql_query($sql);
$row = mysql_fetch_array($result);
$count=mysql_num_rows($result);
$temp=mysql_result($result, 0);
echo "<strong>"  . $temp . "</strong><br>\n";
$Filename=str_replace('/','\\',$temp); //convert names with slashes  in them
echo "<a href=\"ProductImages/" .$Filename . ".jpg\"> <img src=\"ProductImages/" .$Filename . ".jpg \" height=150 width=150>  </a>\n";

echo "<table border='1'>
<tr>
<th>Price</th>
<th>Percent Off MSRP</th>
<th>Quantity Offered</th>
<th>Deal Duration (min)</th>
<th>Time Deal Appeared </th>
</tr>";

$sql="SELECT * FROM BackcountryProductDetails WHERE ProductEntrykey = '".$q."' ORDER BY timeEnter DESC";
$result = mysql_query($sql);
while($row = mysql_fetch_array($result))
  {
    echo "<tr>";
    echo "<td>" . $row['price'] . "</td>";
    echo "<td>" . $row['percentOffMSRP'] . "</td>";
    echo "<td>" . $row['quantity'] . "</td>";
    echo "<td>" . $row['dealdurationinminutes'] . "</td>";
    echo "<td>" . $row['timeEnter'] . "</td>";
    echo "</tr>";
  }
echo "</table>";

mysql_close($con);
?> 