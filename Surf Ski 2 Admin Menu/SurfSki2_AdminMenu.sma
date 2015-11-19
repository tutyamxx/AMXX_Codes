
#include < amxmodx >

#include < fun >
#include < fakemeta >

#pragma semicolon 1

#define ACCESS_CMD		ADMIN_SLAY
#define _LOG_TO_AMXX		1 			// put 0 to disable the log
#define VOL_ZERODOTSEVEN	0.7	
#define MAX_PLAYERS		32 + 1	

static const CT_4SpawnOrigins[ ][ 3 ] =
{
	{ -214, 3715, 41 },
	{ -448, 3714, 41 },
	{ -223, 3311, 41 },
	{ -448, 3308, 41 }
};

static const T_4SpawnOrigins[ ][ 3 ] = 
{
	{ -778, 3705, 41 },
	{ -554, 3722, 41 },
	{ -778, 3288, 41 },
	{ -570, 3347, 41 }
};

static const Scout_Place[ ][ 3 ] =
{
	{ -317, 943, -1161 },
	{ -672, 933, -1161 }
};

static const Gun_Room[ ][ 3 ] =
{
	{ -689, -949, -138 },
	{ -590, -958, -138 },
	{ -485, -947, -138 },
	{ -396, -961, -138 },
	{ -324, -960, -138 },
	{ -688, -840, -138 },
	{ -594, -844, -138 },
	{ -486, -866, -138 },
	{ -398, -852, -138 },
	{ -331, -845, -138 },
	{ -383, -697, -138 },
	{ -317, -683, -138 }
};

static const Mario_Room[ ][ 3 ] =
{
	{ 3610, 1053, -2317 },
	{ 3612,  629, -2317 },
	{ 3403, 1079, -2273 },
	{ 3081, 1091, -2317 },
	{ 3391,  641, -2317 },
	{ 3056,  578, -2317 },
	{ 3116,  285, -2275 },
	{ 3343,  245, -2317 }
};

static const Awp_Place[ ][ 3 ] = 
{
	{ 1795, -1070, -159 },
	{ 1544, -1075, -159 },
	{ 1304, -1072, -159 }
};

new gEnabled;

new gSelectedPlayer[ MAX_PLAYERS ];
new szFormatEx[ 40 ];

new const gTeleportSound[ ] = "common/bodydrop2.wav";

public plugin_init( )
{ 
	register_plugin( "Surf Ski 2 AdminMenu", "4.0.2", "tuty" );
	
	gEnabled = register_cvar( "surfski2_adminmenu", "1" );// enable / disable the plugin
	
	new szMap[ 32 ];
	get_mapname( szMap, charsmax( szMap ) );
	
	if( equal( szMap, "surf_ski_2" ) )
	{
		register_clcmd( "say /surfski2menu", "openMenuSurf" );
		register_clcmd( "say surfski2menu", "openMenuSurf" );
		register_clcmd( "say_team /surfski2menu", "openMenuSurf" );
		register_clcmd( "say_team surfski2menu", "openMenuSurf" );
	}

	register_dictionary( "surfski2_adminmenu.txt" );
}

public plugin_precache( )
{
	precache_sound( gTeleportSound );
}

public openMenuSurf( id )
{
	if( get_pcvar_num( gEnabled ) != 1 )
	{
		client_print( id, print_chat, "[SurfSki2] %L", id, "SURFSKI2_DISABLED" );
		
		return PLUGIN_CONTINUE;
	}

	if( !(get_user_flags( id ) & ACCESS_CMD ) )
	{
		client_print( id, print_chat, "[SurfSki2] %L", id, "SURFSKI2_RESTRICTED" );
		
		return PLUGIN_CONTINUE;
	}
	
	formatex( szFormatEx, charsmax( szFormatEx ), "\r%L", id, "SURFSKI2_SELECT" );
	new iMenu = menu_create( szFormatEx, "menu_handler" );

	new players[ 32 ], idString[ 3 ], szName[ 32 ], num, pid, i;
	get_players( players, num );	

	for( i = 0; i < num; i++ )
	{
		pid = players[ i ];
		num_to_str( pid, idString, charsmax( idString ) );
		
		get_user_name( pid, szName, charsmax( szName ) );
		
		menu_additem( iMenu, szName, idString );
	}
	
	menu_display( id, iMenu );

	return PLUGIN_CONTINUE;
}

public menu_handler( id, menu, item )
{
	if( item >= 0 ) 
	{
		new access, callback, idString[ 3 ];		
		menu_item_getinfo( menu, item, access, idString, charsmax( idString ), _, _, callback );	
		
		new pid = str_to_num( idString );	
	
		if( is_user_alive( pid ) )
		{
			gSelectedPlayer[ id ] = pid;
		
			DoCommand( id );
		}
	}

	menu_destroy( menu );

	return PLUGIN_HANDLED;	
}

public DoCommand( id )
{
	formatex( szFormatEx, charsmax( szFormatEx ), "\r%L", id, "SURFSKI2_MOVETO" );
	new iMenu = menu_create( szFormatEx, "location_menu" );
	
	formatex( szFormatEx, charsmax( szFormatEx ), "\d%L", id, "SURFSKI2_GUNROOM" );
	menu_additem( iMenu, szFormatEx, "0" );
	
	formatex( szFormatEx, charsmax( szFormatEx ), "\d%L", id, "SURFSKI2_SCOUTPLACE" );
	menu_additem( iMenu, szFormatEx, "1" );
	
	formatex( szFormatEx, charsmax( szFormatEx ), "\d%L", id, "SURFSKI2_MARIOROOM" );
	menu_additem( iMenu, szFormatEx, "2" );
	
	formatex( szFormatEx, charsmax( szFormatEx ), "\d%L", id, "SURFSKI2_AWPPLACE" );
	menu_additem( iMenu, szFormatEx, "3" );
	
	formatex( szFormatEx, charsmax( szFormatEx ), "\d%L", id, "SURFSKI2_CTSPAWN" );
	menu_additem( iMenu, szFormatEx, "4" );
	
	formatex( szFormatEx, charsmax( szFormatEx ), "\d%L", id, "SURFSKI2_TSPAWN" );
	menu_additem( iMenu, szFormatEx, "5" );
	
	menu_display( id, iMenu );
}

public location_menu( id, menu, item )
{
	if( item >= 0 ) 
	{
		new access, callback, actionString[ 2 ];		
		menu_item_getinfo( menu, item, access, actionString, charsmax( actionString ), _, _, callback );		
		
		new action = str_to_num( actionString );
		new pid = gSelectedPlayer[ id ];

		new Aname[ 32 ], Tname[ 32 ];
	
		get_user_name( id, Aname, charsmax( Aname ) );
		get_user_name( pid, Tname, charsmax( Tname ) );

		if( is_user_alive( pid ) )
		{
			switch( action )
			{
				case 0:
				{
					set_user_origin( pid, Gun_Room[ random_num( 0, charsmax( Gun_Room ) ) ] );
				}
			
				case 1:
				{
					set_user_origin( pid, Scout_Place[ random_num( 0, charsmax( Scout_Place ) ) ] );
				}
			
				case 2:
				{
					set_user_origin( pid, Mario_Room[ random_num( 0, charsmax( Mario_Room ) ) ] );
				}
			
				case 3:
				{
					set_user_origin( pid, Awp_Place[ random_num( 0, charsmax( Awp_Place ) ) ] );
				}
			
				case 4:
				{
					set_user_origin( pid, CT_4SpawnOrigins[ random_num( 0, charsmax( CT_4SpawnOrigins ) ) ] );
				}
			
				case 5:
				{
					set_user_origin( pid, T_4SpawnOrigins[ random_num( 0, charsmax( T_4SpawnOrigins ) ) ] );
				}
			}
			
			emit_sound( pid, CHAN_STATIC, gTeleportSound, VOL_ZERODOTSEVEN, ATTN_NORM, 0, PITCH_NORM );
			UTIL_TeleportFX( pid );
		}
			
		client_print( 0, print_chat, "%L", LANG_PLAYER, "SURFSKI2_ACTIVITY", Aname, Tname );
			
		set_hudmessage( 255, 170, 42, -1.0, 0.79, 2, 6.0, 5.0 );
		show_hudmessage( pid, "%L", pid, "SURFSKI2_TELEPORTED" );
			
		#if defined _LOG_TO_AMXX == 1
			log_amx( "%L", LANG_SERVER, "SURFSKI2_LOGAMX", Aname, Tname );
		#endif	
	}
			
	menu_destroy( menu );
			
	return PLUGIN_HANDLED;	
}

stock UTIL_TeleportFX( index )
{
	new Velocity[ 3 ];
	set_pev( index, pev_velocity, Velocity );
	
	new iOrigin[ 3 ];
	get_user_origin( index, iOrigin, 0 );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_TELEPORT );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	message_end( );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_TAREXPLOSION );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] ); 
	write_coord( iOrigin[ 2 ] );
	message_end( );
}
