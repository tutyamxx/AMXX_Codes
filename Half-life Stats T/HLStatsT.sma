/*	Formatexright © 2010, tuty

	Half Life StatsT is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Half Life StatsT; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/



#include < amxmodx >
#include < nvault >
#include < fakemeta >

#define PLUGIN_NAME		"Half Life StatsT"
#define PLUGIN_VERSION 		"3.0.0"
#define PLUGIN_AUTHOR 		"tuty" 

#define TOP_PLAYERS		15
#define HL_LEVELS		9
#define TASK_INFO		7.0
#pragma semicolon 1

new gName[ 32 ];
new vKey[ 64 ];
new vData[ 256 ];
new gSoundKills[ 33 ] = { 0,... };

new gCrowbarKills[ 33 ];
new gGlockKills[ 33 ];
new gPythonKills[ 33 ];
new gMp5Kills[ 33 ];
new gCrossBowKills[ 33 ];
new gShotGunKills[ 33 ];
new gRpgKills[ 33 ];
new gGaussKills[ 33 ];
new gEgonKills[ 33 ];
new gHornetKills[ 33 ];
new gGrenadeKills[ 33 ];
new gTripMineKills[ 33 ];
new gSatchelKills[ 33 ];
new gSnarkKills[ 33 ];
new gPoints[ 33 ];
new gDeaths[ 33 ];
new gFrags[ 33 ];
new gSuicides[ 33 ];

new i;
new gVault;
new gEasyWeaponsPoints;
new gHardWeaponsPoints;
new gMediumWeaponsPoints;
new gNoobWeaponPoints;
new gSuiciderPoints;
new gStatsEnabled;
new gShowPlayerNames;
new gEnableStreak;
new gShowStatsAtEnd;
new gMaxFrags;
new gShowWinner;
new gNextMap;
new gHudSync;
new gHudSync2;
new gHudSync3;

new gLevels[ HL_LEVELS ] = { 3, 5, 7, 9, 11, 13, 16, 18, 20 };

new gSounds[ HL_LEVELS ][] = 
{
	"hlstatst/hlstatst_multikill.wav",
	"hlstatst/hlstatst_ultrakill.wav",
	"hlstatst/hlstatst_killingspree.wav",
	"hlstatst/hlstatst_megakill.wav",
	"hlstatst/hlstatst_holyshit.wav",
	"hlstatst/hlstatst_ludicrouskill.wav",
	"hlstatst/hlstatst_rampage.wav",
	"hlstatst/hlstatst_godlike.wav",
	"hlstatst/hlstatst_monsterkill.wav"
};

new gMessages[ HL_LEVELS ][] =
{
	"%s # Multi KILL ! ( 3 frags )",
	"%s # Ultra KILL ! ( 5 frags )",
	"%s # Killing Spree ! ( 7 frags )",
	"%s # Mega KILL ! ( 9 frags )",
	"%s # Holy Shit! ( 11 frags )",
	"%s # Ludicrous KILL ! ( 13 frags )",
	"%s # Rampage ! ( 16 frags )",
	"%s # God Like ! ( 18 frags )",
	"%s # Monster KILL ! ( 20 frags )"
};

public plugin_init()
{
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );

	register_event( "DeathMsg", "hook_death", "a" );
	register_forward( FM_PlayerPreThink, "forward_prethink" );
	register_event( "30", "eventIntermission", "a" );
	
	register_clcmd( "say /rank", "HLRank" );
	register_clcmd( "say_team /rank", "HLRank" );
	register_clcmd( "say /top15", "HLTop15" );
	register_clcmd( "say_team /top15", "HLTop15" );
	register_clcmd( "say /rankstats", "HLRankStats" );
	register_clcmd( "say_team /rankstats", "HLRankStats" );
	register_clcmd( "say /statshelp", "HLHelp" );
	register_clcmd( "say_team /statshelp", "HLHelp" );
	register_clcmd( "say /weaponstats", "HLWeaponStats" );
	register_clcmd( "say_team /weaponstats", "HLWeaponStats" );
	
	gStatsEnabled = register_cvar( "hl_statst_enabled", "1" );
	gShowPlayerNames = register_cvar( "hl_statst_showname", "1" );
	gEnableStreak = register_cvar( "hl_statst_streak", "1" );
	gEasyWeaponsPoints = register_cvar( "hl_statst_easypoints", "2" );
	gNoobWeaponPoints = register_cvar( "hl_statst_noobpoints", "6" );
	gMediumWeaponsPoints = register_cvar( "hl_statst_mediumpoints", "8" );
	gHardWeaponsPoints = register_cvar( "hl_statst_hardpoints", "9" );
	gSuiciderPoints = register_cvar( "hl_statst_suiciderpoints", "5" );
	gShowStatsAtEnd = register_cvar( "hl_statst_showstats_end", "1" ); // 0 - show nothing, 1 - weapon stats, 2 - top 15, 3 - rankstats
	gShowWinner = register_cvar( "hl_statst_showwinner", "1" );

	gMaxFrags = get_cvar_pointer( "mp_fraglimit" );
	gNextMap = get_cvar_pointer( "amx_nextmap" );

	gHudSync = CreateHudSyncObj();
	gHudSync2 = CreateHudSyncObj();
	gHudSync3 = CreateHudSyncObj();
}

public plugin_precache()
{
	for( i = 0; i < HL_LEVELS; i++ )
	{
		precache_sound( gSounds[ i ] );
	}
}

public client_connect( id )
{
	gCrowbarKills[ id ] = 0;
	gGlockKills[ id ] = 0;
	gPythonKills[ id ] = 0;
	gMp5Kills[ id ] = 0;
	gCrossBowKills[ id ] = 0;
	gShotGunKills[ id ] = 0;
	gRpgKills[ id ] = 0;
	gGaussKills[ id ] = 0;
	gEgonKills[ id ] = 0;
	gHornetKills[ id ] = 0;
	gGrenadeKills[ id ] = 0;
	gTripMineKills[ id ] = 0;
	gSatchelKills[ id ] = 0;
	gSnarkKills[ id ] = 0;
	gSoundKills[ id ] = 0;
}

public client_putinserver( id )
{
	 LoadRankings( id );

	 set_task( TASK_INFO, "ShowHLHelp", id );
}

public client_disconnect( id )
{
	gCrowbarKills[ id ] = 0;
	gGlockKills[ id ] = 0;
	gPythonKills[ id ] = 0;
	gMp5Kills[ id ] = 0;
	gCrossBowKills[ id ] = 0;
	gShotGunKills[ id ] = 0;
	gRpgKills[ id ] = 0;
	gGaussKills[ id ] = 0;
	gEgonKills[ id ] = 0;
	gHornetKills[ id ] = 0;
	gGrenadeKills[ id ] = 0;
	gTripMineKills[ id ] = 0;
	gSatchelKills[ id ] = 0;
	gSnarkKills[ id ] = 0;
	
	SaveRankings( id );
}

public hook_death()
{
	if( get_pcvar_num( gStatsEnabled ) == 1 )
	{
		new k = read_data( 1 );
		gFrags[ k ]++;
	
		new v = read_data( 2 );
		gDeaths[ v ]++;
	
		if( k == v )
		{
			gFrags[ k ] -= 1;
			gPoints[ k ] -= get_pcvar_num( gSuiciderPoints );
			gSuicides[ k ]++;
			
			return PLUGIN_CONTINUE;
		}

		gPoints[ v ] -= 1;
	
		new weapon[ 30 ];
		read_data( 3, weapon, charsmax( weapon ) );
	
		if( equali( weapon, "hornetgun" ) || equali( weapon, "snark" ) || equali( weapon, "tripmine" ) || equali( weapon, "satchel" ) || equali( weapon, "handgrenade" ) )
		{
			gPoints[ k ] += get_pcvar_num( gHardWeaponsPoints );
		}

		if( equali( weapon, "python" ) || equali( weapon, "357" ) || equali( weapon, "9mmhandgun" ) || equali( weapon, "glock" ) )
		{
			gPoints[ k ] += get_pcvar_num( gMediumWeaponsPoints );
		}
	
		if( equali( weapon, "rpg" ) || equali( weapon, "shotgun" ) || equali( weapon, "crossbow" ) )
		{
			gPoints[ k ] += get_pcvar_num( gNoobWeaponPoints );
		}
	
		if( equali( weapon, "9mmAR" )  || equali( weapon, "gauss" ) || equali( weapon, "egon" ) || equali( weapon, "mp5" ) || equali( weapon, "crowbar" ) )
		{
			gPoints[ k ] += get_pcvar_num( gEasyWeaponsPoints );
		}
		
		if( is_user_alive( k ) )
		{
			switch( get_user_weapon( k ) )
			{
				case HLW_CROWBAR: gCrowbarKills[ k ]++;
				case HLW_GLOCK: gGlockKills[ k ]++;	
				case HLW_PYTHON: gPythonKills[ k ]++;
				case HLW_MP5: gMp5Kills[ k ]++;
				case HLW_CROSSBOW: gCrossBowKills[ k ]++;
				case HLW_SHOTGUN: gShotGunKills[ k ]++;
				case HLW_RPG: gRpgKills[ k ]++;
				case HLW_GAUSS: gGaussKills[ k ]++;
				case HLW_EGON: gEgonKills[ k ]++;
				case HLW_HORNETGUN: gHornetKills[ k ]++;
				case HLW_HANDGRENADE: gGrenadeKills[ k ]++;
				case HLW_TRIPMINE: gTripMineKills[ k ]++;
				case HLW_SATCHEL: gSatchelKills[ k ]++;
				case HLW_SNARK: gSnarkKills[ k ]++;
			}
		}
			
		gSoundKills[ k ] += 1;
		gSoundKills[ v ] = 0;
			
		if( get_pcvar_num( gEnableStreak ) == 1 )
		{
			for( i = 0; i < HL_LEVELS; i++ ) 
			{
				if( gSoundKills[ k ] == gLevels[ i ] ) 
				{
					hlstatst_announce( k, i );

					return PLUGIN_CONTINUE;
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public HLRank( id )
{
	if( get_pcvar_num( gStatsEnabled ) == 0 )
	{
		client_print( id, print_chat, "-=[ HL StatsT ]=- Sorry, the plugin is disabled!" );
		return PLUGIN_HANDLED;
	}
	
	client_print( id, print_chat, "-=[ HL StatsT ]=- Your rank: Points: %d | Kills: %d | Deaths: %d | Suicides: %d", gPoints[ id ], gFrags[ id ], gDeaths[ id ], gSuicides[ id ] );
	client_print( id, print_chat, "-=[ HL StatsT ]=- This StatsT is created by %s! For more info Y!M: tuty_max_boy", PLUGIN_AUTHOR );
	
	return PLUGIN_CONTINUE;
}

public HLTop15( id )
{
	if( get_pcvar_num( gStatsEnabled ) == 0 )
	{
		client_print( id, print_chat, "-=[ HL StatsT ]=- Sorry, the plugin is disabled!" );
		return PLUGIN_HANDLED;
	}
	
	static Sort[ 33 ][ 2 ];
	new Count;
	
	new Players[ 32 ], Num, Player;
	get_players( Players, Num );
	
	for( i = 0; i < Num; i++ )
	{
		Player = Players[ i ];
		
		Sort[ Count ][ 0 ] = Player;
		Sort[ Count ][ 1 ] = gPoints[ Player ];
		
		Count++;
	}
	
	SortCustom2D( Sort, Count, "points_compare" );
	
	new szBuffer[ 2000 ], num;
	num = formatex( szBuffer, charsmax( szBuffer ), "# | Name     |     SkillPoints     |     Kills     |     Deaths     |     Suicides^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "--------------------------------------------------------------------------^n^n" );
	
	
	new b = clamp( Count, 0, TOP_PLAYERS );
	new user;
	
	for( new a = 0; a < b; a++ )
	{
		user = Sort[ a ][ 0 ];
		get_user_name( user, gName, charsmax( gName ) );
		num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "%d | %s     |     %d     |     %d     |     %d     |     %d^n", a + 1, gName, Sort[ a ][ 1 ], gFrags[ user ], gDeaths[ user ], gSuicides[ user ] );
	}
	
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "--------------------------------------------------------------------------^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "-=[ HL StatsT created by %s. For more info Y!M: tuty_max_boy ]=-", PLUGIN_AUTHOR );
	show_motd( id, szBuffer, "-=[ HL StatsT Top 15 ]=-" );
	
	return PLUGIN_CONTINUE;
}

public HLRankStats( id )
{
	if( get_pcvar_num( gStatsEnabled ) == 0 )
	{
		client_print( id, print_chat, "-=[ HL StatsT ]=- Sorry, the plugin is disabled!" );
		return PLUGIN_HANDLED;
	}
	
	new szBuffer[ 1800 ], steam[ 32 ], num;
	get_user_name( id, gName, charsmax( gName ) );
	get_user_authid( id, steam, charsmax( steam ) );

	new players = get_playersnum( 1 );
	new maxplayers = get_maxplayers();
	
	new time[ 49 ];
	get_time( "%H:%M:%S - %p | %A %B %Y", time, charsmax( time ) );
	
	num = formatex( szBuffer, charsmax( szBuffer ), "--------------------------------------------------------------------------^n^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "-=[ Info ]=-^n^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "%s^n^n", time );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Players Online: %d / %d^n", players, maxplayers );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Nick: %s^n", gName );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "User ID: #%d^n", get_user_userid( id ) );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Steam ID: %s^n^n", steam );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "-=[ Stats ]=-^n^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "SkillPoints: %d^n", gPoints[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Kills: %d^n", gFrags[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Deaths: %d^n", gDeaths[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Suicides: %d^n^n", gSuicides[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "--------------------------------------------------------------------------^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "-=[ HL StatsT created by %s. For more info Y!M: tuty_max_boy ]=-", PLUGIN_AUTHOR );
	
	show_motd( id, szBuffer, "-=[ HL StatsT Rankstats ]=-" );

	return PLUGIN_CONTINUE;
}

public HLHelp( id )
{
	if( get_pcvar_num( gStatsEnabled ) == 0 )
	{
		client_print( id, print_chat, "-=[ HL StatsT ]=- Sorry, the plugin is disabled!" );
		return PLUGIN_HANDLED;
	}	
	
	new szBuffer[ 1000 ], num;
	num = formatex( szBuffer, charsmax( szBuffer ), "--------------------------------------------------------------------------^n^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "The commands are:^n^n^n^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, " - '/rank' ( display your current rank )^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, " - '/top15' ( display the best 15 players )^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, " - '/rankstats' ( display your full rankstats )^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, " - '/weaponstats' ( display your weapon statistics on current map )^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, " - '/statshelp' ( display some help )^n^n^n^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "--------------------------------------------------------------------------^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "-=[ HL StatsT created by %s. For more info Y!M: tuty_max_boy ]=-", PLUGIN_AUTHOR );
	
	show_motd( id, szBuffer, "-=[ HL StatsT Help ]=-" );

	return PLUGIN_CONTINUE;
}	

public HLWeaponStats( id )
{
	if( get_pcvar_num( gStatsEnabled ) == 0 )
	{
		client_print( id, print_chat, "-=[ HL StatsT ]=- Sorry, the plugin is disabled!" );
		return PLUGIN_HANDLED;
	}	
	
	new map[ 32 ];
	get_mapname( map, charsmax( map ) );
	
	new szBuffer[ 3000 ], num;
	num = formatex( szBuffer, charsmax( szBuffer ), "--------------------------------------------------------------------------^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Your Weapon Statistics on '%s' are:^n^n", map );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Crowbar Kills: %d^n", gCrowbarKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "9mmhandgun or Glock Kills: %d^n", gGlockKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "357 or Python Kills: %d^n", gPythonKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Mp5 or 9mmAR Kills: %d^n", gMp5Kills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Shotgun Kills: %d^n", gShotGunKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Crossbow Kills: %d^n", gCrossBowKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "RPG Kills: %d^n", gRpgKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Gauss Kills: %d^n", gGaussKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Egon Kills: %d^n", gEgonKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Hornetgun Kills: %d^n", gHornetKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "HandGrenade Kills: %d^n", gGrenadeKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Satchel Kills: %d^n", gSatchelKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Tripmine Kills: %d^n", gTripMineKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "Snark or Squeak Grenade Kills: %d^n^n", gSnarkKills[ id ] );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "--------------------------------------------------------------------------^n" );
	num += formatex( szBuffer[ num ], charsmax( szBuffer ) - num, "-=[ HL StatsT created by %s. For more info Y!M: tuty_max_boy ]=-", PLUGIN_AUTHOR );
	
	show_motd( id, szBuffer, "-=[ HL Weapon Stats ]=-" );

	return PLUGIN_CONTINUE;
}
	
public eventIntermission()
{
	if( get_pcvar_num( gStatsEnabled ) == 1 )
	{
		set_task( 0.3, "showAtEnd", 900 );
	}
}

public showAtEnd()
{
	new players[ 32 ], num, id;
	get_players( players, num );
	
	new maxfrags = get_pcvar_num( gMaxFrags );

	new map[ 32 ];
	get_pcvar_string( gNextMap, map, charsmax( map ) );
	
	for( i = 0; i < num; i++ )
	{
		id = players[ i ];
		get_user_name( id, gName, charsmax( gName ) );
		
		if( get_pcvar_num( gShowWinner ) == 1 )
		{
			if( get_user_frags( id ) == maxfrags )
			{
				client_print( 0, print_chat, "-=[ HL StatsT ]=- Winner of the game is: %s! (%d frags)", gName, maxfrags  );
				client_print( 0, print_chat, "-=[ HL StatsT ]=- The next map will be: %s", map );

				client_cmd( id, "speak ^"holo/tr_holo_fantastic tr_holo_keeptrying^"" );
			}
		}
		
		switch( get_pcvar_num( gShowStatsAtEnd ) )
		{
			case 0:	return PLUGIN_CONTINUE;
			case 1:	HLWeaponStats( id );
			case 2:	HLTop15( id );
			case 3:	HLRankStats( id );
		}
	}

	return PLUGIN_CONTINUE;
}
		
public forward_prethink( id )
{
	if( get_pcvar_num( gStatsEnabled ) == 1 && get_pcvar_num( gShowPlayerNames ) == 1 )
	{
		new target, body;
		get_user_aiming( id, target, body );
		
		if( pev_valid( target ) && is_user_alive( target ) )
		{
			new model[ 20 ];
		
			get_user_info( target, "model", model, charsmax( model ) );
			get_user_name( target, gName, charsmax( gName ) );
			
			set_hudmessage( 42, 85, 255, -1.0, 0.76, 1, 6.0, 1.0 );
			ShowSyncHudMsg( id, gHudSync2, "%s^n(%s)^n^n[%s]", gName, model, get_user_weapon2( target ) );
		}
	}
}
	
public ShowHLHelp( id )
{
	set_hudmessage( 255, 85, 0, -1.0, 0.93, 0, 6.0, 12.0 );
	ShowSyncHudMsg( id, gHudSync3, "This server is running HLStatsT by %s!^nType /statshelp to get more info!", PLUGIN_AUTHOR );

	client_cmd( id, "speak ^"vox/this sewer use status system and is supercooled^"" );
}

public points_compare( elem1[], elem2[] )
{
	if( elem1[ 1 ] > elem2[ 1 ] )
	{
		return -1;
	}
	else if( elem1[ 1 ] < elem2[ 1 ] )
	{
		return 1;
	}
	return 0;
}

stock SaveRankings( index )
{
	gVault = nvault_open( "HalfLife1_Ranks" );
	get_user_name( index, gName, charsmax( gName ) );
	formatex( vKey, charsmax( vKey ), "%s-halfliferanking", gName );
	formatex( vData, charsmax( vData ), "%i#%i#%i#%i", gPoints[ index ], gFrags[ index ], gDeaths[ index ], gSuicides[ index ] );
	nvault_set( gVault, vKey, vData );
	nvault_close( gVault );
}

stock LoadRankings( index )
{
	gVault = nvault_open( "HalfLife1_Ranks" );
	get_user_name( index, gName, charsmax( gName ) );
	replace_all( gName, charsmax( gName ), " ", "'" );
	formatex( vKey, charsmax( vKey ), "%s-halfliferanking", gName );
	formatex( vData, charsmax( vData ), "%i#%i#%i#%i", gPoints[ index ], gFrags[ index ], gDeaths[ index ], gSuicides[ index ] );
	nvault_get( gVault, vKey, vData, charsmax( vData ) );

	replace_all( vData, charsmax( vData ), "#", " " );
	
	new points[ 33 ], frags[ 33 ], deaths[ 33 ], suicides[ 33 ];
	parse( vData, points, charsmax( points ), frags, charsmax( frags ), deaths, charsmax( deaths ), suicides, charsmax( suicides ) );

	gPoints[ index ] = str_to_num( points );
	gFrags[ index ] = str_to_num( frags );
	gDeaths[ index ] = str_to_num( deaths );
	gSuicides[ index ] = str_to_num( suicides );
}

stock hlstatst_announce( killer, level )		
{
	get_user_name( killer, gName, charsmax( gName ) );
	set_hudmessage( random( 255 ), random( 255 ), random( 255 ), 0.07, 0.57, 2, 6.0, 5.0 );
	
	ShowSyncHudMsg( 0, gHudSync, gMessages[ level ], gName );
	client_cmd( 0, "speak %s", gSounds[ level ] );
}

stock get_user_weapon2( index )
{
    	new szWeapon[ 20 ];
    	get_weaponname( get_user_weapon( index ), szWeapon, charsmax( szWeapon ) );
   	replace( szWeapon, charsmax( szWeapon ), "weapon_", "" );
    
   	return szWeapon;
}
