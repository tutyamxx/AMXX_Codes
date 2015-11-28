
#include < amxmodx >

public plugin_init( )
{
	register_message( get_user_msgid( "VGUIMenu" ), "block_charactersmenu" );
}

public block_charactersmenu( )
{
	if( get_msg_arg_int( 1 ) == 3 )
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_ONTINUE;
}
