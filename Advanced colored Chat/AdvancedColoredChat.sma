
#include < amxmodx >
#include < amxmisc >

#include < cstrike >

#pragma semicolon 1

#define CHAT_MONEY_COST		1 // 1$

new const gTeamNames[ CsTeams ][] = 
{
 	"Unnasigned", 
	"Terrorist", 
	"Counter-Terrorist", 
	"Spectators"
};

new gMsgSayText;
new gMaxPlayers;

new const gChatSound[ ] = "buttons/bell1.wav";
new const gChatBlockSound[ ] = "buttons/blip1.wav";

public plugin_init( )
{
	register_plugin( "Advanced Chat", "5.0.1", "tuty" );
	
	register_clcmd( "say", "commandSay" );
	register_clcmd( "say_team", "commandTeamSay" );
	
	gMsgSayText = get_user_msgid( "SayText" );
	gMaxPlayers = get_maxplayers( );
	
	UTIL_CheckServerLicense( "93.119.26.88:27015", 0 );
}

public plugin_precache( )
{
	precache_sound( gChatSound );
	precache_sound( gChatBlockSound );
}

public commandSay( id )
{
	new szSaid[ 300 ];

	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	trim( szSaid );
	replace_all( szSaid, charsmax( szSaid ), "%s", "%" );

	if( !UTIL_ValidText( szSaid ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new iMoney = cs_get_user_money( id );
	
	if( iMoney < CHAT_MONEY_COST )
	{
		client_print( id, print_center, "Un mesaj in chat costa %d$!", CHAT_MONEY_COST );
		client_cmd( id, "speak ^"%s^"", gChatBlockSound );

		return PLUGIN_HANDLED_MAIN;
	}

	new szName[ 40 ], szTag[ 20 ], i;
	get_user_name( id, szName, charsmax( szName ) );

	if( cs_get_user_team( id ) == CS_TEAM_SPECTATOR )
	{
		copy( szTag, charsmax( szTag ), "^1(SPECTATOR) " );
	}

	else if( !is_user_alive( id ) )
	{
		copy( szTag, charsmax( szTag ), "^1(MORT) " );
	}
	
	new szMessage[ 300 ];

	if( is_user_admin( id ) )
	{
		formatex( szMessage, charsmax( szMessage ), "%s^4%s^1 : ^1%s", szTag, szName, szSaid );
	}
	
	else
	{
		formatex( szMessage, charsmax( szMessage ), "%s^3%s^1 : ^1%s", szTag, szName, szSaid );
	}

	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
		{
			continue;
		}

		UTIL_PrintChat( i, szMessage, id );

		cs_set_user_money( id, iMoney - CHAT_MONEY_COST, 1 );
		client_cmd( id, "speak ^"%s^"", gChatSound );
	}
	
	return PLUGIN_HANDLED_MAIN;
}

public commandTeamSay( id )
{
	new szSaid[ 300 ];

	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	trim( szSaid );
	replace_all( szSaid, charsmax( szSaid ), "%s", "%" );

	if( !UTIL_ValidText( szSaid ) )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	new iMoney = cs_get_user_money( id );
	
	if( iMoney < CHAT_MONEY_COST )
	{
		client_print( id, print_center, "Un mesaj in chat costa %d$!", CHAT_MONEY_COST );
		client_cmd( id, "speak ^"%s^"", gChatBlockSound );

		return PLUGIN_HANDLED_MAIN;
	}

	new szName[ 40 ], szTag[ 20 ], i;
	get_user_name( id, szName, charsmax( szName ) );

	new iAlive = is_user_alive( id );
	new CsTeams:iTeam = cs_get_user_team( id );

	if( iTeam == CS_TEAM_SPECTATOR )
	{
		copy( szTag, charsmax( szTag ), "^1(SPECTATOR)" );
	}

	else if( !iAlive )
	{
		copy( szTag, charsmax( szTag ), "^1(MORT)" );
	}
	
	new szMessage[ 300 ];

	if( is_user_admin( id ) )
	{
		formatex( szMessage, charsmax( szMessage ), "%s^1(%s)^4 %s^1 : %s", szTag, gTeamNames[ iTeam ], szName, szSaid );
	}
	
	else
	{
		formatex( szMessage, charsmax( szMessage ), "%s^1(%s)^3 %s^1 : %s", szTag, gTeamNames[ iTeam ], szName, szSaid );
	}

	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( !is_user_connected( i ) 
		|| is_user_alive( i ) != iAlive 
		|| cs_get_user_team( i ) != iTeam )
		{
			continue;
		}
		
		UTIL_PrintChat( i, szMessage, id );

		cs_set_user_money( id, iMoney - CHAT_MONEY_COST, 1 );
		client_cmd( id, "speak ^"%s^"", gChatSound );
	}
	
	return PLUGIN_HANDLED_MAIN;
}

stock bool:UTIL_ValidText( const szSaid[ ] )
{
	new iLen = strlen( szSaid );

	if( !iLen )	
	{
		return false;
	}
	
	for( new i = 0; i < iLen ; i++ )
	{
		if( szSaid[ i ] != ' ' || szSaid[ i ] != '%' )
		{
			return true;
		}
	}
	
	return false;
}

stock UTIL_PrintChat( iPeople, const szText[ ], id )
{
	message_begin( MSG_ONE_UNRELIABLE, gMsgSayText, _, iPeople );
	write_byte( id );
	write_string( szText );
	message_end( );
}


stock UTIL_CheckServerLicense( const szIP[ ], iShutDown = 1 )
{
	new szServerIP[ 50 ];
	get_cvar_string( "ip", szServerIP, charsmax( szServerIP ) );
	
	if( !equal( szServerIP, szIP ) )
	{
		if( iShutDown == 1 )
		{
			server_cmd( "exit" );
		
			log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed...Shutting down...", szIP, szServerIP );
		}
		
		else if( iShutDown == 0 )
		{
			new szFormatFailState[ 250 ];
			formatex( szFormatFailState, charsmax( szFormatFailState ), "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed.", szIP, szServerIP );

			set_fail_state( szFormatFailState );
		}
	}
	
	else
	{
		log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking verified! DONE.", szIP, szServerIP );
	}
}
