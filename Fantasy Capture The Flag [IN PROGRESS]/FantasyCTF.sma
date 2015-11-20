
#include < amxmodx >
#include < amxmisc >

#include < fakemeta >
#include < engine >
#include < hamsandwich >
#include < fun >
#include < cstrike >

#include < colorchat >
#include < xs >

#pragma semicolon 1

#define PLUGIN_VERSION		"1.0.3"

#define MAX_PLAYERS		32 + 1
#define IS_PLAYER(%1)		( 1 <= %1 <= gMaxPlayers )
#define HUD_MAX_LIFE		0.8
#define FLAG_MENU_ACCESS	ADMIN_IMMUNITY

enum _: iFlags
{
	RED_FLAG,
	BLUE_FLAG
};

enum _: iEvents
{
	RED_FLAG_DROPPED,
	RED_FLAG_TAKEN,
	RED_TEAM_SCORES,
	BLUE_FLAG_DROPPED,
	BLUE_FLAG_TAKEN,
	BLUE_TEAM_SCORES
};

new const gPluginTag[ ] = "[Fantasy CTF]";

new const gBaseClassname[ ] = "FlagBase_Entity";
new const gFlagClassname[ ] = "FlagFlag_Entity";

new const gFlagModels[ iFlags ][  ] =
{
	"models/fantasyctf/red_flag.mdl",
	"models/fantasyctf/blue_flag.mdl"
};

new const gBackFlagModels[ iFlags ][ ] =
{
	"models/fantasyctf/back_redflag.mdl",
	"models/fantasyctf/back_blueflag.mdl"
};

new const gFlagEventSounds[ iEvents ][ ] =
{
	"fantasyctf/red_flag_dropped.mp3",
	"fantasyctf/red_flag_taken.mp3",
	"fantasyctf/red_team_scores.mp3",
	"fantasyctf/blue_flag_dropped.mp3",
	"fantasyctf/blue_flag_taken.mp3",
	"fantasyctf/blue_team_scores.mp3"
};

new const gBaseModel[ ] = "models/kingpin.mdl";

new Float:flFlagMinSize[ 3 ] = { -15.0, -8.0, -15.0 };
new Float:flFlagMaxSize[ 3 ] = { 15.0, 8.0, 15.0 };

new i;
new gMaxPlayers;
new gHudSyncScore;
new gHudSyncFlagEvent;
new gMessageScreenFade;
new gSpriteLight;

new gBlueScore = 0;
new gRedScore = 0;

new bool:bRedFlagInBase = true;
new bool:bBlueFlagInBase = true;

new bCountFlags[ iFlags ];

new bGotEnemyFlag[ MAX_PLAYERS ];
new bBackFlag[ MAX_PLAYERS ];

new Float:flLastHud[ MAX_PLAYERS ];

new Float:flRedBaseOrigins[ 3 ];
new Float:flBlueBaseOrigins[ 3 ];

new gCvarEnableGlow;
new gCvarEnemyBaseDamage;
new gCvarEnemyBaseRadiusDmg;

public plugin_init( )
{
	register_plugin( "Fantasy Capture The Flag", PLUGIN_VERSION, "tuty" );
	
	register_event( "DeathMsg", "Hook_DeathMessage", "a" );
	RegisterHam( Ham_Player_PreThink, "player", "bacon_PreThink" );

	register_touch( gFlagClassname, "player", "forward_TouchedFlag" );

	register_think( gBaseClassname, "forward_BaseThink" );
	register_think( gFlagClassname, "forward_FlagThink" );
	
	register_clcmd( "say /flagmenu", "CommandFlagMenu" );
	register_clcmd( "say_team /flagmenu", "CommandFlagMenu" );
	
	gCvarEnableGlow = register_cvar( "fctf_glow", "1" );
	gCvarEnemyBaseDamage = register_cvar( "fctf_base_dmg", "2" );
	gCvarEnemyBaseRadiusDmg = register_cvar( "fctf_base_radiusdmg", "200" );
	
	gMaxPlayers = get_maxplayers( );
	gHudSyncScore = CreateHudSyncObj( );
	gHudSyncFlagEvent = CreateHudSyncObj( );

	gMessageScreenFade = get_user_msgid( "ScreenFade" );
}

public plugin_precache( )
{
	gSpriteLight = precache_model( "sprites/lgtning.spr" );

	for( i = 0; i < iFlags; i++ )
	{
		precache_model( gFlagModels[ i ] );
	}
	
	for( i = 0; i < iFlags; i++ )
	{
		precache_model( gBackFlagModels[ i ] );
	}
	
	for( i = 0; i < iEvents; i++ )
	{
		precache_sound( gFlagEventSounds[ i ] );
	}

	precache_model( gBaseModel );
}

public plugin_cfg( )
{
	new szConfigsDir[ 64 ], szFile[ 64 ];
	get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
	
	new szMap[ 40 ];
	get_mapname( szMap, charsmax( szMap ) );
	
	formatex( szFile, charsmax( szFile ), "%s/%s_bases.ctf", szConfigsDir, szMap );
	
	if( !file_exists( szFile ) )
	{
		return 1;
	}
	
	new szBuffer[ 128 ], szTemp1[ 128 ], szTemp2[ 128 ];

	new szFileOrigin1[ 3 ][ 32 ], szFileAngles1[ 3 ][ 32 ];
	new szFileOrigin2[ 3 ][ 32 ], szFileAngles2[ 3 ][ 32 ];

	new Float:flOriginRed[ 3 ], Float:flOriginBlue[ 3 ];
	new Float:flAnglesRed[ 3 ], Float:flAnglesBlue[ 3 ];

	new iFile = fopen( szFile, "rt" );
	
	while( !feof( iFile ) )
	{
		fgets( iFile, szBuffer, charsmax( szBuffer ) );
		strtok( szBuffer, szTemp1, charsmax( szTemp1 ), szTemp2, charsmax( szTemp2 ), '|', 0 );
		
		parse( szTemp1, szFileOrigin1[ 0 ], sizeof szFileOrigin1[ ] - 1, szFileOrigin1[ 1 ], sizeof szFileOrigin1[ ] - 1, szFileOrigin1[ 2 ], sizeof szFileOrigin1[ ] - 1, szFileAngles1[ 0 ], sizeof szFileAngles1[ ] - 1, szFileAngles1[ 1 ], sizeof szFileAngles1[ ] - 1, szFileAngles1[ 2 ], sizeof szFileAngles1[ ] - 1 );
		
		flRedBaseOrigins[ 0 ] = flOriginRed[ 0 ] = str_to_float( szFileOrigin1[ 0 ] );
		flRedBaseOrigins[ 1 ] = flOriginRed[ 1 ] = str_to_float( szFileOrigin1[ 1 ] );
		flRedBaseOrigins[ 2 ] = flOriginRed[ 2 ] = str_to_float( szFileOrigin1[ 2 ] );
			
		flAnglesRed[ 0 ] = str_to_float( szFileAngles1[ 0 ] );
		flAnglesRed[ 1 ] = str_to_float( szFileAngles1[ 1 ] );
		flAnglesRed[ 2 ] = str_to_float( szFileAngles1[ 2 ] );
		
		parse( szTemp2, szFileOrigin2[ 0 ], sizeof szFileOrigin2[ ] - 1, szFileOrigin2[ 1 ], sizeof szFileOrigin2[ ] - 1, szFileOrigin2[ 2 ], sizeof szFileOrigin2[ ] - 1, szFileAngles2[ 0 ], sizeof szFileAngles2[ ] - 1, szFileAngles2[ 1 ], sizeof szFileAngles2[ ] - 1, szFileAngles2[ 2 ], sizeof szFileAngles2[ ] - 1 );
		
		flBlueBaseOrigins[ 0 ] = flOriginBlue[ 0 ] = str_to_float( szFileOrigin2[ 0 ] );
		flBlueBaseOrigins[ 1 ] = flOriginBlue[ 1 ] = str_to_float( szFileOrigin2[ 1 ] );
		flBlueBaseOrigins[ 2 ] = flOriginBlue[ 2 ] = str_to_float( szFileOrigin2[ 2 ] );
			
		flAnglesBlue[ 0 ] = str_to_float( szFileAngles2[ 0 ] );
		flAnglesBlue[ 1 ] = str_to_float( szFileAngles2[ 1 ] );
		flAnglesBlue[ 2 ] = str_to_float( szFileAngles2[ 2 ] );
	}
	
	UTIL_CreateBase( gBaseModel, flOriginRed, RED_FLAG, flAnglesRed );
	UTIL_CreateBase( gBaseModel, flOriginBlue, BLUE_FLAG, flAnglesBlue );
		
	fclose( iFile );

	return 1;
}
		
public client_connect( id )
{
	bGotEnemyFlag[ id ] = 0;
}

public client_disconnect( id )
{
	bGotEnemyFlag[ id ] = 0;

	UTIL_RemoveBackFlag( id );
}

public bacon_PreThink( id )
{
	if( is_user_alive( id ) )
	{
		new Float:flGameTime = get_gametime( );
		
		if( flGameTime - flLastHud[ id ] > HUD_MAX_LIFE )
		{
			set_hudmessage( 212, 42, 255, -1.0, 0.02, 1, 6.0, HUD_MAX_LIFE );
			ShowSyncHudMsg( id, gHudSyncScore, "Scoreboard:^nRed: %d | Blue: %d", gRedScore, gBlueScore );
			
			flLastHud[ id ] = flGameTime;
		}
	}
}

public Hook_DeathMessage( )
{
	new iVictim = read_data( 2 );
	
	if( IS_PLAYER( iVictim ) 
	&& bGotEnemyFlag[ iVictim ] == 1 )
	{
		new Float:flOrigin[ 3 ];
		pev( iVictim, pev_origin, flOrigin );
		
		flOrigin[ 2 ] -= 36.0;
		
		bGotEnemyFlag[ iVictim ] = 0;
		UTIL_RemoveBackFlag( iVictim );

		switch( cs_get_user_team( iVictim ) )
		{
			case CS_TEAM_T:
			{
				set_hudmessage( 10, 10, 255, -1.0, 0.65, 1, 6.0, 4.0 );
				ShowSyncHudMsg( iVictim, gHudSyncFlagEvent, "You lost the enemy flag!" );
						
				client_cmd( 0, "mp3 play ^"sound/%s^"", gFlagEventSounds[ BLUE_FLAG_DROPPED ] );
				UTIL_CreateFlag( gFlagModels[ BLUE_FLAG ], flOrigin, BLUE_FLAG );

				bBlueFlagInBase = false;
			}
			
			case CS_TEAM_CT:
			{
				set_hudmessage( 255, 10, 10, -1.0, 0.65, 1, 6.0, 4.0 );
				ShowSyncHudMsg( iVictim, gHudSyncFlagEvent, "You lost the enemy flag!" );

				client_cmd( 0, "mp3 play ^"sound/%s^"", gFlagEventSounds[ RED_FLAG_DROPPED ] );
				UTIL_CreateFlag( gFlagModels[ RED_FLAG ], flOrigin, RED_FLAG );

				bRedFlagInBase = false;
			}
		}
	}
	
	return;
}

public CommandFlagMenu( id )
{
	if( !( get_user_flags( id ) & FLAG_MENU_ACCESS ) )
	{
		ColorChat( id, RED, "^3%s^1 You don't have acces to this menu!", gPluginTag );
		
		return PLUGIN_HANDLED;
	}

	if( !is_user_alive( id ) )
	{
		ColorChat( id, RED, "^3%s^1 You can't create ^4Flags^1 while dead!", gPluginTag );
		
		return PLUGIN_HANDLED;
	}
	
	new iMenu = menu_create( "\wCreate \rFlag\w:", "menu_FlagHandler");
	
	menu_additem( iMenu, "\wCreate \yRed Flag", "1", 0 );
	menu_additem( iMenu, "\wCreate \yBlue Flag", "2", 0 );
	menu_additem( iMenu, "\wDelete \yRed Flag", "3", 0 );
	menu_additem( iMenu, "\wDelete \yBlue Flag", "4", 0 );
	menu_additem( iMenu, "\wSave flag origins", "5", 0 );
	
	menu_setprop( iMenu, MPROP_EXIT, MEXIT_ALL );
	
	menu_display( id, iMenu, 0 );
	
	return PLUGIN_HANDLED;
}

public menu_FlagHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );

		return PLUGIN_HANDLED;
	}

	new szData[ 6 ], szName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, szData, charsmax( szData ), szName, charsmax( szName ), callback );

	new iKey = str_to_num( szData );

	switch( iKey )
	{
		case 1:
		{
			if( bCountFlags[ RED_FLAG ] >= 1 )
			{
				ColorChat( id, RED, "^3%s^1 You already created a^4 Red^1 flag!", gPluginTag );
				
				return PLUGIN_HANDLED;
			}
	
			new Float:flOrigin[ 3 ], Float:flAngles[ 3 ];

			pev( id, pev_origin, flOrigin );
			pev( id, pev_angles, flAngles );

			ColorChat( id, RED, "^3%s^4 Red^1 flag successfuly created!", gPluginTag );
			UTIL_CreateBase( gBaseModel, flOrigin, RED_FLAG, flAngles );

			bCountFlags[ RED_FLAG ]++;

			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}
		
		case 2:
		{
			if( bCountFlags[ BLUE_FLAG ] >= 1 )
			{
				ColorChat( id, RED, "^3%s^1 You already created a^4 Blue^1 flag!", gPluginTag );
				
				return PLUGIN_HANDLED;
			}

			new Float:flOrigin[ 3 ], Float:flAngles[ 3 ];

			pev( id, pev_origin, flOrigin );
			pev( id, pev_angles, flAngles );

			ColorChat( id, RED, "^3%s^4 Blue^1 flag successfuly created!", gPluginTag );
			UTIL_CreateBase( gBaseModel, flOrigin, BLUE_FLAG, flAngles );
			
			bCountFlags[ BLUE_FLAG ]++;

			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}
		
		case 3:
		{
			UTIL_RemoveBase( RED_FLAG );
			ColorChat( id, RED, "^3%s^4 Red^1 flag successfuly deleted!", gPluginTag );

			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}
		
		case 4:
		{
			UTIL_RemoveBase( BLUE_FLAG );
			ColorChat( id, RED, "^3%s^4 Blue^1 flag successfuly deleted!", gPluginTag );

			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}
		
		case 5:
		{
			new szConfigsDir[ 64 ], szFile[ 64 ];
			get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
			
			new szMap[ 40 ];
			get_mapname( szMap, charsmax( szMap ) );
		
			formatex( szFile, charsmax( szFile ), "%s/%s_bases.ctf", szConfigsDir, szMap );
			
			if( file_exists( szFile ) )
			{
				delete_file( szFile );
			}
			
			new iEnt = FM_NULLENT;
			new szBuffer[ 256 ], iBaseTeam;
			
			new Float:flRedBaseOrigin[ 3 ], flRedBaseAngles[ 3 ];
			new Float:flBlueBaseOrigin[ 3 ], flBlueBaseAngles[ 3 ];
			
			while( ( iEnt = engfunc( EngFunc_FindEntityByString, iEnt, "classname", gBaseClassname ) ) )
			{
				iBaseTeam = pev( iEnt, pev_iuser2 );
				
				switch( iBaseTeam )
				{
					case RED_FLAG:
					{
						pev( iEnt, pev_origin, flRedBaseOrigin );
						pev( iEnt, pev_angles, flRedBaseAngles );
					}
					
					case BLUE_FLAG:
					{
						pev( iEnt, pev_origin, flBlueBaseOrigin );
						pev( iEnt, pev_angles, flBlueBaseAngles );
					}
				}
			}
			
			formatex( szBuffer, charsmax( szBuffer ), "%f %f %f %f %f %f | %f %f %f %f %f %f", flRedBaseOrigin[ 0 ], flRedBaseOrigin[ 1 ], flRedBaseOrigin[ 2 ], flRedBaseAngles[ 0 ], flRedBaseAngles[ 1 ], flRedBaseAngles[ 2 ], flBlueBaseOrigin[ 0 ], flBlueBaseOrigin[ 1 ], flBlueBaseOrigin[ 2 ], flBlueBaseAngles[ 0 ], flBlueBaseAngles[ 1 ], flBlueBaseAngles[ 2 ] );
			write_file( szFile, szBuffer, -1 );
			
			ColorChat( id, RED, "^3%s^1 All flags are successfuly saved!", gPluginTag );
		}
	}
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public forward_TouchedFlag( iFlag, iPlayer )
{
	if( pev_valid( iFlag ) )
	{
		new iBaseTeam = pev( iFlag, pev_iuser2 );
		
		new szName[ 40 ];
		get_user_name( iPlayer, szName, charsmax( szName ) );

		if( iBaseTeam == RED_FLAG
		&& cs_get_user_team( iPlayer ) == CS_TEAM_CT )
		{
			engfunc( EngFunc_RemoveEntity, iFlag );
			UTIL_CreateBackFlag( iPlayer,  gBackFlagModels[ RED_FLAG ], { 255, 10, 10 } );
			
			bGotEnemyFlag[ iPlayer ] = 1;
			bRedFlagInBase = false;
			
			set_hudmessage( 255, 10, 10, -1.0, 0.65, 1, 6.0, 4.0 );
			ShowSyncHudMsg( iPlayer, gHudSyncFlagEvent, "You got the enemy flag!" );

			client_cmd( 0, "mp3 play ^"sound/%s^"", gFlagEventSounds[ RED_FLAG_TAKEN ] );
		}

		if( iBaseTeam == BLUE_FLAG
		&& cs_get_user_team( iPlayer ) == CS_TEAM_T )
		{
			engfunc( EngFunc_RemoveEntity, iFlag );
			UTIL_CreateBackFlag( iPlayer,  gBackFlagModels[ BLUE_FLAG ], { 10, 10, 255 } );
			
			bGotEnemyFlag[ iPlayer ] = 1;
			bBlueFlagInBase = false;

			set_hudmessage( 10, 10, 255, -1.0, 0.65, 1, 6.0, 4.0 );
			ShowSyncHudMsg( iPlayer, gHudSyncFlagEvent, "You got the enemy flag!" );

			client_cmd( 0, "mp3 play ^"sound/%s^"", gFlagEventSounds[ BLUE_FLAG_TAKEN ] );
		}

		if( bGotEnemyFlag[ iPlayer ] == 1
		&& iBaseTeam == BLUE_FLAG
		&& cs_get_user_team( iPlayer ) == CS_TEAM_CT
		&& bBlueFlagInBase == true )
		{
			bGotEnemyFlag[ iPlayer ] = 0;
			gBlueScore++;

			set_hudmessage( 255, 10, 10, -1.0, 0.65, 1, 6.0, 4.0 );
			ShowSyncHudMsg( iPlayer, gHudSyncFlagEvent, "Nice!^nYou captured the enemy flag!" );

			ColorChat( 0, RED, "^3%s^4 %s^1 captured the^4 T^1 flag!", gPluginTag, szName );
			UTIL_RemoveBackFlag( iPlayer );
			
			client_cmd( 0, "mp3 play ^"sound/%s^"", gFlagEventSounds[ BLUE_TEAM_SCORES ] );
			UTIL_CreateFlag( gFlagModels[ RED_FLAG ], flRedBaseOrigins, RED_FLAG );
		}
		
		if( bGotEnemyFlag[ iPlayer ] == 1
		&& iBaseTeam == RED_FLAG
		&& cs_get_user_team( iPlayer ) == CS_TEAM_T  
		&& bRedFlagInBase == true )
		{
			bGotEnemyFlag[ iPlayer ] = 0;
			gRedScore++;

			set_hudmessage( 10, 10, 255, -1.0, 0.65, 1, 6.0, 4.0 );
			ShowSyncHudMsg( iPlayer, gHudSyncFlagEvent, "Nice!^nYou captured the enemy flag!" );
			
			ColorChat( 0, RED, "^3%s^4 %s^1 captured the^4 CT^1 flag!", gPluginTag, szName );
			UTIL_RemoveBackFlag( iPlayer );
			
			client_cmd( 0, "mp3 play ^"sound/%s^"", gFlagEventSounds[ RED_TEAM_SCORES ] );
			UTIL_CreateFlag( gFlagModels[ BLUE_FLAG ], flBlueBaseOrigins, BLUE_FLAG );
		}
	}		
}

public forward_BaseThink( iEnt )
{
	if( pev_valid( iEnt ) )
	{
		set_pev( iEnt, pev_nextthink, get_gametime( ) + 1.0 );
		
		set_pev( iEnt, pev_sequence, 0 );
		set_pev( iEnt, pev_framerate, 1.0 );
		
		new id;
		new iBaseTeam = pev( iEnt, pev_iuser2 );

		for( id = 1; id <= gMaxPlayers; id++ )
		{
			if( IS_PLAYER( id ) 
			&& is_user_connected( id ) )
			{
				if( is_user_alive( id ) 
				&& ( cs_get_user_team( id ) == CS_TEAM_T && iBaseTeam == BLUE_FLAG && bBlueFlagInBase == true )
				|| ( cs_get_user_team( id ) == CS_TEAM_CT && iBaseTeam == RED_FLAG && bRedFlagInBase == true ) )
				{
					new Float:flOrigin[ 3 ], Float:flBaseOrigin[ 3 ], iOrigin[ 3 ];

					pev( id, pev_origin, flOrigin );
					pev( iEnt, pev_origin, flBaseOrigin );

					FVecIVec( flBaseOrigin, iOrigin );
						
					if( get_distance_f( flBaseOrigin, flOrigin ) <= float( get_pcvar_num( gCvarEnemyBaseRadiusDmg ) ) )
					{
						if( UTIL_IsVisible( id, iEnt ) )
						{
							switch( iBaseTeam )
							{
								case RED_FLAG:
								{
									UTIL_BeamEnt( iEnt, id, { 255, 10, 10 } );
									UTIL_Fade( id, { 255, 10, 10 } );
								}
								
								case BLUE_FLAG:
								{
									UTIL_BeamEnt( iEnt, id, { 10, 10, 255 } );
									UTIL_Fade( id, { 10, 10, 255 } );
								}
							}

							ExecuteHam( Ham_TakeDamage, id, iEnt, iEnt, float( get_pcvar_num( gCvarEnemyBaseDamage ) ), DMG_PARALYZE  );
						}
					}
				}
			}
		}
	}
}
	
public forward_FlagThink( iEnt )
{
	if( pev_valid( iEnt ) )
	{
		set_pev( iEnt, pev_nextthink, get_gametime( ) + 0.001 );
		
		set_pev( iEnt, pev_sequence, 0 );
		set_pev( iEnt, pev_framerate, 0.7 );
	}
}

public plugin_end( )
{
	gBlueScore = 0;
	gRedScore = 0;
}

stock UTIL_CreateBase( const szModel[ ], Float:flOrigin[ 3 ], const iBaseType, Float:flAngles[ 3 ] )
{
	new iEntity = create_entity( "info_target" );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEntity, pev_classname, gBaseClassname );
	engfunc( EngFunc_SetModel, iEntity, szModel );
	
	set_pev( iEntity, pev_origin, flOrigin );
	set_pev( iEntity, pev_solid, SOLID_NOT );
	set_pev( iEntity, pev_movetype, MOVETYPE_TOSS );
	set_pev( iEntity, pev_iuser2, iBaseType );
	set_pev( iEntity, pev_takedamage, DAMAGE_NO );
	set_pev( iEntity, pev_angles, flAngles );
	set_pev( iEntity, pev_sequence, 0 );
	set_pev( iEntity, pev_framerate, 1.0 );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 5.0 );

	engfunc( EngFunc_DropToFloor, iEntity );

	switch( pev( iEntity, pev_iuser2 ) )
	{
		case RED_FLAG:
		{
			UTIL_CreateFlag( gFlagModels[ RED_FLAG ], flOrigin, RED_FLAG );
				
			if( get_pcvar_num( gCvarEnableGlow ) == 1 )
			{
				set_rendering( iEntity, kRenderFxGlowShell, 255, 10, 10, kRenderNormal, 25 );
			}
		}
		
		case BLUE_FLAG:
		{
			UTIL_CreateFlag( gFlagModels[ BLUE_FLAG ], flOrigin, BLUE_FLAG );
			
			if( get_pcvar_num( gCvarEnableGlow ) == 1 )
			{
				set_rendering( iEntity, kRenderFxGlowShell, 10, 10, 255, kRenderNormal, 25 );
			}
		}
	}

	return PLUGIN_HANDLED;
}

stock UTIL_CreateFlag( const szModel[ ], Float:flOrigin[ 3 ], const iFlagType )
{
	new iEntity = create_entity( "info_target" );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	flOrigin[ 2 ] += 1.5;

	new Float:flAngles[ 3 ];
	pev( iEntity, pev_angles, flAngles );
	
	flAngles[ 1 ] += random_float( 1.0, 360.0 );

	set_pev( iEntity, pev_classname, gFlagClassname );
	engfunc( EngFunc_SetModel, iEntity, szModel );
	engfunc( EngFunc_SetSize, iEntity, flFlagMinSize, flFlagMaxSize );

	set_pev( iEntity, pev_origin, flOrigin );
	set_pev( iEntity, pev_solid, SOLID_BBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_iuser2, iFlagType );
	set_pev( iEntity, pev_takedamage, DAMAGE_NO );
	set_pev( iEntity, pev_angles, flAngles );
	set_pev( iEntity, pev_sequence, 0 );
	set_pev( iEntity, pev_framerate, 0.7 );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 0.001 );
	
	switch( pev( iEntity, pev_iuser2 ) )
	{
		case RED_FLAG:
		{
			if( get_pcvar_num( gCvarEnableGlow ) == 1 )
			{
				set_rendering( iEntity, kRenderFxGlowShell, 255, 10, 10, kRenderNormal, 5 );
			}
			
			bRedFlagInBase = true;
		}
		
		case BLUE_FLAG:
		{
			if( get_pcvar_num( gCvarEnableGlow ) == 1 )
			{
				set_rendering( iEntity, kRenderFxGlowShell, 10, 10, 255, kRenderNormal, 5 );
			}
			
			bBlueFlagInBase = true;
		}
	}

	return PLUGIN_HANDLED;
}

stock UTIL_RemoveBase( const iBaseType ) 
{
	new iEnt = FM_NULLENT;

	while( ( iEnt = find_ent_by_class( iEnt, gBaseClassname ) ) )
	{
		new iBaseTeam = pev( iEnt, pev_iuser2 );
				
		if( iBaseTeam == iBaseType )
		{
			engfunc( EngFunc_RemoveEntity, iEnt );
					
			bCountFlags[ iBaseType ] = 0;
		}
	}
	
	while( ( iEnt = find_ent_by_class( iEnt, gFlagClassname ) ) )
	{
		new iFlagTeam = pev( iEnt, pev_iuser2 );
				
		if( iFlagTeam == iBaseType )
		{
			engfunc( EngFunc_RemoveEntity, iEnt );
		}
	}
}

stock UTIL_CreateBackFlag( id, const szModel[ ], iColor[ 3 ] )
{
	engfunc( EngFunc_RemoveEntity, bBackFlag[ id ] );
	new iEntity = bBackFlag[ id ] = create_entity( "info_target" );
	
	if( pev_valid( iEntity ) )
	{
		engfunc( EngFunc_SetModel, iEntity, szModel );

		set_pev( iEntity, pev_movetype, MOVETYPE_FOLLOW );
		set_pev( iEntity, pev_aiment, id );
		
		set_rendering( iEntity, kRenderFxGlowShell, iColor[ 0 ], iColor[ 1 ], iColor[ 2 ], kRenderNormal, 5 );
	}
}

stock UTIL_RemoveBackFlag( id )
{
	if( bBackFlag[ id ] > 0 )
	{
		engfunc( EngFunc_RemoveEntity, bBackFlag[ id ] );
	}

	bBackFlag[ id ] = 0;
}

stock bool:UTIL_IsVisible( index, entity, ignoremonsters = 0 )
{
	new Float:flStart[ 3 ], Float:flDest[ 3 ];
	pev( index, pev_origin, flStart );
	pev( index, pev_view_ofs, flDest );

	xs_vec_add( flStart, flDest, flStart );
    
	pev( entity, pev_origin, flDest );
	engfunc( EngFunc_TraceLine, flStart, flDest, ignoremonsters, index, 0 );
    
	new Float:flFraction;
	get_tr2( 0, TR_flFraction, flFraction );
	
	if( flFraction == 1.0 || get_tr2( 0, TR_pHit ) == entity )
	{
		return true;
	}
    
	return false;
}

stock UTIL_BeamEnt( iStart, iEnd, iColor[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY );
	write_byte( TE_BEAMENTS );
	write_short( iStart );
	write_short( iEnd  );
	write_short( gSpriteLight );
	write_byte( 2 );
	write_byte( 8 );
	write_byte( 3 );
	write_byte( 35 );
	write_byte( 1 );
	write_byte( iColor[ 0 ] );
	write_byte( iColor[ 1 ] );
	write_byte( iColor[ 2 ] );
	write_byte( 255 );
	write_byte( 1 );
	message_end( );
}

stock UTIL_Fade( id, iColor[ 3 ] )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade, _, id );
	write_short( 1 << 12 );
	write_short( 1 << 12 );
	write_short( 1 << 12 );
	write_byte( iColor[ 0 ] );
	write_byte( iColor[ 1 ] );
	write_byte( iColor[ 2 ] );
	write_byte( 130 );
	message_end( );
}
