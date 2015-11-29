/*
	CopyRight © 2010, tuty

	QUEST Mod (Chaos Edition) is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with QUEST Mod (Chaos Edition); if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

/* 
	
	====================================
	Quest Mod creat special pentru Chaos
	Pentru serverul dr.mapping.ro NR.1 ROMANIA!
	By: tuty
	====================================

*/



#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >
#include < fakemeta >
#include < engine >
#include < fun >
#include < vault >

#include "QuestMod/Constants.inl"
#include "QuestMod/KnifePrecache.inl"
#include "QuestMod/HalfLifePrecache.inl"
#include "QuestMod/Events.inl"
#include "QuestMod/Commands.inl"
#include "QuestMod/Menus.inl"
#include "QuestMod/Cvars.inl"
#include "QuestMod/EffectStocks.inl"

#pragma semicolon 1

public plugin_init( )
{
	register_plugin( "QUEST Mod", PLUGIN_VERSION, "tuty" );
	
	QuestMod_RegisterCommands( );
	
	QuestMod_Menus( );
	
	QuestMod_RegisterEvents( );
	
	QuestMod_RegisterCvars( );
	
	set_task( 200.0, "QuestMsg", _, _, _, "b" );
	
	gMessageScreenShake = get_user_msgid( "ScreenShake" );
	gMessageScreenFade = get_user_msgid( "ScreenFade" );
	gMessageSayText = get_user_msgid( "SayText" );
	gClCorpseMessage = get_user_msgid( "ClCorpse" );
	
	gHudSync1 = CreateHudSyncObj( );
	gHudSync2 = CreateHudSyncObj( );
	gMaxPlayers = get_maxplayers( );
}

public plugin_precache( )
{
	QuestMod_PrecacheFromHalfLife( );
	QuestMod_Precache( );
}

public QuestMsg( )
{
	set_hudmessage( random( 256 ), random( 256 ), random( 256 ), -1.0, 0.22, 1, 6.0, 12.0 );
	ShowSyncHudMsg( 0, gHudSync1, "[Quest Mod] versiunea [%s] creat de [tuty]", PLUGIN_VERSION );
}

/* 
	
	====================================
	Quest Mod creat special pentru Chaos
	Pentru serverul dr.mapping.ro NR.1 ROMANIA!
	By: tuty
	====================================

*/
