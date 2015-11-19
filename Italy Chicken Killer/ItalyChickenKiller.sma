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

#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <cstrike>

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

#define HUD_COLOR_R	255
#define HUD_COLOR_G	0
#define HUD_COLOR_B	0

new gCvarEnabled;
new gCvarChickenKillFrags;
new gCvarChickenKillMoney;
new gCvarChickenKillShowKiller;
new gCvarChickenKillType;
new gCvarChickenKillSlapDamage;
new gCvarChickenKillDamageType;

new gHudSyncCreate;

new const gChickenModelIndexes[][] =
{
	"*63", 
	"*66" 
};

new const gChickenKilledSound[] = "misc/killChicken.wav";

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
		gCvarChickenKillDamageType = register_cvar( "italy_chicken_dmgtype", "1" );
		
		gHudSyncCreate = CreateHudSyncObj();
	}
	
	else
	{
		pause( "a" );
		log_amx( "# [AMXX] :: Plugin paused because current map is <%s>.", szMapName );
	}
}

public plugin_precache()
{
	precache_sound( gChickenKilledSound );
}

public bacon_BreakableKilled( this, idinflictor, idattacker, Float:damage, damagebits )
{
	if( get_pcvar_num( gCvarEnabled ) != 0 && entity_get_float( this, EV_FL_health ) <= 0 )
	{
		new szModelIndex[ 12 ];
		entity_get_string( this, EV_SZ_model, szModelIndex, charsmax( szModelIndex ) );
		
		new szNameIndex[ 32 ];
		get_user_name( idattacker, szNameIndex, charsmax( szNameIndex ) );
		
		for( new i = 0; i < sizeof( gChickenModelIndexes ); i++ )
		{
			if( equal( szModelIndex, gChickenModelIndexes[ i ] ) )
			{
				switch( get_pcvar_num( gCvarChickenKillType ) )
				{
					case 0:
					{
						entity_set_float( idattacker, EV_FL_frags, float( get_user_frags( idattacker ) + get_pcvar_num( gCvarChickenKillFrags ) ) );
						cs_set_user_money( idattacker, cs_get_user_money( idattacker ) + get_pcvar_num( gCvarChickenKillMoney ), 1 );
					}
					
					case 1:
					{
						switch( get_pcvar_num( gCvarChickenKillDamageType ) )
						{
							case 1:	user_slap( idattacker, get_pcvar_num( gCvarChickenKillSlapDamage ) );
							case 2:	user_kill( idattacker );
						}
					}
				}

				if( get_pcvar_num( gCvarChickenKillShowKiller ) != 0 )
				{
					set_hudmessage( HUD_COLOR_R, HUD_COLOR_G, HUD_COLOR_B, -1.0, 0.72, 2, 6.0, 4.0 );
					ShowSyncHudMsg( 0, gHudSyncCreate, "!! %s killed a chicken !!", szNameIndex );
					
					client_cmd( 0, "speak ^"%s^"", gChickenKilledSound );
				}
			}
		}
	}
}
