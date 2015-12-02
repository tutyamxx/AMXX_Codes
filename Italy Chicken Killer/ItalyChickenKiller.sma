/*	Copyright © 2010, tuty

	Italy Chicken Killer is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with DeathRun No FallDown; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include < amxmodx >

#include < hamsandwich >
#include < fakemeta >
#include < cstrike >

#pragma semicolon 1

#define PLUGIN_VERSION	"2.0.0"

new gCvarEnabled;
new gCvarChickenKillFrags;
new gCvarChickenKillMoney;
new gCvarChickenKillShowKiller;
new gCvarChickenKillType;
new gCvarChickenKillSlapDamage;
new gCvarChickenKillDamageType;

new gHudSyncCreate;
new gMessageScoreInfo;

new const szChickenTargetNames[ ][ ] =
{
	"chicken1kill",
	"chicken2kill"
};

new const gChickenKilledSound[ ] = "misc/killChicken.wav";

public plugin_init()
{
	register_plugin( "Italy Chicken Killer", PLUGIN_VERSION, "tuty" );
	
	new szMapName[ 10 ];
	get_mapname( szMapName, charsmax( szMapName ) );
	
	if( equali( szMapName, "cs_italy" ) )
	{
		RegisterHam( Ham_TakeDamage, "func_breakable", "bacon_BreakableKilled", 1 );
		
		gCvarEnabled = register_cvar( "italy_chicken_kill", "1" );
		gCvarChickenKillFrags = register_cvar( "italy_chicken_frags", "2" );
		gCvarChickenKillMoney = register_cvar( "italy_chicken_money", "50" );
		gCvarChickenKillShowKiller = register_cvar( "italy_chicken_showkiller", "1" );
		gCvarChickenKillType = register_cvar( "italy_chicken_type", "1" );
		gCvarChickenKillSlapDamage = register_cvar( "italy_chicken_slapdmg", "13" );
		gCvarChickenKillDamageType = register_cvar( "italy_chicken_dmgtype", "3" );
		
		gHudSyncCreate = CreateHudSyncObj( );
		
		gMessageScoreInfo = get_user_msgid( "ScoreInfo" );
	}
	
	else
	{
		pause( "a" );
		log_amx( "# [AMXX] :: Plugin paused because current map <%s> is not a ^"cs_italy^" map.", szMapName );
	}
}

public plugin_precache( )
{
	precache_sound( gChickenKilledSound );
}

public bacon_BreakableKilled( this, idinflictor, idattacker, Float:damage, damagebits )
{
	if( get_pcvar_num( gCvarEnabled ) != 0 
	&& pev( this, pev_health ) <= 0 )
	{
		new szTargetName[ 14 ];
		pev( this, pev_target, szTargetName, charsmax( szTargetName ) );

		new szNameIndex[ 32 ];
		get_user_name( idattacker, szNameIndex, charsmax( szNameIndex ) );
		
		for( new i = 0; i < sizeof( szChickenTargetNames ); i++ )
		{
			if( equal( szTargetName, szChickenTargetNames[ i ] ) )
			{
				switch( get_pcvar_num( gCvarChickenKillType ) )
				{
					case 0:
					{
						set_pev( idattacker, pev_frags, float( get_user_frags( idattacker ) + get_pcvar_num( gCvarChickenKillFrags ) ) );
						cs_set_user_money( idattacker, cs_get_user_money( idattacker ) + get_pcvar_num( gCvarChickenKillMoney ), 1 );
					
						UTIL_UpdateScoreboard( idattacker );
					}
					
					case 1:
					{
						switch( get_pcvar_num( gCvarChickenKillDamageType ) )
						{
							case 1:		user_slap( idattacker, get_pcvar_num( gCvarChickenKillSlapDamage ) );
							case 2:		user_kill( idattacker );
							case 3: 	ExecuteHam( Ham_TakeDamage, idattacker, 0, idattacker, 999999999.9, DMG_GENERIC );
						}
					}
				}

				if( get_pcvar_num( gCvarChickenKillShowKiller ) != 0 )
				{
					set_hudmessage( 255, 0, 0, -1.0, 0.72, 2, 6.0, 4.0 );
					ShowSyncHudMsg( 0, gHudSyncCreate, "!! %s killed a chicken !!", szNameIndex );
					
					client_cmd( 0, "speak ^"%s^"", gChickenKilledSound );
				}
			}
		}
	}
}

stock UTIL_UpdateScoreboard( id )
{
	message_begin( MSG_ALL, gMessageScoreInfo );
	write_byte( id );
	write_short( get_user_frags( id ) );
	write_short( get_user_deaths(id ) );
	write_short( 0 );
	write_short( get_user_team( id ) ); 
	message_end( );
}
