<?php
//require_once("Rest.inc.php");
require_once("dbinfo_user.php");

class API //extends REST
{
public $data = "";

const DB_SERVER = "localhost";
const DB = "djinnius_BackCountryAlerts"; //BackcountryProducts
const NUMBEROFRECORDSTODISPLAY = 25;

private $db = NULL;

public function __construct()
{
parent::__construct();
$this->dbConnect();
}

private function dbConnect()
{
// Opens a connection to a MySQL server
$this->db = mysql_connect (localhost, $username, $password);
if ($this->db){
mysql_select_db(self::DB,$this->db);
}
else
{
die('Not connected : ' . mysql_error());
}
}//end dbConnect()

public function processApi()
{
$func = strtolower(trim(str_replace("/","",$_REQUEST['rquest'])));
if((int)method_exists($this,$func) > 0)
$this->func();
else
$this->response('',404);
}

//use function name to point call a generic query with the parameters passed in 

private function getRecentRecords()
{
if ($this->get_request_method()!="GET")
{
$this->response('',406);
}
$WebsiteCode=1;

	    $MySQLQuery="SELECT product FROM BackcountryProducts WHERE websitecode=$WebsiteCode ORDER BY ProductEntrykey DESC LIMIT self::NUMBEROFRECORDSTODISPLAY";
$sql = (mysql_query(MySQLQuery, $this->db));

if(mysql_num_rows($sql)>0)
{
$result = array();
while($rlt = mysql_fetch_array($sql,MYSQL_ASSOC))
{
$result[]=$rlt;
}
$this->response($this->json($result),200);
}
$this->response('',204);
}

private function getNumRecords()
{
if ($this->get_request_method()!="GET")
{
$this->response('',406);
}
	    $MySQLQuery="SELECT count(product) FROM BackcountryProducts";
$sql = (mysql_query(MySQLQuery, $this->db));

if(mysql_num_rows($sql)>0)
{
$result = array();
while($rlt = mysql_fetch_array($sql,MYSQL_ASSOC))
{
$result[]=$rlt;
}
$this->response($this->json($result),200);
}
$this->response('',204);
}

 } //end API class
?>