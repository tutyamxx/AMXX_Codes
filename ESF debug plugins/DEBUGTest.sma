
#include < amxmodx >

new gCvarTest;
new gCvarTest1;
new gCvarTest2;



// --| Just to know the colors
enum _ExplosionColors
{
	COLOR_BLUE = 0,
	COLOR_GREEN,
	COLOR_ORANGE,
	COLOR_PURPLE,
	COLOR_YELLOW,
	COLOR_RED,
	COLOR_WHITE
};

public plugin_init( )
{
	register_message( get_user_msgid( "Explosion" ), "ManageExplosionSize" );
	register_message( get_user_msgid( "EETrail" ), "ManageAttackSize" );
	// special beam cannon register_message( get_user_msgid( "SBCTrail" ), "ManageSpecialBeamSize" );
	// deathball register_message( get_user_msgid( "Ball" ), "ManageDeathBall" );
	// transform effect register_message( get_user_msgid( "Transform" ), "managetransform" );
	// teleport register_message( get_user_msgid( "AfterFX" ), "dsadsa" );
	
	gCvarTest = register_cvar( ".DEBUG.AttackSize",  "10" );
	gCvarTest1 = register_cvar( ".DEBUG.ExplosionSize", "80" );
	gCvarTest2 = register_cvar( ".DEBUG.ExplosionColor", "0" );
}

public ManageAttackSize( )
{
	set_msg_arg_int( 9, ARG_BYTE, get_pcvar_num( gCvarTest ) );
}

public ManageExplosionSize( )
{
	set_msg_arg_int( 4, ARG_LONG, get_pcvar_num( gCvarTest1 ) );
	set_msg_arg_int( 5, ARG_BYTE, get_pcvar_num( gCvarTest2 ) );
}
