
#include < amxmodx >

#include < fakemeta >
#include < hamsandwich >
#include < engine >
#include < cstrike >
#include < xs >

#pragma semicolon 1

#define AFLOCK_DAMAGE		15.0
#define AFLOCK_DELAY		1.0

new const gAflockModel[ ] = "models/aflock.mdl";
new const gAflockClassname[ ] = "AflockKamikaze";

new const gAflockShootSounds[ ][ ] =
{
	"aslave/slv_alert1.wav",
	"aslave/slv_alert3.wav",
	"aslave/slv_alert4.wav"
};

new const gAflockHitSounds[ ][ ] =
{
	"aslave/slv_pain1.waV",
	"aslave/slv_pain2.wav"
};

new gBeamSprite;
new gFlareSprite;
new gHitDecal;
new gMaxPlayers;

new Float:flLastAflock[ 33 ];

public plugin_init( )
{
	register_plugin( "Aflock Kamikaze", "1.0.1", "tuty" );
	
	register_clcmd( "drop", "CommandShootAflock" );
	register_logevent( "Log_RoundEnd", 2, "1=Round_End" );
	
	register_think( gAflockClassname, "forward_AflockThink" );

	register_touch( gAflockClassname, "worldspawn", "forward_AflockTouchWorld" );
	register_touch( gAflockClassname, "player", "forward_AflockKill" );
	
	gMaxPlayers = get_maxplayers( );
}

public plugin_precache( )
{
	gBeamSprite = precache_model( "sprites/laserbeam.spr" );
	gFlareSprite = precache_model( "sprites/redflare2.spr" );
	gHitDecal = engfunc( EngFunc_DecalIndex, "{crack1" );

	precache_model( gAflockModel );

	new i;
	for( i = 0; i < sizeof gAflockShootSounds; i++ )
	{
		precache_sound( gAflockShootSounds[ i ] );
	}
	
	for( i = 0; i < sizeof gAflockHitSounds; i++ )
	{
		precache_sound( gAflockHitSounds[ i ] );
	}
}

public CommandShootAflock( id )
{
	if( !is_user_alive( id ) || get_user_weapon( id ) != CSW_KNIFE )
	{
		return PLUGIN_CONTINUE;
	}

	new Float:flGameTime = get_gametime( );
	
	if( flGameTime - flLastAflock[ id ] < AFLOCK_DELAY )
	{
		return PLUGIN_HANDLED;
	}
	
	new Float:flOrigin[ 3 ];
	pev( id, pev_origin, flOrigin );

	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	engfunc( EngFunc_SetModel, iEntity, gAflockModel );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );

	UTIL_GetStartPosition( id, 37.0, 0.0, 13.0, flOrigin );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_classname, gAflockClassname );
	set_pev( iEntity, pev_solid, SOLID_TRIGGER );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_owner, id );
	set_pev( iEntity, pev_framerate, 1.0 );
	set_pev( iEntity, pev_sequence, 1 );
	
	new Float:flVelocity[ 3 ];
	velocity_by_aim( id, random_num( 300, 700 ), flVelocity );

	set_pev( iEntity, pev_velocity, flVelocity );
	set_pev( iEntity, pev_nextthink, flGameTime + 0.1 );
	
	UTIL_BeamFollow( iEntity, gBeamSprite, 20, 7, 255, 10, 10 );
	set_rendering( iEntity, kRenderFxGlowShell, 255, 10, 10, kRenderNormal, 30 );
	emit_sound( id, CHAN_STATIC, gAflockShootSounds[ random_num( 0, charsmax( gAflockShootSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	flLastAflock[ id ] = flGameTime;

	return PLUGIN_HANDLED;
}

public forward_AflockKill( iEnt, iPlayer )
{
	if( pev_valid( iEnt ) )
	{
		new iOwner = pev( iEnt, pev_owner );
		set_pev( iEnt, pev_flags, FL_KILLME );

		if( cs_get_user_team( iOwner ) != cs_get_user_team( iPlayer ) )
		{
			new Float:flOrigin[ 3 ], iOrigin[ 3 ];

			pev( iPlayer, pev_origin, flOrigin );
			FVecIVec( flOrigin, iOrigin );

			UTIL_BlowSprite( iOrigin, gFlareSprite );
			ExecuteHam( Ham_TakeDamage, iPlayer, iEnt, iOwner, AFLOCK_DAMAGE, DMG_SLASH );
			emit_sound( iPlayer, CHAN_BODY, gAflockHitSounds[ random_num( 0, charsmax( gAflockHitSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
	}
}

public forward_AflockTouchWorld( iEnt, iWorld )
{
	if( pev_valid( iEnt ) )
	{
		new Float:flOrigin[ 3 ], iOrigin[ 3 ];

		pev( iEnt, pev_origin, flOrigin );
		FVecIVec( flOrigin, iOrigin );
		
		UTIL_WorldDecal( iOrigin, gHitDecal );
		emit_sound( iEnt, CHAN_STATIC, gAflockHitSounds[ random_num( 0, charsmax( gAflockHitSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		set_pev( iEnt, pev_flags, FL_KILLME );
	}
}

public forward_AflockThink( iEnt )
{
	if( pev_valid( iEnt ) )
	{
		new iOwner = pev( iEnt, pev_owner );
		
		set_pev( iEnt, pev_framerate, 1.0 );
		set_pev( iEnt, pev_sequence, 1 );
		set_pev( iEnt, pev_nextthink, get_gametime( ) + 0.1 );
		
		new Float:flDirection[ 3 ], Float:flOrigin[ 3 ], Float:flTarget[ 3 ], iPlayer;
	
		pev( iEnt, pev_origin, flOrigin );
		pev( iEnt, pev_velocity, flDirection );
	
		if( !( iPlayer = pev( iEnt, pev_enemy ) ) )
		{
			new iNearestEnt = 0;
			new Float:flNearestDist = 9999.0;
			new Float:flDist = 0.0;
		
			while( 1 <= ( iPlayer = find_ent_in_sphere( iPlayer, flOrigin, 1000.0 ) ) <= gMaxPlayers )
			{
				if( !is_user_alive( iPlayer ) || cs_get_user_team( iOwner ) == cs_get_user_team( iPlayer ) )
				{
					continue;
				}
			
				pev( iPlayer, pev_origin, flTarget );   
			
				if( trace_line( iEnt, flOrigin, flTarget, flTarget ) != iPlayer )
				{
					continue;
				}
			
				pev( iPlayer, pev_origin, flTarget );
				xs_vec_sub( flTarget, flOrigin, flTarget );
			
				flDist = xs_vec_len( flTarget );
			
				if( flDist < flNearestDist )
				{
					iNearestEnt = iPlayer;
					flNearestDist = flDist;
				}
			}
		
			iPlayer = iNearestEnt;
		
			if( iPlayer > 0 )
			{
				set_pev( iEnt, pev_enemy, iPlayer );
			}
		}
	
		if( iPlayer )
		{
			pev( iPlayer, pev_origin, flTarget );

			xs_vec_sub( flTarget, flOrigin, flTarget );
			xs_vec_normalize( flTarget, flTarget );
		
			xs_vec_mul_scalar( flTarget, 400.0, flTarget );
			xs_vec_add( flDirection, flTarget, flDirection );
		}
	
		xs_vec_normalize( flDirection, flDirection );
		xs_vec_mul_scalar( flDirection, random_float( 400.0, 600.0 ), flDirection );

		set_pev( iEnt, pev_velocity, flDirection );
		vector_to_angle( flDirection, flDirection );
		set_pev( iEnt, pev_angles, flDirection );
	}
}

public Log_RoundEnd( )
{
	remove_entity_name( gAflockClassname );
}

stock UTIL_WorldDecal( iOrigin[ 3 ], iDecal )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_WORLDDECAL );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_byte( iDecal );
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

stock UTIL_BeamFollow( ent, sprite, life, width, r, g, b )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( ent );
	write_short( sprite );
	write_byte( life );
	write_byte( width ); 
	write_byte( r ); 
	write_byte( g ); 
	write_byte( b ); 
	write_byte( 200 );
	message_end( );
}

stock UTIL_BlowSprite( iOrigin[ 3 ], sprite )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_SPRITETRAIL );
	write_coord( iOrigin[ 0 ] );		
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( sprite );
	write_byte( 10 );
	write_byte( random_num( 1, 3 ) );
	write_byte( 3 );
	write_byte( random_num( 7, 12 ) );
	write_byte( 20 );
	message_end( );
}
