
#include < amxmodx >

#include < fakemeta >
#include < fun >
#include < hamsandwich >
#include < cstrike >
#include < engine >
#include < xs >

#include < colorchat >

#pragma semicolon 1

#define PLUGIN_VERSION			"1.0.1"
#define MAX_PLAYERS			32 + 1
#define HUD_MAX_TIME			0.4
#define FFADE_IN 			0x0000
#define GIB_ALWAYS			2

#define PREDATOR_IDLE_DELAY		30.0
#define PREDATOR_CLOAK_DELAY		1.5
#define PREDATOR_DISK_DELAY 		15.0
#define PREDATOR_DIRTPOUND_DELAY	30.0
#define PREDATOR_HIGHJUMP_DELAY		6.0
#define PREDATOR_PLASMA_DELAY		2.0

#define PREDATOR_DIRTPOUND_RADIUS	400	

#define PREDATOR_YELLOW_BLOOD		111

#define PREDA_NO			0
#define PREDA_YES			1

#define NORMAL_VISION			0
#define INFRARED_VISION			1
#define ULTRAVIOLET_VISION		2
#define TEAM_VISION			3
#define NIGHT_VISION			4

#define DISABLED			0
#define	ENABLED				1

new const gPluginTag[ ] = "[Predator]";

new const gDiskClassname[ ] = "PredatorDisk";
new const gPlasmaClassname[ ] = "PredatorPlasmaBeam";

new const gPredatorPlayerModel[ ] = "predator";
new const gPredatorClaws[ ] = "models/v_predator_hands.mdl";
new const gPredatorDiskModel[ ] = "models/predator_disk.mdl";
new const gPlasmaModelSprite[ ] = "sprites/plasma.spr";

new const gPredatorCloakSound[ ] = "items/suitchargeno1.wav";
new const gDiskHitSound[ ] = "weapons/cbar_hit2.wav";
new const gDiskShootSound[ ] = "x/x_shoot1.wav";

new const gPlasmaHitSound[ ] = "predator/plasma_explosion.wav";
new const gPlasmaShootSound[ ] = "predator/predator_plasmafire.wav";
new const gPredatorTransform[ ] = "predator/predator_growl.wav";
new const gPredatorGibScream[ ] = "predator/predator_scream.wav";
new const gPredatorDirtpound[ ] = "predator/predator_dirtpound.wav";
new const gPredatorVisionchange[ ] = "predator/predator_visionchange.wav";

new const gPredatorDieSounds[ ][ ] =
{
	"predator/predator_die.wav",
	"predator/predator_die2.wav",
	"predator/predator_die3.wav",
	"predator/predator_die4.wav"
};

new const gPredatorIdleSounds[ ][ ] =
{
	"predator/predator_idle.wav",
	"predator/predator_idle2.wav",
	"predator/predator_idle3.wav"
};

new const gPredatorDamageSounds[ ][ ] =
{
	"predator/predator_damage1.wav",
	"predator/predator_damage2.wav",
	"predator/predator_damage3.wav"
};

new const gBlockWeaponsPickup[ ][ ] = 
{
	"weaponbox",
	"weapon_shield",
	"armoury_entity"
};

new gBuyCommands[ ][ ] =  
{ 
	"usp", "glock", "deagle", "p228", "elites", "fn57", "m3", "xm1014", "mp5", "tmp", "p90", "mac10", "ump45", "ak47",  
	"galil", "famas", "sg552", "m4a1", "aug", "scout", "awp", "g3sg1", "sg550", "m249", "vest", "vesthelm", "flash", "hegren", 
	"sgren", "defuser", "nvgs", "shield", "primammo", "secammo", "km45", "9x19mm", "nighthawk", "228compact", "12gauge", 
	"autoshotgun", "smg", "mp", "c90", "cv47", "defender", "clarion", "krieg552", "bullpup", "magnum", "d3au1", "krieg550", 
	"buyammo1", "buyammo2", "autobuy", "rebuy", "cl_autobuy", "cl_setautobuy", "cl_rebuy", "cl_setrebuy"
};

new gRadioCommands[ ][ ] =
{
	"radio1", "radio2", "radio3"
};

new i;
new gMaxPlayers;
new gHudSync;
new gHudSync2;
new gMessageScreenFade;
new gMessageScreenShake;
new gHitDecal;
new gHitDecal2;
new gShockWaveSprite;
new gExplosionSprite;
new gLaserBeam;
new gPlasmaWeapon;
new gDritWeapon;

new gCvarPredatorCost;
new gCvarPredatorFragCost;
new gCvarPredatorHealth;
new gCvarPredatorArmor;
new gCvarPredatorSpeed;
new gCvarPredatorGravity;
new gCvarPredatorDirtpoundDmg;
new gCvarPredatorDisks;
new gCvarPredatorPlasmas;
new gCvarPredatorAutomenu;
new gCvarPredatorPlasmaDmg;
new gCvarPredatorPlasmaRadius;
new gCvarPredatorCloakPercent;

new bPredatorDisks[ MAX_PLAYERS ];
new bPredatorVision[ MAX_PLAYERS ];
new bIsUserPredator[ MAX_PLAYERS ];
new bPredatorCloak[ MAX_PLAYERS ];
new bPredatorPlasma[ MAX_PLAYERS ];

new gVisionString[ MAX_PLAYERS ][ 30 ];

new Float:flLastDisk[ MAX_PLAYERS ];
new Float:flLastDirtpound[ MAX_PLAYERS ];
new Float:flLastCloak[ MAX_PLAYERS ];
new Float:flLastIdleSound[ MAX_PLAYERS ];
new Float:flLastHud[ MAX_PLAYERS ];
new Float:flLastHighJump[ MAX_PLAYERS ];
new Float:flLastPlasma[ MAX_PLAYERS ];

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

public plugin_init( )
{
	register_plugin( "Tuty's Predator", PLUGIN_VERSION, "tuty" );
	
	register_clcmd( "say /predator", "CommandBuyPredator" );
	register_clcmd( "say_team /predator", "CommandBuyPredator" );

	register_clcmd( "nightvision", "CommandPredatorVision" );
	register_clcmd( "drop", "CommandShootDisk" );
	
	register_event( "CurWeapon", "Hook_CurWeapon", "be", "1=1" );
	register_logevent( "Log_RoundEnd", 2, "1=Round_End" );
	register_logevent( "Log_RoundStart", 2, "1=Round_Start" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_Spawned", 1 );
	RegisterHam( Ham_Killed, "player", "bacon_Killed" );
	RegisterHam( Ham_TakeDamage, "player", "bacon_TakeDamage" );
	RegisterHam( Ham_Player_ResetMaxSpeed, "player", "bacon_ResetMaxSpeed", 1 );
	RegisterHam( Ham_Player_PreThink, "player", "bacon_PreThink" );
	RegisterHam( Ham_TraceAttack, "worldspawn", "bacon_TraceAttack", 1 );
	RegisterHam( Ham_TraceAttack, "player", "bacon_TraceAttack", 1 );
	RegisterHam( Ham_BloodColor, "player", "bacon_BloodColor" );
	
	for( i = 0; i < sizeof gBlockWeaponsPickup; i++ )
	{
		RegisterHam( Ham_Touch, gBlockWeaponsPickup[ i ], "bacon_Touch" );
	}
	
	for( i = 0; i < sizeof gBuyCommands; i++ )
	{
		register_clcmd( gBuyCommands[ i ], "CommandBuy" );
	}
	
	for( i = 0; i < sizeof gRadioCommands; i++ )
	{
		register_clcmd( gRadioCommands[ i ], "BlockRadio" );
	}

	register_forward( FM_EmitSound, "forward_EmitSound" );
	register_forward( FM_AddToFullPack, "forward_AddToFullPack_Post", 1 );
	register_forward( FM_CmdStart, "forward_CmdStart" );
	
	register_impulse( 201, "forward_Spray" );
	register_impulse( 100, "forward_Flashlight" );

	register_think( gDiskClassname, "forward_DiskThink" );

	register_touch( gDiskClassname, "worldspawn", "forward_DiskTouchWorld" );
	register_touch( gDiskClassname, "player", "forward_DiskKill" );
	register_touch( gPlasmaClassname, "*", "forward_PlasmaDoDamage" );
	
	gCvarPredatorCost = register_cvar( "predator_cost", "800" );
	gCvarPredatorFragCost = register_cvar( "predator_frag_cost", "0" );
	gCvarPredatorHealth = register_cvar( "predator_health", "300" );
	gCvarPredatorArmor = register_cvar( "predator_armor", "500" );
	gCvarPredatorSpeed = register_cvar( "predator_speed", "500" );
	gCvarPredatorGravity = register_cvar( "predator_gravity", "0.5" );
	gCvarPredatorDirtpoundDmg = register_cvar( "predator_dirtpound_dmg", "15" );
	gCvarPredatorPlasmaDmg = register_cvar( "predator_plasma_dmg", "40" );
	gCvarPredatorDisks = register_cvar( "predator_disks", "3" );
	gCvarPredatorPlasmas = register_cvar( "predator_plasmas", "3" );
	gCvarPredatorPlasmaRadius = register_cvar( "predator_plasma_radius", "160" );
	gCvarPredatorAutomenu = register_cvar( "predator_automenu", "1" );
	gCvarPredatorCloakPercent = register_cvar( "predator_cloak_percent", "7" );

	gMaxPlayers = get_maxplayers( );
	gHudSync = CreateHudSyncObj( );
	gHudSync2 = CreateHudSyncObj( );

	gMessageScreenFade = get_user_msgid( "ScreenFade" );
	gMessageScreenShake = get_user_msgid( "ScreenShake" );
}

public plugin_precache( )
{
	gHitDecal = engfunc( EngFunc_DecalIndex, "{crack1" );
	gHitDecal2 = engfunc( EngFunc_DecalIndex, "{scorch2" );
	
	gShockWaveSprite = precache_model( "sprites/shockwave.spr" );
	gExplosionSprite = precache_model( "sprites/blueflare2.spr" );
	gLaserBeam = precache_model( "sprites/laserbeam.spr" );
	
	precache_sound( gPredatorCloakSound );
	precache_sound( gPredatorTransform );
	precache_sound( gPredatorGibScream );
	precache_sound( gPredatorDirtpound );
	precache_sound( gPredatorVisionchange );
	precache_sound( gDiskHitSound );
	precache_sound( gDiskShootSound );
	precache_sound( gPlasmaShootSound );
	precache_sound( gPlasmaHitSound );
	
	for( i = 0; i < sizeof gPredatorDieSounds; i++ )
	{
		precache_sound( gPredatorDieSounds[ i ] );
	}
	
	for( i = 0; i < sizeof gPredatorIdleSounds; i++ )
	{
		precache_sound( gPredatorIdleSounds[ i ] );
	}
	
	for( i = 0; i < sizeof gPredatorDamageSounds; i++ )
	{
		precache_sound( gPredatorDamageSounds[ i ] );
	}
	
	new szFormatModel[ 200 ];
	formatex( szFormatModel, charsmax( szFormatModel ), "models/player/%s/%s.mdl", gPredatorPlayerModel, gPredatorPlayerModel );
	
	precache_model( szFormatModel );
	precache_model( gPredatorClaws );
	precache_model( gPredatorDiskModel );
	precache_model( gPlasmaModelSprite );
	
	UTIL_CreatePredatorWeap( );
}

public client_connect( id )
{
	bIsUserPredator[ id ] = PREDA_NO;
	bPredatorCloak[ id ] = DISABLED;
	bPredatorDisks[ id ] = 0;
	bPredatorPlasma[ id ] = 0;
	gVisionString[ id ] = "Normala";
}

public client_disconnect( id )
{
	bIsUserPredator[ id ] = PREDA_NO;
	bPredatorCloak[ id ] = DISABLED;
	bPredatorDisks[ id ] = 0;
	bPredatorPlasma[ id ] = 0;
	gVisionString[ id ] = "Normala";
}

public CommandBuyPredator( id )
{
	if( !is_user_alive( id ) )
	{
		ColorChat( id, RED, "^3%s^1 Nu poti sa cumperi^4 Predator^1 cand esti mort!", gPluginTag );
		
		return PLUGIN_HANDLED;
	}
	
	if( bIsUserPredator[ id ] == PREDA_YES )
	{
		ColorChat( id, RED, "^3%s^1 Esti deja^4 Predator^1!", gPluginTag );
		
		return PLUGIN_HANDLED;
	}
	
	new iFragCost = get_pcvar_num( gCvarPredatorFragCost );
	new iFrags = get_user_frags( id );

	if( iFrags < iFragCost  )
	{
		ColorChat( id, RED, "^3%s^1 Iti trebuie^4 %d^1 fraguri sa cumperi^4 Predator^1!", gPluginTag, iFragCost );
		
		return PLUGIN_HANDLED;
	}
	
	new iMoneyCost = get_pcvar_num( gCvarPredatorCost );
	new iMoney = cs_get_user_money( id );

	if( iMoney < iMoneyCost )
	{
		ColorChat( id, RED, "^3%s^1 Iti trebuie^4 %d$^1 ca sa cumperi^4 Predator^1!", gPluginTag, iMoneyCost );
		
		return PLUGIN_HANDLED;
	}
	
	bIsUserPredator[ id ] = PREDA_YES;
	bPredatorVision[ id ] = NORMAL_VISION;
	bPredatorCloak[ id ] = ENABLED;

	gVisionString[ id ] = "Normala";
	bPredatorDisks[ id ] = get_pcvar_num( gCvarPredatorDisks );
	bPredatorPlasma[ id ] = get_pcvar_num( gCvarPredatorPlasmas );

	cs_set_user_money( id, iMoney - iMoneyCost, 1 );
	set_user_frags( id, iFrags - iFragCost );
	
	engclient_cmd( id, "drop", "weapon_c4" );

	strip_user_weapons( id );
	give_item( id, "weapon_knife" );

	set_user_health( id, get_pcvar_num( gCvarPredatorHealth ) );
	set_user_armor( id, get_pcvar_num( gCvarPredatorArmor ) );
	
	UTIL_PredatorCloak( id );
	set_user_footsteps( id, 1 );
	set_user_gravity( id, get_pcvar_float( gCvarPredatorGravity ) );
	
	ColorChat( id, RED, "^3%s^1 Ai cumparat^4 Predator^1 pentru^4 %d^1 frage si ^4%d$^1!", gPluginTag, iFragCost, iMoneyCost );
	emit_sound( id, CHAN_STATIC, gPredatorTransform, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	return PLUGIN_CONTINUE;
}

public CommandPredatorVision( id )
{
	if( !is_user_alive( id ) 
	|| bIsUserPredator[ id ] == PREDA_NO )
	{
		return PLUGIN_CONTINUE;
	}
	
	if( bPredatorVision[ id ] == NORMAL_VISION )
	{
		bPredatorVision[ id ] = INFRARED_VISION;
	}
	
	else if( bPredatorVision[ id ] == INFRARED_VISION )
	{
		bPredatorVision[ id ] = ULTRAVIOLET_VISION;
	}
	
	else if( bPredatorVision[ id ] == ULTRAVIOLET_VISION )
	{
		bPredatorVision[ id ] = TEAM_VISION;
	}
	
	else if( bPredatorVision[ id ] == TEAM_VISION )
	{
		bPredatorVision[ id ] = NIGHT_VISION;
	}
	
	else if( bPredatorVision[ id ] == NIGHT_VISION )
	{
		bPredatorVision[ id ] = NORMAL_VISION;
	}
	
	client_cmd( id, "speak ^"%s^"", gPredatorVisionchange );
	
	return PLUGIN_HANDLED;
}

public CommandShootDisk( id )
{
	if( !is_user_alive( id ) 
	|| get_user_weapon( id ) != CSW_KNIFE
	|| bIsUserPredator[ id ] == PREDA_NO )
	{
		return PLUGIN_CONTINUE;
	}
	
	if( bPredatorDisks[ id ] <= 0 )
	{
		set_hudmessage( 0, 85, 255, -1.0, 0.79, 0, 6.0, 1.0 );
		ShowSyncHudMsg( id, gHudSync2, "Nu mai ai Discuri!" );
		
		return PLUGIN_HANDLED;
	}

	new Float:flGameTime = get_gametime( );
	
	if( flGameTime - flLastDisk[ id ] < PREDATOR_DISK_DELAY )
	{
		set_hudmessage( 0, 85, 255, -1.0, 0.79, 0, 6.0, 1.0 );
		ShowSyncHudMsg( id, gHudSync2, "Discul este gata in [%d] secunde!", floatround( flLastDisk[ id ] + PREDATOR_DISK_DELAY - flGameTime + 1 ) );

		return PLUGIN_HANDLED;
	}
	
	new Float:flOrigin[ 3 ];
	pev( id, pev_origin, flOrigin );

	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	engfunc( EngFunc_SetModel, iEntity, gPredatorDiskModel );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );

	UTIL_GetStartPosition( id, 37.0, 0.0, 13.0, flOrigin );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_classname, gDiskClassname );
	set_pev( iEntity, pev_solid, SOLID_TRIGGER );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_owner, id );
	
	new Float:flVelocity[ 3 ];
	velocity_by_aim( id, random_num( 300, 700 ), flVelocity );

	set_pev( iEntity, pev_velocity, flVelocity );
	set_pev( iEntity, pev_nextthink, flGameTime + 0.1 );
	
	set_rendering( iEntity, kRenderFxGlowShell, 205, 133, 63, kRenderNormal, 10 );
	emit_sound( id, CHAN_STATIC, gDiskShootSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	bPredatorDisks[ id ]--;
	flLastDisk[ id ] = flGameTime;

	return PLUGIN_HANDLED;
}

public forward_Flashlight( id )
{
	if( !is_user_alive( id ) 
	|| get_user_weapon( id ) != CSW_KNIFE
	|| bIsUserPredator[ id ] == PREDA_NO )
	{
		return PLUGIN_CONTINUE;
	}
	
	if( bPredatorPlasma[ id ] <= 0 )
	{
		set_hudmessage( 170, 255, 255, -1.0, 0.79, 0, 6.0, 1.0 );
		ShowSyncHudMsg( id, gHudSync2, "Nu mai ai Plasma!" );
		
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime( );
	
	if( flGameTime - flLastPlasma[ id ] < PREDATOR_PLASMA_DELAY )
	{
		set_hudmessage( 170, 255, 255, -1.0, 0.79, 0, 6.0, 1.0 );
		ShowSyncHudMsg( id, gHudSync2, "Poti trage cu Plasma in [%d] secunde!", floatround( flLastPlasma[ id ] + PREDATOR_PLASMA_DELAY - flGameTime + 1 ) );

		return PLUGIN_HANDLED;
	}

	new Float:flOrigin[ 3 ];
	pev( id, pev_origin, flOrigin );

	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	engfunc( EngFunc_SetModel, iEntity, gPlasmaModelSprite );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -2.0, -2.0, -2.0 }, Float:{ 2.0, 2.0, 2.0 } );

	UTIL_GetStartPosition( id, 37.0, 0.0, 13.0, flOrigin );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_classname, gPlasmaClassname );
	set_pev( iEntity, pev_solid, SOLID_BBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLYMISSILE );
	set_pev( iEntity, pev_owner, id );
	set_pev( iEntity, pev_framerate, 1.0 );
	set_pev( iEntity, pev_rendermode, 5 );
	set_pev( iEntity, pev_renderamt, 255.0 );
	set_pev( iEntity, pev_scale, 1.20 );
	
	new Float:flVelocity[ 3 ];
	velocity_by_aim( id, 1000, flVelocity );

	set_pev( iEntity, pev_velocity, flVelocity );
	UTIL_BeamFollow( iEntity );
	emit_sound( id, CHAN_STATIC, gPlasmaShootSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

	bPredatorPlasma[ id ]--;
	flLastPlasma[ id ] = flGameTime;

	return PLUGIN_HANDLED;
}

public CommandBuy( id )
{
	if( bIsUserPredator[ id ] == PREDA_YES )
	{
		client_print( id, print_center, "Cand esti Predator nu poti cumpara arme!" );
		
		return PLUGIN_HANDLED_MAIN;
	}
	
	return PLUGIN_CONTINUE;
}

public BlockRadio( id )
{	
	if( bIsUserPredator[ id ] == PREDA_YES )
	{
		return PLUGIN_HANDLED_MAIN;
	}
	
	return PLUGIN_CONTINUE;
}

public bacon_Spawned( id )
{
	if( is_user_alive( id ) )
	{
		if( bIsUserPredator[ id ] == PREDA_YES )
		{
			bPredatorDisks[ id ] = get_pcvar_num( gCvarPredatorDisks );
			bPredatorPlasma[ id ] = get_pcvar_num( gCvarPredatorPlasmas );
			bPredatorVision[ id ] = NORMAL_VISION;
			bPredatorCloak[ id ] = ENABLED;
			
			engclient_cmd( id, "drop", "weapon_c4" );

			strip_user_weapons( id );
			give_item( id, "weapon_knife" );

			set_user_health( id, get_pcvar_num( gCvarPredatorHealth ) );
			set_user_armor( id, get_pcvar_num( gCvarPredatorArmor ) );
	
			UTIL_PredatorCloak( id );
			set_user_footsteps( id, 1 );
			set_user_gravity( id, get_pcvar_float( gCvarPredatorGravity ) );
			
			emit_sound( id, CHAN_STATIC, gPredatorTransform, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
		
		if( bIsUserPredator[ id ] == PREDA_NO )
		{
			if( get_pcvar_num( gCvarPredatorAutomenu ) == 1 )
			{
				if( get_user_frags( id ) >= get_pcvar_num( gCvarPredatorFragCost )
				&& cs_get_user_money( id ) >= get_pcvar_num( gCvarPredatorCost ) )
				{
					ShowPredatorMenu( id );
				}
			}
		}
	}
}

public bacon_Killed( victim, attacker, shouldgib )
{
	if( ( 1 <= victim <= gMaxPlayers ) )
	{
		if( bIsUserPredator[ victim ] == PREDA_YES )
		{
			bIsUserPredator[ victim ] = PREDA_NO;
			bPredatorDisks[ victim ] = 0;
			bPredatorPlasma[ victim ] = 0;
			bPredatorVision[ victim ] = NORMAL_VISION;
			bPredatorCloak[ victim ] = DISABLED;

			set_user_rendering( victim );
			set_user_footsteps( victim, 0 );
			set_user_gravity( victim, 1.0 );
			cs_reset_user_model( victim );
		
			emit_sound( victim, CHAN_AUTO, gPredatorDieSounds[ random_num( 0, charsmax( gPredatorDieSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			SetHamParamInteger( 3, GIB_ALWAYS );

			return HAM_HANDLED;
		}
		
		if( bIsUserPredator[ attacker ] == PREDA_YES )
		{
			new iOrigin[ 3 ];
			get_user_origin( victim, iOrigin, 0 );
			
			UTIL_BloodStream( iOrigin );
			SetHamParamInteger( 3, GIB_ALWAYS );

			emit_sound( attacker, CHAN_VOICE, gPredatorGibScream, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			return HAM_HANDLED;
		}
	}
	
	return HAM_IGNORED;
}

public forward_EmitSound( const id, const channel, szSound[ ] )
{
	if( !is_user_alive( id ) 
	|| !is_user_connected( id ) )
	{
		return FMRES_IGNORED;
	}
	
	if( bIsUserPredator[ id ] == PREDA_YES )
	{
		if( contain( szSound, "player/die" ) > -1
		|| contain( szSound, "player/death6" ) > -1 )
		{
			emit_sound( id, CHAN_AUTO, gPredatorDieSounds[ random_num( 0, charsmax( gPredatorDieSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
			return FMRES_SUPERCEDE;
		}
	
		if( contain( szSound, "player/pl_fallpain" ) > -1
		|| contain( szSound, "player/headshot" ) > -1
		|| contain( szSound, "player/pl_die" ) > -1
		|| contain( szSound, "player/pl_shot" ) > -1
		|| contain( szSound, "player/pl_pain" ) > -1
		|| contain( szSound, "player/bhit_" ) > -1 )
		{
			emit_sound( id, CHAN_AUTO, gPredatorDamageSounds[ random_num( 0, charsmax( gPredatorDamageSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public forward_CmdStart( id, uc_handle, random_seed )
{
	if( !is_user_alive( id )
	|| bIsUserPredator[ id ] == PREDA_NO )
	{
		return FMRES_IGNORED;
	}
	
	new iButton = get_uc( uc_handle, UC_Buttons );
	new iFlags = pev( id, pev_flags );

	new Float:flGameTime = get_gametime( );

	if( ( iButton & IN_RELOAD ) 
	&& ( iFlags & FL_ONGROUND )
	&& !( iFlags & FL_WATERJUMP )
	&& !( iFlags & FL_INWATER ) )
	{
		if( flGameTime - flLastDirtpound[ id ] < PREDATOR_DIRTPOUND_DELAY )
		{
			set_hudmessage( 255, 100, 0, -1.0, 0.79, 0, 6.0, 1.0 );
			ShowSyncHudMsg( id, gHudSync2, "Poti folosi Dirtpound peste [%d] secunde!", floatround( flLastDirtpound[ id ] + PREDATOR_DIRTPOUND_DELAY - flGameTime + 1 ) );
			
			return FMRES_IGNORED;
		}
	
		new iOrigin[ 3 ];
		get_user_origin( id, iOrigin, 0 );
		
		UTIL_Cylinder( iOrigin, PREDATOR_DIRTPOUND_RADIUS );
		UTIL_Cylinder( iOrigin, PREDATOR_DIRTPOUND_RADIUS + 50 );
		UTIL_Cylinder( iOrigin, PREDATOR_DIRTPOUND_RADIUS + 100 );
		
		UTIL_Shake( id );
		UTIL_DamageAndShake( id, get_pcvar_num( gCvarPredatorDirtpoundDmg ), float( PREDATOR_DIRTPOUND_RADIUS ) );
		
		emit_sound( id, CHAN_STATIC, gPredatorDirtpound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
		flLastDirtpound[ id ] = flGameTime;
	}
	
	if( ( iButton & IN_DUCK ) 
	&& ( iButton & IN_JUMP ) 
	&& ( iFlags & FL_ONGROUND )
	&& !( iFlags & FL_WATERJUMP )
	&& !( iFlags & FL_INWATER ) )
	{
		if( flGameTime - flLastHighJump[ id ] < PREDATOR_HIGHJUMP_DELAY )
		{
			set_hudmessage( 243, 127, 60, -1.0, 0.79, 0, 6.0, 1.0 );
			ShowSyncHudMsg( id, gHudSync2, "Poti folosi High Jump peste [%d] secunde!", floatround( flLastHighJump[ id ] + PREDATOR_HIGHJUMP_DELAY - flGameTime + 1 ) );
			
			return FMRES_IGNORED;
		}

		new Float:flVelocity[ 3 ];
		pev( id, pev_velocity, flVelocity );
		
		flVelocity[ 2 ] = 580.0;
		
		set_pev( id, pev_velocity, flVelocity );
		
		flLastHighJump[ id ] = flGameTime;
	}
	
	return FMRES_IGNORED;
}

public Log_RoundEnd( ) 
{
	remove_entity_name( gDiskClassname );
	remove_entity_name( gPlasmaClassname );
}

public Log_RoundStart( )
{
	remove_entity_name( gDiskClassname );
	remove_entity_name( gPlasmaClassname );
}

public Hook_CurWeapon( id )
{
	if( bIsUserPredator[ id ] == PREDA_YES )
	{
		new iWeapon = get_user_weapon( id );
	
		if( iWeapon == CSW_KNIFE )
		{
			set_pev( id, pev_viewmodel2, gPredatorClaws );
			set_pev( id, pev_weaponmodel2, "" );
		}
	}
}

public bacon_BloodColor( id )
{
	if( bIsUserPredator[ id ] == PREDA_YES )
	{
		SetHamReturnInteger( PREDATOR_YELLOW_BLOOD );

		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public bacon_Touch( ent, id )
{
	if( pev_valid( ent ) && ( 1 <= id <= gMaxPlayers ) )
	{
		if( bIsUserPredator[ id ] == PREDA_YES && is_user_alive( id ) )
		{
			return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}

public bacon_TraceAttack( iEnt, iAttacker, Float:flDamage, Float:fDir[ 3 ], ptr, iDamageType )
{
	if( !( 1 <= iAttacker <= gMaxPlayers ) && !( 1 <= iEnt <= gMaxPlayers ) )
	{
		return;
	}
	
	if( is_user_alive( iAttacker ) 
	&& bIsUserPredator[ iAttacker ] == PREDA_YES )
	{
		new Float:flEnd[ 3 ];
		get_tr2( ptr, TR_vecEndPos, flEnd );

		UTIL_Sparks( flEnd );
	}
}

public forward_Spray( id )
{
	if( is_user_alive( id ) )
	{
		if( bIsUserPredator[ id ] == PREDA_YES )
		{
			new Float:flGameTime = get_gametime( );
			
			if( flGameTime - flLastCloak[ id ] >= PREDATOR_CLOAK_DELAY )
			{
				if( bPredatorCloak[ id ] == DISABLED )
				{
					bPredatorCloak[ id ] = ENABLED;
				
					new iOrigin[ 3 ];
					get_user_origin( id, iOrigin, 0 );
				
					UTIL_Teleport( iOrigin );
					UTIL_PredatorCloak( id );
					emit_sound( id, CHAN_STATIC, gPredatorCloakSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );	
				}
			
				else if( bPredatorCloak[ id ] == ENABLED )
				{
					bPredatorCloak[ id ] = DISABLED;
				
					set_user_rendering( id );
					emit_sound( id, CHAN_STATIC, gPredatorCloakSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				}
				
				flLastCloak[ id ] = flGameTime;
			}
		}
	}
}

public forward_DiskKill( iEnt, iPlayer )
{
	if( pev_valid( iEnt ) )
	{
		new iOwner = pev( iEnt, pev_owner );
		set_pev( iEnt, pev_flags, FL_KILLME );

		if( cs_get_user_team( iOwner ) != cs_get_user_team( iPlayer ) )
		{
			new szName[ 32 ];
			get_user_name( iPlayer, szName, charsmax( szName ) );

			new iOrigin[ 3 ];
			get_user_origin( iPlayer, iOrigin );
			
			ExecuteHamB( Ham_Killed, iPlayer, iOwner, GIB_ALWAYS );

			ColorChat( iOwner, RED, "^3%s^1 Ai ucis pe^4 %s^1 cu^4 Predator Disk^1!", gPluginTag, szName );
		}
	}
}

public forward_PlasmaDoDamage( iEnt, iTouched )
{
	if( pev_valid( iEnt ) )
	{
		new iOwner = pev( iEnt, pev_owner );

		new Float:flOrigin[ 3 ], iOrigin[ 3 ];

		pev( iEnt, pev_origin, flOrigin );
		FVecIVec( flOrigin, iOrigin );
		
		UTIL_BlowSprite( iOrigin );
		UTIL_WorldDecal( iOrigin, gHitDecal2 );
		emit_sound( iEnt, CHAN_STATIC, gPlasmaHitSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		set_pev( iEnt, pev_flags, FL_KILLME );
		
		new iClient = FM_NULLENT, Float:flClientOrigin[ 3 ], Float:flDistance;
		new Float:flRadius = float( get_pcvar_num( gCvarPredatorPlasmaRadius ) );

		while( ( iClient = engfunc( EngFunc_FindEntityInSphere, iClient, flOrigin, flRadius ) ) )
    		{
			if( ( 1 <= iClient <= gMaxPlayers )
			&& is_user_alive( iClient ) 
			&& get_user_team( iOwner ) != get_user_team( iClient ) )
			{
				pev( iClient, pev_origin, flClientOrigin );
       				flDistance = get_distance_f( flOrigin, flClientOrigin );

				if( flDistance <= flRadius )
				{
					new szName[ 32 ];
					get_user_name( iClient, szName, charsmax( szName ) );
			
					ExecuteHam( Ham_TakeDamage, iClient, gPlasmaWeapon, iOwner, float( get_pcvar_num( gCvarPredatorPlasmaDmg ) ), DMG_ENERGYBEAM );
				}
			}
		}
	}
}

public forward_DiskTouchWorld( iEnt, iWorld )
{
	if( pev_valid( iEnt ) )
	{	
		new Float:flOrigin[ 3 ], iOrigin[ 3 ];

		pev( iEnt, pev_origin, flOrigin );
		FVecIVec( flOrigin, iOrigin );
		
		UTIL_WorldDecal( iOrigin, gHitDecal );
		emit_sound( iEnt, CHAN_STATIC, gDiskHitSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		set_pev( iEnt, pev_flags, FL_KILLME );
	}
}

public forward_DiskThink( iEnt )
{
	if( pev_valid( iEnt ) )
	{
		new iOwner = pev( iEnt, pev_owner );
		
		set_pev( iEnt, pev_nextthink, get_gametime( ) + 0.1 );
		
		new Float:flDirection[ 3 ], Float:flOrigin[ 3 ], Float:flTarget[ 3 ], iPlayer;
	
		pev( iEnt, pev_origin, flOrigin );
		pev( iEnt, pev_velocity, flDirection );
	
		if( !( iPlayer = pev( iEnt, pev_enemy ) ) )
		{
			new iNearestEnt = 0;
			new Float:flNearestDist = 9999.0;
			new Float:flDist = 0.0;
		
			while( 1 <= ( iPlayer = find_ent_in_sphere( iPlayer, flOrigin, 1000.0 ) ) <= gMaxPlayers )
			{
				if( !is_user_alive( iPlayer ) || cs_get_user_team( iOwner ) == cs_get_user_team( iPlayer ) )
				{
					continue;
				}
			
				pev( iPlayer, pev_origin, flTarget );   
			
				if( trace_line( iEnt, flOrigin, flTarget, flTarget ) != iPlayer )
				{
					continue;
				}
			
				pev( iPlayer, pev_origin, flTarget );
				xs_vec_sub( flTarget, flOrigin, flTarget );
			
				flDist = xs_vec_len( flTarget );
			
				if( flDist < flNearestDist )
				{
					iNearestEnt = iPlayer;
					flNearestDist = flDist;
				}
			}
		
			iPlayer = iNearestEnt;
		
			if( iPlayer > 0 )
			{
				set_pev( iEnt, pev_enemy, iPlayer );
			}
		}
	
		if( iPlayer )
		{
			pev( iPlayer, pev_origin, flTarget );

			xs_vec_sub( flTarget, flOrigin, flTarget );
			xs_vec_normalize( flTarget, flTarget );
		
			xs_vec_mul_scalar( flTarget, 400.0, flTarget );
			xs_vec_add( flDirection, flTarget, flDirection );
		}
	
		xs_vec_normalize( flDirection, flDirection );
		xs_vec_mul_scalar( flDirection, random_float( 400.0, 600.0 ), flDirection );

		set_pev( iEnt, pev_velocity, flDirection );
		vector_to_angle( flDirection, flDirection );
		set_pev( iEnt, pev_angles, flDirection );
	}
}

public forward_AddToFullPack_Post( es_handle, e, ent, host, hostflags, player, pSet )
{
	if( !is_user_alive( host )
	|| bIsUserPredator[ host ] == PREDA_NO
	|| !pev_valid( ent ) )
	{
		return FMRES_IGNORED;
	}
	
	static szClassname[ 32 ];
	pev( ent, pev_classname, szClassname, charsmax( szClassname ) );

	switch( bPredatorVision[ host ] )
	{
		case INFRARED_VISION:
		{	
			if( equal( szClassname, "player" ) )
			{
				if( host != ent
				&& is_user_alive( ent ) 
				&& get_user_team( ent ) != get_user_team( host ) )
				{
					set_es( es_handle, ES_RenderAmt, 100 );
					set_es( es_handle, ES_RenderMode, kRenderNormal );
					set_es( es_handle, ES_RenderFx, kRenderFxGlowShell );
					set_es( es_handle, ES_RenderColor, { 10, 10, 255 } );	// albastru
				}
			}
			
			UTIL_Vision( host, 255, 0, 0 );
		}
		
		case ULTRAVIOLET_VISION:
		{
			if( equal( szClassname, "hostage_entity" ) )
			{
				set_es( es_handle, ES_RenderMode, kRenderNormal );
				set_es( es_handle, ES_RenderFx, kRenderFxGlowShell );
				set_es( es_handle, ES_RenderAmt, 40 );
				set_es( es_handle, ES_RenderColor, { 255, 10, 10 } );	// rosu
			}
			
			if( equal( szClassname, "func_wall" ) || equal( szClassname, "func_door" ) 
			|| equal( szClassname, "func_button" ) || equal( szClassname, "func_rot_button" )
			|| equal( szClassname, "func_door_rotating" ) || equal( szClassname, "func_wall_toggle" ) || equal( szClassname, "func_ladder" ) )
			{
				set_es( es_handle, ES_RenderAmt, 100 );
				set_es( es_handle, ES_RenderMode, kRenderTransColor );
				set_es( es_handle, ES_RenderColor, { 255, 255, 255 } );	// alb
			}
			
			if( equal( szClassname, "func_breakable" ) || equal( szClassname, "func_pushable" )
			|| equal( szClassname, "func_vehicle" ) || equal( szClassname, "func_train" )
			|| equal( szClassname, "func_rotating" ) || equal( szClassname, "func_plat" )
			|| equal( szClassname, "func_tank" ) || equal( szClassname, "func_tracktrain" ) )
			{
				set_es( es_handle, ES_RenderAmt, 100 );
				set_es( es_handle, ES_RenderMode, kRenderTransColor );
				set_es( es_handle, ES_RenderColor, { 255, 127, 0 } );	// portocaliu
			}
			
			UTIL_Vision( host, 178, 58, 238 );
		}
		
		case TEAM_VISION:
		{
			if( equal( szClassname, "player" ) )
			{
				if( host != ent
				&& is_user_alive( ent ) 
				&& get_user_team( ent ) == get_user_team( host ) )
				{
					set_es( es_handle, ES_RenderAmt, 60 );
					set_es( es_handle, ES_RenderMode, kRenderTransAlpha );
					set_es( es_handle, ES_RenderFx, kRenderFxGlowShell );
					set_es( es_handle, ES_RenderColor, { 255, 255, 10 } );
				}
			}
			
			if( equal( szClassname, "weaponbox" ) 
			|| equal( szClassname, "weapon_shield" ) 
			|| equal( szClassname, "armoury_entity" ) )
			{
				set_es( es_handle, ES_RenderAmt, 40 );
				set_es( es_handle, ES_RenderMode, kRenderNormal );
				set_es( es_handle, ES_RenderFx, kRenderFxGlowShell );
				set_es( es_handle, ES_RenderColor, { 255, 255, 10 } );
			}

			UTIL_Vision( host, 211, 211, 211 );
		}
		
		case NIGHT_VISION:
		{
			if( host == ent )
			{
				set_es( es_handle, ES_Effects, EF_BRIGHTLIGHT );
				
				UTIL_Vision( host, 10, 255, 0 );
			}
		}
	}
	
	return FMRES_IGNORED;
}

public bacon_TakeDamage( victim, inflictor, attacker, Float:damage, damage_type )
{
	if( !( 1 <= victim <= gMaxPlayers ) )
	{
		return HAM_IGNORED;
	}
	
	if( bIsUserPredator[ attacker ] == PREDA_YES )
	{
		if( get_user_team( victim ) != get_user_team( attacker )
		|| get_user_weapon( attacker ) == CSW_KNIFE )
		{
			SetHamParamFloat( 4, damage * 2 );
		
			return HAM_HANDLED;
		}
	}
	
	return HAM_IGNORED;
}

public bacon_ResetMaxSpeed( id )
{
	if( is_user_alive( id ) )
	{
		if( bIsUserPredator[ id ] == PREDA_YES )
		{
			new Float:flMaxSpeed = float( get_pcvar_num( gCvarPredatorSpeed ) );
		
			engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed );
			set_pev( id, pev_maxspeed, flMaxSpeed );
		}
	}
}

public bacon_PreThink( id )
{
	if( is_user_alive( id ) )
	{
		if( bIsUserPredator[ id ] == PREDA_YES )
		{
			new Float:flGameTime = get_gametime( );
			
			if( flGameTime - flLastIdleSound[ id ] >= PREDATOR_IDLE_DELAY )
			{
				emit_sound( id, CHAN_BODY, gPredatorIdleSounds[ random_num( 0, charsmax( gPredatorIdleSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				
				flLastIdleSound[ id ] = flGameTime;
			}
			
			if( flGameTime - flLastHud[ id ] > HUD_MAX_TIME )
			{
				switch( bPredatorVision[ id ] )
				{
					case NORMAL_VISION:
					{
						set_hudmessage( 255, 85, 0, 0.01, 0.20, 0, 6.0, HUD_MAX_TIME );
						gVisionString[ id ] = "Normala";
					}

					case INFRARED_VISION:
					{
						set_hudmessage( 10, 10, 255, 0.01, 0.20, 0, 6.0, HUD_MAX_TIME );
						gVisionString[ id ] = "Infrarosu";
					}

					case ULTRAVIOLET_VISION:
					{
						set_hudmessage( 255, 255, 255, 0.01, 0.20, 0, 6.0, HUD_MAX_TIME );
						gVisionString[ id ] = "Ultraviolet";
					}

					case TEAM_VISION:
					{
						set_hudmessage( 255, 10, 10, 0.01, 0.20, 0, 6.0, HUD_MAX_TIME );
						gVisionString[ id ] = "Echipa";
					}
					
					case NIGHT_VISION:
					{
						set_hudmessage( 10, 255, 0, 0.01, 0.20, 0, 6.0, HUD_MAX_TIME );
						gVisionString[ id ] = "Nocturna";
					}
				}
				
				flLastHud[ id ] = flGameTime;
				ShowSyncHudMsg( id, gHudSync, "Viata: %d | Armura: %d^nInvizibilitate: %s^nDiscuri: %d | Plasma: %d^nMasca: %s", get_user_health( id ), get_user_armor( id ), ( bPredatorCloak[ id ] == 1 ? "Activ" : "Inactiv" ), bPredatorDisks[ id ], bPredatorPlasma[ id ], gVisionString[ id ] );
			}
		}
	}
}

public ShowPredatorMenu( id )
{
	new szFormatMenuTitle[ 200 ];
	formatex( szFormatMenuTitle, charsmax( szFormatMenuTitle ), "\wVrei sa devii \rPredator\w?^nCosta \y%d\w Fraguri si \y%d$\w.", get_pcvar_num( gCvarPredatorFragCost ), get_pcvar_num( gCvarPredatorCost ) );
	
	new iMenu = menu_create( szFormatMenuTitle, "menu_PredatorHandler" );
	
	menu_additem( iMenu, "\wDa", "1", 0 );
	menu_additem( iMenu, "\wNu", "2", 0 );
	
	menu_setprop( iMenu, MPROP_EXIT, MEXIT_NEVER );
	menu_display( id, iMenu, 0 );
}

public menu_PredatorHandler( id, menu, item )
{
	new szData[ 6 ], szName[ 64 ], access, callback;
    	menu_item_getinfo( menu, item, access, szData, charsmax( szData ), szName, charsmax( szName ), callback );

	new iKey = str_to_num( szData );

	switch( iKey )
	{
		case 1:
		{
			CommandBuyPredator( id );
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
		
		case 2:
		{
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
	}
	
	menu_destroy( menu );

	return PLUGIN_HANDLED;
}

stock UTIL_PredatorCloak( id )
{
	set_user_rendering( id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, floatround( 255.0 * float( get_pcvar_num( gCvarPredatorCloakPercent ) ) / 100.0 ) );
}

stock UTIL_BloodStream( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BLOODSTREAM );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 30 );
	write_coord( random_num( -20, 20 ) );
	write_coord( random_num( -20, 20 ) );
	write_coord( random_num( 50, 300 ) );
	write_byte( 70 );
	write_byte( random_num( 100, 200 ) );
	message_end( );
}

stock UTIL_DamageAndShake( id, iDamage, Float:flRadius )
{
	new iClient = FM_NULLENT, Float:flClientOrigin[ 3 ], Float:flDistance;
	
	new Float:flPredaOrigin[ 3 ];
	pev( id, pev_origin, flPredaOrigin );

    	while( ( iClient = engfunc( EngFunc_FindEntityInSphere, iClient, flPredaOrigin, flRadius ) ) )
    	{
		if( ( 1 <= iClient <= gMaxPlayers )
		&& is_user_alive( iClient ) 
		&& get_user_team( id ) != get_user_team( iClient ) )
		{
			pev( iClient, pev_origin, flClientOrigin );
       			flDistance = get_distance_f( flPredaOrigin, flClientOrigin );

			if( flDistance <= flRadius )
			{
				new Float:flRandom[ 3 ];

				for( i = 0; i < 3; i++ )
				{
					flRandom[ i ] = random_float( 100.0, 150.0 );
				}
				
				set_pev( iClient, pev_punchangle, flRandom );
			
				UTIL_Shake( iClient );
				ExecuteHam( Ham_TakeDamage, iClient, gDritWeapon, id, float( iDamage ), DMG_SHOCK );
			}
		}
	}
}

stock UTIL_BlowSprite( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_SPRITETRAIL );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
 	write_coord( iOrigin[ 0 ] + random_num( -15, 15 ) );
	write_coord( iOrigin[ 1 ] + random_num( -15, 15 ) );
	write_coord( iOrigin[ 2 ] + random_num( -15, 15 ) );
	write_short( gExplosionSprite );
	write_byte( 38 ); //count
	write_byte( 6 ); // Life
	write_byte( 2 ); // Scale
	write_byte( 50 );
	write_byte( 10 );
	message_end( );
}

stock UTIL_Teleport( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_TELEPORT );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	message_end( );
}

stock UTIL_Sparks( Float:flOrigin[ 3 ] )
{
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0 );
	write_byte( TE_SPARKS );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	message_end( );
}

stock UTIL_WorldDecal( iOrigin[ 3 ], iDecal )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_WORLDDECAL );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_byte( iDecal );
	message_end( );
}

stock UTIL_Vision( id, r, g, b )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade, _, id );
	write_short( 1<<10 );
	write_short( 1<<10 );
	write_short( FFADE_IN );
	write_byte( r );
	write_byte( g );
	write_byte( b ); 
	write_byte( 125 );
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
	write_short( gShockWaveSprite );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 4 );
	write_byte( 20 );
	write_byte( 100 );
	write_byte( 255 );
	write_byte( 100 );
	write_byte( 0 );
	write_byte( 128 );
	write_byte( 5 );
	message_end( );
}

stock UTIL_Shake( id )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenShake, _, id );
	write_short( 1<<13 );
	write_short( 1<<13 );
	write_short( 1<<13 );
	message_end( );
}
	
stock UTIL_BeamFollow( ent )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( ent );
	write_short( gLaserBeam );
	write_byte( 25 );
	write_byte( 7 );
	write_byte( 42 );
	write_byte( 170 );
	write_byte( 255 );
	write_byte( 255 );
	message_end( );
}

stock UTIL_CreatePredatorWeap( )
{
	gPlasmaWeapon = create_entity( "info_target" );
	set_pev( gPlasmaWeapon, pev_classname, "Predator Plasma Beam" );
	
	gDritWeapon = create_entity( "info_target" );
	set_pev( gDritWeapon, pev_classname, "Predator Dirt Pound" );
}

stock UTIL_GetStartPosition( id, Float:Forward = 0.0, Float:Right = 0.0, Float:Up = 0.0, Float:vecSource[ 3 ] )
{
	static Float:vecForward[ 3 ], Float:vecRight[ 3 ], Float:vecUp[ 3 ];
	static Float:vecPlayerAngles[ 3 ];
	
	pev( id, pev_origin, vecSource );
	pev( id, pev_v_angle, vecPlayerAngles );
	
	engfunc( EngFunc_MakeVectors, vecPlayerAngles );
	
	if( Forward > 0.0 ) global_get( glb_v_forward, vecForward );
	if( Right > 0.0 ) global_get( glb_v_right, vecRight );
	if( Up > 0.0 ) global_get( glb_v_up, vecUp );
	
	vecSource[ 0 ] += floatmul( vecForward[ 0 ], Forward ) + floatmul( vecRight[ 0 ], Right ) + floatmul( vecUp[ 0 ], Up );
	vecSource[ 1 ] += floatmul( vecForward[ 1 ], Forward ) + floatmul( vecRight[ 1 ], Right ) + floatmul( vecUp[ 1 ], Up );
	vecSource[ 2 ] += floatmul( vecForward[ 2 ], Forward ) + floatmul( vecRight[ 2 ], Right ) + floatmul( vecUp[ 2 ], Up );
}
