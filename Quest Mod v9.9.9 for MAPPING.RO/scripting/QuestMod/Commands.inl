
/*
	
	====================================================
	Comenzile care fac efectele in acest mod!
	====================================================

*/


QuestMod_RegisterCommands( )
{
	register_clcmd( "+scorpion", "commandScorpion" );
	register_clcmd( "-scorpion", "commandOffScorp" );

	register_clcmd( "+thunder", "commandThunderOn" );
 	register_clcmd( "-thunder", "commandThunderOff" );

	register_clcmd( "flash", "commandFlashEnemy" );
	register_clcmd( "teleport", "commandTeleport" );
	register_clcmd( "roots", "commandRootsPlayer" );
	register_clcmd( "sciencetest", "commandCrystal" );
	register_clcmd( "acidspit", "commandAcidSpit" );
	register_clcmd( "ice", "commandsubzero" );
	register_clcmd( "fire", "commandBurnEnemy" );
	register_clcmd( "fireball", "commandFireBall" );
}

public GetSomeSpeed( id )
{
	set_user_maxspeed( id, get_pcvar_float( gCvarLowSpeed ) );
}

public GetNoFootSteps( id )
{
	give_item( id, "weapon_smokegrenade" );
	set_user_footsteps( id, 1 );
}

public GetSpeedAha( id )
{
	set_user_maxspeed( id, get_pcvar_float( gCvarHighSpeed ) );
}

public GetGravity( id )
{
	set_user_gravity( id , get_pcvar_float( gCvarLowGrav ) );
}

public GetInvisible( id )
{
	new iOrigin[ 3 ];
	get_user_origin( id, iOrigin, 0 );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_TELEPORT );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	message_end( );

	set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, get_pcvar_num( gCvarVisibility ) );
}
	
public task_healing( taskid )
{
	new id = taskid - TASKID_HEALING;

	new iHealthAdd = get_pcvar_num( gCvarHealthAdd );
	new iMaxHealth = get_pcvar_num( gCvarHealthMax );
	new iHealth = get_user_health( id );
	
	if( is_user_alive( id ) && ( iHealth < iMaxHealth ) )
	{
		new iOrigin1[ 3 ];
		get_user_origin( id, iOrigin1 );

      		set_user_health( id, iHealth + iHealthAdd );

      		set_hudmessage( 0, 255, 0, -1.0, 0.25, 2, 1.0, 2.0, 0.1, 0.1, 4 );
      		ShowSyncHudMsg( id, gHudSync2, "Viata ti se incarca pana la %d !", iMaxHealth );
		
		message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade, { 0, 0, 0 }, id );
       	 	write_short( 1<<10 );
        	write_short( 1<<10 );
        	write_short( FFADE_IN );
        	write_byte( 0 );
        	write_byte( 255 );  
       	 	write_byte( 0 );  
        	write_byte( 100 );
       		message_end( ); 	

		UTIL_DrawParticles( iOrigin1 );
	}
	
	else
	{
      		if( is_user_alive( id ) && ( iHealth >= iMaxHealth ) )
		{
         		remove_task( id + TASKID_HEALING );
		}
	}
}

public commandScorpion( id )
{
	if( !is_user_alive( id ) || gKnifeModel[ id ] != 11 || get_user_weapon( id ) != CSW_KNIFE )
	{
		return PLUGIN_HANDLED;
	}
	
	if( bIsHigh[ id ] == true )
	{
		client_print( id, print_center, "Nu poti folosi comanda deoarece esti blocat %d secunde!", get_pcvar_num( gCvarStopTime ) );
		return PLUGIN_HANDLED;
	}

	new iTarget, iBody;
	get_user_aiming( id, iTarget, iBody );
	
	if( pev_valid( iTarget ) && is_user_alive( iTarget ) )
	{
		if( get_user_team( id ) == get_user_team( iTarget ) )
		{
			return PLUGIN_HANDLED;
		}
		
		set_user_rendering( iTarget, kRenderFxGlowShell, 255, 165, 0, kRenderTransAlpha, 25 );
		bGrabTarget[ id ] = iTarget;
		
		UTIL_ShowBeam( id, iTarget, gSpriteIndex4, 10, 255, 165, 0, 100 );
		set_task( 0.1, "GrabThink", id + TASKID_SCORPION, _, _, "b" );
		
		ExecuteHam( Ham_TakeDamage, iTarget, 0, id, float( get_pcvar_num( gCvarScorpionDmg ) ), DMG_SHOCK );
		emit_sound( id, CHAN_VOICE, gScorpionSounds[ random_num( 0, charsmax( gScorpionSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
	
	return PLUGIN_HANDLED;
}

public GrabThink( taskid )
{
	new id = taskid - TASKID_SCORPION;
	
	new iOrigin[ 3 ];
	get_user_origin( id, iOrigin );
	
	new Float:flOrigin[ 3 ], iOrigin2[ 3 ];
	pev( bGrabTarget[ id ], pev_origin, flOrigin );
	
	iOrigin2[ 0 ] = floatround( flOrigin[ 0 ] );
	iOrigin2[ 1 ] = floatround( flOrigin[ 1 ] );
	iOrigin2[ 2 ] = floatround( flOrigin[ 2 ] );
	
	new Float:flOrigin1[ 3 ];

	flOrigin1[ 0 ] = float( iOrigin[ 0 ] );
	flOrigin1[ 1 ] = float( iOrigin[ 1 ] );
	flOrigin1[ 2 ] = float( iOrigin[ 2 ] );
	
	new Float:flDistance[ 3 ];

	flDistance[ 0 ] = flOrigin1[ 0 ];
	flDistance[ 1 ] = flOrigin1[ 1 ];
	flDistance[ 2 ] = flOrigin1[ 2 ];

	new Float:TotalDis = floatsqroot( flDistance[ 0 ] * flDistance[ 0 ] + flDistance[ 1 ] * flDistance[ 1 ] + flDistance[ 2 ] * flDistance[ 2 ] );
	new Float:flQue = 0.0 / TotalDis;

	new Float:flOrigin4[ 3 ];

	flOrigin4[ 0 ] = floatadd( floatmul( flDistance[ 0 ], flQue ), flOrigin1[ 0 ] );
	flOrigin4[ 1 ] = floatadd( floatmul( flDistance[ 1 ], flQue ), flOrigin1[ 1 ] );
	flOrigin4[ 2 ] = floatadd( floatmul( flDistance[ 2 ], flQue ), flOrigin1[ 2 ] );

	new Float:flVelocity[ 3 ];

	flVelocity[ 0 ] = floatmul( floatsub( flOrigin4[ 0 ], flOrigin[ 0 ] ), floatdiv( 5.0, 1.666667 ) );
	flVelocity[ 1 ] = floatmul( floatsub( flOrigin4[ 1 ], flOrigin[ 1 ] ), floatdiv( 5.0, 1.666667 ) );
	flVelocity[ 2 ] = floatmul( floatsub( flOrigin4[ 2 ], flOrigin[ 2 ] ), floatdiv( 5.0, 1.666667 ) );
	
	set_pev( bGrabTarget[ id ], pev_velocity, flVelocity );

	return PLUGIN_CONTINUE;
}

public commandOffScorp( id )
{
	new iTarget = bGrabTarget[ id ];

	if( iTarget == INVALID_PLAYER )
	{
		bGrabTarget[ id ] = 0;
	}
	
	else if( iTarget )
	{
		set_user_rendering( bGrabTarget[ id ] );
		bGrabTarget[ id ] = 0;
	}
	
	if( task_exists( id + TASKID_SCORPION ) )
	{
		remove_task( id + TASKID_SCORPION );
	}
	
	return PLUGIN_HANDLED;
}

public commandFireBall( id )
{
	if( !is_user_alive( id ) || get_user_weapon( id ) != CSW_KNIFE || gKnifeModel[ id ] != 18 )
	{
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarLiuKangBallInterval );

	if( flGameTime - bflLastUsed9[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a trage iar cu bile de foc!", floatround( bflLastUsed9[ id ] + iTimeDelay - flGameTime ) );
        	return PLUGIN_HANDLED;
	}

	new Float:flOrigin[ 3 ], Float:flAngles[ 3 ];
		
	pev( id, pev_origin, flOrigin );
	pev( id, pev_v_angle, flAngles );
	
	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEntity, pev_classname, "LiuKangFireBall" );

	engfunc( EngFunc_SetModel, iEntity, FIREBALL_MODEL );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -6.0, -6.0, -6.0 }, Float:{ 6.0, 6.0, 6.0 } );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );
	
	set_pev( iEntity, pev_angles, flAngles );
	set_pev( iEntity, pev_solid, SOLID_BBOX );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_effects, EF_LIGHT );
	set_pev( iEntity, pev_owner, id );
	
	set_rendering( iEntity, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 255 );
	UTIL_BeamFollow( iEntity, gSpriteIndex4, 255, 165, 0 );

	new Float:flVelocity[ 3 ];
	velocity_by_aim( id, get_pcvar_num( gCvarLiukangBallSpeed ), flVelocity );
	
	set_pev( iEntity, pev_velocity, flVelocity );
	emit_sound( iEntity, CHAN_STATIC, FIREBALL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

	bflLastUsed9[ id ] = flGameTime;

	return PLUGIN_HANDLED;
}

public commandBurnEnemy( id )
{
	if( !is_user_alive( id ) || get_user_weapon( id ) != CSW_KNIFE || gKnifeModel[ id ] != 17 )
	{
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarFiremanInterval );

	if( flGameTime - bflLastUsed8[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a folosi Focul!", floatround( bflLastUsed8[ id ] + iTimeDelay - flGameTime ) );
        	return PLUGIN_HANDLED;
	}

	new iTarget, iBody;
	get_user_aiming( id, iTarget, iBody );
	
	if( pev_valid( iTarget ) && is_user_alive( iTarget ) )
	{
		if( get_user_team( id ) == get_user_team( iTarget ) )
		{
			return PLUGIN_HANDLED;
		}
		
		if( task_exists( iTarget + TASKID_FIREMAN ) )
		{
			remove_task( iTarget + TASKID_FIREMAN );
		}

		new iFireDuration = get_pcvar_num( gCvarFiremanFireDuration );

		new iParam[ 2 ];
		
		iParam[ 0 ] = id;
		iParam[ 1 ] = iTarget;

		set_task( 1.0, "BurnEffectAndDmg", iTarget + TASKID_FIREMAN, iParam, 2, "a", iFireDuration );
		
		client_print( id, print_center, "Inamicul va arde %d secunde!", iFireDuration );
		bflLastUsed8[ id ] = flGameTime;
	}
	
	return PLUGIN_HANDLED;
}

public BurnEffectAndDmg( iParam[ ] )
{
	new id = iParam[ 0 ];
	new iTarget = iParam[ 1 ];

	new iOrigin[ 3 ];
	get_user_origin( iTarget, iOrigin, 0 );
	
	UTIL_Sprite( iOrigin, random_num( -17, 17 ), random_num( -13, 13 ), random_num( 0, 20 ), gFireSprite, random_num( 6, 15 ), 200 );
	ExecuteHam( Ham_TakeDamage, iTarget, 0, id, float( get_pcvar_num( gCvarFiremanDamage ) ), DMG_BURN );
	
	if( random( 5 ) == 3 )
	{
		emit_sound( iTarget, CHAN_VOICE, gFirePainSounds[ random_num( 0, charsmax( gFirePainSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}

public commandRootsPlayer( id )
{
	if( !is_user_alive( id ) || gKnifeModel[ id ] != 9 || get_user_weapon( id ) != CSW_KNIFE )
	{
		return PLUGIN_HANDLED;
	}

	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarWeedInterval );

	if( flGameTime - bflLastUsed2[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a folosi Iarba!", floatround( bflLastUsed2[ id ] + iTimeDelay - flGameTime ) );
        	return PLUGIN_HANDLED;
	}

	new iTarget, iBody;
	get_user_aiming( id, iTarget, iBody );
	
	if( pev_valid( iTarget ) && is_user_alive( iTarget ) )
	{
		if( get_user_team( id ) == get_user_team( iTarget ) )
		{
			return PLUGIN_HANDLED;
		}
			
		new iTargetOrigin[ 3 ], Float:flOrigin[ 3 ];

		get_user_origin( iTarget, iTargetOrigin, 0 );
		IVecFVec( iTargetOrigin, flOrigin );
			
		new iEnt = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
			
		engfunc( EngFunc_SetOrigin, iEnt, flOrigin );
		
		if( !pev_valid( iEnt ) )
        	{
			return PLUGIN_HANDLED;
        	}
			
		set_pev( iEnt, pev_classname, "tuty_Roots" );
		engfunc( EngFunc_SetModel, iEnt, ROOTS_MODEL );
		dllfunc( DLLFunc_Spawn, iEnt );
		set_pev( iEnt, pev_solid, SOLID_NOT );
		set_pev( iEnt, pev_movetype, MOVETYPE_NONE );
		engfunc( EngFunc_DropToFloor, iEnt );
			
		emit_sound( id, CHAN_AUTO, gRootsSounds[ random_num( 0, charsmax( gRootsSounds ) ) ], VOL_NORM, ATTN_NORM ,0 , PITCH_NORM );
			
		set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) | FL_FROZEN );
		bIsHigh[ iTarget ] = true;
		
		bflLastUsed2[ id ] = flGameTime;
		set_task( float( get_pcvar_num( gCvarStopTime ) ), "removeRoots", iTarget + TASKID_ROOTS );
	}
	
	return PLUGIN_HANDLED;
}

public commandThunderOn( id )
{
	if( !is_user_alive( id ) || gKnifeModel[ id ] != 7 || get_user_weapon( id ) != CSW_KNIFE )
	{
		return PLUGIN_HANDLED;
	}

	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarThunderInterval );

	if( flGameTime - bflLastUsed6[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a folosi Tunetul!", floatround( bflLastUsed6[ id ] + iTimeDelay - flGameTime ) );
        	return PLUGIN_HANDLED;
	}

	if( bIsHigh[ id ] == true )
	{
		client_print( id, print_center, "Nu poti folosi comanda deoarece esti blocat %d secunde!", get_pcvar_num( gCvarStopTime ) );
		return PLUGIN_HANDLED;
	}

	new iTarget, iBody;
	get_user_aiming( id, iTarget, iBody );
	
	if( pev_valid( iTarget ) && is_user_alive( iTarget ) )
	{
		if( get_user_team( id ) == get_user_team( iTarget ) )
		{
			return PLUGIN_HANDLED;
		}
		
		new iOrigin[ 3 ];
		get_user_origin( iTarget, iOrigin, 0 );
		
		UTIL_ShowBeam( id, iTarget, gSpriteIndex, 50, 255, 255, 255, 255 );
		UTIL_Sprite( iOrigin, 0, 0, 0, gWave, 13, 100 );
		
		emit_sound( id, CHAN_AUTO, gLightSounds[ random_num( 0, charsmax( gLightSounds ) ) ], VOL_NORM, ATTN_NORM , 0, PITCH_NORM );
		ExecuteHam( Ham_TakeDamage, iTarget, 0, id, float( get_pcvar_num( gCvarThunderDmg ) ), DMG_ENERGYBEAM );
		
		bflLastUsed6[ id ] = flGameTime;
	}

	return PLUGIN_HANDLED;
}

public commandFlashEnemy( id )
{
	if( !is_user_alive( id ) || gKnifeModel[ id ] != 8 || get_user_weapon( id ) != CSW_KNIFE )
	{
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarFlashInterval );

	if( flGameTime - bflLastUsed3[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a folosi Blindul!", floatround( bflLastUsed3[ id ] + iTimeDelay - flGameTime ) );
        	return PLUGIN_HANDLED;
	}

	switch( get_user_team( id ) )
	{
		case 1:
		{
			 UTIL_FlashTeam( "CT" );
				
		}
				
		case 2:
		{
			 UTIL_FlashTeam( "TERRORIST" );
		}
	}
	
	bflLastUsed3[ id ] = flGameTime;

	return PLUGIN_HANDLED;
}

public commandTeleport( id )
{
	if( !is_user_alive( id ) || gKnifeModel[ id ] != 6 || get_user_weapon( id ) != CSW_KNIFE )
      	{
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarTeleportInterval );

	if( flGameTime - bflLastUsed[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a folosi Teleportul!", floatround( bflLastUsed[ id ] + iTimeDelay - flGameTime ) );
                return PLUGIN_HANDLED;
	}

	if( bIsHigh[ id ] == true )
	{
		client_print( id, print_center, "Nu poti folosi comanda deoarece esti blocat %d secunde!", get_pcvar_num( gCvarStopTime ) );
		return PLUGIN_HANDLED;
	}

	new iOldOrigin[ 3 ], iNewOrigin[ 3 ];
	
	get_user_origin( id, iOldOrigin, 0 );
	get_user_origin( id, iNewOrigin, 3 );
	
	iOldOrigin[ 2 ] += 15;

	iNewOrigin[ 0 ] += ( ( iNewOrigin[ 0 ] - iOldOrigin[ 0 ] > 0 ) ? -50 : 50 );
	iNewOrigin[ 1 ] += ( ( iNewOrigin[ 1 ] - iOldOrigin[ 2 ] > 0 ) ? -50 : 50 );
	iNewOrigin[ 2 ] += 40;
	
	UTIL_ShowCylinder( iOldOrigin );
	set_user_origin( id, iNewOrigin );
	
	new iParameter[ 5 ];

	iParameter[ 0 ] = id;
	iParameter[ 1 ] = iOldOrigin[ 0 ];
	iParameter[ 2 ] = iOldOrigin[ 1 ];
	iParameter[ 3 ] = iOldOrigin[ 2 ];
	iParameter[ 4 ] = iNewOrigin[ 2 ];

	set_task( 0.1, "CheckIfStuck", id + TASKID_TELEPORT, iParameter, 5 );

   	return PLUGIN_HANDLED;
}

public CheckIfStuck( iParameter[ ] )
{
	new id = iParameter[ 0 ];

	if( !is_user_connected( id ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new iOrigin[ 3 ], iOldLocation[ 3 ];
	get_user_origin( id, iOrigin, 0 );
	
	iOldLocation[ 0 ] = iParameter[ 1 ];
	iOldLocation[ 1 ] = iParameter[ 2 ];
	iOldLocation[ 2 ] = iParameter[ 3 ];
	
	new Float:flGameTime = get_gametime( );
	
	if( iParameter[ 4 ] == iOrigin[ 2 ] )
	{
		if( ++bTeleportFailedCount[ id ] >= MAX_FAIL_TELEPORTS )
		{
			bTeleportFailedCount[ id ] = 0;
			
			bflLastUsed[ id ] = flGameTime;
		}

		client_print( id, print_center, "Locatie invalida! Mai incearca odata!" );
		set_user_origin( id, iOldLocation );
		emit_sound( id, CHAN_VOICE, TELEPORT_FAILED, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
	
	else
	{
		new Float:flPunchAngles[ 3 ];
		
		flPunchAngles[ 0 ] -= -45.6;
		
		set_pev( id, pev_fixangle, 1 );
		set_pev( id, pev_punchangle, flPunchAngles );

		client_print( id, print_center, "Teleportat!" );
		
		message_begin( MSG_ONE_UNRELIABLE, gMessageScreenShake, _, id );
		write_short( 6<<12 ); 
		write_short( 6<<12 );
		write_short( 3<<12 );
		message_end( );

		UTIL_FlaresBlow( iOrigin );
		emit_sound( id, CHAN_AUTO, gTeleportSounds[ random_num( 0, charsmax( gTeleportSounds ) ) ], VOL_NORM, ATTN_NORM ,0 , PITCH_NORM );
		
		bflLastUsed[ id ] = flGameTime;
	}
	
	return PLUGIN_HANDLED;
}

public commandAcidSpit( id )
{
	if( !is_user_alive( id ) || get_user_weapon( id ) != CSW_KNIFE || gKnifeModel[ id ] != 15 )
	{
		return PLUGIN_HANDLED;
	}		
	
	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarReptileSpitInterval );

	if( flGameTime - bflLastUsed5[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a putea scuipa cu acid!", floatround( bflLastUsed5[ id ] + iTimeDelay - flGameTime ) );
                return PLUGIN_HANDLED;
	}

	new Float:flOrigin[ 3 ], Float:flVelocity[ 3 ], Float:flForward[ 3 ];
							
	pev( id, pev_origin, flOrigin );
	pev( id, pev_velocity, flVelocity );
	pev( id, pev_v_angle, flForward );
	
	new iDistance = get_pcvar_num( gCvarReptileSpitDistance );

	new iEnt = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );

	if( !pev_valid( iEnt ) )
	{
		return PLUGIN_HANDLED;
	}
	
	engfunc( EngFunc_SetModel, iEnt, MODEL_SPIT );
	engfunc( EngFunc_SetSize, iEnt, Float:{ -1.0, -1.0, -1.0 }, Float:{ 1.0, 1.0, 1.0 } );
	
	UTIL_GetStartPosition( id, 37.0, 0.0, 13.0, flOrigin )
	engfunc( EngFunc_SetOrigin, iEnt, flOrigin );
	
	set_pev( iEnt, pev_classname, "ReptileAcidSpit" );	
	set_pev( iEnt, pev_movetype, MOVETYPE_TOSS );
	set_pev( iEnt, pev_solid, SOLID_BBOX );
	set_pev( iEnt, pev_renderfx, kRenderFxGlowShell );
	set_pev( iEnt, pev_rendercolor, gSpitColor );
	set_pev( iEnt, pev_rendermode, kRenderTransAlpha );
	set_pev( iEnt, pev_renderamt, 255.0 );
	set_pev( iEnt, pev_scale, 0.5 );
	set_pev( iEnt, pev_iuser3, ACIDSPIT_ENTID );
	set_pev( iEnt, pev_owner, id );
					
	engfunc( EngFunc_MakeVectors, flForward );
	global_get( glb_v_forward, flForward );
					
	flForward[ 0 ] = floatadd( floatmul( flForward[ 0 ], float( iDistance ) ), flVelocity[ 0 ] );
	flForward[ 1 ] = floatadd( floatmul( flForward[ 1 ], float( iDistance ) ), flVelocity[ 1 ] );
	flForward[ 2 ] = floatadd( floatmul( flForward[ 2 ], float( iDistance ) ), flVelocity[ 2 ] );
				
	set_pev( iEnt, pev_velocity, flForward );
	
	new iForward[ 3 ], iOrigin[ 3 ];
		
	FVecIVec( flForward, iForward );
	FVecIVec( flOrigin, iOrigin );

	UTIL_BloodStream( iOrigin, iForward, floatround( vector_length( flForward ) ) );
	emit_sound( id, CHAN_VOICE, gSpitSounds[ random_num( 0, charsmax( gSpitSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	bflLastUsed5[ id ] = flGameTime;

	return PLUGIN_HANDLED;
}

public commandCrystal( id )
{
	if( !is_user_alive( id ) || get_user_weapon( id ) != CSW_KNIFE || gKnifeModel[ id ] != 14 )
	{
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarScientistTestDelay );

	if( flGameTime - bflLastUsed4[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a folosi iarasi abilitatea Scientist!", floatround( bflLastUsed4[ id ] + iTimeDelay - flGameTime ) );
                return PLUGIN_HANDLED;
	}

	new iTarget, iBody;
	get_user_aiming( id, iTarget, iBody );

	if( pev_valid( iTarget ) && is_user_alive( iTarget ) )
	{
		if( get_user_team( id ) == get_user_team( iTarget ) )
		{
			return PLUGIN_HANDLED;
		}
		
		UTIL_CreateCrystal( iTarget, 50.0, 50.0 );
		UTIL_CreateCrystal( iTarget, 50.0, -50.0 );
		UTIL_CreateCrystal( iTarget, -50.0, 50.0 );
		UTIL_CreateCrystal( iTarget, -50.0, -50.0 );
		
		new iParameter[ 2 ];
		
		iParameter[ 0 ] = id;
		iParameter[ 1 ] = iTarget;
		
		emit_sound( iTarget, CHAN_VOICE, CRYSTAL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		set_task( float( get_pcvar_num( gCvarScientistTestDuration ) ), "CreateBlastAndDie", iTarget + TASKID_CRYSTAL, iParameter, 2 );
		set_task( 0.1, "ScienceFailEffect", iTarget + TASKID_SCIENCE, _, _, "a", get_pcvar_num( gCvarScientistTestDuration ) * 8 );
		
		set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) | FL_FROZEN );
		
		bflLastUsed4[ id ] = flGameTime;
	}
	
	return PLUGIN_HANDLED;
}

public CreateBlastAndDie( iParameter[ ] )
{
	new id = iParameter[ 0 ];
	new iTarget = iParameter[ 1 ];
	
	new iOrigin[ 3 ], iPosition[ 3 ];
	get_user_origin( iTarget, iOrigin, 0 );
	
	iPosition[ 0 ] = iOrigin[ 0 ] + 150;
	iPosition[ 1 ] = iOrigin[ 1 ] + 150;
	iPosition[ 2 ] = iOrigin[ 2 ] + 800;
	
	new Float:flAngles[ 3 ];
	
	flAngles[ 0 ] = -88.9;
	flAngles[ 1 ] = 90.0;
	flAngles[ 2 ] = 0.0;
	
	set_pev( iTarget, pev_fixangle, 1 );
	set_pev( iTarget, pev_punchangle, flAngles );

	UTIL_CreateThunder( iPosition, iOrigin );
	UTIL_Sprite( iOrigin, random_num( -10, 10 ), random_num( -10, 10 ), random_num( 40, 60 ), gAgruntSprite, 8, 120 );
	UTIL_CreateAgrunt( iTarget );
	
	ExecuteHam( Ham_TakeDamage, iTarget, 0, id, float( get_pcvar_num( gCvarScientistTestDamage ) ), DMG_CRUSH );
	emit_sound( iTarget, CHAN_VOICE, DIE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) & ~FL_FROZEN );
}

public ScienceFailEffect( taskid )
{
	new iTarget = taskid - TASKID_SCIENCE;

	UTIL_BeamTorus( iTarget );
}

public commandsubzero( id )
{
	if( !is_user_alive( id ) || get_user_weapon( id ) != CSW_KNIFE || gKnifeModel[ id ] != 16 )
	{
		return PLUGIN_HANDLED;
	}
	
	new Float:flGameTime = get_gametime( );
	new iTimeDelay = get_pcvar_num( gCvarSubzeroInterval );

	if( flGameTime - bflLastUsed7[ id ] < iTimeDelay )
	{
		client_print( id, print_center, "Asteapta %d secunde pentru a folosi iarasi Inghetul!", floatround( bflLastUsed7[ id ] + iTimeDelay - flGameTime ) );
                return PLUGIN_HANDLED;
	}

	new iTarget, iBody;
	get_user_aiming( id, iTarget, iBody );
		
	if( pev_valid( iTarget ) && is_user_alive( iTarget ) )
	{
		if( get_user_team( id ) == get_user_team( iTarget ) )
		{
			return PLUGIN_HANDLED;
		}
		
		new iOrigin[ 3 ];
		get_user_origin( iTarget, iOrigin, 0 );

		UTIL_Implosion( iOrigin, -43 );
		UTIL_Implosion( iOrigin, 9 );
		UTIL_Frostnova( iTarget );

		set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) | FL_FROZEN );
		set_user_rendering( iTarget, kRenderFxGlowShell, 0, 255, 255, kRenderTransAlpha, 25 );
		
		emit_sound( iTarget, CHAN_AUTO, ICE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

		new iParam[ 2 ];
			
		iParam[ 0 ] = id;
		iParam[ 1 ] = iTarget;

		set_task( float( get_pcvar_num( gCvarSubzeroIceTime ) ), "StopIceFreeze", iTarget + TASKID_SUBZERO, iParam, 2 );
		
		bflLastUsed7[ id ] = flGameTime;
	}
	
	return PLUGIN_HANDLED;
}

public StopIceFreeze( iParam[ ] )
{
	new id = iParam[ 0 ];
	new iTarget = iParam[ 1 ];

	if( task_exists( iTarget + TASKID_SUBZERO ) )
	{
		remove_task( iTarget + TASKID_SUBZERO );
	}

	new iOrigin[ 3 ];
	get_user_origin( iTarget, iOrigin );
	
	UTIL_Sprite( iOrigin, 50, 0, 0, gIceSmoke, 20, 100 );
	UTIL_Sprite( iOrigin, 0, 50, 0, gIceSmoke, 20, 100 );
	UTIL_Sprite( iOrigin, -50, 0, 0, gIceSmoke, 20, 100 );
	UTIL_Sprite( iOrigin, 0, -50, 0, gIceSmoke, 20, 100 );
	UTIL_Sprite( iOrigin, 35, 35, 0, gIceSmoke, 20, 100 );
	UTIL_Sprite( iOrigin, 35, -35, 0, gIceSmoke, 20, 100 );
	UTIL_Sprite( iOrigin, -35, 35, 0, gIceSmoke, 20, 100 );
	UTIL_Sprite( iOrigin, -35, -35, 0, gIceSmoke, 20, 100 );
	
	set_user_rendering( iTarget );
	set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) & ~FL_FROZEN );

	emit_sound( iTarget, CHAN_AUTO, ICE_DIE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

	set_msg_block( gClCorpseMessage, BLOCK_ONCE );
	ExecuteHam( Ham_TakeDamage, iTarget, 0, id, float( get_pcvar_num( gCvarSubzeroDamage ) ), DMG_FREEZE );

	UTIL_BreakModel( iOrigin, { 3, 3, 9 }, { 0, 0, 6 }, 17, 40, 80, BREAK_GLASS );
	remove_entity_name( "tuty_Frostnova" );
}

public RemoveEntityCrystal( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		engfunc( EngFunc_RemoveEntity, iEntity );
	}
}

public RemoveAgruntEntity( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		engfunc( EngFunc_RemoveEntity, iEntity );
	}
}

public SpinCrystals( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		new Float:flAvelocity[ 3 ];
		
		flAvelocity[ 0 ] = 0.0;
		flAvelocity[ 1 ] = 500.0;
		flAvelocity[ 2 ] = 0.0;
		
		set_pev( iEntity, pev_avelocity, flAvelocity );
	}
}

public RemoveFrostnovaEntity( iEntity )
{
	if( pev_valid( iEntity ) )
	{
		engfunc( EngFunc_RemoveEntity, iEntity );
	}
}

public commandThunderOff( id )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_KILLBEAM );
	write_short( id );
	message_end( );

	return PLUGIN_HANDLED;
}

public removeRoots( taskid )
{
	new iTarget = taskid - TASKID_ROOTS;

	bIsHigh[ iTarget ] = false;

	remove_entity_name( "tuty_Roots" );
	set_pev( iTarget, pev_flags, pev( iTarget, pev_flags ) & ~FL_FROZEN );
}
