#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <nvault>
#include <hamsandwich>
#include <fakemeta>


/* --| Let's force the semicolon on every endline */
#pragma semicolon 1

/* --| Some defines :) */
#define PICKUP_SND		"items/gunpickup2.wav"
#define HEALTH_SOUND		"items/smallmedkit1.wav"
#define ARMOR_SOUND		"items/ammopickup2.wav"
#define CLOACK_SOUND		"hornet/ag_buzz1.wav"
#define LJ_SOUND		"fvox/powermove_on.wav"
#define SOUND_NVGOFF		"items/nvg_off.wav"
#define ADMIN_ACCESS_CMD	ADMIN_KICK	
#define HAS_NVGS		(1<<0)
#define USES_NVGS		(1<<8)
#define get_user_nvg(%1)    	(get_pdata_int(%1,m_iNvg) & HAS_NVGS)

/* --| Plugin informations */
new const PLUGIN[] 	= "Deathrun Shop";
new const VERSION[] 	= "4.0";
new const AUTHOR[] 	= "tuty";
 
/* --| Zomg lot of globals :) */
new gDrShopOn;
new gHeCost;
new gBothGrenadesCost;
new gSilentCost;
new gHealthCost;
new gArmorCost;
new gSpeedCost;
new gGravityCost;
new gInvisCost;
new gSpeedCvar;
new gGravityCvar;
new gAdvertiseCvar;
new gHealthPointCvar;
new gArmorPointCvar;
new gAdvertiseTimeCvar;
new gInvisPercent;
new gKillerPointsCvar;
new gSuiciderPointsCvar;
new gSavePlayerPoints;
new gNoclipCost;
new gVault;
new gNoclipTime;
new gJetSprite;
new gJetPackCost;
new gJetTime;
new gDeagleCost;
new gMsgItemPickup;
new gLongJumpTime;
new gLongJumpCost;
new gGlowCost;
new gNvgCost;
new gMessageNVG;

/* --| Item variables */
new HasHe[ 33 ];
new HasBothGren[ 33 ];
new HasSilent[ 33 ];
new HasHealth[ 33 ];
new HasArmor[ 33 ];
new HasSpeed[ 33 ];
new HasGravity[ 33 ];
new HasInvis[ 33 ];
new HasNoclip[ 33 ];
new HasJet[ 33 ];
new HasDeagle[ 33 ];
new HasLongJump[ 33 ];
new HasGlow[ 33 ];
new HasNVG[ 33 ];
new gName[ 32 char ];
new gSteamID[ 32 ];
new vKey[ 64 ];
new vData[ 64 ];

/* --| Player points, need this to save points, load points, etc */
new gKillerPoints[ 33 ];

/* --| Offsets for nvg */
const m_iNvg = 129;
const m_iLinuxDiff = 5;

/* --| So, let's get started */
public plugin_init()
{
	/* --| Registering the plugin to show when you type amx_plugins.. */
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	/* --| Registering a little cvar to see wich servers using this plugin */
	register_cvar( "drshop_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY );

	/* --| Register some usefull events */
	register_logevent( "logevent_round_start", 2, "1=Round_Start" );
	register_event( "DeathMsg", "Hook_Deathmessage", "a" );
	register_event( "CurWeapon", "HookCurWeapon", "be", "1=1" );
	
	/* --| Called when a player is performing a jump */
	RegisterHam( Ham_Player_Jump, "player", "bacon_playerJumping" );
	
	/* --| We need this forward to find if player has suicided with kill in console */
	/* --| We can't do that on deathmsg because player die in traps by suicide,.. trigger_hurt or world.. etc */
	register_forward( FM_ClientKill, "forward_kill" );
	
	/* --| Command for setting points to player/@all */
	register_concmd( "deathrun_set_points", "cmdSetPoints", ADMIN_ACCESS_CMD, "<name/@all> <points> - set points to a player" );
	
	/* --| Command for reseting points to palyer/@all */
	register_concmd( "deathrun_reset_points", "cmdResetPoints", ADMIN_ACCESS_CMD, "<name/@all> - reset player points" );
	
	/* --| Command for opening the menu */
	register_clcmd( "say /drshop", "DeathrunShop" );
	register_clcmd( "say_team /drshop", "DeathrunShop" );
	
	/* --| Command to see our points :) */
	register_clcmd( "say /mypoints", "ShowPoints" );
	register_clcmd( "say_team /mypoints", "ShowPoints" );

	
	/* --| Let's register the cvars, a lot of cvars but huh.. stf :) */
	gDrShopOn = register_cvar( "deathrun_shop", "1" );
	gHeCost = register_cvar( "deathrun_he_cost", "10" ); 
	gBothGrenadesCost = register_cvar( "deathrun_bothgrenades_cost", "20" );
	gSilentCost = register_cvar( "deathrun_silent_cost", "24" );
	gHealthCost = register_cvar( "deathrun_health_cost", "30" );
	gArmorCost = register_cvar( "deathrun_armor_cost", "15" );
	gSpeedCost = register_cvar( "deathrun_speed_cost", "39" );
	gGravityCost = register_cvar( "deathrun_gravity_cost", "41" );
	gNoclipCost = register_cvar( "deathrun_noclip_cost", "50" );
	gJetPackCost = register_cvar( "deathrun_jetpack_cost", "60" );
	gInvisCost = register_cvar( "deathrun_invisibility_cost", "69" );
	gSpeedCvar = register_cvar( "deathrun_speed_power", "400.0" );
	gNoclipTime = register_cvar( "deathrun_noclip_duration", "2" );
	gJetTime = register_cvar( "deathrun_jetpack_duration", "10" );
	gDeagleCost = register_cvar( "deathrun_deagle_cost", "31" );
	gGravityCvar = register_cvar( "deathrun_gravity_power", "0.7" );
	gAdvertiseCvar = register_cvar( "deathrun_advertise_message", "1" );
	gHealthPointCvar = register_cvar( "deathrun_health_points", "255" );
	gArmorPointCvar = register_cvar( "deathrun_armor_points", "400" );
	gAdvertiseTimeCvar = register_cvar( "deathrun_advertise_time", "7.0" );
	gInvisPercent = register_cvar( "deathrun_invisibility_percentage", "111" );
	gKillerPointsCvar = register_cvar( "deathrun_killer_bonuspoints", "5" );
	gSuiciderPointsCvar = register_cvar( "deathrun_suicider_loose_points", "3" );
	gSavePlayerPoints = register_cvar( "deathrun_save_points", "1" );
	gLongJumpTime = register_cvar( "deathrun_longjump_duration", "6" );
	gLongJumpCost = register_cvar( "deathrun_longjump_cost", "46" );
	gGlowCost = register_cvar( "deathrun_glow_cost", "8" );
	gNvgCost = register_cvar( "deathrun_nvg_cost", "33" );

	/* --| Let's find/do some stuff here */
	gMsgItemPickup = get_user_msgid( "ItemPickup" );
	gMessageNVG = get_user_msgid( "NVGToggle" );
	
	/* --| Register the multilingual file */
	register_dictionary( "DeathrunShopLang.txt" );
}

/* --| Precache stuff */
public plugin_precache()
{
	gJetSprite = precache_model( "sprites/explode1.spr" );
	precache_sound( PICKUP_SND );
	precache_sound( HEALTH_SOUND );
	precache_sound( ARMOR_SOUND );
	precache_sound( CLOACK_SOUND );
	precache_sound( LJ_SOUND );
}

/* --| Plugin cfg, here we do some ugly shit ever -.- */
public plugin_cfg()
{
	new iCfgDir[ 32 ], iFile[ 192 ];
	
	/* --| We need to find the configs directory, and to add the configuration file */
	get_configsdir( iCfgDir, charsmax( iCfgDir ) );
	formatex( iFile, charsmax( iFile ), "%s/DeathrunShop_Cfg.cfg", iCfgDir );
		
	/* --| If file not exists, let's create one but empty */
	if( !file_exists( iFile ) )
	{
		server_print( "[DrShop] %L", LANG_SERVER, "DRSHOP_SVPRINT", iFile );
		write_file( iFile, " ", -1 );
	}
	
	/* --| Else, let's load the cvars from cfg */
	else
	{		
		server_print( "[DrShop] %L", LANG_SERVER, "DRSHOP_SVPRINT_DONE", iFile );
		server_cmd( "exec %s", iFile );
	}
	
	/* --| Set the server maxspeed to a high value, need it for speed item */
	server_cmd( "sv_maxspeed 99999999.0" );
}

/* --| When client is connecting, let's reset stuff and load client's points */
public client_connect( id )
{
	HasHe[ id ] = false;
	HasBothGren[ id ] = false;
	HasSilent[ id ] = false;
	HasHealth[ id ] = false;
	HasArmor[ id] = false;
	HasSpeed[ id ] = false;
	HasGravity[ id ] = false;
	HasInvis[ id ] = false;
	HasNoclip[ id ] = false;
	HasJet[ id ] = false;
	HasDeagle[ id ] = false;
	HasLongJump[ id ] = false;
	HasGlow[ id ] = false;
	HasNVG[ id ] = false;
	
	/* --| Load client points */
	load_client_points( id );
}

/* --| When client has disconnected let's reset stuff and save points */
public client_disconnect( id )
{
	HasHe[ id ] = false;
	HasBothGren[ id ] = false;
	HasSilent[ id ] = false;
	HasHealth[ id ] = false;
	HasArmor[ id] = false;
	HasSpeed[ id ] = false;
	HasGravity[ id ] = false;
	HasInvis[ id ] = false;
	HasNoclip[ id ] = false;
	HasJet[ id ] = false;
	HasDeagle[ id ] = false;
	HasLongJump[ id ] = false;
	HasGlow[ id ] = false;
	HasNVG[ id ] = false;
	
	/* --| If player is not a bot, let's save the points */
	if( get_pcvar_num( gSavePlayerPoints ) != 0 && !is_user_bot( id ) )
	{
		/* --| Save player points is cvar is 1 */
		save_client_points( id );
	}
}

/* --| When client has entered on sv, need to show him a hudmessage :) */
public client_putinserver( id )
{
	if( get_pcvar_num( gAdvertiseCvar ) != 0 )
	{
		/* --| Need to set task, 7 default because need to wait for player choosing a team or something */
		set_task( get_pcvar_float( gAdvertiseTimeCvar ), "ShowPlayerInfo", id );
	}
}

/* --| Deathrun shop menu with items ^^ */
public DeathrunShop( id )
{
	/* --| If cvar is set to 0, player can't open the shop */
	if( get_pcvar_num( gDrShopOn ) != 1 )
	{
		client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_DISABLED" );
		return PLUGIN_HANDLED;
	}
	
	/* --| If player is dead, cant buy items :) */
	if( !is_user_alive( id ) )
	{
		client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_ONLY_ALIVE" );
		return PLUGIN_HANDLED;
	}
	
	/* --| Menu stuff */
	new szText[ 555 char ];
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_MENU_TITLE", VERSION, gKillerPoints[ id ] );
	
	new menu = menu_create( szText, "shop_handler" );

	/* --| Menu item 1 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_1", get_pcvar_num( gHeCost ) );
	menu_additem( menu, szText, "1", 0 );
	
	/* --| Menu item 2 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_2", get_pcvar_num( gBothGrenadesCost ) );
	menu_additem( menu, szText, "2", 0 );
	
	/* --| Menu item 3 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_3", get_pcvar_num( gSilentCost ) );
	menu_additem( menu, szText, "3", 0 );
	
	/* --| Menu item 4 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_4", get_pcvar_num( gHealthPointCvar ), get_pcvar_num( gHealthCost ) );
	menu_additem( menu, szText, "4", 0 );
	
	/* --| Menu item 5 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_5", get_pcvar_num( gArmorPointCvar ), get_pcvar_num( gArmorCost ) );
	menu_additem( menu, szText, "5", 0 );
	
	/* --| Menu item 6 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_6", get_pcvar_num( gSpeedCost ) );
	menu_additem( menu, szText, "6", 0 );
	
	/* --| Menu item 7 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_7", get_pcvar_num( gGravityCost ) );
	menu_additem( menu, szText, "7", 0 );
	
	/* --| Menu item 8 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_8", get_pcvar_num( gInvisPercent ), get_pcvar_num( gInvisCost ) );
	menu_additem( menu, szText, "8", 0 );
	
	/* --| Menu item 9 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_9", get_pcvar_num( gNoclipTime ), get_pcvar_num( gNoclipCost ) );
	menu_additem( menu, szText, "9", 0 );
	
	/* --| Menu item 10 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_10", get_pcvar_num( gJetTime ), get_pcvar_num( gJetPackCost ) );
	menu_additem( menu, szText, "10", 0 );
	
	/* --| Menu item 11 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_11", get_pcvar_num( gDeagleCost ) );
	menu_additem( menu, szText, "11", 0 );
	
	/* --| Menu item 12 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_12", get_pcvar_num( gLongJumpTime ), get_pcvar_num( gLongJumpCost ) );
	menu_additem( menu, szText, "12", 0 );
	
	/* --| Menu item 13 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_13", get_pcvar_num( gGlowCost ) );
	menu_additem( menu, szText, "13", 0 );
	
	/* --| Menu item 14 */
	formatex( szText, charsmax( szText ), "%L", id, "DRSHOP_ITEM_14", get_pcvar_num( gNvgCost ) );
	menu_additem( menu, szText, "14", 0 );
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	
	/* --| Show the menu, with current page 0 */
	menu_display( id, menu, 0 );

	return PLUGIN_CONTINUE;
}

/* --| Menu commands */
public shop_handler( id, menu, item )
{
	/* --| If key is 0, let's close the menu */
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	/* --| Getting the menu information */
	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );

	/* --| Get menu keys */
	new key = str_to_num( data );
	
	/* --| Here we find the player points */
	new points = gKillerPoints[ id ];
	
	switch( key )
	{
		/* --| Menu item 1 */
		case 1:
		{
			/* --| If already has item, show a damn print and return */
			if( HasHe[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gHeCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */
			give_item( id, "weapon_hegrenade" );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_GRENADE_ITEM" );
			HasHe[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gHeCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 0 );
		}
		
		/* --| Menu item 2 */
		case 2:
		{
			/* --| If already has item, show a damn print and return */
			if( HasBothGren[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gBothGrenadesCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */
			give_item( id, "weapon_hegrenade" );
			give_item( id, "weapon_flashbang" );
			give_item( id, "weapon_flashbang" );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_BOTHGREN_ITEM" );
			HasBothGren[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gBothGrenadesCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 0 );
		}
		
		/* --| Menu item 3 */
		case 3:
		{
			/* --| If already has item, show a damn print and return */
			if( HasSilent[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gSilentCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}	
			
			/* --| Let's give the item, and do some stuff */
			set_user_footsteps( id, 1 );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_SILENTWALK_ITEM" );
			HasSilent[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gSilentCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 0 );
		}
		
		/* --| Menu item 4 */
		case 4:
		{
			/* --| If already has item, show a damn print and return */
			if( HasHealth[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gHealthCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_user_health( id, get_user_health( id ) + get_pcvar_num( gHealthPointCvar ) );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_HEALTH_ITEM", get_pcvar_num( gHealthPointCvar ) );
			HasHealth[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gHealthCost );
			emit_sound( id, CHAN_ITEM, HEALTH_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 0 );
		}
		
		/* --| Menu item 5 */
		case 5:
		{
			/* --| If already has item, show a damn print and return */
			if( HasArmor[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gArmorCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_user_armor( id, get_user_armor( id ) + get_pcvar_num( gArmorPointCvar ) );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_ARMOR_ITEM", get_pcvar_num( gArmorPointCvar ) );	
			HasArmor[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gArmorCost );
			emit_sound( id, CHAN_ITEM, ARMOR_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 0 );
		}
		
		/* --| Menu item 6 */
		case 6:
		{
			/* --| If already has item, show a damn print and return */
			if( HasSpeed[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gSpeedCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_user_maxspeed( id, get_pcvar_float( gSpeedCvar ) );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_SPEED_ITEM" );
			HasSpeed[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gSpeedCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 0 );
		}
		
		/* --| Menu item 7 */
		case 7:
		{
			/* --| If already has item, show a damn print and return */
			if( HasGravity[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gGravityCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_user_gravity( id, get_pcvar_float( gGravityCvar ) );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_GRAVITY_ITEM" );
			HasGravity[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gGravityCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 0 );
		}
		
		/* --| Menu item 8 */
		case 8:
		{
			/* --| If already has item, show a damn print and return */
			if( HasInvis[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
		
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gInvisCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, get_pcvar_num( gInvisPercent ) );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_INVISIBILITY_ITEM" );
			HasInvis[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gInvisCost );
			emit_sound( id, CHAN_ITEM, CLOACK_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 1 );
		}
		
		/* --| Menu item 9 */
		case 9:
		{
			/* --| If already has item, show a damn print and return */
			if( HasNoclip[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
		
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gNoclipCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_task( float( get_pcvar_num( gNoclipTime ) ), "remove_noclip", id );
			set_user_noclip( id, 1 );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_NOCLIP_ITEM" );
			HasNoclip[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gNoclipCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 1 );
		}
		
		/* --| Menu item 10 */
		case 10:
		{
			/* --| If already has item, show a damn print and return */
			if( HasJet[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
		
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gJetPackCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_task( float( get_pcvar_num( gJetTime ) ), "remove_jetpack", id );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_JETPACK_ITEM" );
			HasJet[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gJetPackCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 1 );
		}
		
		/* --| Menu item 11 */
		case 11:
		{
			/* --| If already has item, show a damn print and return */
			if( HasDeagle[ id ] || user_has_weapon( id, CSW_DEAGLE ) )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
		
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gDeagleCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			strip_user_weapons( id );
			give_item( id, "weapon_knife" );
			give_item( id, "weapon_deagle" );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_DEAGLE_ITEM" );
			HasDeagle[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gDeagleCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 1 );
		}
		
		/* --| Menu item 12 */
		case 12:
		{
			/* --| If already has item, show a damn print and return */
			if( HasLongJump[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
		
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gLongJumpCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			/* --| Setting the temporary long jump */
			set_temporary_longjump( id );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_LJ_ITEM" );
			HasLongJump[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gLongJumpCost );
			emit_sound( id, CHAN_ITEM, LJ_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 1 );
		}
		
		/* --| Menu item 13 */
		case 13:
		{
			/* --| If already has item, show a damn print and return */
			if( HasGlow[ id ] )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
		
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gGlowCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_user_rendering( id, kRenderFxGlowShell, random( 256 ), random( 256 ), random( 256 ), kRenderNormal, random( 256 ) );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_GLOW_ITEM" );
			HasGlow[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gGlowCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 1 );
		}
		
		/* --| Menu item 13 */
		case 14:
		{
			/* --| If already has item, show a damn print and return */
			if( HasNVG[ id ] || get_user_nvg( id ) )
			{
				allready_have( id );
				return PLUGIN_HANDLED;
			}
		
			/* --| If player does not have enough points, show a print and return */
			if( points < get_pcvar_num( gNvgCost ) )
			{
				dont_have( id );
				return PLUGIN_HANDLED;
			}
			
			/* --| Let's give the item, and do some stuff */ 
			set_user_nvg( id, 1 );
			
			client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_NVG_ITEM" );
			HasNVG[ id ] = true;
			
			gKillerPoints[ id ] -= get_pcvar_num( gNvgCost );
			emit_sound( id, CHAN_ITEM, PICKUP_SND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
			menu_display( id, menu, 1 );
		}
	}
	
	return PLUGIN_HANDLED;
}

/* --| Command for setting points | admin only ;/ */
public cmdSetPoints( id, level, cid )
{
	/* --| If user doesn't have acces to command, return */
	if( !cmd_access( id, level, cid, 2 ) || !get_pcvar_num( gDrShopOn ) )
	{
		return PLUGIN_HANDLED; 
	}
	
	/* --| Need to read the first argument */
	new argument[ 32 ];
   	read_argv( 1, argument, charsmax( argument ) );

	/* --| Need to read second argument */
	new give_points[ 5 ];
	read_argv( 2, give_points, charsmax( give_points ) );

	/* --| We are getting the gift from second argument */
	new gift = str_to_num( give_points );
	
	new iPlayer[ 32 ], iNum, all;
	get_players( iPlayer, iNum, "c" );

	/* --| Lets see if argument 1 is @all */
	if( equal( argument, "@all" ) )
	{
		for( new i; i < iNum; i++ )
		{
			/* --| Find the index :) */
			all = iPlayer[ i ];
			
			/* --| Set points to all */
			gKillerPoints[ all ] = gKillerPoints[ all ] + gift;
			
			/* --| Show a print in chat */
			get_user_name( id, gName, charsmax( gName ) );
			client_print( 0, print_chat, "[DrShop] %L", LANG_PLAYER, "DRSHOP_SHOW_ALLCMD", gName, gift );
		}
	}
			
	else
	{
		/* --| Now, we find the target */
		new player = cmd_target( id, argument, 10 );

		/* --| If is not a valid target, return */
		if( !player ) 
		{
  			 return PLUGIN_HANDLED;
		}
	

		/* --| Get admin, and target name */
		new TargetName[ 32 char ];
		get_user_name( player, TargetName, charsmax( TargetName ) );
		get_user_name( id, gName, charsmax( gName ) );	
	
		/* --| Setting target points */
		gKillerPoints[ player ] = gKillerPoints[ player ] + gift;
		client_print( 0, print_chat, "[DrShop] %L", LANG_PLAYER, "DRSHOP_SHOW_CMD", gName, gift, TargetName );
	}

	return PLUGIN_HANDLED;
}

/* --| Command for reseting points | admin only ;/ */
public cmdResetPoints( id, level, cid )
{
	/* --| If user doesn't have acces to command, return */
	if( !cmd_access( id, level, cid, 2 ) || !get_pcvar_num( gDrShopOn ) )
	{
		return PLUGIN_HANDLED; 
	}
	
	/* --| Need to read the first argument */
	new argument[ 32 ];
   	read_argv( 1, argument, charsmax( argument ) );
	
	new iPlayer[ 32 ], iNum, all;
	get_players( iPlayer, iNum, "c" );

	/* --| Lets see if argument 1 is @all */
	if( equal( argument, "@all" ) )
	{
		for( new i; i < iNum; i++ )
		{
			/* --| Find the index :) */
			all = iPlayer[ i ];
			
			/* --| Set points to all */
			gKillerPoints[ all ] = 0;
			
			/* --| Show a print in chat */
			get_user_name( id, gName, charsmax( gName ) );
			client_print( 0, print_chat, "[DrShop] %L", LANG_PLAYER, "DRSHOP_SHOWRESET_ALLCMD", gName );
		}
	}
			
	else
	{
		/* --| Now, we find the target */
		new player = cmd_target( id, argument, 10 );

		/* --| If is not a valid target, return */
		if( !player ) 
		{
  			 return PLUGIN_HANDLED;
		}
	

		/* --| Get admin, and target name */
		new TargetName[ 32 char ];
		get_user_name( player, TargetName, charsmax( TargetName ) );
		get_user_name( id, gName, charsmax( gName ) );	
	
		/* --| Setting target points */
		gKillerPoints[ player ] = 0;
		client_print( 0, print_chat, "[DrShop] %L", LANG_PLAYER, "DRSHOP_SHOWRESET_CMD", gName, TargetName );
	}

	return PLUGIN_HANDLED;
}
	
/* --| We need to find if player has performed a jump, and set some velocity */
public bacon_playerJumping( id )
{
	/* --| If plugin is on, and user has jetpack item */
	if( get_pcvar_num( gDrShopOn ) != 0 && HasJet[ id ] )
	{
		/* --| Get user origins from feet */
		new iOrigin[ 3 ];
		get_user_origin( id, iOrigin, 0 );
		
		/* --| Modify origin a bit */
		iOrigin[ 2 ] -= 20;
		
		/* --| Get player velocity */
		new Float:fVelocity[ 3 ];
		pev( id, pev_velocity, fVelocity );

		/* --| Modify velocity a bit */
		fVelocity[ 2 ] += 93;
		
		/* --| Set the player velocity and add a flame effect, jetpack style */
		set_pev( id, pev_velocity, fVelocity );
		create_flame( iOrigin );
	}
}	

/* --| We need to check is player has changed his weapon */
public HookCurWeapon( id )
{
	/* --| If plugin is on, and user has speed item, let's set the speed again */
	if( get_pcvar_num( gDrShopOn ) != 0 && HasSpeed[ id ] )
	{
		set_user_maxspeed( id, get_pcvar_float( gSpeedCvar ) );
	}
}

/* --| Command for show points */	
public ShowPoints( id )
{
	/* --| Set a hud message */
	set_hudmessage( 255, 42, 212, 0.03, 0.86, 2, 6.0, 5.0 );
	
	/* --| We show player points on hud */
	show_hudmessage( id, "[DrShop] %L", id, "DRSHOP_POINTS_INFO", gKillerPoints[ id ] );
	
	/* --| We show player points on chat */
	client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_POINTS_INFO", gKillerPoints[ id ] );
	
	return PLUGIN_CONTINUE;
}

/* --| Here we show player hud information about this god damn shop */
public ShowPlayerInfo( id )
{
	/* --| Set a hud message */
	set_hudmessage( 0, 0, 255, -1.0, 0.82, 0, 6.0, 12.0 );
	
	/* --| Now we show the info message in hud channel */
	show_hudmessage( id, "%L", id, "DRSHOP_HUD_INFO" );
}

/* --| If player has suicided by console */
public forward_kill( id )
{
	/* --| Check if plugin is on, and user is alive */
	if( get_pcvar_num( gDrShopOn ) == 1 && is_user_alive( id ) )
	{
		/* --| Set player points with suicide cvar */
		client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_SHOW_LOOSER", get_pcvar_num( gSuiciderPointsCvar ) );
		gKillerPoints[ id ] -= get_pcvar_num( gSuiciderPointsCvar );
	}
}

/* --| Event for round start */		
public logevent_round_start()
{
	/* --| If plugin is on... */
	if( get_pcvar_num( gDrShopOn ) == 1 )
	{
		/* --| I used this native because with get_maxplayers will recieve a damn error with invalid player id.. */
		/* --| This is good because we can skip the damn bots */
		new iPlayers[ 32 ], iNum, i, id;
		get_players( iPlayers, iNum, "c" );
		
		for( i = 0; i < iNum; i++ )
		{
			/* --| Find the index :) */
			id = iPlayers[ i ];
			
			/* --| Reseting items */
			HasHe[ id ] = false;
			HasBothGren[ id ] = false;
			HasSilent[ id ] = false;
			HasHealth[ id ] = false;
			HasArmor[ id] = false;
			HasSpeed[ id ] = false;
			HasGravity[ id ] = false;
			HasInvis[ id ] = false;
			HasNoclip[ id ] = false;
			HasJet[ id ] = false;
			HasDeagle[ id ] = false;
			HasLongJump[ id ] = false;
			HasGlow[ id ] = false;
			HasNVG[ id ] = false;
			
			set_user_gravity( id, 1.0 );	
			set_user_maxspeed( id, 0.0 );
			set_user_footsteps( id, 0 );
			set_user_noclip( id, 0 );
			set_user_rendering( id );
			set_user_nvg( id, 0 );
			remove_user_nvg( id );
			remove_task( id );
		}
	}
}

/* --| Event when player died */
public Hook_Deathmessage()
{
	/* --| If plugin is on... */
	if( get_pcvar_num( gDrShopOn ) == 1 )
	{
		/* --| Get the killer and attacker */
		new killer = read_data( 1 );
		new victim = read_data( 2 );

		/* --| If player has died with world / trigger_hurt */
		if( killer == victim )
		{
			return PLUGIN_HANDLED;
		}
		
		/* --| Setting killer points when killed a enemy */
		gKillerPoints[ killer ] += get_pcvar_num( gKillerPointsCvar );
	
		/* --| Reseting items */
		HasHe[ victim ] = false;
		HasBothGren[ victim ] = false;
		HasSilent[ victim ] = false;
		HasHealth[ victim ] = false;
		HasArmor[ victim ] = false;
		HasSpeed[ victim ] = false;
		HasGravity[ victim ] = false;
		HasInvis[ victim ] = false;
		HasNoclip[ victim ] = false;
		HasJet[ victim ] = false;
		HasDeagle[ victim ] = false;
		HasLongJump[ victim ] = false;
		HasGlow[ victim ] = false;
		HasNVG[ victim ] = false;
		
		set_user_gravity( victim, 1.0 );	
		set_user_maxspeed( victim, 0.0 );
		set_user_footsteps( victim, 0 );
		set_user_noclip( victim, 0 );
		set_user_rendering( victim );
		set_user_nvg( victim, 0 );
		remove_user_nvg( victim );
		remove_task( victim );
	}
	
	return PLUGIN_CONTINUE;
}

/* --| Now we need to remove the noclip */
public remove_noclip( id )
{
	HasNoclip[ id ] = false;
	set_user_noclip( id, 0 );
	client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_NOCLIP_OFF", get_pcvar_num( gNoclipTime ) );
}

/* --| Now we need to remove the jetpack */	
public remove_jetpack( id )
{
	HasJet[ id ] = false;
	client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_JETPACK_OFF", get_pcvar_num( gJetTime ) );
}

/* --| Now we need to remove the longjump */
public remove_lj( index )
{
	HasLongJump[ index ] = false;
	engfunc( EngFunc_SetPhysicsKeyValue, index, "slj", "0" );
	client_print( index, print_chat, "[DrShop] %L", index, "DRSHOP_LJ_OFF", get_pcvar_num( gLongJumpTime ) );
}

/* --| Usefull stocks on this plugin */
/* --| Display a message in chat if player already have the item */
stock allready_have( id )
{
	client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_ALLREADY_HAVE" );
}	

/* --| Display a message in chat if player don't have enough points */
stock dont_have( id )
{
	client_print( id, print_chat, "[DrShop] %L", id, "DRSHOP_DONTHAVE_POINTS" );
}	

/* --| Saving player points */
stock save_client_points( index )
{
	/* --| Open the vault file */
	gVault = nvault_open( "DeathrunShop_SavedPoints" );
	
	/* --| If vault return -1, lets stop this shit */
	if( gVault == INVALID_HANDLE )
	{
		set_fail_state( "[DrShop] nValut ERROR: =-> Invalid-Handle" );
	}
	
	/* --| Get the player steamid */
	get_user_authid( index, gSteamID, charsmax( gSteamID ) );
	
	/* --| Setting stuff on vault file, and close the file */
	formatex( vKey, charsmax( vKey ), "%sPOINTS", gSteamID );
	formatex( vData, charsmax( vData ), "%d", gKillerPoints[ index ] );
	nvault_set( gVault, vKey, vData );
	nvault_close( gVault );
}

/* --| Loading client points */
stock load_client_points( index )
{
	/* --| Open the vault file */
	gVault = nvault_open( "DeathrunShop_SavedPoints" );
	
	/* --| If vault return -1, lets stop this shit */
	if( gVault == INVALID_HANDLE )
	{
		set_fail_state( "[DrShop] nValut ERROR: =-> Invalid-Handle" );
	}
	
	/* --| Get the player steamid */
	get_user_authid( index, gSteamID, charsmax( gSteamID ) );
	
	/* --| Get the player points, then, close the nvault vile */
	formatex( vKey, charsmax( vKey ), "%sPOINTS", gSteamID );
	gKillerPoints[ index ] = nvault_get( gVault, vKey );
	nvault_close( gVault );
}

/* --| Flame jetpack effect stock */
stock create_flame( origin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin );
	write_byte( TE_SPRITE );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] );
	write_short( gJetSprite );
	write_byte( 3 );
	write_byte( 99 );
	message_end();
}

/* --| Setting temporary longjump stock */
stock set_temporary_longjump( index )
{
	/* --| Let's show to player the jetpack item on hud */
	message_begin( MSG_ONE_UNRELIABLE, gMsgItemPickup, _, index );
	write_string( "item_longjump" );
	message_end();

	/* --| Setting the jetpack on */
	engfunc( EngFunc_SetPhysicsKeyValue, index, "slj", "1" );
	
	/* --| Setting the time before jetpack will go off */
	set_task( float( get_pcvar_num( gLongJumpTime ) ), "remove_lj", index );
}

/* --| Stock for setting user nightvision */
/* --| This stock is more good than cstrike native( give errors ) */
stock set_user_nvg( index, nvgoggles = 1 )
{
	if( nvgoggles )
	{
		set_pdata_int( index, m_iNvg, get_pdata_int( index, m_iNvg ) | HAS_NVGS );
	}

	else
	{
		set_pdata_int( index, m_iNvg, get_pdata_int( index, m_iNvg ) & ~HAS_NVGS );
	}
}

/* --| Stock for removing turned on nightvision from players. Let's call, force remove nvg :) */ 
stock remove_user_nvg( index )
{
	new iNvgs = get_pdata_int( index, m_iNvg, m_iLinuxDiff );

	if( !iNvgs )
	{
		return;
	}

	if( iNvgs & USES_NVGS )
	{
		emit_sound( index, CHAN_ITEM, SOUND_NVGOFF, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		emessage_begin( MSG_ONE_UNRELIABLE, gMessageNVG, _, index );
		ewrite_byte( 0 );
		emessage_end();
	}

	set_pdata_int( index, m_iNvg, 0, m_iLinuxDiff );
}  

/* --| Enf of plugin... */