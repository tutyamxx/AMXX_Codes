

/* 		
	~~~~~~~~~~~~~~~~~~~~~~~
	    Build Dispenser

	    Like in TFC or TF2 dispensers give you armor health and ammo
	    Every time you are near at a teammate dispenser, your health, amor, or ammo will refill to maximum!		
 
	    By tuty;
	~~~~~~~~~~~~~~~~~~~~~~~
*/



#include < amxmodx >
#include < amxmisc >

#include < fakemeta >
#include < hamsandwich >
#include < cstrike >
#include < engine >
#include < fun >

#include < xs >

#pragma semicolon 1

#define PLUGIN_VERSION		"#1.0.3"
#define BREAK_COMPUTER		6
#define MAX_PLAYERS		32 + 1

enum
{
	STATUS_BUILDING,
	STATUS_ACTIVE
};

new const gDamageSounds[ ][ ] = 
{
	"debris/metal1.wav",
	"debris/metal2.wav",
	"debris/metal3.wav"
};

new const gDispenserClassname[ ] = "NiceDispenser:D";

new const gDispenserActive[ ] = "buttons/button9.wav";
new const gDispenserMdl[ ] = "models/dispenser.mdl";
new const gMetalGibsMdl[ ] = "models/computergibs.mdl";
new const gHealingSprite[ ] = "sprites/laserbeam.spr";

new gHealingBeam;
new gMetalGibs;
new gMaxPlayers;
new gHudSync;

new gCvarEnabled;
new gDispenserCost;
new gCvarDispenserHealth;
new gCvarBuildTime;
new gCvarReplenishRadius;
new gCvarSpinDispenser;
new gCvarMaxHealth;
new gCvarMaxArmor;

new Float:gDispenserOrigin[ MAX_PLAYERS ][ 3 ];
new gBeamcolor[ MAX_PLAYERS ][ 3 ];

new Float:gDispenserHealthOff[ MAX_PLAYERS ];
new bool:bDispenserBuild[ MAX_PLAYERS ];

public plugin_init( )
{
	register_plugin( "Build Dispenser", PLUGIN_VERSION, "tuty" );
	
	register_event( "TextMsg", "EVENT_TextMsg", "a", "2&#Game_C", "2&#Game_w", "2&#Game_will_restart_in" );
	register_logevent( "LOG_RoundEnd", 2, "1=Round_End" );
	
	RegisterHam( Ham_TakeDamage, "info_target", "bacon_TakeDamage", 1 );
	RegisterHam( Ham_TraceAttack, "info_target", "bacon_TraceAttack" );
	
	register_think( gDispenserClassname, "DispenserThink" );
	register_clcmd( "drop", "CommandDispenserBuild" );
	
	gCvarEnabled = register_cvar( "dispenser_enabled", "1" );
	gDispenserCost = register_cvar( "dispenser_cost", "1500" );
	gCvarDispenserHealth = register_cvar( "dispenser_health", "900" );
	gCvarBuildTime = register_cvar( "dispenser_buildtime", "5" );
	gCvarReplenishRadius = register_cvar( "dispenser_radius", "300" );
	gCvarSpinDispenser = register_cvar( "dispenser_spin", "1" );
	gCvarMaxHealth = register_cvar( "dispenser_playermax_health", "100" );
	gCvarMaxArmor = register_cvar( "dispenser_playermax_armor", "100" );
	
	gMaxPlayers = get_maxplayers( );
	gHudSync = CreateHudSyncObj( );
}

public client_connect( id )
{
	bDispenserBuild[ id ] = false;
}

public plugin_precache( )
{	
	gHealingBeam = precache_model( gHealingSprite );
	gMetalGibs = precache_model( gMetalGibsMdl );
	
	precache_model( gDispenserMdl );
	precache_sound( gDispenserActive );
	
	new i;
	for( i = 0; i < sizeof gDamageSounds; i++ )
	{
		precache_sound( gDamageSounds[ i ] );
	}
}

public CommandDispenserBuild( id )
{
	if( !is_user_alive( id ) || get_user_weapon( id ) != CSW_KNIFE || get_pcvar_num( gCvarEnabled ) != 1 )
	{
		return PLUGIN_CONTINUE;
	}
	
	if( !( pev( id, pev_flags ) & FL_ONGROUND ) )
	{
		client_print( id, print_chat, "[AMXX] You must be on ground to build a Dispenser!" );
		
		return PLUGIN_HANDLED;
	}

	if( bDispenserBuild[ id ] == true )
	{
		client_print( id, print_chat, "[AMXX] You already have build a Dispenser!" );
		
		return PLUGIN_HANDLED;
	}

	new iMoney = cs_get_user_money( id );
	new iCost = get_pcvar_num( gDispenserCost );
	
	if( iMoney < iCost )
	{
		client_print( id, print_chat, "[AMXX] You don't have enough money to build a Dispenser... Need(%d$)", iCost );
		
		return PLUGIN_HANDLED;
	}

	new Float:flPlayerOrigin[ 3 ];
	pev( id, pev_origin, flPlayerOrigin );
	
	new Float:flHealth = float( get_pcvar_num( gCvarDispenserHealth ) );

	new iEntity = create_entity( "info_target" );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}

	set_pev( iEntity, pev_classname, gDispenserClassname );
	engfunc( EngFunc_SetModel, iEntity, gDispenserMdl );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -12.0, -10.0, -12.0 }, Float:{ 12.0, 10.0, 12.0 } );
	set_pev( iEntity, pev_origin, flPlayerOrigin );
	set_pev( iEntity, pev_solid, SOLID_NOT );
	set_pev( iEntity, pev_movetype, MOVETYPE_TOSS );
	set_pev( iEntity, pev_health, flHealth );
	set_pev( iEntity, pev_takedamage, DAMAGE_YES );
	set_pev( iEntity, pev_iuser2, id );
	set_pev( iEntity, pev_iuser3, STATUS_BUILDING );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 0.1 );

	gDispenserOrigin[ id ][ 0 ] = flPlayerOrigin[ 0 ];
	gDispenserOrigin[ id ][ 1 ] = flPlayerOrigin[ 1 ];
	gDispenserOrigin[ id ][ 2 ] = flPlayerOrigin[ 2 ];
	
	gDispenserHealthOff[ id ] = flHealth;
	bDispenserBuild[ id ] = true;
	
	set_task( float( get_pcvar_num( gCvarBuildTime ) ), "BuildDispenserSolid", iEntity );
	cs_set_user_money( id, iMoney - iCost, 1 );
	client_print( id, print_chat, "[AMXX] Building a Dispenser right here..." );
	
	return PLUGIN_HANDLED;
}

public bacon_TakeDamage( ent, idinflictor, idattacker, Float:damage, damagebits )
{
	new szClassname[ 32 ];
	pev( ent, pev_classname, szClassname, charsmax( szClassname ) );
	
	if( equal( szClassname, gDispenserClassname ) )
	{
		new iOwner = pev( ent, pev_iuser2 );

		if( pev( ent, pev_health ) <= 0.0 )
		{
			new szName[ 32 ];
			get_user_name( idattacker, szName, charsmax( szName ) );

			new Float:flOrigin[ 3 ];
			pev( ent, pev_origin, flOrigin );
				
			UTIL_BreakModel( flOrigin, gMetalGibs, BREAK_COMPUTER );
			set_pev( ent, pev_flags, pev( ent, pev_flags ) | FL_KILLME );

			if( idattacker == iOwner )
			{
				client_print( iOwner, print_chat, "[AMXX] You have destroyed your Dispenser!" );
			}

			else
			{
				client_print( iOwner, print_chat, "[AMXX] %s destroyed your Dispenser!", szName );
			}

			client_cmd( iOwner, "speak ^"vox/bizwarn computer destroyed^"" );
			bDispenserBuild[ iOwner ] = false;
		}
		
		gDispenserHealthOff[ iOwner ] = float( pev( ent, pev_health ) );
		emit_sound( ent, CHAN_STATIC, gDamageSounds[ random_num( 0, charsmax( gDamageSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );	
	}
}

public bacon_TraceAttack( iVictim, iAttacker, Float:flDamage, Float:flDirection[ 3 ], iTr, iDamageBits )
{
	new szClassname[ 32 ];
	pev( iVictim, pev_classname, szClassname, charsmax( szClassname ) );
	
	if( equal( szClassname, gDispenserClassname ) )
	{
		new Float:flEndOrigin[ 3 ];
		get_tr2( iTr, TR_vecEndPos, flEndOrigin );
	
		UTIL_Sparks( flEndOrigin );
	}
}	
			
public DispenserThink( iEnt )
{
	if( pev_valid( iEnt ) )
	{
		new iStatus = pev( iEnt, pev_iuser3 );
		new iOwner = pev( iEnt, pev_iuser2 );

		switch( iStatus )
		{
			case STATUS_BUILDING:
			{
				set_rendering( iEnt, kRenderFxDistort, 255, 255, 255, kRenderTransAdd, 70 );
			}
			
			case STATUS_ACTIVE:
			{
				new id;
				for( id = 1; id <= gMaxPlayers; id++ )
				{
					if( is_user_alive( id ) && cs_get_user_team( id ) == cs_get_user_team( iOwner ) )
					{
						new Float:flOrigin[ 3 ];
						pev( id, pev_origin, flOrigin );
						
						if( get_distance_f( gDispenserOrigin[ iOwner ], flOrigin ) <= float( get_pcvar_num( gCvarReplenishRadius ) ) )
						{
							if( UTIL_IsVisible( id, iEnt ) )
							{
								UTIL_GiveWeaponAmmo( id );
							
								// people will ask why i didn't used if and else if...
								// because i want to recharge health and armor and ammo in same time if needed :D

								if( get_user_health( id ) < get_pcvar_num( gCvarMaxHealth ) )
								{
									set_user_health( id, get_user_health( id ) + 1 );
								}
							
								if( get_user_armor( id ) < get_pcvar_num( gCvarMaxArmor ) )
								{
									set_user_armor( id, get_user_armor( id ) + 1 );
								}
							
								UTIL_BeamEnts( gDispenserOrigin[ iOwner ], flOrigin, gBeamcolor[ iOwner ][ 0 ], gBeamcolor[ iOwner ][ 1 ], gBeamcolor[ iOwner ][ 2 ] );
							}
						}
					}
				}
				
				set_hudmessage( gBeamcolor[ iOwner ][ 0 ], gBeamcolor[ iOwner ][ 1 ], gBeamcolor[ iOwner ][ 2 ], 0.0, 0.21, 1, 6.0, 0.2 );
				ShowSyncHudMsg( iOwner, gHudSync, ">>>[ Dispenser ]<<<^n^nHealth Status: [%d]", floatround( gDispenserHealthOff[ iOwner ] ) );
			}
		}
		
		if( get_pcvar_num( gCvarSpinDispenser ) == 1 )
		{
			new Float:flAngles[ 3 ];
			pev( iEnt, pev_angles, flAngles );
			
			flAngles[ 1 ] += 1.0;
			
			set_pev( iEnt, pev_angles, flAngles );
		}

		set_pev( iEnt, pev_nextthink, get_gametime( ) + 0.1 );
	}
}

public BuildDispenserSolid( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		new iOwner = pev( iEntity, pev_iuser2 );

		switch( cs_get_user_team( iOwner ) )
		{
			case CS_TEAM_T:
			{
				gBeamcolor[ iOwner ][ 0 ] = 255, gBeamcolor[ iOwner ][ 1 ] = 0, gBeamcolor[ iOwner ][ 2 ] = 0;
				set_rendering( iEntity, kRenderFxGlowShell, gBeamcolor[ iOwner ][ 0 ], gBeamcolor[ iOwner ][ 1 ], gBeamcolor[ iOwner ][ 2 ], kRenderNormal, 3 );
			}
		
			case CS_TEAM_CT:
			{
				gBeamcolor[ iOwner ][ 0 ] = 0, gBeamcolor[ iOwner ][ 1 ] = 0, gBeamcolor[ iOwner ][ 2 ] = 255;
				set_rendering( iEntity, kRenderFxGlowShell, gBeamcolor[ iOwner ][ 0 ], gBeamcolor[ iOwner ][ 1 ], gBeamcolor[ iOwner ][ 2 ], kRenderNormal, 3 );
			}
		}

		set_pev( iEntity, pev_solid, SOLID_BBOX );
		set_pev( iEntity, pev_iuser3, STATUS_ACTIVE );
		engfunc( EngFunc_DropToFloor, iEntity );
		
		emit_sound( iEntity, CHAN_STATIC, gDispenserActive, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}

public EVENT_TextMsg( )
{
	UTIL_DestroyDispensers( );
}

public LOG_RoundEnd( )
{
	UTIL_DestroyDispensers( );
}


/* 		
	~~~~~~~~~~~~~~~~~~~~~~~
		Stocks
	~~~~~~~~~~~~~~~~~~~~~~~
*/


stock UTIL_DestroyDispensers( )
{
	new iEnt = FM_NULLENT;
	
	while( ( iEnt = find_ent_by_class( iEnt, gDispenserClassname ) ) )
	{
		new iOwner = pev( iEnt, pev_iuser2 );
		
		bDispenserBuild[ iOwner ] = false;
		set_pev( iEnt, pev_flags, pev( iEnt, pev_flags ) | FL_KILLME );
	}
}

stock UTIL_BreakModel( Float:flOrigin[ 3 ], model, flags )
{
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0 );
	write_byte( TE_BREAKMODEL );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	write_coord( 16 );
	write_coord( 16 );
	write_coord( 16 );
	write_coord( random_num( -20, 20 ) );
	write_coord( random_num( -20, 20 ) );
	write_coord( 10 );
	write_byte( 10 );
	write_short( model );
	write_byte( 10 );
	write_byte( 9 );
	write_byte( flags );
	message_end( );
}

stock UTIL_BeamEnts( Float:flStart[ 3 ], Float:flEnd[ 3 ], r, g, b )
{
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flStart );
	write_byte( TE_BEAMPOINTS );
	engfunc( EngFunc_WriteCoord, flStart[ 0 ] );
	engfunc( EngFunc_WriteCoord, flStart[ 1 ] );
	engfunc( EngFunc_WriteCoord, flStart[ 2 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 0 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 1 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 2 ] );
	write_short( gHealingBeam );
	write_byte( 5 );
	write_byte( 2 );
	write_byte( 1 );
	write_byte( 80 );
	write_byte( 1 );
	write_byte( r );
	write_byte( g );
	write_byte( b );
	write_byte( 130 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_GiveWeaponAmmo( index )
{
	new szCopyAmmoData[ 40 ];
	
	switch( get_user_weapon( index ) )
	{
		case CSW_P228: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_357sig" );
		case CSW_SCOUT, CSW_G3SG1, CSW_AK47: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_762nato" );
		case CSW_XM1014, CSW_M3: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_buckshot" );
		case CSW_MAC10, CSW_UMP45, CSW_USP: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_45acp" );
		case CSW_SG550, CSW_GALIL, CSW_FAMAS, CSW_M4A1, CSW_SG552, CSW_AUG: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_556nato" );
		case CSW_ELITE, CSW_GLOCK18, CSW_MP5NAVY, CSW_TMP: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_9mm" );
		case CSW_AWP: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_338magnum" );
		case CSW_M249: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_556natobox" );
		case CSW_FIVESEVEN, CSW_P90: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_57mm" );
		case CSW_DEAGLE: copy( szCopyAmmoData, charsmax( szCopyAmmoData ), "ammo_50ae" );
	}
	
	give_item( index, szCopyAmmoData );
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

stock bool:UTIL_IsVisible( index, entity, ignoremonsters = 0 )
{
	new Float:flStart[ 3 ], Float:flDest[ 3 ];
	pev( index, pev_origin, flStart );
	pev( index, pev_view_ofs, flDest );

	xs_vec_add( flStart, flDest, flStart );
    
	pev( entity, pev_origin, flDest );
	engfunc( EngFunc_TraceLine, flStart, flDest, ignoremonsters, index, 0 );
    
	new Float:flFraction;
	get_tr2( 0, TR_flFraction, flFraction );
	
	if( flFraction == 1.0 || get_tr2( 0, TR_pHit) == entity )
	{
		return true;
	}
    
	return false;
}

/* 		
	~~~~~~~~~~~~~~~~~~~~~~~
	      End of Code
	~~~~~~~~~~~~~~~~~~~~~~~
*/
