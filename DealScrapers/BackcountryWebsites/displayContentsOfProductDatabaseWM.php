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
    $sql = 'SELECT p.product,p.websiteCode,d.price,d.percentOffMSRP,d.quantity,d.timeEnter,d.dealdurationinminutes FROM BackcountryProducts p, BackcountryProductDetails d WHERE p.ProductEntrykey=d.ProductEntrykey AND p.websiteCode=1 ORDER BY p.product ASC' ;

    $result=mysql_query($sql);
    $count=mysql_num_rows($result);

    ?>
    <html>
       <body>


       <table border="0" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC">
       <tr>
       <td bgcolor="#FFFFFF">&nbsp;</td>
				       <td colspan="8" bgcolor="#FFFFFF"><strong>Whiskey Militia Product Database Contents</strong> </td>
				       </tr>
				       <tr>
				       <td align="center" bgcolor="#FFFFFF"><strong>Key</strong></td>

				       <td align="center" bgcolor="#FFFFFF"><strong>Product</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Price</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Percent off MSRP</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Quantity </strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Deal Duration (minutes)</strong></td>
				       <td align="center" bgcolor="#FFFFFF"><strong>Time Deal Appeared</strong></td>
<?php
                                       while($rows=mysql_fetch_array($result)){ ?>
				       </tr>
					 <tr>
					 <td bgcolor="#FFFFFF"><? echo $rows['ProductEntrykey']; ?></td>
					 <?		  $Filename=str_replace('/','\\',$rows['product']);
					 $ImageLink="<a href=\"ProductImages/" .$Filename . ".jpg \">" . $rows['product'] . "</a> \n";
					 ?>
					 <td bgcolor="#FFFFFF"><? echo $ImageLink; ?></td>
					 <td bgcolor="#FFFFFF"><? echo $rows['price']; ?></td>
					 <td bgcolor="#FFFFFF"><? echo $rows['percentOffMSRP']; ?></td>
					 <td bgcolor="#FFFFFF"><? echo $rows['quantity']; ?></td>
					 <td bgcolor="#FFFFFF"><? echo $rows['dealdurationinminutes']; ?></td>
					 <td bgcolor="#FFFFFF"><? echo $rows['timeEnter']; ?></td>

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
	