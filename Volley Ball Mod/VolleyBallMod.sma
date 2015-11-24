/*
                  
                  #@#######HH$                                                        
                             @X                                                                 
                             H@#,                                                                                             
               #######X$-.      $M:                                         
                        MHX$-    M%@:                                        
                          MHXM    M%M                                       
                           .;@X#   #X-                                       
                            %@%#   MM                                       
                 HX$H$X$M@@H#M#H%M =##                                       
              MX@#@HHHHH#@$$XM$X#%+###                                       
            X@##.     #$H#M@X%#$MMMM#               H#@M%                    
           @#H      HXHH$   #MMM####M%             ;M#.#@@$                  
         ,H        XHX;       XM#MMMHM             H#M   ###                 
        H#        .@          ####@#MM-        .MM/M#M    .@H$.              
                  H#        $$#MMH@##H        %$M#X##        :H@             
                 $#        $XH#H###### ;@H#HH  H# #H##         M             
                 H#       XH@+###@##;H=X=$=@@M#MM#@#M###:      #H            
                ##       M#  #@MX#%:+//;:::=H M####MM@$@MM##    ##           
                #       H#  #%MM#X;=:;;:;//::M###$$HHHHX@H@M##  ,@           
               H       H$  M$#M###MH;=;;;-:/+M#@@HHMHHHHXMHHM#%  #M          
             #M:      #X  MM. #MM#MMX=;;/;=:M###@H#HHHHHM@HHH###  @=         
             #       MM  #@    M###MH;//+/;%M#M#M@@HMH#HH#@HHM##, #@         
                  @H#: M$M      #M#MM+++%++#M###MMMMMM@M@#HH@M###  M:        
                      XXM        ####M$$$$%M########MMMMMMHMMM###. ##        
                     XH#         :M##M@HH%$##M###################   #:       
                    ,@$            M#MH@#@MMM #############H#####   .H@      
                   #@               #@,   XM     ,#########H###.      ##:    
                  #@                                       ##                
                 -#                                        #H                
                 M#                                        #                
                ##                 -== Tuty ==-             #                
               M#                                           -H               
            /@##                      www.mapping.ro         #@.             
                                                              ##
	
	==========================================

	Volley Ball Mod

	by: tuty@mapping.ro

	Data: 13.08.2010

	==========================================
	
	Credite:
	---------
		* chaosmedia90 - mapping
		* Nokia - pentru teste
		* edduard - pt teste si sugestii
		* ghw_chronic - ceva din sursele sale
		* neurotoxin - ceva din sursa lui
		* OT [:x] - cum sa verific sa nu mai fie mingea blocata in ziduri :)
		* BLUE - teste pana peste cap !
		* vb.mapping.ro - pentru teste
		* Tiesto - pentru banner

*/





#include < amxmodx >
#include < amxmisc >

#include < fakemeta >
#include < engine >

#include < hamsandwich >
#include < fun >
#include < cstrike >

#pragma semicolon 1

// --| Some globals, defines, enums etc

#define PLUGIN_VERSION		"2.1.0"
#define HUD_LIFE_TIME		0.4
#define ADMIN_ACCESS		ADMIN_CFG
#define WHITE_SPACE		"  "
#define VOLLEYBALL_BALL_GRAVITY	0.6

#define TASKID_UNQ1		33322
#define TASKID_UNQ2		77731

#define HUD_HIDE_RHA 		(1<<3)
#define HUD_HIDE_TIMER 		(1<<4)
#define HUD_HIDE_MONEY 		(1<<5)

#define VOLLEYBALL_CFGNAME	"VolleyBall.cfg"
#define VOLLEYBALL_TAG		"[VolleyBall]"
#define VOLLEYBALL_MODEL	"models/VolleyBallMod/volleyball1.mdl"
#define VOLLEYBALL_BEAMSPRITE	"sprites/laserbeam.spr"
#define VOLLEYBALL_EXPLOSPRITE	"sprites/shockwave.spr"
#define VOLLEYBALL_THUBDERSPR	"sprites/lgtning.spr"

#define VOLLEYBALL_BOUNCE_SND	"VolleyBallMod/boing.wav"

// --| If you want to change players custom models, rename the Terr and Ct names here
// --| And add to models/player/ a folder with same CT and Terr model name!

#define VOLLEYBALL_PLAYER_CT	"volleyct" 
#define VOLLEYBALL_PLAYER_T	"volleyte"

#define MODEL_V_HANDS		"models/v_volleybhands.mdl"
#define MODEL_P_HANDS		"models/p_volleyhands.mdl"

new const gVolleyBallEntityName[ ] 	= "VolleyBallEntity";
new const gAmbienceSound[ ] 		= "ambience/thunder_clap.waV";

new Float:bFlLastHudTime[ 32 ];
new Float:flBallOldOrigin[ 3 ];

new gTerroristScore = 0;
new gCTScore = 0;

new gBeamFollowSprite;
new gThunderSprite;
new gBallDiskSprite;
new gHudSync;
new gHudSync1;
new gHudSync2;
new gHudSync3;
new gMaxPlayers;
new gMessageScoreInfo;

new gCvarBlockRadio;
new gCvarBlockSpray;
new gCvarPlayersGlow;
new gCvarBallSpeed;
new gCvarFragsBonus;
new gCvarRandomSkyColor;
new gCvarWelcomeMessage;
new gCvarSecondsToGiveBall;
new gCvarSecondsVoiceEnable;
new gCvarPlayerSpeed;
new gCvarKillPlayerOnEnemy;

new gTimerCounter[ 32 ] = 0;

enum
{
	x,
	y,
	z
};

enum _:RGB
{
	red,
	green,
	blue
};

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

const m_iHideHUD = 361;
const m_iClientHideHUD = 362;
const m_iHUD_HIDE = HUD_HIDE_RHA | HUD_HIDE_TIMER | HUD_HIDE_MONEY;

new const szHelloSounds[ ][ ] =
{
	"scientist/hello.wav",
	"scientist/hello2.wav",
	"scientist/hellothere.wav",
	"scientist/hellofreeman.wav"
};

new const szWinnerSounds[ ][ ] =
{
	"VolleyBallMod/boomchakalaka.wav",
	"VolleyBallMod/hoho.wav",
	"VolleyBallMod/mhaha.wav",
	"VolleyBallMod/tazrazz.wav",
	"VolleyBallMod/whoa.wav",
	"VolleyBallMod/yeahbaby.wav",
	"VolleyBallMod/bart.wav",
	"ambience/goal_1.wav"
};

// --| World entities where ball can bounce \:D/

new const szWorldEntities[ ][ ] =
{
	"worldspawn",
	"func_wall",
	"func_wall_toggle",
	"func_door",
	"func_door_rotating"
};

// --| If some guy put some buttons in a volley map, lets find it and block buttons

new const szButtonsEntities[ ][ ] =
{
	"func_button",
	"func_rot_button",
	"momentary_rot_button",
	"button_target"
};

// --| Those sounds must blocked since it's annoying

new const szBlockRadios[ ][ ] =
{	
	"%!MRAD_GO",
	"%!MRAD_LOCKNLOAD",
	"%!MRAD_LETSGO",
	"%!MRAD_MOVEOUT",
	"%!MRAD_terwin",
	"%!MRAD_ctwin"
};

public plugin_init( )
{
	// --| Register the plugin

	register_plugin( "VolleyBall Mod", PLUGIN_VERSION, "tuty" );
	register_cvar( "volleyball_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	
	new i;
	
	// --| Block some commands, won't need it since is VB

	register_clcmd( "radio1", "CommandBlockRadio" );
	register_clcmd( "radio2", "CommandBlockRadio" );
	register_clcmd( "radio3", "CommandBlockRadio" );
	register_clcmd( "fullupdate", "CommandBlockRadio" );

	// --| Register some commands

	register_clcmd( "say /help", "CommandShowHelp" );
	register_clcmd( "say_team /help", "CommandShowHelp" );
	register_clcmd( "say /reset", "CommandResetMatch" );
	register_clcmd( "say_team /reset", "CommandResetMatch" );
	
	// --| Detect ball touch, player touch

	register_touch( gVolleyBallEntityName, "func_breakable", "ForwardBallTouchFloor" );
	register_touch( "player", gVolleyBallEntityName, "ForwardBallTouchPlayer" );
	register_touch( "player", "func_breakable", "ForwardPlayerTouchTerritory" );
	
	for( i = 0; i < sizeof szWorldEntities; i++ )
	{
		register_touch( gVolleyBallEntityName, szWorldEntities[ i ], "ForwardBallTouchWorld" );
	}
	
	// --| Some forwards

	register_think( gVolleyBallEntityName, "ForwardBallThink" );
	register_impulse( 201, "ForwardSprayPaint" );
		
	register_forward( FM_CmdStart, "ForwardCmdStart" );
	register_forward( FM_GetGameDescription, "ForwardGameDescription" );
	register_forward( FM_ClientKill, "ForwardClientKill" );

	// --| Some hams

	RegisterHam( Ham_Player_PreThink, "player", "bacon_PlayerPreThink" );
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawned", 1 );
	RegisterHam( Ham_Killed, "player", "bacon_PlayerKilled" );
	RegisterHam( Ham_Player_ResetMaxSpeed, "player", "bacon_ResetMaxSpeed", 1 );

	for( i = 0; i < sizeof szButtonsEntities; i++ )
	{
		RegisterHam( Ham_Use, szButtonsEntities[ i ], "bacon_ButtonUsed" );
	}
	
	// --| Register some events

	register_event( "CurWeapon", "Event_CurWeapon", "be", "1=1" );
	register_logevent( "LogEvent_RoundStart", 2, "1=Round_Start" );
	register_event( "TextMsg", "RoundRestart_Attempt", "a", "2&#Game_C", "2&Game_W" );
	register_event( "30", "Hook_EventIntermission", "a" );
	register_event( "ResetHUD", "Hook_ResetHUD", "be" );	
	register_event( "HideWeapon", "Hook_HideWeapon", "be" );

	register_message( get_user_msgid( "SendAudio" ), "Message_SendAudio" ); 
	register_message( get_user_msgid( "TextMsg" ), "Message_TextMsg" ); 
	register_message( get_user_msgid( "StatusIcon" ), "Message_StatusIcon" );
	
	// --| Block DeathMsg because we avoid the death messages and console flood prints, won't need it

	set_msg_block( get_user_msgid( "DeathMsg" ), BLOCK_SET );
	set_msg_block( get_user_msgid( "ClCorpse" ), BLOCK_SET );
	
	// --| Register the cvars

	gCvarBlockRadio = register_cvar( "volleyball_blockradio", "1" );
	gCvarBlockSpray = register_cvar( "volleyball_blockspray", "1" );
	gCvarPlayersGlow = register_cvar( "volleyball_playerglow", "1" );
	gCvarBallSpeed = register_cvar( "volleyball_ballspeed", "731" );
	gCvarFragsBonus = register_cvar( "volleyball_fragbonus", "1" );
	gCvarRandomSkyColor = register_cvar( "volleyball_randomskycolor", "1" );
	gCvarWelcomeMessage = register_cvar( "volleyball_welcomemessage", "1" );
	gCvarSecondsToGiveBall = register_cvar( "volleyball_balltime", "7" );
	gCvarSecondsVoiceEnable = register_cvar( "volleyball_secondvoice", "1" );
	gCvarPlayerSpeed = register_cvar( "volleyball_player_speed", "400" );
	gCvarKillPlayerOnEnemy = register_cvar( "volleyball_playerkill", "1" );
	
	// --| Some variables

	gHudSync = CreateHudSyncObj( );
	gHudSync1 = CreateHudSyncObj( );
	gHudSync2 = CreateHudSyncObj( );
	gHudSync3 = CreateHudSyncObj( );

	gMessageScoreInfo = get_user_msgid( "ScoreInfo" );
	gMaxPlayers = get_maxplayers( );
	
	// --| ML support

	register_dictionary( "VolleyBall.txt" );
}

public plugin_precache( )
{
	// --| Precache required sprites, sounds, mdls

	gBeamFollowSprite = precache_model( VOLLEYBALL_BEAMSPRITE );
	gBallDiskSprite = precache_model( VOLLEYBALL_EXPLOSPRITE );
	gThunderSprite = precache_model( VOLLEYBALL_THUBDERSPR );
	
	new szPlayerModelPath[ 64 ];

	formatex( szPlayerModelPath, charsmax( szPlayerModelPath ), "models/player/%s/%s.mdl", VOLLEYBALL_PLAYER_CT, VOLLEYBALL_PLAYER_CT );
	precache_model( szPlayerModelPath );

	formatex( szPlayerModelPath, charsmax( szPlayerModelPath ), "models/player/%s/%s.mdl", VOLLEYBALL_PLAYER_T, VOLLEYBALL_PLAYER_T );
	precache_model( szPlayerModelPath );

	precache_model( VOLLEYBALL_MODEL );
	precache_model( MODEL_V_HANDS );
	precache_model( MODEL_P_HANDS );
	
	precache_sound( VOLLEYBALL_BOUNCE_SND );
	precache_sound( gAmbienceSound );

	new i;
	
	for( i = 0; i < sizeof szHelloSounds; i++ )
	{
		precache_sound( szHelloSounds[ i ] );
	}
	
	for( i = 0; i < sizeof szWinnerSounds; i++ )
	{
		precache_sound( szWinnerSounds[ i ] );
	}
}

public plugin_cfg( )
{
	// --| Executing the config file!

	new szConfigsDir[ 64 ], szFile[ 200 ];
	
	get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
	formatex( szFile, charsmax( szFile ), "%s/%s", szConfigsDir, VOLLEYBALL_CFGNAME );
	
	if( file_exists( szFile ) )
	{
		server_print( "%s %L", VOLLEYBALL_TAG, LANG_SERVER , "FILE_LOADED", szFile );
		log_amx( "%s %L", VOLLEYBALL_TAG, LANG_SERVER, "FILE_LOADED", szFile );

		server_cmd( "exec %s", szFile );
	}
	
	else
	{
		server_print( "%s %L", VOLLEYBALL_TAG, LANG_SERVER, "FILE_NOT_FOUND", szFile );
		log_amx( "%s %L", VOLLEYBALL_TAG, LANG_SERVER, "FILE_NOT_FOUND", szFile );
	}

	// --| Enforce some server cvars for gameplay

	server_cmd( "mp_autoteambalance 1" );
	server_cmd( "mp_freezetime 0" );
	server_cmd( "sv_gravity 800" );
	server_cmd( "sv_maxspeed 2000.0" );
	server_cmd( "mp_friendlyfire 0" );
}

public client_putinserver( id )
{
	if( get_pcvar_num( gCvarWelcomeMessage ) == 1 )
	{
		set_task( 7.0, "ShowMessageInfo", id );
	}
	
	gTimerCounter[ id ] = 0;
}

// --| Find at rou8ndstart a random guy, and if its necessary set the sky color in random colors

public LogEvent_RoundStart( )
{
	// --| Clear center message channel because will apper some random messages like free look etc

	client_print( 0, print_center, "      " );
	client_print( 0, print_center, "      " );
	
	remove_entity_name( gVolleyBallEntityName );

	UTIL_GiveBallRandom( );

	if( get_pcvar_num( gCvarRandomSkyColor ) == 1 )
	{
		new iSkyColor[ RGB ];
	
		iSkyColor[ red ] = random_num( 0, 255 );
		iSkyColor[ green ] = random_num( 0, 255 );
		iSkyColor[ blue ] = random_num( 0, 255 );
	
		server_cmd( "sv_skycolor_r %d", iSkyColor[ red ] );
		server_cmd( "sv_skycolor_g %d", iSkyColor[ green ] );
		server_cmd( "sv_skycolor_b %d", iSkyColor[ blue ] );
	}

	return PLUGIN_CONTINUE;
}

// --| If game is restarting, remove current tasks and remove ball

public RoundRestart_Attempt( )
{
	new iPlayers[ 32 ], iNum, Index;
	get_players( iPlayers, iNum, "cgh" );
	
	for( new i = 0; i < iNum; i++ )
	{
		Index = iPlayers[ i ];
		
		UTIL_CheckExistingTasks( Index );
		remove_entity_name( gVolleyBallEntityName );
	}

	UTIL_ResetTeamsScore( );
}

// --| Show a hud message as countdown and sound if enabled

public ShowCountDown( taskid )
{
	new iRandomPlayer = taskid - TASKID_UNQ2;

	new szName[ 32 ];
	get_user_name( iRandomPlayer, szName, charsmax( szName ) );

	gTimerCounter[ iRandomPlayer ]++;
	
	new iTimer = get_pcvar_num( gCvarSecondsToGiveBall ) - gTimerCounter[ iRandomPlayer ];
	
	set_hudmessage( 42, 255, 42, -1.0, 0.39, 1, 6.0, 2.0 );
	ShowSyncHudMsg( 0, gHudSync2, "%s %L", VOLLEYBALL_TAG, LANG_PLAYER, "WILL_HAVE_BALL", szName, iTimer );
	
	if( get_pcvar_num( gCvarSecondsVoiceEnable ) == 1 )
	{
		if( iTimer <= 3 )
		{
			new szNumToWord[ 20 ];
			num_to_word( iTimer, szNumToWord, charsmax( szNumToWord ) );
		
			client_cmd( 0, "speak ^"fvox/%s^"", szNumToWord );
		}
	}
}

// --| Here we create ball, and give to player's head ^^

public GiveBallToPlayer( taskid )
{
	new iRandomPlayer = taskid - TASKID_UNQ1;

	UTIL_CheckExistingTasks( iRandomPlayer );

	new iOrigin[ 3 ], Float:flOrigin[ 3 ];
	get_user_origin( iRandomPlayer, iOrigin );
	
	new szName[ 32 ];
	get_user_name( iRandomPlayer, szName, charsmax( szName ) );

	iOrigin[ z ] += 400;
	
	IVecFVec( iOrigin, flOrigin );

	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEntity, pev_classname, gVolleyBallEntityName );
	
	engfunc( EngFunc_SetModel, iEntity, VOLLEYBALL_MODEL );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -15.930000, -15.930000, -15.930000 }, Float:{ 15.930000, 15.930000, 15.930000 } );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );
	
	set_pev( iEntity, pev_solid, SOLID_BBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_BOUNCE );
	set_pev( iEntity, pev_iuser2, get_user_team( iRandomPlayer ) );
	set_pev( iEntity, pev_target, szName );
	set_pev( iEntity, pev_gravity, VOLLEYBALL_BALL_GRAVITY );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 6.0 );
	
	gTimerCounter[ iRandomPlayer ] = 0;

	return PLUGIN_HANDLED;
}

// --| If player JUMP in the ball, set ball glow color as player team and trail 
// --| Do the ball velocity and update last player name who touched ball

public ForwardBallTouchPlayer( iPlayer, iBall )
{
	set_pev( iBall, pev_iuser2, get_user_team( iPlayer ) );

	new iTeam = pev( iBall, pev_iuser2 );
	
	switch( iTeam )
	{
		case 1:
		{
			UTIL_KillBeamFollow( iBall );
			UTIL_BeamFollow( iBall, 255, 0, 0 );

			set_rendering( iBall, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25 );
		}
		
		case 2:
		{
			UTIL_KillBeamFollow( iBall );
			UTIL_BeamFollow( iBall, 0, 0, 255 );

			set_rendering( iBall, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25 );
		}
	}
	
	new Float:flVelocity[ 3 ];
	velocity_by_aim( iPlayer, get_pcvar_num( gCvarBallSpeed ), flVelocity );

	set_pev( iBall, pev_velocity, flVelocity );
	
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );
		
	set_pev( iBall, pev_target, szName );
}

// --| If player touch the enemy's terrain, let's slay the whole team

public ForwardPlayerTouchTerritory( iPlayer, iEntity )
{
	if( !is_user_alive( iPlayer ) || get_pcvar_num( gCvarKillPlayerOnEnemy ) == 0 || !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}

	new szTeritoryName[ 10 ];
	pev( iEntity, pev_target, szTeritoryName, charsmax( szTeritoryName ) );
	
	new szName[ 32 ];
	get_user_name( iPlayer, szName, charsmax( szName ) );

	if( equal( szTeritoryName, "CT", 2 ) )
	{
		if( get_user_team( iPlayer ) == 1 )
		{
			UTIL_SlayTeam( "TERRORIST" );

			set_hudmessage( 255, 0, 0, -1.0, 0.86, 1, 6.0, 5.0 );
			ShowSyncHudMsg( 0, gHudSync3, "%L", LANG_PLAYER, "RED_TEAM_SLAY", szName );
		
			client_print( 0, print_chat, "%L", LANG_PLAYER, "RED_TEAM_SLAY", szName );
			client_cmd( 0, "speak %s", gAmbienceSound );
		}
	}
	
	if( equal( szTeritoryName, "T", 1 ) )
	{
		if( get_user_team( iPlayer ) == 2 )
		{
			UTIL_SlayTeam( "CT" );

			set_hudmessage( 0, 0, 255, -1.0, 0.86, 1, 6.0, 5.0 );
			ShowSyncHudMsg( 0, gHudSync3, "%L", LANG_PLAYER, "BLUE_TEAM_SLAY", szName );
		
			client_print( 0, print_chat, "%L", LANG_PLAYER, "BLUE_TEAM_SLAY", szName );
			client_cmd( 0, "speak %s", gAmbienceSound );
		}
	}
	
	return PLUGIN_HANDLED;
}

// --| If ball touch enemy or owner terrain let's do same slays and score

public ForwardBallTouchFloor( iBall, iTrigger )
{
	new Float:flOrigin[ 3 ], iOrigin[ 3 ];

	pev( iBall, pev_origin, flOrigin );
	FVecIVec( flOrigin, iOrigin );

	new szTeritoryName[ 10 ];
	pev( iTrigger, pev_target, szTeritoryName, charsmax( szTeritoryName ) );
	
	new szPlayerName[ 32 ];
	pev( iBall, pev_target, szPlayerName, charsmax( szPlayerName ) );

	if( equal( szTeritoryName, "CT", 2 ) )
	{
		gTerroristScore++;

		UTIL_SlayTeam( "CT" );
		UTIL_AddFragToTeam( "TERRORIST" );

		set_hudmessage( 255, 0, 0, -1.0, 0.86, 1, 6.0, 5.0 );
		ShowSyncHudMsg( 0, gHudSync, "%L", LANG_PLAYER, "RED_TEAM_WIN", szPlayerName );
		
		client_print( 0, print_chat, "%s %L", VOLLEYBALL_TAG, LANG_PLAYER, "RED_TEAM_SCORE", gTerroristScore, gCTScore );
		client_cmd( 0, "speak %s", szWinnerSounds[ random_num( 0, charsmax( szWinnerSounds ) ) ] );
	}
	
	if( equal( szTeritoryName, "T", 1 ) )
	{
		gCTScore++;

		UTIL_SlayTeam( "TERRORIST" );
		UTIL_AddFragToTeam( "CT" );
		
		set_hudmessage( 0, 0, 255, -1.0, 0.86, 1, 6.0, 5.0 );
		ShowSyncHudMsg( 0, gHudSync, "%L", LANG_PLAYER, "BLUE_TEAM_WIN", szPlayerName );
	
		client_print( 0, print_chat, "%s %L", VOLLEYBALL_TAG, LANG_PLAYER, "BLUE_TEAM_SCORE", gCTScore, gTerroristScore );
		client_cmd( 0, "speak %s", szWinnerSounds[ random_num( 0, charsmax( szWinnerSounds ) ) ] );
	}
	
	UTIL_BeamDisk( iOrigin );
	UTIL_TareExplosion( iOrigin );

	set_pev( iBall, pev_flags, pev( iBall, pev_flags ) | FL_KILLME );
}

// --| Ball touch world so, let make it bounce

public ForwardBallTouchWorld( iBall, iWorld )
{
	if( pev_valid( iBall ) )
	{
		new Float:flOrigin[ 3 ], Float:flVelocity[ 3 ];
	
		pev( iBall, pev_origin, flOrigin );
		pev( iBall, pev_velocity, flVelocity );
	
		// --| Keep the old origin for checking if is in same origin to remve it when stuck

		flBallOldOrigin[ x ] = flOrigin[ 0 ];
		flBallOldOrigin[ y ] = flOrigin[ 1 ];
		flBallOldOrigin[ z ] = flOrigin[ 2 ];

		UTIL_Sparks( flOrigin );

		flVelocity[ x ] = floatmul( flVelocity[ 0 ], 0.85 );
		flVelocity[ y ] = floatmul( flVelocity[ 1 ], 0.85 );
		flVelocity[ z ] = floatmul( flVelocity[ 2 ], 0.85 );
	
		set_pev( iBall, pev_velocity, flVelocity );
		emit_sound( iBall, CHAN_BODY, VOLLEYBALL_BOUNCE_SND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}

// --| Ball think, here we remove it if is stuck or is in same origin for X seconds
// --| We remove the ball and re-give to a random guy

public ForwardBallThink( iBall )	
{
	if( pev_valid( iBall ) )
	{
		set_pev( iBall, pev_nextthink, get_gametime( ) + 6.0 );

		new Float:flOrigin[ 3 ];
		pev( iBall, pev_origin, flOrigin );

		if( UTIL_IsHullVacant( flOrigin, HULL_HEAD ) )
		{
			remove_entity_name( gVolleyBallEntityName );

			UTIL_GiveBallRandom( );
		}
	
		if( flOrigin[ x ] == flBallOldOrigin[ x ] && flOrigin[ y ] == flBallOldOrigin[ y ] && flOrigin[ z ] == flBallOldOrigin[ z ] )
		{
			remove_entity_name( gVolleyBallEntityName );
		
			UTIL_GiveBallRandom( );
		}
	}
}

// --| When player connected, let's show him a info message
	
public ShowMessageInfo( id )
{
	new szServerName[ 64 ];
	get_cvar_string( "hostname", szServerName, charsmax( szServerName ) );

	new szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );

	client_print( id, print_chat, "%s %L", VOLLEYBALL_TAG, id, "WELCOME_MSG1", szName, szServerName );
	client_print( id, print_chat, "%s %L", VOLLEYBALL_TAG, id, "WELCOME_MSG2" );

	client_cmd( id, "speak ^"%s^"", szHelloSounds[ random_num( 0, charsmax( szHelloSounds ) ) ] );
}

// --| If player weapon is a knife, let's replace knife with hands[our custom model]

public Event_CurWeapon( id )
{
	if( !is_user_alive( id ) || !is_user_connected( id ) ) 
	{
		return PLUGIN_CONTINUE;
	}
	
	new iTempId[ 2 ];
	new iWeapon = get_user_weapon( id, iTempId[ 0 ], iTempId[ 1 ] );
	
	if( iWeapon == CSW_KNIFE )
	{
		set_pev( id, pev_viewmodel2, MODEL_V_HANDS );
		set_pev( id, pev_weaponmodel2, MODEL_P_HANDS );
	}
	
	return PLUGIN_CONTINUE;
}

// --| Here we remove the unnecessary hud messages

public Hook_ResetHUD( id )
{
	set_pdata_int( id, m_iClientHideHUD, 0 );
	set_pdata_int( id, m_iHideHUD, m_iHUD_HIDE );
}

public Hook_HideWeapon( id )
{
	set_pdata_int( id, m_iClientHideHUD, 0 );
	set_pdata_int( id, m_iHideHUD, m_iHUD_HIDE );
}

// --| Block some radio sounds here

public Message_SendAudio( msg_id, msg_dest, msg_entity )
{
	if( get_msg_args( ) == 3 )
	{
		if( get_msg_argtype( 2 ) == ARG_STRING )
		{
			new szValue[ 64 ];
			get_msg_arg_string( 2 , szValue, charsmax( szValue ) );
			
			new i;
			
			for( i = 0; i < sizeof szBlockRadios; i++ )
			{
				if( equal( szValue, szBlockRadios[ i ] ) )
				{
					return PLUGIN_HANDLED;
				}
			}
		}
	}

	return PLUGIN_CONTINUE;
}

// --| Block ct win , ter winn messages

public Message_TextMsg( msg_id, msg_dest, msg_entity )
{
	new szMessage[ 3 ];
	get_msg_arg_string( 2, szMessage, charsmax( szMessage ) );
	
	switch( szMessage[ 1 ] )
	{
		case 'C', 'T', 'R': return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// --| Remove buyicon because is annoying

public Message_StatusIcon( msg_id, msg_dest, msg_entity )
{
	new szIcon[ 8 ];
    	get_msg_arg_string( 2, szIcon, charsmax( szIcon ) );
	
	if( equal( szIcon, "buyzone", 7 ) )
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// --| When scoreboard is ON at map end let's remove tasks and entity

public Hook_EventIntermission( )
{
	new iPlayers[ 32 ], iNum, Index;
	get_players( iPlayers, iNum, "cgh" );
	
	for( new i = 0; i < iNum; i++ )
	{
		Index = iPlayers[ i ];
		
		UTIL_CheckExistingTasks( Index );
	}
	
	remove_entity_name( gVolleyBallEntityName );
}
	
// --| Best event to check player speed
// --| With curweapon will have some serious bugs, so this is the best way

public bacon_ResetMaxSpeed( id )
{
	if( is_user_alive( id ) )
	{
		new Float:flMaxSpeed = float( get_pcvar_num( gCvarPlayerSpeed ) );
	
		engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed );
		set_pev( id, pev_maxspeed, flMaxSpeed );
		
		/*
			// --| For some people, is slowfuckinghacking, if you want to enable it just remove the slash's
			client_cmd( id, "cl_forwardspeed %0.1f;cl_sidespeed %0.1f;cl_backspeed %0.1f", flMaxSpeed, flMaxSpeed, flMaxSpeed );
		*/
	}
}

// --| If player is spawned let's glow his suit and set the team custom model

public bacon_PlayerSpawned( id )
{
	if( !is_user_alive( id ) )
	{
        	return HAM_IGNORED;
	}

	if( get_pcvar_num( gCvarPlayersGlow ) == 1 )
	{
		switch( get_user_team( id ) )
		{
			case 1: set_user_rendering( id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 20 );
			case 2: set_user_rendering( id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 20 );
		}
	}
	
	new CsTeams:team = cs_get_user_team( id );
	cs_set_user_model( id, team == CS_TEAM_CT ?  VOLLEYBALL_PLAYER_CT :  VOLLEYBALL_PLAYER_T );
	
	return HAM_IGNORED;
}

// --| Block buttons because our floor func_breakable is with only trigger flag, so if
// --| Some guy want to destroy the map and have fun with bugs, to prevent it.

public bacon_ButtonUsed( this, idcaller, idactivator, use_type, Float:value )
{
   	if( idcaller == idactivator )
	{
        	return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

// --| Here we show the "score board" with team score

public bacon_PlayerPreThink( id )
{
	if( is_user_alive( id ) )
	{
		new Float:flGameTime = get_gametime( );
		
		new iTimeleft = get_timeleft( );
		new iPlayersNum = get_playersnum( );
		new iTotalScore = gCTScore + gTerroristScore;
			
		if( flGameTime - bFlLastHudTime[ id ] >= HUD_LIFE_TIME )
		{
			bFlLastHudTime[ id ] = flGameTime;
			
			switch( get_user_team( id ) )
			{
				case 1: set_hudmessage( 255, 0, 0, -1.0, 0.03, 0, 6.0, HUD_LIFE_TIME );
				case 2: set_hudmessage( 0, 0, 255, -1.0, 0.03, 0, 6.0, HUD_LIFE_TIME );
			}
			
			ShowSyncHudMsg( id, gHudSync1, "%s^n%L", VOLLEYBALL_TAG, id, "HUD_SCOREBOARD", iTotalScore, gCTScore, gTerroristScore, ( iTimeleft / 60 ), ( iTimeleft % 60 ), iPlayersNum, gMaxPlayers );
		}
	}
}

// --| Since deathmsg is blocked, this ham event is good to check if player died and remove the current ball task
	
public bacon_PlayerKilled( iVictim, iAttacker, shouldgib )
{
	if( 1 <= iVictim <= gMaxPlayers )
    	{
		UTIL_CheckExistingTasks( iVictim );
	}
}

// --| Command to reset match
		
public CommandResetMatch( id )
{
	if( !( get_user_flags( id ) & ADMIN_ACCESS ) )
	{
		client_print( id, print_chat, "%s %L", VOLLEYBALL_TAG, id, "DONT_HAVE_ACCESS" );
		
		return PLUGIN_HANDLED;
	}
	
	new id2;
	
	for( id2 = 1; id2 <= gMaxPlayers; id2++ )
	{
		UTIL_CheckExistingTasks( id2 );
	}

	set_task( 1.0, "RestartMatch" );

	client_print( 0, print_chat, "%s %L", VOLLEYBALL_TAG, LANG_PLAYER, "GAME_WILL_START" );
	client_print( 0, print_center, "%L", LANG_PLAYER, "GAME_WILL" );
	
	remove_entity_name( gVolleyBallEntityName );

	return PLUGIN_CONTINUE;
}

public RestartMatch( )
{
	server_cmd( "sv_restartround %d", random_num( 1, 2 ) );

	remove_entity_name( gVolleyBallEntityName );
	UTIL_ResetTeamsScore( );
}

// --| Here will show some help in player console
	
public CommandShowHelp( id )
{
	client_cmd( id, "toggleconsole" );
	
	console_print( id, "=================================" );
	console_print( id, "* %L *", id, "INFO_1" );
	console_print( id, "=================================" );
	console_print( id, "%s", WHITE_SPACE );
	console_print( id, "%s", WHITE_SPACE );
	console_print( id, "%L", id, "INFO_2" );
	console_print( id, "%L", id, "INFO_3" );
	console_print( id, "%L", id, "INFO_4" );
	console_print( id, "%L", id, "INFO_5" );
	console_print( id, "%s", WHITE_SPACE );
	console_print( id, "%s", WHITE_SPACE );
	console_print( id, "%L", id, "INFO_6" );
	console_print( id, "%L", id, "INFO_7" );
	console_print( id, "%L", id, "INFO_8" );
	console_print( id, "%s", WHITE_SPACE );
	console_print( id, "=================================" );
}

// --| Set the mod name

public ForwardGameDescription( )
{
	forward_return( FMV_STRING, "[Volley Ball Mod]" );
	
	return FMRES_SUPERCEDE;
}

// --| Block player kill

public ForwardClientKill( id )
{
	client_print( id, print_chat, "%s %L", VOLLEYBALL_TAG, id, "CANNOT_SUICIDE" );
	console_print( id, "%s %L", VOLLEYBALL_TAG, id, "CANNOT_SUICIDE" );
	
	return FMRES_SUPERCEDE;
}

// --| Block spraypaint

public ForwardSprayPaint( id )
{
	if( get_pcvar_num( gCvarBlockSpray ) == 1 )
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// --| Block radio

public CommandBlockRadio( id )
{
	if( get_pcvar_num( gCvarBlockRadio ) == 1 )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	return PLUGIN_CONTINUE;
}

// --| At changing map, reset team scores

public plugin_end( )
{
	UTIL_ResetTeamsScore( );
}
	
// --| Some stocks with effect and more made by me or amx mod x members
// --| Use it if you want
		
stock UTIL_Sparks( Float:flOrigin[ 3 ] )
{
	engfunc( EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, flOrigin, 0 );
	write_byte( TE_SPARKS );
	engfunc( EngFunc_WriteCoord, flOrigin[ x ] ); 
	engfunc( EngFunc_WriteCoord, flOrigin[ y ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ z ] ); 
	message_end( );
}

stock UTIL_BeamDisk( iOrigin[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMDISK );
	write_coord( iOrigin[ x ] ); 
	write_coord( iOrigin[ y ] );
	write_coord( iOrigin[ z ] + random_num( -30, 50 ) );
	write_coord( iOrigin[ x ] );
	write_coord( iOrigin[ y ] );
	write_coord( iOrigin[ z ] + 200 );
	write_short( gBallDiskSprite );
	write_byte( 1 ); 
	write_byte( 3 );
	write_byte( 8 ); 
	write_byte( 20 );
	write_byte( 6 ); 
	write_byte( random( 256 ) );
	write_byte( random( 256 ) );
	write_byte( random( 256 ) );
	write_byte( 255 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_TareExplosion( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_TAREXPLOSION );
	write_coord( iOrigin[ x ] );
	write_coord( iOrigin[ y ] );
	write_coord( iOrigin[ z ] );
	message_end( );
}

stock UTIL_SlayTeam( const szTeam[ ] )
{
	new iPlayers[ 32 ], iCount, Index;
	get_players( iPlayers, iCount, "ce", szTeam );
	
	for( new i = 0; i < iCount; i++ )
	{
		Index = iPlayers[ i ];

		if( is_user_alive( Index ) && is_user_connected( Index ) )
		{
			new iOrigin[ 3 ], iPosition[ 3 ];
			get_user_origin( Index, iOrigin );
			
			iPosition[ x ] = iOrigin[ 0 ] + 100;
			iPosition[ y ] = iOrigin[ 1 ] + 150;
			iPosition[ z ] = iOrigin[ 2 ] + 812;
			
			UTIL_CreateThunder( iPosition, iOrigin );
			ExecuteHam( Ham_TakeDamage, Index, 0, Index, 9999.0, DMG_GENERIC );
			
			UTIL_SetClientDeaths( Index, 0 );
			UTIL_ScoreInfo( Index, get_user_frags( Index ), get_user_deaths( Index ), get_user_team( Index ) );
		}
	}
}

stock UTIL_AddFragToTeam( const szTeam[ ] )
{
	new iPlayers[ 32 ], iCount, Index;
	get_players( iPlayers, iCount, "ce", szTeam );
	
	for( new i = 0; i < iCount; i++ )
	{
		Index = iPlayers[ i ];

		if( is_user_connected( Index ) )
		{
			set_user_frags( Index, get_user_frags( Index ) + get_pcvar_num( gCvarFragsBonus ) );
			
			UTIL_ScoreInfo( Index, get_user_frags( Index ), get_user_deaths( Index ), get_user_team( Index ) );
		}
	}
}

stock UTIL_BeamFollow( ent, r, g, b )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( ent );
	write_short( gBeamFollowSprite );
	write_byte( 8 );
	write_byte( 16 ); 
	write_byte( r ); 
	write_byte( g ); 
	write_byte( b ); 
	write_byte( 255 );
	message_end( );
}

stock UTIL_KillBeamFollow( ent )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_KILLBEAM );    
	write_short( ent );
	message_end( );
}

stock UTIL_SetClientDeaths( iClient, iDeathsNum )
{
	set_pdata_int( iClient, 444, iDeathsNum, 5 );
}

stock UTIL_CheckExistingTasks( index )
{
	if( task_exists( index + TASKID_UNQ1 ) )
	{
		remove_task( index + TASKID_UNQ1 );
	}
		
	if( task_exists( index + TASKID_UNQ2 ) )
	{
		remove_task( index + TASKID_UNQ2 );
	}
	
	gTimerCounter[ index ] = 0;
}

stock UTIL_ScoreInfo( id, iFrags, iDeaths, iTeam )
{
	message_begin( MSG_BROADCAST, gMessageScoreInfo );
	write_byte( id );
	write_short( iFrags );
	write_short( iDeaths );
	write_short( 0 );
	write_short( iTeam );
	message_end( );
}

stock UTIL_ResetTeamsScore( )
{
	gTerroristScore = 0;
	gCTScore = 0;
}

stock bool:UTIL_IsHullVacant( const Float:origin[ 3 ], hull ) 
{
	new tr = 0;
	engfunc( EngFunc_TraceHull, origin, origin, 0, hull, 0, tr );

	if( !get_tr2( tr, TR_StartSolid ) && !get_tr2( tr, TR_AllSolid ) && get_tr2( tr, TR_InOpen ) )
	{
		return true;
	}

	return false;
}

stock UTIL_CreateThunder( iStart[ 3 ], iEnd[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMPOINTS  );
	write_coord( iStart[ x ] );
	write_coord( iStart[ y ] );
	write_coord( iStart[ z ] );
	write_coord( iEnd[ x ] );
	write_coord( iEnd[ y ] );
	write_coord( iEnd[ z ] );
	write_short( gThunderSprite );
	write_byte( 0 );	
	write_byte( 0 ); 			
	write_byte( 7 ); 			
	write_byte( 200 ); 			
	write_byte( 25 );
	write_byte( 127 );
	write_byte( 255 );		
	write_byte( 0 );
	write_byte( 220 );
	write_byte( 1 );
	message_end( );
}

stock UTIL_GiveBallRandom( )
{
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum, "ach" );
	
	if( iNum )
    	{
		new iRandomPlayer = iPlayers[ random( iNum ) ];
		new iTime = get_pcvar_num( gCvarSecondsToGiveBall );
		
		UTIL_CheckExistingTasks( iRandomPlayer );

		if( is_user_connected( iRandomPlayer ) )
		{
			set_task( 1.0, "ShowCountDown", iRandomPlayer + TASKID_UNQ2, _, _, "a", iTime );
			set_task( float( iTime ), "GiveBallToPlayer", iRandomPlayer + TASKID_UNQ1 );
		}
	}
}

// --| End of plugin
// --| Y!M: tuty_max_boy@yahoo.com ^^
// --| www.mapping.ro
