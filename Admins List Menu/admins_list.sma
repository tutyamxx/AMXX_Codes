
#include < amxmodx >
#include < amxmisc >
#include < colorchat >

#define	MAX_GRADES	8
#define MAX_PLAYERS	32 + 1

new const gAdminFlags[ MAX_GRADES ][ ] = 
{
	"abcdefghijklmnopqrstu",
	"abcdefghijklmnopqrst",
	"bcdefghijklmnopqrst",
	"bcdefghijlmnopqrst",
	"bcdefgijlmnopqr",
	"bcdefgijmnop",
	"bcefijmno",
	"b"
};

new const gAdminGradeNames[ MAX_GRADES ][ ] =
{
	"Owner",
	"Co-Owner",
	"Maresal",
	"General",
	"Colonel",
	"Maior",
	"Sergent",
	"Slot"
};

new const gTag[ ] = "[FUN WD]";

new gMaxPlayers;

public plugin_init()
{
	register_plugin( "Admins Online Menu", "0.1", "Exolent / tuty" );
	
	register_clcmd( "say_team /admins", "CmdAdmins" );
	register_clcmd( "say /admins", "CmdAdmins" );
	register_clcmd( "say /admin", "CmdAdmins" );
	register_clcmd( "say_team /admin", "CmdAdmins" );
	register_clcmd( "say /who", "CmdAdmins" );
	register_clcmd( "say_team /who", "CmdAdmins" );
	
	gMaxPlayers = get_maxplayers( );
}

public CmdAdmins( client )
{
	ShowMainMenu( client );
}

public ShowMainMenu( client )
{
	new iMenu = menu_create( "\yAdmini Online:", "MenuSelect" );
	
	new bool:bAdminsInServer = false;
	
	new szName[ 32 ], i, j, szFormatExMenu[ 3000 ];

	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_bot( i ) )
		{
			continue;
		}

		get_user_name( i, szName, charsmax( szName ) );

		for( j = 0; j < MAX_GRADES; j++ )
		{
			if( is_user_connected( i ) )
			{
				if( get_user_flags( i ) == read_flags( gAdminFlags[ j ] ) )
				{
					formatex( szFormatExMenu, charsmax( szFormatExMenu ), "\w%s \d(%s)", szName, gAdminGradeNames[ j ] );
					
					menu_additem( iMenu, szFormatExMenu, "" );
				
					bAdminsInServer = true;
				}
			}
		}
	}
	
	if( bAdminsInServer )
	{
		menu_display( client, iMenu );
	}

	else
	{
		ColorChat( client, RED, "^3%s^1 Nu sunt admini online!", gTag );
		
		menu_destroy( iMenu );
	}
}

public MenuSelect( client, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		
		return PLUGIN_HANDLED;
	}
	
	menu_display( client, menu );
	
	return PLUGIN_HANDLED;
}
