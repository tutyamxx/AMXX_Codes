/*	Copyright © 2009, tuty
	Healthkit On Dead Body is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Teleport Destination Angles Editor; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include < amxmodx >

#include < fakemeta >
#include < fakemeta_util >

#define PLUGIN_VERSION		"3.3"

#define FFADE_IN 		0x0000

enum _: iCoords
{
	x = 0,
	y,
	z
};
		
new const szModelKit[ ] = "models/w_medkit.mdl";
new const szPickupSound[ ] = "items/smallmedkit1.wav";

new gToggleKitEnable;
new gToggleGlowShow;
new gGMsgFade;
new gToggleFadeEnable;
new gToggleRemoveAtRstart;
new gKitHealthCvar;
new gLimitHealthCvar;
new gGMsgItemPickup;

new const gMedKitClassname[ ] = "medkit_entity";

public plugin_init( )
{
	register_plugin( "Healthkit on dead body", PLUGIN_VERSION, "tuty" );
    	
        register_event( "DeathMsg","Event_DeathMsg","a" );
        register_logevent( "LOGEvent_Round_Start", 2, "1=Round_Start" );
	
        register_forward( FM_Touch, "forward_FM_Touch" );
	
        gToggleKitEnable = register_cvar( "kit_enable", "1" );
        gToggleGlowShow = register_cvar( "kit_glow", "1" );
        gToggleFadeEnable = register_cvar( "kit_fade", "1" );
        gToggleRemoveAtRstart = register_cvar( "kit_remove", "0" );
        gKitHealthCvar = register_cvar( "kit_health", "20" );
        gLimitHealthCvar = register_cvar( "kit_limit_health", "100" );
	
	gGMsgFade = get_user_msgid( "ScreenFade" );
        gGMsgItemPickup = get_user_msgid( "ItemPickup" );
}
 
public plugin_precache( )
{
	precache_model( szModelKit );
        precache_sound( szPickupSound );
}

public Event_DeathMsg( )
{
	if( get_pcvar_num( gToggleKitEnable ) == 0 )
        {
		return PLUGIN_HANDLED;
        }	
	
        new iVictim = read_data( 2 );
	
        static Float:flOrigin[ iCoords ];
        pev( iVictim, pev_origin, flOrigin );
	
        new iEnt = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	/* --| Modify the origin a little bit. This is calculated to be set on floor */
        flOrigin[ z ] -= 36; 
	
        engfunc( EngFunc_SetOrigin, iEnt, flOrigin );
	
        if( !pev_valid( iEnt ) )
        {
		return PLUGIN_HANDLED;
        }
	
        set_pev( iEnt, pev_classname, gMedKitClassname );
        engfunc( EngFunc_SetModel, iEnt, szModelKit );
        dllfunc( DLLFunc_Spawn, iEnt );
        set_pev( iEnt, pev_solid, SOLID_BBOX );
        set_pev( iEnt, pev_movetype, MOVETYPE_NONE );
        engfunc( EngFunc_SetSize, iEnt, Float:{ -23.160000, -13.660000, -0.050000 }, Float:{ 11.470000, 12.780000, 6.720000 } );
        engfunc( EngFunc_DropToFloor, iEnt );
	
        if( get_pcvar_num( gToggleGlowShow ) == 1 )
        {
		fm_set_rendering( iEnt, kRenderFxGlowShell, 255, 255, 255, kRenderFxNone, 27 );
        }
	
        return PLUGIN_HANDLED;
}

public forward_FM_Touch( iEnt, id )
{
        if( !pev_valid( iEnt ) 
	|| get_pcvar_num( gToggleKitEnable ) == 0 )
        {
		return FMRES_IGNORED;
        }
	
        new szClassname[ 32 ];
        pev( iEnt, pev_classname, szClassname, charsmax( szClassname ) );
	
        if( !equal( szClassname, gMedKitClassname ) )
        {
		return FMRES_IGNORED;
        }
	
        new iUserHealth = get_user_health( id );

        new iCvarHealth = get_pcvar_num( gKitHealthCvar );
        new iMaxHealth = get_pcvar_num( gLimitHealthCvar );

        if( iUserHealth >= iMaxHealth )
        {
		return FMRES_IGNORED;
        }

        set_hudmessage( 255, 0, 0, -1.0, 0.83, 2, 6.0, 3.0 );
        show_hudmessage( id, "You received %d HP", iCvarHealth );
	
        fm_set_user_health( id, iUserHealth + iCvarHealth );

        emit_sound( id, CHAN_ITEM, szPickupSound, VOL_NORM, ATTN_NORM, 0 , PITCH_NORM );
        UTIL_Send_PickupMessage( id, "item_healthkit" );
        
        if( get_pcvar_num( gToggleFadeEnable ) == 1 )
        {
		message_begin( MSG_ONE_UNRELIABLE, gGMsgFade , _, id );
		write_short( 1<<10 );
		write_short( 1<<10 );
		write_short( FFADE_IN );
		write_byte( 255 );
		write_byte( 0 );
		write_byte( 0 ); 
		write_byte( 75 );
		message_end( );
        }
	
        engfunc( EngFunc_RemoveEntity, iEnt );

        return FMRES_IGNORED;
}

public LOGEvent_Round_Start( )
{
        if( get_pcvar_num( gToggleRemoveAtRstart ) == 1 )
        {
		new iEntity = FM_NULLENT;

		while( ( iEntity = fm_find_ent_by_class( iEntity, gMedKitClassname ) ) )
		{
			engfunc( EngFunc_RemoveEntity, iEntity );
		}
	}	
}

stock UTIL_Send_PickupMessage( const id, const szItemName[ ] )
{
	message_begin( MSG_ONE_UNRELIABLE, gGMsgItemPickup, _, id );
        write_string( szItemName );
        message_end( );
}
