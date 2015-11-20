
#include < amxmodx >

#include < hamsandwich >
#include < fun >
#include < engine >
#include < fakemeta >
#include < cstrike >

#include < colorchat >

#pragma semicolon 1

#define MAX_PLAYERS		32 + 1
#define INVALID_CHARACTER	-1
#define JETPACK_SOUND_DELAY	2.0
#define write_coord_f(%1)	engfunc(EngFunc_WriteCoord,%1) 

#define TASK_YODA		321563
#define TASK_STORMTROOPER	298435


/* --| Setarile caracterelor */
#define MAUL_GRAVITY		0.7
#define MAULT_TELEPORTDELAY	20.0

#define VADER_DELAYDAMAGE	1.0
#define VADER_DAMAGE		10.0

#define JABBA_HEALTH		250
#define JABBA_SPEED		150.0

#define CHEwBACCA_HEALTH	250
#define CHEWBACCA_SPEED		150.0

#define JARJAR_SPEED		99999990.0
#define JARJAR_HEALTH		75

#define YODA_GRAVITY		0.4
#define YODA_HPDELAY		1.0
#define YODA_FORCESHIELDTIME	15.0
#define YODA_FORCESHIELD_DELAY	35.0
#define YODA_HEALTH_LIMIT	9999

#define STORMTROOPER_ARMOR	350

#define OBIWAN_HOLOGRAM_DELAY	3.0
/* --| Sfarsitul setarilor caracterelor */

enum _: iGoodCharacters
{
	CHARACTER_LUKE,
	CHARACTER_OBI,
	CHARACTER_YODA,
	CHARACTER_JARJARBINKS,
	CHARACTER_CHEWBACCA
};

enum _: iBadCharacters
{
	CHARACTER_DARTHMAUL,
	CHARACTER_DARTHVADER,
	CHARACTER_JABBA,
	CHARACTER_BOBAFETT,
	CHARACTER_STORMTROOPER
};

new const gGoodCharacterNames[ iGoodCharacters ][ ] =
{
	"Luke Skywalker",
	"Obi-Wan Kenobi",
	"Yoda",
	"Jar-Jar Binks",
	"Chewbacca"
};

new const gEvilCharacterNames[ iBadCharacters ][ ] = 
{
	"Darth Maul",
	"Darth Vader",
	"Jabba da Hut",
	"Boba Fett",
	"Storm Trooper"
};

new const gEvilCharactersAbi[ iBadCharacters ][ ] =
{
	"Gravitatie Scazuta + Teleport(Tasta T)",
	"-10 HP/s Doar uitandu-te la inamic",
	"Viteza scazuta + 250 Viata",
	"Jetpack (Tasta SPACE)",
	"350 Armura + Tracer la fiecare arma"
};

new const gGoodCharactersAbi[ iGoodCharacters ][ ] =
{
	"Stii cand se apropie un inamic",
	"Tot la 3s esti: Holograma/Invizibil",
	"Gravitatie Scazuta + 1 HP/s + 15s Force Shield(Tasta T)",
	"75 Viata + Viteza Mare",
	"Viteza Scazuta + 250 Viata"
};

new const gTag[ ] = "[FUN WD]";

new const gTeleportSound[ ] = "plats/squeekstop1.wav";
new const gJetpackSound[ ] = "ambience/flameburst1.wav";
new const gYodaShieldSound[ ] = "debris/metal5.wav";
new const gYodaShieldBlockSnd[ ] = "weapons/grenade_hit1.wav";
new const gLukeSound[ ] = "fvox/near_death.wav";

new Float:flLastTeleport[ MAX_PLAYERS ];
new Float:flLastDamage[ MAX_PLAYERS ];
new Float:flLastHp[ MAX_PLAYERS ];
new Float:flLastJpCheck[ MAX_PLAYERS ];
new Float:flLastSprite[ MAX_PLAYERS ];
new Float:flLastShield[ MAX_PLAYERS ];
new Float:flLastHologram[ MAX_PLAYERS ];
new Float:flLastNear[ MAX_PLAYERS ];

new bPlayerCharacter[ MAX_PLAYERS ][ 2 ];
new bYodaShield[ MAX_PLAYERS ];
new bObiHolo[ MAX_PLAYERS ];

new gHudSync;
new gMaxPlayers;
new gLaserBeam;
new gJetpackFlameSprite;

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

public plugin_init( )
{
	register_plugin( "Star Wars", "1.0.1", "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawn", 1 );
	RegisterHam( Ham_Player_PreThink, "player", "bacon_PreThink" );
	RegisterHam( Ham_Player_ResetMaxSpeed, "player", "bacon_ResetMaxSpeed", 1 );
	RegisterHam( Ham_TraceAttack, "worldspawn", "bacon_TraceAttack", 1 );
	RegisterHam( Ham_TraceAttack, "player", "bacon_TraceAttack", 1 );
	RegisterHam( Ham_TakeDamage, "player", "bacon_TakeDamage" );

	register_event( "DeathMsg", "Hook_Death", "a" );
	
	register_forward( FM_CmdStart, "fwd_cmdstart" );
	register_impulse( 201, "forward_Spray" );

	gHudSync = CreateHudSyncObj( );
	gMaxPlayers = get_maxplayers( );
	
	server_cmd( "sv_maxspeed 9999999999999.0" );
}

public plugin_precache( )
{
	gLaserBeam = precache_model( "sprites/laserbeam.spr" );
	gJetpackFlameSprite = precache_model( "sprites/explode1.spr" );

	precache_sound( gTeleportSound );
	precache_sound( gJetpackSound );
	precache_sound( gYodaShieldSound );
	precache_sound( gYodaShieldBlockSnd );
	precache_sound( gLukeSound );
}

public client_connect( id )
{
	bYodaShield[ id ] = 0;
}

public client_disconnect( id )
{
	bYodaShield[ id ] = 0;

	remove_task( id + TASK_YODA );
	remove_task( id + TASK_STORMTROOPER );
}

public bacon_PlayerSpawn( id )
{
	if( is_user_alive( id ) )
	{
		switch( get_user_team( id ) )
		{
			case 1:
			{
				bPlayerCharacter[ id ][ 0 ] = random( iBadCharacters );
				bPlayerCharacter[ id ][ 1 ] = INVALID_CHARACTER;
			
				new iCharacter = bPlayerCharacter[ id ][ 0 ];

				UTIL_ClearChat( id );
				ColorChat( id, RED, "^3%s^1 Acum esti eroul^4 %s^1. Abilitate:^4 %s", gTag, gEvilCharacterNames[ iCharacter ], gEvilCharactersAbi[ iCharacter ] );
			}

			case 2:
			{
				bPlayerCharacter[ id ][ 1 ] = random( iGoodCharacters );
				bPlayerCharacter[ id ][ 0 ] = INVALID_CHARACTER;
			
				new iCharacter2 = bPlayerCharacter[ id ][ 1 ];
				
				UTIL_ClearChat( id );
				ColorChat( id, RED, "^3%s^1 Acum esti eroul^4 %s^1. Abilitate:^4 %s", gTag, gGoodCharacterNames[ iCharacter2 ], gGoodCharactersAbi[ iCharacter2 ] );
			}
		}
		
		remove_task( id + TASK_YODA );
		bYodaShield[ id ] = 0;

		set_user_gravity( id, 1.0 );
		
		switch( bPlayerCharacter[ id ][ 0 ] )
		{
			case CHARACTER_JABBA:
			{
				set_user_health( id, JABBA_HEALTH );
			}

			case CHARACTER_DARTHMAUL:
			{
				set_user_gravity( id, MAUL_GRAVITY );
			}
			
			case CHARACTER_STORMTROOPER:
			{
				set_task( 0.8, "AddPlayerArmor", id + TASK_STORMTROOPER );
			}
		}
	
		switch( bPlayerCharacter[ id ][ 1 ] )
		{
			case CHARACTER_CHEWBACCA:
			{
				set_user_health( id, CHEwBACCA_HEALTH );
			}
		
			case CHARACTER_JARJARBINKS:
			{
				set_user_health( id, JARJAR_HEALTH );
			}

			case CHARACTER_YODA:
			{
				set_user_gravity( id, YODA_GRAVITY );
			}
		}
	}
}

public Hook_Death( )
{
	new iVictim = read_data( 2 );
	
	if( ( 1 <= iVictim <= gMaxPlayers ) )
	{
		remove_task( iVictim + TASK_YODA );
		remove_task( iVictim + TASK_STORMTROOPER );

		set_user_gravity( iVictim, 1.0 );
	}
}

public AddPlayerArmor( iTaskId )
{
	new id = iTaskId - TASK_STORMTROOPER;
	
	if( ( 1 <= id <= gMaxPlayers ) )
	{
		set_user_armor( id, STORMTROOPER_ARMOR );
	}
}

public bacon_ResetMaxSpeed( id )
{
	if( is_user_alive( id ) )
	{
		if( bPlayerCharacter[ id ][ 0 ] == CHARACTER_JABBA )
		{
			new Float:flMaxSpeed = JABBA_SPEED;
		
			engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed );
			set_pev( id, pev_maxspeed, flMaxSpeed );
		}
		
		switch( bPlayerCharacter[ id ][ 1 ] )
		{
			case CHARACTER_CHEWBACCA:
			{
				new Float:flMaxSpeed = CHEWBACCA_SPEED;
				
				engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed );
				set_pev( id, pev_maxspeed, flMaxSpeed );
			}

			case CHARACTER_JARJARBINKS: 
			{
				new Float:flMaxSpeed = JARJAR_SPEED;
			
				engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed );
				set_pev( id, pev_maxspeed, flMaxSpeed );
			}
		}
	}
}

public bacon_TraceAttack( iEnt, iAttacker, Float:flDamage, Float:fDir[ 3 ], ptr, iDamageType )
{
	if( !( 1 <= iAttacker <= gMaxPlayers ) && !( 1 <= iEnt <= gMaxPlayers ) )
	{
		return;
	}

	if( bPlayerCharacter[ iAttacker ][ 0 ] == CHARACTER_STORMTROOPER )
	{
		new iWeapon = get_user_weapon( iAttacker );

		if( iWeapon == CSW_KNIFE || iWeapon == CSW_C4
		|| iWeapon == CSW_HEGRENADE || iWeapon == CSW_SMOKEGRENADE
		|| iWeapon == CSW_FLASHBANG )
		{
			return;
		}
		
		new Float:flEnd[ 3 ];
		get_tr2( ptr, TR_vecEndPos, flEnd );

		UTIL_Tracer( iAttacker, flEnd );
	}
	
	if( bPlayerCharacter[ iEnt ][ 1 ] == CHARACTER_YODA )
	{
		if( bYodaShield[ iEnt ] == 1 )
		{
			new Float:flEnd[ 3 ];
			get_tr2( ptr, TR_vecEndPos, flEnd );

			UTIL_Sparks( flEnd );
			emit_sound( iEnt, CHAN_BODY, gYodaShieldBlockSnd, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
	}
}

public bacon_TakeDamage( victim, inflictor, attacker, Float:damage, damage_type )
{
	if( !( 1 <= victim <= gMaxPlayers ) )
	{
		return HAM_IGNORED;
	}
	
	if( bPlayerCharacter[ victim ][ 1 ] == CHARACTER_YODA )
	{
		if( bYodaShield[ victim ] == 1 )
		{
			return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}

public fwd_cmdstart( id, uc_handle, random_seed )
{
	if( !is_user_alive( id ) )
	{
		return FMRES_IGNORED;
	}

	if( bPlayerCharacter[ id ][ 0 ] == CHARACTER_BOBAFETT )
	{
		new iButton = get_uc( uc_handle, UC_Buttons );

		if( iButton & IN_JUMP )
		{
			new iFlags = pev( id, pev_flags );

			if( iFlags & FL_WATERJUMP || pev( id, pev_waterlevel ) >= 2 )
			{
				return FMRES_IGNORED;
			}

			new Float:flGameTime = get_gametime( );

			if( flGameTime - flLastJpCheck[ id ] > JETPACK_SOUND_DELAY )
			{
				emit_sound( id, CHAN_BODY, gJetpackSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
				flLastJpCheck[ id ] = flGameTime;
			}
			
			new iOrigin[ 3 ];
			get_user_origin( id, iOrigin, 0 );

			iOrigin[ 2 ] -= 20;
		
			new Float:flVelocity[ 3 ];
			pev( id, pev_velocity, flVelocity );

			flVelocity[ 2 ] += 25;
			set_pev( id, pev_velocity, flVelocity );
			
			if( flGameTime - flLastSprite[ id ] > 0.3 )
			{
				UTIL_Sprite( iOrigin, 0, 0, 0, gJetpackFlameSprite, 6, 120 );	
				
				flLastSprite[ id ] = flGameTime;
			}
		}
	}

	return FMRES_IGNORED;
}
	
public forward_Spray( id )
{
	if( is_user_alive( id ) )
	{
		if( bPlayerCharacter[ id ][ 0 ] == CHARACTER_DARTHMAUL )
		{
			new Float:flGameTime = get_gametime( );

			set_hudmessage( 10, 10, 255, -1.0, 0.89, 1, 6.0, 1.6 );

			if( flGameTime - flLastTeleport[ id ] < MAULT_TELEPORTDELAY )
			{
				ShowSyncHudMsg( id, gHudSync, "Teleportul nu este incarcat!^nAsteapta %d secunde!", floatround( flLastTeleport[ id ] + MAULT_TELEPORTDELAY - flGameTime + 1 ) );
			
				return PLUGIN_HANDLED;
			}
		
			new iDistance = 999999999, iTarget = 0, i, iDistance2;
			new iOrigin[ 3 ], iTargetOrigin[ 3 ];
		
			get_user_origin( id, iOrigin );
			
			for( i = 0; i <= gMaxPlayers; i++ )
			{
				if( is_user_connected( i ) && is_user_alive( i ) 
				&& get_user_team( id ) != get_user_team( i ) )
				{
					get_user_origin( i, iTargetOrigin );
					iDistance2 = get_distance( iOrigin, iTargetOrigin );
			
					if( iDistance > iDistance2 )
					{
						iDistance = iDistance2;
						iTarget = i;
					}
				}
			}

			if( iTarget == 0 )
			{
				ShowSyncHudMsg( id, gHudSync, "Nu a fost gasit niciun inamic!" );
			
				return PLUGIN_HANDLED;
			}
		
			new iCurrentOrigin[ 3 ];
			get_user_origin( iTarget, iCurrentOrigin );
		
			iCurrentOrigin[ 2 ] += 80;
		
			ShowSyncHudMsg( id, gHudSync, "Ai fost teleportat pe cel mai apropiat inamic!^nOrigini: X: %d | Y:%d | Z:%d", iCurrentOrigin[ 0 ], iCurrentOrigin[ 1 ], iCurrentOrigin[ 2 ] );
			set_user_origin( id, iCurrentOrigin );
			emit_sound( id, CHAN_BODY, gTeleportSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			UTIL_Teleport( iCurrentOrigin );
		
			flLastTeleport[ id ] = flGameTime;	
		}
		
		if( bPlayerCharacter[ id ][ 1 ] == CHARACTER_YODA )
		{
			set_hudmessage( 42, 255, 0, -1.0, 0.76, 1, 6.0, 2.0 );
			
			new Float:flGameTime = get_gametime( );

			if( bYodaShield[ id ] == 1 )
			{
				ShowSyncHudMsg( id, gHudSync, "Scutul Yoda este deja activ!" );
				
				return PLUGIN_HANDLED;
			}

			if( flGameTime - flLastShield[ id ] < YODA_FORCESHIELD_DELAY )
			{
				ShowSyncHudMsg( id, gHudSync, "Poti sa folosesti Scutul Yoda dupa %d secunde!", floatround( flLastShield[ id ] + YODA_FORCESHIELD_DELAY - flGameTime + 1 ) );
	
				return PLUGIN_HANDLED;
			}

			bYodaShield[ id ] = 1;

			set_task( YODA_FORCESHIELDTIME, "RemoveYodaShield", id + TASK_YODA );
			ShowSyncHudMsg( id, gHudSync, "Ai activat Scutul Yoda!^nNu vei mai primi daune timp de %d secunde!", floatround( YODA_FORCESHIELDTIME ) );
			emit_sound( id, CHAN_STATIC, gYodaShieldSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
		
	}
	
	return PLUGIN_CONTINUE;
}

public RemoveYodaShield( iTaskid )
{
	new id = iTaskid - TASK_YODA;
	
	new Float:flGameTime = get_gametime( );
	set_hudmessage( 42, 255, 0, -1.0, 0.76, 1, 6.0, 2.0 );

	if( ( 1 <= id <= gMaxPlayers ) )
	{
		bYodaShield[ id ] = 0;
		flLastShield[ id ] = flGameTime;

		ShowSyncHudMsg( id, gHudSync, "Scutul Yoda este acum dezactivat!" );
		emit_sound( id, CHAN_STATIC, gYodaShieldSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}

public bacon_PreThink( id )
{
	if( is_user_alive( id ) )
	{
		new Float:flGameTime = get_gametime( );

		if( bPlayerCharacter[ id ][ 0 ] == CHARACTER_DARTHVADER )
		{
			new iTarget, iDistance = 99999999, iBody;
			get_user_aiming( id, iTarget, iBody, iDistance );
			
			if( pev_valid( iTarget ) && get_user_team( id ) != get_user_team( iTarget ) && id != iTarget )
			{
				if( flGameTime - flLastDamage[ id ] >= VADER_DELAYDAMAGE )
				{
					ExecuteHam( Ham_TakeDamage, iTarget, 0, id, VADER_DAMAGE, DMG_BURN );
					
					flLastDamage[ id ] = flGameTime;
				}
			}				
		}
		
		switch( bPlayerCharacter[ id ][ 1 ] )
		{		
			case CHARACTER_YODA:
			{
				if( flGameTime - flLastHp[ id ] >= YODA_HPDELAY )
				{
					set_user_health( id, min( YODA_HEALTH_LIMIT, get_user_health( id ) + 1 ) );
				
					flLastHp[ id ] = flGameTime;
				}
			}
			
			case CHARACTER_OBI:
			{
				if( flGameTime - flLastHologram[ id ] >= OBIWAN_HOLOGRAM_DELAY )
				{
					if( bObiHolo[ id ] == 1 )
					{
						bObiHolo[ id ] = 0;
					}
				
					else if( bObiHolo[ id ] == 0 )
					{
						bObiHolo[ id ] = 1;
					}
					
					flLastHologram[ id ] = flGameTime;
				}
				
				switch( bObiHolo[ id ] )
				{
					case 0: set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha , 0 );
					case 1:	set_user_rendering( id, kRenderFxGlowShell, 255, 255, 255, kRenderTransAlpha, 45 );
				}
			}
			
			case CHARACTER_LUKE:
			{
				new i, iDistance, iOrigin[ 3 ], iOrigin2[ 3 ];
				get_user_origin( id, iOrigin );

				for( i = 1; i <= gMaxPlayers; i++ )
				{
					if( is_user_connected( i ) && is_user_alive( i ) 
					&& i != id && get_user_team( i ) != get_user_team( id ) )
					{
						get_user_origin( i, iOrigin2 );
						iDistance = get_distance( iOrigin, iOrigin2 );
				
						if( 400 > iDistance )
						{
							if( flGameTime - flLastNear[ id ] >= 4.0 )
							{
								client_cmd( id, "speak ^"%s^"", gLukeSound );
								engclient_print( id, engprint_center, "Un inamic este aproape de tine!^nUn inamic este aproape de tine!" );
							
								flLastNear[ id ] = flGameTime;
							}
						}
					}
				}
			}
		}
	}
}
	
stock UTIL_Tracer( iAttacker, Float:flEnd[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMENTPOINT );
	write_short( iAttacker | 0x1000 );
	write_coord_f( flEnd[ 0 ] ); 
	write_coord_f( flEnd[ 1 ] ); 
	write_coord_f( flEnd[ 2 ] ); 
	write_short( gLaserBeam );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 1 );
	write_byte( 5 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 10 );
	write_byte( 10 );
	write_byte( 200 );
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

stock UTIL_Sprite( iOrigin[ 3 ], iCoordX, iCoordY, iCoordZ, iSprite, iFrame, iBrightness )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_SPRITE );
	write_coord( iOrigin[ 0 ] + iCoordX );
	write_coord( iOrigin[ 1 ] + iCoordY );
	write_coord( iOrigin[ 2 ] + iCoordZ );
	write_short( iSprite );
	write_byte( iFrame );
	write_byte( iBrightness );
	message_end( );
}

stock UTIL_ClearChat( id )
{
	new i;

	for( i = 1; i < 7; i++ )
	{
		client_print( id, print_chat, "      " );
	}
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
