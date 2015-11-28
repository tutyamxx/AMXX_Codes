
#include < amxmodx >

#include < fakemeta >
#include < hamsandwich >

#pragma semicolon 1

new bool:bBhopEnabled[ 33 ];

public plugin_init( )
{
	register_plugin( "Bhop for DR", "1.0.0", "tuty" );
	
	register_clcmd( "say /bhop", "commandBhop" );
	register_clcmd( "say_team /bhop", "commandBhop" );
	
	RegisterHam( Ham_Player_PreThink, "player", "bacon_PlayerPreThink" );
}

public client_connect( id )
{
	bBhopEnabled[ id ] = false;
}

public commandBhop( id )
{
	if( bBhopEnabled[ id ] == true )
	{
		client_print( id, print_chat, "[Dr Bhop] Bhop dezactivat!" );
		bBhopEnabled[ id ] = false;
		
		return PLUGIN_HANDLED;
	}
	
	else if( bBhopEnabled[ id ] == false )
	{
		client_print( id, print_chat, "[Dr Bhop] Bhop activat!" );
		bBhopEnabled[ id ] = true;
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public bacon_PlayerPreThink( id )
{
	if( is_user_alive( id ) 
	&& bBhopEnabled[ id ] == true
	&& ( pev( id, pev_button ) & IN_JUMP )
	&& ( pev( id, pev_flags ) & FL_ONGROUND ) 
	&& !( pev( id, pev_flags ) & FL_WATERJUMP )
	&& !( pev( id, pev_waterlevel ) >= 2 ) )
	{
		set_pev( id, pev_oldbuttons, pev( id, pev_oldbuttons ) & ~IN_JUMP );
		ExecuteHamB( Ham_Player_Jump, id );
	}
}
