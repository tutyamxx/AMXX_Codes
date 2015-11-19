
#include < amxmodx >

#include < fakemeta >
#include < engine >
#include < hamsandwich >

#tryinclude < biohazard >

#define PLUGIN_VERSION		"1.0.3"
#define is_player(%1)		(1 <= %1 <= gMaxPlayers)

#define BREAK_FLESH		0x04
#define THROW_DISTANCE		2200
#define EXPLOSION_DELAY		5.0
#define EXPLODE_RADIUS		250

new const gHeadcrabSound[ ] = "headcrab/hc_attack2.wav";
new const gHeadcrabExpSound[ ] = "squeek/sqk_blast1.wav";

new const gExplosionSprite[ ] = "sprites/flare6.spr";
new const gWaveSprite[ ] = "sprites/shockwave.spr";
new const gTrailSprite[ ] = "sprites/laserbeam.spr";

new const gHeadCrabModel[ ] = "models/headcrab.mdl";
new const gHeadCrabModelT[ ] = "models/headcrabt.mdl";
new const gFleshModel[ ] = "models/agibs.mdl";

new bool:bHasHeadcrab[ 33 ] = false;

new gTSprite;
new gESprite;
new gWSprite;
new gMaxPlayers;
new gFleshMdl;

public plugin_init( )
{
	register_plugin( "BIO Zombie Headcrab", PLUGIN_VERSION, "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawned", 1 );
	register_event( "DeathMsg", "EVENT_Death", "a" );
	register_logevent( "RoundEND", 2, "1=Round_End" );
	register_logevent( "RoundSTART", 2, "1=Round_Start" );
	
	register_clcmd( "drop", "CommandDrop" );
	
	gMaxPlayers = get_maxplayers( );
}

public plugin_precache( )
{
	gTSprite = precache_model( gTrailSprite );
	gESprite = precache_model( gExplosionSprite );
	gWSprite = precache_model( gWaveSprite );
	gFleshMdl = precache_model( gFleshModel );

	precache_model( gHeadCrabModel );
	precache_model( gHeadCrabModelT );	
	
	precache_sound( gHeadcrabSound );
	precache_sound( gHeadcrabExpSound );
}

public client_connect( id )
{
	bHasHeadcrab[ id ] = false;
}

public EVENT_Death( )
{
	bHasHeadcrab[ read_data( 2 ) ] = false;
}

public bacon_PlayerSpawned( id )
{
	if( is_user_alive( id ) )
	{
		bHasHeadcrab[ id ] = false;
	}
}

public event_infect( victim, attacker )
{
	bHasHeadcrab[ victim ] = true;
}

public RoundEND( )
{
	new iEnt = FM_NULLENT;
	
	while( ( iEnt = find_ent_by_class( iEnt, "_ToxicHeadcrab" ) ) )
	{
		remove_task( iEnt );
		set_pev( iEnt, pev_flags, pev( iEnt, pev_flags ) | FL_KILLME );
	}
}	

public RoundSTART( )
{
	new iEnt = FM_NULLENT;
	
	while( ( iEnt = find_ent_by_class( iEnt, "_ToxicHeadcrab" ) ) )
	{
		remove_task( iEnt );
		set_pev( iEnt, pev_flags, pev( iEnt, pev_flags ) | FL_KILLME );
	}
}	
	
public CommandDrop( id )
{
	if( !is_user_alive( id ) || !is_user_zombie( id )
	|| is_user_bot( id ) || bHasHeadcrab[ id ] == false
	|| get_user_weapon( id ) != CSW_KNIFE )
	{
		return PLUGIN_CONTINUE;
	}
	
	ThrowDamnHeadCrab( id );
	
	return PLUGIN_HANDLED;
}

public ThrowDamnHeadCrab( id )
{
	new Float:flOrigin[ 3 ], Float:flVelocity[ 3 ], Float:flForward[ 3 ], Float:flAngles[ 3 ];		
					
	pev( id, pev_origin, flOrigin );
	pev( id, pev_velocity, flVelocity );
	pev( id, pev_v_angle, flForward );
		
	new iDistance = THROW_DISTANCE;
	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	pev( iEntity, pev_angles, flAngles );
	flAngles[ 1 ] += random_float( 1.0, 360.0 );

	set_pev( iEntity, pev_classname, "_ToxicHeadcrab" );
	engfunc( EngFunc_SetModel, iEntity, gHeadCrabModel );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -12.000000, -12.000000, 0.000000 }, Float:{ 12.000000, 12.000000, 24.000000 } );

	UTIL_GetStartPosition( id, 37.0, 0.0, 13.0, flOrigin )
	set_pev( iEntity, pev_origin, flOrigin );

	set_pev( iEntity, pev_solid, SOLID_BBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_TOSS );	
	set_pev( iEntity, pev_iuser2, id );
	
	engfunc( EngFunc_MakeVectors, flForward );
	global_get( glb_v_forward, flForward );
					
	flForward[ 0 ] = floatadd( floatmul( flForward[ 0 ], float( iDistance ) ), flVelocity[ 0 ] );
	flForward[ 1 ] = floatadd( floatmul( flForward[ 1 ], float( iDistance ) ), flVelocity[ 1 ] );
	flForward[ 2 ] = floatadd( floatmul( flForward[ 2 ], float( iDistance ) ), flVelocity[ 2 ] );
		
	set_pev( iEntity, pev_angles, flAngles );		
	set_pev( iEntity, pev_velocity, flForward );

	set_rendering( iEntity, kRenderFxGlowShell, 10, 255, 10, kRenderNormal, 5 );
	UTIL_BeamFollow( iEntity );
	set_task( EXPLOSION_DELAY, "ExplodeAndInfect", iEntity );
	emit_sound( id, CHAN_BODY, gHeadcrabSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	bHasHeadcrab[ id ] = false;
	
	return PLUGIN_HANDLED;
}

public ExplodeAndInfect( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		new Float:flOrigin[ 3 ], iOrigin[ 3 ];

		pev( iEntity, pev_origin, flOrigin );
		flOrigin[ 2 ] += 4.0;
		
		FVecIVec( flOrigin, iOrigin );
		
		UTIL_Cylinder( iOrigin, EXPLODE_RADIUS );
		UTIL_BlowSprite( iOrigin );	
		UTIL_ExplodeFlesh( iOrigin );
		UTIL_InfectInRadius( iEntity, float( EXPLODE_RADIUS ) );
		
		emit_sound( iEntity, CHAN_BODY, gHeadcrabExpSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		set_pev( iEntity, pev_flags, pev( iEntity, pev_flags ) | FL_KILLME );
	}	
}



/*
	Stocks
*/

stock UTIL_BeamFollow( iClient )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( iClient );
	write_short( gTSprite );
	write_byte( 7 );
	write_byte( 10 );
	write_byte( 10 );
	write_byte( 255 );
	write_byte( 10 );
	write_byte( 100 );
	message_end( );
}

stock UTIL_InfectInRadius( index, Float:flRadius )
{
	new Float:flEntityOrigin[ 3 ];
    	pev( index, pev_origin, flEntityOrigin );
    
    	new iEnt = FM_NULLENT;
	new Float:flClientOrigin[ 3 ], Float:flDistance;

	new iOwner = pev( index, pev_iuser2 );
	
	new szName[ 32 ];
	get_user_name( iOwner, szName, charsmax( szName ) );

    	while( ( iEnt = engfunc( EngFunc_FindEntityInSphere, iEnt, flEntityOrigin, flRadius ) ) )
    	{
		if( is_player( iEnt ) && is_user_alive( iEnt ) && !is_user_zombie( iEnt ) )
		{
			pev( iEnt, pev_origin, flClientOrigin );
       			flDistance = get_distance_f( flEntityOrigin, flClientOrigin );

			if( flDistance <= flRadius )
			{
				make_deathmsg( iOwner, iEnt, 0, "Infected Headcrab" );
       				infect_user( iEnt, iOwner );	
				client_print( iEnt, print_chat, "You got infected by %s's Infected Headcrab!", szName );
			}
    		}
	}
}

stock UTIL_Cylinder( iOrigin[ 3 ], iRadius )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[ 0 ] ); 
	write_coord( iOrigin[ 1 ] ); 
	write_coord( iOrigin[ 2 ] ); 
	write_coord( iOrigin[ 0 ] ); 
	write_coord( iOrigin[ 1 ] ); 
	write_coord( iOrigin[ 2 ] + iRadius ); 
	write_short( gWSprite ); 
	write_byte( 0 );
	write_byte( 0 ); 
	write_byte( 4 ); 
	write_byte( 16 );
	write_byte( 0 );
	write_byte( 10 ); 
	write_byte( 255 );
	write_byte( 10 ); 
	write_byte( 199 ); 
	write_byte( 0 ); 
	message_end( );
}

stock UTIL_BlowSprite( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_SPRITETRAIL );
	write_coord( iOrigin[ 0 ] );		
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( gESprite );
	write_byte( 50 );
	write_byte( random_num( 1, 3 ) );
	write_byte( 2 );
	write_byte( random_num( 20, 45 ) );
	write_byte( 20 );
	message_end( );
}

stock UTIL_GetStartPosition( id, Float:Forward = 0.0, Float:Right = 0.0, Float:Up = 0.0, Float:vecSource[ 3 ] )
{
	static Float:vecForward[ 3 ], Float:vecRight[ 3 ], Float:vecUp[ 3 ];
	static Float:vecPlayerAngles[ 3 ];
	
	pev( id, pev_origin, vecSource );
	pev( id, pev_v_angle, vecPlayerAngles );
	
	engfunc( EngFunc_MakeVectors, vecPlayerAngles );
	
	if( Forward > 0.0 ) global_get( glb_v_forward, vecForward );
	if( Right > 0.0 ) global_get( glb_v_right, vecRight );
	if( Up > 0.0 ) global_get( glb_v_up, vecUp );
	
	vecSource[ 0 ] += floatmul( vecForward[ 0 ], Forward ) + floatmul( vecRight[ 0 ], Right ) + floatmul( vecUp[ 0 ], Up );
	vecSource[ 1 ] += floatmul( vecForward[ 1 ], Forward ) + floatmul( vecRight[ 1 ], Right ) + floatmul( vecUp[ 1 ], Up );
	vecSource[ 2 ] += floatmul( vecForward[ 2 ], Forward ) + floatmul( vecRight[ 2 ], Right ) + floatmul( vecUp[ 2 ], Up );
}

stock UTIL_ExplodeFlesh( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin ); 
        write_byte( TE_BREAKMODEL);
        write_coord( iOrigin[ 0 ] );
        write_coord( iOrigin[ 1 ] );
        write_coord( iOrigin[ 2 ] + 14); 
        write_coord( 16 );
        write_coord( 16 ); 
        write_coord( 16 );
        write_coord( random_num( -50, 50 ) ); 
        write_coord( random_num( -50, 50 ) );
        write_coord( 25 );
        write_byte( 10 );
        write_short( gFleshMdl );
        write_byte( 10 );
        write_byte( 15 ); 
        write_byte( BREAK_FLESH );
        message_end( );  
}
