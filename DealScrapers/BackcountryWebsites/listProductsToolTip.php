<?php
$con = mysql_connect("localhost","BCA","backcountryalerts");
if (!$con)
  {
    die('Could not connect:'.mysql_error());
  }
else 
  {
    mysql_select_db("djinnius_BackCountryAlerts",$con);

    $sql="SELECT filename from ProductImages ORDER BY filename ASC";

    if (!mysql_query($sql,$con))
      {
	die('Error:'.mysql_error());
      }
    else
      {
	$result=mysql_query($sql);
  
	//creating the table /w headers
	echo "<html><body>\n";
	echo "<title>ODAT Product List</list>";
	echo "<head>";
	echo "<script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js\"></script>";
	echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"ddimgtooltip.css\" />";

	echo "<script type=\"text/javascript\" src=\"ddimgtooltip.js\">\n";
	echo "/***********************************************\n";
	echo "* Image w/ description tooltip v2.0- (c) Dynamic Drive DHTML code library (www.dynamicdrive.com)\n";
	echo "* This notice MUST stay intact for legal use\n";
	echo "* Visit Dynamic Drive at http://www.dynamicdrive.com/ for this script and 100s more\n";
	echo "***********************************************/\n";
	echo "</script>\n";
	echo "</head>\n";

	echo "<table>\n";

	$FileRead1=file_get_contents('ddimgtooltippt1.js');
	$FileRead2=file_get_contents('ddimgtooltippt2.js');
	if (	$FileWriteHandle=fopen('ddimgtooltip.js','w') )	  {
	  //	    if ( is_writable('ddimgtooltip.js') ) {

		$fwrite=fwrite($FileWriteHandle, $FileRead1);
		if ($fwrite === false )
		  {
		    echo "--------------------------unable to write to file----------------\n";
		  }
		else
		  {
		    //   echo " " . $fwrite . "bytes written\n";
		    //echo " " . $FileRead1 ." ";
		  }

		$counter=0;
		$OutputString="";
		//row for each record
		while ($row = mysql_fetch_array($result)) {
		  $Filename=str_replace('/','\\',$row['filename']);
		  echo "<tr><td><a href=\"ProductImages/" .$Filename . ".jpg\" rel=\"imgtip[" . $counter . "]\">" . $row['filename'] . "</a></td></tr>\n";
		  $TempString="tooltips[" . $counter . "]=[\"ProductImages/" . $Filename . ".jpg\"]\n";
		  $OutputString=$OutputString . $TempString; // you need to use the . concatenate operator for strings.
		  $counter+=1;
		}
		//		echo $OutputString;
		fwrite($FileWriteHandle, $OutputString);
		fwrite($FileWriteHandle, $FileRead2);
		fclose($FileWriteHandle);

		echo "</table>\n";
		echo "</body></html>\n";
	    }
	/*else 
	      { 
		echo "file not writable";
		  }
		  }*/
	else
	  {
	    echo "can't open file";
	      }
      }
  }
//free memory
mysql_free_result($result);

//close the db

mysql_close($con)
?>
