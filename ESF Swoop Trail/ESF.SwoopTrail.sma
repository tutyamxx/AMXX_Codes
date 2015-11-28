
#include < amxmodx >

#include < fakemeta >
#include < hamsandwich >

#pragma semicolon 1

enum
{
        CLASS_NONE = 0,
 
        CLASS_BUU,
      	CLASS_GOKU,
        CLASS_GOHAN,
       	CLASS_KRILLIN,
        CLASS_FRIEZA,
        CLASS_PICCOLO,
        CLASS_TRUNKS,
        CLASS_VEGETA,
        CLASS_CELL
};

new gPlayerSwoopColor[ 32 ][ 3 ];
new bool:bWasSwooping[ 32 ];

new gSwoopSpriteTrail;

const m_iSwooping = 317;
const m_iExtraOff = 5;

public plugin_init( )
{
	register_plugin( ">>>[ ESF Swoop Trail ]<<<", "1.0.0", "tuty / hleV" );

	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawned", 1 );
	register_forward( FM_CmdStart, "forward_CmdStart" );
}

public plugin_precache( )
{
	gSwoopSpriteTrail = precache_model( "sprites/laserbeam.spr" );
}

public bacon_PlayerSpawned( id )
{
	if( is_user_alive( id ) )
	{
		switch( pev( id, pev_playerclass ) )
		{
			case CLASS_BUU:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 255;
				gPlayerSwoopColor[ id ][ 1 ] = 28;
				gPlayerSwoopColor[ id ][ 2 ] = 174;
			}
			
			case CLASS_GOKU:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 255;
				gPlayerSwoopColor[ id ][ 1 ] = 10;
				gPlayerSwoopColor[ id ][ 2 ] = 10;
			}
			
			case CLASS_GOHAN:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 255;
				gPlayerSwoopColor[ id ][ 1 ] = 255;
				gPlayerSwoopColor[ id ][ 2 ] = 255;
			}
			
			case CLASS_KRILLIN:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 255;
				gPlayerSwoopColor[ id ][ 1 ] = 127;
				gPlayerSwoopColor[ id ][ 2 ] = 0;
			}
			
			case CLASS_FRIEZA:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 178;
				gPlayerSwoopColor[ id ][ 1 ] = 58;
				gPlayerSwoopColor[ id ][ 2 ] = 238;
			}
			
			case CLASS_PICCOLO:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 0;
				gPlayerSwoopColor[ id ][ 1 ] = 205;
				gPlayerSwoopColor[ id ][ 2 ] = 0;
			}
			
			case CLASS_TRUNKS:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 255;
				gPlayerSwoopColor[ id ][ 1 ] = 255;
				gPlayerSwoopColor[ id ][ 2 ] = 0;
			}
			
			case CLASS_VEGETA:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 10;
				gPlayerSwoopColor[ id ][ 1 ] = 10;
				gPlayerSwoopColor[ id ][ 2 ] = 255;
			}
			
			case CLASS_CELL:
			{
				gPlayerSwoopColor[ id ][ 0 ] = 35;
				gPlayerSwoopColor[ id ][ 1 ] = 142;
				gPlayerSwoopColor[ id ][ 2 ] = 35;
			}
		}
	}
}

public forward_CmdStart( id )
{
	if( UTIL_IsSwooping( id ) && !bWasSwooping[ id ] )
	{
		bWasSwooping[ id ] = true;
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( TE_BEAMFOLLOW );
		write_short( id );
		write_short( gSwoopSpriteTrail );
		write_byte( 6 );
		write_byte( 4 );
		write_byte( gPlayerSwoopColor[ id ][ 0 ] );
		write_byte( gPlayerSwoopColor[ id ][ 1 ] );
		write_byte( gPlayerSwoopColor[ id ][ 2 ] );
		write_byte( 96 );
		message_end( );
	}
	
	else if( !UTIL_IsSwooping( id ) && bWasSwooping[ id ] )
	{
		bWasSwooping[ id ] = false;
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( TE_KILLBEAM );
		write_short( id );
		message_end( );
	}
}

stock UTIL_IsSwooping( index )
{
	return get_pdata_int( index, m_iSwooping, m_iExtraOff );
}
