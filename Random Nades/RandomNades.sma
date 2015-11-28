#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fun>

#pragma semicolon 1

#define PLUGIN 	"New Plug-In"
#define VERSION "1.0"
#define AUTHOR 	"tuty"


public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawn", 1 );
}

public bacon_PlayerSpawn()
{
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum, "achg" );
	
	new id = iPlayers[ random_num( 0, iNum - 1 ) ];
	
	if( is_user_alive( id ) && get_user_team( id ) == 2 )
	{
		give_item( id, "weapon_hegrenade" );
		
		color_print( id, "^4[ tutY.DR ]^1 You are the ^4lucky chosen^1 player this round! You got a ^3HE Grenade^1!" );
	}
}

stock color_print( id, const message[], { Float, Sql, Result, _ }:... )
{
	new Buffer[ 128 ],Buffer2[ 128 ];
	new players[ 32 ], index, num, i;
	
	formatex( Buffer2,charsmax( Buffer2 ), "%s", message );
	vformat( Buffer, charsmax( Buffer ), Buffer2, 3 );
	get_players( players, num, "c" );
	
	if( id )
	{
		if( !is_user_connected( id ) )
		{
			return;
		}
			
		message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, id );
		write_byte( id );
		write_string( Buffer );
		message_end();
	} 
	
	else
	{	
		for( i = 0; i < num;i++ )
		{
			index = players[ i ];

			if( !is_user_connected( index ) ) 
			{
				continue;
			}
				
			message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, index );
			write_byte( index );
			write_string( Buffer );
			message_end();
		}
	}
}
