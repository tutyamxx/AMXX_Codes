
#include < amxmodx >
#include < amxmisc >

#include < cstrike >

new gMoneyCost;
new gPluginEnabled;

const KEYS = MENU_KEY_1 | MENU_KEY_2;

public plugin_init()
{
	register_plugin( "C4 Drop Menu", "2.0.1", "tuty" );	
	
	register_clcmd( "drop", "HookDropBomb" );
	register_menucmd( register_menuid( "Are you sure?" ), KEYS, "c4_menu" );
	
	gMoneyCost = register_cvar( "c4_drop_cost", "6000" );
	gPluginEnabled = register_cvar( "c4_drop_plugin", "1" );
	
	register_dictionary( "c4_drop_menu.txt" );
}

public HookDropBomb( id )
{
	if( get_pcvar_num( gPluginEnabled ) 
	&& is_user_alive( id ) 
	&& get_user_weapon( id ) == CSW_C4 )
	{
		new szBuffer[ 300 ], iLen;
	
		iLen = formatex( szBuffer, charsmax( szBuffer ), "%L", id, "ARE_YOU_SURE" );
		iLen += formatex( szBuffer[ iLen ], charsmax( szBuffer ) - iLen, "%L", id, "SHOW_DROP_COST", get_pcvar_num( gMoneyCost) );
		iLen += formatex( szBuffer[ iLen ], charsmax( szBuffer ) - iLen, "%L", id, "YES_I_WANT" );
		iLen += formatex( szBuffer[ iLen ], charsmax( szBuffer ) - iLen, "%L", id, "NO_I_DONT" );
		
		show_menu( id, KEYS, szBuffer );
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public c4_menu( id, iKey )
{
	switch( iKey )
	{
		case 0:
		{
			new iCost = get_pcvar_num( gMoneyCost );
			new iMoney = cs_get_user_money( id );
			
			if( iMoney < iCost )
			{
				client_print( id, print_chat, "%L", id, "DONT_HAVE_CASH", iCost );
				
				return PLUGIN_HANDLED;
			}
			
			cs_set_user_money( id, iMoney - iCost, 1 );
			engclient_cmd( id, "drop", "weapon_c4" );
			
			return PLUGIN_HANDLED;
		}
		
		case 1:	return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}
