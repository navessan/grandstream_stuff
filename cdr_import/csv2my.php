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
// Parameters: filename.csv table_name

//$argv = $_SERVER[argv];

if($argv[1]) { $file = $argv[1]; }
else {
    echo "Please provide a file name\n"; exit; 
}
if($argv[2]) { $table = $argv[2]; }
else {
    $table = pathinfo($file);
    $table = $table['filename'];
}

/********************************************************************************/
// Get the first row to create the column headings

$fp = fopen($file, 'r');
$frow = fgetcsv($fp);
$columns="";

foreach($frow as $column) {
    if($columns) $columns .= ', ';
    $columns .= "`$column` varchar(250) NULL default NULL";
}

$q = "create table if not exists $table ($columns);";
//echo "SQL: $q \n";
//$result=$db->query($q);

if(!$result){
    echo ($db->error);
    exit;
}

/********************************************************************************/
// Import the data into the newly created table.


$file = $file;
$q = "load data local infile '$file' into table $table character set utf8 fields terminated by ',' OPTIONALLY ENCLOSED BY '\"' ignore 1 lines;";

echo "SQL: $q \n";
$result=$db->query($q);

if(!$result){
    echo "$file import error: ".($db->error)."\n";
    exit;
}

$db->close();
echo "$file import success\n"

?>
