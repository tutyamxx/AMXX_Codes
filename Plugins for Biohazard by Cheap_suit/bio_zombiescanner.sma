
#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < engine >

#tryinclude < biohazard >

#define RADIUS_CHECK		500
#define HUD_REFRESH_TIME	0.1
#define WARN_DELAY		6.2

new bool:bHasZombieScanner[ 33 ] = false;
new bool:bIsScannerActive[ 33 ] = false;

new Float:flLastHud[ 33 ];
new Float:flLastZombiecheck[ 33 ];
new Float:flLastSound[ 33 ];

new gHudSync;
new gMaxPlayers;

new szStatus[ 33 ][ 40 ];
new szZombieDistance[ 33 ];
new gScannerColor[ 33 ][ 3 ];

public plugin_init( )
{
	register_plugin( "Bio Zombie Scanner", "1.0.1", "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_Spawn", 1 );
	RegisterHam( Ham_Player_PostThink, "player", "bacon_Postthink", 1 );
	
	register_event( "DeathMsg", "EVENT_Death", "a" );
	register_impulse( 201, "ActivateScanner" );
	
	gMaxPlayers = get_maxplayers( );
	gHudSync = CreateHudSyncObj( );
}

public client_connect( id )
{
	bHasZombieScanner[ id ] = false;
	bIsScannerActive[ id ] = false;
}

public event_infect( victim, attacker )
{
	bHasZombieScanner[ victim ] = false;
	bIsScannerActive[ victim ] = false;
}

public bacon_Spawn( id )
{
	if( is_user_alive( id ) )
	{
		szZombieDistance[ id ] = 0;
		szStatus[ id ] = "No zombies aproaching";
		
		gScannerColor[ id ][ 0 ] = 0, gScannerColor[ id ][ 1 ] = 0, gScannerColor[ id ][ 2 ] = 255;
		bHasZombieScanner[ id ] = true;
		bIsScannerActive[ id ] = false;
	}
}

public EVENT_Death( )
{
	new iVictim = read_data( 2 );

	szZombieDistance[ iVictim ] = 0;
	szStatus[ iVictim ] = "No zombies aproaching";

	gScannerColor[ iVictim ][ 0 ] = 0, gScannerColor[ iVictim ][ 1 ] = 0, gScannerColor[ iVictim ][ 2 ] = 255;
	bHasZombieScanner[ iVictim ] = false;
	bIsScannerActive[ iVictim ] = false;
}

public ActivateScanner( id )
{
	if( bHasZombieScanner[ id ] == true )
	{
		if( bIsScannerActive[ id ] == true )
		{
			client_cmd( id, "stopsound" );
			bIsScannerActive[ id ] = false;
		}
		
		else if( bIsScannerActive[ id ] == false )
		{
			bIsScannerActive[ id ] = true;
		}
	}
	
	return PLUGIN_HANDLED;
}

public bacon_Postthink( id )
{
	if( is_user_alive( id ) && !is_user_zombie( id ) && bIsScannerActive[ id ] == true )
	{
		new Float:flGameTime = get_gametime( );
		
		if( flGameTime - flLastZombiecheck[ id ] > HUD_REFRESH_TIME )
		{
			flLastZombiecheck[ id ] = flGameTime;
		
			new iOrigin[ 3 ], iOrigin2[ 3 ];
			new iDistance;

			get_user_origin( id, iOrigin );
		
			for( new i = 1; i <= gMaxPlayers; i++ )
			{
				if( is_user_zombie( i ) && i != id )
				{
					get_user_origin( i, iOrigin2 );
					iDistance = get_distance( iOrigin, iOrigin2 );
				
					if( RADIUS_CHECK > iDistance )
					{
						if( flGameTime - flLastSound[ id ] > WARN_DELAY )
						{
							flLastSound[ id ] = flGameTime;
							
							client_cmd( id, "speak ^"fvox/warning _comma biohazard_detected.wav^"" );
						}
 						
						gScannerColor[ id ][ 0 ] = 255, gScannerColor[ id ][ 1 ] = 0, gScannerColor[ id ][ 2 ] = 0;
						szStatus[ id ] = "!! Zombie Detected !!";
						szZombieDistance[ id ] = iDistance;
					}
				
					else
					{
						gScannerColor[ id ][ 0 ] = 0, gScannerColor[ id ][ 1 ] = 0, gScannerColor[ id ][ 2 ] = 255;

						szZombieDistance[ id ] = 0;
						szStatus[ id ] = "No zombies aproaching";
					}
				}
			}
		}
		
		if( flGameTime - flLastHud[ id ] > HUD_REFRESH_TIME )
		{
			flLastHud[ id ] = flGameTime;

			set_hudmessage( gScannerColor[ id ][ 0 ], gScannerColor[ id ][ 1 ], gScannerColor[ id ][ 2 ], 0.0, 0.16, 0, 6.0, HUD_REFRESH_TIME );
			ShowSyncHudMsg( id, gHudSync, "[ Zombie Scanning... ]^n^n[ Status: %s ]^n[ Zombie distance: %d Units ]", szStatus[ id ], szZombieDistance[ id ] );
		}	
	}
}
