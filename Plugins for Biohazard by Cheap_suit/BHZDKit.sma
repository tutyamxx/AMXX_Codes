
#include < amxmodx >

#include < fakemeta >
#include < hamsandwich >
#include < engine >
#include < fun >

#tryinclude < biohazard >

#define PLUGIN_VERSION	"1.0.0"	
#define CHARGE_TIME	6
#define MINIMUM_HEALTH	70

new bHasKitPack[ 33 ];
new bIsChargingKit[ 33 ];

new Float:flSpriteShowTime[ 33 ];

new gSpriteHeal;
new gHudSync;
new gMessageBarTime;

new const gStartHealSound[ ] = "items/medshot5.wav";
new const gHealedSound[ ] = "items/smallmedkit1.wav";

public plugin_init( )
{
	register_plugin( "Biohazard: KIT Pack", PLUGIN_VERSION, "tuty" );
	
	register_event( "DeathMsg", "EVENT_Death", "a" );
	register_clcmd( "nightvision", "CommandActivateKIT" );
	
	register_forward( FM_AddToFullPack, "forward_AddToFullPack", 1 );
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawned", 1 );
	
	gHudSync = CreateHudSyncObj( );
	gMessageBarTime = get_user_msgid( "BarTime" );
}

public plugin_precache( )
{
	gSpriteHeal = precache_model( "sprites/healKIT.spr" );
	precache_model( "models/rpgrocket.mdl" );
	
	precache_sound( gStartHealSound );
	precache_sound( gHealedSound );
}

public client_connect( id )
{
	bHasKitPack[ id ] = 0;
	bIsChargingKit[ id ] = 0;
}

public bacon_PlayerSpawned( id )
{
	if( is_user_alive( id ) )
	{
		bHasKitPack[ id ] = 1;
		bIsChargingKit[ id ] = 0;
		
		set_hudmessage( 255, 255, 255, -1.0, 0.84, 1, 6.0, 12.0 );
		ShowSyncHudMsg( id, gHudSync, "You have a Kit Pack!^nTo use it press N while your health is under %d", MINIMUM_HEALTH );	
	}
}

public EVENT_Death( )
{
	new iVictim = read_data( 2 );

	bHasKitPack[ iVictim ] = 0;
	bIsChargingKit[ iVictim ] = 0;
	
	new iFlags = pev( iVictim, pev_flags );
	
	if( iFlags & FL_FROZEN )
	{
		set_pev( iVictim, pev_flags, iFlags & ~FL_FROZEN );
	}
	
	UTIL_BarTime( iVictim, 0 );
	set_view( iVictim, CAMERA_NONE );
	remove_task( iVictim + 4531 );
	set_user_rendering( iVictim, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );
}

public event_infect( victim, attacker )
{
	if( bIsChargingKit[ victim ] == 1 )
	{
		UTIL_BarTime( victim, 0 );
		bIsChargingKit[ victim ] = 0;
			
		new iFlags = pev( victim, pev_flags );
	
		if( iFlags & FL_FROZEN )
		{
			set_pev( victim, pev_flags, iFlags & ~FL_FROZEN );
		}
	
		set_view( victim, CAMERA_NONE );
		remove_task( victim + 4531 );
		set_user_rendering( victim, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );

		set_hudmessage( 255, 255, 10, -1.0, 0.84, 1, 6.0, 5.0 );
		ShowSyncHudMsg( victim, gHudSync, "Heal process failed! You are infected!" );	
	}
	
	bHasKitPack[ victim ] = 0;
}

public CommandActivateKIT( id )
{
	if( is_user_zombie( id ) )
	{
		return PLUGIN_CONTINUE;
	}
	
	if( !is_user_alive( id ) )
	{
		set_hudmessage( 255, 255, 10, -1.0, 0.84, 1, 6.0, 5.0 );
		ShowSyncHudMsg( id, gHudSync, "You can't use Kit while you are dead!" );
		
		return PLUGIN_HANDLED_MAIN;
	}

	if( bHasKitPack[ id ] == 0 )
	{
		set_hudmessage( 255, 10, 10, -1.0, 0.84, 1, 6.0, 5.0 );
		ShowSyncHudMsg( id, gHudSync, "You don't have any Kit to heal!" );
		
		return PLUGIN_HANDLED_MAIN
	}
	
	if( get_user_health( id ) > MINIMUM_HEALTH )
	{
		set_hudmessage( 10, 10, 255, -1.0, 0.84, 1, 6.0, 5.0 );
		ShowSyncHudMsg( id, gHudSync, "It seems you don't need a Kit right now!" );
		
		return PLUGIN_HANDLED_MAIN
	}
	
	UTIL_BarTime( id, CHARGE_TIME );
	set_user_rendering( id, kRenderFxGlowShell, 10, 255, 10, kRenderNormal, 25 );

	set_view( id, CAMERA_3RDPERSON );
	set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
	
	bHasKitPack[ id ] = 0;
	bIsChargingKit[ id ] = 1;
	
	emit_sound( id, CHAN_BODY, gStartHealSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	set_task( float( CHARGE_TIME ), "ChargeHealth", id + 4531 );
	
	return PLUGIN_HANDLED_MAIN;
}

public ChargeHealth( taskid )
{
	new id = taskid - 4531;
	
	set_user_health( id, 100 );
	set_view( id, CAMERA_NONE );
	
	UTIL_BarTime( id, 0 );
	bIsChargingKit[ id ] = 0;

	emit_sound( id, CHAN_BODY, gHealedSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	set_user_rendering( id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );
	set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );
	
	set_hudmessage( 10, 255, 10, -1.0, 0.84, 1, 6.0, 5.0 );
	ShowSyncHudMsg( id, gHudSync, "Healed with Kit Pack!" );
}

public forward_AddToFullPack( es_handle, e, id, host, hostflags, player, pSet )
{
	if( !is_user_alive( id ) )
	{
		return FMRES_IGNORED;
	}
	
	if( bIsChargingKit[ id ] == 1 )
	{
		new Float:flGameTime = get_gametime( );
		
		if( flGameTime - flSpriteShowTime[ id ] >= 0.3 )
		{
			flSpriteShowTime[ id ] = flGameTime;

			UTIL_HealEffect( id );
		}
	}
	
	return FMRES_IGNORED;
}

stock UTIL_HealEffect( index )
{
	new iOrigin[ 3 ];
	get_user_origin( index, iOrigin );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_PROJECTILE );
	write_coord( iOrigin[ 0 ] + random_num( -13, 13 ) );
	write_coord( iOrigin[ 1 ] + random_num( -13, 13 ) );
	write_coord( iOrigin[ 2 ] + random_num( 0, 40 ) );
	write_coord( 0 );
	write_coord( 0 );
	write_coord( 15 );
	write_short( gSpriteHeal );
	write_byte( 1 );
	write_byte( index );
	message_end( );
}

stock UTIL_BarTime( index, time )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageBarTime, _, index );
	write_short( time );
	message_end( );
}
