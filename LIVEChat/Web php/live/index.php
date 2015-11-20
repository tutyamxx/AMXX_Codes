<?php
echo '<html>
		<head>
			<title>Statistics Redirect</title>
			<link rel="stylesheet" href="style.css" type="text/css" />
			<script src="http://code.jquery.com/jquery-latest.js"></script>
			<script src="Scripts/swfobject_modified.js" type="text/javascript"></script>
			<script>
			var refreshId = setInterval(function()
			{
				 $(\'#responsecontainer\').fadeOut("fast").load(\'response.php\').fadeIn("fast");
			}, 5000);
			//$(\'#responsecontainer\').fadeOut("slow").load(\'response.php\').fadeIn("slow");
			</script>
</head>
		<body>
	  <center>
			<table>
				<tr>
					<td class="banner">
					  <object id="FlashID" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="604">
					    <param name="movie" value="header_v8.swf">
					    <param name="quality" value="high">
					    <param name="wmode" value="opaque">
					    <param name="swfversion" value="8.0.35.0">
					    
					    <param name="expressinstall" value="Scripts/expressInstall.swf">
					    <!-- Next object tag is for non-IE browsers. So hide it from IE using IECC. -->
					    <!--[if !IE]>-->
					    <object type="application/x-shockwave-flash" data="header_v8.swf" width="100%" height="604">
					      <!--<![endif]-->
					      <param name="quality" value="high">
					      <param name="wmode" value="opaque">
					      <param name="swfversion" value="8.0.35.0">
					      <param name="expressinstall" value="Scripts/expressInstall.swf">
					      <!-- The browser displays the following alternative content for users with Flash Player 6.0 and older. -->
					      <div>
					        <h4>Content on this page requires a newer version of Adobe Flash Player.</h4>
					        <p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" width="112" height="33" /></a></p>
				          </div>
					      <!--[if !IE]>-->
				        </object>
					    <!--<![endif]-->
			      </object></td>
				</tr>
			</table>
			<table class="contents" border="0" valign="top">
				<tr>
					<td valign="top">
						<table class="tops">
							
						</table>
						<div id="responsecontainer">
						<center><img src="loading.gif" width="200"></center>
						</div>
					</td>
				</tr>
			</table>
		</center>
        <script type="text/javascript">
swfobject.registerObject("FlashID");
        </script>
	</body>
	</html>
';

?>
