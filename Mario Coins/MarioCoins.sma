
#include < amxmodx >
#include < amxmisc >

#include < fakemeta >
#include < hamsandwich >
#include < engine >
#include < cstrike >

#pragma semicolon 1

#define PLUGIN_VERSION		"2.0.1"

#define __MAX_CLIENTS		32 + 1
#define __HUD_MAXTIME		1.2

enum _: iCoinSequences
{
	CoinIdle = 0,
	CoinFloat,
	CoinSpin
};

new bCountTokenCoins[ __MAX_CLIENTS ];
new Float:bflLastHudTime[ __MAX_CLIENTS ];

new gCvarPluginEnable;
new gCvarPluginMaxCoinsForLife;
new gCvarPluginRespawnTime;
new gCvarPluginCoinPerBody;
new gCvarPluginCoinGlow;
new gHudSyncronizer;
new gHudSyncronizer2;

new const gCoinClassname[ ] = "MarioCoin$";

new const gCoinModel[ ] = "models/MarioCoins/mario_coin.mdl";
new const gCoinGained[ ] = "MarioCoins/coingained.wav";
new const gLifeGained[ ] = "MarioCoins/lifegained.wav";
new const gRespawned[ ] = "MarioCoins/respawned.wav";

public plugin_init( )
{
	register_plugin( "Mario Coins", PLUGIN_VERSION, "tuty" );
	
	register_event( "DeathMsg", "Hook_DeathMessage", "a" );
	register_event( "TextMsg", "EVENT_TextMsg", "a", "2&#Game_C", "2&#Game_w", "2&#Game_will_restart_in" );
	register_logevent( "LOG_RoundEnd", 2, "1=Round_End" );

	RegisterHam( Ham_Player_PreThink, "player", "bacon_PlayerPreThink" );

	register_touch( gCoinClassname, "player", "Forward_TouchCoin" );
	register_think( gCoinClassname, "Forward_CoinThink" );
	
	gCvarPluginEnable = register_cvar( "mc_enabled", "1" );
	gCvarPluginCoinPerBody = register_cvar( "mc_bodycoin", "1" );
	gCvarPluginMaxCoinsForLife = register_cvar( "mc_maxcoins", "4" );
	gCvarPluginRespawnTime = register_cvar( "mc_respawntime", "10" );
	gCvarPluginCoinGlow = register_cvar( "mc_glowcoin", "1" );
	
	gHudSyncronizer = CreateHudSyncObj( );
	gHudSyncronizer2 = CreateHudSyncObj( );
}

public plugin_precache( )
{
	precache_model( gCoinModel );
	
	precache_sound( gCoinGained );
	precache_sound( gLifeGained );
	precache_sound( gRespawned );
}

public client_connect( id )
{
	bCountTokenCoins[ id ] = 0;
}

public EVENT_TextMsg( )
{
	remove_entity_name( gCoinClassname );
}

public LOG_RoundEnd( )
{
	remove_entity_name( gCoinClassname );
}

public Hook_DeathMessage( )
{
	if( get_pcvar_num( gCvarPluginEnable ) != 1 )
	{
		return;
	}

	new iVictim = read_data( 2 );

	if( read_data( 1 ) == iVictim )
	{
		return;
	}

	if( bCountTokenCoins[ iVictim ] >= get_pcvar_num( gCvarPluginMaxCoinsForLife ) )
	{
		new iRespawnTime = get_pcvar_num( gCvarPluginRespawnTime );

		set_hudmessage( 255, 255, 0, 0.08, 0.78, 0, 6.0, 4.0 );
		ShowSyncHudMsg( iVictim, gHudSyncronizer2, "You will respawn in %d second%s!", iRespawnTime, iRespawnTime == 1 ? "" : "s" );

		set_task( float( iRespawnTime ), "RespawnPlayerAndResetCoins", iVictim );
	}

	new Float:flPlayerOrigin[ 3 ];
	pev( iVictim, pev_origin, flPlayerOrigin );
	
	flPlayerOrigin[ 2 ] += 4.0;

	new iEntity = create_entity( "info_target" );

	if( !pev_valid( iEntity ) )
	{
		return;
	}
	
	engfunc( EngFunc_SetOrigin, iEntity, flPlayerOrigin );

	set_pev( iEntity, pev_classname, gCoinClassname );
	engfunc( EngFunc_SetModel, iEntity, gCoinModel );
	set_pev( iEntity, pev_solid, SOLID_SLIDEBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_NONE );
	set_pev( iEntity, pev_framerate, 1.0 );
	set_pev( iEntity, pev_sequence, CoinFloat );

	engfunc( EngFunc_SetSize, iEntity, Float:{ -10.0, -10.0, -10.0 }, Float:{ 10.0, 10.0, 10.0 } );
	engfunc( EngFunc_DropToFloor, iEntity );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 1.0 );
	
	if( get_pcvar_num( gCvarPluginCoinGlow ) == 1 )
	{
		set_rendering( iEntity, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 30 );
	}
}

public Forward_CoinThink( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		set_pev( iEntity, pev_nextthink, get_gametime( ) + 1.0 );

		set_pev( iEntity, pev_framerate, 1.0 );
		set_pev( iEntity, pev_sequence, CoinFloat );
		
		new Float:flOrigin[ 3 ];
		pev( iEntity, pev_origin, flOrigin );
		
		UTIL_DynamicLight( flOrigin, 255, 255, 0, 50 );
	}
}

public Forward_TouchCoin( iEntity, id )
{
	if( pev_valid( iEntity ) )
	{
		set_hudmessage( 255, 255, 0, 0.08, 0.78, 0, 6.0, 4.0 );

		new iMaxCoins = get_pcvar_num( gCvarPluginMaxCoinsForLife );

		if( bCountTokenCoins[ id ] == iMaxCoins )
		{
			set_pev( iEntity, pev_flags, FL_KILLME );
			bCountTokenCoins[ id ] = iMaxCoins;

			return PLUGIN_CONTINUE;
		}

		else if( ++bCountTokenCoins[ id ] >= iMaxCoins )
		{
			ShowSyncHudMsg( id, gHudSyncronizer2, "You have 1 UP [%d/%d Coins]!^nAfter death, you will respawn!", bCountTokenCoins[ id ], iMaxCoins );
			emit_sound( id, CHAN_ITEM, gLifeGained, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			
			set_pev( iEntity, pev_flags, FL_KILLME );
			return PLUGIN_CONTINUE;
		}
		
		new iGainCoins = get_pcvar_num( gCvarPluginCoinPerBody );	

		ShowSyncHudMsg( id, gHudSyncronizer2, "You got %d coin%s from this body!", iGainCoins, iGainCoins == 1 ? "" : "s" );
		emit_sound( id, CHAN_ITEM, gCoinGained, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		set_pev( iEntity, pev_flags, FL_KILLME );
	}
	
	return PLUGIN_CONTINUE;
}

public bacon_PlayerPreThink( id )
{
	if( is_user_alive( id ) && !is_user_bot( id ) && get_pcvar_num( gCvarPluginEnable ) != 0 )
	{
		new Float:flGameTime = get_gametime ( );
		
		if( flGameTime - bflLastHudTime[ id ] >= __HUD_MAXTIME )
		{
			bflLastHudTime[ id ] = flGameTime;
			set_hudmessage( 255, 127, 42, 0.0, 0.90, 0, 6.0, __HUD_MAXTIME );
			
			new iMaxCoins = get_pcvar_num( gCvarPluginMaxCoinsForLife );
			new szFormatHUDMessage[ 300 ];

			if( bCountTokenCoins[ id ] >= iMaxCoins )
			{
				formatex( szFormatHUDMessage, charsmax( szFormatHUDMessage ), "1 UP^nCoins: [%d/%d]", bCountTokenCoins[ id ], iMaxCoins );
			}
			
			else
			{
				formatex( szFormatHUDMessage, charsmax( szFormatHUDMessage ), "Coins: [%d/%d]", bCountTokenCoins[ id ], iMaxCoins );
			}
			
			ShowSyncHudMsg( id, gHudSyncronizer, szFormatHUDMessage );
		}
	}
}

public RespawnPlayerAndResetCoins( iVictim )
{
	if( !is_user_alive( iVictim ) && cs_get_user_team( iVictim ) != CS_TEAM_SPECTATOR )
	{
		set_hudmessage( 255, 255, 0, 0.08, 0.78, 0, 6.0, 4.0 );
		ShowSyncHudMsg( iVictim, gHudSyncronizer2, "You used 1 UP! Go go go!" );

		ExecuteHamB( Ham_CS_RoundRespawn, iVictim );
		emit_sound( iVictim, CHAN_ITEM, gRespawned, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
		bCountTokenCoins[ iVictim ] = 0;
	}
}

stock UTIL_DynamicLight( Float:flOrigin[ 3 ], r, g, b, a )
{
	engfunc( EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, flOrigin );
	write_byte( TE_DLIGHT );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	write_byte( 17 );
	write_byte( r );
	write_byte( g );
	write_byte( b );
	write_byte( a );
	write_byte( 10 );
	message_end( );
}
