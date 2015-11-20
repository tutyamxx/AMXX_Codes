
#include < amxmodx >
#include < hamsandwich >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

#define VOMIT_COLOR	82
#define VOMIT_SOUND	"misc/vomit.wav"

new gDeadBodyOrigins[ 33 ][ 3 ];
new Float:gVomitTime[ 33 ];

new gHudSync;
new gCvarVomitInterval;

public plugin_init()
{
	register_plugin( "Puke", PLUGIN_VERSION, "tuty" );
	
	register_event( "DeathMsg", "Hook_DeathMessage", "a" );
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawn", 1 );

	register_clcmd( "vomit", "commandVomitOnBody" );
	
	gCvarVomitInterval = register_cvar( "vomit_time", "20" );
	
	gHudSync = CreateHudSyncObj();
}

public plugin_precache()
{
	precache_sound( VOMIT_SOUND );
}

public commandVomitOnBody( id )
{
	if( !is_user_alive( id ) )
	{
		client_print( id, print_center, "Nu poti vomita cand esti mort!" );
		
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime();
	new iTimeDelay = get_pcvar_num( gCvarVomitInterval );
	
	if( flGameTime - gVomitTime[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Nu poti vomita acum, asteapta %d secunde!", floatround( gVomitTime[ id ] + iTimeDelay - flGameTime ) );
		
		return PLUGIN_HANDLED;
	}
	
	new iOrigin[ 3 ];
	get_user_origin( id, iOrigin, 0 );
	
	new iPlayers[ 32 ], iNum, iPlayer, i;
	get_players( iPlayers, iNum, "bh" );
	
	for( i = 0; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];

		if( iPlayer != id )
		{
			if( get_distance( iOrigin, gDeadBodyOrigins[ iPlayer ] ) < 80 )
			{
				new szName[ 32 ], szDeadName[ 32 ];
				
				get_user_name( id, szName, charsmax( szName ) );
				get_user_name( iPlayer, szDeadName, charsmax( szDeadName ) );
				
				set_hudmessage( 255, 0, 0, -1.0, 0.26, 1, 6.0, 8.0 );
				ShowSyncHudMsg( 0, gHudSync, "%s VOMITA pe cadavrul lui %s AHAHAHA!", szName, szDeadName );
				
				emit_sound( id, CHAN_VOICE, VOMIT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				set_task( 0.3, "VomitEffect", id + 1233210, _, _, "a", 10 );
				
				gVomitTime[ id ] = flGameTime;
			}
			
			else
			{
				client_print( id, print_center, "Nu sunt cadavre in jurul tau!" );
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public VomitEffect( taskid )
{
	new id = taskid - 1233210;
	
	new iOrigin1[ 3 ], iAimOrigin[ 3 ], Float:flVelocity[ 3 ];
	
	get_user_origin( id, iOrigin1, 1 );
	get_user_origin( id, iAimOrigin, 3 );

	new iDistance = get_distance( iOrigin1, iAimOrigin );
	new iSpeed = floatround( iDistance * 1.9 );
	
	flVelocity[ 0 ] = float( iAimOrigin[ 0 ] ) - float( iOrigin1[ 0 ] );
	flVelocity[ 1 ] = float( iAimOrigin[ 1 ] ) - float( iOrigin1[ 1 ] );
	flVelocity[ 2 ] = float( iAimOrigin[ 2 ] ) - float( iOrigin1[ 2 ] );

	new Float:iLength = floatsqroot( flVelocity[ 0 ] * flVelocity[ 0 ] + flVelocity[ 1 ] * flVelocity[ 1 ] + flVelocity[ 2 ] * flVelocity[ 2 ] );
	
	flVelocity[ 0 ] = flVelocity[ 0 ] * iSpeed / floatround( iLength );
	flVelocity[ 1 ] = flVelocity[ 1 ] * iSpeed / floatround( iLength );
	flVelocity[ 2 ] = flVelocity[ 2 ] * iSpeed / floatround( iLength );
	
	new iVelocity[ 3 ];
	FVecIVec( flVelocity, iVelocity );
	
	UTIL_BloodStream( iOrigin1, iVelocity, VOMIT_COLOR, 160 );
}

public bacon_PlayerSpawn( id )
{
	if( is_user_alive( id ) )
	{
		if( task_exists( id + 1233210 ) )
		{
			remove_task( id + 1233210 );
		}
	}
}
		
public Hook_DeathMessage()
{
	new iVictim = read_data( 2 );
	
	get_user_origin( iVictim, gDeadBodyOrigins[ iVictim ], 0 );
	
	if( task_exists( iVictim + 1233210 ) )
	{
		remove_task( iVictim + 1233210 );
	}
}

stock UTIL_BloodStream( iPosition[ 3 ], iVector[ 3 ], iColor, iSpeed )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BLOODSTREAM );
	write_coord( iPosition[ 0 ] );
	write_coord( iPosition[ 1 ] );
	write_coord( iPosition[ 2 ] );
	write_coord( iVector[ 0 ] );
	write_coord( iVector[ 1 ] );
	write_coord( iVector[ 2 ] );
	write_byte( iColor );
	write_byte( iSpeed );
	message_end();
}
