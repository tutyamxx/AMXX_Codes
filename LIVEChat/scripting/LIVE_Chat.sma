/*	CopyRight © 2010, tuty

	LIVE Chat is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with LIVE Chat; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/



#include < amxmodx >
#include < amxmisc >
#include < sqlx >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

#define SCRIPT_NAME	"LIVEChat"
#define CFG_NUMEFISIER	"LIVEChat.cfg"

#define DEBUG_PLUGIN

new Handle:gSqlTuple;
new Handle:gSqlConnection;

new gCvarPointerHost;
new gCvarPointerUser;
new gCvarPointerPass;
new gCvarPointerDb;

public plugin_init()
{
	register_plugin( "LIVE CS Chat", PLUGIN_VERSION, "tuty" );

	#if defined DEBUG_PLUGIN
		server_print( "[LiveChat] Plugin started..." );
		log_amx( "[LiveChat] Plugin started..." );
	#endif

	register_clcmd( "say", "checkCommandSay" );
	register_clcmd( "say_team", "checkCommandSay" );

	gCvarPointerHost = register_cvar( "livechat_host", "" );
	gCvarPointerUser = register_cvar( "livechat_user", "" );
	gCvarPointerPass = register_cvar( "livechat_pass", "" );
	gCvarPointerDb = register_cvar( "livechat_db", "" );


	new iSqlHost[ 64 ], iSqlUser[ 64 ], iSqlPass[ 64 ], iSqlDb[ 64 ];
	
	get_pcvar_string( gCvarPointerHost, iSqlHost, charsmax( iSqlHost ) );
	get_pcvar_string( gCvarPointerUser, iSqlUser, charsmax( iSqlUser ) );
	get_pcvar_string( gCvarPointerPass, iSqlPass, charsmax( iSqlPass ) );
	get_pcvar_string( gCvarPointerDb, iSqlDb, charsmax( iSqlDb ) );
	
	gSqlTuple = SQL_MakeDbTuple( iSqlHost, iSqlUser, iSqlPass, iSqlDb );
	
	new iError, szError[ 256 ];
	gSqlConnection = SQL_Connect( gSqlTuple, iError, szError, charsmax( szError ) );
	
	if( gSqlConnection != Empty_Handle )
	{
		SQL_QueryAndIgnore( gSqlConnection, "CREATE TABLE IF NOT EXISTS `%s`(`id` int(11) NOT NULL auto_increment, `time` time NOT NULL default '00:00:00', `alive` varchar(50) NOT NULL default '', `team` int(50) NOT NULL default '0', `name` varchar(100) NOT NULL, `message` text NOT NULL, PRIMARY KEY (`id`) );", SCRIPT_NAME );
		SQL_FreeHandle( gSqlConnection );
		
		#if defined DEBUG_PLUGIN
			server_print( "[LiveChat] Connected successfuly!" );
			log_amx( "[LiveChat] Connected successfuly!" );
		#endif
	}
	
	else
	{
		#if defined DEBUG_PLUGIN
			server_print( "[LiveChat] SQLx error (#%d) -=> [%s]", iError, szError );
			log_amx( "[LiveChat] SQLx error (#%d) -=> [%s]", iError, szError );
		#endif
	}
}

public plugin_cfg()
{
	new szConfigsDir[ 32 ], szFile[ 192 ];
	
	get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
	formatex( szFile, charsmax( szFile ), "%s/%s", szConfigsDir, CFG_NUMEFISIER );
	
	if( file_exists( szFile ) )
	{
		server_cmd( "exec %s", szFile );
		
		#if defined DEBUG_PLUGIN
			server_print( "[LiveChat] File ^"%s^" found!", szFile );
			log_amx( "[LiveChat] File ^"%s^" found!", szFile );
		#endif
	}
	
	else
	{
		#if defined DEBUG_PLUGIN
			server_print( "[LiveChat] Warning! File ^"%s^" not found!", szFile );
			log_amx( "[LiveChat] Warning! File ^"%s^" not found!", szFile );
		#endif
	}
}

public checkCommandSay( id )
{
	if( is_user_bot( id ) || !is_user_connected( id ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new szSaid[ 300 ], szName[ 32 ], szTime[ 20 ], szQuery[ 2010 ];

	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	trim( szSaid );	
	
	if( !is_valid_message( szSaid ) )
	{
		return PLUGIN_HANDLED;
	}

	get_user_name( id, szName, charsmax( szName ) );
	get_time( "%H:%M:%S", szTime, charsmax( szTime ) );

	formatex( szQuery, charsmax( szQuery ), "INSERT INTO `%s` (time, alive, team, name, message) values ('%s', '%s', '%d', '%s', '%s')", SCRIPT_NAME, szTime, is_user_alive( id ) ? "*ALIVE*" : "*DEAD*", get_user_team( id ), szName, szSaid );
	SQL_ThreadQuery( gSqlTuple, "QueryHandle", szQuery );
	
	return PLUGIN_CONTINUE;
}

public QueryHandle( iFailState, Handle:hQuery, szError[], iErrnum, iData[], iSize, Float:fQueueTime )
{
	if( iFailState != TQUERY_SUCCESS )
	{
		#if defined DEBUG_PLUGIN
			server_print( "[LiveChat] SQLx error (#%d) -=> [%s]", iErrnum, szError );
			log_amx( "[LiveChat] SQLx error (#%d) -=> [%s]", iErrnum, szError );
		#endif
	}
}
	
public plugin_end()
{
	if( gSqlTuple )
	{
		SQL_FreeHandle( gSqlTuple  );
		
		#if defined DEBUG_PLUGIN
			server_print( "[LiveChat] Connection closed!" );
			log_amx( "[LiveChat] Connection closed!" );
		#endif
	}
}

stock bool:is_valid_message( const said[] )
{
	new len = strlen( said );

	if( !len )	
	{
		return false;
	}
	
	for( new i = 0; i < len; i++ )
	{
		if( said[ i ] != ' ' || said[ i ] != '%' )
		{
			return true;
		}
	}
	
	return false;
}
