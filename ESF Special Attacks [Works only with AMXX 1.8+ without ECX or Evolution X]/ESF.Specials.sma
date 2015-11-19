
/*

	=========================================

	+---------------------+
	| ESF Special Attacks |
	+---------------------+


	Coded by: tuty
	Date: 13 - Octomber - 2010
	Country: Romania
	

	+-------------+
	| Credits to: |
	+-------------+

		* Lord of Destruction
		* EVM, ECX Team, for some sounds/models/sprites! Thank you!
		* To hleV, ConnorMcLeod, Blondu!
		* Other AMXX Coders


	+-------------+
	| For haters: |
	+-------------+
		

		* I didn't wrote some tips behind the lines, because is too much to write and 
		good coders can understand this. I fixed every bug possible, i think aren't another bugs!
		* If you really think i copy-pasted this code you are a moron.
		* I spent more than one week making this code and im proud of it
		* If you still think i copied this code, read the whole damn code,
		and see i made this with my own brain, and used some tricks here.
		* Thank you hleV for helping me out with some code, and Connor too!
 		* Hope you won't rename the damn author![joke]


	+--------------+
	| Information: |
	+--------------+
	

		* Vegeta: 	<Ultimate Sacrifice>
		* Goku: 	<Super Kaioken + Ryuken>
		* Krillin: 	<Bloody Solar Flare>
		* Buu: 		<Body Part>
		* Cell: 	<Self Destruct>
		* Trunks: 	<Warp>
		* Piccolo: 	<Regenerate>
		* Frieza: 	<Telekinese>
		* Gohan:	<Angry Blast>
	

	+---------------+
	| Modules used: |
	+---------------+
		
		* Hamsandwich
		* Engine
		* Fakemeta
		* And of course, the AMXX Mod.
	

	+-------------+
	| Cooldown's: |
	+-------------+
	
		* Vegeta: 180 seconds
		* Goku: 80 seconds
		* Krillin: 45 seconds
		* Buu: 75 seconds
		* Cell: 180 seconds
		* Trunks: 45 seconds
		* Piccolo: 62 seconds
		* Frieza: 95 seconds
		* Gohan: 66 seconds

	=========================================

*/




#include < amxmodx >

#include < engine >
#include < fakemeta >
#include < hamsandwich >

#pragma semicolon 1

#define PLUGIN_VERSION		"1.0.4"

#define FFADE_IN		0x0000
#define DELAY_RESET		-5000.0
#define PICCOLO_ASCEND_MAXLIFE	140
#define IsPlayer(%1)		(1 <= %1 <= gMaxPlayers)
#define MAX_PLAYERS		32 + 1


enum
{
        CLASS_NONE = 0,
 
        CLASS_BUU,	
      	CLASS_GOKU,	
        CLASS_GOHAN,
       	CLASS_KRILLIN,	
        CLASS_FRIEZA,	
        CLASS_PICCOLO,	
        CLASS_TRUNKS,	
        CLASS_VEGETA,	
        CLASS_CELL	
};

enum
{
	EXPLOSION_COLOR_BLUE = 0,

	EXPLOSION_COLOR_GREEN,
	EXPLOSION_COLOR_ORANGE,
	EXPLOSION_COLOR_PURPLE,
	EXPLOSION_COLOR_YELLOW,
	EXPLOSION_COLOR_RED,
	EXPLOSION_COLOR_WHITE
};

enum ( += 593 )
{
	TASK_KAIOKEN_1 = 1000,
	TASK_KAIOKEN_2,
	TASK_KAIOKEN_3,
	TASK_ULSACRIFICE_1,
	TASK_ULSACRIFICE_2,
	TASK_SOLARFLARE_1,
	TASK_SOLARFLARE_2,
	TASK_BODYPART_1,
	TASK_BODYPART_2,
	TASK_SDESTRUCT_1,
	TASK_SDESTRUCT_2,
	TASK_SDESTRUCT_3,
	TASK_HEAL_1,
	TASK_HEAL_2,
	TASK_TELEKINESE,
	TASK_ANGRYBLAST_1,
	TASK_ANGRYBLAST_2,
	TASK_BODYPART_DURATION
};


/* --| Fake weapon entities */

new gUltimateSacrificeEnt;
new gBloodySolarFlareEnt;
new gSelfDestructEnt;
new gTelekineseEnt;
new gAngryBlastEnt;

/* --| --------------------- */

new bUltimateSacrifice[ MAX_PLAYERS ];
new bSacrificeMdl[ MAX_PLAYERS ];
new bGlowGrownUp[ MAX_PLAYERS ];
new bChargeTime[ MAX_PLAYERS ];
new bSuperKaioken[ MAX_PLAYERS ];
new bCurrentPL[ MAX_PLAYERS ];
new bDragonHead[ MAX_PLAYERS ];
new bChargeKaioken[ MAX_PLAYERS ];
new bSolarFlareCharge[ MAX_PLAYERS ];
new bGlowSolarFlare[ MAX_PLAYERS ];
new bBodyPartCharge[ MAX_PLAYERS ];
new bSelfDestructMdl[ MAX_PLAYERS ];
new bAngryBlastMdl[ MAX_PLAYERS ];
new bSelfDestruct[ MAX_PLAYERS ];
new bChangeAnimation[ MAX_PLAYERS ];
new bHealingCharge[ MAX_PLAYERS ];
new bTelekineseActivated[ MAX_PLAYERS ];
new bAngryStarted[ MAX_PLAYERS ];
new bUserTrapped[ MAX_PLAYERS ];

new Float:flSacrificeScale[ MAX_PLAYERS ];
new Float:flSpecialUltimateDelay[ MAX_PLAYERS ];
new Float:flSpecialKaiokenDelay[ MAX_PLAYERS ];
new Float:flSpecialSolarDelay[ MAX_PLAYERS ];
new Float:flSpecialBodyPartDelay[ MAX_PLAYERS ];
new Float:flLastHealthToken[ MAX_PLAYERS ];
new Float:flSpecialDestructDelay[ MAX_PLAYERS ];
new Float:flSpecialWarpDelay[ MAX_PLAYERS ];
new Float:flSpecialRegenerateDelay[ MAX_PLAYERS ];
new Float:flSpecialTelekinese[ MAX_PLAYERS ];
new Float:flSpecialAngryAttack[ MAX_PLAYERS ];

new bool:bWasSwoopingHuh[ MAX_PLAYERS ];

new gKaiokenTrail;
new gSpriteShockwave;
new gSpriteLight;
new gMessageExplosion;
new gMessageCharge;
new gMessagePowerUp;
new gMessageStopPowerup;
new gMessageBlob;
new gMessageScreenFade;
new gMessageMaxHealth;
new gMaxPlayers;
new gHudSyncronizer;

new const gBodyPartEntity[ ] = "ESFBodyPart";

new const gWhiteSphereModel[ ] = "models/ESFSpecials/white_sphere.mdl";
new const gSdSphereModel[ ] = "models/ESFSpecials/selfdestruct.mdl";
new const gBodyPartSmallModel[ ] = "models/ESFSpecials/bodypart.mdl";
new const gKaiokenDragonModel[ ] = "models/ESFSpecials/dragonhead.mdl";
new const gUlSacrificeModel[ ] = "models/ESFSpecials/ultimatesacrifice.mdl";

new const gBodyPartSound[ ] = "weapons/candypop.wav";
new const gTeleportSound[ ] = "weapons/teleport.wav";
new const gGohanBlastSound[ ] = "gohan/shield.wav";
new const gSolarFlareSound[ ] = "krillin/solarflare.wav";
new const gSuperKaiokenSound[ ] = "ESFSpecials/superkaioken.waV";
new const gSwoopKaiokenSound[ ] = "ESFSpecials/kaioswoop.wav";
new const gUlSacrificeSound[ ] = "ESFSpecials/ultimatesacrifice.wav";
new const gBodyPartYeahSound[ ] = "ESFSpecials/bodypart.wav";
new const gSelfDestructionSound[ ] = "ESFSpecials/selfdestruction.wav";
new const gWarpSound[ ] = "ESFSpecials/excuseme.wav";
new const gRegenerateSound[ ] = "ESFSpecials/regenerate.wav";
new const gRyukenSound[ ] = "ESFSpecials/ryuken.wav";
new const gGohanAngrySound[ ] = "ESFSpecials/angryblast.wav";

new const gTelekineseExplosionSounds[ ][ ] =
{
	"weapons/explode3.wav",
	"weapons/explode4.wav",
	"weapons/explode5.wav"
};

new Float:flSolarFlareDamage = 25.0;
new Float:flBodyPartDuration = 15.0;
new Float:flTelekineseDuration = 8.0;
new Float:flAngryAttackDamage = 30.0;
new Float:flAngryAttackRadius = 2800.0;

new Float:flDelayTimeUltimate = 180.0;
new Float:flDelayTimeKaio = 80.0;
new Float:flDelayTimeSolar = 45.0;
new Float:flDelayBodyPart = 75.0;
new Float:flDelayWarp = 45.0;
new Float:flDelayRegenerate = 62.0;
new Float:flDelayTelekinese = 95.0;
new Float:flDelayAngryBlast = 66.0;

public plugin_init( )
{
	register_plugin( ">>>[ ESF Special Attacks ]<<<", PLUGIN_VERSION, "tuty" );
	register_cvar( ".ESFSpecialAttacks_Version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY );
	
	register_event( "CurWeapon", "EVENT_CurWeapon", "be", "1!1" );
	register_event( "DeathMsg", "EVENT_DeathMessage", "a" );

	register_message( get_user_msgid( "DeathMsg" ), "MessageDeathWeaponName" );

	RegisterHam( Ham_TakeDamage, "player", "bacon_TakeDamage" );

	register_forward( FM_AddToFullPack, "forward_AddToFullPack", 1 );
	register_forward( FM_CmdStart, "forward_CmdStart" );
	register_forward( FM_EmitSound, "forward_EmitSound" );
	
	register_touch( gBodyPartEntity, "worldspawn", "ForwardBodyTouchGround" );
	register_touch( gBodyPartEntity, "player", "ForwardBodyTouchPlayer" );

	register_clcmd( ".ESFSpecialAttack", "CommandSpecialAttack" );
	register_clcmd( ".ESFSpecialHelp", "CommandShowHelp" );
	
	register_clcmd( "descend", "CommandBlock" );	
	register_clcmd( "ascend", "CommandBlock" );
	register_clcmd( "turbo", "CommandBlock" );
	register_clcmd( "+powerup", "CommandBlock" );

	register_clcmd( "togglefly", "CommandBlockFly" );
	register_clcmd( "teleport", "CommandBlockTeleport" );

	gMessageExplosion = get_user_msgid( "Explosion" );
	gMessageCharge = get_user_msgid( "Charge" );
	gMessagePowerUp = get_user_msgid( "Powerup" );
	gMessageStopPowerup = get_user_msgid( "StopPowerup" );
	gMessageBlob = get_user_msgid( "TransformFX" );
	gMessageScreenFade = get_user_msgid( "ScreenFade" );
	gMessageMaxHealth = get_user_msgid( "MaxHealth" );
	
	gMaxPlayers = get_maxplayers( );
	gHudSyncronizer = CreateHudSyncObj( );
}

public plugin_precache( )
{
	UTIL_CreateFakeWeaponEnt( );

	gSpriteShockwave = precache_model( "sprites/shockwave.spr" );
	gKaiokenTrail = precache_model( "sprites/ESFSpecials/kaiokentrail.spr" );
	gSpriteLight = precache_model( "sprites/lgtning.spr" );

	precache_model( gBodyPartSmallModel );
	precache_model( gKaiokenDragonModel );
	precache_model( gUlSacrificeModel );
	precache_model( gSdSphereModel );
	precache_model( gWhiteSphereModel );

	precache_sound( gSelfDestructionSound );
	precache_sound( gBodyPartSound );
	precache_sound( gBodyPartYeahSound );
	precache_sound( gUlSacrificeSound );
	precache_sound( gSuperKaiokenSound );
	precache_sound( gSwoopKaiokenSound );
	precache_sound( gSolarFlareSound );
	precache_sound( gTeleportSound );
	precache_sound( gWarpSound );
	precache_sound( gRegenerateSound );
	precache_sound( gRyukenSound );
	precache_sound( gGohanAngrySound );
	precache_sound( gGohanBlastSound );
	
	new i;

	for( i = 0; i < sizeof gTelekineseExplosionSounds; i++ )
	{
		precache_sound( gTelekineseExplosionSounds[ i ] );
	}
}

public plugin_cfg( )
{
	server_exec( );

	server_cmd( "mp_spawn_invulnerable_time 0.0" );
	server_cmd( "mp_gamemode 1" );
}

public client_connect( id )
{
	bSuperKaioken[ id ] = 0;
	bCurrentPL[ id ] = 0;
	bChargeKaioken[ id ] = 0;
	bUltimateSacrifice[ id ] = 0;
	bGlowGrownUp[ id ] = 0;
	bSolarFlareCharge[ id ] = 0;
	bGlowSolarFlare[ id ] = 0;
	bBodyPartCharge[ id ] = 0;
	bChargeTime[ id ] = 0;
	bSelfDestruct[ id ] = 0;
	bChangeAnimation[ id ] = 0;
	bHealingCharge[ id ] = 0;
	bTelekineseActivated[ id ] = 0;
	bAngryStarted[ id ] = 0;
	bUserTrapped[ id ] = 0;
	
	flSpecialUltimateDelay[ id ] = DELAY_RESET;
	flSpecialKaiokenDelay[ id ] = DELAY_RESET;
	flSpecialSolarDelay[ id ] = DELAY_RESET;
	flSpecialBodyPartDelay[ id ] = DELAY_RESET;
	flSpecialDestructDelay[ id ] = DELAY_RESET;
	flSpecialWarpDelay[ id ] = DELAY_RESET;
	flSpecialRegenerateDelay[ id ] = DELAY_RESET;
	flSpecialTelekinese[ id ] = DELAY_RESET;
	flSpecialAngryAttack[ id ] = DELAY_RESET;
}

public client_disconnect( id )
{
	bSuperKaioken[ id ] = 0;
	bCurrentPL[ id ] = 0;
	bChargeKaioken[ id ] = 0;
	bUltimateSacrifice[ id ] = 0;
	bGlowGrownUp[ id ] = 0;
	bSolarFlareCharge[ id ] = 0;
	bGlowSolarFlare[ id ] = 0;
	bBodyPartCharge[ id ] = 0;
	bChargeTime[ id ] = 0;
	bSelfDestruct[ id ] = 0;
	bChangeAnimation[ id ] = 0;
	bHealingCharge[ id ] = 0;
	bTelekineseActivated[ id ] = 0;
	bAngryStarted[ id ] = 0;
	bUserTrapped[ id ] = 0;
	
	UTIL_RemoveTasks( id );
	UTIL_StopPowerUp( id );
}

public EVENT_CurWeapon( id )
{
	if( pev( id, pev_playerclass ) == CLASS_GOKU
	&& bSuperKaioken[ id ] == 1 )
	{
		bSuperKaioken[ id ] = 0;
		set_rendering( id );
		remove_entity( bDragonHead[ id ] );
		
		UTIL_StopPowerUp( id );
		UTIL_SetClientPowerlevel( id, bCurrentPL[ id ] );
		UTIL_KillBeam( id );
	}
}

public bacon_TakeDamage( victim, inflictor, attacker, Float:damage, damagebits )
{
	if( !attacker || attacker > gMaxPlayers || inflictor == attacker || inflictor < gMaxPlayers )
	{ 
  		return HAM_IGNORED;
	}
	
	if( bSuperKaioken[ attacker ] != 1 && pev( attacker, pev_playerclass ) != CLASS_GOKU )
	{
		return HAM_IGNORED;
	}
	
	SetHamParamFloat( 4, damage * 3.0 );

	return HAM_HANDLED;
}

public forward_EmitSound( id, iChannel, const szSample[ ] )
{
	if( IsPlayer( id )
	&& bSuperKaioken[ id ] == 1
	&& pev( id, pev_playerclass ) == CLASS_GOKU
	&& ( equal( szSample, "weapons/swoop.wav" ) || equal( szSample, "weapons/chainswoop.wav" ) ) )
	{
		emit_sound( id, iChannel, gSwoopKaiokenSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public forward_CmdStart( id )
{
	if( is_user_alive( id ) 
	&& pev( id, pev_playerclass ) == CLASS_GOKU 
	&& bSuperKaioken[ id ] == 1
	&& UTIL_IsSwooping( id ) 
	&& !bWasSwoopingHuh[ id ] )
	{
		UTIL_DragonHead( id );
		bWasSwoopingHuh[ id ] = true;
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( TE_BEAMFOLLOW );
		write_short( id );
		write_short( gKaiokenTrail );
		write_byte( 10 );
		write_byte( 13 );
		write_byte( 255 );
		write_byte( 10 );
		write_byte( 10 );
		write_byte( 255 );
		message_end( );
	}
	
	else if( !UTIL_IsSwooping( id ) && bWasSwoopingHuh[ id ] && bSuperKaioken[ id ] == 1 )
	{
		remove_entity( bDragonHead[ id ] );
		set_rendering( id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 6 );

		bWasSwoopingHuh[ id ] = false;
		UTIL_KillBeam( id );
	}
}

public client_PostThink( id )
{
	if( is_user_alive( id ) 
	&& pev( id, pev_playerclass ) == CLASS_GOKU 
	&& bSuperKaioken[ id ] == 1 )
	{
		new iHealth = pev( id, pev_health );

		if( iHealth <= 6 )
		{
			bSuperKaioken[ id ] = 0;
			bChargeKaioken[ id ] = 0;

			set_rendering( id );
			remove_entity( bDragonHead[ id ] );
			
			UTIL_SetClientPowerlevel( id, bCurrentPL[ id ] );
			UTIL_KillBeam( id );
		}
		
		if( get_gametime( ) - flLastHealthToken[ id ] >= 1.0 )
		{
			flLastHealthToken[ id ] = get_gametime( );
			set_pev( id, pev_health, float( iHealth ) - 4.0 );
		}
	}
}

public ForwardBodyTouchGround( iEnt, iWorld )
{
	if( pev_valid( iEnt ) )
	{
		set_pev( iEnt, pev_flags, pev( iEnt, pev_flags ) | FL_KILLME );
	}
}

public ForwardBodyTouchPlayer( iEnt, iPlayer )
{
	if( pev_valid( iEnt ) )
	{
		new iOwner = pev( iEnt, pev_owner );
		
		new szName[ 40 ];
		get_user_name( iOwner, szName, charsmax( szName ) );
		
		if( UTIL_GetClientTeam( iOwner ) == UTIL_GetClientTeam( iPlayer ) )
		{
			return PLUGIN_HANDLED;
		}
		
		set_hudmessage( 255, 192, 203, -1.0, 0.77, 1, 6.0, 5.0 );
		ShowSyncHudMsg( iPlayer, gHudSyncronizer, ">>>[ ESF Specials ]<<<^n%s trapped you with < Body Part >!", szName );

		set_pev( iEnt, pev_flags, pev( iEnt, pev_flags ) | FL_KILLME );
		set_pev( iPlayer, pev_flags, pev( iPlayer, pev_flags ) | FL_FROZEN );
		
		bUserTrapped[ iPlayer ] = 1;
		
		new iParams[ 1 ];
		iParams[ 0 ] = iPlayer;

		emit_sound( iOwner, CHAN_VOICE, gBodyPartYeahSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		set_task( flBodyPartDuration, "RemoveTrapBody", iPlayer + TASK_BODYPART_DURATION, iParams, 1 );
	}
	
	return PLUGIN_HANDLED;
}

public MessageDeathWeaponName( )
{
	new id = get_msg_arg_int( 1 );

	new szWeapon[ 26 ];
	get_msg_arg_string( 3, szWeapon, charsmax( szWeapon ) );

	if( bSuperKaioken[ id ] == 1 )
	{
		if( equal( szWeapon, "melee", 5 ) )
		{
			set_msg_arg_string( 3, ">>>[ Ryuken ]<<<" );
			emit_sound( id, CHAN_VOICE, gRyukenSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
	}
	
	if( equal( szWeapon, "worldspawn", 10 ) )
	{
		set_msg_arg_string( 3, ">>>[ Class Change Menu ]<<<" );
	}
}

public forward_AddToFullPack( es_handle, e, id, host, hostflags, player, pSet )
{
	if( !player || !is_user_alive( id ) )
	{
		return FMRES_IGNORED;
	}

	if( bChargeKaioken[ id ] == 1 )
	{
		set_es( es_handle, ES_FrameRate, 2.0 );
		set_es( es_handle, ES_Sequence, 102 );
		set_es( es_handle, ES_GaitSequence, 102 );
	}
	
	if( bUltimateSacrifice[ id ] == 1 )
	{
		set_es( es_handle, ES_FrameRate, 0.5 );
		set_es( es_handle, ES_Sequence, 27 );
		set_es( es_handle, ES_GaitSequence, 27 );
	}
	
	if( bSolarFlareCharge[ id ] == 1 )
	{
		set_es( es_handle, ES_FrameRate, 0.3 );
		set_es( es_handle, ES_Sequence, 112 );
		set_es( es_handle, ES_GaitSequence, 112 );
	}
	
	if( bBodyPartCharge[ id ] == 1 )
	{
		set_es( es_handle, ES_FrameRate, 2.0 );
		set_es( es_handle, ES_Sequence, 204 );
		set_es( es_handle, ES_GaitSequence, 204 );
	}
	
	if( bSelfDestruct[ id ] == 1 )
	{
		set_es( es_handle, ES_FrameRate, 1.6 );
		set_es( es_handle, ES_Sequence, bChangeAnimation[ id ] );
		set_es( es_handle, ES_GaitSequence, bChangeAnimation[ id ] );
	}
	
	if( bHealingCharge[ id ] == 1 )
	{
		set_es( es_handle, ES_FrameRate, 1.0 );
		set_es( es_handle, ES_Sequence, 102 );
		set_es( es_handle, ES_GaitSequence, 102 );
	}
	
	if( bAngryStarted[ id ] == 1 )
	{
		set_es( es_handle, ES_FrameRate, 1.0 );
		set_es( es_handle, ES_Sequence, 116 );
		set_es( es_handle, ES_GaitSequence, 116 );
	}

	return FMRES_HANDLED;
}

public EVENT_DeathMessage( )
{
	new iVictim = read_data( 2 );
	
	UTIL_RemoveTasks( iVictim );
	set_rendering( iVictim );

	UTIL_SetProtect( iVictim, 0 );
	UTIL_Charge( iVictim, 0 );
	UTIL_StopPowerUp( iVictim );
	UTIL_SetClientPowerlevel( iVictim, bCurrentPL[ iVictim ] );

	bGlowSolarFlare[ iVictim ] = 0;
	bSolarFlareCharge[ iVictim ] = 0;
	bGlowSolarFlare[ iVictim ] = 0;
	bSuperKaioken[ iVictim ] = 0;
	bChargeTime[ iVictim ] = 0;
	bChargeKaioken[ iVictim ] = 0;
	bBodyPartCharge[ iVictim ] = 0;	
	bSelfDestruct[ iVictim ] = 0;
	bChangeAnimation[ iVictim ] = 0;
	bHealingCharge[ iVictim ] = 0;
	bTelekineseActivated[ iVictim ] = 0;
	bAngryStarted[ iVictim ] = 0;
	bUserTrapped[ iVictim ] = 0;
	
	new iFlags = pev( iVictim, pev_flags );
		
	if( iFlags & FL_FROZEN )
	{
		set_pev( iVictim, pev_flags, iFlags & ~FL_FROZEN );
	}
}

public CommandBlockTeleport( id )
{
	if( !is_user_alive( id ) || bChargeKaioken[ id ] == 1
	|| bUltimateSacrifice[ id ] == 1 || bSolarFlareCharge[ id ] == 1
	|| bBodyPartCharge[ id ] == 1 || bSelfDestruct[ id ] == 1 
	|| bHealingCharge[ id ] == 1 || bTelekineseActivated[ id ] == 1
	|| bAngryStarted[ id ] == 1 || bUserTrapped[ id ] == 1 )
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public CommandBlock( id )
{
	if( !is_user_alive( id ) || bChargeKaioken[ id ] == 1 || bSuperKaioken[ id ] == 1
	|| bUltimateSacrifice[ id ] == 1 || bSolarFlareCharge[ id ] == 1
	|| bBodyPartCharge[ id ] == 1 || bSelfDestruct[ id ] == 1 
	|| bHealingCharge[ id ] == 1 || bTelekineseActivated[ id ] == 1 
	|| bAngryStarted[ id ] == 1 || bUserTrapped[ id ] == 1 )
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public CommandBlockFly( id )
{
	if( !is_user_alive( id ) || bChargeKaioken[ id ] == 1
	|| bUltimateSacrifice[ id ] == 1 || bSolarFlareCharge[ id ] == 1
	|| bBodyPartCharge[ id ] == 1 || bSelfDestruct[ id ] == 1 
	|| bHealingCharge[ id ] == 1 || bTelekineseActivated[ id ] == 1
	|| bAngryStarted[ id ] == 1 || bUserTrapped[ id ] == 1 )
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public CommandShowHelp( id )
{
	const SIZE = 4024;
	static iMsg[ SIZE + 1 ], iLen = 0;

	iLen += formatex( iMsg[ iLen ], SIZE - iLen, ">>>[ ESF Special Attacks by tuty ]<<<^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, ">>>[ Y!M: tuty_max_boy@yahoo.com ]<<<^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "--------------------------------------------------------------------------^n^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "* First for all, if you want to use Special attacks, you must be in an ascended form!^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "* Every class have their own Special Attacks!^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "* You can't swoop, powerup, attack, descend during the Special Attack charge^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "* List of Special Attacks: *^n^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Vegeta: < Ultimate Sacrifice >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Make a explosion and kill every enemy alive including you!^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Add's frags for each killed enemy^n^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Goku: < Super Kaioken + Ryuken >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Triple damage, fast speed, powerlevel multiplied by x3^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Careful, kaioken eats a lot of health.^n^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Krillin: < Bloody Solar Flare >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "A super Solarflare blinds everyone alive on map and do %d damage. Will not affect other teammates^n^n", floatround( flSolarFlareDamage ) );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Buu: < Body Part >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Throw's a bodypart and trap enemy for %d seconds on touch^n^n", floatround( flBodyPartDuration ) );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Cell: < Self Destruction >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Like Vegeta's Ultimate Sacrifice!^n^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Trunks: < Warp >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Teleports closer to enemy, most of time behind enemy :)^n^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, " - Piccolo: < Regenerate >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Heal himself to max health possible in his form!^n^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Frieza: < Telekinese >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Grabs an enemy with invisible powers, and kill him after %d seconds^n^n", floatround( flTelekineseDuration ) );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "- Gohan: < Angry Blast >^n" );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "Make an angry attack and do %d damage to near enemies!^n", floatround( flAngryAttackDamage ) );
	iLen += formatex( iMsg[ iLen ], SIZE - iLen, "--------------------------------------------------------------------------^n" );
	
	show_motd( id, iMsg, ">>>[ Special Attacks Help ]<<<" );

	return PLUGIN_HANDLED;
}

public CommandSpecialAttack( id )
{
	if( !is_user_alive( id ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new iClass = pev( id, pev_playerclass );

	switch( iClass )
	{
		case CLASS_GOKU:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 
			|| bSuperKaioken[ id ] == 1 || bChargeKaioken[ id ] == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialKaiokenDelay[ id ] < flDelayTimeKaio )
			{
				set_hudmessage( 255, 0, 0, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Super Kaioken > again after %d seconds!", floatround( flSpecialKaiokenDelay[ id ] - get_gametime( ) + flDelayTimeKaio ) );
				
				return PLUGIN_HANDLED;
			}
			
			new iParams[ 2 ];
			iParams[ 1 ] = id;

			UTIL_SetProtect( id, 1 );
			bChargeKaioken[ id ] = 1;

			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
			UTIL_PowerUp( id, 255, 0, 0 );
	
			set_task( 1.0, "StartSuperKaioken", id + TASK_KAIOKEN_1, iParams, 2, "a", 5 );
			set_task( 5.0, "SuperKaiokenFx", id + TASK_KAIOKEN_2, iParams, 2 );
			set_task( 2.0, "StartBlob", id + TASK_KAIOKEN_3, iParams, 2, "a", 2 );
		}

		case CLASS_VEGETA:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bUltimateSacrifice[ id ] == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialUltimateDelay[ id ] < flDelayTimeUltimate )
			{
				set_hudmessage( 255, 127, 0, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Ultimate Sacrifice > again after %d seconds!", floatround( flSpecialUltimateDelay[ id ] - get_gametime( ) + flDelayTimeUltimate ) );
		
				return PLUGIN_HANDLED;
			}
			
			bUltimateSacrifice[ id ] = 1;

			UTIL_SetProtect( id, 1 );
			UTIL_PowerUp( id, 255, 127, 0 );

			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
			client_cmd( id, "cam_idealdist 220" );
	
			emit_sound( id, CHAN_VOICE, gUlSacrificeSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
			new iOrigin[ 3 ];
			get_user_origin( id, iOrigin );
	
			new iParams[ 4 ];

			iParams[ 0 ] = id;
			iParams[ 1 ] = iOrigin[ 0 ];
			iParams[ 2 ] = iOrigin[ 1 ];
			iParams[ 3 ] = iOrigin[ 2 ];

			set_task( 1.0, "GrowUpTheModel", id + TASK_ULSACRIFICE_1, iParams, 4, "a", 15 );
			set_task( 15.0, "UltimateSacrificeGo", id + TASK_ULSACRIFICE_2, iParams, 4 );
	
			flSpecialUltimateDelay[ id ] = get_gametime( );
		}
		
		case CLASS_KRILLIN:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bSolarFlareCharge[ id ] == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialSolarDelay[ id ] < flDelayTimeSolar )
			{
				set_hudmessage( 255, 255, 10, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Bloody Solar Flare > again after %d seconds!", floatround( flSpecialSolarDelay[ id ] - get_gametime( ) + flDelayTimeSolar ) );
		
				return PLUGIN_HANDLED;
			}
			
			bSolarFlareCharge[ id ] = 1;

			client_cmd( id, "weapon_solarflare" );
			UTIL_SetProtect( id, 1 );
			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
			
			new iParams[ 2 ];
			iParams[ 1 ] = id;
			
			set_task( 1.0, "SolarFlareCharge", id + TASK_SOLARFLARE_1, iParams, 2, "a", 4 );
			set_task( 4.0, "SolarFlareAttack", id + TASK_SOLARFLARE_2, iParams, 2 );
		}
		
		case CLASS_BUU:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bBodyPartCharge[ id ] == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialBodyPartDelay[ id ] < flDelayBodyPart )
			{
				set_hudmessage( 255, 192, 203, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Body Part > again after %d seconds!", floatround( flSpecialBodyPartDelay[ id ] - get_gametime( ) + flDelayBodyPart ) );
		
				return PLUGIN_HANDLED;
			}

			bBodyPartCharge[ id ] = 1;
	
			UTIL_SetProtect( id, 1 );
			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
	
			new iParams[ 2 ];
			iParams[ 1 ] = id;

			set_task( 1.0, "ChargeBodyPart", id + TASK_BODYPART_1, iParams, 2, "a", 4 );
			set_task( 6.0, "ThrowBodyPart", id + TASK_BODYPART_2, iParams, 2 );
			
			flSpecialBodyPartDelay[ id ] = get_gametime( );
		}
		
		case CLASS_CELL:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bSelfDestruct[ id ] == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialDestructDelay[ id ] < flDelayTimeUltimate )
			{
				set_hudmessage( 10, 199, 10, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Self Destruct > again after %d seconds!", floatround( flSpecialDestructDelay[ id ] - get_gametime( ) + flDelayTimeUltimate ) );
		
				return PLUGIN_HANDLED;
			}
			
			bSelfDestruct[ id ] = 1;
			bChangeAnimation[ id ] = 25;

			UTIL_SetProtect( id, 1 );
			UTIL_PowerUp( id, 10, 199, 10 );
			
			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
			client_cmd( id, "cam_idealdist 200" );
			
			emit_sound( id, CHAN_VOICE, gSelfDestructionSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			set_rendering( id, kRenderFxGlowShell, 10, 199, 10, kRenderNormal, 5 );
			
			new iOrigin[ 3 ], Float:flOrigin[ 3 ];

			get_user_origin( id, iOrigin );
			IVecFVec( iOrigin, flOrigin );
	
			UTIL_SelfDestructModel( id, flOrigin, 12.0, 100 );

			new iParams[ 2 ];
			iParams[ 1 ] = id;
			
			set_task( 6.0, "RemoveBallModel", id + TASK_SDESTRUCT_1, iParams, 2 );
			set_task( 1.0, "ChargeSelfDestruct", id + TASK_SDESTRUCT_2, iParams, 2, "a", 7 );
			set_task( 8.0, "SpecialSelfDestruct", id + TASK_SDESTRUCT_3, iParams, 2 );
			
			flSpecialDestructDelay[ id ] = get_gametime( );
		}
		
		case CLASS_TRUNKS:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialWarpDelay[ id ] < flDelayWarp )
			{
				set_hudmessage( 255, 255, 0, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Warp > again after %d seconds!", floatround( flSpecialWarpDelay[ id ] - get_gametime( ) + flDelayWarp ) );
		
				return PLUGIN_HANDLED;
			}

			ShowPlayerWarpMenu( id );
		}
		
		case CLASS_PICCOLO:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bHealingCharge[ id ] == 1
			|| get_user_health( id ) >= PICCOLO_ASCEND_MAXLIFE || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialRegenerateDelay[ id ] < flDelayRegenerate )
			{
				set_hudmessage( 255, 255, 255, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Regenerate > again after %d seconds!", floatround( flSpecialRegenerateDelay[ id ] - get_gametime( ) + flDelayRegenerate ) );
		
				return PLUGIN_HANDLED;
			}

			UTIL_SetProtect( id, 1 );
			bHealingCharge[ id ] = 1;
	
			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
			client_cmd( id, "cam_idealdist 100" );
			set_rendering( id, kRenderFxDistort, 0, 0, 0, kRenderTransAdd, 127 );

			new iOrigin[ 3 ];
			get_user_origin( id, iOrigin );
	
			new iParams[ 4 ];
	
			iParams[ 0 ] = id;
			iParams[ 1 ] = iOrigin[ 0 ];
			iParams[ 2 ] = iOrigin[ 1 ];
			iParams[ 3 ] = iOrigin[ 2 ];
	
			set_task( 1.0, "SpecialHealFX", id + TASK_HEAL_1, iParams, 4, "a", 15 );
			set_task( 15.0, "SpecialHeal", id + TASK_HEAL_2, iParams, 4 );
			
			emit_sound( id, CHAN_VOICE, gRegenerateSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			flSpecialRegenerateDelay[ id ] = get_gametime( );
		}
		
		case CLASS_FRIEZA:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialTelekinese[ id ] < flDelayTelekinese )
			{
				set_hudmessage( 255, 0, 255, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Telekinese > again after %d seconds!", floatround( flSpecialTelekinese[ id ] - get_gametime( ) + flDelayTelekinese ) );
		
				return PLUGIN_HANDLED;
			}

			new iTarget, iBody;
			get_user_aiming( id, iTarget, iBody );
	
			if( pev_valid( iTarget ) && UTIL_GetClientTeam( id ) != UTIL_GetClientTeam( iTarget ) )
			{
				set_rendering( iTarget, kRenderFxGlowShell, 224, 102, 255, kRenderNormal, 30 );
				set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) | FL_FROZEN );
		
				UTIL_SetProtect( iTarget, 1 );
				bTelekineseActivated[ iTarget ] = 1;
		
				new iParams[ 2 ];
		
				iParams[ 0 ] = id;
				iParams[ 1 ] = iTarget;
		
				set_task( flTelekineseDuration, "TelekineseKillPlayer", iTarget + TASK_TELEKINESE, iParams, 2 );
				flSpecialTelekinese[ id ] = get_gametime( );
			}
		}
		
		case CLASS_GOHAN:
		{
			if( UTIL_IsAscendedForm( id ) == 0 || UTIL_IsBusy( id ) == 1 || bAngryStarted[ id ] == 1 || bUserTrapped[ id ] == 1 )
			{
				return PLUGIN_HANDLED;
			}
			
			if( get_gametime( ) - flSpecialAngryAttack[ id ] < flDelayAngryBlast )
			{
				set_hudmessage( 155, 155, 155, -1.0, 0.77, 1, 6.0, 5.0 );
				ShowSyncHudMsg( id, gHudSyncronizer, ">>>[ ESF Specials ]<<<^nYou can use < Angry Blast > again after %d seconds!", floatround( flSpecialAngryAttack[ id ] - get_gametime( ) + flDelayAngryBlast ) );
		
				return PLUGIN_HANDLED;
			}

			bAngryStarted[ id ] = 1;
	
			new Float:flOrigin[ 3 ];
			pev( id, pev_origin, flOrigin );
	
			client_cmd( id, "cam_idealdist 180" );

			UTIL_WhiteSphere( id, flOrigin, 3.5 );
			UTIL_SetProtect( id, 1 );
	
			set_rendering( id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 8 );
			set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
			emit_sound( id, CHAN_VOICE, gGohanAngrySound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
			new iParams[ 2 ];
			iParams[ 1 ] = id;

			set_task( 1.0, "ChargeAngryBlast", id + TASK_ANGRYBLAST_1, iParams, 2, "a", 5 );
			set_task( 5.0, "ExecuteAngryAttack", id + TASK_ANGRYBLAST_2, iParams, 2 );
			
			flSpecialAngryAttack[ id ] = get_gametime( );
		}	
	}
	
	return PLUGIN_HANDLED;
}

public StartSuperKaioken( iParams[ ] )
{
	new id = iParams[ 1 ];
	
	set_rendering( id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 6 );
	bChargeTime[ id ] += 25;
	
	if( bChargeTime[ id ] >= 100 )
	{
		bChargeTime[ id ] = 100;
	}

	UTIL_Charge( id, bChargeTime[ id ] );
}

public SuperKaiokenFx( iParams[ ] )
{
	new id = iParams[ 1 ];
	
	UTIL_StopPowerUp( id );
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );
	emit_sound( id, CHAN_VOICE, gSuperKaiokenSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	new iPowerlevel = get_pdata_int( id , 460 );
	bCurrentPL[ id ] = iPowerlevel;

	bSuperKaioken[ id ] = 1;
	bChargeTime[ id ] = 0;
	bChargeKaioken[ id ] = 0;

	UTIL_SetProtect( id, 0 );
	UTIL_Charge( id, 0 );
	UTIL_SetClientPowerlevel( id, iPowerlevel * 3 );
	UTIL_StopPowerUp( id );

	flSpecialKaiokenDelay[ id ] = get_gametime( );
}

public StartBlob( iParams[ ] )
{
	new id = iParams[ 1 ];
	
	UTIL_BlobBackFx( id );
}

public GrowUpTheModel( iParams[ ] )
{
	new id = iParams[ 0 ];
	
	new Float:flOrigin[ 3 ];
	
	flOrigin[ 0 ] = float( iParams[ 1 ] );
	flOrigin[ 1 ] = float( iParams[ 2 ] );
	flOrigin[ 2 ] = float( iParams[ 3 ] );

	flSacrificeScale[ id ] += 1.1;
	bGlowGrownUp[ id ] += 9;
	bChargeTime[ id ] += 7;
	
	if( bChargeTime[ id ] >= 105 )
	{
		bChargeTime[ id ] = 105;
	}

	UTIL_Charge( id, bChargeTime[ id ] );
	set_rendering( id, kRenderFxGlowShell, 255, 127, 0, kRenderNormal, bGlowGrownUp[ id ] );
	
	remove_entity( bSacrificeMdl[ id ] );
	UTIL_SacrificeModel( id, flOrigin, flSacrificeScale[ id ] );
}

public UltimateSacrificeGo( iParams[ ] )
{
	new id = iParams[ 0 ];
	
	UTIL_SetProtect( id, 0 );
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );
	client_cmd( id, "cam_idealdist 40" );

	new iOrigin[ 3 ];

	iOrigin[ 0 ] = iParams[ 1 ];
	iOrigin[ 1 ] = iParams[ 2 ];
	iOrigin[ 2 ] = iParams[ 3 ];

	UTIL_Disc( iOrigin, 21000, 255, 127, 0 );
	UTIL_Disc( iOrigin, 17000, 255, 127, 0 );
	UTIL_Disc( iOrigin, 18000, 255, 127, 0 );
	UTIL_Disc( iOrigin, 19000, 255, 127, 0 );
	UTIL_Disc( iOrigin, 20000, 255, 127, 0 );

	UTIL_KillPlayers( id, gUltimateSacrificeEnt );
	UTIL_Explosion( id, 1000, EXPLOSION_COLOR_ORANGE );
	UTIL_StopPowerUp( id );

	ExecuteHam( Ham_TakeDamage, id, gUltimateSacrificeEnt, id, 9999.0, DMG_GENERIC );

	set_rendering( id );
	remove_entity( bSacrificeMdl[ id ] );
	UTIL_Charge( id, 0 );
	
	flSacrificeScale[ id ] = 0.0;
	bUltimateSacrifice[ id ] = 0;
	bGlowGrownUp[ id ] = 0;
	bChargeTime[ id ] = 0;
}

public SolarFlareCharge( iParams[ ] )
{
	new id = iParams[ 1 ];
	
	bGlowSolarFlare[ id ] += 4;
	bChargeTime[ id ] += 25;

	if( bChargeTime[ id ] >= 100 )
	{
		bChargeTime[ id ] = 100;
	}

	UTIL_Charge( id, bChargeTime[ id ] );
	set_rendering( id, kRenderFxGlowShell, 205, 10, 10, kRenderTransAdd, bGlowSolarFlare[ id ] );
}

public SolarFlareAttack( iParams[ ] )
{
	new id = iParams[ 1 ];
	
	UTIL_Charge( id, 0 );
	UTIL_SetProtect( id, 0 );
	set_rendering( id );

	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );
	emit_sound( id, CHAN_VOICE, gSolarFlareSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	bSolarFlareCharge[ id ] = 0;
	bGlowSolarFlare[ id ] = 0;
	bChargeTime[ id ] = 0;
	
	new i;

	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_alive( i ) && UTIL_GetClientTeam( i ) != UTIL_GetClientTeam( id ) )
		{
			ExecuteHam( Ham_TakeDamage, i, gBloodySolarFlareEnt, id, flSolarFlareDamage, DMG_BURN );
			
			UTIL_Implosion( i );
			UTIL_ScreenFade( i, 205, 10, 10, 255 );
		}
	}
	
	UTIL_ScreenFade( id, 205, 10, 10, 45 );
	flSpecialSolarDelay[ id ] = get_gametime( );
}

public ChargeBodyPart( iParams[ ] )
{
	new id = iParams[ 1 ];

	bChargeTime[ id ] += 25;
	
	if( bChargeTime[ id ] >= 100 )
	{
		bChargeTime[ id ] = 100;
	}
	
	UTIL_Charge( id, bChargeTime[ id ] );
	set_rendering( id, kRenderFxGlowShell, 255, 192, 203, kRenderNormal, 4 );
}

public ThrowBodyPart( iParams[ ] )
{
	new id = iParams[ 1 ];

	bBodyPartCharge[ id ] = 0;
	bChargeTime[ id ] = 0;

	set_rendering( id );
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );

	UTIL_SetProtect( id, 0 );
	UTIL_Charge( id, 0 );

	new Float:flOrigin[ 3 ], Float:flAngles[ 3 ];
	
	pev( id, pev_origin, flOrigin );
	pev( id, pev_v_angle, flAngles );
	
	new iEntity = create_entity( "info_target" );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEntity, pev_classname, gBodyPartEntity );

	engfunc( EngFunc_SetModel, iEntity, gBodyPartSmallModel );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -10.0, -10.0, -10.0 }, Float:{ 10.0, 10.0, 10.0 } );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_angles, flAngles );
	set_pev( iEntity, pev_solid, SOLID_BBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_framerate, 2.3 );
	set_pev( iEntity, pev_sequence, 0 );
	set_pev( iEntity, pev_owner, id );

	set_rendering( iEntity, kRenderFxGlowShell, 255, 192, 203, kRenderNormal, 4 );
	emit_sound( id, CHAN_AUTO, gBodyPartSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	new Float:flVelocity[ 3 ];
	velocity_by_aim( id, 1000, flVelocity );
	
	set_pev( iEntity, pev_velocity, flVelocity );

	return PLUGIN_HANDLED;
}

public RemoveTrapBody( iParams[ ] )
{
	new id = iParams[ 0 ];

	bUserTrapped[ id ] = 0;
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );
}

public ChargeSelfDestruct( iParams[ ] )
{
	new id = iParams[ 1 ];
	bChargeTime[ id ] += 13;
	
	if( bChargeTime[ id ] >= 104 )
	{
		bChargeTime[ id ] = 104;
	}

	UTIL_Charge( id, bChargeTime[ id ] );
}

public RemoveBallModel( iParams[ ] )
{
	new id = iParams[ 1 ];

	client_cmd( id, "cam_idealdist 40" );
	bChangeAnimation[ id ] = 27;

	remove_entity( bSelfDestructMdl[ id ] );
	
	new Float:flOrigin[ 3 ];
	pev( id, pev_origin, flOrigin );

	UTIL_SelfDestructModel( id, flOrigin, 1.5, 255 );
}

public SpecialSelfDestruct( iParams[ ] )
{
	new id = iParams[ 1 ];

	UTIL_SetProtect( id, 0 );
	UTIL_Charge( id, 0 );
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );

	new iOrigin[ 3 ];
	get_user_origin( id, iOrigin );

	UTIL_Disc( iOrigin, 21000, 10, 199, 10 );
	UTIL_Disc( iOrigin, 19000, 10, 199, 10 );
	UTIL_Disc( iOrigin, 20000, 10, 199, 10 );

	UTIL_KillPlayers( id, gSelfDestructEnt );
	UTIL_Explosion( id, 600, EXPLOSION_COLOR_GREEN );
	UTIL_StopPowerUp( id );
	
	ExecuteHam( Ham_TakeDamage, id, gSelfDestructEnt, id, 9999.0, DMG_GENERIC );

	remove_entity( bSelfDestructMdl[ id ] );

	set_rendering( id );
	bSelfDestruct[ id ] = 0;
	bChargeTime[ id ] = 0;
	bChangeAnimation[ id ] = 0;
}

public ShowPlayerWarpMenu( id )
{
	new menu = menu_create( ">>>[ Warp Closer To Enemy ]<<<", "menu_warp" );
		
	new i, idString[ 3 ];
	
	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_alive( i ) && id != i && UTIL_GetClientTeam( id ) != UTIL_GetClientTeam( i ) )
		{
			new szName[ 50 ];
			get_user_name( i, szName, charsmax( szName ) );
			
			num_to_str( i, idString, charsmax( idString ) );
			menu_additem( menu, szName, idString );
		}
	}

	menu_display( id, menu );
}

public menu_warp( id, menu, item )
{
	if( item >= 0 && UTIL_IsAscendedForm( id ) == 1 ) 
	{
		new access, callback, idString[ 3 ];		
		menu_item_getinfo( menu, item, access, idString, charsmax( idString ), _, _, callback );	
		
		new iTeamMate = str_to_num( idString );

		new Float:flLocation[ 3 ];
		pev( iTeamMate, pev_origin, flLocation );

		flLocation[ 0 ] -= 90.0;
		flLocation[ 1 ] += 0.1;
		
		UTIL_SetClientAiming( id, iTeamMate );
		set_pev( id, pev_origin, flLocation );

		emit_sound( id, CHAN_BODY, gTeleportSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		emit_sound( id, CHAN_VOICE, gWarpSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
		flSpecialWarpDelay[ id ] = get_gametime( );
	}
	
	menu_destroy( menu );

	return PLUGIN_HANDLED;	
}

public SpecialHealFX( iParams[ ] )
{
	new id = iParams[ 0 ];
	new iOrigin1[ 3 ], Float:flOrigin[ 3 ];
	
	iOrigin1[ 0 ] = iParams[ 1 ];
	iOrigin1[ 1 ] = iParams[ 2 ];
	iOrigin1[ 2 ] = iParams[ 3 ] + 8;

	IVecFVec( iOrigin1, flOrigin );
	bChargeTime[ id ] += 7;
	
	if( bChargeTime[ id ] >= 105 )
	{
		bChargeTime[ id ] = 105;
	}

	UTIL_Charge( id, bChargeTime[ id ] );
	UTIL_DrawSphere(  flOrigin );
	
	UTIL_Cylinder( iOrigin1, 115 );
	UTIL_Cylinder( iOrigin1, 155 );
	UTIL_Cylinder( iOrigin1, 225 );
	UTIL_Cylinder( iOrigin1, 255 );
	UTIL_Cylinder( iOrigin1, 335 );
	UTIL_Cylinder( iOrigin1, 355 );
	UTIL_Cylinder( iOrigin1, 445 );
	UTIL_Cylinder( iOrigin1, 555 );
	UTIL_Cylinder( iOrigin1, 655 );
	UTIL_Cylinder( iOrigin1, 755 );
}

public SpecialHeal( iParams[ ] )
{
	new id = iParams[ 0 ];
	
	bChargeTime[ id ] = 0;
	bHealingCharge[ id ] = 0;
	
	UTIL_BlobBackFx( id );
	UTIL_SetProtect( id, 0 );
	UTIL_Charge( id, 0 );
	
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );
	client_cmd( id, "cam_idealdist 40" );
	set_rendering( id );
	
	UTIL_SetMaxHealth( id, PICCOLO_ASCEND_MAXLIFE );
}

public TelekineseKillPlayer( iParams[ ]  )
{
	new iTarget = iParams[ 1 ];
	
	set_rendering( iTarget );
	set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) & ~FL_FROZEN );
	
	bTelekineseActivated[ iTarget ] = 0;
	UTIL_SetProtect( iTarget, 0 );
	UTIL_Explosion( iTarget, 150, EXPLOSION_COLOR_PURPLE );
	
	emit_sound( iTarget, CHAN_BODY, gTelekineseExplosionSounds[ random_num( 0, charsmax( gTelekineseExplosionSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	ExecuteHam( Ham_TakeDamage, iTarget, gTelekineseEnt, iParams[ 0 ], 9999.0, DMG_CRUSH );
}	

public ChargeAngryBlast( iParams[ ] )
{
	new id = iParams[ 1 ];
	
	bChargeTime[ id ] += 25;
	
	if( bChargeTime[ id ] >= 100 )
	{
		bChargeTime[ id ] = 100;
	}
	
	UTIL_Charge( id, bChargeTime[ id ] );
}

public ExecuteAngryAttack( iParams[ ] )
{
	new id = iParams[ 1 ];
	
	new iOrigin[ 3 ];
	get_user_origin( id, iOrigin );
	
	bAngryStarted[ id ] = 0;
	bChargeTime[ id ] = 0;
	
	set_rendering( id );
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );

	client_cmd( id, "cam_idealdist 40" );
	remove_entity( bAngryBlastMdl[ id ] );
	
	UTIL_SetProtect( id, 0 );
	UTIL_Charge( id, 0 );
	
	UTIL_AngryAttack( id, flAngryAttackRadius, flAngryAttackDamage );
	UTIL_Explosion( id, 200, EXPLOSION_COLOR_WHITE );
	
	UTIL_Disc( iOrigin, 700, 255, 255, 255 ); 
	UTIL_Disc( iOrigin, 800, 255, 255, 255 ); 
	UTIL_Disc( iOrigin, 900, 255, 255, 255 ); 
	UTIL_Disc( iOrigin, 1000, 255, 255, 255 ); 
	
	emit_sound( id, CHAN_VOICE, gGohanBlastSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
}
		


/*
	===========================================
	*	Stocks Area 
	*	Some stocks made by me!
	*	Some stocks by other amxx coders
	===========================================
*/

stock UTIL_CreateFakeWeaponEnt( )
{
	gUltimateSacrificeEnt = create_entity( "info_target" );
	set_pev( gUltimateSacrificeEnt, pev_classname, ">>>[ Ultimate Sacrifice ]<<<" );
	
	gBloodySolarFlareEnt = create_entity( "info_target" );
	set_pev( gBloodySolarFlareEnt, pev_classname, ">>>[ Bloody Solar Flare ]<<<" );
	
	gSelfDestructEnt = create_entity( "info_target" );
	set_pev( gSelfDestructEnt, pev_classname, ">>>[ Self Destruct ]<<<" );
	
	gTelekineseEnt = create_entity( "info_target" );
	set_pev( gTelekineseEnt, pev_classname, ">>>[ Telekinese ]<<<" );

	gAngryBlastEnt = create_entity( "info_target" );
	set_pev( gAngryBlastEnt, pev_classname, ">>>[ Angry Blast ]<<<" );
}
	
stock UTIL_SacrificeModel( id, Float:flOrigin[ 3 ], Float:flScale )
{
	bSacrificeMdl[ id ] = create_entity( "env_model" );

	set_pev( bSacrificeMdl[ id ], pev_classname, "ESFUltimateSacrifice" );
	engfunc( EngFunc_SetModel, bSacrificeMdl[ id ], gUlSacrificeModel );
	entity_set_origin( bSacrificeMdl[ id ], flOrigin );
	set_pev( bSacrificeMdl[ id ], pev_solid, SOLID_NOT ); 
	set_pev( bSacrificeMdl[ id ], pev_movetype, MOVETYPE_FLY );
	set_pev( bSacrificeMdl[ id ], pev_scale, flScale );
	set_pev( bSacrificeMdl[ id ], pev_framerate, 1.0 );
	set_pev( bSacrificeMdl[ id ], pev_sequence, 0 );
	set_rendering( bSacrificeMdl[ id ], kRenderFxNone, 255, 127, 0, kRenderTransAdd, 39 );
	set_rendering( bSacrificeMdl[ id ], kRenderFxGlowShell, 255, 127, 0, kRenderNormal, 5 );

	DispatchSpawn( bSacrificeMdl[ id ] );
}

stock UTIL_SelfDestructModel( id, Float:flOrigin[ 3 ], Float:flScale, iThickness )
{
	bSelfDestructMdl[ id ] = create_entity( "env_model" );

	set_pev( bSelfDestructMdl[ id ], pev_classname, "ESFSelfDestruction" );
	engfunc( EngFunc_SetModel, bSelfDestructMdl[ id ], gSdSphereModel );
	entity_set_origin( bSelfDestructMdl[ id ], flOrigin );
	set_pev( bSelfDestructMdl[ id ], pev_solid, SOLID_NOT ); 
	set_pev( bSelfDestructMdl[ id ], pev_movetype, MOVETYPE_FLY );
	set_pev( bSelfDestructMdl[ id ], pev_scale, flScale );
	set_pev( bSelfDestructMdl[ id ], pev_framerate, 1.0 );
	set_pev( bSelfDestructMdl[ id ], pev_sequence, 0 );
	set_rendering( bSelfDestructMdl[ id ], kRenderFxNone, 0, 255, 0, kRenderTransAdd, iThickness );
	
	DispatchSpawn( bSelfDestructMdl[ id ] );
}

stock UTIL_WhiteSphere( id, Float:flOrigin[ 3 ], Float:flScale )
{
	bAngryBlastMdl[ id ] = create_entity( "env_model" );

	set_pev( bAngryBlastMdl[ id ], pev_classname, "ESFAngryBlast" );
	engfunc( EngFunc_SetModel, bAngryBlastMdl[ id ], gWhiteSphereModel );
	entity_set_origin( bAngryBlastMdl[ id ], flOrigin );
	set_pev( bAngryBlastMdl[ id ], pev_solid, SOLID_NOT ); 
	set_pev( bAngryBlastMdl[ id ], pev_movetype, MOVETYPE_FLY );
	set_pev( bAngryBlastMdl[ id ], pev_scale, flScale );
	set_rendering( bAngryBlastMdl[ id ], kRenderFxGlowShell, 255, 255, 255, kRenderTransAdd, 80 );

	DispatchSpawn( bAngryBlastMdl[ id ] );
}

stock UTIL_Explosion( id, iRadius, iColor )
{
	new iOrigin[ 3 ];
	get_user_origin( id, iOrigin );

	message_begin( MSG_ALL, gMessageExplosion, _, id ); 
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] ); 
	write_long( iRadius );
	write_byte( iColor ); 
	message_end( );
}

stock UTIL_AngryAttack( id, Float:flRadius, Float:flDamage )
{
	new Float:flEntityOrigin[ 3 ];
    	pev( id, pev_origin, flEntityOrigin );
    
    	new iClient = FM_NULLENT, Float:flClientOrigin[ 3 ], Float:flDistance;

    	while( ( iClient = engfunc( EngFunc_FindEntityInSphere, iClient, flEntityOrigin, flRadius ) ) )
    	{
		if( IsPlayer( iClient ) && is_user_alive( iClient ) && UTIL_GetClientTeam( id ) != UTIL_GetClientTeam( iClient ) )
		{
			pev( iClient, pev_origin, flClientOrigin );
       			flDistance = get_distance_f( flEntityOrigin, flClientOrigin );

			if( flDistance <= flRadius )
			{
       				ExecuteHam( Ham_TakeDamage, iClient, gAngryBlastEnt, id, flDamage, DMG_BLAST );
			}
    		}
	}
}

stock UTIL_SetProtect( id, iStatus )
{
	if( iStatus == 1 )
	{
		set_pdata_int( id, 301, 1, -89 );
	}
	
	else if( iStatus == 0 )
	{
		set_pdata_int( id, 301, 0, -89 );
	}
}

stock UTIL_RemoveTasks( id )
{
	remove_task( id + TASK_KAIOKEN_1 );
	remove_task( id + TASK_KAIOKEN_2 );
	remove_task( id + TASK_KAIOKEN_3 );
	remove_task( id + TASK_ULSACRIFICE_1 );
	remove_task( id + TASK_ULSACRIFICE_2 );
	remove_task( id + TASK_SOLARFLARE_1 );
	remove_task( id + TASK_SOLARFLARE_2 );
	remove_task( id + TASK_BODYPART_1 );
	remove_task( id + TASK_BODYPART_2 );
	remove_task( id + TASK_SDESTRUCT_1 );
	remove_task( id + TASK_SDESTRUCT_2 );
	remove_task( id + TASK_SDESTRUCT_3 );
	remove_task( id + TASK_HEAL_1 );
	remove_task( id + TASK_HEAL_2 );
	remove_task( id + TASK_TELEKINESE );
	remove_task( id + TASK_ANGRYBLAST_1 );
	remove_task( id + TASK_ANGRYBLAST_2 );
	remove_task( id + TASK_BODYPART_DURATION );
}

stock UTIL_Disc( iOrigin[ 3 ], iRadius, iRed, iGreen, iBlue )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMTORUS );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + iRadius );
	write_short( gSpriteShockwave );
	write_byte( 0 );
	write_byte( 1 );
	write_byte( 20 );
	write_byte( 50 ); 
	write_byte( 1 ); 
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );  
	write_byte( 155 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_KillPlayers( id, iFakeWeaponEntity )
{
	new i;

	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_alive( i ) && UTIL_GetClientTeam( id ) != UTIL_GetClientTeam( i ) )
		{
			ExecuteHam( Ham_TakeDamage, i, iFakeWeaponEntity, id, 9999.0, DMG_GENERIC );
		}
	}
}

stock UTIL_IsAscendedForm( id )
{
	new iPlayerModel[ 50 ];
	get_user_info( id, "model", iPlayerModel, charsmax( iPlayerModel ) );

	switch( pev( id, pev_playerclass ) )
	{
		case CLASS_BUU:
		{
			if( equal( iPlayerModel, "evilbuu" ) )
			{
				return 1;
			}
		}
		
		case CLASS_GOKU:
		{
			if( equal( iPlayerModel, "ssjgoku" ) )
			{
				return 1;
			}
		}
		
		case CLASS_GOHAN:
		{
			if( equal( iPlayerModel, "ssjgohan" ) )
			{
				return 1;
			}
		}
		
		case CLASS_KRILLIN:
		{
			if( equal( iPlayerModel, "krillin2" ) )
			{
				return 1;
			}
		}
		
		case CLASS_FRIEZA:
		{
			if( equal( iPlayerModel, "frieza2" ) )
			{
				return 1;
			}
		}
		
		case CLASS_PICCOLO:
		{
			if( equal( iPlayerModel, "piccolo2" ) )
			{
				return 1;
			}
		}
		
		case CLASS_TRUNKS:
		{
			if( equal( iPlayerModel, "ssjtrunks" ) )
			{
				return 1;
			}
		}
		
		case CLASS_VEGETA:
		{
			if( equal( iPlayerModel, "ssjvegeta" ) )
			{
				return 1;
			}
		}
		
		case CLASS_CELL:
		{
			if( equal( iPlayerModel, "cell2" ) )
			{
				return 1;
			}
		}
	}
	
	return 0;
}

stock UTIL_Charge( index, value )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageCharge, _, index );
	write_byte( value );
	message_end( );
}

stock UTIL_PowerUp( index, iRed, iGreen, iBlue )
{
	message_begin( MSG_ALL, gMessagePowerUp, _, index );
	write_byte( index );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	message_end( );
}

stock UTIL_StopPowerUp( index )
{
	message_begin( MSG_ALL, gMessageStopPowerup, _, index );	
	write_byte( 1 );
	message_end( );
}

stock UTIL_IsBusy( id )
{
	if( get_pdata_int( id, 459 ) == 0 	// Speed
	|| get_pdata_int( id, 462 ) == 0 	// Speed
	|| get_pdata_int( id, 196 )	 	// Turbo
	|| get_pdata_int( id, 198 )		// Attack Block
	|| get_pdata_int( id, 199 )		// Powerup
	|| get_pdata_int( id, 200 )		// Attack Charge
	|| get_pdata_int( id, 230 )		// Player is throw away		
	|| get_pdata_int( id, 300 )		// Throw
	|| get_pdata_int( id, 298 )		// Advanced Melee
	|| get_pdata_int( id, 317 )		// Swooping
	|| get_pdata_int( id, 464 ) == 0	// Shooting Attack
	|| get_pdata_int( id, 27 ) == 0		// Falling down
	|| pev( id, pev_health ) < 6.0 		// Hp less then 6 meaning KI is losing
	|| pev( id, pev_movetype ) == 15 )	// Beam Jump 
	{
		return 1;			// So client is busy with something
	}
	
	return 0;				// Client is not busy, is ok.
}

stock UTIL_SetClientPowerlevel( index, powerlevel )
{
	set_pdata_int( index, 460, powerlevel );
}

stock UTIL_IsSwooping( index )
{
	return get_pdata_int( index, 317, 5 );
}

stock UTIL_DragonHead( id )
{
	bDragonHead[ id ] = create_entity( "env_model" );

	engfunc( EngFunc_SetModel, bDragonHead[ id ], gKaiokenDragonModel );
	set_pev( bDragonHead[ id ], pev_movetype, MOVETYPE_FOLLOW );
	set_pev( bDragonHead[ id ], pev_aiment, id );
	set_rendering( bDragonHead[ id ], kRenderFxNone, 255, 10, 10, kRenderTransAdd, 63 );
}

stock UTIL_KillBeam( id )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_KILLBEAM );
	write_short( id );
	message_end( );
}

stock UTIL_BlobBackFx( index )
{
	message_begin( MSG_ALL, gMessageBlob, _, index );
	write_byte( index );
	write_coord( -1 );
	message_end( );
}

stock UTIL_ScreenFade( index, iRed, iGreen, iBlue, iAlpha )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade, _, index );
        write_short( UTIL_FixedUnsigned16( 10.0, 1<<12 ) );
        write_short( UTIL_FixedUnsigned16( 10.0, 1<<12 ) );
        write_short( FFADE_IN );
        write_byte( iRed );
        write_byte( iGreen );  
        write_byte( iBlue );  
        write_byte( iAlpha );
        message_end( ); 
}

stock UTIL_Implosion( index )
{
	new iOrigin[ 3 ];
	get_user_origin( index, iOrigin, 0 );

	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
        write_byte( TE_IMPLOSION );
        write_coord( iOrigin[ 0 ] );
        write_coord( iOrigin[ 1 ] );
        write_coord( iOrigin[ 2 ] );
        write_byte( 255 );
        write_byte( 255 );
        write_byte( 20 );
        message_end( );
}

stock UTIL_FixedUnsigned16( Float:flValue, iScale )
{
	new iOutput = floatround( flValue * iScale );

	if( iOutput < 0 )
	{
		iOutput = 0;
	}

	if( iOutput > 0xFFFF )
	{
		iOutput = 0xFFFF;
	}

	return iOutput;
}

stock UTIL_GetClientTeam( index )
{
	new szTeamName[ 2 ];
	get_user_team( index, szTeamName, charsmax( szTeamName ) );

	switch( szTeamName[ 0 ] )
	{
		case 'G': return 1; 
		case 'E': return 2;
	}

	return 0;
}

stock UTIL_SetMaxHealth( id, health )
{
	set_pev( id, pev_health, float( health ) );
	
	message_begin( MSG_ONE_UNRELIABLE, gMessageMaxHealth, _, id );
	write_byte( health );
	message_end( );
}

stock UTIL_Cylinder( iOrigin[ 3 ], iRadius )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[ 0 ] ); 
	write_coord( iOrigin[ 1 ] ); 
	write_coord( iOrigin[ 2 ] ); 
	write_coord( iOrigin[ 0 ] ); 
	write_coord( iOrigin[ 1 ] ); 
	write_coord( iOrigin[ 2 ] + iRadius ); 
	write_short( gSpriteShockwave ); 
	write_byte( 0 );
	write_byte( 0 ); 
	write_byte( 4 ); 
	write_byte( 16 );
	write_byte( 0 );
	write_byte( 188 ); 
	write_byte( 220 );
	write_byte( 255 ); 
	write_byte( 30 ); 
	write_byte( 0 ); 
	message_end( );
}

stock UTIL_DrawSphere( Float:origin[ 3 ] )
{
	new i, j;
    	for( i = 0; i < 5; i++ )
    	{
        	for( j = 0; j < 10; j++ )
        	{
            		static Float:flAngleVector[ 3 ], Float:flRadialVector[ 3 ];

            		flAngleVector[ 0 ] = ( 180.0 / 5 * i ) - 90.0;
            		flAngleVector[ 1 ] = ( 360.0 / 10 * j ) - 180.0;

            		angle_vector( flAngleVector, ANGLEVECTOR_FORWARD, flRadialVector );

           		flRadialVector[ 0 ] = flRadialVector[ 0 ] * 90.0 + origin[ 0 ];
            		flRadialVector[ 1 ] = flRadialVector[ 1 ] * 90.0 + origin[ 1 ];
            		flRadialVector[ 2 ] = flRadialVector[ 2 ] * 90.0 + origin[ 2 ];

            		UTIL_DrawBeam( origin, flRadialVector );
		}
	}
}

stock UTIL_DrawBeam( Float:start[ 3 ], Float:end[ 3 ] )
{
	engfunc( EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, start, 0 );
	write_byte( TE_BEAMPOINTS );
	engfunc( EngFunc_WriteCoord, start[ 0 ] );
	engfunc( EngFunc_WriteCoord, start[ 1 ] );
	engfunc( EngFunc_WriteCoord, start[ 2 ] );
	engfunc( EngFunc_WriteCoord, end[ 0 ] );
	engfunc( EngFunc_WriteCoord, end[ 1 ] );
	engfunc( EngFunc_WriteCoord, end[ 2 ] );
	write_short( gSpriteLight );
	write_byte( 2 );
	write_byte( 9 );
	write_byte( 15 ); 
	write_byte( 8 );
	write_byte( 4 );
	write_byte( 10 );
	write_byte( 244 );
	write_byte( 10 );
	write_byte( 170 );
	write_byte( 15 );
	message_end( );
}

/* --| Thanks to Lord of Destruction */

stock Float:UTIL_Distance2D( Float:X, Float:Y )
{
	return floatsqroot( ( X * X ) + ( Y * Y ) );
}

stock Float:UTIL_Radian2Degree( Float:Radian )
{
	return Radian * 360.0 / ( 2 * M_PI );
}

stock UTIL_SetClientAiming( CoreID, TargetID, Float:AimOffset[ 2 ] = { 0.0, 0.0 }, Float:TargetOffset[ 3 ] = { 0.0, 0.0, 0.0 } )
{
	new Float:CoreAngles[ 3 ] = { 0.0, 0.0, 0.0 };
	
	new Float:CoreOrigin[ 3 ];
	pev( CoreID, pev_origin, CoreOrigin );
	
	new Float:TargetOrigin[ 3 ];
	pev( TargetID, pev_origin, TargetOrigin );
	
	new Float:TargetAngles[ 3 ];
	pev( TargetID, pev_angles, TargetAngles );
	
	new anglemode:Mode = degrees;

	TargetOrigin[ 0 ] += TargetOffset[ 0 ] * floatsin( TargetAngles[ 1 ], Mode );
	TargetOrigin[ 1 ] += TargetOffset[ 1 ] * floatcos( TargetAngles[ 1 ], Mode );
	TargetOrigin[ 2 ] += TargetOffset[ 2 ];
	
	new Float:DeltaOrigin[ 3 ];
	for( new i = 0; i < 3; i++ )
	{
		DeltaOrigin[ i ] = CoreOrigin[ i ] - TargetOrigin[ i ];
	}

	CoreAngles[ 0 ] = UTIL_Radian2Degree( floatatan( DeltaOrigin[ 2 ] / UTIL_Distance2D( DeltaOrigin[ 0 ], DeltaOrigin[ 1 ] ), 0 ) );
	CoreAngles[ 0 ] += AimOffset[ 1 ];
	
	CoreAngles[ 1 ] = UTIL_Radian2Degree( floatatan( DeltaOrigin[ 1 ] / DeltaOrigin[ 0 ], 0 ) ) + AimOffset[ 0 ];
	CoreAngles[ 1 ] += AimOffset[ 0 ];
	
	( DeltaOrigin[ 0 ] >= 0.0 ) ? ( CoreAngles[ 1 ] += 180.0 ) : ( CoreAngles[ 1 ] += 0.0 );
	
	set_pev( CoreID, pev_angles, CoreAngles );
	set_pev( CoreID, pev_fixangle, 1 );
	
	return 1;
}

/* 
	
	=================================================

	End of code: oops that was a little bit hard xD!
	
	=================================================

*/
