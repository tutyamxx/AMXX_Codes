
#include < amxmodx >
#include < amxmisc >

#include < hamsandwich >

#pragma semicolon 1

#define PLUGIN_VERSION		"1.0.5"
#define IS_PLAYER(%1)		( 1 <= %1 <= gMaxPlayers )

new const szCounterTerrSprite[ ] = "sprites/teamspr/ct_blue.spr";
new const szTerrSprite[ ] = "sprites/teamspr/t_red.spr";

new gCounterTerrSpriteModel;
new gTerrSpriteModel;

new gCvarSpriteTime;
new gCvarPluginMode;
new gMaxPlayers;

public plugin_init( )
{
	register_plugin( "Team Icon Spr", PLUGIN_VERSION, "tuty" );
	
	register_event( "DeathMsg", "Event_DeathMsg", "a" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawned", 1 );
	
	register_clcmd( "say /teamspr", "command_CreateSprite" );
        register_clcmd( "say_team /teamspr", "command_CreateSprite" );

        register_clcmd( "say /delspr", "command_RemoveSprite" );
        register_clcmd( "say_team /delspr", "command_RemoveSprite" );

	gCvarSpriteTime = register_cvar( "teamspr_sprite_time", "32767" );
	gCvarPluginMode = register_cvar( "teamspr_mode", "2" );
	
	gMaxPlayers = get_maxplayers( );

	register_dictionary( "teamspr.txt" );
}

public plugin_precache( )
{
	gCounterTerrSpriteModel = precache_model( szCounterTerrSprite );
	gTerrSpriteModel = precache_model( szTerrSprite );
}

public bacon_PlayerSpawned( const id )
{
	if( is_user_alive( id ) 
	&& !is_user_hltv( id )
	&& !is_user_bot( id ) )
	{
		switch( get_pcvar_num( gCvarPluginMode ) )
            	{
                	case 0:	{ }
                	case 1: UTIL_RemoveSprite( id );
                	case 2:
			{
				UTIL_RemoveSprite( id );
				UTIL_CreateSprite( id );
			}
                }
	}
	
	return HAM_IGNORED;
}

public Event_DeathMsg( )
{
	new iVictim = read_data( 2 );
	
	if( IS_PLAYER( iVictim ) )
	{
		UTIL_RemoveSprite( iVictim );
	}
}

public command_CreateSprite( id )
{
	new iCvarMode = get_pcvar_num( gCvarPluginMode );

	if( iCvarMode == 0 )
	{
		client_print( id, print_chat, "%L", id, "CANNOT_CREATE" );
		client_cmd( id, "speak buttons/blip1.wav" );

		UTIL_RemoveSprite( id );
            
		return PLUGIN_HANDLED;
	}
        
	else if( iCvarMode != 1 )
	{
		client_print( id, print_chat, "%L", id, "ALLREADY_HAVE" );
		client_cmd( id, "speak buttons/blip1.wav" );
            
		return PLUGIN_HANDLED;
	}
        
	UTIL_RemoveSprite( id );
	UTIL_CreateSprite( id );

	client_print( id, print_chat, "%L", id, "SUCCESSFULLY_CREATED" );
	client_cmd( id, "speak fvox/activated.wav" );
        
	return PLUGIN_CONTINUE;
}

public command_RemoveSprite( id )
{
	new iCvarMode = get_pcvar_num( gCvarPluginMode );

	if( iCvarMode == 0 )
	{
		client_print( id, print_chat, "%L", id, "CANNOT_CREATE" );
		client_cmd( id, "speak buttons/blip1.wav" );
            
		return PLUGIN_HANDLED;
	}
	
	else if( iCvarMode != 1 )
	{
		client_print( id, print_chat, "%L", id, "MUST_STAY_UP" );
		client_cmd( id, "speak buttons/blip1.wav" );
            
		return PLUGIN_HANDLED;
	}
	
	UTIL_RemoveSprite( id );
	
	client_print( id, print_chat, "%L", id, "SUCCESSFULLY_DELETED" );
	client_cmd( id, "speak fvox/deactivated.wav" );
        
        return PLUGIN_CONTINUE;
}

stock UTIL_CreateSprite( id )
{
	message_begin( MSG_ALL, SVC_TEMPENTITY );
	write_byte( TE_PLAYERATTACHMENT );
	write_byte( id );
	write_coord( 45 );
	write_short( ( get_user_team( id ) == 1 ) ? gTerrSpriteModel : gCounterTerrSpriteModel ); 
	write_short( get_pcvar_num( gCvarSpriteTime ) );
	message_end( );
}

stock UTIL_RemoveSprite( id )
{
	message_begin( MSG_ALL, SVC_TEMPENTITY );
	write_byte( TE_KILLPLAYERATTACHMENTS );
	write_byte( id );
	message_end( );
}
