
#include < amxmodx >

#include < fakemeta >
#include < engine >
#include < fun >
#include < hamsandwich >

#pragma semicolon 1	

#define SMOKE_ID		071192
#define pev_valid2(%1)		( pev( %1, pev_iuser4 ) == SMOKE_ID ) ? 1 : 0

new gSmokeLightEnable;
new gLightTime;
new gDeployTime;
new gSpriteTrail;
new gSpriteCircle;
new gSpriteSmoke;
new gTrailEnable;
new gCylinderEnable;
new gGlowColorCvar;
new gSmokeCvar;
new gSmokeBonus;

new Float:flOrigin[ 3 ];
new iOrigin[ 3 ];

new const gSmokeModel[ ] = "models/w_smokegrenade.mdl";

new const gSmokeStartSound[ ] = "items/nvg_on.wav";
new const gSmokeStopSound[ ] = "items/nvg_off.wav";

public plugin_init( )
{
	register_plugin( "Light Smoke Grenade", "2.0.0", "tuty" );
	
	register_forward( FM_SetModel, "forward_SetModel" );
	register_forward( FM_Think, "forward_Think" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_Spawn", 1 );
	
	gSmokeLightEnable = register_cvar( "lightsmoke_enabled", "1" );
	gLightTime = register_cvar( "lightsmoke_light_duration", "20.0" );
	gDeployTime = register_cvar( "lightsmoke_deploytime", "3.0" );
	gTrailEnable = register_cvar( "lightsmoke_trail", "1" );
	gCylinderEnable = register_cvar( "lightsmoke_cylinder", "1" );
	gSmokeCvar = register_cvar( "lightsmoke_smoke", "1" );
	gGlowColorCvar = register_cvar( "lightsmoke_glow_color", "255 255 255" );
	gSmokeBonus = register_cvar( "lightsmoke_bonus", "1" );
}

public plugin_precache( )
{
	gSpriteTrail = precache_model( "sprites/laserbeam.spr" );
	gSpriteCircle = precache_model( "sprites/shockwave.spr" );
	gSpriteSmoke = precache_model( "sprites/steam1.spr" );
	
	precache_model( gSmokeModel );
	
	precache_sound( gSmokeStartSound );
	precache_sound( gSmokeStopSound );
}

public bacon_Spawn( id )
{
	if( is_user_alive( id ) 
	&& get_pcvar_num( gSmokeLightEnable ) == 1 
	&& get_pcvar_num( gSmokeBonus ) == 1 )
	{
		give_item( id, "weapon_smokegrenade" );
	}
}	

public forward_SetModel( iEnt, const szModel[ ] )
{
	if( !pev_valid( iEnt ) 
	|| get_pcvar_num( gSmokeLightEnable ) == 0 
	|| !equal( szModel[ 9 ], "smokegrenade.mdl" ) )
	{
		return FMRES_IGNORED;
	}
	
	static szClassname[ 32 ];
	pev( iEnt, pev_classname, szClassname, charsmax( szClassname ) );
	
	if( equal( szClassname, "grenade" ) )
	{
		if( get_pcvar_num( gTrailEnable ) == 1 )
		{
			UTIL_TrailSprite( iEnt );
		}
		
		engfunc( EngFunc_SetModel, iEnt, gSmokeModel );
		set_task( get_pcvar_float( gDeployTime ), "deploy_smoke", iEnt );
		
		set_pev( iEnt, pev_iuser4, SMOKE_ID );
		set_pev( iEnt, pev_nextthink, get_gametime( ) + get_pcvar_float( gLightTime ) );
		
		new szColor[ 12 ], iRgb[ 3 ][ 4 ], iR, iG, iB;
		get_pcvar_string( gGlowColorCvar, szColor, charsmax( szColor ) );
		
		parse( szColor, iRgb[ 0 ], 3, iRgb[ 1 ], 3, iRgb[ 2 ], 3 );
		
		iR = clamp( str_to_num( iRgb[ 0 ] ) , 0, 255 );
		iG = clamp( str_to_num( iRgb[ 1 ] ) , 0, 255 );
		iB = clamp( str_to_num( iRgb[ 2 ] ) , 0, 255 );
		
		set_rendering( iEnt, kRenderFxGlowShell, iR, iG, iB, kRenderNormal, 18 );
		
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public deploy_smoke( iEnt )
{
	if( pev_valid( iEnt ) )
	{
		if( get_pcvar_num( gCylinderEnable ) == 1 )
		{
			UTIL_BlastCircle( iEnt );
		}
		
		set_pev( iEnt, pev_effects, EF_DIMLIGHT );
		emit_sound( iEnt, CHAN_ITEM, gSmokeStartSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}

public forward_Think( iEnt )
{
	if( pev_valid( iEnt ) 
	&& get_pcvar_num( gSmokeLightEnable ) == 1 
	&& pev_valid2( iEnt ) )
	{
		if( get_pcvar_num( gSmokeCvar ) == 1 )
		{
			pev( iEnt, pev_origin, flOrigin );
			FVecIVec( flOrigin, iOrigin );
			
			new x = iOrigin[ 0 ];
			new y = iOrigin[ 1 ];
			new z = iOrigin[ 2 ];
			
			UTIL_Smoke( x + 50, y, z );
			UTIL_Smoke( x, y + 50, z );
			UTIL_Smoke( x - 50, y, z );
			UTIL_Smoke( x, y - 50, z );
			UTIL_Smoke( x + 35, y + 35, z );
			UTIL_Smoke( x + 35, y - 35, z );
			UTIL_Smoke( x - 35, y + 35, z );
			UTIL_Smoke( x - 35, y - 35, z );
		}
		
		emit_sound( iEnt, CHAN_ITEM, gSmokeStopSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		set_pev( iEnt, pev_flags, FL_KILLME );
	}
}

stock UTIL_TrailSprite( ent )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( ent );		
	write_short( gSpriteTrail );
	write_byte( 3 );
	write_byte( 7 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 100 );
	message_end( );
}

stock UTIL_BlastCircle( ent )
{
	pev( ent, pev_origin, flOrigin );
	FVecIVec( flOrigin, iOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin ); 
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 220 ) ;
	write_short( gSpriteCircle );
	write_byte( 0 );
	write_byte( 1 );
	write_byte( 6 );
	write_byte( 8 );
	write_byte( 1 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 128 );
	write_byte( 5 );
	message_end( );
}

stock UTIL_Smoke( x, y, z )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SMOKE );
	write_coord( x );
	write_coord( y );
	write_coord( z ); 
	write_short( gSpriteSmoke );
	write_byte( 12 );
	write_byte( 3 );
	message_end( );
}
