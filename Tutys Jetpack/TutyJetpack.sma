#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>

#define PLUGIN 		"Tuty's Jetpack"
#define VERSION		"1.2"
#define AUTHOR 		"tuty"

#define JETPACK_P_MODEL		"models/p_longjump.mdl"
#define JETPACK_BUY_SOUND	"weapons/ric_metal-1.wav"
#define JETPACK_FLAME_SOUND	"ambience/flameburst1.wav"
#define JETPACK_SPRITE		"sprites/explode1.spr"
#define JETPACK_ADMIN_FLAG	ADMIN_BAN

new gJetpackAdminOnly;
new gJetpackArmorEat;
new gJetpackCost;
new gJetpackBuyZone;
new gJetpackFlameSprite;
new gJetpackStatusIcon;
new gJetpackPower;
new Jetpack[ 33 ];
new JetpackEnt[ 33 ];
new JetpackFlameTime[ 33 ];

new gJetpackEnabled;

public plugin_init() 
{
	gJetpackEnabled = get_pcvar_num( register_cvar( "jetpack_enabled", "1" ) );
	
	if( gJetpackEnabled )
	{	
		register_plugin( PLUGIN, VERSION, AUTHOR );
		RegisterHam( Ham_Player_Jump, "player", "bacon_playerJumping" );
		RegisterHam( Ham_Spawn, "player", "bacon_playerSpawnPre" );
		register_event( "DeathMsg", "hook_death", "a" );
		register_clcmd( "say /bjp", "cmdBuyJetpack" );
		register_clcmd( "say_team /bjp", "cmdBuyJetpack" );
		
		gJetpackArmorEat = register_cvar( "jetpack_armor_eat", "1" );
		gJetpackAdminOnly = register_cvar( "jetpack_admin_only", "0" );
		gJetpackBuyZone = register_cvar( "jetpack_buyzone", "1" );
		gJetpackCost = register_cvar( "jetpack_cost", "6000" );
		gJetpackPower = register_cvar( "jetpack_power", "100" );
		gJetpackStatusIcon = get_user_msgid( "StatusIcon" );
		
		register_dictionary( "TutyJetpack.txt" );
	}
}
public client_connect( id )
{
	Jetpack[ id ] = 0;
}
public client_disconnect( id )
{
	Jetpack[ id ] = 0;
}
public plugin_precache()
{
	gJetpackFlameSprite = precache_model( JETPACK_SPRITE );
	precache_model( JETPACK_P_MODEL );
	precache_sound( JETPACK_BUY_SOUND );
	precache_sound( JETPACK_FLAME_SOUND );
}	
public cmdBuyJetpack( id )
{
	if( !gJetpackEnabled )
	{
		client_print( id, print_chat, "[T-Jp] %L", id, "TJP_DISABLED" );
		return PLUGIN_CONTINUE;
	}
	
	if( get_pcvar_num( gJetpackBuyZone ) == 1 )
	{
		if( !cs_get_user_buyzone( id ) )
		{
			client_print( id, print_chat, "[T-Jp] %L", id, "TJP_BUYZONE" );
			return  PLUGIN_CONTINUE;
		}
	}
	
	if( get_pcvar_num( gJetpackAdminOnly ) == 1 )
	{
		if( !( get_user_flags( id ) & JETPACK_ADMIN_FLAG ) )
		{
			client_print( id, print_chat, "[T-Jp] %L", id, "TJP_ADMINONLY" );
			return PLUGIN_CONTINUE;
		}
	}
	
	if( !is_user_alive( id ) )
	{
		client_print( id, print_chat, "[T-Jp] %L", id, "TJP_ALIVE" );
		return  PLUGIN_CONTINUE;
	}
	
	new money = cs_get_user_money( id );
	new cost = get_pcvar_num( gJetpackCost );
	
	if( money < cost )
	{
		client_print( id, print_chat, "[T-Jp] %L", id, "TJP_MONEY", cost );
		return PLUGIN_CONTINUE;
	}
		
	if( Jetpack[ id ] )
	{
		client_print( id, print_chat, "[T-Jp] %L", id, "TJP_HAVE" );
		return PLUGIN_CONTINUE;
	}
	
	cs_set_user_money( id, money - cost, 1 );
	client_print( id, print_chat, "[T-Jp] %L", id, "TJP_BOUGHT" );
	emit_sound( id, CHAN_ITEM, JETPACK_BUY_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	give_jetpack( id );
	Jetpack[ id ] = 1;
	
	return PLUGIN_CONTINUE;
}
public hook_death()
{
	new id = read_data( 2 );
	
	if( Jetpack[ id ] )
	{
		remove_jetpack( id );
	}
}
public bacon_playerSpawnPre( id )
{
	if( is_user_alive( id ) )
	{
		if( Jetpack[ id ] )
		{
			remove_jetpack( id );
		}
	}
}
public bacon_playerJumping( id )
{
	if( Jetpack[ id ] )
	{
		new armor = get_user_armor( id );
		
		if( armor <= 0 )
		{
			jetpack_icon( id, 1, 255, 0, 0 );
			return HAM_IGNORED;
		}	
		
		jetpack_icon( id, 1, 0, 30, 255 );

		new iOrigin[ 3 ];
		get_user_origin( id, iOrigin, 0 );
		iOrigin[ 2 ] -= 20;
		
		new Float:fVelocity[ 3 ];
		pev( id, pev_velocity, fVelocity );
		fVelocity[ 2 ] += get_pcvar_num( gJetpackPower );
		
		set_pev( id, pev_velocity, fVelocity );
		set_pev( id, pev_armorvalue, float( armor - get_pcvar_num( gJetpackArmorEat ) ) );
		create_flame( iOrigin );
		
		if( JetpackFlameTime[ id ] == 48 )
		{
			JetpackFlameTime[ id ] = 0;
			emit_sound( id, CHAN_ITEM, JETPACK_FLAME_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}

		JetpackFlameTime[ id ]++;
	}
	return HAM_IGNORED;
}
public give_jetpack( id )
{
	JetpackEnt[ id ] = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	if( pev_valid( JetpackEnt[ id ] ) )
	{
		engfunc( EngFunc_SetModel, JetpackEnt[ id ], JETPACK_P_MODEL );
		set_pev( JetpackEnt[ id ], pev_movetype, MOVETYPE_FOLLOW );
		set_pev( JetpackEnt[ id ], pev_aiment, id );
	}
	
	jetpack_icon( id, 1, 0, 255, 0 );
}
stock remove_jetpack( index )
{
	if( pev_valid( JetpackEnt[ index ] ) )
	{
		engfunc( EngFunc_RemoveEntity, JetpackEnt[ index ] );
	}
	
	jetpack_icon( index, 0, 0, 0, 0 );
	Jetpack[ index ] = 0;
}		
stock create_flame( origin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin );
	write_byte( TE_SPRITE );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] );
	write_short( gJetpackFlameSprite );
	write_byte( 6 );
	write_byte( 120 );
	message_end();
}
stock jetpack_icon( index, status, r, g, b )
{
	message_begin( MSG_ONE_UNRELIABLE, gJetpackStatusIcon, { 0,0,0 }, index );
	write_byte( status );
	write_string( "item_longjump" );
	write_byte( r ); 
	write_byte( g ); 
	write_byte( b ); 
	message_end();
}
