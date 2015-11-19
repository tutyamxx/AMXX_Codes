
#include < amxmodx >

#include < engine >
#include < hamsandwich >

#define ADMIN_ACCESS_LEVEL 	ADMIN_IMMUNITY  
#define CHECK_TIME 		0.5

#define esf_get_ki(%1)		entity_get_float( %1, EV_FL_fuser4 )
#define esf_set_ki(%1,%2)	entity_set_float( %1, EV_FL_fuser4, %2 )  

new gCvar;

public plugin_init( )
{
	register_plugin( "ESF Admin Unlimited KI", "3.0.0", "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_SpawnPost", 1 );
	
	gCvar = register_cvar( "esf_admin_unlimited_ki", "1" );
}

public client_disconnect( id )
{
	remove_task( id );
}

public bacon_SpawnPost( iPlayer )
{
	if( get_pcvar_num( gCvar ) == 1 )
	{
		if( is_user_alive( iPlayer ) 
		&& ( get_user_flags( iPlayer ) & ADMIN_ACCESS_LEVEL ) )
		{
			set_task( CHECK_TIME, "Task_checkAdminKi", iPlayer , "", 0, "b" );
		}
	}
}

public Task_checkAdminKi( iPlayer )
{
	if( !is_user_alive( iPlayer ) )
	{
		remove_task( iPlayer );
		
		return PLUGIN_HANDLED;
	}
	
	esf_set_ki( iPlayer, floatmax( 1000.0, esf_get_ki( iPlayer ) ) );
	
	return PLUGIN_CONTINUE;
}
