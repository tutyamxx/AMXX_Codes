
#include < amxmodx >
#include < amxmisc >
#include < fun >
#include < fakemeta >
#include < time >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"
#define COMMAND_ACCESS	ADMIN_RCON

new bool:bGamePaused;

new gHudSync;
new gCountTimer;

new gCvarEnabled;
new gCvarPauseTime;

public plugin_init()
{
	register_plugin( "PAUSE", PLUGIN_VERSION, "tuty" );

	register_event( "CurWeapon", "Hook_CurWeapon", "be", "1=1" );
	
	register_clcmd( "say .pause", "commandDoPause" );
	register_clcmd( "say_team .pause", "commandDoPause" );
	register_clcmd( "say .stoppause", "commandDoStopPause" );
	register_clcmd( "say_team .stoppause", "commandDoStopPause" );
	
	gCvarEnabled = register_cvar( "pause_enabled", "1" );

	/* --| 1 minut = 60 secunde
  	   --| 5 minute = 5 * 60 = 300 */

	gCvarPauseTime = register_cvar( "pause_time", "300" );
	
	gHudSync = CreateHudSyncObj();
	register_dictionary( "time_length.txt" );
}

public Hook_CurWeapon( id )
{
	if( get_pcvar_num( gCvarEnabled ) == 1 )
	{
		if( bGamePaused == true )
		{
			set_user_maxspeed( id, 0.1 );
		}
	}
}

public commandDoPause( id )
{
	if( get_pcvar_num( gCvarEnabled ) == 0 )
	{
		client_print( id, print_chat, "* Pluginul este oprit!" );
	
		return PLUGIN_CONTINUE;
	}

	if( !( get_user_flags( id ) & COMMAND_ACCESS ) )	
	{
		client_print( id, print_chat, "* Nu ai acces la aceasta comanda!" );
		
		return PLUGIN_CONTINUE;
	}

	if( bGamePaused == true )
	{
		client_print( id, print_chat, "* Jocul este deja in pauza!" );
		
		return PLUGIN_CONTINUE;
	}
	
	if( task_exists( 13379501 ) )
	{
		remove_task( 13379501 );
	}

	if( task_exists( 123321 ) )
	{
		remove_task( 123321 );
	}
	
	new szAdminName[ 32 ];
	get_user_name( id, szAdminName, charsmax( szAdminName ) );

	bGamePaused = true;
	
	new iPlayers[ 32 ], iCount, id;
	get_players( iPlayers, iCount, "ch" );
	
	for( new i = 0; i < iCount; i++ )
	{
		id = iPlayers[ i ];
		
		set_user_maxspeed( id, 0.1 );
	}
	
	client_print( 0, print_chat, "* Pauza a fost pornita de adminul: %s", szAdminName );
	log_amx( "* Pauza a fost pornita de adminul:<%s>.", szAdminName );
	
	set_task( float( get_pcvar_num( gCvarPauseTime ) ), "StopPause", 123321 );
	set_task( 1.0, "ShowTimeRemaining", 13379501, _, _, "a", get_pcvar_num( gCvarPauseTime ) );
	
	client_cmd( 0, "speak scientist/stop4.wav" );
	
	return PLUGIN_CONTINUE;
}

public ShowTimeRemaining()
{
	gCountTimer++;
	
	new iTimer = get_pcvar_num( gCvarPauseTime ) - gCountTimer;

	new szTimeLenght[ 128 ];
	get_time_length( 0, iTimer, timeunit_seconds, szTimeLenght, charsmax( szTimeLenght ) );

	set_hudmessage( 42, 42, 255, -1.0, 0.87, 0, 6.0, 2.0 );
	ShowSyncHudMsg( 0, gHudSync, "Timp ramas pana ce expira pauza^n%s", szTimeLenght );
	
	if( iTimer <= 10 )
	{
		new szNumToWord[ 20 ];
		num_to_word( iTimer, szNumToWord, charsmax( szNumToWord ) );
		
		client_cmd( 0, "speak ^"fvox/%s^"", szNumToWord );
	}
}

public StopPause()
{
	new iPlayers[ 32 ], iCount, id;
	get_players( iPlayers, iCount, "ch" );
	
	for( new i = 0; i < iCount; i++ )
	{
		id = iPlayers[ i ];
		
		reset_client_maxspeed( id );
	}
	
	if( task_exists( 13379501 ) )
	{
		remove_task( 13379501 );
	}

	if( task_exists( 123321 ) )
	{
		remove_task( 123321 );
	}
	
	bGamePaused = false;
	gCountTimer = 0;
	
	client_print( 0, print_chat, "* Timpul a expirat, pauza a fost oprita!" );
	log_amx( "* Timpul a expirat, pauza a fost oprita!" );
	
	client_cmd( 0, "speak barney/letsgo.wav" );
}

public commandDoStopPause( id )
{
	if( get_pcvar_num( gCvarEnabled ) == 0 )
	{
		client_print( id, print_chat, "* Pluginul este oprit!" );
	
		return PLUGIN_CONTINUE;
	}

	if( !( get_user_flags( id ) & COMMAND_ACCESS ) )	
	{
		client_print( id, print_chat, "* Nu ai acces la aceasta comanda!" );
		
		return PLUGIN_CONTINUE;
	}

	if( bGamePaused == false )
	{
		client_print( id, print_chat, "* Pauza este oprita deja!" );
		
		return PLUGIN_CONTINUE;
	}
	
	new szAdminName[ 32 ];
	get_user_name( id, szAdminName, charsmax( szAdminName ) );
	
	bGamePaused = false;
	gCountTimer = 0;
	
	new iPlayers[ 32 ], iCount, id;
	get_players( iPlayers, iCount, "ch" );
	
	for( new i = 0; i < iCount; i++ )
	{
		id = iPlayers[ i ];
		
		reset_client_maxspeed( id );
	}
	
	client_print( 0, print_chat, "* Pauza a fost oprita de adminul: %s", szAdminName );
	log_amx( "* Pauza a fost oprita de adminul:<%s>.", szAdminName );
	
	if( task_exists( 13379501 ) )
	{
		remove_task( 13379501 );
	}

	if( task_exists( 123321 ) )
	{
		remove_task( 123321 );
	}
	
	client_cmd( 0, "speak barney/letsgo.wav" );	
	
	return PLUGIN_CONTINUE;
}

stock reset_client_maxspeed( id ) 
{ 
	new Float:flMaxSpeed; 

	switch ( get_user_weapon( id ) ) 
    	{ 
       		case CSW_SG550, CSW_AWP, CSW_G3SG1: flMaxSpeed = 210.0; 
        	case CSW_M249: flMaxSpeed = 220.0; 
        	case CSW_AK47: flMaxSpeed = 221.0; 
        	case CSW_M3, CSW_M4A1: flMaxSpeed = 230.0; 
        	case CSW_SG552: flMaxSpeed = 235.0; 
        	case CSW_XM1014, CSW_AUG, CSW_GALIL, CSW_FAMAS: flMaxSpeed = 240.0; 
        	case CSW_P90 : flMaxSpeed = 245.0; 
        	case CSW_SCOUT: flMaxSpeed = 260.0; 
        	default: flMaxSpeed = 250.0; 
	} 

    	engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed ); 
    	set_pev( id, pev_maxspeed, flMaxSpeed ); 
}
