<?php
require ('config.php');
echo '<center>
			<table style="border-style: none; border-color: none; border-width: 0px;" width="500">
				<tr>
					<td>
						<table width="800" style="font-size:12px; font-family: \'Arial\', tahoma, arial, helvetica, sans-serif; color:fff; ">';
$sql = mysql_query("SELECT * FROM `LIVEChat` ORDER BY ID DESC LIMIT 10") or die(mysql_error());
							if(mysql_num_rows($sql) > 0 )
	{
		while($rand = mysql_fetch_array($sql))	{
			$id= stripslashes($rand['0']);
			$time = stripslashes($rand['1']);
                  $alive = stripslashes($rand['2']);
			$team = stripslashes($rand['3']);
			$name = stripslashes($rand['4']);
			$message = stripslashes($rand['5']);
		
			switch($team)
			{						
				case 0:
				{
					$team = "(Spectator)";
					$culoare = "gray";
					break;
				}
				case 1:
				{
					$team = "(Terrorist)";
					$culoare = "red";
					break;
				}
				case 2:
				{
					$team = "(Counter)";
					$culoare = "#6B8ADA";
					break;
				}
				case 3:
				{
					$team = "(Spectator)";
					$culoare = "gray";
					break;
				}
			}
		echo '
		<tr>
			<td>'.$time.'</td>	
            <td><b><font color="white">'.$alive.'</font></b></td>
			<td><b><font color="'.$culoare.'">'.$team.'</font></b></td>
			<td width="60"><b><font color="'.$culoare.'">'.$name.'</font>:</b></td>
			<td width="600">'.$message.'</td>
	      </tr>					
					';		
			} 
	}else{ echo 'Nimic de afisat.'; }
	
	$sql = mysql_query("SELECT * FROM `LIVEChat` ORDER BY ID DESC LIMIT 1") or die(mysql_error());
		if(mysql_num_rows($sql) > 0 )
	{
		while($rand = mysql_fetch_array($sql))	{
			$id= stripslashes($rand['0']);
			$time = stripslashes($rand['1']);
                  $alive = stripslashes($rand['2']);
			$team = stripslashes($rand['3']);
			$name = stripslashes($rand['4']);
			$message = stripslashes($rand['5']);
			$ultimele = $id - 11;
			for($i=0;$i<=$ultimele;$i++) {
				mysql_query("DELETE FROM `LIVEChat` where `id` = '$i' ");
			}
		}
		}
echo '</table>
</td>
</tr>
</table>
</center>';
?>

