#include <amxmodx>
#include <amxmisc>

#pragma semicolon 1	

#define PLUGIN_NAME	"Weapon name Replacer"
#define PLUGIN_VERSION 	"1.0"
#define PLUGIN_AUTHOR 	"tuty"

#define MAX_LINES	70 

new gWeaponReplace[ 2 ][ MAX_LINES ][ 30 ];
new gNumCount;
new gPluginEnabled;

public plugin_init() 
{
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
	register_message( get_user_msgid( "DeathMsg" ), "registered_death_message" );
	
	gPluginEnabled = register_cvar( "wnr_enabled", "1" );
}
public plugin_cfg()
{
	new szDir[ 64 ], iFile[ 64 ];
	
	get_configsdir( szDir, charsmax( szDir ) );
	formatex( iFile, charsmax( iFile ), "%s/wnr.ini", szDir );
	
	if( !file_exists( iFile ) )
	{
		write_file( iFile, " ", -1 );
		server_print( "File %s doesn't exist. Creating one now!", iFile );
	}
	
	new szBuffer[ 500 ];
	new szFile = fopen( iFile, "rt" );
	
	while( !feof( szFile ) )
	{
		fgets( szFile, szBuffer, charsmax( szBuffer ) );
		
		if( szBuffer[ 0 ] == ';' || szBuffer[ 0 ] == '#' || szBuffer[ 0 ] == ' ' )
		{
			continue;
		}
		
		strtok( szBuffer, gWeaponReplace[ 0 ][ gNumCount ], charsmax( gWeaponReplace[][] ), gWeaponReplace[ 1 ][ gNumCount ], charsmax( gWeaponReplace[][] ), '/', 0 );
		gNumCount++;
	}
	
	fclose( szFile );
}
public registered_death_message()
{
	if( get_pcvar_num( gPluginEnabled ) != 0 )
	{
		new iWeapon[ 18 ], i;
		get_msg_arg_string( 4, iWeapon, charsmax( iWeapon ) );
		
		for( i = 0; i < gNumCount; i++ )
		{
			if( equal( iWeapon, gWeaponReplace[ 0 ][ i ] ) )
			{
				set_msg_arg_string( 4, gWeaponReplace[ 1 ][ i ] );
			}
		}
	}
}
