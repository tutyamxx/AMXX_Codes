/* 

	L-am reeditat sa nu se suprapuna mesajul asta HUD cu altele
  	Acum sta intruna fara sa licareasca sau sa dispara!
   	Have fun!
*/


#include < amxmodx >
#include < amxmisc >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

new gHostName;
new gNextMap;
new gHudSync;

public plugin_init()
{
	register_plugin( "Deathrun Statistici", PLUGIN_VERSION, "tuty" );
	
	set_task( 1.1, "showStatistics", _, _, _, "b" );
	
	gHostName = get_cvar_pointer( "hostname" );
	gNextMap = get_cvar_pointer( "amx_nextmap" );
	gHudSync = CreateHudSyncObj();
}

public showStatistics()
{
	new szHostName[ 64 ];
	get_pcvar_string( gHostName, szHostName, charsmax( szHostName ) );
	
	new szCurrentMap[ 64 ];
	get_mapname( szCurrentMap, charsmax( szCurrentMap ) );
	
	new szNextMap[ 64 ];
	get_pcvar_string( gNextMap, szNextMap, charsmax( szNextMap ) );
	
	new iTimeleft = get_timeleft();
	
	set_hudmessage( 255, 212, 42, -1.0, 0.0, 0, 6.0, 4.0 );
	ShowSyncHudMsg( 0, gHudSync, "%s - HARTA JUCATA: %s^nURMATOAREA HARTA: %s - TIMP RAMAS: %d:%02d", szHostName, szCurrentMap, szNextMap, ( iTimeleft / 60 ), ( iTimeleft % 60 ) );
}
