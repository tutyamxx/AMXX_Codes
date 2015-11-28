
#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >

#pragma semicolon 1

#define MINIM_AFK_TIME		30
#define AFK_WARNING_TIME	15
#define PLUGIN_VERSION		"1.0.0"

#define TEAM_TERRORIST		1
#define TEAM_CT			2

new gOldOrigin[ 33 ][ 3 ];
new gAfkTime[ 33 ];

new bool:bSpawned[ 33 ] = false;

new gCvarAfkTime;
new gMaxPlayers;
new gHudSync;
new gHudSync2;

public plugin_init()
{
	register_plugin( "Tuty's AFK Detector", PLUGIN_VERSION, "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawned", 1 );
	set_task( 5.0, "CheckPlayersOrigin", _, _, _, "b" );
	
	gCvarAfkTime = register_cvar( "mp_afktime", "90" );
	gMaxPlayers = get_maxplayers();
	gHudSync = CreateHudSyncObj();
	gHudSync2 = CreateHudSyncObj();
}

public client_putinserver( id )
{
	gAfkTime[ id ] = 0;
}

public bacon_PlayerSpawned( id )
{
	if( is_user_alive( id ) )
	{
		set_task( 1.0, "GetCurrentOrigin", id );
	}
}

public GetCurrentOrigin( id )
{
	get_user_origin( id, gOldOrigin[ id ], 0 );
	
	bSpawned[ id ] = true;
}

public CheckPlayersOrigin()
{
	new id;

	for( id = 1; id <= gMaxPlayers; id++ )
	{
		if( is_user_alive( id ) 
		&& is_user_connected( id ) 
		&& !is_user_bot( id ) 
		&& !is_user_hltv( id ) 
		&& bSpawned[ id ] == true )
		{
			new iPlayerOrigin[ 3 ];
			get_user_origin( id, iPlayerOrigin, 0 );

			if( iPlayerOrigin[ 0 ] == gOldOrigin[ id ][ 0 ] 
			&&  iPlayerOrigin[ 1 ] == gOldOrigin[ id ][ 1 ] 
			&&  iPlayerOrigin[ 2 ] == gOldOrigin[ id ][ 2 ] )
			{
				gAfkTime[ id ] += 5;
				CheckAfkTime( id );
			}
			
			else
			{
				gOldOrigin[ id ][ 0 ] = iPlayerOrigin[ 0 ];
				gOldOrigin[ id ][ 1 ] = iPlayerOrigin[ 1 ];
				gOldOrigin[ id ][ 2 ] = iPlayerOrigin[ 2 ];
				
				gAfkTime[ id ] = 0;
			}
		}
	}
}

public CheckAfkTime( id )
{
	new iAfkTime = get_pcvar_num( gCvarAfkTime );
	
	new szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );

	if( iAfkTime < MINIM_AFK_TIME )
	{
		log_amx( "Cvarul <mp_afktime> este setat pe <%d> si e prea mic! Valoarea minima este: <%d>", iAfkTime, MINIM_AFK_TIME );
		set_pcvar_num( iAfkTime, MINIM_AFK_TIME );
	}

	if( iAfkTime - AFK_WARNING_TIME <= gAfkTime[ id ] < iAfkTime  )
	{
		if( get_user_team( id ) == TEAM_TERRORIST )
		{
			set_hudmessage( 255, 110, 180, 0.02, 0.18, 1, 6.0, 6.0 );
			ShowSyncHudMsg( 0, gHudSync2, "Teroristul %s e AFK!", szName );
			
			client_cmd( 0, "speak houndeye/he_pain2.wav" );
			gAfkTime[ id ] = 0;
		}
		
		else if( get_user_team( id ) == TEAM_CT )
		{
			new iTimeleft = iAfkTime - gAfkTime[ id ];
		
			set_hudmessage( 255, 0, 0, -1.0, 0.78, 1, 6.0, 3.0 );
			ShowSyncHudMsg( id, gHudSync, "Ai %d secunde sa te misti sau vei primi KICK!", iTimeleft );
		
			client_cmd( id, "speak buttons/blip2.wav" );
		}
	}
	
	else if( gAfkTime[ id ] > iAfkTime && get_user_team( id ) == TEAM_CT )
	{
		client_print( 0, print_chat, "* %s a primit kick pentru ca a fost AFK mai mult de %d secunde!", szName, iAfkTime );
		log_amx( "%s a primit kick pentru ca a fost AFK mai mult de %d secunde!", szName, iAfkTime );

		server_cmd( "kick #%d ^"Ai primit KICK pentru ca ai fost AFK!^"", get_user_userid( id ) );
		bSpawned[ id ] = false;
	}
}
