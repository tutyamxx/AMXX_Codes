
#include < amxmodx >

new gPluginMode;

new const gSkies[ ][ ] =
{
	"2desert", "alien1", "alien2", "alien3",
	"black", "city", "cliffe", "desert",
	"dusk", "morning","neb1", "neb6",
	"neb7", "space", "xen10", "xen8",
	"xen9", "night", "black","green",
	"blue", "backalley", "city1", "morningdew",
	"hav", "cliff", "office", "grnplsnt",
	"tornsky", "doom1", "cx", "de_storm",
	"snowlake_", "tornsky", "trainyard", "tsccity_",
	"snow", "2desert", "des"
};

public plugin_init( )
{
	register_plugin( "Random Skies", "2.0.0", "tuty" );
	
	gPluginMode = register_cvar( "sv_skies_mode", "1" );  // 0 - disabled, 1 - random skies
}

public plugin_end( )
{
	if( get_pcvar_num( gPluginMode ) == 1 )
	{
		server_cmd( "sv_skyname %s", gSkies[ random_num( 0, charsmax( gSkies ) ) ] );
	}
}
