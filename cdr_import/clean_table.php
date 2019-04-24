<?php


#default values
#$host = 'localhost';
#$user = 'cdr';
#$pass = 'password';
#$database = 'cdr';

include('config_db.php');

$db = mysqli_connect($host, $user, $pass);

/* check connection */
if ($db->connect_errno) {
    printf("Connect failed: %s\n", $db->connect_error);
    exit();
}

$q="use $database";
echo "SQL: $q \n";
$result=$db->query($q);

if(!$result){
    echo ($db->error);
    exit;
}

/********************************************************************************/
// Parameters: table_name

//$argv = $_SERVER[argv];

if($argv[1]) {
    $table = $argv[1]; }
else {
    echo "Please provide a table name\n";
    exit;
}

$q = "truncate table $table;";
echo "SQL: $q \n";
$result=$db->query($q);

if(!$result){
    echo ($db->error);
    exit;
}

$db->close();
echo "truncate $table success\n"

?>
