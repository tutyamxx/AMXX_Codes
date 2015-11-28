#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#pragma semicolon 1


#define PLUGIN_NAME	"Death Gibs"
#define PLUGIN_VERSION 	"1.0.0"
#define PLUGIN_AUTHOR 	"tuty"


public plugin_init()
{
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
	
	RegisterHam( Ham_Killed, "player", "baconPlayerKilled" );
	
	set_msg_block( get_user_msgid( "ClCorpse" ), BLOCK_SET );
}

public baconPlayerKilled( victim, attacker, shouldgib )
{
	if( victim != attacker )
	{
		SetHamParamInteger( 3, 2 );

		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}
