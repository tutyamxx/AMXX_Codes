
#include <amxmodx>
#include <amxmisc>

#pragma semicolon 1

#define PLUGIN_NAME		"Winner Of The Game"
#define PLUGIN_VERSION 		"1.0"
#define PLUGIN_AUTHOR 		"tuty"

#define ONE_FRAG_LEFT		"misc/1frag.wav"
#define TWO_FRAGS_LEFT		"misc/2frags.wav"
#define THREE_FRAGS_LEFT	"misc/3frags.wav"

new gFragLimit;
new gHusSync;
new gNextMap;

public plugin_init()
{
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
	
	register_event( "DeathMsg", "Hook_DeathMessage", "a" );
	register_event( "30", "Hook_EventIntermission", "a" );
	
	gFragLimit = get_cvar_pointer( "mp_fraglimit" );
	gNextMap = get_cvar_pointer( "amx_nextmap" );
	
	gHusSync = CreateHudSyncObj();
}

public plugin_precache()
{
	precache_sound( ONE_FRAG_LEFT );
	precache_sound( TWO_FRAGS_LEFT );
	precache_sound( THREE_FRAGS_LEFT );
}
	
public Hook_DeathMessage()
{
	new iKiller = read_data( 1 );
	new iVictim = read_data( 2 );
	
	if( iKiller == iVictim )
	{
		return PLUGIN_CONTINUE;
	}

	new iKillerFrags = get_user_frags( iKiller );
	iKillerFrags++;
	
	new iFragsLeft = get_pcvar_num( gFragLimit ) - iKillerFrags;
	
	new szName[ 32 ];
	get_user_name( iKiller, szName, charsmax( szName ) );
	
	if( iKillerFrags >= 0 )
	{
		switch( iFragsLeft )
		{
			case 1:
			{
				set_hudmessage( 255, 0, 0, 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2 );
				ShowSyncHudMsg( 0, gHusSync, "[ %s ] >>>>>>> 1 FRAG LEFT !!! <<<<<<<", szName );
				
				client_cmd( 0, "speak %s", ONE_FRAG_LEFT );
			}
			
			case 2:
			{
				set_hudmessage( 0, 0, 255, 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2 );
				ShowSyncHudMsg( 0, gHusSync, "[ %s ] >>>>>>> 2 FRAGS LEFT !!! <<<<<<<", szName );
				
				client_cmd( 0, "speak %s", TWO_FRAGS_LEFT );
			}
		
			case 3:
			{
				set_hudmessage( 0, 255, 0, 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2 );
				ShowSyncHudMsg( 0, gHusSync, "[ %s ] >>>>>>> 3 FRAGS LEFT !!! <<<<<<<", szName );
				
				client_cmd( 0, "speak %s", THREE_FRAGS_LEFT );
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public Hook_EventIntermission()
{
	new iPlayers[ 32 ], iNum, Index, szName[ 32 ];
	get_players( iPlayers, iNum, "cgh" );
	
	new iMaxFrags = get_pcvar_num( gFragLimit );
	
	new szMap[ 32 ];
	get_pcvar_string( gNextMap, szMap, charsmax( szMap ) );
	
	for( new i = 0; i < iNum; i++ )
	{
		Index = iPlayers[ i ];
		
		get_user_name( Index, szName, charsmax( szName ) );
		
		if( get_user_frags( Index ) == iMaxFrags )
		{
			client_print( 0, print_chat, "* %s win this round with %d frag(s)!", szName, iMaxFrags );
			client_print( 0, print_chat, "* The next battle map will be (%s)", szMap );
			
			client_cmd( Index, "speak ^"holo/tr_holo_fantastic tr_holo_keeptrying^"" );
		}
	}
}
