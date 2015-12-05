/*	CopyRight © 2015, tuty

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

#define PLUGIN_VERSION	"1.0.3"

new const gDbTableName[ ] = "LIVEChat";
new const gConfigFileName[ ] = "LIVEChat.cfg";

new Handle:gSqlTuple;
new Handle:gSqlConnection;

new gCvarPointerHost;
new gCvarPointerUser;
new gCvarPointerPass;
new gCvarPointerDb;

public plugin_init( )
{
	register_plugin( "LIVE CS 1.6 Chat", PLUGIN_VERSION, "tuty" );

	register_clcmd( "say", "check_CommandSay" );
	register_clcmd( "say_team", "check_CommandSay" );

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
		SQL_QueryAndIgnore( gSqlConnection, "CREATE TABLE IF NOT EXISTS `%s`(`id` int(11) NOT NULL auto_increment, `time` time NOT NULL default '00:00:00', `alive` varchar(50) NOT NULL default '', `team` int(50) NOT NULL default '0', `name` varchar(100) NOT NULL, `message` text NOT NULL, PRIMARY KEY (`id`) );", gDbTableName );
		SQL_FreeHandle( gSqlConnection );
		
		server_print( "[LiveChat] Connected successfuly!" );
		log_amx( "[LiveChat] Connected successfuly!" );
	}
	
	else
	{
		server_print( "[LiveChat] SQLx error (#%d) -=> [%s]", iError, szError );
		log_amx( "[LiveChat] SQLx error (#%d) -=> [%s]", iError, szError );
	}
}

public plugin_cfg( )
{
	new szConfigsDir[ 32 ], szFile[ 192 ];
	
	get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
	formatex( szFile, charsmax( szFile ), "%s/%s", szConfigsDir, gConfigFileName );
	
	if( file_exists( szFile ) )
	{
		server_cmd( "exec %s", szFile );
		
		server_print( "[LiveChat] File ^"%s^" found!", szFile );
		log_amx( "[LiveChat] File ^"%s^" found!", szFile );
	}
	
	else
	{
		server_print( "[LiveChat] Warning! File ^"%s^" not found!", szFile );
		log_amx( "[LiveChat] Warning! File ^"%s^" not found!", szFile );
	}
}

public check_CommandSay( id )
{
	if( !is_user_connected( id ) )
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

	formatex( szQuery, charsmax( szQuery ), "INSERT INTO `%s` (time, alive, team, name, message) values ('%s', '%s', '%d', '%s', '%s')", gDbTableName, szTime, is_user_alive( id ) ? "*ALIVE*" : "*DEAD*", get_user_team( id ), szName, szSaid );
	SQL_ThreadQuery( gSqlTuple, "QueryHandle", szQuery );
	
	return PLUGIN_CONTINUE;
}

public QueryHandle( iFailState, Handle:hQuery, szError[ ], iErrnum, iData[ ], iSize, Float:fQueueTime )
{
	if( iFailState != TQUERY_SUCCESS )
	{
		server_print( "[LiveChat] SQLx error (#%d) -=> [%s]", iErrnum, szError );
		log_amx( "[LiveChat] SQLx error (#%d) -=> [%s]", iErrnum, szError );
	}
}
	
public plugin_end( )
{
	if( gSqlTuple )
	{
		SQL_FreeHandle( gSqlTuple  );
		
		server_print( "[LiveChat] Connection closed!" );
		log_amx( "[LiveChat] Connection closed!" );
	}
}

stock bool:is_valid_message( const szSaid[ ] )
{
	new iLen = strlen( szSaid );

	if( !iLen )	
	{
		return false;
	}
	
	for( new i = 0; i < iLen; i++ )
	{
		if( szSaid[ i ] != ' ' || szSaid[ i ] != '%' )
		{
			return true;
		}
	}
	
	return false;
}
