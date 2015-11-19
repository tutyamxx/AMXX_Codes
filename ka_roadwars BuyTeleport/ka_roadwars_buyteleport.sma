
#include < amxmodx >

#include < fun >
#include < cstrike >

#pragma semicolon 1

#define ADMIN_ACCES_TO_TELE	ADMIN_IMMUNITY

new gPcvarCost;
new gPcvar;
new gAdminOnly;

new const gSoundPain[ ] = "player/pl_pain4.wav";
new const gSoundDenied[ ] = "buttons/button10.wav";

new const gWeaponsOrigin[ 3 ] = { 105, -885, 1212 };

public plugin_init( )
{
	register_plugin( "ka_roadwars BuyTeleport", "2.0", "tuty" );
	
	register_clcmd( "say !teleme", "TeleportToWeapons" );
	register_clcmd( "say_team !teleme", "TeleportToWeapons" );
	
	gPcvar = register_cvar( "sv_kr_buytele", "1" );		
	gAdminOnly = register_cvar( "sv_kr_buytele_admin", "0" );	
	gPcvarCost = register_cvar( "sv_kr_buytele_cost", "16000" ); 	
}

public plugin_precache( )
{
	precache_sound( gSoundPain );
	precache_sound( gSoundDenied );
}

public TeleportToWeapons( id )
{
	if( get_pcvar_num( gPcvar ) == 0 )
	{
		client_print( id, print_chat, "[KRT] ** Plugin is Disabled! **" );
		client_cmd( id, "speak %s", gSoundDenied );
		
		return PLUGIN_HANDLED;
	}	
	
	if( !is_user_alive( id ) )
	{
		client_print( id, print_chat, "[KRT] ** You must be alive! **" );
		client_cmd( id, "speak %s", gSoundDenied );
		
		return PLUGIN_HANDLED;
	}
	
	if( get_pcvar_num( gAdminOnly ) == 1 )
	{
		if( !( get_user_flags( id ) & ADMIN_ACCES_TO_TELE ) )
		{
			client_print( id, print_chat, "[KRT] ** The plugin is for Admin only! **" );	
			client_cmd( id, "speak %s", gSoundDenied );
			
			return PLUGIN_HANDLED;
		}
	}
	
	new szMap[ 32 ];
	get_mapname( szMap, charsmax( szMap ) );
	
	if( !equal( szMap, "ka_roadwars" ) && !equal( szMap, "ka_roadwars_v2" ) )
	{
		client_print( id, print_chat, "[KRT] ** Invalid Map! Must be ka_roadwars! **" );		
		client_cmd( id, "speak %s", gSoundDenied );
		
		return PLUGIN_HANDLED;
	}
	
	new iMoney = cs_get_user_money( id );
	new iCost = get_pcvar_num( gPcvarCost );
	
	if( iMoney < iCost )
	{
		client_print( id, print_chat, "[KRT] ** You don't have enough money! You need(%d$)! **", iCost );	
		client_cmd( id, "speak %s", gSoundDenied );
		
		return PLUGIN_HANDLED;
	}
	
	set_user_origin( id, gWeaponsOrigin );
	cs_set_user_money( id, iMoney - iCost, 1 );
	
	emit_sound( id, CHAN_VOICE, gSoundPain, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	client_print( id, print_chat, "[KRT] ** Successfully teleported to ^"Secret Weapons Room^"! **" );
	
	return PLUGIN_CONTINUE;
}
