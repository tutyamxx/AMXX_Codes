
/* 
	Codat special pt MediaCS :)
	Cumparat cu 5$ :D
	
	Autor: tuty
	6 Iunie 2011
*/


#include < amxmodx >
#include < amxmisc >

#include < fakemeta >
#include < engine >
#include < nvault >
#include < hamsandwich >
#include < colorchat >

#pragma semicolon 1

#define PLUGIN_VERSION		"1.0.4"

#define COMMAND_ACCESS		ADMIN_KICK		// accesu adminilor pt comanda
#define MAX_PLAYERS		32 + 1
#define MAX_WORDS		200
#define MINUTE_IN_SECOND	60

#define MINUTE_LIMIT		300			// limita maxima pentru gag minute
#define AUTOGAG_MINUTE		2			// minutele pt gag cand ia autogag

new const gLogFileName[ ] = "GagLog.log";		// fisierul pentru log
new const gGagFileName[ ] = "GagWords.ini";     // fisierul cu cuvinte sau reclame
	
new const gGagThinkerClassname[ ] = "GagThinker_";
new const gGagVaultName[ ] = "GaggedPlayers";

new const gGaggedSound[ ] = "misc/gag_dat.wav";
new const gUnGaggedSound[ ] = "misc/gag_scos.wav";

new const gHalfLifeGaggedSounds[ ][ ] =
{
	"barney/youtalkmuch.wav",
	"scientist/stopasking.wav",
	"scientist/shutup.wav",
	"scientist/shutup2.wav",
	"hgrunt/silence!.wav"
};

new const gTag[ ] = "[Deathrun]";

new bPlayerGagged[ MAX_PLAYERS ];
new bPlayerGagTime[ MAX_PLAYERS ];
new bJoinTime[ MAX_PLAYERS ];

new gWords[ MAX_WORDS ][ 32 ];

new gVault;
new giNum;
new gMaxPlayers;
new gCvarAdminGag;

public plugin_init( )
{
	register_plugin( "Advanced Gag", PLUGIN_VERSION, "tuty" );
	
	register_concmd( "amx_gag", "CommandGag", COMMAND_ACCESS, "<nume> <minute> <motiv>" );
	register_concmd( "amx_ungag", "CommandUngag", COMMAND_ACCESS, "<nume>" );
	
	register_clcmd( "say", "CheckGag" );
	register_clcmd( "say_team", "CheckGag" );

	UTIL_GagThinker( );
	register_think( gGagThinkerClassname, "Forward_GagThinker" );

	gCvarAdminGag = register_cvar( "gag_admingag", "0" );
	gMaxPlayers = get_maxplayers( );
	
	UTIL_CheckServerLicense( "93.119.26.88:27015", 0 );
}

public plugin_cfg( )
{
	new szConfigDir[ 64 ], iFile[ 64 ];
	
	get_configsdir( szConfigDir, charsmax( szConfigDir ) );
        formatex( iFile, charsmax( iFile ), "%s/%s", szConfigDir, gGagFileName );

	if( !file_exists( iFile ) )
        {
        	write_file( iFile, "# Pune aici cuvintele jignitoare sau reclamele^n# Spatiu publicitar :))", -1 );
		log_to_file( gLogFileName, "%s Fisierul <%s> nu exista! Creez unul nou acum...", gTag, iFile );
	}
	
	new szBuffer[ 128 ];
        new szFile = fopen( iFile, "rt" );

        while( !feof( szFile ) )
        {
        	fgets( szFile, szBuffer, charsmax( szBuffer ) );

           	if( szBuffer[ 0 ] == '#' )
           	{
                	continue;
            	}
		
		parse( szBuffer, gWords[ giNum ], sizeof gWords[ ] - 1 );
		giNum++;
		
		if( giNum >= MAX_WORDS )
		{
			break;
		}
	}
	
	fclose( szFile );
}
	
public plugin_precache( )
{
	new i;
	for( i = 0; i < sizeof gHalfLifeGaggedSounds; i++ )
	{
		precache_sound( gHalfLifeGaggedSounds[ i ] );
	}

	precache_sound( gGaggedSound );
	precache_sound( gUnGaggedSound );
}
	
public client_disconnect( id )
{
	if( bPlayerGagged[ id ] == 1 )
	{
		new szName[ 32 ], szIp[ 40 ], szAuthid[ 32 ];

		get_user_name( id, szName, charsmax( szName ) );
		get_user_ip( id, szIp, charsmax( szIp ) );
		get_user_authid( id, szAuthid, charsmax( szAuthid ) );
		
		ColorChat( 0, RED, "^4%s^1 Jucatorul cu gag^4 %s^1(^3%s^1|^3%s^1), s-a deconectat!", gTag, szName, szIp, szAuthid );
		log_to_file( gLogFileName, "%s Jucatorul cu gag <%s><%s><%s>, s-a deconectat!", gTag, szName, szIp, szAuthid );
	}

	bJoinTime[ id ] = 0;
	UTIL_SaveGag( id );
}

public client_connect( id )
{
	UTIL_LoadGag( id );
}

public client_putinserver( id )
{
	if( is_user_connected( id ) )
	{
		bJoinTime[ id ] = get_systime( );
	}
}
			
public CheckGag( id )
{
	new szSaid[ 300 ];

	read_args( szSaid, charsmax( szSaid ) );
	remove_quotes( szSaid );
	
	if( !UTIL_IsValidMessage( szSaid ) )
	{
		return PLUGIN_HANDLED;
	}

	if( bPlayerGagged[ id ] == 1 )
	{	
		ColorChat( id, RED, "^4%s^1 Ai primit Gag pentru limbaj vulgar, asteapta^4 %d^1 minute!", gTag, bPlayerGagTime[ id ] );
		client_cmd( id, "speak ^"%s^"", gHalfLifeGaggedSounds[ random_num( 0, charsmax( gHalfLifeGaggedSounds ) ) ] );	

		return PLUGIN_HANDLED;
	}
	
	else
	{
		new i;
		for( i = 0; i < MAX_WORDS; i++ )
		{
			if( containi( szSaid, gWords[ i ] ) != -1 )
			{	
				if( get_pcvar_num( gCvarAdminGag ) == 0 )
				{
					if( is_user_admin( id ) )
					{	
						return PLUGIN_CONTINUE;
					}
				}
				
				new szName[ 32 ], szIp[ 40 ], szAuthid[ 32 ];

				get_user_name( id, szName, charsmax( szName ) );
				get_user_ip( id, szIp, charsmax( szIp ) );
				get_user_authid( id, szAuthid, charsmax( szAuthid ) );
			

				bPlayerGagged[ id ] = 1;
				bPlayerGagTime[ id ] = AUTOGAG_MINUTE;
				set_speak( id, SPEAK_MUTED );
				
				ColorChat( 0, RED, "^3%s^4 %s^1 (^%s | %s)^4 a primit AutoGag pentru limbaj sau reclama!", gTag, szName, szIp, szAuthid );
				ColorChat( id, RED, "^4%s^1 Ai primit AutoGag pentru injuratura sau reclama! Timpul expira in:^4 %d^1 minute!", gTag, AUTOGAG_MINUTE );
				ColorChat( id, RED, "^4%s^1 Nu mai poti folosi urmatoarele comenzi:^4 say^1,^4 say_team^1,^4 voice speak", gTag );
				
				log_to_file( gLogFileName, "%s <%s><%s><%s> a luat AutoGag pentru ca a injurat sau a facut reclama!", gTag, szName, szIp, szAuthid );
		
				client_cmd( id, "speak ^"%s^"", gGaggedSound );
				
				return PLUGIN_HANDLED;
			}
		}
	}

	return PLUGIN_CONTINUE;
}
 
public CommandGag( id, level, cid )
{
	if( !cmd_access( id, level, cid, 2 ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new szArg[ 32 ], szMinutes[ 32 ], szReason[ 32 ];

	read_argv( 1, szArg, charsmax( szArg ) );
	
	new iTarget = cmd_target( id, szArg, CMDTARGET_ALLOW_SELF );

	if( !iTarget )
	{
		return PLUGIN_HANDLED;
	}
	
	if( get_pcvar_num( gCvarAdminGag ) == 0 )
	{
		if( is_user_admin( iTarget ) )
		{
			console_print( id, "%s Nu poti da gag la Admini!", gTag );
			
			return PLUGIN_HANDLED;
		}
	}

	read_argv( 2, szMinutes, charsmax( szMinutes ) );
	read_argv( 3, szReason, charsmax( szReason ) );
	
	new iMinutes = str_to_num( szMinutes );

	if( iMinutes > MINUTE_LIMIT )
	{
		console_print( id, "%s Ai setat %d minute, iar limita maxima de minute este %d! Setare automata pe %d.", gTag, iMinutes, MINUTE_LIMIT, MINUTE_LIMIT );
		iMinutes = MINUTE_LIMIT;
	}

	new szAdminName[ 40 ], szName[ 32 ], szIp[ 40 ], szAuthid[ 32 ];

	get_user_name( id, szAdminName, charsmax( szAdminName ) );
	get_user_name( iTarget, szName, charsmax( szName ) );
	get_user_ip( iTarget, szIp, charsmax( szIp ) );
	get_user_authid( iTarget, szAuthid, charsmax( szAuthid ) );

	if( bPlayerGagged[ iTarget ] == 1 )
	{
		console_print( id, "%s Jucatorul %s are deja Gag!", gTag, szName );
		
		return PLUGIN_HANDLED;
	}

	bPlayerGagged[ iTarget ] = 1;
	bPlayerGagTime[ iTarget ] = iMinutes;
	set_speak( iTarget, SPEAK_MUTED );
	
	ColorChat( 0, RED, "^4%s^1 ADMIN^4 %s:^1 Gag^3 %s^1(^3%s^1) pentru^4 %d^1 minute, motiv:^4 %s", gTag, szAdminName, szName, szIp, iMinutes, szReason );
	ColorChat( iTarget, RED, "^4%s^1 Ai primit Gag pentru ca ai injurat sau ai facut reclama!", gTag );
	ColorChat( iTarget, RED, "^4%s^1 Nu mai poti folosi urmatoarele comenzi:^4 say^1,^4 say_team^1,^4 voice speak", gTag );
	
	log_to_file( gLogFileName, "%s %s i-a dat gag lui <%s><%s><%s> pt. <%d> minute, motiv: <%s>", gTag, szAdminName, szName, szIp, szAuthid, iMinutes, szReason );

	client_cmd( iTarget, "speak ^"%s^"", gGaggedSound );
	
	return PLUGIN_HANDLED;
}

public CommandUngag( id, level, cid )
{
	if( !cmd_access( id, level, cid, 2 ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new szArg[ 32 ];
	read_argv( 1, szArg, charsmax( szArg ) );
	
	new iTarget = cmd_target( id, szArg, CMDTARGET_ALLOW_SELF );

	if( !iTarget )
	{
		return PLUGIN_HANDLED;
	}
	
	new szAdminName[ 40 ], szName[ 32 ], szIp[ 40 ], szAuthid[ 32 ];

	get_user_name( id, szAdminName, charsmax( szAdminName ) );
	get_user_name( iTarget, szName, charsmax( szName ) );
	get_user_ip( iTarget, szIp, charsmax( szIp ) );
	get_user_authid( iTarget, szAuthid, charsmax( szAuthid ) );
	
	if( bPlayerGagged[ iTarget ] == 0 )
	{
		console_print( id, "%s Jucatorul %s nu are Gag!", gTag, szName );
		
		return PLUGIN_HANDLED;
	}

	bPlayerGagged[ iTarget ] = 0;
	bPlayerGagTime[ iTarget ] = 0;
	set_speak( iTarget, SPEAK_NORMAL );
	
	ColorChat( 0, RED, "^4%s^1 ADMIN^4 %s:^1 Ungag^3 %s^1(^3%s^1|^3%s^1)", gTag, szAdminName, szName, szIp, szAuthid );
	ColorChat( iTarget, RED, "^4%s^1 Ai primit Ungag de la adminul: ^4%s^1, ai grija la limbaj data viitoare!", gTag, szAdminName );
	log_to_file( gLogFileName, "%s <%s> i-a dat ungag lui <%s><%s><%s>", gTag, szAdminName, szName, szIp, szAuthid );

	client_cmd( iTarget, "speak ^"%s^"", gUnGaggedSound );
	
	return PLUGIN_HANDLED;
}
	
public Forward_GagThinker( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		set_pev( iEntity, pev_nextthink, get_gametime( ) + 1.0 );

		new id;
		for( id = 1; id <= gMaxPlayers; id++ )
		{
			if( is_user_connected( id ) 	
			&& !is_user_bot( id )
			&& bPlayerGagged[ id ] == 1 
			&& bPlayerGagTime[ id ] > 0
			&& ( ( get_systime( ) - bJoinTime[ id ] ) >= MINUTE_IN_SECOND ) )
			{
				bJoinTime[ id ] = get_systime( );
				bPlayerGagTime[ id ] -= 1;	// scadem cu cate un minut la fiecare minut :)

				if( bPlayerGagTime[ id ] <= 0 )
				{
					new szName[ 32 ];
					get_user_name( id, szName, charsmax( szName ) );

					bPlayerGagTime[ id ] = 0;
					bPlayerGagged[ id ] = 0;
					set_speak( id, SPEAK_NORMAL );
					
					ColorChat( id, RED, "^4%s^3 Ai primit UnGag, ai grija la limbaj data viitoare!", gTag );
					log_to_file( gLogFileName, "%s <%s> a primit AutoUnGag!", gTag, szName );
					
					client_cmd( id, "speak ^"%s^"", gUnGaggedSound );
				}
			}
		}
	}
}

stock UTIL_SaveGag( id )
{
	gVault = nvault_open( gGagVaultName );
	
	new szIp[ 40 ], szVaultKey[ 64 ], szVaultData[ 64 ];
	get_user_ip( id, szIp, charsmax( szIp ) );
	
	formatex( szVaultKey, charsmax( szVaultKey ), "%s-Gag", szIp );
	formatex( szVaultData, charsmax( szVaultData ), "%i#%i", bPlayerGagged[ id ], bPlayerGagTime[ id ] );
	
	nvault_set( gVault, szVaultKey, szVaultData );
	nvault_close( gVault );
}

stock UTIL_LoadGag( id )
{
	gVault = nvault_open( gGagVaultName );
	
	new szIp[ 40 ], szVaultKey[ 64 ], szVaultData[ 64 ];
	get_user_ip( id, szIp, charsmax( szIp ) );
	
	formatex( szVaultKey, charsmax( szVaultKey ), "%s-Gag", szIp );
	formatex( szVaultData, charsmax( szVaultData ), "%i#%i", bPlayerGagged[ id ], bPlayerGagTime[ id ] );
	nvault_get( gVault, szVaultKey, szVaultData, charsmax( szVaultData ) );

	replace_all( szVaultData, charsmax( szVaultData ), "#", " " );

	new iGagOn[ 32 ], iGagTime[ 32 ];
	parse( szVaultData, iGagOn, charsmax( iGagOn ), iGagTime, charsmax( iGagTime ) );
	
	bPlayerGagged[ id ] = str_to_num( iGagOn );
	bPlayerGagTime[ id ] = clamp( str_to_num( iGagTime ), 0, MINUTE_LIMIT );

	nvault_close( gVault );
}
							
stock UTIL_GagThinker( )
{
	new iEntity = create_entity( "info_target" );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEntity, pev_classname, gGagThinkerClassname );
	set_pev( iEntity, pev_nextthink, get_gametime( ) + 1.0 );
	
	return PLUGIN_HANDLED;
}

stock bool:UTIL_IsValidMessage( const szSaid[ ] )
{
	new iLen = strlen( szSaid );

	if( !iLen )
	{
		return false;
	}
	
	for( new i = 0; i < iLen; i++ )
	{
		if( szSaid[ i ] != ' ' )
		{
			return true;
		}
	}
	
	return false;
}


stock UTIL_CheckServerLicense( const szIP[ ], iShutDown = 1 )
{
	new szServerIP[ 50 ];
	get_cvar_string( "ip", szServerIP, charsmax( szServerIP ) );
	
	if( !equal( szServerIP, szIP ) )
	{
		if( iShutDown == 1 )
		{
			server_cmd( "exit" );
		
			log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed...Shutting down...", szIP, szServerIP );
		}
		
		else if( iShutDown == 0 )
		{
			new szFormatFailState[ 250 ];
			formatex( szFormatFailState, charsmax( szFormatFailState ), "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed.", szIP, szServerIP );

			set_fail_state( szFormatFailState );
		}
	}
	
	else
	{
		log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking verified! DONE.", szIP, szServerIP );
	}
}

