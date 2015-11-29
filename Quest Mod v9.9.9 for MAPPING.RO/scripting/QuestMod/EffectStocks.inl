
/*
	
	====================================================
	Stockuri create de mine, si de alti membrii amxmodx!
	====================================================

*/


stock UTIL_FlashTeam( const team[ ] )
{
	new iPlayers[ 32 ], iCount, Index;
	get_players( iPlayers, iCount, "ce", team );
	
	for( new i = 0; i < iCount; i++ )
	{
		Index = iPlayers[ i ];

		if( is_user_alive( Index ) && is_user_connected( Index ) )
		{
			UTIL_ScreenFade( Index, random( 256 ), random( 256 ), random( 256 ), 255 );
		}
	}
}

stock UTIL_SaveData( index )
{
	new szName[ 32 ];
	get_user_name( index, szName, charsmax( szName ) );
	
	new vKey[ 64 ], vData[ 64 ];
	
	formatex( vKey, charsmax( vKey ), "QMod_%s", szName );
  	formatex( vData, charsmax(  vData ), "%d", gKnifeModel[ index ] );

   	set_vaultdata( vKey, vData );
}

stock UTIL_LoadData( index )
{
	new szName[ 32 ];
	get_user_name( index, szName, charsmax( szName ) );
	
	new vKey[ 64 ], vData[ 64 ];
	
	formatex( vKey, charsmax( vKey ), "QMod_%s", szName );

   	get_vaultdata( vKey, vData, charsmax( vData ) );
   	gKnifeModel[ index ] = str_to_num( vData );
}

stock UTIL_ScreenFade( target, red, green, blue, alpha )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade, { 0, 0, 0 }, target );
        write_short( 3<<12 );
        write_short( 2<<12 );
        write_short( FFADE_IN );
        write_byte( red );
        write_byte( green );  
        write_byte( blue );  
        write_byte( alpha );
        message_end( ); 	
}

stock UTIL_ShowBeam( id, target, sprite, width, r, g, b, a )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMENTS );
	write_short( id );
	write_short( target );
	write_short( sprite );
	write_byte( 0 );
	write_byte( 15 );
	write_byte( 10 );
	write_byte( width );
	write_byte( 10 );
	write_byte( r );
	write_byte( g );
	write_byte( b );
	write_byte( a );
	write_byte( 0 );
	message_end( );
}

stock UTIL_DrawParticles( origin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin );
	write_byte( TE_PARTICLEBURST );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] );
	write_short( 150 );
	write_byte( 184 );
	write_byte( 6 );
	message_end( );
}

stock UTIL_FlaresBlow( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_SPRITETRAIL );
	write_coord( iOrigin[ 0 ] );		
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 40 );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( gSpriteIndex2 );
	write_byte( 30 );
	write_byte( 10 );
	write_byte( 1 );
	write_byte( 50 );
	write_byte( 10 );
	message_end( );
}

stock UTIL_ShowCylinder( origin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] + 10 );
	write_coord( origin[ 0 ] );
	write_coord( origin[ 1 ] );
	write_coord( origin[ 2 ] + 10 + 80 ); 
	write_short( gSpriteIndex3 );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 3 );
	write_byte( 60 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 123 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_GetPercent( const curNumber, const maxNumber )
{
	return floatround( ( curNumber * 100.0 ) / maxNumber );
}

stock UTIL_ColorPrint( id, const message[ ], { Float, Sql, Result, _ }:... )
{
	new Buffer[ 128 ],Buffer2[ 128 ];
	new players[ 32 ], index, num, i;
	
	formatex( Buffer2,charsmax( Buffer2 ), "%s", message );
	vformat( Buffer, charsmax( Buffer ), Buffer2, 3 );
	get_players( players, num, "c" );
	
	if( id )
	{
		if( !is_user_connected( id ) )
		{
			return;
		}
			
		message_begin( MSG_ONE_UNRELIABLE, gMessageSayText, _, id );
		write_byte( id );
		write_string( Buffer );
		message_end();
	} 
	
	else
	{	
		for( i = 0; i < num; i++ )
		{
			index = players[ i ];

			if( !is_user_connected( index ) ) 
			{
				continue;
			}
				
			message_begin( MSG_ONE_UNRELIABLE, gMessageSayText, _, index );
			write_byte( index );
			write_string( Buffer );
			message_end();
		}
	}
}

stock UTIL_HealEffect( index )
{
	new iOrigin[ 3 ];
	get_user_origin( index, iOrigin );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_PROJECTILE );
	write_coord( iOrigin[ 0 ] + random_num( -13, 13 ) );
	write_coord( iOrigin[ 1 ] + random_num( -13, 13 ) );
	write_coord( iOrigin[ 2 ] + random_num( 0, 40 ) );
	write_coord( 0 );
	write_coord( 0 );
	write_coord( 15 );
	write_short( gSpriteHeal );
	write_byte( 1 );
	write_byte( index );
	message_end( );
}

stock UTIL_CreateCrystal( index, Float:flCoordX, Float:flCoordY )
{
	new Float:flOrigin[ 3 ];
	pev( index, pev_origin, flOrigin );
	
	flOrigin[ 0 ] += flCoordX;
	flOrigin[ 1 ] += flCoordY;

	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEntity, pev_classname, "tuty_ScientistCrystal" );

	engfunc( EngFunc_SetModel, iEntity, CRYSTAL_MODEL );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_solid, SOLID_NOT );
	set_pev( iEntity, pev_movetype, MOVETYPE_NOCLIP );

	engfunc( EngFunc_DropToFloor, iEntity );
	set_rendering( iEntity, kRenderFxGlowShell, 255, 85, 0, kRenderNormal, 255 );

	set_task( 0.3, "SpinCrystals", iEntity );
	set_task( float( get_pcvar_num( gCvarScientistTestDuration ) ), "RemoveEntityCrystal", iEntity );
	
	return PLUGIN_HANDLED;
}

stock UTIL_CreateAgrunt( index )
{
	new Float:flOrigin[ 3 ];
	pev( index, pev_origin, flOrigin );

	flOrigin[ 2 ] += 120.0;

	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}

	set_pev( iEntity, pev_classname, "tuty_ScientistAgrunt" );

	engfunc( EngFunc_SetModel, iEntity, AGRUNT_MODEL );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_solid, SOLID_NOT );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );

	new Float:flVelocity[ 3 ];

	flVelocity[ 2 ] = -250.0;

	set_pev( iEntity, pev_velocity, flVelocity );
	set_task( 1.0, "RemoveAgruntEntity", iEntity );
	
	return PLUGIN_HANDLED;
}

stock UTIL_CreateThunder( iStart[ 3 ], iEnd[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY ); 
	write_byte( TE_BEAMPOINTS ); 
	write_coord( iStart[ 0 ] ); 
	write_coord( iStart[ 1 ] ); 
	write_coord( iStart[ 2 ] ); 
	write_coord( iEnd[ 0 ] ); 
	write_coord( iEnd[ 1 ] ); 
	write_coord( iEnd[ 2 ] ); 
	write_short( gBoltSpritee ); 
	write_byte( 1 );
	write_byte( 5 );
	write_byte( 7 );
	write_byte( 20 );
	write_byte( 30 );
	write_byte( 127 ); 
	write_byte( 255 );
	write_byte( 0 );
	write_byte( 200 );
	write_byte( 255 );
	message_end( );
}

stock UTIL_Sprite( iOrigin[ 3 ], iCoordX, iCoordY, iCoordZ, iSprite, iFrame, iBrightness )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_SPRITE );
	write_coord( iOrigin[ 0 ] + iCoordX );
	write_coord( iOrigin[ 1 ] + iCoordY );
	write_coord( iOrigin[ 2 ] + iCoordZ );
	write_short( iSprite );
	write_byte( iFrame );
	write_byte( iBrightness );
	message_end( );
}

stock UTIL_BloodStream( iOrigin[ 3 ], iDirection[ 3 ], iSpeed )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin, 0 );
	write_byte( TE_BLOODSTREAM );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iDirection[ 0 ] ); 
	write_coord( iDirection[ 1 ] ); 
	write_coord( iDirection[ 2 ] ); 
	write_byte( 195 );
	write_byte( iSpeed );
	message_end( );
}

stock UTIL_DLight( iOrigin[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_DLIGHT );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_byte( 5 );
	write_byte( 0 );
	write_byte( 255 );
	write_byte( 0 );
	write_byte( 30 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_WorldDecal( iOrigin[ 3 ], iDecal )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_WORLDDECAL );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_byte( iDecal );
	message_end( );
}

stock UTIL_BeamTorus( index )
{
	new iOrigin[ 3 ];
	get_user_origin( index, iOrigin );

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMDISK );
	write_coord( iOrigin[ 0 ] ); 
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + random_num( -30, 50 ) );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + 173 );
	write_short( gSpriteIndex3 );
	write_byte( 1 ); 
	write_byte( 3 );
	write_byte( 8 ); 
	write_byte( 20 );
	write_byte( 6 ); 
	write_byte( random( 256 ) );
	write_byte( random( 256 ) );
	write_byte( random( 256 ) );
	write_byte( 199 );
	write_byte( 0 );
	message_end( );
}

stock UTIL_GetStartPosition( id, Float:Forward = 0.0, Float:Right = 0.0, Float:Up = 0.0, Float:vecSource[ 3 ] )
{
	static Float:vecForward[ 3 ], Float:vecRight[ 3 ], Float:vecUp[ 3 ];
	static Float:vecPlayerAngles[ 3 ];
	
	pev( id, pev_origin, vecSource );
	pev( id, pev_v_angle, vecPlayerAngles );
	
	engfunc( EngFunc_MakeVectors, vecPlayerAngles );
	
	if( Forward > 0.0 ) global_get( glb_v_forward, vecForward );
	if( Right > 0.0 ) global_get( glb_v_right, vecRight );
	if( Up > 0.0 ) global_get( glb_v_up, vecUp );
	
	vecSource[ 0 ] += floatmul( vecForward[ 0 ], Forward ) + floatmul( vecRight[ 0 ], Right ) + floatmul( vecUp[ 0 ], Up );
	vecSource[ 1 ] += floatmul( vecForward[ 1 ], Forward ) + floatmul( vecRight[ 1 ], Right ) + floatmul( vecUp[ 1 ], Up );
	vecSource[ 2 ] += floatmul( vecForward[ 2 ], Forward ) + floatmul( vecRight[ 2 ], Right ) + floatmul( vecUp[ 2 ], Up );
}

stock UTIL_BreakModel( iOrigin[ 3 ], iSize[ 3 ], iVelocity[ 3 ], iNoise, iCount, iLife, iFlags )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin, 0 );
	write_byte( TE_BREAKMODEL );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_coord( iSize[ 0 ] );
	write_coord( iSize[ 1 ] );
	write_coord( iSize[ 2 ] );
	write_coord( iVelocity[ 0 ] + random_num( -6, 6 ) );
	write_coord( iVelocity[ 1 ] + random_num( -4, 4 ) );
	write_coord( iVelocity[ 2 ] + random_num( 50, 80 ) );
	write_byte( iNoise );
	write_short( gGlassModel );
	write_byte( iCount );
	write_byte( iLife );
	write_byte( iFlags );
	message_end( );
}

stock UTIL_Implosion( iOrigin[ 3 ], addrad )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_IMPLOSION );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + addrad );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 20 );
	message_end( );
}

stock UTIL_Frostnova( index )
{
	new Float:flOrigin[ 3 ];
	pev( index, pev_origin, flOrigin );
	
	flOrigin[ 2 ] += -21.1;
	
	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}
	
	set_pev( iEntity, pev_classname, "tuty_Frostnova" );

	engfunc( EngFunc_SetModel, iEntity, ICE_MODEL );
	engfunc( EngFunc_SetOrigin, iEntity, flOrigin );

	set_pev( iEntity, pev_solid, SOLID_NOT );
	set_pev( iEntity, pev_movetype, MOVETYPE_NONE );

	engfunc( EngFunc_DropToFloor, iEntity );
	set_rendering( iEntity, kRenderFxGlowShell, 0, 255, 255, kRenderTransAlpha, 8 );
	
	set_task( float( get_pcvar_num( gCvarSubzeroIceTime ) ), "RemoveFrostnovaEntity", iEntity );

	return PLUGIN_HANDLED;
}
	
stock UTIL_BeamFollow( ent, sprite, r, g, b )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( ent );
	write_short( sprite );
	write_byte( 6 );
	write_byte( 30 ); 
	write_byte( r ); 
	write_byte( g ); 
	write_byte( b ); 
	write_byte( 255 );
	message_end( );
}

stock UTIL_ExecuteDamage( entid, Float:flDamage, Float:flRange, dmgbit ) 
{
	new Float:flOrigin[ 3 ];
	pev( entid, pev_origin, flOrigin );

	new Float:flDistance;
	new Float:flTmpDmg;
	new Float:flOrigin2[ 3 ];
	
	new id = pev( entid, pev_owner );

	for( new i = 1; i <= gMaxPlayers; i++ ) 
	{
		if( is_user_alive( i ) && get_user_team( id ) != get_user_team( i ) )
		{
			pev( i, pev_origin, flOrigin2 );
			flDistance = get_distance_f( flOrigin, flOrigin2 );
			
			if( flDistance <= flRange ) 
			{
				flTmpDmg = flDamage - ( flDamage / flRange ) * flDistance;
				
				ExecuteHam( Ham_TakeDamage, i, entid, id, flTmpDmg, dmgbit );
			}
		}
	}
}

stock UTIL_FireballExplo( iOrigin[ 3 ] )
{
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_EXPLOSION );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( gFbExploSprite );
	write_byte( 28 );
	write_byte( 0 );
	write_byte( TE_EXPLFLAG_NONE );
	message_end( );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SMOKE );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] );
	write_short( gFbSmokeSprite );
	write_byte( 28 );
	write_byte( 0 );
	message_end( );
}
