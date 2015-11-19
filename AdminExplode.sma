
#include < amxmodx >
#include < amxmisc >

#include < engine >
#include < cstrike >
#include < fun >

#pragma semicolon 1

new gCvarEnabled;
new gCvarRadius;
new gCvarDamage;
new gCvarFragBonus;
new gCvarMoneyBonus;

new gCylinderSprite;
new gMaxPlayers;
new gMessageDeathMsg;

new Trie:gTrieHandleInflictorToIgnore;

new const InflictorToIgnore[ ][ ] =
{
	"world",
    	"worldspawn",
    	"trigger_hurt",
    	"door_rotating",
    	"door",
    	"rotating",
    	"env_explosion"
};

new const gExplodeSound[ ] = "weapons/rocketfire1.wav";

public plugin_init( )
{
	register_plugin( "Admin Explode", "1.0.1", "tuty" );
	
	register_event( "DeathMsg", "Hook_DeathMessage", "a" );
	
	gCvarEnabled = register_cvar( "ae_enabled", "1" );
	gCvarRadius = register_cvar( "ae_radius", "500" );
	gCvarDamage = register_cvar( "ae_damage", "1000.0" );
	gCvarFragBonus = register_cvar( "ae_frags", "1" );
	gCvarMoneyBonus = register_cvar( "ae_money", "100" );
	
	gMaxPlayers = get_maxplayers();
	gMessageDeathMsg = get_user_msgid( "DeathMsg" );

	gTrieHandleInflictorToIgnore = TrieCreate( );

	for( new i = 0; i < sizeof InflictorToIgnore; i++ )
	{
    		TrieSetCell( gTrieHandleInflictorToIgnore, InflictorToIgnore[ i ], i );
	}
}

public plugin_precache( )
{
	gCylinderSprite = precache_model( "sprites/shockwave.spr" );
	
	precache_sound( gExplodeSound );
}

public Hook_DeathMessage( )
{
	if( get_pcvar_num( gCvarEnabled ) != 1 )
	{
		return PLUGIN_CONTINUE;
	}

	new iKiller = read_data( 1 );
	new iVictim = read_data( 2 );
	
	new szWeapon[ 30 ];
	read_data( 4, szWeapon, charsmax( szWeapon ) );
	
	if( iVictim == iKiller )
	{
		return PLUGIN_CONTINUE;
	}
	
	if( TrieKeyExists( gTrieHandleInflictorToIgnore, szWeapon ) )
	{
   		return PLUGIN_CONTINUE;
	}

	if( is_user_admin( iVictim ) )
	{
		new iOrigin[ 3 ];
		get_user_origin( iVictim, iOrigin );
		
		new iRadius = get_pcvar_num( gCvarRadius );
	
		UTIL_CreateBeamCylinder( iOrigin, 120, gCylinderSprite, 0, 0, 6, 16, 0, random( 255 ), random( 255 ), random( 255 ), 255, 0 );
		UTIL_CreateBeamCylinder( iOrigin, 320, gCylinderSprite, 0, 0, 6, 16, 0, random( 255 ), random( 255 ), random( 255 ), 255, 0 );
		UTIL_CreateBeamCylinder( iOrigin, iRadius, gCylinderSprite, 0, 0, 6, 16, 0, random( 255 ), random( 255 ), random( 255 ), 255, 0 );
		
		UTIL_Blast_ExplodeDamage( iVictim, get_pcvar_float( gCvarDamage ), float( iRadius ) );
		
		emit_sound( iVictim, CHAN_BODY, gExplodeSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}

	return PLUGIN_CONTINUE;
}

stock UTIL_Blast_ExplodeDamage( entid, Float:damage, Float:range ) 
{
	new Float:flOrigin1[ 3 ];
	entity_get_vector( entid, EV_VEC_origin, flOrigin1 );

	new Float:flDistance;
	new Float:flTmpDmg;
	new Float:flOrigin2[ 3 ];

	for( new i = 1; i <= gMaxPlayers; i++ ) 
	{
		if( is_user_alive( i ) && get_user_team( entid ) != get_user_team( i ) )
		{
			entity_get_vector( i, EV_VEC_origin, flOrigin2 );
			flDistance = get_distance_f( flOrigin1, flOrigin2 );
			
			static const szWeaponName[] = "Admin Blast Explosion";
		
			if( flDistance <= range ) 
			{
				flTmpDmg = damage - ( damage / range ) * flDistance;
				fakedamage( i, szWeaponName, flTmpDmg, DMG_BLAST );
			
				message_begin( MSG_BROADCAST, gMessageDeathMsg );
				write_byte( entid );
				write_byte( i );
				write_byte( 0 );
				write_string( szWeaponName );
				message_end();
			}
		}
	}

	set_user_frags( entid, get_user_frags( entid ) + get_pcvar_num( gCvarFragBonus ) );
	cs_set_user_money( entid, cs_get_user_money( entid ) + get_pcvar_num( gCvarMoneyBonus ) );
}

stock UTIL_CreateBeamCylinder( origin[ 3 ], addrad, sprite, startfrate, framerate, life, width, amplitude, red, green, blue, brightness, speed )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin ); 
	write_byte( TE_BEAMCYLINDER );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] + addrad );
	write_short( sprite );
	write_byte( startfrate );
	write_byte( framerate );
	write_byte(life );
	write_byte( width );
	write_byte( amplitude );
	write_byte( red );
	write_byte( green );
	write_byte( blue );
	write_byte( brightness );
	write_byte( speed );
	message_end();
}
