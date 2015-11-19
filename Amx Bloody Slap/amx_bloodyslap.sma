
#include < amxmodx >
#include < amxmisc >

#define LOG_COMMAND
#define FFADE_IN 	0x0000

new const gPainSounds[ ][ ] = 
{
	"scientist/sci_fear12.wav",
	"scientist/sci_fear8.wav", 
	"scientist/sci_fear15.wav", 
	"scientist/sci_pain1.wav", 
	"scientist/scream01.wav", 
	"scientist/scream07.wav", 
	"scientist/scream20.wav"
};

new gBlood_drop;
new gBlood_spray;
new gMessageFade;

new gEnableScreenfade;

public plugin_init( )
{
	register_plugin( "Bloody Slap", "1.0.3", "tuty" );
	register_concmd( "amx_bloodyslap", "CommandSlapUserBloody", ADMIN_SLAY, "<name> <power> - bloodyslap target" );
	
	gEnableScreenfade = register_cvar( "bloodyslap_fade", "1" );
	
	gMessageFade = get_user_msgid( "ScreenFade" );
	register_dictionary( "amx_bloodyslap.txt" );
}

public plugin_precache( )
{
	new i;
	
	for( i = 0; i < sizeof gPainSounds; i++ )
	{
		precache_sound( gPainSounds[ i ] );
	}	
	
	gBlood_drop = precache_model( "sprites/blood.spr" );
	gBlood_spray = precache_model( "sprites/bloodspray.spr" );
}

public CommandSlapUserBloody( id, level, cid )
{
	if( !cmd_access( id, level, cid, 3 ) )
	{
		return PLUGIN_HANDLED; 
	}
	
	new szArgument[ 32 ];
	read_argv( 1, szArgument, charsmax( szArgument ) );
	
	new iTarget = cmd_target( id, szArgument, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ONLY_ALIVE | CMDTARGET_NO_BOTS );
	
	if( !iTarget )
	{
		return PLUGIN_HANDLED;
	}

	new Adminname[ 32 ], Targetname[ 32 ], SlapPower[ 5 ];
	
	get_user_name( id, Adminname, charsmax( Adminname ) );
	get_user_name( iTarget, Targetname, charsmax( Targetname ) );
	
	read_argv( 2, SlapPower, charsmax( SlapPower ) );
	
	new Damage = str_to_num( SlapPower );

	if( Damage <= 0 )
	{
		console_print( id, "%L", id, "BLOODY_MORE_DMG" );
		user_slap( iTarget, 0 );
		
		return PLUGIN_HANDLED;
	}

	#if defined LOG_COMMAND
		log_amx( "%L", LANG_SERVER, "BLOODY_LOG_FILE", Adminname, Targetname, Damage );
	#endif

	user_slap( iTarget, Damage );
	client_print( 0, print_chat, "%L", 0, "BLOODY_PRINT_CHAT", Adminname, Targetname, Damage );
	emit_sound( iTarget, CHAN_VOICE, gPainSounds[ random_num( 0, charsmax( gPainSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	if( get_pcvar_num( gEnableScreenfade ) != 0 )
	{
		UTIL_Fade( iTarget );
	}

	new iOrigin[ 3 ];
	get_user_origin( iTarget, iOrigin );
	
	UTIL_BloodFX( iOrigin );

	return PLUGIN_HANDLED;
}

stock UTIL_BloodFX( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BLOODSPRITE );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 20 );
	write_short( gBlood_spray );
	write_short( gBlood_drop );
	write_byte( 248 );
	write_byte( 30 );
	message_end( );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BLOODSTREAM );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 30 );
	write_coord( random_num( -20, 20 ) );
	write_coord( random_num( -20, 20 ) );
	write_coord( random_num( 50, 300 ) );
	write_byte( 70 );
	write_byte( random_num( 100, 200 ) );
	message_end( );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_PARTICLEBURST );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( 50 );
	write_byte( 70 );
	write_byte( 3 );
	message_end( );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BLOODSTREAM );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 10 );
	write_coord( random_num( -360, 360 ) );
	write_coord( random_num( -360, 360 ) );
	write_coord( -10 );
	write_byte( 70 );
	write_byte( random_num( 50, 100 ) );
	message_end( );
}

stock UTIL_Fade( target )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageFade , {0,0,0}, target );
	write_short( 1<<10 );
	write_short( 1<<10 );
	write_short( FFADE_IN );
	write_byte( 255 );
	write_byte( 0 );  
	write_byte( 0 );  
	write_byte( 99 );
	message_end( ); 	
}
