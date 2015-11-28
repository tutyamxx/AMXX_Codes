
#include < amxmodx >
#include < amxmisc >

#include < hamsandwich >

#pragma semicolon 1

#define TASK_RESPAWN_UNIQUE	362154365214
#define TASK_TIME_UNIQUE	111233324092

#define PLUGIN_VERSION		"1.0.0"

new gCvarRespawnTime;
new gHudSync;

new gCountTimer[ 33 ];

public plugin_init()
{
	register_plugin( "Simple Respawn", PLUGIN_VERSION, "tuty" );
	
	register_event( "DeathMsg", "Hook_DeathMessage", "a" );
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawn", 1 );
	
	gCvarRespawnTime = register_cvar( "sr_deathwait", "20" );
	gHudSync = CreateHudSyncObj();	
}

public Hook_DeathMessage()
{
	new iVictim = read_data( 2 );
	
	new iTimeDelay = get_pcvar_num( gCvarRespawnTime );
	
	set_task( float( iTimeDelay ), "RespawnPlayer", iVictim + TASK_RESPAWN_UNIQUE );
	set_task( 1.0, "ShowTimer", iVictim + TASK_TIME_UNIQUE, _, _, "a", iTimeDelay );
}

public RespawnPlayer( taskid )
{
	new id = taskid - TASK_RESPAWN_UNIQUE;
	
	if( !is_user_alive( id ) )
	{
		ExecuteHamB( Ham_CS_RoundRespawn, id );
	}
}

public ShowTimer( taskid )
{
	new id = taskid - TASK_TIME_UNIQUE;
	
	gCountTimer[ id ]++;
		
	new iTimer = get_pcvar_num( gCvarRespawnTime ) - gCountTimer[ id ];
	
	set_hudmessage( 255, 0, 0, -1.0, 0.0, 1, 6.0, 2.0 );
	ShowSyncHudMsg( id, gHudSync, "Reinvii in %d secunde...", iTimer );
	
	if( iTimer <= 3 )
	{
		new szNumToWord[ 20 ];
		num_to_word( iTimer, szNumToWord, charsmax( szNumToWord ) );
		
		client_cmd( id, "speak ^"fvox/%s^"", szNumToWord );
		ShowSyncHudMsg( id, gHudSync, "Fi gata!" );
	}
}

public bacon_PlayerSpawn( id )
{
	if( is_user_alive( id ) )
	{
		gCountTimer[ id ] = 0;
		
		if( task_exists( id + TASK_RESPAWN_UNIQUE ) )
		{
			remove_task( id + TASK_RESPAWN_UNIQUE );
		}
		
		if( task_exists( id + TASK_TIME_UNIQUE ) )
		{
			remove_task( id + TASK_TIME_UNIQUE );
		}
	}
}
