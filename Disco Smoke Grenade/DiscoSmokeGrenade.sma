
#include < amxmodx >

#include < fakemeta >
#include < hamsandwich >
#include < engine >

#pragma semicolon 1

#define PLUGIN_VERSION		"1.0.1"

#define SMOKE_MODEL_INDEX	"models/can.mdl"
#define SMOKE_SOUND		"misc/disco.wav"

new gSpriteLight;

const m_iGrenadeId = 2312;

public plugin_init( )
{
	register_plugin( "Disco SmokeGrenade", PLUGIN_VERSION, "tuty" );

	register_forward( FM_SetModel, "forward_setmodel" );

	register_touch( "grenade", "worldspawn", "forward_TouchNade" );
}

public plugin_precache( )
{
	precache_sound( SMOKE_SOUND );
	precache_model( SMOKE_MODEL_INDEX );

	gSpriteLight = precache_model( "sprites/lgtning.spr" );
}

public forward_setmodel( ent, const model[ ] )
{
	if( !pev_valid( ent ) || !equal( model[ 9 ], "smokegrenade.mdl" ) )
        {
            return FMRES_IGNORED;
        }
	
	new szClassName[ 32 ];
        pev( ent, pev_classname, szClassName, charsmax( szClassName ) );

        if( equal( szClassName, "grenade" ) )
        {
		engfunc( EngFunc_SetModel, ent, SMOKE_MODEL_INDEX );
		
		set_pev( ent, pev_movetype, MOVETYPE_TOSS );
		set_pev( ent, pev_iuser4, m_iGrenadeId );
		set_pev( ent, pev_nextthink, get_gametime() + 17.0 );

		set_rendering( ent, kRenderFxGlowShell, random( 256 ), random( 256 ), random( 256 ), kRenderNormal, 255 );

		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public forward_TouchNade( ent, world )
{
	if( !pev_valid( ent ) )
	{
		return PLUGIN_HANDLED;
	}
	
	if( pev( ent, pev_iuser4 ) != m_iGrenadeId  )
	{
		return PLUGIN_HANDLED;
	}

	new Float:flEntOrigin[ 3 ];
	pev( ent, pev_origin, flEntOrigin );

	flEntOrigin[ 2 ] += 70.0;
	
	UTIL_DrawSphere( flEntOrigin );

	set_pev( ent, pev_origin, flEntOrigin );
	set_pev( ent, pev_effects, EF_BRIGHTFIELD );
	
	emit_sound( ent, CHAN_ITEM, SMOKE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

	set_task( 2.0, "DrawTarBaby", ent, _, _, "a", 16 );
	set_task( 16.0, "RemoveEntity", ent );
	
	return HAM_SUPERCEDE;
}

public DrawTarBaby( ent )
{
	if( pev_valid( ent ) )
	{
		new Float:flOrigin[ 3 ];
		pev( ent, pev_origin, flOrigin );
		
		UTIL_ParticleBurst( flOrigin );
	}
}

public RemoveEntity( ent )
{
	set_pev( ent, pev_flags, FL_KILLME );
}

stock UTIL_DrawSphere( Float:origin[ 3 ] )
{
	new i, j;
	
    	for( i = 0; i < 5; i++ )
    	{
        	for( j = 0; j < 10; j++ )
        	{
            		static Float:flAngleVector[ 3 ], Float:flRadialVector[ 3 ];

            		flAngleVector[ 0 ] = ( 180.0 / 5 * i ) - 90.0;
            		flAngleVector[ 1 ] = ( 360.0 / 10 * j ) - 180.0;

            		angle_vector( flAngleVector, ANGLEVECTOR_FORWARD, flRadialVector );

           		flRadialVector[ 0 ] = flRadialVector[ 0 ] * 90.0 + origin[ 0 ];
            		flRadialVector[ 1 ] = flRadialVector[ 1 ] * 90.0 + origin[ 1 ];
            		flRadialVector[ 2 ] = flRadialVector[ 2 ] * 90.0 + origin[ 2 ];

            		UTIL_DrawBeam( origin, flRadialVector );
		}
	}
}

stock UTIL_DrawBeam( Float:start[ 3 ], Float:end[ 3 ] )
{
	engfunc( EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, start, 0 );
	write_byte( TE_BEAMPOINTS );
	engfunc( EngFunc_WriteCoord, start[ 0 ] );
	engfunc( EngFunc_WriteCoord, start[ 1 ] );
	engfunc( EngFunc_WriteCoord, start[ 2 ] );
	engfunc( EngFunc_WriteCoord, end[ 0 ] );
	engfunc( EngFunc_WriteCoord, end[ 1 ] );
	engfunc( EngFunc_WriteCoord, end[ 2 ] );
	write_short( gSpriteLight );
	write_byte( 2 );
	write_byte( 9 );
	write_byte( 158 ); 
	write_byte( 20 );
	write_byte( 4 );
	write_byte( random( 256 ) );
	write_byte( random( 256 ) );
	write_byte( random( 256 ) );
	write_byte( 255 );
	write_byte( 30 );
	message_end( );
}

stock UTIL_ParticleBurst( Float:Origin[ 3 ] )
{
	engfunc( EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, Origin, 0 );
	write_byte( TE_PARTICLEBURST );
	engfunc( EngFunc_WriteCoord, Origin[ 0 ] );
	engfunc( EngFunc_WriteCoord, Origin[ 1 ] );
	engfunc( EngFunc_WriteCoord, Origin[ 2 ] );
	write_short( 50 );
	write_byte( random( 255 ) );
	write_byte( 6 );
	message_end( );
}
