
#include < amxmodx >
#include < amxmisc >

#pragma semicolon 1
	
new gHudSync;

public plugin_init()
{
	register_plugin( "Radio", "1.0.0", "tuty" );
	register_clcmd( "say /radio", "CommandShowRadio" );
	register_clcmd( "say /listen", "CommandShowRadio" );
	register_clcmd( "say /muzica", "CommandShowRadio" );
	
	register_clcmd( "say /stop", "CommandStopRadio" );
	register_clcmd( "say_team /stop", "CommandStopRadio" );
	
	register_clcmd( "say_team /radio", "CommandShowRadio" );
	register_clcmd( "say_team /listen", "CommandShowRadio" );
	register_clcmd( "say_team /muzica", "CommandShowRadio" );
	
	gHudSync = CreateHudSyncObj();
}

public CommandShowRadio( id )
{
	const SIZE = 3333;
	new msg[ SIZE + 1 ],len = 0;

	len += formatex( msg[ len ], SIZE - len, "<html><body bgcolor=^"black^">" );
	len += formatex( msg[ len ], SIZE - len, "<center><b><font color=^"red^">[ RADIO NovusLink! ]</font></b></center><br/>" );
	len += formatex( msg[ len ], SIZE - len, "<center><font color=^"white^">Nota: Trebuie sa asteptati unpic pana ce se incarca Radio-ul.</font></center>" );
	len += formatex( msg[ len ], SIZE - len, "<center><font color=^"white^">Puteti inchide fereastra, muzica va continua sa mearga.</font></center><br/>" );
	len += formatex( msg[ len ], SIZE - len, "<p align=^"center^"><embed type=^"application/x-mplayer2^" pluginspage=^"http://www.microsoft.com/Windows/MediaPlayer/^" src=^"http://89.36.86.130:7000^" name=^"MediaP8layer1^" uimode=^"mini^" url=^"http://89.36.86.130:7000^" autostart=^"1^" animationatstart=^"false^" transparentatstart=^"true^" showcontrols=^"1^" showtracker=^"0^" showstatusbar=^"0^" volume=^"0.5^" height=^"100^" width=^"300^"></embed></p>" );
	len += formatex( msg[ len ], SIZE - len, "</body></html>" );
	
	show_motd( id, msg, "[ NovusLink RADIO ]");
	
	new szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );
	
	set_hudmessage( 255, 255, 255, 0.0, 0.88, 2, 6.0, 7.0 );
	ShowSyncHudMsg( 0, gHudSync, "%s Asculta acum RADIO NovusLink!", szName );
	
	return PLUGIN_CONTINUE;
}

public CommandStopRadio( id )
{
	const SIZE = 400;
	new msg[ SIZE + 1 ],len = 0;
	
	len += formatex( msg[ len ], SIZE - len, "<html><body bgcolor=^"black^">" );
	len += formatex( msg[ len ], SIZE - len, "<br/><br/><center><b><font color=^"white^">RADIO-ul s-a oprit. Puteti inchide fereastra MOTD!</font></b></center>" );
	len += formatex( msg[ len ], SIZE - len, "</body></html>" );
	
	show_motd( id, msg, "[ NovusLink RADIO Oprit! ]");
	
	new szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );

	set_hudmessage( 255, 255, 255, 0.0, 0.88, 2, 6.0, 7.0 );
	ShowSyncHudMsg( 0, gHudSync, "%s a oprit RADIO-ul NovusLink!", szName );

	return PLUGIN_CONTINUE;
}
