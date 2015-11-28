
#include < amxmodx >
#include < amxmisc >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.1"

#define LOG_FILE	"LoadingMenu.log"

new szBuffer[ 4000 + 1 ];

public plugin_init()
{
	register_plugin( "NON-Steam Loading Menu", PLUGIN_VERSION, "tuty" );
	
	register_cvar( "nonsteam_lmenu", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY );
}

public plugin_cfg( )
{
	new szConfigsDir[ 64 ], szFile[ 64 ];
	get_configsdir( szConfigsDir, charsmax( szConfigsDir ) );
	
	formatex( szFile, charsmax( szFile ), "%s/GameMenu.ini", szConfigsDir );
	
	if( !file_exists( szFile ) )
	{
		server_print( "[Loading Menu] Fisierul ^"%s^" nu exista! Trebuie pus in ^"%s^"", szFile, szConfigsDir );
		log_to_file( LOG_FILE, "[Loading Menu] Fisierul ^"%s^" nu exista! Trebuie pus in ^"%s^"", szFile, szConfigsDir );
		
		return 1;
	}
	
	new iFileIni = fopen( szFile, "rt" );
	
	while( !feof( iFileIni ) )
	{
		fgets( iFileIni, szBuffer, charsmax( szBuffer ) );
		
		server_print( "[Loading Menu] Continutul din fisierul ^"%s^" a fost extras!", szFile );
		log_to_file( LOG_FILE, "[Loading Menu] Continutul din fisierul ^"%s^" a fost extras!", szFile );
	}
	
	fclose( iFileIni );
	
	return 1;
}

public client_putinserver( id )
{
	set_task( 2.0, "ExecuteGameMenuEdit", id );
}

public ExecuteGameMenuEdit( id )
{
	new szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );

	client_cmd( id, "motdfile ^"resource/GameMenu.res^"" );
	client_cmd( id, "motd_write %s", szBuffer );
	
	server_print( "[Loading Menu] Datele au fost adaugate in meniul jucatorului <%s>", szName );
	log_to_file( LOG_FILE, "[Loading Menu] Datele au fost adaugate in meniul jucatorului <%s>", szName );
}
