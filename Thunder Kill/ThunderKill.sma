/*

Iti va da +1 frag +300 $ 
De ce iti va da asa? Pentru ca am folosit o nativa din HAMSANDWICH
Care isi face treaba excelent si e super cool!

Cum folosesti?
bind <tasta> +fulger

Cvar:
thunder_damage - 200 
Aici schimbi damage cu cat vrei :)

*/


#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < hamsandwich >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

new const gThunderSprite[] = "sprites/lgtning.spr";

new gSpriteIndex;
new gCvarForDamage;
new gCvarForFrags;

public plugin_init()
{
	register_plugin( "Thunder Kill", PLUGIN_VERSION, "tuty" );
		
	register_clcmd( "+fulger", "commandThunderOn" );
	register_clcmd( "-fulger", "commandThunderOff" );
	
	gCvarForDamage = register_cvar( "thunder_damage", "200" );
	gCvarForFrags = register_cvar( "thunder_frags", "1" );
}

public plugin_precache()
{
	gSpriteIndex = precache_model( gThunderSprite );
}

public commandThunderOn( id )
{
	if( !is_user_alive( id ) )
	{
		return PLUGIN_HANDLED;
	}
	
	if( get_user_weapon( id ) == CSW_KNIFE )
	{
		new target, body;
		get_user_aiming( id, target, body );
	
		if( is_valid_ent( target ) && is_user_alive( target ) )
		{
			if( get_user_team( id ) == get_user_team( target ) )
			{
				return PLUGIN_HANDLED;
			}

			new iPlayerOrigin[ 3 ], iEndOrigin[ 3 ];

			get_user_origin( id, iPlayerOrigin );
			get_user_origin( target, iEndOrigin );
		
			show_beam( iPlayerOrigin, iEndOrigin );
			ExecuteHam( Ham_TakeDamage, target, 0, id, float( get_pcvar_num( gCvarForDamage ) ), DMG_ENERGYBEAM );
			entity_set_float( id, EV_FL_frags, get_user_frags( id ) + float( get_pcvar_num( gCvarForFrags ) ) );
		}
	}
	
	return PLUGIN_HANDLED;
}

public commandThunderOff( id )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_KILLBEAM );
	write_short( id );
	message_end();

	return PLUGIN_HANDLED;
}

stock show_beam( StartOrigin[ 3 ], EndOrigin[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMPOINTS );
	write_coord( StartOrigin[ 0 ] );
	write_coord( StartOrigin[ 1 ] );
	write_coord( StartOrigin[ 2 ] );
	write_coord( EndOrigin[ 0 ] );
	write_coord( EndOrigin[ 1 ] );
	write_coord( EndOrigin[ 2 ] );
	write_short( gSpriteIndex );
	write_byte( 1 );
	write_byte( 1 );
	write_byte( 3 );
	write_byte( 33);
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 200 );
	write_byte( 0 );
	message_end();
}
