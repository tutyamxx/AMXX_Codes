
#include < amxmodx >
#include < fun >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.1"

#define FFADE_IN	0x0000

new gCvarHealthAdd;
new gCvarHsHealthAdd;
new gCvarMaxHealth;

new gMessageScreenFade;

new const szVampireSound[ ] = "bullchicken/bc_bite1.wav";

public plugin_init( )
{
	register_plugin( "Vampire", PLUGIN_VERSION, "tuty" );
	
	register_event( "DeathMsg", "EVENT_DeathMsg", "a", "1>0" );
	
	gCvarHealthAdd = register_cvar( "vampire_hp", "15" );
	gCvarHsHealthAdd = register_cvar( "vampire_hp_hs", "40" );
	gCvarMaxHealth = register_cvar( "vampire_max_hp", "500" );

	gMessageScreenFade = get_user_msgid( "ScreenFade" );
}

public plugin_precache( )
{
	precache_sound( szVampireSound );
}

public EVENT_DeathMsg( )
{
	new iKiller = read_data( 1 );
	new iVictim = read_data( 2 );

	new iHeadShot = read_data( 3 );
	
	new iClientHp, iClientHpAdd;
	new iClientMaxHp = get_pcvar_num( gCvarMaxHealth );

	if( iKiller && iKiller == iVictim )
	{
		return;
	}
	
	iClientHpAdd = ( iHeadShot == 1 ) ? get_pcvar_num( gCvarHsHealthAdd ) : get_pcvar_num( gCvarHealthAdd );

	iClientHp = get_user_health( iKiller );
	iClientHp += iClientHpAdd;
	
	if( iClientHp > iClientMaxHp )
	{
		iClientHp = iClientMaxHp;
	}
	
	set_user_health( iKiller, iClientHp );
	
	set_hudmessage( 0, 255, 0, -1.0, 0.15, 0, 1.0, 1.0, 0.1, 0.1, -1 );
	show_hudmessage( iKiller, "Healed +%d hp", iClientHpAdd );
	
	switch( get_user_team( iKiller ) )
	{
		case 1:	UTIL_Fade( iKiller, 255, 10, 10 );
		case 2:	UTIL_Fade( iKiller, 10, 10, 255 );
	}
	
	emit_sound( iKiller, CHAN_BODY, szVampireSound, VOL_NORM, ATTN_NORM, 0 , PITCH_NORM );

	return;
}

UTIL_Fade( id, iRed, iGreen, iBlue )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade, _, id );
	
write_short( 1 << 10 )
;
	
write_short( 1 << 10 )
;
	write_short( FFADE_IN )
;
	write_byte( iRed )
;
	write_byte( iGreen );
	write_byte( iBlue )
;
	write_byte( 75 )
;
	message_end( );
}
