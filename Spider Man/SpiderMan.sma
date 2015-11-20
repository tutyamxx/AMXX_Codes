
#include < amxmodx >
#include < amxmisc >
#include < fun >
#include < fakemeta >
#include < hamsandwich >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.1"
#define SPIDER_SOUND	"weapons/cbar_miss1.wav"

new const gSpiderSprite[] = "sprites/laserbeam.spr";
new gSpriteIndex;

new bHookToOrigin[ 33 ][ 3 ];

public plugin_init()
{
	register_plugin( "Spiderman", PLUGIN_VERSION, "tuty" );
	
	register_clcmd( "+swing", "commandSpiderSwing" );
	register_clcmd( "-swing", "commandSpiderSwingOff" );
}

public plugin_precache()
{
	gSpriteIndex = precache_model( gSpiderSprite );
	
	precache_sound( SPIDER_SOUND );
}
	
public commandSpiderSwing( id )
{
	if( !is_user_alive( id ) )
	{
		client_print( id, print_center, "You cant Swing while you are dead!" );
		
		return PLUGIN_HANDLED;
	}

	set_user_gravity( id, 0.0 );
	set_task( 0.1, "SwingThink", id + 12839162, _, _, "b" );
	
	bHookToOrigin[ id ][ 0 ] = 999999;
	SwingThink( id + 12839162 );
	
	emit_sound( id, CHAN_VOICE, SPIDER_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	return PLUGIN_HANDLED;
}

public SwingThink( taskid )
{
	new id = taskid - 12839162;
	new iOrigin[ 3 ];

	get_user_origin( id, iOrigin, 0 );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMENTPOINT );
	write_short( id );
	write_coord( bHookToOrigin[ id ][ 0 ] );
	write_coord( bHookToOrigin[ id ][ 1 ] );
	write_coord( bHookToOrigin[ id ][ 2 ] );
	write_short( gSpriteIndex );
	write_byte( 1 );
	write_byte( 1 );		
	write_byte( 2 );		
	write_byte( 5 );		
	write_byte( 0 );
	write_byte( random( 256 ) );		
	write_byte( random( 256 ) );		
	write_byte( random( 256 ) );		
	write_byte( 123 );		
	write_byte( 0 );
	message_end();

	if( bHookToOrigin[ id ][ 0 ] == 999999 )
	{
		new iOriginAim[ 3 ];
		get_user_origin( id, iOriginAim, 3 );
		
		bHookToOrigin[ id ][ 0 ] = iOriginAim[ 0 ];
		bHookToOrigin[ id ][ 1 ] = iOriginAim[ 1 ];
		bHookToOrigin[ id ][ 2 ] = iOriginAim[ 2 ];
	}

	new Float:flVelocity[ 3 ];
	
	flVelocity[ 0 ] = ( float( bHookToOrigin[ id ][ 0 ] ) - float( iOrigin[ 0 ] ) ) * 3.0;
	flVelocity[ 1 ] = ( float( bHookToOrigin[ id ][ 1 ] ) - float( iOrigin[ 1 ] ) ) * 3.0;
	flVelocity[ 2 ] = ( float( bHookToOrigin[ id ][ 2 ] ) - float( iOrigin[ 2 ] ) ) * 3.0;
	
	new Float:flCoordY = flVelocity[ 0 ] * flVelocity[ 0 ] + flVelocity[ 1 ] * flVelocity[ 1 ] + flVelocity[ 2 ] * flVelocity[ 2 ];
	new Float:flCoordX = ( 5.0 * 120.0 ) / floatsqroot( flCoordY );
	
	flVelocity[ 0 ] *= flCoordX;
	flVelocity[ 1 ] *= flCoordX;
	flVelocity[ 2 ] *= flCoordX;
	
	set_pev( id, pev_velocity, flVelocity );
}

public commandSpiderSwingOff( id )
{
	if( is_user_alive( id ) )
	{
		set_user_gravity( id, 1.0 );
	}
	
	if( task_exists( id + 12839162 ) )
	{
		remove_task( id + 12839162 );
	}

	return PLUGIN_HANDLED;
}
