
#include < amxmodx > 
#include < hamsandwich > 

#pragma semicolon 1

#define DMG_DROWN		( 1 << 14 )

new gEnabled;

public plugin_init( )
{
        register_plugin( "No Drown", "1.0.4", "tuty" ); 

        RegisterHam( Ham_TakeDamage, "player", "bacon_TakeDamage" );  

        gEnabled= register_cvar( "sv_nodrown", "1" ); 
}

public bacon_TakeDamage( client, inflictor, attacker, Float:damage, damagebits )
{
	if( get_pcvar_num( gEnabled ) == 1 )
	{
		if( damagebits & DMG_DROWN )
		{
			return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}
