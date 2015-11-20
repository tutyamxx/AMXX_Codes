
#include < amxmodx >
#include < amxmisc >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

new gTagNameTE[ ] = "a";
new gTagNameCT[ ] = "b";

new gLastTag[ ] = "<100>";

public plugin_init()
{
	register_plugin( "TAG", PLUGIN_VERSION, "tuty" );
	
	register_event( "TeamInfo", "Hook_TeamInfo", "a" );
}

public Hook_TeamInfo()
{
	new id = read_data( 1 );
		
	new szTeam[ 2 ];
	read_data( 2, szTeam, charsmax( szTeam ) ); 
	
	new szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );
	
	new szFormatName[ 50 ];

	switch( szTeam[ 0 ] )
	{	
		case 'T':
		{
			if( equal( szName, gTagNameTE, charsmax( gTagNameTE ) ) )
			{
				return;
			}
			
			if( !replace( szName, charsmax( szName ), gTagNameCT, gTagNameTE ) )
			{
				formatex( szFormatName, charsmax( szFormatName ), "%s. %s%s", gTagNameTE, szName, gLastTag );
			}

			set_user_info( id, "name", szFormatName );
		}

		case 'C':
		{
			if( equal( szName, gTagNameCT, charsmax( gTagNameCT ) ) )
			{
				return;
			}
			
			if( !replace( szName, charsmax( szName ), gTagNameTE, gTagNameCT ) )
			{
				formatex( szFormatName, charsmax( szFormatName ), "%s. %s%s", gTagNameCT, szName, gLastTag );
			}
			
			set_user_info( id, "name", szFormatName );
		}
	}

	return;
}
