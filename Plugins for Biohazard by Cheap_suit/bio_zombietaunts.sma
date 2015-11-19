
#include < amxmodx >
#include < hamsandwich >

#tryinclude < biohazard >

#define SPEAK_DELAY	15.0

new Float:flTauntTime[ 33 ];

new const gZombieTaunts[ ][ ] = 
{
	"biohazard/braaains.wav",
	"biohazard/brains.wav",
	"biohazard/brains2.wav",
	"biohazard/feeed.wav",
	"biohazard/join2.wav",
	"biohazard/joinusss.wav",
	"biohazard/mustfeed.wav"
};

public plugin_init( )
{
	register_plugin( "Zombie Taunts", "1.0.1", "tuty" );
	
	RegisterHam( Ham_Player_PostThink, "player",  "bacon_PostThink", 1 );
}

public plugin_precache( )
{
	new i;
	
	for( i = 0; i < sizeof gZombieTaunts; i++ )
	{
		precache_sound( gZombieTaunts[ i ] );
	}
}

public bacon_PostThink( id )
{
	if( is_user_alive( id ) && is_user_zombie( id ) )
	{
		new Float:flGameTime = get_gametime( );
		
		if( flGameTime - flTauntTime[ id ] > SPEAK_DELAY )
		{
			flTauntTime[ id ] = flGameTime;
				
			emit_sound( id, CHAN_VOICE, gZombieTaunts[ random_num( 0, charsmax( gZombieTaunts ) ) ], random_float( 0.7, 1.0 ), ATTN_NORM, 0, PITCH_NORM );
		}
	}
}
