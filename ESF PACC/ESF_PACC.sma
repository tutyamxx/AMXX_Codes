
#include < amxmodx >

#include < fakemeta >

#pragma semicolon 1

#define IS_PLAYER(%1)		( 1 <= %1 <= gMaxPlayers )

new gPowerUpColorCvar;
new gPowerUpColor;
new gAuraColor;
new gAuraColorMode;

new gMaxPlayers;
new gMessagePowerUp;

public plugin_init( )
{
	register_plugin( "ESF PowerUp & Aura Color Changer", "4.0.0", "tuty" );
	
	register_forward( FM_EmitSound, "forward_EmitSound" );
	
	gMessagePowerUp = get_user_msgid( "Powerup" );
	register_message( gMessagePowerUp, "Message_Powerup" );
	
	gPowerUpColorCvar = register_cvar( "esf_powerupcolor_mode", "2" );
	gPowerUpColor = register_cvar( "esf_powerupcolor_color", "255 255 255" );
	gAuraColorMode = register_cvar( "esf_auracolor_mode", "0" );
	gAuraColor = register_cvar( "esf_auracolor_color", "1" );
	
	gMaxPlayers = get_maxplayers( );
}

public Message_Powerup( )
{
	new iR, iG, iB;
	
	switch( get_pcvar_num( gPowerUpColorCvar ) )
	{
		case 0: 
		{
			return;
		}
		
		case 1:
		{
			new szColor[ 10 ], iRgb[ 3 ][ 4 ];
			get_pcvar_string( gPowerUpColor, szColor, charsmax( szColor ) );
			
			parse( szColor, iRgb[ 0 ], 3, iRgb[ 1 ], 3, iRgb[ 2 ], 3 );
			
			iR = UTIL_ClampByte( str_to_num( iRgb[ 0 ] ) );
			iG = UTIL_ClampByte( str_to_num( iRgb[ 1 ] ) );
			iB = UTIL_ClampByte( str_to_num( iRgb[ 2 ] ) );
		}
		
		case 2:
		{
			iR = random_num( 0, 0xFF );
			iG = random_num( 0, 0xFF );
			iB = random_num( 0, 0xFF );
		}
	}
	
	set_msg_arg_int( 2, ARG_BYTE, iR ); 
	set_msg_arg_int( 3, ARG_BYTE, iG ); 
	set_msg_arg_int( 4, ARG_BYTE, iB );
}


public forward_EmitSound( id, iChannel, const szSample[ ] )
{
	if( IS_PLAYER( id ) 
	&& ( equal( szSample, "weapons/aura.wav" ) || equal( szSample, "weapons/swoop.wav" ) ) )
	{
		new iEnt = FM_NULLENT;
		
		while( ( iEnt = engfunc( EngFunc_FindEntityByString, iEnt, "model", "models/aura.mdl" ) ) > 0 )
		{
			if( pev( iEnt, pev_owner ) == id )
			{
				new iAuraColor;
				
				switch( get_pcvar_num( gAuraColorMode ) )
				{
					case 0:
					{
						return FMRES_IGNORED;
					}
					
					case 1:
					{
						iAuraColor = random_num( 0, 7 );
					}
					
					case 2:
					{
						iAuraColor = get_pcvar_num( gAuraColor );
					}
				}	
				
				set_pev( iEnt, pev_skin, iAuraColor );
				
				return FMRES_IGNORED;
			}
		}
	}

	return FMRES_IGNORED;
}

stock UTIL_ClampByte( iByte )
{
	if( iByte < 0 )
	{
		return 0;
	}

	if( iByte > 0xFF )
	{
		return 0xFF;
	}
	
	return iByte;
}
