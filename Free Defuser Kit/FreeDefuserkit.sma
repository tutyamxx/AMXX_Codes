
#include < amxmodx >

#include < hamsandwich >
#include < cstrike >

#pragma semicolon 1

new gEnableDefusers;
new gDefuseColor;

public plugin_init( )
{
	register_plugin( "Free Defuser KIT", "2.0.0", "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_Spawn", 1 );
	
	gEnableDefusers = register_cvar( "free_defuser", "1" );
	gDefuseColor = register_cvar( "free_defuser_color", "0 160 0" );
}

public bacon_Spawn( id )
{
	if( is_user_alive( id ) 
	&& get_pcvar_num( gEnableDefusers ) 
	&& cs_get_user_team( id ) == CS_TEAM_CT
	&& !cs_get_user_defuse( id ) )
	{
		new szColor[ 12 ], iRgb[ 3 ][ 4 ], r, g, b;
		get_pcvar_string( gDefuseColor, szColor, charsmax( szColor ) );
		
		parse( szColor, iRgb[ 0 ], 3, iRgb[ 1 ], 3, iRgb[ 2 ], 3 );
		
		r = clamp( str_to_num( iRgb[ 0 ] ) , 0, 255 );
		g = clamp( str_to_num( iRgb[ 1 ] ) , 0, 255 );
		b = clamp( str_to_num( iRgb[ 2 ] ) , 0, 255 );
		
		cs_set_user_defuse( id, 1, r, g, b );
	}

	return HAM_IGNORED;
}
