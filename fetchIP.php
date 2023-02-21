<?php

$filename = './output.txt'; // The output file on the server
$content = $_GET["x"];  //

// Let's open $filename in write mode ad fwrite $content into it.
if (!$fp = fopen($filename, 'w')) {
     //echo "Cannot open file ($filename)";
	 echo "Cannot open the output file on the server!";
     exit;
}

// Write $somecontent to our opened file.
if (fwrite($fp, $content) === FALSE) {
	//echo "Cannot write to the output file on the server!";
    echo '<script language="javascript">';
    echo 'alert("Problem writing output file on the server!")';
    echo "window.close();</script>";
   exit;
}

fclose($fp);

?>