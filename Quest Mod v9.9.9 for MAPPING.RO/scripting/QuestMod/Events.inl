
/*
	
	====================================================
	Eventuri, forwarduri, hamuri aici!
	====================================================

*/


QuestMod_RegisterEvents( )
{
	register_event( "CurWeapon", "Hook_CurWeapon", "be", "1=1" );
	register_event( "HLTV", "Hook_NewRound", "a", "1=0", "2=0" );
	register_event( "DeathMsg", "Hook_Death", "a" );

	RegisterHam( Ham_Spawn, "player", "bacon_Spanwed", 1 );
	RegisterHam( Ham_TakeDamage, "player", "bacon_TakeDamage", 0 );
	RegisterHam( Ham_Player_PreThink, "player", "bacon_PreThink" );
	
	register_forward( FM_CmdStart, "forward_cmdstart" );
	register_forward( FM_Touch, "forward_touch" );
	
	register_touch( "ReptileAcidSpit", "player", "forward_SpitTouchPlayer" );
	register_touch( "ReptileAcidSpit", "*", "forward_SpitTouchAll" );
}

public client_putinserver( id )
{
	UTIL_LoadData( id );
	
	bChoose[ id ] = 0;
	bIsHigh[ id ] = false;
}

public client_disconnect( id )
{
	if( task_exists( id + TASKID_HEALING ) )
	{
		remove_task( id + TASKID_HEALING );
	}
	
	if( task_exists( id + TASKID_SCORPION ) )
	{
		remove_task( id + TASKID_SCORPION );
	}
	
	if( task_exists( id + TASKID_CRYSTAL ) )
	{
		remove_task( id + TASKID_CRYSTAL );
	}
	
	if( task_exists( id + TASKID_SCIENCE ) )
	{
		remove_task( id + TASKID_SCIENCE );
	}
	
	if( task_exists( id + TASKID_SUBZERO ) )
	{
		remove_task( id + TASKID_SUBZERO );
	}
	
	if( task_exists( id + TASKID_FIREMAN ) )
	{
		remove_task( id + TASKID_FIREMAN );
	}
} 

public Hook_NewRound( )
{
	for( new id = 1; id <= gMaxPlayers; id++ )
	{
		bChoose[ id ] = 0;
		bIsHigh[ id ] = false;
	}
}

public bacon_Spanwed( id )
{
	bIsHigh[ id ] = false;

	if( is_user_alive( id ) && gKnifeModel[ id ] == 2 )
	{
		give_item( id, "weapon_smokegrenade" );
	}
}

public Hook_Death( )
{
	new id = read_data( 2 );

	if( task_exists( id + TASKID_HEALING ) )
	{
		remove_task( id + TASKID_HEALING );
	}
	
	if( task_exists( id + TASKID_SCORPION ) )
	{
		remove_task( id + TASKID_SCORPION );
	}
	
	if( task_exists( id + TASKID_CRYSTAL ) )
	{
		remove_task( id + TASKID_CRYSTAL );
	}
	
	if( task_exists( id + TASKID_SCIENCE ) )
	{
		remove_task( id + TASKID_SCIENCE );
	}
	
	if( task_exists( id + TASKID_SUBZERO ) )
	{
		remove_task( id + TASKID_SUBZERO );
	}
	
	if( task_exists( id + TASKID_FIREMAN ) )
	{
		remove_task( id + TASKID_FIREMAN );
	}

	bIsHigh[ id ] = false;
	
	new iFlags = pev( id, pev_flags );
	
	if( iFlags & FL_FROZEN )
	{
		set_pev( id, pev_flags, iFlags & ~FL_FROZEN );
	}
}

public bacon_PreThink( id )
{
	if( is_user_alive( id ) )
	{
		if( gKnifeModel[ id ] != 0 && task_exists( id + TASKID_HEALING ) )
		{
			remove_task( id + TASKID_HEALING );
		}
		
		if( gKnifeModel[ id ] == 5 )
		{
			set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, get_pcvar_num( gCvarVisibility ) );
		}
	}
}

public Hook_CurWeapon( id )
{
	SetKnifePower( id, gKnifeModel[ id ] );
	
	new iIsKnifeWeapon = read_data( 2 ) == CSW_KNIFE;
		
	new Float:flGravity = ( ( gKnifeModel[ id ] == 1 && iIsKnifeWeapon ) ? get_pcvar_float( gCvarLowGrav ) : get_pcvar_float( gCvarNormGrav ) );
   	set_user_gravity( id , flGravity );
	
	set_user_footsteps( id, ( gKnifeModel[ id ] == 2 ) ? 1 : 0 );

	if( gKnifeModel[ id ] == 0 && !task_exists( id + TASKID_HEALING ) )
	{
		set_task( TASK_INTERVAL , "task_healing", id + TASKID_HEALING, _,_, "b" );
	}

	if( gKnifeModel[ id ] == 4 )
	{
		set_user_maxspeed( id, get_pcvar_float( gCvarLowSpeed ) );
	}
	
	if( gKnifeModel[ id ] == 3 )
	{
		set_user_maxspeed( id, get_pcvar_float( gCvarHighSpeed ) );
	}
	
	if( gKnifeModel[ id ] == 5 )
	{
		set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, get_pcvar_num( gCvarVisibility ) );
	}

	if( gKnifeModel[ id ] > 0 )
	{
		if( task_exists( id + TASKID_HEALING ) )
		{
			remove_task( id + TASKID_HEALING );
		}
	}
	
	if( gKnifeModel[ id ] != 5 )
	{
		set_user_rendering( id );
	}

	return PLUGIN_CONTINUE;
}

public bacon_TakeDamage( victim, inflictor, attacker, Float:damage, damagebits )
{
	if( !( 1 <= attacker <= gMaxPlayers )
	|| attacker != inflictor 
	|| !( 1 <= victim <= gMaxPlayers )
	|| victim != inflictor )
	{
        	return HAM_IGNORED;
	}
	
	if( gKnifeModel[ attacker ] == 4 && get_user_weapon( attacker ) == CSW_KNIFE )
	{
    		SetHamParamFloat( 4, damage * float( get_pcvar_num( gCvarDamage ) ) ); 
		SetHamParamInteger( 5, DMG_ALWAYSGIB );
	}
	
	if( gKnifeModel[ victim ] == 13 )
	{
		SetHamParamFloat( 4, damage / float( 2 ) );
	}

    	return HAM_HANDLED;
}

public forward_cmdstart( id, handle )
{
	if( !is_user_alive( id ) || gKnifeModel[ id ] != 12 )
	{
		return FMRES_IGNORED;
	}
	
	new iButton = get_uc( handle, UC_Buttons );
	
	if( iButton & IN_USE )
	{	
		new iTarget, iBody;
		get_user_aiming( id, iTarget, iBody, get_pcvar_num( gCvarMedicHealDistance ) );
		
		if( pev_valid( iTarget ) && is_user_alive( iTarget ) )
		{
			if( get_user_team( id ) != get_user_team( iTarget ) )
			{
				return FMRES_IGNORED;
			}
		
			new iMaxHealth = get_pcvar_num( gCvarMedicMaxHealth );
			new iHealth = get_user_health( iTarget );

			if( iHealth >= iMaxHealth )
			{
				client_print( id, print_center, "Coechipierul tau are deja viata %d!", iMaxHealth );
	
				return FMRES_IGNORED;
			}
			
			new Float:flGameTime = get_gametime( );
			
			if( flGameTime - bflLastHealed[ id ] >= 0.2 )
			{
				bflLastHealed[ id ] = flGameTime;
				set_pev( iTarget, pev_health, float( iHealth + 1 ) );

				UTIL_HealEffect( iTarget );
				UTIL_ShowBeam( id, iTarget, gSpriteBeamHeal, 20, 0, 255, 0, 60 );
			}
		}
	}
	
	return FMRES_IGNORED;
}

public forward_SpitTouchPlayer( iEnt, iPlayer )
{
	if( pev( iEnt, pev_iuser3 ) == ACIDSPIT_ENTID && pev_valid( iEnt ) )
	{
		new iOwner = pev( iEnt, pev_owner );
		
		if( get_user_team( iOwner ) == get_user_team( iPlayer ) )
		{
			return PLUGIN_HANDLED;
		}
		
		new Float:flOrigin[ 3 ], iOrigin[ 3 ];
		
		pev( iPlayer, pev_origin, flOrigin );
		FVecIVec( flOrigin, iOrigin );
		
		set_pev( iPlayer, pev_dmg_inflictor, iOwner );
		
		UTIL_Sprite( iOrigin, 0, 0, 0, gAcidSprite, 21, 255 );
		emit_sound( iPlayer, CHAN_STATIC, ACID_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		ExecuteHamB( Ham_TakeDamage, iPlayer, iEnt, iOwner, float( get_pcvar_num( gCvarReptileDmg ) ), DMG_PARALYZE );
		
		set_pev( iEnt, pev_flags, FL_KILLME );
	}
	
	return PLUGIN_HANDLED;
}

public forward_SpitTouchAll( iEnt, iWorld )
{
	if( pev( iEnt, pev_iuser3 ) == ACIDSPIT_ENTID && pev_valid( iEnt ) )
	{
		new Float:flOrigin[ 3 ], iOrigin[ 3 ];

		pev( iEnt, pev_origin, flOrigin );
		FVecIVec( flOrigin, iOrigin );
		
		UTIL_DLight( iOrigin );
		UTIL_WorldDecal( iOrigin, gBloodDecals[ random_num( 0, charsmax( gBloodDecals ) ) ] );

		set_pev( iEnt, pev_flags, FL_KILLME );
	}
}

public forward_touch( ent, id )
{
	if( !pev_valid( ent ) )
	{
		return FMRES_IGNORED;
	}
	
	new szClassname[ 32 ];
	pev( ent, pev_classname, szClassname, charsmax( szClassname ) );
	
	if( !equal( szClassname, "LiuKangFireBall" ) )
	{
		return FMRES_IGNORED;
	}
	
	new iOwner = pev( ent, pev_owner );

	if( get_user_team( iOwner ) == get_user_team( id ) )
	{
		return FMRES_IGNORED;
	}

	new Float:flOrigin[ 3 ], iOrigin[ 3 ];
	
	pev( ent, pev_origin, flOrigin );
	FVecIVec( flOrigin, iOrigin );

	UTIL_FireballExplo( iOrigin );
	UTIL_ExecuteDamage( ent, float( gCvarLiukangBallDamage ), float( gCvarLiukangBallRadius ), DMG_BURN );

	set_pev( ent, pev_flags, pev( ent, pev_flags ) | FL_KILLME );
	
	return FMRES_IGNORED;
}

public SetKnifePower( id, knife )
{
	gKnifeModel[ id ] = knife;
	   
	if( get_user_weapon( id ) != CSW_KNIFE )
	{
		return PLUGIN_HANDLED;
	}
	   
	new szViewModel[ 60 ];
	   
	switch( knife )
	{
		case 0: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_MUTANT );
		case 1:	formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_HULK );
		case 2:	formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_NINJA );
		case 3:	formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_FLASH );
		case 4:	formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_WOLF );
		case 5: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_PREDATOR );	
		case 6: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_NIGHT );
		case 7:	formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_STORM );
		case 8: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_SPECTRU );
		case 9: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_WEED );
		case 10: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_DEFAULT );
		case 11: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_SCORPION );
		case 12: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_MEDIC );
		case 13: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_GORDON );
		case 14: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_SCIENTIST );
		case 15: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_REPTILE );
		case 16: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_SUBZERO );
		case 17: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_FIREMAN );
		case 18: formatex( szViewModel, charsmax( szViewModel ), "%s", KNIFE_LIUKANG );
	}

	set_pev( id, pev_viewmodel2, szViewModel );
	set_pev( id, pev_weaponmodel2, KNIFE_PDEF );
	
	return PLUGIN_HANDLED;
}
