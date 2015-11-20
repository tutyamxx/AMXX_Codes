
#include < amxmodx >
#include < fakemeta >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.1"

#define MODEL_SKELETON	"models/skeleton.mdl"

public plugin_init() 
{
	register_plugin( "Skeletons", PLUGIN_VERSION, "Samurai" );
	
	set_msg_block( get_user_msgid( "ClCorpse" ), BLOCK_SET );
	
	register_event( "HLTV", "HookEvent_NewRound", "a", "1=0", "2=0" );
	register_event( "DeathMsg", "Hook_DeathMessage", "a" );
}

public plugin_precache()
{
	precache_model( MODEL_SKELETON );
}

public HookEvent_NewRound()
{
	new iEntity = FM_NULLENT;
	
	while( ( iEntity  = engfunc( EngFunc_FindEntityByString, iEntity, "classname", "CS_SkeletonBody" ) ) )
	{
		engfunc( EngFunc_RemoveEntity, iEntity );
	}
}

public Hook_DeathMessage()
{
	new iVictim = read_data( 2 );

	new Float:flVictimOrigin[ 3 ];
	pev( iVictim, pev_origin, flVictimOrigin );
	
	new iEntity = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if( !pev_valid( iEntity ) )
	{
		return PLUGIN_HANDLED;
	}

	flVictimOrigin[ 2 ] -= 32.0;
	
	engfunc( EngFunc_SetOrigin, iEntity, flVictimOrigin );
		
	new Float:flSkeletonAngles[ 3 ];
	pev( iEntity, pev_angles, flSkeletonAngles );
	
	flSkeletonAngles[ 1 ] += random_num( 1, 360 );

	engfunc( EngFunc_SetModel, iEntity, MODEL_SKELETON );
	set_pev( iEntity, pev_classname, "CS_SkeletonBody" );
	dllfunc( DLLFunc_Spawn, iEntity );
	set_pev( iEntity, pev_solid, SOLID_NOT );
	set_pev( iEntity, pev_movetype, MOVETYPE_FLY );
	set_pev( iEntity, pev_angles, flSkeletonAngles );
	engfunc( EngFunc_SetSize, iEntity, Float:{ -2.440000, -3.540000, -4.960000 }, Float:{ 5.880000, 3.780000, 4.750000 } );
	engfunc( EngFunc_DropToFloor, iEntity );
	
	return PLUGIN_CONTINUE;
}
