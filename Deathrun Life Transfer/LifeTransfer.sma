
#include < amxmodx >
#include < amxmisc >

#include < fun >
#include < cstrike >
#include < colorchat >
#include < hamsandwich >

#pragma semicolon 1

#define MAX_PLAYERS			32 + 1		

new gCvarFragToBonus;
new gCvarMenuDisplayTime;

new gMessageScoreInfo;

new const gTag[ ] = "[Deathrun]";
new const gTransferSound[ ] = "fvox/vitalsigns_on.wav";

new gInviter[ MAX_PLAYERS ];

new bool:bIsInvited[ MAX_PLAYERS ];
new bool:bAlreadyInvited[ MAX_PLAYERS ];

public plugin_init()
{
	register_plugin( "Life Transfer", "6.2.1", "tuty" );

	RegisterHam( Ham_Spawn, "player", "bacon_Spawn", 1 );

	register_clcmd( "say", "cmdSayTransfer" );
	register_clcmd( "say_team", "cmdSayTransfer" );

	gCvarFragToBonus = register_cvar( "lt_fragbonus", "2" );
	gCvarMenuDisplayTime = register_cvar( "lt_menudisplay_time", "3" );	
	
	gMessageScoreInfo = get_user_msgid( "ScoreInfo" );
}

public client_connect( id )
{
	bIsInvited[ id ] = false;
	bAlreadyInvited[ id ] = false;
}

public client_disconnect( id )
{
	bIsInvited[ id ] = false;
	bAlreadyInvited[ id ] = false;
}

public plugin_precache()
{
	precache_sound( gTransferSound );
}

public cmdSayTransfer( id )
{
	new szSaid[ 300 ], szCommand[ 20 ];

	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	trim( szSaid );

	if( !strlen( szSaid ) )
	{
		return PLUGIN_CONTINUE;
	}

	parse( szSaid, szCommand, charsmax( szCommand ), szSaid, charsmax( szSaid ) );
	
	if( equal( szCommand, "/transfer" ) )
	{
		if( !is_user_alive( id ) )
		{
			ColorChat( id, RED,"^3%s^1 You must be alive to use this command!", gTag );

			return PLUGIN_HANDLED;
		}

		if( cs_get_user_team( id ) == CS_TEAM_T )
		{
			ColorChat( id, RED,"^3%s^1 Only ^3CT^1 can use transfer command!", gTag );

			return PLUGIN_HANDLED;
		}

		new iTarget = cmd_target( id, szSaid, 10 );

		new szName[ MAX_PLAYERS ];
		get_user_name( iTarget, szName, charsmax( szName ) );

		if( !iTarget )
		{
			ColorChat( id, RED,"^3%s ^1This player does not exist!", gTag );

			return PLUGIN_HANDLED;
		}

		if( cs_get_user_team( id ) != cs_get_user_team( iTarget ) )
		{
			ColorChat( id, RED,"^3%s ^4%s^1 is not from your team!", gTag, szName );

			return PLUGIN_HANDLED;
		}

		if( is_user_alive( iTarget ) )
		{
			ColorChat( id, RED,"^3%s ^4%s ^1is already alive!", gTag, szName );

			return PLUGIN_HANDLED;
		}

		if( bIsInvited[ iTarget ] == true )
		{
			ColorChat( id, RED,"^3%s ^1A invite transfer was already sent to ^4%s^1!", gTag, szName );

			return PLUGIN_HANDLED;
		}

		if( bAlreadyInvited[ iTarget ] == true )
		{
			ColorChat( id, RED,"^3%s ^1You already sent an invitation! Wait for next spawn!", gTag );

			return PLUGIN_HANDLED;
		}

		UTIL_SendInvitation( id, iTarget );
		ColorChat( id, RED,"^3%s^1 Invite transfer was sent to ^4%s", gTag, szName );
	}

	return PLUGIN_CONTINUE;
}

public menu_transfer( id, menu, item )
{
	new szData[ 6 ], szNamem[ 64 ], access, callback;
    	menu_item_getinfo( menu, item, access, szData, charsmax( szData ), szNamem, charsmax( szNamem ), callback );

	new iKey = str_to_num( szData );
	new iInviter = gInviter[ id ];

	new szName[ MAX_PLAYERS ], szName2[ MAX_PLAYERS ];

	get_user_name( id, szName, charsmax( szName ) );
	get_user_name( iInviter, szName2, charsmax( szName2 ) );
	
	new iFrags = get_pcvar_num( gCvarFragToBonus );

	switch( iKey )
	{
		case 1:
		{
			ExecuteHamB( Ham_CS_RoundRespawn, id );

			cs_set_user_team( id, CS_TEAM_CT );
			user_silentkill( iInviter );

			set_user_frags( iInviter, get_user_frags( iInviter ) + iFrags );
			UTIL_ScoreInfo( iInviter );

			set_task( 0.2, "doOrigin", id );

			bIsInvited[ id ] = false;
			bAlreadyInvited[ iInviter ] = true;

			ColorChat( iInviter, RED, "^3%s^1 Invite transfer was accepted by ^4%s^1! You got^4 %d^1 frags!", gTag, szName, iFrags );
			ColorChat( 0, RED, "^3%s ^4%s^1 transfered his life to ^4%s^1!", gTag, szName2, szName );

			emit_sound( id, CHAN_VOICE, gTransferSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			menu_destroy( menu );

            		return PLUGIN_HANDLED;
		}

		case 2:
		{
			ColorChat( iInviter, RED, "^3%s^1 Invite transfer was declined by ^4%s^1!", gTag, szName );

			bIsInvited[ id ] = false;
			bAlreadyInvited[ iInviter ] = false;
			
			menu_destroy( menu );

            		return PLUGIN_HANDLED;
		}
	}
	
	bIsInvited[ id ] = false;
	bAlreadyInvited[ iInviter ] = false;

	menu_destroy( menu );

       	return PLUGIN_HANDLED;
}

public doOrigin( id )
{
	new iOrigin[ 3 ];
	get_user_origin( gInviter[ id ], iOrigin, 0 );
	
	iOrigin[ 2 ] += 10;
	set_user_origin( id, iOrigin );

	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_TELEPORT );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	message_end( );
}

public bacon_Spawn( id )
{
	if( is_user_alive( id ) )
	{
		bAlreadyInvited[ id ] = false;
	}
}

public RemoveInvite( iTarget )
{
	show_menu( iTarget, 0, "^n", 1 );

	bIsInvited[ iTarget ] = false;
}

stock UTIL_SendInvitation( iInviter, iTarget )
{
	new szName[ MAX_PLAYERS ];
	get_user_name( iInviter, szName, charsmax( szName ) );

	new szFormatMenu[ 150 ];
	formatex( szFormatMenu, charsmax( szFormatMenu ), "\rDo you accept life transfer from \w%s\r?^n^n", szName );

	new iMenu = menu_create( szFormatMenu, "menu_transfer" );
	
	menu_additem( iMenu, "Yes, ofcourse", "1", 0 );
	menu_additem( iMenu, "No, no way", "2", 0 );
	
	menu_setprop( iMenu, MPROP_EXIT, MEXIT_NEVER );
	menu_display( iTarget, iMenu, 0 );
	
	gInviter[ iTarget ] = iInviter;

	bIsInvited[ iTarget ] = true;
	set_task( float( get_pcvar_num( gCvarMenuDisplayTime ) ), "RemoveInvite", iTarget );
}

stock UTIL_ScoreInfo( id )
{
	message_begin( MSG_BROADCAST, gMessageScoreInfo );
	write_byte( id );
	write_short( get_user_frags( id ) );
	write_short( get_user_deaths( id ) );
	write_short( 0 );
	write_short( get_user_team( id ) );
	message_end( );
}
