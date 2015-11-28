
#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

new gKnifeHitDecalIndex[ 2 ];

new gMaxClients;

public plugin_init()
{
	register_plugin( "Knife Hit Decal", PLUGIN_VERSION, "tuty" );

	RegisterHam( Ham_TraceAttack, "worldspawn", "bacon_TraceAttackWorldspawn" );
	
	gMaxClients = get_maxplayers();
}

public plugin_precache()
{
	gKnifeHitDecalIndex[ 0 ] = engfunc( EngFunc_DecalIndex, "{crack1" );
	gKnifeHitDecalIndex[ 1 ] = engfunc( EngFunc_DecalIndex, "{crack2" );
}

public bacon_TraceAttackWorldspawn( iVictim, iAttacker, Float:flDamage, Float:flDirection[ 3 ], iTr, iDamageBits )
{
	if( 1 <= iAttacker <= gMaxClients )
	{
		if( get_user_weapon( iAttacker ) == CSW_KNIFE )
		{
			new Float:flEndOrigin[ 3 ];
			get_tr2( iTr, TR_vecEndPos, flEndOrigin );
			
			UTIL_WorldDecal( flEndOrigin, gKnifeHitDecalIndex[ random_num( 0, charsmax( gKnifeHitDecalIndex ) ) ] );
		}
	}
}

stock UTIL_WorldDecal( Float:flOrigin[ 3 ], iDecal )
{
	engfunc( EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, flOrigin, 0 );
	write_byte( TE_WORLDDECAL );
	engfunc( EngFunc_WriteCoord, flOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, flOrigin[ 2 ] );
	write_byte( iDecal );
	message_end();
}
