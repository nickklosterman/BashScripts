############### Code

<?php
$host="localhost"; // Host name
$username="BCA"; // Mysql username
$password="backcountryalerts"; // Mysql password
$db_name="djinnius_BackCountryAlerts"; // Database name
$tbl_name="Backcountrydeals"; // Table name

// Connect to server and select databse.
$con=mysql_connect("$host", "$username", "$password")or die("cannot connect");
if (!$con)
  {
    die('Could not connect'.mysql_error());
      }
else
  {
    mysql_select_db("$db_name")or die("cannot select DB");

    $sql = 'SELECT * FROM `'.$tbl_name.'`  ORDER BY product ASC';
    $sql = 'SELECT distinct(product),websiteCode,price,percentOffMSRP,quantity,timeEnter,dealdurationinminutes,Bkey FROM `'.$tbl_name.'`  ORDER BY product ASC';
    $sql = 'SELECT p.product,p.websiteCode,d.price,d.percentOffMSRP,d.quantity,d.timeEnter,d.dealdurationinminutes FROM BackcountryProducts p, BackcountryProductDetails d WHERE p.ProductEntrykey=d.ProductEntrykey ORDER BY p.product ASC' ;
    $sql = 'SELECT DISTINCT p.product,p.websiteCode,d.price , d.percentOffMSRP, d.dealdurationinminutes FROM BackcountryProducts p, BackcountryProductDetails d WHERE p.ProductEntrykey=d.ProductEntrykey ORDER BY p.product ASC' ;
$sql = 'SELECT DISTINCT p.product,p.websiteCode,min(d.price) as minprice, avg(d.price) as avgprice ,max(d.price) as maxprice,max(d.timeEnter) as maxtimeEnter  FROM BackcountryProducts p, BackcountryProductDetails d WHERE p.ProductEntrykey=d.ProductEntrykey GROUP BY p.product ORDER BY p.product ASC' ; //http://dev.mysql.com/doc/refman/5.0/en/group-by-functions.html http://www.java2s.com/Code/Php/MySQL-Database/Getcolumnalias.htm

//I really wanted to display the mode (most common value) but that is nontrivial to do in a query http://www.freeopenbook.com/mysqlcookbook/mysqlckbk-chp-13-sect-2.html
    $result=mysql_query($sql);
    $count=mysql_num_rows($result);

    ?>
    <html>
       <body>

       Website Codes: SC=Steep and Cheap; WM= Whiskey Militia; BT= Bonktown; CL=Chainlove
       <table border="0" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC">
       <tr>

				       <td colspan="8" bgcolor="#FFFFFF"><strong>Product Database Contents</strong> </td>
				       </tr>
				       <tr>
				       <td align="center" bgcolor="#FFFFFF"><strong>Key</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Website</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Product</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Min Price</strong></td>
<!--				       <td align="center" bgcolor="#FFFFFF"><strong>Avg Price</strong></td> -->
				       <td align="center" bgcolor="#FFFFFF"><strong>Max Price</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Last Seen</strong></td>
				       </tr>
				       <?php
				       while($rows=mysql_fetch_array($result)){
					 switch ($rows['websiteCode'])
					   {
					   case 0:
					   $WebsiteCode="SC";
					   break;
					   case 1:
					   $WebsiteCode="WM";
					   break;
					   case 2:
					   $WebsiteCode="BT";
					   break;
					   case 3:
					   $WebsiteCode="CL";
					   break;
					   }
					 ?>
					 <tr>
					 <td bgcolor="#FFFFFF"><? echo $rows['ProductEntrykey']; ?></td>
					 <td bgcolor="#FFFFFF"><? echo $WebsiteCode; ?></td>
					 <?		  $Filename=str_replace('/','\\',$rows['product']);
					 $ImageLink="<a href=\"ProductImages/" .$Filename . ".jpg \">" . $rows['product'] . "</a> \n";
					 ?>
					 <td bgcolor="#FFFFFF"><? echo $ImageLink; ?></td>
	
<? if ($rows['minprice']<$rows['maxprice'] )
{
$Output1="				 <td bgcolor=\"#00FF00\">" .$rows['minprice'] . "</td>";
$Output2="				 <td bgcolor=\"#FFFFFF\">" .$rows['maxprice'] . "</td> ";
}
else
{
$Output1="				 <td bgcolor=\"#FFFFFF\">" .$rows['minprice'] . "</td>";
$Output2="				 <td bgcolor=\"#FFFFFF\">-=-</td> ";
}
?>
<? echo $Output1; ?>
<? echo $Output2; ?>
<!--					 <td bgcolor="#FFFFFF"><? echo $rows['avgprice']; ?></td>
					 <td bgcolor="#FFFFFF"><? echo $rows['maxprice']; ?></td> -->

					 <td bgcolor="#FFFFFF"><? echo $rows['maxtimeEnter']; ?></td>


					 </tr>
					 <?php
				       }
  }
    ?>

    <?
    mysql_close();
    ?>

    </table>
	</body>
	</html>
	