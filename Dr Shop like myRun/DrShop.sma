
#include < amxmodx >

#include < hamsandwich >
#include < fun >
#include < cstrike >
#include < colorchat >

#pragma semicolon 1

#define TASK_STEALTH		465229
#define MAX_PLAYERS		32 + 1
#define IS_PLAYER(%1)		(1 <= %1 <= gMaxPlayers)

new gCvarHealth;
new gCvarArmor;
new gCvarHealthCost;
new gCvarArmorCost;
new gCvarGrenadeCost;
new gCvarGrenPackCost;
new gCvarNoflashCost;
new gCvarStealthSec;
new gCvarStealthCost;
new gCvarRespawnFrags;
new gCvarRespawnCost;

new gMessageScoreInfo;
new gMaxPlayers;

new const gTag[ ] = "[Deathrun]";

new const gHealthSound[ ] = "items/smallmedkit1.wav";
new const gArmorSound[ ] = "items/ammopickup2.wav";
new const gNoFlashSound[ ] = "items/guncock1.wav";
new const gStealthSound[ ] = "items/airtank1.wav";

new bNoBlind[ MAX_PLAYERS ];
new bHasStealth[ MAX_PLAYERS ];

public plugin_init( )
{
	register_plugin( "Deahtrun Shop Csblue", "1.0.1", "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_Spawned", 1 );

	register_event( "DeathMsg", "Hook_Death", "a" );
	register_message( get_user_msgid( "ScreenFade" ), "Message_ScreenFade" );

	register_clcmd( "nightvision", "CommandShop" );
	
	gCvarHealth = register_cvar( "ds_health", "255" );
	gCvarArmor = register_cvar( "ds_armor", "900" );
	gCvarHealthCost = register_cvar( "ds_health_cost", "7000" );
	gCvarArmorCost = register_cvar( "ds_armor_cost", "5000" );
	gCvarGrenadeCost = register_cvar( "ds_grenade_cost", "5000" );
	gCvarGrenPackCost = register_cvar( "ds_grenpack_cost", "7000" );
	gCvarNoflashCost = register_cvar( "ds_noflash_cost", "8000" );
	gCvarStealthSec = register_cvar( "ds_stealth_frags", "20" );
	gCvarStealthCost = register_cvar( "ds_stealth_cost", "16000" );
	gCvarRespawnFrags = register_cvar( "ds_respawn_frags", "2" );
	gCvarRespawnCost = register_cvar( "ds_respawn_cost", "16000" );
	
	gMessageScoreInfo = get_user_msgid( "ScoreInfo" );
	gMaxPlayers = get_maxplayers( );
	
	UTIL_CheckServerLicense( "93.119.26.88:27015", 0 );
}

public plugin_precache( )
{
	precache_sound( gHealthSound );
	precache_sound( gArmorSound );
	precache_sound( gNoFlashSound );
	precache_sound( gStealthSound );
}

public client_connect( id )
{
	bNoBlind[ id ] = 0;
	bHasStealth[ id ] = 0;
}

public client_disconnect( id )
{
	bNoBlind[ id ] = 0;
	bHasStealth[ id ] = 0;
	
	remove_task( id + TASK_STEALTH );
}

public CommandShop( id )
{
	new iMenu = menu_create( "\rShop\w - \yDeathrun Shop", "menu_shop" );
	
	new szFormatMenu[ 300 ];

	formatex( szFormatMenu, charsmax( szFormatMenu ), "\w%d HP \R\y%d$", get_pcvar_num( gCvarHealth ), get_pcvar_num( gCvarHealthCost ) );
	menu_additem( iMenu, szFormatMenu, "1", 0 );
	
	formatex( szFormatMenu, charsmax( szFormatMenu ), "\w%d AP \R\y%d$", get_pcvar_num( gCvarArmor ), get_pcvar_num( gCvarArmorCost ) );
	menu_additem( iMenu, szFormatMenu, "2", 0 );
	
	formatex( szFormatMenu, charsmax( szFormatMenu ), "\wHE Grenade \R\y%d$", get_pcvar_num( gCvarGrenadeCost ) );
	menu_additem( iMenu, szFormatMenu, "3", 0 );
	
	formatex( szFormatMenu, charsmax( szFormatMenu ), "\wHE + 2 Flashbangs \R\y%d$", get_pcvar_num( gCvarGrenPackCost ) );
	menu_additem( iMenu, szFormatMenu, "4", 0 );
	
	formatex( szFormatMenu, charsmax( szFormatMenu ), "\wNo Flash Blinding \R\y%d$", get_pcvar_num( gCvarNoflashCost ) );
	menu_additem( iMenu, szFormatMenu, "5", 0 );
	
	formatex( szFormatMenu, charsmax( szFormatMenu ), "\wStealth \d(Doar T) \r(%d Secunde) \R\y%d$", get_pcvar_num( gCvarStealthSec ), get_pcvar_num( gCvarStealthCost ) );
	menu_additem( iMenu, szFormatMenu, "6", 0 );
	
	formatex( szFormatMenu, charsmax( szFormatMenu ), "\wRespawn \d(Doar CT) \r(%d Frage) \R\y%d$", get_pcvar_num( gCvarRespawnFrags ), get_pcvar_num( gCvarRespawnCost ) );
	menu_additem( iMenu, szFormatMenu, "7", 0 );
	
	menu_setprop( iMenu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, iMenu, 0 );
}

public bacon_Spawned( id )
{
	if( is_user_alive( id ) )
	{
		set_user_rendering( id );
		remove_task( id + TASK_STEALTH );
		
		bNoBlind[ id ] = 0;
		bHasStealth[ id ] = 0;
	}
}

public Hook_Death( )
{
	new iVictim = read_data( 2 );
	
	if( IS_PLAYER( iVictim ) )
	{
		remove_task( iVictim + TASK_STEALTH );
		set_user_rendering( iVictim );
	
		bNoBlind[ iVictim ] = 0;
		bHasStealth[ iVictim ] = 0;
	}
}

public Message_ScreenFade( msg_id, msg_dest, id )
{
	if( get_msg_arg_int( 4 ) != 255 || get_msg_arg_int( 5 ) != 255 || get_msg_arg_int( 6 ) != 255 )
	{
        	return PLUGIN_CONTINUE;
	}
    
    	static iAlpha;
    	iAlpha = get_msg_arg_int( 7 );

    	if( iAlpha != 200 && iAlpha != 255 )
	{
        	return PLUGIN_CONTINUE;
	}
	
	if( bNoBlind[ id ] == 1 )
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}  

public menu_shop( id, menu, item )
{
	if( item == MENU_EXIT )
    	{
        	menu_destroy( menu );
        
		return PLUGIN_HANDLED;
    	}
	
	new szData[ 6 ], szName[ 64 ], access, callback;
    	menu_item_getinfo( menu, item, access, szData, charsmax( szData ), szName, charsmax( szName ), callback );

    	new key = str_to_num( szData );
	new iMoney = cs_get_user_money( id );
	
	switch( key )
	{
		case 1:
		{
			if( !is_user_alive( id ) )
			{
				ColorChat( id, RED, "^3%s^1 Nu poti cumpara acest item cand esti mort!", gTag );
				
				return PLUGIN_HANDLED;
			}

			new iCost = get_pcvar_num( gCvarHealthCost );
			new iHealth = get_pcvar_num( gCvarHealth );
			
			if( iMoney < iCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destui bani sa cumperi^4 %d HP^1. Iti trebuie^4 %d$", gTag, iHealth, iCost );
				
				return PLUGIN_HANDLED;
			}
			
			cs_set_user_money( id, iMoney - iCost, 1 );
			set_user_health( id, iHealth );
			
			ColorChat( id, RED, "^3%s^1 Ai cumparat^4 %d HP", gTag, iHealth );
			emit_sound( id, CHAN_STATIC, gHealthSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
		
		case 2:
		{
			if( !is_user_alive( id ) )
			{
				ColorChat( id, RED, "^3%s^1 Nu poti cumpara acest item cand esti mort!", gTag );
				
				return PLUGIN_HANDLED;
			}

			new iCost = get_pcvar_num( gCvarArmorCost );
			new iArmor = get_pcvar_num( gCvarArmor );
				
			if( iMoney < iCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destui bani sa cumperi^4 %d AP^1. Iti trebuie^4 %d$", gTag, iArmor, iCost );
				
				return PLUGIN_HANDLED;
			}
			
			cs_set_user_money( id, iMoney - iCost, 1 );
			set_user_armor( id, iArmor );
			
			ColorChat( id, RED, "^3%s^1 Ai cumparat^4 %d AP", gTag, iArmor );
			emit_sound( id, CHAN_STATIC, gArmorSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
		
		case 3:
		{
			if( !is_user_alive( id ) )
			{
				ColorChat( id, RED, "^3%s^1 Nu poti cumpara acest item cand esti mort!", gTag );
				
				return PLUGIN_HANDLED;
			}

			if( user_has_weapon( id, CSW_HEGRENADE ) )
			{
				ColorChat( id, RED, "^3%s^1 Detii deja itemul^4 HE Grenade^1", gTag );
				
				return PLUGIN_HANDLED;
			}

			new iCost = get_pcvar_num( gCvarGrenadeCost );
			
			if( iMoney < iCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destui bani sa cumperi^4 HE Grenade^1. Iti trebuie^4 %d$", gTag, iCost );
				
				return PLUGIN_HANDLED;
			}
		
			cs_set_user_money( id, iMoney - iCost, 1 );
			give_item( id, "weapon_hegrenade" );
			
			ColorChat( id, RED, "^3%s^1 Ai cumparat^4 He Grenade", gTag );
		}
		
		case 4:
		{
			if( !is_user_alive( id ) )
			{
				ColorChat( id, RED, "^3%s^1 Nu poti cumpara acest item cand esti mort!", gTag );
				
				return PLUGIN_HANDLED;
			}
			
			if( user_has_weapon( id, CSW_HEGRENADE ) && user_has_weapon( id, CSW_FLASHBANG ) )
			{
				ColorChat( id, RED, "^3%s^1 Detii deja itemul^4 HE + 2 Flashbangs^1", gTag );
				
				return PLUGIN_HANDLED;
			}
			
			new iCost = get_pcvar_num( gCvarGrenPackCost );
			
			if( iMoney < iCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destui bani sa cumperi^4 HE + 2 Flashbangs^1. Iti trebuie^4 %d$", gTag, iCost );
				
				return PLUGIN_HANDLED;
			}
			
			cs_set_user_money( id, iMoney - iCost, 1 );
			give_item( id, "weapon_hegrenade" );
			give_item( id, "weapon_flashbang" );
			give_item( id, "weapon_flashbang" );
			
			ColorChat( id, RED, "^3%s^1 Ai cumparat^4 HE + 2 Flashbangs", gTag );
		}
		
		case 5:
		{
			if( !is_user_alive( id ) )
			{
				ColorChat( id, RED, "^3%s^1 Nu poti cumpara acest item cand esti mort!", gTag );
				
				return PLUGIN_HANDLED;
			}
			
			if( bNoBlind[ id ] == 1 )
			{
				ColorChat( id, RED, "^3%s^1 Detii deja itemul^4 No Flash Blinding^1", gTag );
				
				return PLUGIN_HANDLED;
			}

			new iCost = get_pcvar_num( gCvarNoflashCost );
			
			if( iMoney < iCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destui bani sa cumperi^4 No Flash Blinding^1. Iti trebuie^4 %d$", gTag, iCost );
				
				return PLUGIN_HANDLED;
			}
			
			bNoBlind[ id ] = 1;
			cs_set_user_money( id, iMoney - iCost, 1 );
			
			ColorChat( id, RED, "^3%s^1 Ai cumparat^4 No Flash Blinding", gTag );
			emit_sound( id, CHAN_STATIC, gNoFlashSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
		
		case 6:
		{
			if( !is_user_alive( id ) )
			{
				ColorChat( id, RED, "^3%s^1 Nu poti cumpara acest item cand esti mort!", gTag );
				
				return PLUGIN_HANDLED;
			}
			
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				ColorChat( id, RED, "^3%s^1 Doar cei din echipa^4 T^1 pot cumpara acest item!", gTag );
				
				return PLUGIN_HANDLED;
			}

			if( bHasStealth[ id ] == 1 )
			{
				ColorChat( id, RED, "^3%s^1 Detii deja itemul^4 Stealth^1", gTag );
				
				return PLUGIN_HANDLED;
			}

			new iCost = get_pcvar_num( gCvarStealthCost );
			
			if( iMoney < iCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destui bani sa cumperi^4 Stealth^1. Iti trebuie^4 %d$", gTag, iCost );
				
				return PLUGIN_HANDLED;
			}

			cs_set_user_money( id, iMoney - iCost, 1 );
			bHasStealth[ id ] = 1;
			
			set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha , 0 );
			set_task( float( get_pcvar_num( gCvarStealthSec ) ), "RemoveStealth", id + TASK_STEALTH );
			
			ColorChat( id, RED, "^3%s^1 Ai cumparat^4 Stealth^1 pentru^4 %d^1 secunde.", gTag, get_pcvar_num( gCvarStealthSec ));
			emit_sound( id, CHAN_STATIC, gStealthSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
		
		case 7:
		{
			if( cs_get_user_team( id ) == CS_TEAM_T )
			{
				ColorChat( id, RED, "^3%s^1 Doar cei din echipa^4 CT^1 pot cumpara acest item!", gTag );
				
				return PLUGIN_HANDLED;
			}

			if( is_user_alive( id ) )
			{
				ColorChat( id, RED, "^3%s^1 Nu poti cumpara acest item cand esti viu!", gTag );
				
				return PLUGIN_HANDLED;
			}
			
			new iFrags = get_user_frags( id );
			new iFragCost = get_pcvar_num( gCvarRespawnFrags );
			
			if( iFrags < iFragCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destule fraguri sa cumperi^4 Respawn^1. Iti trebuie^4 %d", gTag, iFragCost );
				
				return PLUGIN_HANDLED;
			}
			
			new iCost = get_pcvar_num( gCvarRespawnCost );
			
			if( iMoney < iCost )
			{
				ColorChat( id, RED, "^3%s^1 Nu ai destui bani sa cumperi^4 Respawn^1. Iti trebuie^4 %d$", gTag, iCost );
				
				return PLUGIN_HANDLED;
			}
			
			cs_set_user_money( id, iMoney - iCost, 1 );
			set_user_frags( id, iFrags - iFragCost );
			UTIL_ScoreInfo( id );

			ColorChat( id, RED, "^3%s^1 Ai cumparat^4 Respawn^1 pentru^4 %d^1 fraguri si^4 %d$", gTag, iFragCost, iCost );
			set_task( 1.1, "RespawnPlayer", id );
		}
	}
	
	menu_display( id, menu, 0 );
	
	return PLUGIN_HANDLED;
}

public RespawnPlayer( id )
{
	if( IS_PLAYER( id ) )
	{
		if( is_user_connected( id ) && !is_user_alive( id ) && cs_get_user_team( id ) != CS_TEAM_SPECTATOR )
		{
			ExecuteHamB( Ham_CS_RoundRespawn, id );
		}
	}
}

public RemoveStealth( iTaskid )
{
	new id = iTaskid - TASK_STEALTH;
	
	if( IS_PLAYER( id ) )
	{
		bHasStealth[ id ] = 0;
		set_user_rendering( id );
		
		ColorChat( id, RED, "^3%s^4 Stealth^1 dezactivat!", gTag );
		emit_sound( id, CHAN_STATIC, gStealthSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}

UTIL_ScoreInfo( id )
{
	message_begin( MSG_BROADCAST, gMessageScoreInfo );
	write_byte( id );
	write_short( get_user_frags( id ) );
	write_short( get_user_deaths( id ) );
	write_short( 0 );
	write_short( get_user_team( id ) );
	message_end( );
}

stock UTIL_CheckSteal( const szServerIp[ ] )
{
	new szIp[ 50 ];
	get_user_ip( 0, szIp, charsmax( szIp ) );
	
	if( !equal( szIp, szServerIp ) )
	{
		set_fail_state( "Licenta invalida! Server oprit!" );
		server_print( "Licenta invalida! Server oprit!" );
		
		server_cmd( "exit" );
	}
}


stock UTIL_CheckServerLicense( const szIP[ ], iShutDown = 1 )
{
	new szServerIP[ 50 ];
	get_cvar_string( "ip", szServerIP, charsmax( szServerIP ) );
	
	if( !equal( szServerIP, szIP ) )
	{
		if( iShutDown == 1 )
		{
			server_cmd( "exit" );
		
			log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed...Shutting down...", szIP, szServerIP );
		}
		
		else if( iShutDown == 0 )
		{
			new szFormatFailState[ 250 ];
			formatex( szFormatFailState, charsmax( szFormatFailState ), "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed.", szIP, szServerIP );

			set_fail_state( szFormatFailState );
		}
	}
	
	else
	{
		log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking verified! DONE.", szIP, szServerIP );
	}
}
