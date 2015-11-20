
#include < amxmodx >

#include < fakemeta >
#include < hamsandwich >
#include < xs >

#pragma semicolon 1

#define IsPlayer(%1)		(1 <= %1 <= gMaxPlayers)
#define write_coord_f(%0)	(engfunc( EngFunc_WriteCoord, %0 ))
#define BREAK_TRANS		0x20

const m_bLightSmoke = 114;
const m_bIsC4 = 96;
const m_XoGrenade = 5;

new gSpriteShockwave;
new gMaxPlayers;
new gExplodeModel;
new gCvarKnockBackPower;
new gCvarExplosionRadius;
new gCvarInstantExplode;

new const gFbExplodeSound[ ] = "x/x_shoot1.wav";
new const gFbExplodeModel[ ] = "models/w_flashbang.mdl";

public plugin_init( )
{
	register_plugin( "ShockWave FB", "1.1.0", "tuty" );
	
	RegisterHam( Ham_Think, "grenade", "bacon_Think" );
	RegisterHam( Ham_Touch, "grenade", "bacon_Touch", 1 );
	
	gCvarInstantExplode = register_cvar( "fb_instantexplo", "1" );
	gCvarKnockBackPower = register_cvar( "fb_knockback", "200.0" );
	gCvarExplosionRadius = register_cvar( "fb_exploradius", "350.0" );
	
	gMaxPlayers = get_maxplayers( );
}

public plugin_precache( )
{
	gSpriteShockwave = precache_model( "sprites/shockwave.spr" );
	gExplodeModel = precache_model( gFbExplodeModel );

	precache_sound( gFbExplodeSound );
}

public bacon_Think( iEnt )
{
	new Float:flGameTime = get_gametime( );
	new iOwner;

	new Float:flDmgTime;
	pev( iEnt, pev_dmgtime, flDmgTime );

	if( flDmgTime <= flGameTime
	&& get_pdata_int( iEnt, m_bLightSmoke, m_XoGrenade ) == 0
    	&& !( get_pdata_int( iEnt, m_bIsC4, m_XoGrenade ) & ( 1<<8 ) )
	&& IsPlayer( ( iOwner = pev( iEnt, pev_owner ) ) ) )
    	{
		emit_sound( iEnt, CHAN_WEAPON, gFbExplodeSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		UTIL_KnockBack( iEnt, iOwner, get_pcvar_float( gCvarKnockBackPower ), get_pcvar_float( gCvarExplosionRadius ) );

		set_pev( iEnt, pev_flags, pev( iEnt, pev_flags ) | FL_KILLME );

		return HAM_SUPERCEDE;
	}
	 
	return HAM_IGNORED;
}

public bacon_Touch( iEnt )
{
	if( get_pdata_int( iEnt, m_bLightSmoke, m_XoGrenade ) == 0
    	&& !( get_pdata_int( iEnt, m_bIsC4, m_XoGrenade ) & ( 1<<8 ) )
	&& IsPlayer( ( pev( iEnt, pev_owner ) ) )
	&& get_pcvar_num( gCvarInstantExplode ) == 1 )
    	{
		set_pev( iEnt, pev_dmgtime, 0.0 );
		
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

stock UTIL_KnockBack( iEnt, id, Float:flKnockBack, Float:flRadius )
{
	new Float:flEntOrigin[ 3 ];
	pev( iEnt, pev_origin, flEntOrigin );

	UTIL_BreakModel( flEntOrigin, gExplodeModel, BREAK_TRANS );

	UTIL_Cylinder( flEntOrigin, 100 );
	UTIL_Cylinder( flEntOrigin, 200 );
	UTIL_Cylinder( flEntOrigin, floatround( get_pcvar_float( gCvarExplosionRadius ) ) );

	new iClient = FM_NULLENT, Float:flClientOrigin[ 3 ], Float:flDistance;

    	while( ( iClient = engfunc( EngFunc_FindEntityInSphere, iClient, flEntOrigin, flRadius ) ) )
    	{
		if( IsPlayer( iClient ) 
		&& is_user_alive( iClient ) 
		&& get_user_team( id ) != get_user_team( iClient ) )
		{
			pev( iClient, pev_origin, flClientOrigin );
       			flDistance = get_distance_f( flEntOrigin, flClientOrigin );

			if( flDistance <= flRadius )
			{
				new Float:flVelocity[ 3 ];
 
				xs_vec_sub( flClientOrigin, flEntOrigin, flClientOrigin );
				xs_vec_normalize( flClientOrigin, flClientOrigin );
				pev( iClient, pev_velocity, flVelocity );
 
    				xs_vec_mul_scalar( flClientOrigin, floatmul( flKnockBack, 800.0 ), flClientOrigin );
    				xs_vec_add( flVelocity, flClientOrigin, flVelocity );

    				set_pev( iClient, pev_velocity, flVelocity );
			}
		}
	}
}			

stock UTIL_Cylinder( Float:flOrigin[ 3 ], flRadius )
{
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord_f( flOrigin[ 0 ] ); 
	write_coord_f( flOrigin[ 1 ] ); 
	write_coord_f( flOrigin[ 2 ] ); 
	write_coord_f( flOrigin[ 0 ] ); 
	write_coord_f( flOrigin[ 1 ] ); 
	write_coord_f( flOrigin[ 2 ] + flRadius ); 
	write_short( gSpriteShockwave ); 
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 4 );
	write_byte( 40 );
	write_byte( 0 );
	write_byte( 10 ); 
	write_byte( 255 ); 
	write_byte( 10 );
	write_byte( 200 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_BreakModel( Float:flOrigin[ 3 ], model, flags )
{
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0 );
	write_byte( TE_BREAKMODEL );
	write_coord_f( flOrigin[ 0 ] );
	write_coord_f( flOrigin[ 1 ] );
	write_coord_f( flOrigin[ 2 ] );
	write_coord( 16 );
	write_coord( 16 );
	write_coord( 16 );
	write_coord( random_num( -20, 20 ) );
	write_coord( random_num( -20, 20 ) );
	write_coord( 10 );
	write_byte( 10 );
	write_short( model );
	write_byte( 10 );
	write_byte( 9 );
	write_byte( flags );
	message_end( );
}
