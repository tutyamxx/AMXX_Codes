
#include < amxmodx >

#include < fun >
#include < fakemeta >
#include < cstrike >
#include < hamsandwich >

#include < csx >
#include < sqlx >
#include < xs >

#pragma semicolon 1

#define MAX_PLAYERS			32 + 1

#define TUTOR_RED_TIME			6.0
#define TUTOR_BLUE_TIME			4.0
#define TUTOR_GREEN_TIME		6.0

#define TASK_TUTOR			791238
#define TASK_GLOW_GOLD			213120

#define ALPHA_FULLBLINDED    		255
#define HITGROUP_HEAD    		1
#define HUNDERD_UNITS_INAIR		60.0

#define UNITS_TO_KM(%1)			( ( %1 / 35 ) / 1000 )
#define DAMAGE_TO_POINT(%1)		( %1 / 10 )
#define IS_PLAYER(%1)			( 1 <= %1 <= gMaxPlayers )
	
enum _: iMaxBoolCells
{
	DAMAGE_1,
	DAMAGE_2,
	MONEY_1,
	MONEY_2,
	MONEY_3,
	MONEY_4,
	WALK_1,
	WALK_2,
	SECRET_PLACE,
	WALK_3,
	WALK_4,
	SEXY_PLACE,
	HACKER_PLACE,
	SECRET_PLACE2
};

enum _: iTutorColors
{
	RED = 1,
	BLUE,
	YELLOW,
	GREEN
};

enum _: iEntityNames
{
	ENTITY_NAME_ARCTIC,
	ENTITY_NAME_SEXY,
	ENTITY_NAME_HACKER,
	ENTITY_NAME_ARCTIC_2
};

enum _: iAchievements
{
	ACHIEVEMENT_DOMINATION,
	ACHIEVEMENT_ELECTRICITY,
	ACHIEVEMENT_GRAFFITTY,
	ACHIEVEMENT_HELLYEAH,
	ACHIEVEMENT_KIDWITHGUN,
	ACHIEVEMENT_PSYCHO,
	ACHIEVEMENT_STRIKER,
	ACHIEVEMENT_BOOMHEADSHOT,
	ACHIEVEMENT_THROWTHEBALL,
	ACHIEVEMENT_HPHERO,
	ACHIEVEMENT_AIMBOT,
	ACHIEVEMENT_PHRASE,
	ACHIEVEMENT_GRENADEMAN,
	ACHIEVEMENT_WHAITWHUT,
	ACHIEVEMENT_ADDICT,
	ACHIEVEMENT_MACHOMAN,
	ACHIEVEMENT_DESERTRUSH,
	ACHIEVEMENT_AIRSENSATION,
	ACHIEVEMENT_BORNRICH,
	ACHIEVEMENT_SUICIDER,
	ACHIEVEMENT_WINNER,
	ACHIEVEMENT_WARHERO,
	ACHIEVEMENT_RACIST,
	ACHIEVEMENT_PREMATUREBURIAL,
	ACHIEVEMENT_JUMPER,
	ACHIEVEMENT_NEWBWORLD,
	ACHIEVEMENT_SAFETY,
	ACHIEVEMENT_ARCTIC,
	ACHIEVEMENT_BLOODMONEY,
	ACHIEVEMENT_DING,
	ACHIEVEMENT_RUNNER,
	ACHIEVEMENT_RAINBOWRUNNER,
	ACHIEVEMENT_IMAKERULES,
	ACHIEVEMENT_NOMERCY,
	ACHIEVEMENT_SEXY,
	ACHIEVEMENT_HUNTING,
	ACHIEVEMENT_ABOVE,
	ACHIEVEMENT_NOBELPRIZE,
	ACHIEVEMENT_EVOLUTION,
	ACHIEVEMENT_ASSASSIN,
	ACHIEVEMENT_IMPOSSIBLE,
	ACHIEVEMENT_SLEEPER,
	ACHIEVEMENT_HIPSHOT
};

new const gAchievementNames[ iAchievements ][ ] =
{
	"Domination",			
	"Electricity o.O",		
	"Art Of War",			
	"Hell Yeah!",			
	"Kid With Gun",			
	"Psycho",			
	"Striker",			
	"B00m Headshot",		
	"Throw The B4ll",		
	"1 HP Hero",			
	"Aimbot",			
	"Za Frickin Phrase",		
	"Grenade Man",			
	"Wait Whut?!",			
	"Addict",			
	"Machoman",			
	"Desert Rush",			
	"Air Sensation",		
	"Born Rich!",			
	"Suicider",			
	"Winner",			
	"War Hero",			
	"Racist",			
	"Premature Burial",
	"Jumper",
	"Newb World Order",
	"Safety First",
	"Yall! Freeze & Peace",
	"Blood Money",
	"Ding! Hardcore",
	"Road Runner",
	"Rainbow Runner OMG!",
	"I Make The Rulez",
	"No Mercy",
	"Sexy Time",
	"Polar Expert",
	"Death From Above",
	"Nobel Prize",
	"Evolution Hacker",
	"Silent Assassin",
	"Sherlock Holmes",
	"Sleeper",
	"Hip Shot"
};

new gAchievementValues[ iAchievements ] =
{
	150,
	500,
	4_000,
	350,
	46,
	2_000_000,
	100,
	36,
	1_000,
	1,
	250,
	1,
	26,
	1,
	1_000,
	400,
	56,
	10,
	2_500_000,
	800,
	600,
	1_500,
	100,
	1,
	10_000,
	10,
	1,
	1,
	50_000_000,
	200,
	14_000,
	100_000,
	10,
	150,
	1,
	100,
	20,
	iAchievements,
	1,
	14,
	1,
	50,
	1
};

new const gAchievementColumns[ iAchievements ][ ] =
{
	"Ach1", "Ach2", "Ach3", "Ach4", "Ach5",	"Ach6",
	"Ach7", "Ach8", "Ach9", "Ach10", "Ach11", "Ach12",
	"Ach13", "Ach14", "Ach15", "Ach16", "Ach17", "Ach18",
	"Ach19", "Ach20", "Ach21", "Ach22", "Ach23", "Ach24", 
	"Ach25", "Ach26", "Ach27", "Ach28", "Ach29", "Ach30",
	"Ach31", "Ach32", "Ach33", "Ach34", "Ach35", "Ach36",
	"Ach37", "Ach38", "Ach39", "Ach40", "Ach41", "Ach42", 
	"Ach43"
};

new const gEntityNames[ iEntityNames ][ ] =
{
	"Achievement_SecretFlash",
	"Achievement_SexyZone",
	"Achievement_HackerRoom",
	"Achievement_SecretUmp"
};

new const gTutorResources[ ][ ] =
{
	"gfx/career/icon_!.tga",
	"gfx/career/icon_!-bigger.tga",
	"gfx/career/icon_i.tga",
	"gfx/career/icon_i-bigger.tga",
	"gfx/career/icon_skulls.tga",
	"gfx/career/round_corner_ne.tga",
	"gfx/career/round_corner_nw.tga",
	"gfx/career/round_corner_se.tga",
	"gfx/career/round_corner_sw.tga"
};

new const gWorldEntities[ ][ ] =
{
	"world",
    	"worldspawn",
    	"trigger_hurt",
    	"door_rotating",
    	"door",
    	"rotating",
    	"env_explosion",
	"env_laser",
	"env_beam",
	"rot"
};

new const gButtons[ ][ ] =
{
	"func_button",
	"button_target",
	"func_rot_button"
};

new const gAchievementLogFile[ ] = "AchievementLogs.log";
new const gAchievementSound[ ] = "ambience/goal_1.wav";
new const gAchievementProgressSound[ ] = "events/enemy_died.wav";

new const gSecretPhrase[ ] = "I <3 Deathrun, iar asta este fraza secreta!";

new i;
new gMaxPlayers;
new gMessageTutorText;
new gMessageTutorClose;
new gMessageSayText;
new gSprite1;
new gSprite2;
new gSprite3;
new gSprite4;

new gForwardAchievementEarned;
new gForwardReturn;

new bool:bReached[ MAX_PLAYERS ][ iMaxBoolCells ];

new bPlayerMoney[ MAX_PLAYERS ];
new bZoomLess[ MAX_PLAYERS ];
new bFlashOwner[ MAX_PLAYERS ];
new bPlayerWeaponSilenced[ MAX_PLAYERS ];
new bPlayerAchievementsEarned[ MAX_PLAYERS ];
new bPlayerAchievements[ MAX_PLAYERS ][ iAchievements ];

new const Float:flNullOrigin[ 3 ];
new Float:flOldOrigin[ MAX_PLAYERS ][ 3 ];
new Float:flDistanceWalked[ MAX_PLAYERS ];

new szFormatLog[ 200 ];

const m_iExtraOffPlayer = 5;
const m_iExtraOff = 4;
const m_flFlashedUntil = 514;
const m_flFlashedAt = 515;
const m_flFlashHoldTime = 516;
const m_flFlashDuration = 517;
const m_iFlashAlpha = 518;
const m_fSilent	= 74;
const m_pPlayer = 41;
const m_bLightSmoke = 114;
const m_bIsC4 = 96;
const m_XoGrenade = 5;

new Handle:gSqlTuple;

new Trie:gWeaponsTrie;

public plugin_init( )
{
	register_plugin( "Deathrun Achievements", "1.3.8", "tuty" );
	
	register_event( "Money", "Hook_Money", "b" );
	register_event( "DeathMsg", "Hook_Death", "a" );
	register_event( "SendAudio", "Hook_CT_Win", "a", "2&%!MRAD_ctwin" );
	register_event( "SendAudio", "Hook_Terr_Win", "a", "2&%!MRAD_terwin" );
	register_event( "ScreenFade", "Hook_ScreenFade", "be", "4=255", "5=255", "6=255", "7=200", "7=255" );
	
	RegisterHam( Ham_TakeDamage, "player", "bacon_TakeDamagePlayer" );
	RegisterHam( Ham_TakeDamage, "func_breakable", "bacon_KilledBreakable", 1 );
	RegisterHam( Ham_TraceAttack, "player", "bacon_TraceAttackPlayer", 1 );
	RegisterHam( Ham_Spawn, "player", "bacon_Spawned", 1 );
	RegisterHam( Ham_Item_PostFrame, "weapon_usp", "bacon_Item_PostFrame" );
	RegisterHam( Ham_Think, "grenade", "bacon_ThinkGrenade" );

	for( i = 0; i < sizeof gButtons; i++ )
	{
		RegisterHam( Ham_Use, gButtons[ i ], "bacon_ButtonUsed" );
	}
	
	new szMap[ 30 ];
	get_mapname( szMap, charsmax( szMap ) );
		
	if( equal( szMap, "deathrun_arctic" ) )
	{
		RegisterHam( Ham_Touch, "info_target", "bacon_TouchZone" );
		
		UTIL_Zone( gEntityNames[ ENTITY_NAME_ARCTIC ], Float:{ -240.3, 2113.1, -191.9 }, Float:{ -14.0, -15.0, -14.0 }, Float:{ 14.0, 15.0, 14.0 } );
		UTIL_Zone( gEntityNames[ ENTITY_NAME_ARCTIC_2 ], Float:{ 1504.3, 406.4, -200.9 }, Float:{ -22.0, -27.0, -30.0 }, Float:{ 22.0, 27.0, 30.0 } );
	}
	
	else if( equal( szMap, "deathrun_projetocs3" ) )
	{
		RegisterHam( Ham_Touch, "info_target", "bacon_TouchZone" );
		
		UTIL_Zone( gEntityNames[ ENTITY_NAME_SEXY ], Float:{ 965.0, 1600.4, -435.9 }, Float:{ -154.0, -250.0, -82.0 }, Float:{ 154.0, 250.0, 82.0 } );
	}
	
	else if( equal( szMap, "deathrun_evolution" ) )
	{
		RegisterHam( Ham_Touch, "info_target", "bacon_TouchZone" );
		
		UTIL_Zone( gEntityNames[ ENTITY_NAME_HACKER ], Float:{ 417.8, 457.1, -667.9 }, Float:{ -152.0, -148.0, -72.0 }, Float:{ 152.0, 148.0, 72.0 } );
	}

	gForwardAchievementEarned = CreateMultiForward( "forward_AchievementEarned", ET_STOP, FP_CELL );

	register_forward( FM_EmitSound, "forward_EmitSound_Post", 1 );
	register_forward( FM_CmdStart, "forward_CmdStart" );

	register_clcmd( "say", "CheckCommandSay" );

	register_clcmd( "say /stats", "CommandStats" );
	register_clcmd( "say_team /stats", "CommandStats" );
	
	gMessageTutorText = get_user_msgid( "TutorText" );
	gMessageTutorClose = get_user_msgid( "TutorClose" );
	gMessageSayText = get_user_msgid( "SayText" );
	
	gMaxPlayers = get_maxplayers( );
	server_cmd( "decalfrequency 100.0" );
	
	UTIL_InitTrie( );
}

public plugin_precache( )
{
	for( i = 0; i < sizeof gTutorResources; i++ )
	{
		precache_generic( gTutorResources[ i ] );
	}
	
	gSprite1 = precache_model( "sprites/flare6.spr" );
	gSprite2 = precache_model( "sprites/blueflare2.spr" );	
	gSprite3 = precache_model( "sprites/muz4.spr" );
	gSprite4 = precache_model( "sprites/redflare2.spr" );

	precache_sound( gAchievementSound );
	precache_sound( gAchievementProgressSound );
	
	UTIL_CreateTable( );
}

public client_putinserver( id )
{
	if( is_user_connected( id ) )
	{
		bPlayerAchievements[ id ][ ACHIEVEMENT_ADDICT ]++;
		
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_ADDICT ] == gAchievementValues[ ACHIEVEMENT_ADDICT ] / 2 )
		{
			UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_ADDICT ], bPlayerAchievements[ id ][ ACHIEVEMENT_ADDICT ], gAchievementValues[ ACHIEVEMENT_ADDICT ] );
		
			client_cmd( id, "speak %s", gAchievementProgressSound );
		}
			
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_ADDICT ] == gAchievementValues[ ACHIEVEMENT_ADDICT ] )
		{
			new szName[ 40 ];
			get_user_name( id, szName, charsmax( szName ) );

			UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_ADDICT ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_ADDICT ] );

			emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( id );
			UTIL_ForwardApply( id );

			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_ADDICT ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
	}
}

public client_connect( id )
{
	UTIL_LoadStats( id );
}

public client_disconnect( id )
{
	remove_task( id + TASK_GLOW_GOLD );

	UTIL_SaveStats( id );
}

public CheckCommandSay( id )
{
	new szSaid[ 200 ];

	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	trim( szSaid );

	if( equal( szSaid, gSecretPhrase ) )
	{
		bPlayerAchievements[ id ][ ACHIEVEMENT_PHRASE ]++;
	
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_PHRASE ] == gAchievementValues[ ACHIEVEMENT_PHRASE ] )
		{
			new szName[ 40 ];
			get_user_name( id, szName, charsmax( szName ) );
		
			UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_PHRASE ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_PHRASE ] );

			emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( id );
			UTIL_ForwardApply( id );
			
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_PHRASE ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public CommandStats( id )
{
	new szWebSite[ 50 ];
	get_cvar_string( "amx_sql_host", szWebSite, charsmax( szWebSite ) );
	
	new szName[ 50 ];
	get_user_name( id, szName, charsmax( szName ) );

	new szFormatMotd[ 1000 ];
	formatex( szFormatMotd, charsmax( szFormatMotd ), "http://%s/tuty/cauta.php?name=%s", szWebSite, szName );

	show_motd( id, szFormatMotd, "[ Realizari Deathrun ]" );
}

public bacon_Spawned( id )
{
	if( is_user_alive( id )
	&& !UTIL_GetPlayerCheating( id ) )
	{
		if( bPlayerAchievementsEarned[ id ] >= iAchievements )
		{
			set_task( 1.6, "GlowGoldPlayer", id + TASK_GLOW_GOLD );
		}

		UTIL_SaveStats( id );

		xs_vec_copy( flNullOrigin, flOldOrigin[ id ] );
	}
}

public bacon_Item_PostFrame( iWeapon )
{
	static id;
	id = get_pdata_cbase( iWeapon, m_pPlayer, m_iExtraOff );
	
	bPlayerWeaponSilenced[ id ] = ( get_pdata_int( iWeapon, m_fSilent, m_iExtraOff ) == 1 ? 1 : 0 );
}

public bacon_ThinkGrenade( iEnt )
{
	new Float:flGameTime = get_gametime( );
	new iOwner;

	new Float:flDmgTime;
	pev( iEnt, pev_dmgtime, flDmgTime );

	if( flDmgTime <= flGameTime
	&& get_pdata_int( iEnt, m_bLightSmoke, m_XoGrenade ) == 0
    	&& !( get_pdata_int( iEnt, m_bIsC4, m_XoGrenade ) & ( 1<<8 ) )
	&& IS_PLAYER( ( iOwner = pev( iEnt, pev_owner ) ) ) )
    	{
		bFlashOwner[ iOwner ] = iOwner;
	}
}

public bacon_ButtonUsed( this, idcaller, idactivator, use_type, Float:value )
{
	if( idcaller != idactivator )
	{
		return HAM_IGNORED;
	}
	
	if( pev( this, pev_frame ) > 0.0 )
	{
		 return HAM_IGNORED;
	}
	
	if( cs_get_user_team( idcaller ) != CS_TEAM_T )
	{
		return HAM_IGNORED;
	}
	
	if( UTIL_GetPlayerCheating( idcaller ) )
	{
		return HAM_IGNORED;
	}

	bPlayerAchievements[ idcaller ][ ACHIEVEMENT_ELECTRICITY ]++;
		
	if( bPlayerAchievements[ idcaller ][ ACHIEVEMENT_ELECTRICITY ] == gAchievementValues[ ACHIEVEMENT_ELECTRICITY ] / 2 )
	{
		UTIL_CreateTutorMsg( idcaller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_ELECTRICITY ], bPlayerAchievements[ idcaller ][ ACHIEVEMENT_ELECTRICITY ], gAchievementValues[ ACHIEVEMENT_ELECTRICITY ] );
			
		client_cmd( idcaller, "speak %s", gAchievementProgressSound );
	}
			
	if( bPlayerAchievements[ idcaller ][ ACHIEVEMENT_ELECTRICITY ] == gAchievementValues[ ACHIEVEMENT_ELECTRICITY ] )
	{
		new szName[ 40 ];
		get_user_name( idcaller, szName, charsmax( szName ) );

		UTIL_CreateTutorMsg( idcaller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_ELECTRICITY ] );
		UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_ELECTRICITY ] );

		emit_sound( idcaller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
		UTIL_EarnedAchievement( idcaller );
		UTIL_ForwardApply( idcaller );
		
		formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_ELECTRICITY ] );
		log_to_file( gAchievementLogFile, szFormatLog );
	}
	
	return HAM_IGNORED;
}

public bacon_TouchZone( iEnt, id )
{
	if( pev_valid( iEnt ) 
	&& is_user_alive( id )
	&& !UTIL_GetPlayerCheating( id ) )
	{
		new szClassName[ 40 ];
		pev( iEnt, pev_classname, szClassName, charsmax( szClassName ) );
		
		if( equal( szClassName, gEntityNames[ ENTITY_NAME_ARCTIC ] ) )
		{
			bPlayerAchievements[ id ][ ACHIEVEMENT_ARCTIC ]++;
			
			if( bPlayerAchievements[ id ][ ACHIEVEMENT_ARCTIC ] == gAchievementValues[ ACHIEVEMENT_ARCTIC ]
			&& !bReached[ id ][ SECRET_PLACE ] )
			{
				new szName[ 40 ];
				get_user_name( id, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_ARCTIC ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_ARCTIC ] );

				bReached[ id ][ SECRET_PLACE ] = true;

				emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( id );
				UTIL_ForwardApply( id );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_ARCTIC ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		else if( equal( szClassName, gEntityNames[ ENTITY_NAME_SEXY ] ) )
		{
			bPlayerAchievements[ id ][ ACHIEVEMENT_SEXY ]++;
			
			if( bPlayerAchievements[ id ][ ACHIEVEMENT_SEXY ] == gAchievementValues[ ACHIEVEMENT_SEXY ]
			&& !bReached[ id ][ SEXY_PLACE ] )
			{
				new szName[ 40 ];
				get_user_name( id, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_SEXY ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_SEXY ] );

				bReached[ id ][ SEXY_PLACE ] = true;

				emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( id );
				UTIL_ForwardApply( id );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_SEXY ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		else if( equal( szClassName, gEntityNames[ ENTITY_NAME_HACKER ] ) )
		{
			bPlayerAchievements[ id ][ ACHIEVEMENT_EVOLUTION ]++;
			
			if( bPlayerAchievements[ id ][ ACHIEVEMENT_EVOLUTION ] == gAchievementValues[ ACHIEVEMENT_EVOLUTION ]
			&& !bReached[ id ][ HACKER_PLACE ] )
			{
				new szName[ 40 ];
				get_user_name( id, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_EVOLUTION ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_EVOLUTION ] );

				bReached[ id ][ HACKER_PLACE ] = true;

				emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( id );
				UTIL_ForwardApply( id );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_EVOLUTION ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		else if( equal( szClassName, gEntityNames[ ENTITY_NAME_ARCTIC_2 ] ) )
		{
			bPlayerAchievements[ id ][ ACHIEVEMENT_IMPOSSIBLE ]++;
			
			if( bPlayerAchievements[ id ][ ACHIEVEMENT_IMPOSSIBLE ] == gAchievementValues[ ACHIEVEMENT_IMPOSSIBLE ]
			&& !bReached[ id ][ SECRET_PLACE2 ] )
			{
				new szName[ 40 ];
				get_user_name( id, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_IMPOSSIBLE ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_IMPOSSIBLE ] );

				bReached[ id ][ SECRET_PLACE2 ] = true;

				emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( id );
				UTIL_ForwardApply( id );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_IMPOSSIBLE ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
	}
}

public GlowGoldPlayer( iTaskid )
{
	new id = iTaskid - TASK_GLOW_GOLD;
	
	if( IS_PLAYER( id )
	&& is_user_alive( id ) )
	{
		set_user_rendering( id, kRenderFxGlowShell, 255, 215, 0, kRenderNormal, 40 );
	}
}

public Hook_ScreenFade( id )
{
	if( id == bFlashOwner[ id ]
	&& !UTIL_GetPlayerCheating( id ) )
	{
		bPlayerAchievements[ id ][ ACHIEVEMENT_SLEEPER ]++;
				
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_SLEEPER ] == gAchievementValues[ ACHIEVEMENT_SLEEPER ] / 2 )
		{
			UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_SLEEPER ], bPlayerAchievements[ id ][ ACHIEVEMENT_SLEEPER ], gAchievementValues[ ACHIEVEMENT_SLEEPER ] );
			
			client_cmd( id, "speak %s", gAchievementProgressSound );
		}
					
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_SLEEPER ] == gAchievementValues[ ACHIEVEMENT_SLEEPER ] )
		{
			new szName[ 40 ];
			get_user_name( id, szName, charsmax( szName ) );

			UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_SLEEPER ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_SLEEPER ] );
	
			emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
					
			UTIL_EarnedAchievement( id );
			UTIL_ForwardApply( id );
				
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_SLEEPER ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
	}
}

public Hook_Death( )
{
	new iVictim = read_data( 2 );
	new iKiller = read_data( 1 );
	new iHeadShot = read_data( 3 );
	
	new szWeapon[ 32 ];

	read_data( 4, szWeapon, charsmax( szWeapon ) );
	strtolower( szWeapon );

	if( iVictim == iKiller )
	{
		return;
	}

	if( IS_PLAYER( iKiller ) 
	&& IS_PLAYER( iVictim )
	&& !UTIL_GetPlayerCheating( iKiller ) )
	{
		remove_task( iVictim + TASK_GLOW_GOLD );

		new iFlags = pev( iVictim, pev_flags );
		new iFlags2 = pev( iKiller, pev_flags );

		new szName[ 40 ];
		get_user_name( iKiller, szName, charsmax( szName ) );
		
		bPlayerAchievements[ iKiller ][ ACHIEVEMENT_WARHERO ]++;
		
		if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_WARHERO ] == gAchievementValues[ ACHIEVEMENT_WARHERO ] / 2 )
		{
			UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_WARHERO ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_WARHERO ], gAchievementValues[ ACHIEVEMENT_WARHERO ] );
			
			client_cmd( iKiller, "speak %s", gAchievementProgressSound );
		}
			
		if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_WARHERO ] == gAchievementValues[ ACHIEVEMENT_WARHERO ] )
		{
			UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_WARHERO ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_WARHERO ] );

			emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( iKiller );
			UTIL_ForwardApply( iKiller );
			
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_WARHERO ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
	
		bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HELLYEAH ]++;
		
		if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HELLYEAH ] == gAchievementValues[ ACHIEVEMENT_HELLYEAH ] / 2 )
		{
			UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_HELLYEAH ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HELLYEAH ], gAchievementValues[ ACHIEVEMENT_HELLYEAH ] );
			
			client_cmd( iKiller, "speak %s", gAchievementProgressSound );
		}
			
		if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HELLYEAH ] == gAchievementValues[ ACHIEVEMENT_HELLYEAH ] )
		{
			UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_HELLYEAH ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_HELLYEAH ] );

			emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( iKiller );
			UTIL_ForwardApply( iKiller );
			
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_HELLYEAH ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
		
		bPlayerAchievements[ iKiller ][ ACHIEVEMENT_STRIKER ]++;
		
		if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_STRIKER ] == gAchievementValues[ ACHIEVEMENT_STRIKER ] / 2 )
		{
			UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_STRIKER ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_STRIKER ], gAchievementValues[ ACHIEVEMENT_STRIKER ] );
			
			client_cmd( iKiller, "speak %s", gAchievementProgressSound );
		}
			
		if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_STRIKER ] == gAchievementValues[ ACHIEVEMENT_STRIKER ] )
		{
			UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_STRIKER ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_STRIKER ] );

			emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( iKiller );
			UTIL_ForwardApply( iKiller );
			
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_STRIKER ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
		
		if( iHeadShot )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIMBOT ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIMBOT ] == gAchievementValues[ ACHIEVEMENT_AIMBOT ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_AIMBOT ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIMBOT ], gAchievementValues[ ACHIEVEMENT_AIMBOT ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIMBOT ] == gAchievementValues[ ACHIEVEMENT_AIMBOT ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_AIMBOT ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_AIMBOT ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_AIMBOT ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
			
			if( equal( szWeapon, "knife" ) )
			{
				bPlayerAchievements[ iKiller ][ ACHIEVEMENT_BOOMHEADSHOT ]++;
		
				if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_BOOMHEADSHOT ] == gAchievementValues[ ACHIEVEMENT_BOOMHEADSHOT ] / 2 )
				{
					UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_BOOMHEADSHOT ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_BOOMHEADSHOT ], gAchievementValues[ ACHIEVEMENT_BOOMHEADSHOT ] );
			
					client_cmd( iKiller, "speak %s", gAchievementProgressSound );
				}
			
				if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_BOOMHEADSHOT ] == gAchievementValues[ ACHIEVEMENT_BOOMHEADSHOT ] )
				{
					UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_BOOMHEADSHOT ] );
					UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_BOOMHEADSHOT ] );

					emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
					
					UTIL_EarnedAchievement( iKiller );
					UTIL_ForwardApply( iKiller );

					formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_BOOMHEADSHOT ] );
					log_to_file( gAchievementLogFile, szFormatLog );
				}
			}
		}
		
		new iPercent;
		UTIL_GetClient_Flashed( iKiller, iPercent );

		if( iPercent == 100 )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_WHAITWHUT ]++;
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_WHAITWHUT ] >= gAchievementValues[ ACHIEVEMENT_WHAITWHUT ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_WHAITWHUT ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_WHAITWHUT ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_WHAITWHUT ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		if( bZoomLess[ iKiller ] )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HIPSHOT ]++;
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HIPSHOT ] >= gAchievementValues[ ACHIEVEMENT_HIPSHOT ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_HIPSHOT ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_HIPSHOT ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_HIPSHOT ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}

		if( equal( szWeapon, "tmp" ) )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_KIDWITHGUN ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_KIDWITHGUN ] == gAchievementValues[ ACHIEVEMENT_KIDWITHGUN ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_KIDWITHGUN ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_KIDWITHGUN ], gAchievementValues[ ACHIEVEMENT_KIDWITHGUN ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_KIDWITHGUN ] == gAchievementValues[ ACHIEVEMENT_KIDWITHGUN ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_KIDWITHGUN ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_KIDWITHGUN ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
			
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_KIDWITHGUN ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		if( equal( szWeapon, "grenade" ) )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_GRENADEMAN ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_GRENADEMAN ] == gAchievementValues[ ACHIEVEMENT_GRENADEMAN ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_GRENADEMAN ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_GRENADEMAN ], gAchievementValues[ ACHIEVEMENT_GRENADEMAN ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_GRENADEMAN ] == gAchievementValues[ ACHIEVEMENT_GRENADEMAN ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_GRENADEMAN ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_GRENADEMAN ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_GRENADEMAN ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
			
			if( !is_user_alive( iKiller ) )
			{
				bPlayerAchievements[ iKiller ][ ACHIEVEMENT_PREMATUREBURIAL ]++;
			
				if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_PREMATUREBURIAL ] == gAchievementValues[ ACHIEVEMENT_PREMATUREBURIAL ] )
				{
					UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_PREMATUREBURIAL ] );
					UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_PREMATUREBURIAL ] );

					emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
					
					UTIL_EarnedAchievement( iKiller );
					UTIL_ForwardApply( iKiller );
					
					formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_PREMATUREBURIAL ] );
					log_to_file( gAchievementLogFile, szFormatLog );
				}
			}
		}
		
		if( equal( szWeapon, "deagle" ) )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DESERTRUSH ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DESERTRUSH ] == gAchievementValues[ ACHIEVEMENT_DESERTRUSH ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_DESERTRUSH ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DESERTRUSH ], gAchievementValues[ ACHIEVEMENT_DESERTRUSH ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DESERTRUSH ] == gAchievementValues[ ACHIEVEMENT_DESERTRUSH ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_DESERTRUSH ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_DESERTRUSH ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_DESERTRUSH ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		if( equal( szWeapon, "m249" ) )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DING ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DING ] == gAchievementValues[ ACHIEVEMENT_DING ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_DING ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DING ], gAchievementValues[ ACHIEVEMENT_DING ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DING ] == gAchievementValues[ ACHIEVEMENT_DING ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_DING ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_DING ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_DING ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		if( equal( szWeapon, "awp" ) )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HUNTING ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HUNTING ] == gAchievementValues[ ACHIEVEMENT_HUNTING ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_HUNTING ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HUNTING ], gAchievementValues[ ACHIEVEMENT_HUNTING ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HUNTING ] == gAchievementValues[ ACHIEVEMENT_HUNTING ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_HUNTING ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_HUNTING ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_HUNTING ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}

		if( get_user_health( iKiller ) == 1 )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HPHERO ]++;
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_HPHERO ] == gAchievementValues[ ACHIEVEMENT_HPHERO ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_HPHERO ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_HPHERO ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_HPHERO ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		if( !( iFlags2 & FL_ONGROUND )
		&& !( iFlags2 & FL_INWATER )
		&& ( iFlags & FL_ONGROUND ) 
		&& !( iFlags & FL_INWATER )
		&& UTIL_DistanceToFloor( iKiller ) >= HUNDERD_UNITS_INAIR )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ABOVE ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ABOVE ] == gAchievementValues[ ACHIEVEMENT_ABOVE ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_ABOVE ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ABOVE ], gAchievementValues[ ACHIEVEMENT_ABOVE ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ABOVE ] == gAchievementValues[ ACHIEVEMENT_ABOVE ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_ABOVE ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_ABOVE ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_ABOVE ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}

		if( !( iFlags & FL_ONGROUND )
		&& !( iFlags & FL_INWATER )
		&& UTIL_DistanceToFloor( iVictim ) >= HUNDERD_UNITS_INAIR )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIRSENSATION ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIRSENSATION ] == gAchievementValues[ ACHIEVEMENT_AIRSENSATION ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_AIRSENSATION ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIRSENSATION ], gAchievementValues[ ACHIEVEMENT_AIRSENSATION ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_AIRSENSATION ] == gAchievementValues[ ACHIEVEMENT_AIRSENSATION ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_AIRSENSATION ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_AIRSENSATION ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_AIRSENSATION ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
		
		if( cs_get_user_team( iKiller ) == CS_TEAM_CT
		&& is_user_alive( iKiller ) )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_RACIST ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_RACIST ] == gAchievementValues[ ACHIEVEMENT_RACIST ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_RACIST ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_RACIST ], gAchievementValues[ ACHIEVEMENT_RACIST ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_RACIST ] == gAchievementValues[ ACHIEVEMENT_RACIST ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_RACIST ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_RACIST ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_RACIST ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
			
			if( equal( szWeapon, "usp" ) )
			{
				if( bPlayerWeaponSilenced[ iKiller ] == 1 )
				{
					bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ASSASSIN ]++;
		
					if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ASSASSIN ] == gAchievementValues[ ACHIEVEMENT_ASSASSIN ] / 2 )
					{
						UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_ASSASSIN ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ASSASSIN ], gAchievementValues[ ACHIEVEMENT_ASSASSIN ] );
			
						client_cmd( iKiller, "speak %s", gAchievementProgressSound );
					}
			
					if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_ASSASSIN ] == gAchievementValues[ ACHIEVEMENT_ASSASSIN ] )
					{
						UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_ASSASSIN ] );
						UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_ASSASSIN ] );

						emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
						UTIL_EarnedAchievement( iKiller );
						UTIL_ForwardApply( iKiller );
			
						formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_ASSASSIN ] );
						log_to_file( gAchievementLogFile, szFormatLog );
					}
				}
			}
		}
		
		if( cs_get_user_team( iKiller ) == CS_TEAM_T
		&& is_user_alive( iKiller ) )
		{
			bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DOMINATION ]++;
		
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DOMINATION ] == gAchievementValues[ ACHIEVEMENT_DOMINATION ] / 2 )
			{
				UTIL_CreateTutorMsg( iKiller, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_DOMINATION ], bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DOMINATION ], gAchievementValues[ ACHIEVEMENT_DOMINATION ] );
			
				client_cmd( iKiller, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iKiller ][ ACHIEVEMENT_DOMINATION ] == gAchievementValues[ ACHIEVEMENT_DOMINATION ] )
			{
				UTIL_CreateTutorMsg( iKiller, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_DOMINATION ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_DOMINATION ] );

				emit_sound( iKiller, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iKiller );
				UTIL_ForwardApply( iKiller );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_DOMINATION ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
	}
	
	else if( IS_PLAYER( iVictim ) )
	{
		if( TrieKeyExists( gWeaponsTrie, szWeapon ) )
		{
			bPlayerAchievements[ iVictim ][ ACHIEVEMENT_SUICIDER ]++;
		
			if( bPlayerAchievements[ iVictim ][ ACHIEVEMENT_SUICIDER ] == gAchievementValues[ ACHIEVEMENT_SUICIDER ] / 2 )
			{
				UTIL_CreateTutorMsg( iVictim, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_SUICIDER ], bPlayerAchievements[ iVictim ][ ACHIEVEMENT_SUICIDER ], gAchievementValues[ ACHIEVEMENT_SUICIDER ] );
			
				client_cmd( iVictim, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ iVictim ][ ACHIEVEMENT_SUICIDER ] == gAchievementValues[ ACHIEVEMENT_SUICIDER ] )
			{
				new szName[ 40 ];
				get_user_name( iVictim, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( iVictim, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_SUICIDER ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_SUICIDER ] );

				emit_sound( iVictim, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( iVictim );
				UTIL_ForwardApply( iVictim );
					
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_SUICIDER ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
	}
}	
	
public Hook_Terr_Win( )
{
	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_connected( i )
		&& is_user_alive( i )
		&& !is_user_bot( i )
		&& cs_get_user_team( i ) == CS_TEAM_T )
		{
			bPlayerAchievements[ i ][ ACHIEVEMENT_NOMERCY ]++;
		
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_NOMERCY ] == gAchievementValues[ ACHIEVEMENT_NOMERCY ] / 2 )
			{
				UTIL_CreateTutorMsg( i, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_NOMERCY ], bPlayerAchievements[ i ][ ACHIEVEMENT_NOMERCY ], gAchievementValues[ ACHIEVEMENT_NOMERCY ] );
			
				client_cmd( i, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_NOMERCY ] == gAchievementValues[ ACHIEVEMENT_NOMERCY ] )
			{
				new szName[ 40 ];
				get_user_name( i, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( i, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_NOMERCY ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_NOMERCY ] );

				emit_sound( i, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( i );
				UTIL_ForwardApply( i );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_NOMERCY ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}

			bPlayerAchievements[ i ][ ACHIEVEMENT_IMAKERULES ]++;
		
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_IMAKERULES ] == gAchievementValues[ ACHIEVEMENT_IMAKERULES ] / 2 )
			{
				UTIL_CreateTutorMsg( i, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_IMAKERULES ], bPlayerAchievements[ i ][ ACHIEVEMENT_IMAKERULES ], gAchievementValues[ ACHIEVEMENT_IMAKERULES ] );
			
				client_cmd( i, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_IMAKERULES ] == gAchievementValues[ ACHIEVEMENT_IMAKERULES ] )
			{
				new szName[ 40 ];
				get_user_name( i, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( i, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_IMAKERULES ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_IMAKERULES ] );

				emit_sound( i, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( i );
				UTIL_ForwardApply( i );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_IMAKERULES ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
	}
}

public Hook_CT_Win( )
{
	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_connected( i )
		&& is_user_alive( i )
		&& !is_user_bot( i )
		&& cs_get_user_team( i ) == CS_TEAM_CT )
		{
			bPlayerAchievements[ i ][ ACHIEVEMENT_WINNER ]++;
		
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_WINNER ] == gAchievementValues[ ACHIEVEMENT_WINNER ] / 2 )
			{
				UTIL_CreateTutorMsg( i, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_WINNER ], bPlayerAchievements[ i ][ ACHIEVEMENT_WINNER ], gAchievementValues[ ACHIEVEMENT_WINNER ] );
			
				client_cmd( i, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_WINNER ] == gAchievementValues[ ACHIEVEMENT_WINNER ] )
			{
				new szName[ 40 ];
				get_user_name( i, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( i, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_WINNER ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_WINNER ] );

				emit_sound( i, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( i );
				UTIL_ForwardApply( i );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_WINNER ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
			
			bPlayerAchievements[ i ][ ACHIEVEMENT_NEWBWORLD ]++;
			
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_NEWBWORLD ] == gAchievementValues[ ACHIEVEMENT_NEWBWORLD ] / 2 )
			{
				UTIL_CreateTutorMsg( i, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_NEWBWORLD ], bPlayerAchievements[ i ][ ACHIEVEMENT_NEWBWORLD ], gAchievementValues[ ACHIEVEMENT_NEWBWORLD ] );
			
				client_cmd( i, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ i ][ ACHIEVEMENT_NEWBWORLD ] == gAchievementValues[ ACHIEVEMENT_NEWBWORLD ] )
			{
				new szName[ 40 ];
				get_user_name( i, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( i, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_NEWBWORLD ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_NEWBWORLD ] );

				emit_sound( i, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( i );
				UTIL_ForwardApply( i );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_NEWBWORLD ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
	}
}

public grenade_throw( id, greindex, wId )
{
	if( !UTIL_GetPlayerCheating( id ) )
	{
		bPlayerAchievements[ id ][ ACHIEVEMENT_THROWTHEBALL ]++;
		
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_THROWTHEBALL ] == gAchievementValues[ ACHIEVEMENT_THROWTHEBALL ] / 2 )
		{
			UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_THROWTHEBALL ], bPlayerAchievements[ id ][ ACHIEVEMENT_THROWTHEBALL ], gAchievementValues[ ACHIEVEMENT_THROWTHEBALL ] );
			
			client_cmd( id, "speak %s", gAchievementProgressSound );
		}
			
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_THROWTHEBALL ] == gAchievementValues[ ACHIEVEMENT_THROWTHEBALL ] )
		{
			new szName[ 40 ];
			get_user_name( id, szName, charsmax( szName ) );

			UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_THROWTHEBALL ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_THROWTHEBALL ] );

			emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( id );
			UTIL_ForwardApply( id );
		
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_THROWTHEBALL ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
	}
}
	
public forward_AchievementEarned( const id )
{
	if( ++bPlayerAchievementsEarned[ id ] >= iAchievements )
	{
		bPlayerAchievementsEarned[ id ] = iAchievements;
	}

	bPlayerAchievements[ id ][ ACHIEVEMENT_NOBELPRIZE ]++;
	
	if( bPlayerAchievements[ id ][ ACHIEVEMENT_NOBELPRIZE ] == gAchievementValues[ ACHIEVEMENT_NOBELPRIZE ] / 2 )
	{
		UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_NOBELPRIZE ], bPlayerAchievements[ id ][ ACHIEVEMENT_NOBELPRIZE ], gAchievementValues[ ACHIEVEMENT_NOBELPRIZE ] );
			
		client_cmd( id, "speak %s", gAchievementProgressSound );
	}
			
	if( bPlayerAchievements[ id ][ ACHIEVEMENT_NOBELPRIZE ] == gAchievementValues[ ACHIEVEMENT_NOBELPRIZE ] )
	{
		new szName[ 40 ];
		get_user_name( id, szName, charsmax( szName ) );

		UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_NOBELPRIZE ] );
		UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_NOBELPRIZE ] );

		emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );		
		
		UTIL_EarnedAchievement( id );
		UTIL_ForwardApply( id );
				
		formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_NOBELPRIZE ] );
		log_to_file( gAchievementLogFile, szFormatLog );
	}
}

public forward_EmitSound_Post( iEnt, channel, const szSample[ ] )
{
	if( pev_valid( iEnt ) 
	&& equal( szSample, "player/sprayer.wav" ) )
	{
		new id = pev( iEnt, pev_owner );

		if( IS_PLAYER( id ) 
		&& is_user_alive( id )
		&& !UTIL_GetPlayerCheating( id ) )
		{
			bPlayerAchievements[ id ][ ACHIEVEMENT_GRAFFITTY ]++;
		
			if( bPlayerAchievements[ id ][ ACHIEVEMENT_GRAFFITTY ] == gAchievementValues[ ACHIEVEMENT_GRAFFITTY ] / 2 )
			{
				UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_GRAFFITTY ], bPlayerAchievements[ id ][ ACHIEVEMENT_GRAFFITTY ], gAchievementValues[ ACHIEVEMENT_GRAFFITTY ] );
			
				client_cmd( id, "speak %s", gAchievementProgressSound );
			}
			
			if( bPlayerAchievements[ id ][ ACHIEVEMENT_GRAFFITTY ] == gAchievementValues[ ACHIEVEMENT_GRAFFITTY ] )
			{
				new szName[ 40 ];
				get_user_name( id, szName, charsmax( szName ) );

				UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_GRAFFITTY ] );
				UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_GRAFFITTY ] );

				emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				UTIL_EarnedAchievement( id );
				UTIL_ForwardApply( id );
				
				formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_GRAFFITTY ] );
				log_to_file( gAchievementLogFile, szFormatLog );
			}
		}
	}
	
	return FMRES_IGNORED;
}

public forward_CmdStart( id, uc_handle, random_seed )
{
	if( !is_user_alive( id )
	|| UTIL_GetPlayerCheating( id ) )
	{
		return HAM_IGNORED;
	}

	new Float:flOrigin[ 3 ];
     	pev( id, pev_origin, flOrigin );
        
        if( !xs_vec_equal( flOldOrigin[ id ], flNullOrigin ) )
        {
		flDistanceWalked[ id ] += get_distance_f( flOrigin, flOldOrigin[ id ] );
        }
        
        xs_vec_copy( flOrigin, flOldOrigin[ id ] );

	if( UNITS_TO_KM( floatround( flDistanceWalked[ id ] ) ) >= 1 ) 
	{
		bPlayerAchievements[ id ][ ACHIEVEMENT_RUNNER ]++;
		bPlayerAchievements[ id ][ ACHIEVEMENT_RAINBOWRUNNER ]++;
			
		flDistanceWalked[ id ] = 0.0;
	}

	if( bPlayerAchievements[ id ][ ACHIEVEMENT_RUNNER ] >= gAchievementValues[ ACHIEVEMENT_RUNNER ] / 2
	&& !bReached[ id ][ WALK_1 ] )
	{
		UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_RUNNER ], bPlayerAchievements[ id ][ ACHIEVEMENT_RUNNER ], gAchievementValues[ ACHIEVEMENT_RUNNER ] );
			
		client_cmd( id, "speak %s", gAchievementProgressSound );
				
		bReached[ id ][ WALK_1 ] = true;
	}
		
	if( bPlayerAchievements[ id ][ ACHIEVEMENT_RUNNER ] >= gAchievementValues[ ACHIEVEMENT_RUNNER ]
	&& !bReached[ id ][ WALK_2 ] )
	{
		new szName[ 40 ];
		get_user_name( id, szName, charsmax( szName ) );

		UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_RUNNER ] );
		UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_RUNNER ] );

		bReached[ id ][ WALK_2 ] = true;

		emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
		UTIL_EarnedAchievement( id );
		UTIL_ForwardApply( id );
			
		formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_RUNNER ] );
		log_to_file( gAchievementLogFile, szFormatLog );
	}
		
	if( bPlayerAchievements[ id ][ ACHIEVEMENT_RAINBOWRUNNER ] >= gAchievementValues[ ACHIEVEMENT_RAINBOWRUNNER ] / 2
	&& !bReached[ id ][ WALK_3 ] )
	{
		UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_RAINBOWRUNNER ], bPlayerAchievements[ id ][ ACHIEVEMENT_RAINBOWRUNNER ], gAchievementValues[ ACHIEVEMENT_RAINBOWRUNNER ] );
			
		client_cmd( id, "speak %s", gAchievementProgressSound );
			
		bReached[ id ][ WALK_3 ] = true;
	}
		
	if( bPlayerAchievements[ id ][ ACHIEVEMENT_RAINBOWRUNNER ] >= gAchievementValues[ ACHIEVEMENT_RAINBOWRUNNER ]
	&& !bReached[ id ][ WALK_4 ] )
	{
		new szName[ 40 ];
		get_user_name( id, szName, charsmax( szName ) );

		UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_RAINBOWRUNNER ] );
		UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_RAINBOWRUNNER ] );

		bReached[ id ][ WALK_4 ] = true;

		emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
		UTIL_EarnedAchievement( id );
		UTIL_ForwardApply( id );
			
		formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_RAINBOWRUNNER ] );
		log_to_file( gAchievementLogFile, szFormatLog );
	}

	new iButton = get_uc( uc_handle, UC_Buttons );
	new iOldButton = pev( id, pev_oldbuttons );

	new iFlags = pev( id, pev_flags );

	if( iButton & IN_JUMP 
	&& !( iOldButton & IN_JUMP ) 
	&& ( iFlags & FL_ONGROUND ) 
	&& !( iFlags & FL_WATERJUMP )
	&& !( iFlags & FL_INWATER ) )
	{
		bPlayerAchievements[ id ][ ACHIEVEMENT_JUMPER ]++;
		
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_JUMPER ] == gAchievementValues[ ACHIEVEMENT_JUMPER ] / 2 )
		{
			UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_JUMPER ], bPlayerAchievements[ id ][ ACHIEVEMENT_JUMPER ], gAchievementValues[ ACHIEVEMENT_JUMPER ] );
			
			client_cmd( id, "speak %s", gAchievementProgressSound );
		}
			
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_JUMPER ] == gAchievementValues[ ACHIEVEMENT_JUMPER ] )
		{
			new szName[ 40 ];
			get_user_name( id, szName, charsmax( szName ) );

			UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_JUMPER ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_JUMPER ] );

			emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( id );
			UTIL_ForwardApply( id );
				
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_JUMPER ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
	}
	
	static iWeapon, iZoom;

	iWeapon = get_user_weapon( id );
	iZoom = cs_get_user_zoom( id );

	bZoomLess[ id ] = ( iButton & IN_ATTACK && ( iWeapon == CSW_AWP || iWeapon == CSW_SCOUT ) && iZoom == CS_SET_NO_ZOOM );

	return HAM_IGNORED;
}

public Hook_Money( id )
{
	if( UTIL_GetPlayerCheating( id ) )
	{
		return;
	}

	new iMoney = read_data( 1 );
	new iMoneyDiff = bPlayerMoney[ id ] - iMoney;
    		
	bPlayerMoney[ id ] = iMoney;

    	if( iMoneyDiff > 0 )
    	{
		bPlayerAchievements[ id ][ ACHIEVEMENT_BLOODMONEY ] += iMoneyDiff;

		if( bPlayerAchievements[ id ][ ACHIEVEMENT_BLOODMONEY ] >= gAchievementValues[ ACHIEVEMENT_BLOODMONEY ] / 2
		&& !bReached[ id ][ MONEY_1 ] )
		{
			UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_BLOODMONEY ], bPlayerAchievements[ id ][ ACHIEVEMENT_BLOODMONEY ], gAchievementValues[ ACHIEVEMENT_BLOODMONEY ] );
			
			client_cmd( id, "speak %s", gAchievementProgressSound );
			
			bReached[ id ][ MONEY_1 ] = true;
		}
		
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_BLOODMONEY ] >= gAchievementValues[ ACHIEVEMENT_BLOODMONEY ]
		&& !bReached[ id ][ MONEY_2 ] )	
		{
			new szName[ 40 ];
			get_user_name( id, szName, charsmax( szName ) );

			UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_BLOODMONEY ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_BLOODMONEY ] );

			emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( id );
			UTIL_ForwardApply( id );
			
			bReached[ id ][ MONEY_2 ] = true;
			
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_BLOODMONEY ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}

		bPlayerAchievements[ id ][ ACHIEVEMENT_BORNRICH ] += iMoneyDiff;
		
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_BORNRICH ] >= gAchievementValues[ ACHIEVEMENT_BORNRICH ] / 2
		&& !bReached[ id ][ MONEY_3 ] )
		{
			UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_BORNRICH ], bPlayerAchievements[ id ][ ACHIEVEMENT_BORNRICH ], gAchievementValues[ ACHIEVEMENT_BORNRICH ] );
			
			client_cmd( id, "speak %s", gAchievementProgressSound );
			
			bReached[ id ][ MONEY_3 ] = true;
		}
		
		if( bPlayerAchievements[ id ][ ACHIEVEMENT_BORNRICH ] >= gAchievementValues[ ACHIEVEMENT_BORNRICH ]
		&& !bReached[ id ][ MONEY_4 ] )	
		{
			new szName[ 40 ];
			get_user_name( id, szName, charsmax( szName ) );

			UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_BORNRICH ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_BORNRICH ] );

			emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( id );
			UTIL_ForwardApply( id );
			
			bReached[ id ][ MONEY_4 ] = true;
			
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_BORNRICH ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
	}
}

public bacon_TakeDamagePlayer( victim, inflictor, attacker, Float:damage, damagebits )
{
	if( IS_PLAYER( attacker ) 
	&& IS_PLAYER( victim ) 
	&& victim != attacker
	&& cs_get_user_team( attacker ) != cs_get_user_team( victim )
	&& !UTIL_GetPlayerCheating( attacker ) )
	{
		bPlayerAchievements[ attacker ][ ACHIEVEMENT_PSYCHO ] += DAMAGE_TO_POINT( floatround( damage ) );
		
		if( bPlayerAchievements[ attacker ][ ACHIEVEMENT_PSYCHO ] >= gAchievementValues[ ACHIEVEMENT_PSYCHO ] / 2
		&& !bReached[ attacker ][ DAMAGE_1 ] )
		{
			UTIL_CreateTutorMsg( attacker, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_PSYCHO ], bPlayerAchievements[ attacker ][ ACHIEVEMENT_PSYCHO ], gAchievementValues[ ACHIEVEMENT_PSYCHO ] );
			
			client_cmd( attacker, "speak %s", gAchievementProgressSound );
		
			bReached[ attacker ][ DAMAGE_1 ] = true;
		}
			
		if( bPlayerAchievements[ attacker ][ ACHIEVEMENT_PSYCHO ] >= gAchievementValues[ ACHIEVEMENT_PSYCHO ]
		&& !bReached[ attacker ][ DAMAGE_2 ] )
		{
			new szName[ 40 ];
			get_user_name( attacker, szName, charsmax( szName ) );

			UTIL_CreateTutorMsg( attacker, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_PSYCHO ] );
			UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_PSYCHO ] );

			emit_sound( attacker, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			UTIL_EarnedAchievement( attacker );
			UTIL_ForwardApply( attacker );
			
			bReached[ attacker ][ DAMAGE_2 ] = true;
			
			formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_PSYCHO ] );
			log_to_file( gAchievementLogFile, szFormatLog );
		}
	}
}

public bacon_KilledBreakable( this, idinflictor, id, Float:damage, damagebits )
{
	if( pev( this, pev_health ) <= 0 )
	{
		if( IS_PLAYER( id ) )
		{
			if( !UTIL_GetPlayerCheating( id ) )
			{
				bPlayerAchievements[ id ][ ACHIEVEMENT_MACHOMAN ]++;
				
				if( bPlayerAchievements[ id ][ ACHIEVEMENT_MACHOMAN ] == gAchievementValues[ ACHIEVEMENT_MACHOMAN ] / 2 )
				{
					UTIL_CreateTutorMsg( id, RED, TUTOR_RED_TIME, "%s^nProgres: %d/%d", gAchievementNames[ ACHIEVEMENT_MACHOMAN ], bPlayerAchievements[ id ][ ACHIEVEMENT_MACHOMAN ], gAchievementValues[ ACHIEVEMENT_MACHOMAN ] );
			
					client_cmd( id, "speak %s", gAchievementProgressSound );
				}
					
				if( bPlayerAchievements[ id ][ ACHIEVEMENT_MACHOMAN ] == gAchievementValues[ ACHIEVEMENT_MACHOMAN ] )
				{
					new szName[ 40 ];
					get_user_name( id, szName, charsmax( szName ) );

					UTIL_CreateTutorMsg( id, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_MACHOMAN ] );
					UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_MACHOMAN ] );
	
					emit_sound( id, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
					
					UTIL_EarnedAchievement( id );
					UTIL_ForwardApply( id );
				
					formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_MACHOMAN ] );
					log_to_file( gAchievementLogFile, szFormatLog );
				}
			}
		}
	}
}

public bacon_TraceAttackPlayer( iVictim, iAttacker, Float:flDamage, Float:flDirection[3], ptr, iDamagebits )
{
	if( IS_PLAYER( iVictim ) 
	&& IS_PLAYER( iAttacker ) )
	{
		new CsArmorType:ArmorType;
		new iArmor = cs_get_user_armor( iVictim, ArmorType );
	
		if( iArmor && ArmorType == CS_ARMOR_VESTHELM )
		{
			if( cs_get_user_team( iVictim ) != cs_get_user_team( iAttacker )
			&& get_tr2( ptr, TR_iHitgroup ) == HITGROUP_HEAD
			&& is_user_alive( iVictim )
			&& !UTIL_GetPlayerCheating( iVictim ) )
			{
				bPlayerAchievements[ iVictim ][ ACHIEVEMENT_SAFETY ]++;
				
				if( bPlayerAchievements[ iVictim ][ ACHIEVEMENT_SAFETY ] == gAchievementValues[ ACHIEVEMENT_SAFETY ] )
				{
					new szName[ 40 ];
					get_user_name( iVictim, szName, charsmax( szName ) );

					UTIL_CreateTutorMsg( iVictim, GREEN, TUTOR_GREEN_TIME, "Realizare Deblocata^n%s", gAchievementNames[ ACHIEVEMENT_SAFETY ] );
					UTIL_ColorChat( 0, "^3%s^1 a deblocat realizarea:^4 %s", szName, gAchievementNames[ ACHIEVEMENT_SAFETY ] );

					emit_sound( iVictim, CHAN_STATIC, gAchievementSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
					
					UTIL_EarnedAchievement( iVictim );
					UTIL_ForwardApply( iVictim );
					
					formatex( szFormatLog, charsmax( szFormatLog ), "^"%s^" a deblocat realizarea: ^"%s^"", szName, gAchievementNames[ ACHIEVEMENT_SAFETY ] );
					log_to_file( gAchievementLogFile, szFormatLog );
				}
			}
		}
	}
}

public plugin_end( )
{
	TrieDestroy( gWeaponsTrie );

	if( gSqlTuple != Empty_Handle )
	{
		SQL_FreeHandle( gSqlTuple );
	}
}

public UTIL_LoadStats( id )
{
	new szName[ 50 ];
	get_user_name( id, szName, charsmax( szName ) );

	new szQuery[ 228 ];
	formatex( szQuery, charsmax( szQuery ), "SELECT * FROM `PlayerAchievements` WHERE `name` = ^"%s^"", szName );
	
	new iData[ 1 ];
	iData[ 0 ] = id;
	
	SQL_ThreadQuery( gSqlTuple, "QueryLoadData", szQuery, iData, sizeof( iData ) );
}

public QueryLoadData( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime )
{
	if( iFailState == TQUERY_CONNECT_FAILED
	|| iFailState == TQUERY_QUERY_FAILED )
	{
		formatex( szFormatLog, charsmax( szFormatLog ), "%s", szError );
		log_to_file( gAchievementLogFile, szFormatLog );
	}

	new id = iData[ 0 ];

	if( !SQL_NumResults( hQuery ) )
	{
		new szName[ 50 ];
		get_user_name( id, szName, charsmax( szName ) );

		const iSize = 4000;
		new szFormatTable[ iSize + 1 ], iLen = 0;

		iLen += copy( szFormatTable[ iLen ], iSize - iLen, "INSERT INTO `PlayerAchievements` ( `name`," );
		
		for( i = 0; i < iAchievements; i++ )
		{
			iLen += formatex( szFormatTable[ iLen ], iSize - iLen, "%s`%s`", ( i > 0 ? "," : "" ), gAchievementColumns[ i ] );
		}
		
		iLen += formatex( szFormatTable[ iLen ], iSize - iLen, ",`AchievementsEarned` ) VALUES ( ^"%s^",", szName );
		
		for( i = 0; i < iAchievements; i++ )
		{
			iLen += formatex( szFormatTable[ iLen ], iSize - iLen, "%s'%d'", ( i > 0 ? "," : "" ), bPlayerAchievements[ id ][ i ] );
		}
		
		iLen += formatex( szFormatTable[ iLen ], iSize - iLen, ",'%d' ", bPlayerAchievementsEarned[ id ] );
		iLen += copy( szFormatTable[ iLen ], iSize - iLen, ");" );
		
		SQL_ThreadQuery( gSqlTuple, "QuerySaveData", szFormatTable );
		
		formatex( szFormatLog, charsmax( szFormatLog ), "Nu a fost gasit jucatorul ^"%s^" in baza de date! Creez unul nou acum!", szName );
		log_to_file( gAchievementLogFile, szFormatLog );
	}
	
	else
	{
		for( i = 0; i < iAchievements; i++ )
		{
			bPlayerAchievements[ id ][ i ] = clamp( SQL_ReadResult( hQuery, SQL_FieldNameToNum( hQuery, gAchievementColumns[ i ] ) ), 0, gAchievementValues[ i ] );
		}
		
		bPlayerAchievementsEarned[ id ] = clamp( SQL_ReadResult( hQuery, SQL_FieldNameToNum( hQuery, "AchievementsEarned" ) ), 0, iAchievements );
	}
}

public UTIL_SaveStats( id )
{
	new szName[ 50 ];
	get_user_name( id, szName, charsmax( szName ) );

	const iSize = 4000;
	new szFormatTable[ iSize + 1 ], iLen = 0;

	iLen += copy( szFormatTable[ iLen ], iSize - iLen, "UPDATE `PlayerAchievements` SET" );
		
	for( i = 0; i < iAchievements; i++ )
	{
		iLen += formatex( szFormatTable[ iLen ], iSize - iLen, "%s`%s` = '%d'", ( i > 0 ? "," : "" ), gAchievementColumns[ i ], clamp( bPlayerAchievements[ id ][ i ], 0, gAchievementValues[ i ] ) );
	}
	
	iLen += formatex( szFormatTable[ iLen ], iSize - iLen, ",`AchievementsEarned` = '%d'", clamp( bPlayerAchievementsEarned[ id ], 0, iAchievements ) );
	iLen += formatex( szFormatTable[ iLen ], iSize - iLen, " WHERE `name` = ^"%s^"", szName );
	
	SQL_ThreadQuery( gSqlTuple, "QuerySaveData", szFormatTable );
}

public QuerySaveData( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime )
{
	if( iFailState == TQUERY_CONNECT_FAILED
	|| iFailState == TQUERY_QUERY_FAILED )
	{
		formatex( szFormatLog, charsmax( szFormatLog ), "%s", szError );
		log_to_file( gAchievementLogFile, szFormatLog );
	}
}

UTIL_ForwardApply( index )
{
	ExecuteForward( gForwardAchievementEarned, gForwardReturn, index );
	
	if( gForwardReturn != PLUGIN_CONTINUE )
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

stock UTIL_InitTrie( )
{
	gWeaponsTrie = TrieCreate( );
	
	for( i = 0; i < sizeof gWorldEntities; i++ )
	{
		TrieSetCell( gWeaponsTrie, gWorldEntities[ i ], i );
	}
}

stock UTIL_CreateTable( )
{
	gSqlTuple = SQL_MakeStdTuple( );

	const iSize = 4000;
	new szFormatTable[ iSize + 1 ], iLen = 0;
	
	iLen += formatex( szFormatTable[ iLen ], iSize - iLen, "CREATE TABLE IF NOT EXISTS `PlayerAchievements` ( `name` VARCHAR(50) NOT NULL," );
	
	for( i = 0; i < iAchievements; i++ )
	{
		iLen += formatex( szFormatTable[ iLen ], iSize - iLen, "%s`%s` INT(25) NOT NULL", ( i > 0 ? "," : "" ), gAchievementColumns[ i ] );
	}
	
	iLen += copy( szFormatTable[ iLen ], iSize - iLen, ",`AchievementsEarned` INT(10) NOT NULL " );
	iLen += formatex( szFormatTable[ iLen ], iSize - iLen, ");" );

	SQL_ThreadQuery( gSqlTuple, "QueryCreateTable", szFormatTable );
}

public QueryCreateTable( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime )
{
	if( iFailState == TQUERY_CONNECT_FAILED
	|| iFailState == TQUERY_QUERY_FAILED )
	{
		formatex( szFormatLog, charsmax( szFormatLog ), "%s", szError );
		log_to_file( gAchievementLogFile, szFormatLog );
	}
}

stock UTIL_GetPercent( iCurValue, iMaxValue )
{
	return ( ( iCurValue * 100 ) / iMaxValue );
}

stock UTIL_CreateTutorMsg( id, iColor, Float:flDuration, const szText[ ], any:... )
{
	if( !id 
	|| !is_user_connected( id ) 
	|| equal( szText, "" ) )
	{
		return 0;
	}
	
	new szBuffer[ 200 ];
	vformat( szBuffer, charsmax( szBuffer ), szText, 5 );

	message_begin( MSG_ONE_UNRELIABLE, gMessageTutorText, _, id );
	write_string( szBuffer );
	write_byte( 0 );
	write_short( 0 );
	write_short( 0 );
	write_short( 1<<iColor );
	message_end( );
	
	if( flDuration != 0.0 )
	{
		remove_task( id + TASK_TUTOR );
		set_task( flDuration, "RemoveTutorPopup", id + TASK_TUTOR );
	}
	
	return 1;
}

public RemoveTutorPopup( taskid )
{
	new id = taskid - TASK_TUTOR;
	
	message_begin( MSG_ONE_UNRELIABLE, gMessageTutorClose, _, id );
	message_end( );
}

stock UTIL_GetClient_Flashed( id, &iPercent=0 )
{
	new Float:flFlashedAt = get_pdata_float( id, m_flFlashedAt, m_iExtraOffPlayer );
	
	if( !flFlashedAt )
	{
		return 0;
	}
	
	new Float:flGameTime = get_gametime( );
	new Float:flTimeLeft = flGameTime - flFlashedAt;

	new Float:flFlashDuration = get_pdata_float( id, m_flFlashDuration, m_iExtraOffPlayer );
	new Float:flFlashHoldTime = get_pdata_float( id, m_flFlashHoldTime, m_iExtraOffPlayer );

	new Float:flTotalTime = flFlashHoldTime + flFlashDuration;
	
	if( flTimeLeft > flTotalTime )
	{
		return 0;
	}
	
	new iFlashAlpha = get_pdata_int( id, m_iFlashAlpha, m_iExtraOffPlayer );
	
	if( iFlashAlpha == ALPHA_FULLBLINDED )
	{
		if( get_pdata_float( id, m_flFlashedUntil, m_iExtraOffPlayer ) - flGameTime > 0.0 )
		{
			iPercent = 100;
		}

		else
		{
			iPercent = 100 - floatround( ( ( flGameTime - ( flFlashedAt + flFlashHoldTime ) ) * 100.0 ) / flFlashDuration );
		}
	}

	else
	{
		iPercent = 100 - floatround( ( ( flGameTime - flFlashedAt ) * 100.0 ) / flTotalTime );
	}
	
	return iFlashAlpha;
}

stock UTIL_EarnedAchievement( index )
{
	//new szTime[ 60 ];
	//get_time( "%b %d, %Y %H:%M(%p)", szTime, charsmax( szTime ) );
	
	if( is_user_alive( index ) )
	{
		new iOrigin[ 3 ];
		get_user_origin( index, iOrigin );
		
		UTIL_BlowSprite( iOrigin, 30, gSprite1 );
		UTIL_BlowSprite( iOrigin, 40, gSprite2 );
		UTIL_BlowSprite( iOrigin, 20, gSprite3 );
		UTIL_BlowSprite( iOrigin, 50, gSprite4 );
	}	
}

stock UTIL_BlowSprite( iOrigin[ 3 ], addrad, sprite )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_SPRITETRAIL );
	write_coord( iOrigin[ 0 ] );		
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + addrad );
	write_short( sprite );
	write_byte( 10 );
	write_byte( random_num( 1, 3 ) );
	write_byte( 3 );
	write_byte( random_num( 7, 12 ) );
	write_byte( 20 );
	message_end( );
}

stock UTIL_ColorChat( id, const message[ ], { Float, Sql, Result, _ }:... )
{
	new Buffer[ 230 ],Buffer2[ 230 ];
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
			
		message_begin( MSG_ONE_UNRELIABLE, gMessageSayText, _, id );
		write_byte( id );
		write_string( Buffer );
		message_end( );
	} 
	
	else
	{	
		for( i = 0; i < num; i++ )
		{
			index = players[ i ];

			if( !is_user_connected( index ) ) 
			{
				continue;
			}
				
			message_begin( MSG_ONE_UNRELIABLE, gMessageSayText, _, index );
			write_byte( index );
			write_string( Buffer );
			message_end( );
		}
	}
}

stock UTIL_GetPlayerCheating( id )
{
	if( pev( id, pev_movetype ) == MOVETYPE_NOCLIP
	|| pev( id, pev_takedamage ) == DAMAGE_YES )
	{
		return 1;
	}
	
	return 0;
}

stock Float:UTIL_DistanceToFloor( id, iIgnoremonsters = 1 )
{
    	new Float:flStart[ 3 ], Float:flDest[ 3 ], Float:flEnd[ 3 ];
    	pev( id, pev_origin, flStart );

    	flDest[ 0 ] = flStart[ 0 ];
    	flDest[ 1 ] = flStart[ 1 ];
    	flDest[ 2 ] = -8191.0;

    	engfunc( EngFunc_TraceLine, flStart, flDest, iIgnoremonsters, id, 0 );
    	get_tr2( 0, TR_vecEndPos, flEnd );

    	pev( id, pev_absmin, flStart );

    	new Float:flReturn = flStart[ 2 ] - flEnd[ 2 ];

    	return flReturn > 0 ? flReturn : 0.0;
}

stock UTIL_Zone( const szClass[ ], Float:flOrigin[ 3 ], Float:flMins[ 3 ], Float:flMaxs[ 3 ] )
{
	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return 0;
	}
	
	set_pev( iEntity, pev_classname, szClass );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_solid, SOLID_TRIGGER );

	engfunc( EngFunc_SetSize, iEntity, flMins, flMaxs );

	return iEntity;
}
