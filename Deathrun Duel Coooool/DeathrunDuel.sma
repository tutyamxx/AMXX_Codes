
#include < amxmodx >

#include < fun >
#include < hamsandwich >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < csx >

#include < colorchat >

#pragma semicolon 1

#define MAX_PLAYERS		32 + 1
#define IS_PLAYER(%1)		(1 <= %1 <= gMaxPlayers)

#define ONESHOT_AMMO		1
#define FFADE_IN		0x0000
#define WAVE_DELAY		0.5
#define DUELMUSIC_DELAY		8.6
#define GIB_ALWAYS		2

#define PLUGIN_VERSION		"4.0.23"

enum _: iTasks ( += 2931 )
{
	TASK_ONE = 2931,	
	TASK_TWO,
	TASK_THREE,
	TASK_FOUR,
	TASK_FIVE,
	TASK_SIX,
	TASK_SEVEN,
	TASK_EIGHT
};

enum _: iAmmos
{ 
	m_rgpPlayerItems_None = 376, 
   	m_rgpPlayerItems_338magnum, 
   	m_rgpPlayerItems_762nato, 
	m_rgpPlayerItems_556natobox, 
	m_rgpPlayerItems_556nato, 
	m_rgpPlayerItems_buckshot, 
	m_rgpPlayerItems_45acp, 
	m_rgpPlayerItems_57mm, 
	m_rgpPlayerItems_50ae, 
	m_rgpPlayerItems_357sig, 
	m_rgpPlayerItems_9mm, 
	m_rgpPlayerItems_flashbang, 
	m_rgpPlayerItems_hegrenade, 
	m_rgpPlayerItems_smokegrenade, 
	m_rgpPlayerItems_c4 
};

enum _: iPlayerData
{
	DATA_HEALTH,
	DATA_ARMOR,
	DATA_WEAPONS
};

new const gWeaponEntities[ ][ ] =
{
	"weaponbox",
	"weapon_shield",
	"armoury_entity"
};

new const gDuelWeapons[ ][ ] =
{
	"weapon_scout",
	"weapon_awp",
	"weapon_deagle"
};

new const gTeleportSounds[ ][ ] =
{
	"plats/heavystop1.wav",
	"plats/heavystop2.wav",
	"plats/squeekstop1.wav"
};

new const gDuelMusicSounds[ ][ ] =
{
	"media/Half-Life08",
	"media/Half-Life11",
	"media/Half-Life14",
	"media/Half-Life15",
	"media/Half-Life17"
};

new const gPluginTag[ ] = "[Deathrun]";

new const gDuelStartSound[ ] = "drduel/drduel.wav";
new const gCongratzSound[ ] = "holo/tr_holo_fantastic.wav";

new gDuelPlayerCT = 0;
new gDuelPlayerT = 0;
new gTimerCount = 0;

new i;
new gMaxPlayers;
new gRingSprite;
new gArrowSprite;
new gHudSync;
new gHudSync2;
new gHudSync3;
new gHudSync4;
new gMessageScreenFade;
new gMessageScoreInfo;

new gCvarScoutBpAmmo;
new gCvarDeagleBpAmmo;
new gCvarAwpBpAmmo;
new gCvarPlayerHealth;
new gCvarRamboDuelHealth;
new gCvarRamboBpAmmo;
new gCvarDuelTimeout;
new gCvarDuelFx;
new gCvarDuelOneShot;
new gCvarWinnerFrags;
new gCvarDuelMenuDuration;
new gCvarDuelSprayTime;
new gCvarTieDecideTime;
new gCvarGrenadeDuelFx;

const m_iXtraOff = 4;
const m_iXtraOffPlayer = 5;
const m_rgAmmo_player_Slot0 = 376;
const m_iPrimaryAmmoType = 49;
const m_fInReload = 54;
const m_pPlayer	= 41;
const m_flNextAttack = 83;
const m_fKnown = 44;
const m_iClip = 51;
const m_flNextDecalTime = 486;

new bool:bRoundEnded = false;
new bool:bMenuOpen = false;
new bool:bSprayDuel = false;
new bool:bDuelStarted = false;
new bool:bSprayDuelSelected = false;

new bPlayerBpAmmo[ MAX_PLAYERS ][ iAmmos ];
new bPlayerData[ MAX_PLAYERS ][ iPlayerData ];
new bPlayerCountSpray[ MAX_PLAYERS ];

public plugin_init( )
{
	register_plugin( "Deathrun CT Duel", PLUGIN_VERSION, "tuty" );
	
	register_clcmd( "say /duel", "CommandStartDuel" );
	register_clcmd( "say_team /duel", "CommandStartDuel" );
	register_clcmd( "drop", "CommandDropWeapon" );
	
	register_logevent( "RoundStart", 2, "1=Round_Start" );
	register_logevent( "RoundEnd", 2, "1=Round_End" );
	register_event( "TextMsg", "RoundStart", "a", "2&#Game_C", "2&#Game_w", "2&#Game_will_restart_in" );
	
	register_forward( FM_CmdStart, "forward_CmdStart" );
	register_forward( FM_UpdateClientData, "forward_UpdateClientData", 1 );
	register_forward( FM_EmitSound, "forward_EmitSound_Post", 1 );
	
	RegisterHam( Ham_Killed, "player", "bacon_Killed" );

	for( i = 0; i < sizeof gWeaponEntities; i++ )
	{
		RegisterHam( Ham_Touch, gWeaponEntities[ i ], "bacon_TouchWeapon" );
	}
	
	for( i = 0; i < sizeof gDuelWeapons; i++ )
	{
		RegisterHam( Ham_Item_PostFrame, gDuelWeapons[ i ], "bacon_PostFrame" );
		RegisterHam( Ham_Item_AttachToPlayer, gDuelWeapons[ i ], "bacon_AttachToPlayer" );
	}
	
	gCvarPlayerHealth = register_cvar( "drduel_player_health", "100" );
	gCvarRamboDuelHealth = register_cvar( "drduel_rambo_health", "500" );
	gCvarScoutBpAmmo = register_cvar( "drduel_scout_bpammo", "200" );
	gCvarDeagleBpAmmo = register_cvar( "drduel_deagle_bpammo", "50" );
	gCvarAwpBpAmmo = register_cvar( "drduel_awp_bpammo", "100" );
	gCvarDuelTimeout = register_cvar( "drduel_waittime", "10" );
	gCvarDuelFx = register_cvar( "drduel_fx", "1" );
	gCvarDuelOneShot = register_cvar( "drduel_one_shot", "1" );
	gCvarWinnerFrags = register_cvar( "drduel_winner_frags", "3" );
	gCvarDuelMenuDuration = register_cvar( "drduel_menu_duration", "10" );
	gCvarRamboBpAmmo = register_cvar( "drduel_rambo_bpammo", "250" );
	gCvarDuelSprayTime = register_cvar( "drduel_sprayduel_time", "20" );
	gCvarTieDecideTime = register_cvar( "drduel_tie_decidetime", "5" );
	gCvarGrenadeDuelFx = register_cvar( "drduel_grenadeduel_fx", "1" );

	gHudSync = CreateHudSyncObj( );
	gHudSync2 = CreateHudSyncObj( );
	gHudSync3 = CreateHudSyncObj( );
	gHudSync4 = CreateHudSyncObj( );

	gMaxPlayers = get_maxplayers( );
	gMessageScoreInfo = get_user_msgid( "ScoreInfo" );
	gMessageScreenFade = get_user_msgid( "ScreenFade" );
}

public plugin_precache( )
{
	gRingSprite = precache_model( "sprites/zbeam5.spr" );
	gArrowSprite = precache_model( "sprites/arrow1.spr" );

	for( i = 0; i < sizeof gTeleportSounds; i++ )
	{
		precache_sound( gTeleportSounds[ i ] );
	}
	
	precache_sound( gDuelStartSound );
}

public client_connect( id )
{
	bPlayerCountSpray[ id ] = 0;
}

public client_disconnect( id )
{
	bPlayerCountSpray[ id ] = 0;
}

public CommandStartDuel( id )
{
	if( !is_user_alive( id ) )
	{
		ColorChat( id, RED, "^3%s^1 Nu poti porni un ^4Duel^1 cand esti mort !", gPluginTag );
		
		return PLUGIN_CONTINUE;
	}
	
	if( cs_get_user_team( id ) == CS_TEAM_T )
	{
		ColorChat( id, RED, "^3%s^1 Esti in echipa ^4T^1, nu poti porni un ^4Duel^1 !", gPluginTag );
	
		return PLUGIN_CONTINUE;
	}

	if( bRoundEnded == true )
	{
		ColorChat( id, RED, "^3%s^1 Nu poti porni un ^4Duel^1 pentru ca s-a terminat runda !", gPluginTag );
		
		return PLUGIN_CONTINUE;
	}

	if( bMenuOpen == true )
	{
		ColorChat( id, RED, "^3%s^1 Selecteaza o optiune !", gPluginTag );
		
		return PLUGIN_CONTINUE;
	}

	if( bDuelStarted == true 
	|| bSprayDuel == true 
	|| bSprayDuelSelected == true )
	{
		ColorChat( id, RED, "^3%s^4 Duelul^1 deja este in desfasurare !", gPluginTag );
		
		return PLUGIN_CONTINUE;
	}
	
	if( UTIL_FindPlayers( ) == false )
	{
		ColorChat( id, RED, "^3%s^1 Nu poti porni inca un^4 Duel^1 !", gPluginTag );
		
		return PLUGIN_CONTINUE;
	}
	
	new iHealth = get_pcvar_num( gCvarPlayerHealth );
		
	bPlayerData[ gDuelPlayerCT ][ DATA_HEALTH ] = get_user_health( gDuelPlayerCT );
	bPlayerData[ gDuelPlayerCT ][ DATA_ARMOR ] = get_user_armor( gDuelPlayerCT );
	bPlayerData[ gDuelPlayerCT ][ DATA_WEAPONS ] = ( pev( gDuelPlayerCT, pev_weapons ) &~ ( 1 << 31 ) );

	bPlayerData[ gDuelPlayerT ][ DATA_HEALTH ] = get_user_health( gDuelPlayerT );
	bPlayerData[ gDuelPlayerT ][ DATA_ARMOR ] = get_user_armor( gDuelPlayerT );
	bPlayerData[ gDuelPlayerT ][ DATA_WEAPONS ] = ( pev( gDuelPlayerT, pev_weapons ) &~ ( 1 << 31 ) );

	UTIL_StoreBpAmmo( gDuelPlayerCT );
	UTIL_StoreBpAmmo( gDuelPlayerT );
	
	set_user_health( gDuelPlayerCT, iHealth );
	set_user_health( gDuelPlayerT, iHealth );

	set_user_armor( gDuelPlayerCT, 0 );
	set_user_armor( gDuelPlayerT, 0 );

	strip_user_weapons( gDuelPlayerCT );
	strip_user_weapons( gDuelPlayerT );
		
	if( get_pcvar_num( gCvarDuelFx ) == 1 )
	{
		set_user_rendering( gDuelPlayerCT, kRenderFxGlowShell, 10, 10, 255, kRenderNormal, 25 );
		set_user_rendering( gDuelPlayerT, kRenderFxGlowShell, 255, 10, 10, kRenderNormal, 25 );
	
		set_task( WAVE_DELAY, "ShowWaveFX", gDuelPlayerCT + TASK_THREE );
		set_task( WAVE_DELAY, "ShowWaveFX", gDuelPlayerT + TASK_THREE );

		UTIL_ScreenFadeFX( gDuelPlayerCT, 10, 10, 255, 255 );
		UTIL_ScreenFadeFX( gDuelPlayerT, 255, 10, 10, 255 );
	}

	set_user_godmode( gDuelPlayerCT, 1 );
	set_user_godmode( gDuelPlayerT, 1 );

	ShowWeaponsMenu( id );
	
	return PLUGIN_CONTINUE;
}

public bacon_Killed( iVictim, iAttacker, shouldgib )
{
	if( IS_PLAYER( iVictim ) && IS_PLAYER( iAttacker ) )
	{
		new szKillerName[ 32 ], szVictimName[ 32 ];
	
		get_user_name( iAttacker, szKillerName, charsmax( szKillerName ) );
		get_user_name( iVictim, szVictimName, charsmax( szVictimName ) );
			
		new iWinnerFrags = get_pcvar_num( gCvarWinnerFrags );

		if( gDuelPlayerCT == iAttacker && gDuelPlayerT == iVictim )
		{
			set_user_frags( gDuelPlayerCT, get_user_frags( gDuelPlayerCT ) - 1 + iWinnerFrags );
			UTIL_ScoreInfo( gDuelPlayerCT );

			client_cmd( gDuelPlayerCT, "speak ^"%s^"", gCongratzSound );
			ColorChat( 0, RED, "^3%s^4 %s^1 l-a invins in duel pe^4 %s^1 si a primit^4 %d^1 %s", gPluginTag, szKillerName, szVictimName, iWinnerFrags, ( iWinnerFrags == 1 ? "frag" : "fraguri" ) );
		}
	
		if( gDuelPlayerT == iAttacker && gDuelPlayerCT == iVictim )
		{
			set_user_frags( gDuelPlayerT, get_user_frags( gDuelPlayerT ) - 1 + iWinnerFrags );
			UTIL_ScoreInfo( gDuelPlayerT );
	
			client_cmd( gDuelPlayerT, "speak ^"%s^"", gCongratzSound );
			ColorChat( 0, RED, "^3%s^4 %s^1 l-a invins in duel pe^4 %s^1 si a primit^4 %d^1 %s", gPluginTag, szKillerName, szVictimName, iWinnerFrags, ( iWinnerFrags == 1 ? "frag" : "fraguri" ) );
		}
		
		set_user_rendering( iVictim );
		set_user_godmode( iVictim, 0 );

		show_menu( iVictim, 0, "^n", 1 );

		remove_task( TASK_FIVE );
		remove_task( iVictim + TASK_FOUR );
	
		client_cmd( gDuelPlayerCT, "mp3 stop" );
		client_cmd( gDuelPlayerT, "mp3 stop" );
	}
}

public bacon_AttachToPlayer( iEnt, id )
{
	if( bDuelStarted == true && get_pcvar_num( gCvarDuelOneShot ) == 1 )
	{
		if( get_pdata_int( iEnt, m_fKnown, m_iXtraOff ) )
		{
			return;
		}
	
		set_pdata_int( iEnt, m_iClip, ONESHOT_AMMO, m_iXtraOff );
	}
}

public bacon_PostFrame( iEnt )
{
	if( bDuelStarted == true && get_pcvar_num( gCvarDuelOneShot ) == 1 )
	{
		new fInReload = get_pdata_int( iEnt, m_fInReload, m_iXtraOff );
		new id = get_pdata_cbase( iEnt, m_pPlayer, m_iXtraOff );
		
		new iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int( iEnt, m_iPrimaryAmmoType, m_iXtraOff );
		new iBpAmmo = get_pdata_int( id, iAmmoType, m_iXtraOffPlayer );
		
		new Float:flNextAttack = get_pdata_float( id, m_flNextAttack, m_iXtraOffPlayer );
	
		if( fInReload && flNextAttack <= 0.0 )
		{
			set_pdata_int( iEnt, m_iClip, ONESHOT_AMMO, m_iXtraOff );
			set_pdata_int( id, iAmmoType, iBpAmmo - ONESHOT_AMMO, m_iXtraOffPlayer );

			set_pdata_int( iEnt, m_fInReload, 0, m_iXtraOff );
	
			fInReload = 0;
		}
		
		new iButton = pev( id, pev_button );
		
		if( iButton & IN_RELOAD && !fInReload )
		{
			if( get_pdata_int( iEnt, m_iClip, m_iXtraOff ) >= 1 )
			{
				set_pev( id, pev_button, iButton & ~IN_RELOAD );
				UTIL_WeaponAnimation( id, 0 );
			}
		}
	}
}

public grenade_throw( id, iGrenIndex, wId )
{
	if( bDuelStarted == true )
	{
		if( get_pcvar_num( gCvarGrenadeDuelFx ) == 1 )
		{
			if( id == gDuelPlayerT )
			{
				set_rendering( iGrenIndex, kRenderFxGlowShell, 255, 10, 10, kRenderTransAlpha, 45 );
				UTIL_BeamFollow( iGrenIndex, 255, 10, 10 );
			}
			
			else if( id == gDuelPlayerCT )
			{
				set_rendering( iGrenIndex, kRenderFxGlowShell, 10, 10, 255, kRenderTransAlpha, 45 );
				UTIL_BeamFollow( iGrenIndex, 10, 10, 255 );
			}
		}

		if( wId == CSW_HEGRENADE && is_user_alive( id ) )
		{
			set_task( 0.1, "GiveGrenade", id );
		}
	}
}

public GiveGrenade( id )
{
	if( IS_PLAYER( id ) && is_user_alive( id ) )
	{
		give_item( id, "weapon_hegrenade" );
	}
}

public forward_CmdStart( id, uc, uc_seed )
{
	if( !IS_PLAYER( id ) 
	|| !is_user_alive( id ) 
	|| bSprayDuel == false )
	{
		return FMRES_IGNORED;
	}

	new iButtons = get_uc( uc, UC_Buttons );

	if( iButtons & IN_ATTACK )
	{
		iButtons &= ~IN_ATTACK;
	}

	if( iButtons & IN_ATTACK2 )
	{
		iButtons &= ~IN_ATTACK2;
	}

	set_uc( uc, UC_Buttons, iButtons );

	return FMRES_HANDLED;
}

public forward_UpdateClientData( id, weapons, cd )
{
	if( !IS_PLAYER( id ) 
	|| !is_user_alive( id ) 
	|| bSprayDuel == false )
	{
		return FMRES_IGNORED;
	}
	
	set_cd( cd, CD_flNextAttack, 0.5 );

	return FMRES_HANDLED;
}
	
public forward_EmitSound_Post( iEnt, channel, const szSample[ ] )
{
	if( pev_valid( iEnt ) && equal( szSample, "player/sprayer.wav" ) )
	{
		if( bSprayDuel == true )
		{
			new id = pev( iEnt, pev_owner );

			if( IS_PLAYER( id ) && is_user_alive( id ) )
			{
				bPlayerCountSpray[ id ]++;
			
				set_pdata_float( id, m_flNextDecalTime, 0.0, m_iXtraOffPlayer );
			}
		}
	}
	
	return FMRES_IGNORED;
}

public ShowWeaponsMenu( id )
{
	new iMenu = menu_create( "\rAlege arma pentru \wDuel^n", "menu_handler" );
	
	menu_additem( iMenu, "\yScout", "1", 0 );
	menu_additem( iMenu, "\yDeagle", "2", 0 );
	menu_additem( iMenu, "\yAWP", "3", 0 );
	menu_additem( iMenu, "\yCutit", "4", 0 );
	menu_additem( iMenu, "\yM249", "5", 0 );
	menu_additem( iMenu, "\ySpray", "6", 0 );
	menu_additem( iMenu, "\yGrenade", "7", 0 );
	
	menu_setprop( iMenu, MPROP_EXIT, MEXIT_NEVER );
	menu_display( id, iMenu, 0 );
	
	bMenuOpen = true;

	set_task( float( get_pcvar_num( gCvarDuelMenuDuration ) ), "RemoveDuelMenu", id + TASK_FOUR );
	set_task( float( get_pcvar_num( gCvarDuelMenuDuration ) ), "RemoveDuelMenu", gDuelPlayerT + TASK_FOUR );
}

public menu_handler( id, menu, item )
{
	new szData[ 6 ], szName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access,  szData, charsmax( szData ), szName, charsmax( szName ), callback );

	new iKey = str_to_num( szData );
	
	new iTerOrigin[ 3 ];
	get_user_origin( gDuelPlayerT, iTerOrigin, 0 );

	iTerOrigin[ 2 ] += 80;

	switch( iKey )
	{
		case 1:
		{
			bDuelStarted = true;
			bMenuOpen = false;

			set_user_origin( gDuelPlayerCT, iTerOrigin );

			if( get_pcvar_num( gCvarDuelFx ) == 1 )
			{
				UTIL_TeleportFX( iTerOrigin );
				emit_sound( gDuelPlayerCT, CHAN_STATIC, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}

			EnableDuelLoading( );
			remove_task( gDuelPlayerCT + TASK_FOUR );
			remove_task( gDuelPlayerT + TASK_FOUR );

			UTIL_GiveWeapon( gDuelPlayerCT, "weapon_scout", CSW_SCOUT, get_pcvar_num( gCvarScoutBpAmmo ) );
			UTIL_GiveWeapon( gDuelPlayerT, "weapon_scout", CSW_SCOUT, get_pcvar_num( gCvarScoutBpAmmo ) );
			
			ColorChat( gDuelPlayerCT, RED, "^3%s^4 Duelul^1 selectat este: ^4Scout^1 !", gPluginTag );
			ColorChat( gDuelPlayerT, RED, "^3%s^4 Duelul^1 selectat este: ^4Scout^1 !", gPluginTag );
		
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
		
		case 2:
		{
			bDuelStarted = true;
			bMenuOpen = false;

			set_user_origin( gDuelPlayerCT, iTerOrigin );

			if( get_pcvar_num( gCvarDuelFx ) == 1 )
			{
				UTIL_TeleportFX( iTerOrigin );
				emit_sound( gDuelPlayerCT, CHAN_STATIC, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}

			EnableDuelLoading( );
			remove_task( gDuelPlayerCT + TASK_FOUR );
			remove_task( gDuelPlayerT + TASK_FOUR );

			UTIL_GiveWeapon( gDuelPlayerCT, "weapon_deagle", CSW_DEAGLE, get_pcvar_num( gCvarDeagleBpAmmo ) );
			UTIL_GiveWeapon( gDuelPlayerT, "weapon_deagle", CSW_DEAGLE, get_pcvar_num( gCvarDeagleBpAmmo ) );
				
			ColorChat( gDuelPlayerCT, RED, "^3%s^4 Duelul^1 selectat este: ^4Deagle^1 !", gPluginTag );
			ColorChat( gDuelPlayerT, RED, "^3%s^4 Duelul^1 selectat este: ^4Deagle^1 !", gPluginTag );
		
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
		
		case 3:
		{
			bDuelStarted = true;
			bMenuOpen = false;

			set_user_origin( gDuelPlayerCT, iTerOrigin );

			if( get_pcvar_num( gCvarDuelFx ) == 1 )
			{
				UTIL_TeleportFX( iTerOrigin );
				emit_sound( gDuelPlayerCT, CHAN_STATIC, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}

			EnableDuelLoading( );
			remove_task( gDuelPlayerCT + TASK_FOUR );
			remove_task( gDuelPlayerT + TASK_FOUR );

			UTIL_GiveWeapon( gDuelPlayerCT, "weapon_awp", CSW_AWP, get_pcvar_num( gCvarAwpBpAmmo ) );
			UTIL_GiveWeapon( gDuelPlayerT, "weapon_awp", CSW_AWP, get_pcvar_num( gCvarAwpBpAmmo ) );
			
			ColorChat( gDuelPlayerCT, RED, "^3%s^4 Duelul^1 selectat este: ^4AWP^1 !", gPluginTag );
			ColorChat( gDuelPlayerT, RED, "^3%s^4 Duelul^1 selectat este: ^4AWP^1 !", gPluginTag );
				
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
		
		case 4:
		{
			bDuelStarted = true;
			bMenuOpen = false;

			set_user_origin( gDuelPlayerCT, iTerOrigin );

			if( get_pcvar_num( gCvarDuelFx ) == 1 )
			{
				UTIL_TeleportFX( iTerOrigin );
				emit_sound( gDuelPlayerCT, CHAN_STATIC, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}

			EnableDuelLoading( );
			remove_task( gDuelPlayerCT + TASK_FOUR );
			remove_task( gDuelPlayerT + TASK_FOUR );

			give_item( gDuelPlayerCT, "weapon_knife" );
			give_item( gDuelPlayerT, "weapon_knife" );
			
			ColorChat( gDuelPlayerCT, RED, "^3%s^4 Duelul^1 selectat este: ^4Cutit^1 !", gPluginTag );
			ColorChat( gDuelPlayerT, RED, "^3%s^4 Duelul^1 selectat este: ^4Cutit^1 !", gPluginTag );
			
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
		
		case 5:
		{
			bDuelStarted = true;
			bMenuOpen = false;

			new iRamboHealth = get_pcvar_num( gCvarRamboDuelHealth );
			
			set_user_health( gDuelPlayerCT, iRamboHealth );
			set_user_health( gDuelPlayerT, iRamboHealth );
			set_user_origin( gDuelPlayerCT, iTerOrigin );

			if( get_pcvar_num( gCvarDuelFx ) == 1 )
			{
				UTIL_TeleportFX( iTerOrigin );
				emit_sound( gDuelPlayerCT, CHAN_STATIC, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}

			EnableDuelLoading( );
			remove_task( gDuelPlayerCT + TASK_FOUR );
			remove_task( gDuelPlayerT + TASK_FOUR );

			UTIL_GiveWeapon( gDuelPlayerCT, "weapon_m249", CSW_M249, get_pcvar_num( gCvarRamboBpAmmo ) );
			UTIL_GiveWeapon( gDuelPlayerT, "weapon_m249", CSW_M249, get_pcvar_num( gCvarRamboBpAmmo ) );
			
			ColorChat( gDuelPlayerCT, RED, "^3%s^4 Duelul^1 selectat este: ^4M249^1 !", gPluginTag );
			ColorChat( gDuelPlayerT, RED, "^3%s^4 Duelul^1 sselectat este: ^4M249^1 !", gPluginTag );
			
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
		
		case 6:
		{
			set_user_origin( gDuelPlayerCT, iTerOrigin );

			if( get_pcvar_num( gCvarDuelFx ) == 1 )
			{
				UTIL_TeleportFX( iTerOrigin );
				emit_sound( gDuelPlayerCT, CHAN_STATIC, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}

			EnableDuelLoading( );
			remove_task( gDuelPlayerCT + TASK_FOUR );
			remove_task( gDuelPlayerT + TASK_FOUR );

			bSprayDuelSelected = true;
			bMenuOpen = false;

			bPlayerCountSpray[ gDuelPlayerCT ] = 0;
			bPlayerCountSpray[ gDuelPlayerT ] = 0;
			
			give_item( gDuelPlayerCT, "weapon_knife" );
			give_item( gDuelPlayerT, "weapon_knife" );
		
			ColorChat( gDuelPlayerCT, RED, "^3%s^4 Duelul^1 selectat este: ^4Spray^1 !", gPluginTag );
			ColorChat( gDuelPlayerT, RED, "^3%s^4 Duelul^1 sselectat este: ^4Spray^1 !", gPluginTag );

			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
		
		case 7:
		{
			bDuelStarted = true;
			bMenuOpen = false;

			set_user_origin( gDuelPlayerCT, iTerOrigin );

			if( get_pcvar_num( gCvarDuelFx ) == 1 )
			{
				UTIL_TeleportFX( iTerOrigin );
				emit_sound( gDuelPlayerCT, CHAN_STATIC, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}

			EnableDuelLoading( );
			remove_task( gDuelPlayerCT + TASK_FOUR );
			remove_task( gDuelPlayerT + TASK_FOUR );

			give_item( gDuelPlayerCT, "weapon_hegrenade" );
			give_item( gDuelPlayerT, "weapon_hegrenade" );
			
			ColorChat( gDuelPlayerCT, RED, "^3%s^4 Duelul^1 selectat este: ^4Grenade^1 !", gPluginTag );
			ColorChat( gDuelPlayerT, RED, "^3%s^4 Duelul^1 selectat este: ^4Grenade^1 !", gPluginTag );
			
			menu_destroy( menu );

			return PLUGIN_HANDLED;
		}
	}

	menu_destroy( menu );

	return PLUGIN_HANDLED;
}

public RemoveDuelMenu( taskiD )
{
	new id = taskiD - TASK_FOUR;

	if( IS_PLAYER( id ) )
	{
		set_user_health( id, bPlayerData[ id ][ DATA_HEALTH ] );
		set_user_armor( id, bPlayerData[ id ][ DATA_ARMOR ] );
		set_user_godmode( id, 0 );
		set_user_rendering( id );
	
		remove_task( id );
		remove_task( id + TASK_FOUR );
		remove_task( id + TASK_THREE );

		bDuelStarted = false;
		bSprayDuel = false;
		bSprayDuelSelected = false;
		bMenuOpen = false;

		new iWeapons = bPlayerData[ id ][ DATA_WEAPONS ];
		new szWeapon[ 32 ], i;
	
		for( i = CSW_P228; i <= CSW_P90; i++ )
		{
			if( ( 1 & ( iWeapons >> i ) ) && ( i != 2 ) && ( i != CSW_C4 ) )
    			{
        			get_weaponname( i, szWeapon, charsmax( szWeapon ) );
       				give_item( id, szWeapon );
		
				UTIL_RestoreBpAmmo( id );
    			}
		}

		show_menu( id, 0, "^n", 1 );
	}
}

public RoundStart( )
{
	bRoundEnded = false;
	bDuelStarted = false;	
	bSprayDuel = false;
	bSprayDuelSelected = false;
	bMenuOpen = false;

	gDuelPlayerCT = 0;
	gDuelPlayerT = 0;
	gTimerCount = 0;
	
	remove_task( TASK_ONE );
	remove_task( TASK_TWO );
	remove_task( TASK_FIVE );
	remove_task( TASK_SIX );
	remove_task( TASK_SEVEN );
	remove_task( TASK_EIGHT );

	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_connected( i ) )
		{
			set_user_rendering( i );
			set_user_godmode( i, 0 );

			give_item( i, "weapon_knife" );
			client_cmd( i, "mp3 stop" );

			remove_task( i + TASK_THREE );
			remove_task( i + TASK_FOUR );
			remove_task( i );
		}
	}
}

public RoundEnd( )
{
	bRoundEnded = true;
	bDuelStarted = false;
	bSprayDuel = false;
	bSprayDuelSelected = false;
	bMenuOpen = false;

	gDuelPlayerCT = 0;
	gDuelPlayerT = 0;
	gTimerCount = 0;
	
	remove_task( TASK_ONE );
	remove_task( TASK_TWO );
	remove_task( TASK_FIVE );
	remove_task( TASK_SIX );
	remove_task( TASK_SEVEN );
	remove_task( TASK_EIGHT );

	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_connected( i ) )
		{
			set_user_rendering( i );
			set_user_godmode( i, 0 );

			give_item( i, "weapon_knife" );
			client_cmd( i, "mp3 stop" );

			remove_task( i + TASK_THREE );
			remove_task( i + TASK_FOUR );
			remove_task( i );
		}
	}
}

public CommandDropWeapon( id )
{
	if( bDuelStarted == true 
	|| bSprayDuel == true
	|| bMenuOpen == true 
	|| bSprayDuelSelected == true )
	{
		client_print( id, print_center, "Duel in progres! Nu poti arunca arma!" );
	
		return PLUGIN_HANDLED;	
	}
	
	return PLUGIN_CONTINUE;
}

public bacon_TouchWeapon( iWeapon, id )
{
	if( !is_user_connected( id ) )
	{
		return HAM_IGNORED;
	}
	
	if( bDuelStarted == true 
	|| bSprayDuel == true 
	|| bMenuOpen == true
	|| bSprayDuelSelected == true )
	{	
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public EnableDuelLoading( )
{
	remove_task( TASK_ONE );
	remove_task( TASK_TWO );

	new iTimer = get_pcvar_num( gCvarDuelTimeout );

	set_task( float( iTimer ), "StartDuel", TASK_ONE );
	set_task( 1.0, "ShowTimer", TASK_TWO, _, _, "a", iTimer );
}

public ShowTimer( iTaskid )
{
	gTimerCount++;
	
	new iTimer = get_pcvar_num( gCvarDuelTimeout ) - gTimerCount;

	set_hudmessage( 42, 42, 255, -1.0, 0.04, 1, 6.0, 1.0 );
	ShowSyncHudMsg( 0, gHudSync2, "Duelul va incepe in %d secunde!", iTimer );
	
	if( iTimer <= 3 )
	{
		new szNumToWord[ 20 ];
		num_to_word( iTimer, szNumToWord, charsmax( szNumToWord ) );
		
		client_cmd( 0, "speak ^"fvox/%s^"", szNumToWord );
	}
}

public StartDuel( iTaskid )
{
	new szCTName[ 32 ], szTName[ 32 ];
	
	get_user_name( gDuelPlayerCT, szCTName, charsmax( szCTName ) );
	get_user_name( gDuelPlayerT, szTName, charsmax( szTName ) );

	set_hudmessage( 255, 127, 0, -1.0, 0.0, 1, 6.0, 8.0 );
	
	if( bSprayDuelSelected == true )
	{
		bSprayDuel = true;

		set_user_godmode( gDuelPlayerCT, 1 );
		set_user_godmode( gDuelPlayerT, 1 );
		
		set_pdata_float( gDuelPlayerCT, m_flNextDecalTime, 0.0, m_iXtraOffPlayer );
		set_pdata_float( gDuelPlayerT, m_flNextDecalTime, 0.0, m_iXtraOffPlayer );

		set_task( 0.2, "ShowPlayersSprayCound", TASK_SIX, _, _, "b" );
		set_task( float( get_pcvar_num( gCvarDuelSprayTime ) ), "EndDuelSpray", TASK_SEVEN );

		ShowSyncHudMsg( 0, gHudSync, "^nDuelul a inceput!^n%s Vs. %s^n^nCare pune cele mai multe spray-uri in [%d] secunde castiga!", szCTName, szTName, get_pcvar_num( gCvarDuelSprayTime ) );
	}
	
	else
	{
		set_user_godmode( gDuelPlayerCT, 0 );
		set_user_godmode( gDuelPlayerT, 0 );

		ShowSyncHudMsg( 0, gHudSync, "^nDuelul a inceput!^n%s Vs. %s^n>--(*_*)-->", szCTName, szTName );
	}
	
	remove_task( TASK_ONE );
	remove_task( TASK_TWO );

	gTimerCount = 0;

	ColorChat( 0, RED, "^3%s^1 Duelul a inceput: ^4%s^1 Vs.^4 %s^1 !", gPluginTag, szCTName, szTName );
	client_cmd( 0, "speak ^"%s^"", gDuelStartSound );
	set_task( DUELMUSIC_DELAY, "PlayDuelMusic", TASK_FIVE );
}

public ShowPlayersSprayCound( tid )
{
	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_alive( i ) && is_user_connected( i ) )
		{
			if( i == gDuelPlayerCT )
			{
				new szName[ 32 ];
				get_user_name( i, szName, charsmax( szName ) );

				set_hudmessage( 0, 0, 255, 0.02, 0.27, 1, 6.0, 0.0 );
				ShowSyncHudMsg( 0, gHudSync3, "Nume: %s^nSpray-uri = %d", szName, bPlayerCountSpray[ gDuelPlayerCT ] );
			}
			
			if( i == gDuelPlayerT )
			{
				new szName[ 32 ];
				get_user_name( i, szName, charsmax( szName ) );

				set_hudmessage( 255, 0, 0, 0.02, 0.19, 1, 6.0, 0.0 );
				ShowSyncHudMsg( 0, gHudSync4, "Nume: %s^nSpray-uri = %d", szName, bPlayerCountSpray[ gDuelPlayerT ] );
			}
		}
	}
}

public EndDuelSpray( dsad )
{
	remove_task( TASK_SIX );
	remove_task( TASK_SEVEN );

	new szName1[ 32 ], szName2[ 32 ];

	get_user_name( gDuelPlayerCT, szName1, charsmax( szName1 ) );
	get_user_name( gDuelPlayerT, szName2, charsmax( szName2 ) );

	if( bPlayerCountSpray[ gDuelPlayerCT ] > bPlayerCountSpray[ gDuelPlayerT ] )
	{
		ColorChat( 0, RED, "^3%s^4 %s^1 l-a invins pe^4 %s^1 cu scorul:^4 %d^1 -^4 %d", gPluginTag, szName1, szName2, bPlayerCountSpray[ gDuelPlayerCT ], bPlayerCountSpray[ gDuelPlayerT ] );
				
		bPlayerCountSpray[ gDuelPlayerCT ] = 0;
		bPlayerCountSpray[ gDuelPlayerT ] = 0;
				
		ExecuteHamB( Ham_Killed, gDuelPlayerT, gDuelPlayerCT, GIB_ALWAYS );
		UTIL_ScoreInfo( gDuelPlayerCT );
	}
			
	else if( bPlayerCountSpray[ gDuelPlayerCT ] < bPlayerCountSpray[ gDuelPlayerT ] )
	{
		ColorChat( 0, RED, "^3%s^4 %s^1 l-a invins pe^4 %s^1 cu scorul:^4 %d^1 -^4 %d", gPluginTag, szName2, szName1, bPlayerCountSpray[ gDuelPlayerT ], bPlayerCountSpray[ gDuelPlayerCT ] );
				
		bPlayerCountSpray[ gDuelPlayerCT ] = 0;
		bPlayerCountSpray[ gDuelPlayerT ] = 0;
				
		ExecuteHamB( Ham_Killed, gDuelPlayerCT, gDuelPlayerT, GIB_ALWAYS );
		UTIL_ScoreInfo( gDuelPlayerT );
	}
			
	else
	{
		new iTieTime = get_pcvar_num( gCvarTieDecideTime );

		set_task( float( iTieTime ), "DecideWinner", TASK_EIGHT );
		client_cmd( 0, "speak ^"fvox/near_death immediately^"" );

		ColorChat( 0, RED, "^3%s^1 Remiza intre jucatorii:^4 %s^1 si^4 %s^1 ! Unul va fi condamnat la moarte in^4 %d^1 secunde!", gPluginTag, szName1, szName2, iTieTime );
	}
}
	
public DecideWinner( dasa )
{
	remove_task( TASK_EIGHT );

	new iRandomWinner = random_num( 1, 2 );

	new szName1[ 32 ], szName2[ 32 ];

	get_user_name( gDuelPlayerCT, szName1, charsmax( szName1 ) );
	get_user_name( gDuelPlayerT, szName2, charsmax( szName2 ) );

	switch( iRandomWinner )
	{
		case 1:
		{
			ColorChat( 0, RED, "^3%s^1 Remiza castigata de catre:^4 %s^1!", gPluginTag, szName1 );
			ExecuteHamB( Ham_Killed, gDuelPlayerT, gDuelPlayerCT, GIB_ALWAYS );
			
			UTIL_ScoreInfo( gDuelPlayerCT );
		}
		
		case 2:
		{
			ColorChat( 0, RED, "^3%s^1 Remiza castigata de catre:^4 %s^1!", gPluginTag, szName2 );
			ExecuteHamB( Ham_Killed, gDuelPlayerCT, gDuelPlayerT, GIB_ALWAYS );
		
			UTIL_ScoreInfo( gDuelPlayerT );
		}
	}
}
	
public PlayDuelMusic( tasKid )
{
	remove_task( TASK_FIVE );
	
	client_cmd( gDuelPlayerCT, "mp3 play ^"%s.mp3^"", gDuelMusicSounds[ random_num( 0, charsmax( gDuelMusicSounds ) ) ] );
	client_cmd( gDuelPlayerT, "mp3 play ^"%s.mp3^"", gDuelMusicSounds[ random_num( 0, charsmax( gDuelMusicSounds ) ) ] );
}

public ShowWaveFX( iTaskid )
{
	new id = iTaskid - TASK_THREE;

	if( IS_PLAYER( id ) && is_user_alive( id ) && is_user_connected( id ) )
	{
		new iOrigin[ 3 ];
		get_user_origin( id, iOrigin, 0 );

		if( pev( id, pev_flags ) & FL_DUCKING )
		{
			iOrigin[ 2 ] += 17;
		}

		if( id == gDuelPlayerCT )
		{
			UTIL_WaveFX( iOrigin, 10, 10, 255 );
		}	
		
		if( id == gDuelPlayerT )
		{
			UTIL_WaveFX( iOrigin, 255, 10, 10 );
		}
		
		set_task( WAVE_DELAY, "ShowWaveFX", id + TASK_THREE );
	}
	
	else
	{
		remove_task( id + TASK_THREE );
	}
}

stock bool:UTIL_FindPlayers( )
{
	new iNum[ 2 ];

	for( i = 1 ; i <= gMaxPlayers ; i++ )
	{
		if( !is_user_alive( i ) )
		{
			continue;
		}
		
		if( cs_get_user_team( i ) == CS_TEAM_T )
		{
			++iNum[ 0 ];
			
			if( iNum[ 0 ] == 1 )
			{
				gDuelPlayerT = i;
			}
			
			else
			{
				gDuelPlayerT = 0;
			}
		}

		else if( cs_get_user_team( i ) == CS_TEAM_CT )
		{
			++iNum[ 1 ];
			
			if( iNum[ 1 ] == 1 )
			{
				gDuelPlayerCT = i;
			}
			
			else
			{
				gDuelPlayerCT = 0;
			}
		}
	}

	if( ( iNum[ 0 ] == 1 ) && ( iNum[ 1 ] == 1 ) )
	{
		return true;
	}
	
	return false;
}

stock UTIL_StoreBpAmmo( id ) 
{ 
	for( new rgpPlayerItems = m_rgpPlayerItems_338magnum; rgpPlayerItems <= m_rgpPlayerItems_c4; rgpPlayerItems++ ) 
    	{ 
        	bPlayerBpAmmo[ id ][ rgpPlayerItems ] = get_pdata_int( id, rgpPlayerItems, m_iXtraOffPlayer ); 
    	} 
} 

stock UTIL_RestoreBpAmmo( id ) 
{ 
	for( new rgpPlayerItems = m_rgpPlayerItems_338magnum; rgpPlayerItems <= m_rgpPlayerItems_c4; rgpPlayerItems++ ) 
    	{ 
        	set_pdata_int( id, rgpPlayerItems, bPlayerBpAmmo[ id ][ rgpPlayerItems ], m_iXtraOffPlayer ); 
    	} 
}  

stock UTIL_GiveWeapon( id, const szWeapon[ ], iCsw, iBpammo )
{
	if( is_user_alive( id ) && is_user_connected( id ) )
	{
		give_item( id, szWeapon );
		
		cs_set_user_bpammo( id, iCsw, iBpammo );
	}
}

stock UTIL_BeamFollow( iGrenId, iRed, iGreen, iBlue )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte( TE_BEAMFOLLOW );
	write_short( iGrenId );
	write_short( gArrowSprite );
	write_byte( 15 );
	write_byte( 7 );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( 255 );
	message_end( );
}
			
stock UTIL_ScreenFadeFX( id, iRed, iGreen, iBlue, iAlpha )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade, _, id );
   	write_short( 1<<10 );
   	write_short( 1<<10 );
   	write_short( FFADE_IN );
  	write_byte( iRed );
   	write_byte( iGreen );
   	write_byte( iBlue );
   	write_byte( iAlpha );
   	message_end( );
}

stock UTIL_WaveFX( iOrigin[ 3 ], iRed, iGreen, iBlue )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] - 29 );	
	write_coord( iOrigin[ 0 ] - 50 );	
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 100 );
	write_short( gRingSprite );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 5 );
	write_byte( 5 );
	write_byte( 0 );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( 200 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_TeleportFX( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_TELEPORT );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	message_end( );
}

stock UTIL_WeaponAnimation( id, iAnimation )
{
	set_pev( id, pev_weaponanim, iAnimation );

	message_begin( MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id );
	write_byte( iAnimation );
	write_byte( pev( id, pev_body ) );
	message_end( );
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
