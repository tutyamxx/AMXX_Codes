
#include < amxmodx >

#pragma semicolon 1

new gVoteMenu;
new gHudSync;
new gVoting;

new gVoteOptions[ 2 ];

new gCvarVoteEnabled;
new gCvarVoteSound;
new gCvarVoteAdminOnly;

public plugin_init( )
{
	register_clcmd( "say /voterr", "commandStartVoteRR" );
	register_clcmd( "say_team /voterr", "commandStartVoteRR" );
		
	gCvarVoteEnabled = register_cvar( "voterr_enabled", "1" );
	gCvarVoteSound = register_cvar( "voterr_sound", "1" );
	gCvarVoteAdminOnly = register_cvar( "voterr_admin", "1" );

	gHudSync = CreateHudSyncObj( );
}

public commandStartVoteRR( id )
{
	if( get_pcvar_num( gCvarVoteEnabled ) != 1 )
	{
		client_print( id, print_chat, "[VoteRR] Plugin disabled!" );
		
		return PLUGIN_HANDLED;
	}

	if( get_pcvar_num( gCvarVoteAdminOnly ) == 1 )
	{
		if( !( get_user_flags( id ) & ADMIN_CFG ) )
		{
			client_print( id, print_chat, "[VoteRR] Only admins can use this command!" );
			
			return PLUGIN_HANDLED;
		}
	}

	if( gVoting )
	{
		client_print( id, print_chat, "[VoteRR] There is already a vote process!" );
			
		return PLUGIN_HANDLED;
	}

	set_hudmessage( 255, 85, 42, -1.0, 0.21, 1, 6.0, 5.0 );
	ShowSyncHudMsg( 0, gHudSync, "Vote for 'Restart' will start in 7 seconds!" );
	
	if( get_pcvar_num( gCvarVoteSound ) != 0 )
	{
		client_cmd( 0, "speak ^"vox/get rads to capture number^"" );
	}

	set_task( 7.0, "StartVoteRestart" );
	
	gVoting++;

	return PLUGIN_CONTINUE;
}

public StartVoteRestart( )
{
	client_print( 0, print_chat, "[VoteRR] Voting for 'Restart' started..." );

	gVoteMenu = menu_create( "\yRestart Round?:", "menu_handler" );
	
	menu_additem( gVoteMenu, "\wYes", "0", 0 );
	menu_additem( gVoteMenu, "\wNo", "1", 0 );
	
	new iPlayers[ 32 ], iNum, id, i;
	get_players( iPlayers, iNum, "ch" );
	
	for( i = 0; i < iNum; i++ )
	{
		id = iPlayers[ i ];
		
		menu_display( id, gVoteMenu, 0 );
	}
	
	set_task( 10.0, "EndVoteProcess" );
	
	return PLUGIN_HANDLED;
}

public menu_handler( id, menu, item )
{
	if( item == MENU_EXIT || !gVoting )
	{
		return PLUGIN_HANDLED;
    	}
	
	new iData[ 6 ], szName[ 40 ], access, callback;
	
	menu_item_getinfo( menu, item, access, iData, charsmax( iData ), szName, charsmax( szName ), callback );
	
	new iVoteId = str_to_num( iData );

	gVoteOptions[ iVoteId ]++;

	return PLUGIN_HANDLED;
}

public EndVoteProcess( )
{
	if( gVoteOptions[ 0 ] > gVoteOptions[ 1 ] )
	{
		client_print( 0, print_chat, "[VoteRR] Option <Yes> recieved (%d) votes (%d%%)! Restarting the round in 4 seconds!", gVoteOptions[ 0 ], get_percent( gVoteOptions[ 0 ], 100 ) );
		
		if( get_pcvar_num( gCvarVoteSound ) != 0 )
		{
			client_cmd( 0, "speak ^"vox/bizwarn _comma round will relay in four seconds^"" );
		}

		set_task( 4.0, "RestartRound" );
	}
	
	else if( gVoteOptions[ 0 ] < gVoteOptions[ 1 ] )
	{
		client_print( 0, print_chat, "[VoteRR] Option <No> recieved (%d) votes (%d%%)! Voting failed!", gVoteOptions[ 1 ], get_percent( gVoteOptions[ 1 ], 100 ) );
		
		if( get_pcvar_num( gCvarVoteSound ) != 0 )
		{
			client_cmd( 0, "speak ^"vox/alert _comma access denied^"" );
		}
	}
	
	else
	{
		client_print( 0, print_chat, "[VoteRR] Both votes <Yes> and <No> are equal! Voting failed!", gVoteOptions[ 0 ] );
		
		if( get_pcvar_num( gCvarVoteSound ) != 0 )
		{
			client_cmd( 0, "speak ^"vox/bizwarn _comma unauthorized access^"" );
		}
	}
	
	menu_destroy( gVoteMenu );

	gVoting = 0;
	gVoteOptions[ 0 ] = 0;	
	gVoteOptions[ 1 ] = 0;
}

public RestartRound( )
{
	server_cmd( "sv_restart 1" );
}

stock get_percent( cur, max )
{
	return ( cur * 100 ) / max;
}
