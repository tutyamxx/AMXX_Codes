
/* Credits
* -------------
* 
*	() VEN 
*	() KleeneX
*	() Alka
*  	() Anakin
*
* Changelog
* --------------
*
* Version 2.3 
* --------------
*
* - first release
*
* Version 2.4
* --------------
*
* - added 2 cvars for bonus money and loose money when you kill a teammate
*
*
* Version 2.5
* -------------- 
*
* - optimized code
* - added a cool effect if you make damage to someone or yourself
* 
* Version 2.6
* --------------
*
* - optimized
* - added a smoke effect when nail explosion over
*
* Version 2.7
* --------------
* - added 2 cvars
* - optimized
* - fakemeta only
*
*
* Version 2.8 (2015)
*
* - re-wrote my shitty code
* - optimized
*/

#include < amxmodx >
#include < amxmisc >

#include < fakemeta >
#include < engine >
#include < cstrike >
#include < fun >

#pragma semicolon 1

#define PLUGIN_VERSION		"2.8"
#define MAX_PLAYERS		32 + 1
#define ADMIN_CMD_ACCESS 	ADMIN_BAN

enum _: iRGB
{
	iRedColor = 0,
	iGreenColor,
	iBlueColor
};

new const szNailModel[ ] = "models/nail.mdl";
new const szNailSound[ ] = "misc/spike1.wav";

new const szSpriteTrail[ ] = "sprites/smoke.spr";
new const szExplosionSprite[ ] = "sprites/zerogxplode.spr";
new const szSmokeSprite[ ] = "sprites/steam1.spr";

new const szNailClassname[ ] = "deagle_nail";

new gTrailSprite;
new gExplosionSprite;
new gSmokeSprite;
new gMaxPlayers;
new gMessageDamage;
new gDeathMessage;
new gMessageScoreInfo;
new gCvarFriendlyFire;

new gCvarNailEnabled;
new gCvarNailAdminOnly;
new gCvarNailSpeed;
new gCvarNailDelay;
new gCvarNailDmgRadius;
new gCvarNailDamage;
new gCvarNailTrailWidth;
new gCvarNailColorMode;
new gCvarNailMoneyBonus;
new gCvarNailMoneyLoose;
new gCvarNailFragBonus;
new gCvarNailFragLoose;

new Float:flWasNail[ MAX_PLAYERS ];

public plugin_init( )
{
	register_plugin( "Deagle Nail Launcher", PLUGIN_VERSION, "tuty" );

	register_forward( FM_Touch, "forward_FM_Touch" );
	register_forward( FM_StartFrame, "forward_FM_StartFrame" );

	register_logevent( "LOGEvent_RoundEnd", 2, "1=Round_End" );

	gCvarNailEnabled = register_cvar( "nail_enable", "1" );
	gCvarNailAdminOnly = register_cvar( "nail_admin_only", "0" );
	gCvarNailSpeed = register_cvar( "nail_speed", "600" );
	gCvarNailDelay = register_cvar( "nail_delay","3.0" );
	gCvarNailDmgRadius = register_cvar( "nail_damage_radius", "500" );
	gCvarNailDamage = register_cvar( "nail_damage", "200" );
	gCvarNailTrailWidth = register_cvar( "nail_trail_width", "5" );
	gCvarNailColorMode = register_cvar( "nail_trail_colormode", "1" );
	gCvarNailMoneyBonus = register_cvar( "nail_kill_money_bonus", "1000" );
	gCvarNailMoneyLoose = register_cvar( "nail_tk_loose_money", "5000" );
	gCvarNailFragBonus = register_cvar( "nail_fragbonus", "3" );
	gCvarNailFragLoose = register_cvar( "nail_loosefrags", "5" );
	
	gMessageScoreInfo = get_user_msgid( "ScoreInfo" );
	gMessageDamage = get_user_msgid( "Damage" );
	gDeathMessage = get_user_msgid( "DeathMsg" );

	gMaxPlayers = get_maxplayers( );
	gCvarFriendlyFire = get_cvar_pointer( "mp_friendlyfire" );
}

public plugin_precache( )
{
	gTrailSprite = precache_model( szSpriteTrail );
	gExplosionSprite = precache_model( szExplosionSprite );
	gSmokeSprite = precache_model( szSmokeSprite );

	precache_model( szNailModel );
	
	precache_sound( szNailSound );
}

public forward_FM_Touch( szPtr, szPtd )
{	
	if( get_pcvar_num( gCvarNailEnabled ) == 0
	|| !pev_valid( szPtr ) )
	{
		return FMRES_IGNORED;
	}

	new szClassname[ MAX_PLAYERS ];
	pev( szPtr, pev_classname, szClassname, charsmax( szClassname ) );
		
	if( equal( szClassname, szNailClassname ) )
	{	
		new Float:flOrigin[ 3 ];
		pev( szPtr, pev_origin, flOrigin );

 		new iOrigin[ 3 ];
		FVecIVec( flOrigin, iOrigin );
			
		UTIL_NailDamage( szPtr );
		UTIL_ExplosionFX( iOrigin );	
				
		engfunc( EngFunc_RemoveEntity, szPtr );
	}
	
	return FMRES_IGNORED;
}

public forward_FM_StartFrame( )
{
	if( get_pcvar_num( gCvarNailEnabled ) == 0 )
	{
		return FMRES_IGNORED;
	}
		
	new id;

	for( id = 1; id <= gMaxPlayers; id++ )
	{	
		if( is_user_alive( id )
		&& !is_user_hltv( id ) )
		{
			UTIL_CheckNails( id );
		}
	}

	return FMRES_IGNORED;
}

public LOGEvent_RoundEnd( )
{
	if( get_pcvar_num( gCvarNailEnabled ) == 1 )
	{
		new iEntity = FM_NULLENT;

		while( ( iEntity = find_ent_by_class( iEntity, szNailClassname ) ) )
		{
			engfunc( EngFunc_RemoveEntity, iEntity );
		}		
	}
}

public UTIL_CheckNails( const id )
{
	if( get_pcvar_num( gCvarNailEnabled ) == 0 )
	{
		return PLUGIN_HANDLED;
	}
	
	new iUserWeapon = get_user_weapon( id );	
	new iButton = pev( id, pev_button );
	
	if( iUserWeapon == CSW_DEAGLE )
	{	
		if( iButton & IN_ATTACK2 )
		{		
			UTIL_LaunchNail( id );
		}
	}

	return PLUGIN_CONTINUE;
}

public UTIL_LaunchNail( const id )
{
	if( get_pcvar_num( gCvarNailAdminOnly ) == 1 )
	{	
		if( !( get_user_flags( id ) & ADMIN_CMD_ACCESS ) )
		{
			return PLUGIN_HANDLED;
		}
	}

	new Float:flNexTime = get_gametime( );

	if( flWasNail[ id ] > flNexTime )
	{	
		return PLUGIN_HANDLED;
	}

	else
	{
		new iNailEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
		
		if( !pev_valid( iNailEntity ) )
		{
			return PLUGIN_HANDLED;
		}
		
		set_pev( iNailEntity, pev_classname, szNailClassname );
		engfunc( EngFunc_SetModel, iNailEntity, szNailModel );
		set_pev( iNailEntity, pev_size, Float:{ 0.0, 0.0, 0.0 }, Float:{ 0.0, 0.0, 0.0 } );
		set_pev( iNailEntity, pev_movetype, MOVETYPE_FLY );
		set_pev( iNailEntity, pev_solid, SOLID_BBOX );
		
		new Float:flVecSrc[ 3 ];
		pev( id, pev_origin, flVecSrc );

		new Float:flAim[ 3 ], Float:flOrigin[ 3 ];

		velocity_by_aim( id, 64, flAim );
		pev( id, pev_origin,flOrigin );
		
		flVecSrc[ 0 ] += flAim[ 0 ];
		flVecSrc[ 1 ] += flAim[ 1 ];

		engfunc( EngFunc_SetOrigin, iNailEntity, flVecSrc );

		new Float:flVelocity[ 3 ];
		new Float:flAngles[ 3 ];
		
		velocity_by_aim( id, get_pcvar_num( gCvarNailSpeed ), flVelocity );
		set_pev( iNailEntity, pev_velocity, flVelocity );
		vector_to_angle( flVelocity, flAngles);

		set_pev( iNailEntity, pev_angles, flAngles );
		set_pev( iNailEntity, pev_owner, id );
		set_pev( iNailEntity, pev_takedamage, DAMAGE_YES );
		
		new iTrailColor[ iRGB ];

		if( get_pcvar_num( gCvarNailColorMode ) )
		{
			switch( get_user_team( id ) )
			{
				case 1:
				{
					iTrailColor[ iRedColor ] = 255;
					iTrailColor[ iGreenColor ] = 0; 
					iTrailColor[ iBlueColor ] = 0;
				}
				case 2:
				{
					iTrailColor[ iRedColor ] = 0;
					iTrailColor[ iGreenColor ] = 0; 
					iTrailColor[ iBlueColor ] = 255;
				}

				default:
				{
					iTrailColor[ iRedColor ] = 211;
					iTrailColor[ iGreenColor ] = 211; 
					iTrailColor[ iBlueColor ] = 211;
				}
			}
	
		}
		
		UTIL_TrailFX( iNailEntity, iTrailColor );
		emit_sound( iNailEntity, CHAN_WEAPON, szNailSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		flWasNail[ id ] = flNexTime + get_pcvar_float( gCvarNailDelay );
	}

	return PLUGIN_CONTINUE;
}

public UTIL_NailDamage( const iEntity )
{
	new id = pev( iEntity, pev_owner );
	
	new i;

	for( i = 1; i <= gMaxPlayers; i++ )
	{	
		if( is_user_alive( i ) && pev_valid( iEntity ) )
		{	
			new flDistance = floatround( entity_range( iEntity, i ) );
			
			if( flDistance <= get_pcvar_num( gCvarNailDmgRadius ) )
			{	
				new iUserHealth = get_user_health( i );

				new Float:flDamage = get_pcvar_float( gCvarNailDamage ) - ( get_pcvar_float( gCvarNailDamage) / get_pcvar_float( gCvarNailDmgRadius ) ) * float( flDistance );
				
				new iOrigin[ 3 ];
				get_user_origin( i, iOrigin );

				if( get_pcvar_num( gCvarFriendlyFire ) == 0 )
				{	
					if( get_user_team( id ) != get_user_team( i ) )
					{	
						if( iUserHealth > flDamage )
						{
							UTIL_DamageFX( i, iOrigin );
							set_user_health( i, iUserHealth - floatround( flDamage ) );
						}
					}
				}

				else if( get_pcvar_num( gCvarFriendlyFire ) == 1 )
				{
					if( get_user_team( id ) == get_user_team( i )
					&& id != i )
					{	
						UTIL_NailKill( id, i, szNailClassname, 0 );
					}
				}
			}
		}
	}
}

public UTIL_NailKill( const iKiller, const iVictim, const szWeapon[ ], iHeadshot )
{
	set_msg_block( gDeathMessage, BLOCK_ONCE );
	user_kill( iVictim, 1 );

	set_msg_block( gDeathMessage, BLOCK_NOT );
	
	message_begin( MSG_ALL, gDeathMessage, { 0, 0, 0 }, 0 );
	write_byte( iKiller );
	write_byte( iVictim );
	write_byte( iHeadshot );
	write_string( szWeapon );
	message_end( );
	
	new iMoney = cs_get_user_money( iKiller );
	
	if( get_user_team( iKiller ) != get_user_team( iVictim ) )
	{
		set_user_frags( iKiller, get_user_frags( iKiller ) + get_pcvar_num( gCvarNailFragBonus ) );
		cs_set_user_money( iKiller, ( iMoney >= 16000 ) ? 16000 : iMoney + get_pcvar_num( gCvarNailMoneyBonus ), 1 );
		
		UTIL_UpdateScoreboard( iKiller );
	}

	else 
	{
		set_user_frags( iKiller, get_user_frags( iKiller ) - get_pcvar_num( gCvarNailFragLoose ) );
		cs_set_user_money( iKiller, iMoney - get_pcvar_num( gCvarNailMoneyLoose ), 1 );
		
		UTIL_UpdateScoreboard( iKiller );
	}
}

stock UTIL_UpdateScoreboard( id )
{
	message_begin( MSG_ALL, gMessageScoreInfo );
	write_byte( id );
	write_short( get_user_frags( id ) );
	write_short( get_user_deaths(id ) );
	write_short( 0 );
	write_short( get_user_team( id ) ); 
	message_end( );
}

stock UTIL_DamageFX( const id, iOrigin[ 3 ] )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageDamage, { 0, 0 ,0 }, id );
	write_byte( 21 );
	write_byte( 20 );
	write_long( DMG_BLAST );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	message_end( );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin ); 
	write_byte( TE_LAVASPLASH ); 
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	message_end( ); 
}

stock UTIL_TrailFX( iEntity, iColor[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( iEntity );
	write_short( gTrailSprite );
	write_byte( 25 );
	write_byte( get_pcvar_num( gCvarNailTrailWidth ) );
	write_byte( iColor[ 0 ] );
	write_byte( iColor[ 1 ] );
	write_byte( iColor[ 2 ] );
	write_byte( 255 );
	message_end( );
}

stock UTIL_ExplosionFX( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_EXPLOSION );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( gExplosionSprite );
	write_byte( 30 );
	write_byte( 15 );
	write_byte( 0 );
	message_end( );
			
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SMOKE );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( gSmokeSprite );
	write_byte( 40 );
	write_byte( 5 );
	message_end( );
}
