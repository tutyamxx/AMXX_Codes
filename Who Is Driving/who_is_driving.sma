
#include < amxmodx >
#include < fakemeta >

#include < hamsandwich >

#pragma semicolon 1

new gPluginOn;
new gHudTime;

new const gWhoMessages[ ][ ] =
{
	"We all want to drive, but %s is obsessed !",
	"%s: Someone called TAXI?",
	"Whatch OUT!!!!! %s is driving :O:O !!!!!",
	"%s: I am a soooooooooooper driver !? Whant some lessons? :D",
	"What the ... ?!?! %s is driving ?!???",
	"Hey! %s is driving, and is good :)"
};

new const gCarSounds[ ][ ] =
{
	"debris/beamstart5.wav",
	"debris/beamstart7.wav",
	"debris/beamstart10.wav",
	"debris/beamstart11.wav",
	"weapons/electro4.wav"
};	


public plugin_init( )
{
	register_plugin( "Who Is Driving?", "3.0.0", "tuty" );
	
	RegisterHam( Ham_Use, "func_vehicle", "bacon_Use" );
	
	gPluginOn = register_cvar( "wid_on", "1" );
	gHudTime = register_cvar( "wid_hudtime", "8.0" );
}

public plugin_precache( )
{
	new i;
	
	for( i = 0; i < sizeof( gCarSounds ); i++ )
	{
		precache_sound( gCarSounds[ i ] );
	}
}	

public bacon_Use( iEntity, id, iActivator, iUseType, Float:flValue )
{
	if( get_pcvar_num( gPluginOn ) != 0 
	&& is_user_alive( id ) && iUseType == 2 
	&& flValue == 1.0 && ( pev( id, pev_button ) & IN_FORWARD )
	&& !( pev( id, pev_oldbuttons ) & IN_FORWARD ) )
	{
		new szName[ 32 ];
		get_user_name( id, szName, charsmax( szName ) );
		
		set_hudmessage( random( 255 ), random( 255 ), random( 255 ), -1.0, 0.80, 1, 6.0, get_pcvar_float( gHudTime ) );
		show_hudmessage( 0, gWhoMessages[ random_num( 0, charsmax( gWhoMessages ) ) ], szName );
		
		client_cmd( 0, "speak %s", gCarSounds[ random_num( 0, charsmax( gCarSounds ) ) ] );
	}
}
