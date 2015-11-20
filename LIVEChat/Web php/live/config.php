<?php
session_start();
set_time_limit(0);
error_reporting(E_ALL);

// Informatii baza de date

 $AdresaBazaDate = "";
 $UtilizatorBazaDate = "";
 $ParolaBazaDate = "";
 $NumeBazaDate = "";

 $conexiune = mysql_connect($AdresaBazaDate,$UtilizatorBazaDate,$ParolaBazaDate) or die("Nu ma pot conecta la MySQL!");
 mysql_select_db($NumeBazaDate, $conexiune) or die("Nu gasesc baza de date !");
 
function addentities($data){
   if(trim($data) != ''){
   $data = htmlentities($data, ENT_QUOTES);
   return str_replace('\\', '&#92;', $data);
   } else return $data;
} 
$_SESSION["link"] = "http://www.requirehelp.com"

?>
