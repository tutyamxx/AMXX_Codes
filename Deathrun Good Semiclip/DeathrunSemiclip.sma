
#include < amxmodx >

#include < fakemeta >
#include < engine >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

new gCvarSemiclipEnabled;

new gSemiClip[ 33 ];

public plugin_init()
{
	register_plugin( "Good Semiclip", PLUGIN_VERSION, "tuty" );
	
	register_forward( FM_StartFrame, "forward_StartFrame", 0 );
	register_forward( FM_AddToFullPack, "forward_FullPack", 1 );
	
	gCvarSemiclipEnabled = register_cvar( "sv_semiclip", "1" );
}

public forward_StartFrame()
{
	if( get_pcvar_num( gCvarSemiclipEnabled ) != 1 )
	{
		return FMRES_IGNORED;
	}
	
	new iPlayers[ 32 ], iNum, id, id2, i, j;
	get_players( iPlayers, iNum, "ache", "CT" );
	
	if( iNum <= 1 )
	{
		return FMRES_IGNORED;
	}
	
	for( i = 0; i < iNum; i++ )
	{
		id = iPlayers[ i ];
		
		for( j = 0; j < iNum; j++ )
		{
			id2 = iPlayers[ j ];
			
			if( id == id2 )
			{
				continue;
			}
			
			if( gSemiClip[ id ] && gSemiClip[ id2 ] )
			{
				continue;
			}
			
			if( entity_range( id, id2 ) < get_pcvar_num( gCvarSemiclipRenderDist ) )
			{
				gSemiClip[ id ] = true;
				gSemiClip[ id2 ] = true;
			}
		}
	}
	
	for( i = 0; i < iNum; i++ )
	{
		id = iPlayers[ i ];
		
		set_pev( id, pev_solid, gSemiClip[ id ] ? SOLID_NOT : SOLID_SLIDEBOX );
	}
	
	return FMRES_IGNORED;
}

public forward_FullPack( es, e, ent, host, flags, player, pSet )
{
	if( get_pcvar_num( gCvarSemiclipEnabled ) != 1 )
	{
		return FMRES_IGNORED;
	}
	
	if( player && gSemiClip[ ent ] && gSemiClip[ host ] )
	{
		set_es( es, ES_Solid, SOLID_NOT );
	}
	
	return FMRES_IGNORED;
}
