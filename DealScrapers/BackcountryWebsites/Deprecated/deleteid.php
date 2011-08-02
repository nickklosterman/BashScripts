<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
  {
    die('Could not connect:'.mysql_error());
  }
else {
  //	mysql_select_db("djinnius_BackCountryAlerts",$con);
  mysql_select_db("djinnius_BackCountryAlerts");

  $sql_getdeleterecordinfo="SELECT * FROM SearchTermsAndContactAddress WHERE prim_key = ('$_POST[DeleteID]')";

  $sql_deleterecord="DELETE FROM SearchTermsAndContactAddress WHERE prim_key = ('$_POST[DeleteID]')";

  /**/
  //	if (!mysql_query($sql_getdeleterecordinfo,$con))
  if (!mysql_query($sql_getdeleterecordinfo))
    {
      die('Error:'.mysql_error());
    }
  else {

    $results_recordinfo=mysql_query($sql_getdeleterecordinfo);
    /**/
    //if (!mysql_query($sql_deleterecord,$con))	
    if (!mysql_query($sql_deleterecord))	
      {  
	die	('Error:'.mysql_error());
      }	
    else	
      {	
	$result=mysql_query($sql_deleterecord); 
      }			
    /**/
  }	
  /*	*/
  echo "<html><body>";
  echo "<meta http-equiv=\"refresh\" content=\"5; url=PHPDeleteID.html\">";
  echo "1 record removed: SearchTerm: $_POST[SearchTerms] Address: $_POST[ContactAddress] ";
  echo "<br>";
  /**/
  while ($row = mysql_fetch_array($results_recordinfo)) {
    echo   "key:" . $row['prim_key'] . " Search Term:" . $row['searchterms'] . " Contact Address:" . $row['contactaddress'] ;
    echo "<br>";
  }
  /*	* /
  if($result)
    {
      echo "what the fu";
      }*/
} /*end the larg if that matches the connection being made*/	

echo "<br>";
echo "Click here to go back to the <a href=\"http://www.djinnius.com/Deals/\">Main Page</a> otherwise you will be redirected to the <a href=\"PHPDeleteID.html\">alert deletion page</a> in 5 seconds ";
echo "</body></html>";


//close the db
mysql_close($con);
?>
