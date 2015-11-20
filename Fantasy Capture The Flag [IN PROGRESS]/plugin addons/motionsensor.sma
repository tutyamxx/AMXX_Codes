
#include < amxmodx >

#include < fakemeta >
#include < engine >
#include < colorchat >

#pragma semicolon 1

#define MAX_PLAYERS	32 + 1

#define MAX_MINES	2

new gBeamSprite;
new gHudSync;

new const gTripmineEntity[ ] = "MotionSensor_Mine";

new const gTripmineModel[ ] = "models/v_tripmine.mdl";

new const gBeamSpriteIndex[ ] = "sprites/laserbeam.spr";
new const gMineDeploySound[ ] = "weapons/mine_charge.wav";
new const gMineDetectedSound[ ] = "turret/tu_ping.wav";

new gPlayerTripmine[ MAX_PLAYERS ];

new Float:flLastDetect[ MAX_PLAYERS ];

public plugin_init( )
{
	register_forward( FM_CmdStart, "forward_CmdStart" );
	register_forward( FM_TraceLine , "forward_TraceLine" );

	register_think( gTripmineEntity, "forward_SensorMineThink" );
	
	gHudSync = CreateHudSyncObj( );
}

public client_connect( id )
{
	gPlayerTripmine[ id ] = 0;
}

public plugin_precache( )
{
	gBeamSprite = precache_model( gBeamSpriteIndex );
	precache_model( gTripmineModel );
	
	precache_sound( gMineDeploySound );
	precache_sound( gMineDetectedSound );
}

public forward_SensorMineThink( iEnt )
{
	if( pev_valid( iEnt ) )
	{
		new Float:flGameTime = get_gametime( );

		set_pev( iEnt, pev_nextthink, flGameTime + 0.1 );
		
		new Float:flOrigin[ 3 ], Float:flEnd[ 3 ], Float:flTrace[ 3 ];

		pev( iEnt, pev_origin, flOrigin );
		pev( iEnt, pev_vuser1, flEnd );
		
		UTIL_DrawLaser( flOrigin, flEnd );
		
		new iHit;
		iHit = trace_line( iEnt, flOrigin, flEnd, flTrace );
		
		new id = pev( iEnt, pev_iuser1 );

		if( pev_valid( iHit ) )
		{
			static szClassname[ 32 ];
			pev( iHit, pev_classname, szClassname, charsmax( szClassname ) );
			
			if( equal( szClassname, "player" ) )
			{
				if( is_user_alive( iHit ) && get_user_team( id ) != get_user_team( iHit ) )
				{
					if( flGameTime - flLastDetect[ id ] >= 0.3 )
					{
						flLastDetect[ id ] = flGameTime;
					
						emit_sound( iEnt, CHAN_BODY, gMineDetectedSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
					}
				}
			}
		}
	}
}

public forward_TraceLine( Float:flStart[ 3 ] , Float:fEnd[ 3 ], Conditions , id , iTrace )
{
	static iHit;
	iHit = get_tr2( iTrace , TR_pHit );
    
	if( pev_valid( iHit ) )
    	{
		static szClassname[ 32 ];
		pev( iHit, pev_classname, szClassname, charsmax( szClassname ) );
		
		if( equal( szClassname, gTripmineEntity ) )
		{
			new iOwner = pev( iHit, pev_iuser1 );
			
			new szName[ 32 ];
			get_user_name( iOwner, szName, charsmax( szName ) );
			
			set_hudmessage( 186, 85, 211, -1.0, 0.76, 1, 6.0, 0.1 );
			ShowSyncHudMsg( id, gHudSync, "Owner:^n%s", szName );
		}
	}
}

public forward_CmdStart( id, uc_handle, seed )
{
	if( !is_user_alive( id ) )
	{
		return FMRES_IGNORED;
	}
	
	new iButton = get_uc( uc_handle, UC_Buttons );
	new iOldButton = pev( id, pev_oldbuttons );

	if( ( iButton & IN_USE ) 
	&& !( iOldButton & IN_USE )
	&& ( iButton & IN_ATTACK ) )
	{
		CommandMineActivate( id );
	}
	
	return FMRES_IGNORED;
}

public CommandMineActivate( id )
{
	if( gPlayerTripmine[ id ] >= MAX_MINES )
	{
		ColorChat( id, GREEN, "^1You can only plant^4 %d^1 mines!", MAX_MINES );
		
		return PLUGIN_HANDLED;
	}
	
	new Float:flOrigin[ 3 ];
	new Float:flAngles[ 3 ];
	
	pev( id, pev_origin, flOrigin );
	pev( id, pev_v_angle, flAngles );
	
	new iEnt = create_entity( "info_target" );
	
	if( !pev_valid( iEnt ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEnt, pev_classname, gTripmineEntity );
	engfunc( EngFunc_SetModel, iEnt, gTripmineModel );
	set_pev( iEnt, pev_body, 3 );
	set_pev( iEnt, pev_sequence, 7 );
	engfunc( EngFunc_SetSize, iEnt, Float:{ -8.0, -8.0, -8.0 }, Float:{ 8.0, 8.0, 8.0 } );
	
	new Float:flNewOrigin[ 3 ], Float:flNormal[ 3 ], Float:flTraceDir[ 3 ];
	new Float:flTraceEnd[ 3 ], Float:flTraceResult[ 3 ], Float:flEntAngles[ 3 ];
	
	velocity_by_aim( id, 85, flTraceDir );
	
	flTraceEnd[ 0 ] = flTraceDir[ 0 ] + flOrigin[ 0 ];
	flTraceEnd[ 1 ] = flTraceDir[ 1 ] + flOrigin[ 1 ];
	flTraceEnd[ 2 ] = flTraceDir[ 2 ] + flOrigin[ 2 ];
	
	trace_line( id, flOrigin, flTraceEnd, flTraceResult );
	
	if( trace_normal( id, flOrigin, flTraceEnd, flNormal ) == 0 )
	{
		engfunc( EngFunc_RemoveEntity, iEnt );
		ColorChat( id, GREEN, "^1You must plant the^4 Sensor Mine^1 on a wall!" );
		
		return PLUGIN_HANDLED;
	}
	
	flNewOrigin[ 0 ] = flTraceResult[ 0 ] + ( flNormal[ 0 ] * 8.0 );
	flNewOrigin[ 1 ] = flTraceResult[ 1 ] + ( flNormal[ 1 ] * 8.0 );
	flNewOrigin[ 2 ] = flTraceResult[ 2 ] + ( flNormal[ 2 ] * 8.0 );
	
	set_pev( iEnt, pev_origin, flNewOrigin );
	vector_to_angle( flNormal, flEntAngles );
	set_pev( iEnt, pev_angles, flEntAngles );
	
	new Float:flBeamEnd[ 3 ];
	new Float:flTraceBeamEnd[ 3 ];
	
	flBeamEnd[ 0 ] = flNewOrigin[ 0 ] + ( flNormal[ 0 ] * 8192.0 );
	flBeamEnd[ 1 ] = flNewOrigin[ 1 ] + ( flNormal[ 1 ] * 8192.0 );
	flBeamEnd[ 2 ] = flNewOrigin[ 2 ] + ( flNormal[ 2 ] * 8192.0 );
	
	trace_line( -1, flNewOrigin, flBeamEnd, flTraceBeamEnd );
	set_pev( iEnt, pev_vuser1, flTraceBeamEnd );

	set_pev( iEnt, pev_solid, SOLID_BBOX );
	set_pev( iEnt, pev_movetype, MOVETYPE_FLY );
	set_pev( iEnt, pev_iuser1, id );
	set_pev( iEnt, pev_nextthink, get_gametime( ) + 0.1 );
	
	emit_sound( iEnt, CHAN_STATIC, gMineDeploySound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	set_rendering( iEnt, kRenderFxGlowShell, 186, 85, 211, kRenderNormal, 17 );

	gPlayerTripmine[ id ]++;
	
	return PLUGIN_HANDLED;
}

stock UTIL_DrawLaser( Float:flOrigin[ 3 ], Float:flEnd[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMPOINTS );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 0 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 1 ] );
	engfunc( EngFunc_WriteCoord, flEnd[ 2 ] );
	write_short( gBeamSprite );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 2 );
	write_byte( 5 );
	write_byte( 0 );
	write_byte( 186 );//r
	write_byte( 85 );//g
	write_byte( 211 ); // b
	write_byte( 255 );
	write_byte( 255 );
	message_end( );
}
