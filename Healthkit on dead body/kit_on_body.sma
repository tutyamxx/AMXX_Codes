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

#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>



/* --| Plugin information */
#define PLUGIN 		"Healthkit on dead body"
#define AUTHOR 		"tuty"
#define VERSION 	"3.2b"

/* --| Some plugin defines */
#define MEDKIT_MINSZ 	Float:{ -23.160000, -13.660000, -0.050000 }
#define MEDKIT_MAXSZ 	Float:{ 11.470000, 12.780000, 6.720000 }
#define MODEL_KIT 	"models/w_medkit.mdl"
#define SOUND_KIT 	"items/smallmedkit1.wav" 
#define FFADE_IN 	0x0000

/* --| Some globals... */
new gToggleKitEnable;
new gToggleGlowShow;
new gGMsgFade;
new gToggleFadeEnable;
new gToggleRemoveAtRstart;
new gKitHealthCvar;
new gLimitHealthCvar;
new gGMsgItemPickup;

/* --| Medkit classname */
new const gMedKitClassname[] = "medkit_entity";

/* --| Let's start the plugin */
public plugin_init()
{
	/* --| Registering the plugin to show it on plugins list */
	register_plugin( PLUGIN, VERSION, AUTHOR );
    	
	/* --| Some usefull events */
        register_event( "DeathMsg","drop_kit","a" );
        register_logevent( "logevent_round_start", 2, "1=Round_Start" );
	
	/* --| Register the touch forward */
        register_forward( FM_Touch,"ForwardTouch" );
	
	/* --| Cvar list */
        gToggleKitEnable = register_cvar( "kit_enable", "1" );
        gToggleGlowShow = register_cvar( "kit_glow", "1" );
        gToggleFadeEnable = register_cvar( "kit_fade", "1" );
        gToggleRemoveAtRstart = register_cvar( "kit_remove", "0" );
        gKitHealthCvar = register_cvar( "kit_health", "20" );
        gLimitHealthCvar = register_cvar( "kit_limit_health", "100" );
	
	/* --| Let's catch the user message id's */
	gGMsgFade = get_user_msgid( "ScreenFade" );
        gGMsgItemPickup = get_user_msgid( "ItemPickup" );
}

/* --| Precaching stuff */  
public plugin_precache()
{
	precache_model( MODEL_KIT );
        precache_sound( SOUND_KIT );
}

/* --| When player dies, let's drop the kit if plugin is elabled */
public drop_kit()
{
	/* --| Check if plugin is enabled/disabled */
	if( get_pcvar_num( gToggleKitEnable ) == 0 )
        {
		return PLUGIN_HANDLED;
        }	
	
	/* --| Get the victim id */
        new victim = read_data( 2 );
	
	/* --| Get the victim origin */
        static Float:origin[ 3 ];
        pev( victim, pev_origin, origin );
	
	/* --| Creating healthkit entity */
        new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	/* --| Modify the origin a little bit. This is calculated to be set on floor */
        origin[ 2 ] -= 36; 
	
	/* --| Setting the ent origin */
        engfunc( EngFunc_SetOrigin, ent, origin );
	
	/* --| Check if isn't a valid ent */
        if( !pev_valid( ent ) )
        {
		return PLUGIN_HANDLED;
        }
	
	/* --| Now let's set the entity model and some stuff */
        set_pev( ent, pev_classname, gMedKitClassname );
        engfunc( EngFunc_SetModel, ent, MODEL_KIT );
        dllfunc( DLLFunc_Spawn, ent );
        set_pev( ent, pev_solid, SOLID_BBOX );
        set_pev( ent, pev_movetype, MOVETYPE_NONE );
        engfunc( EngFunc_SetSize, ent, MEDKIT_MINSZ, MEDKIT_MAXSZ );
        engfunc( EngFunc_DropToFloor, ent );
	
	/* --| If cvar is set to 1, let's glow the entity */
        if( get_pcvar_num( gToggleGlowShow ) == 1 )
        {
		fm_set_rendering( ent, kRenderFxGlowShell, 255, 255, 255, kRenderFxNone, 27 );
        }
	
        return PLUGIN_HANDLED;
}

/* --| Calling the touch forward from fakemeta to see if player touched the entity */  
public ForwardTouch( ent, id )
{
	/* --| Check if is a valid entity and is plugin enabled */
        if( !pev_valid( ent ) || get_pcvar_num( gToggleKitEnable ) == 0 )
        {
		return FMRES_IGNORED;
        }
	
	/* --| Find the ent classname */
        new classname[ 32 ];
        pev( ent, pev_classname, classname, charsmax( classname ) );
	
	/* --| Check if isn't our classname */
        if( !equal( classname, gMedKitClassname ) )
        {
		return FMRES_IGNORED;
        }
	
	/* --| Get the user health, and check some cvars */
        new health = get_user_health( id );
        new cvarhealth = get_pcvar_num( gKitHealthCvar );
        new maxhealth = get_pcvar_num( gLimitHealthCvar );
	
	/* --| Check player health */
        if( health >= maxhealth )
        {
		client_print( id, print_center, "Sorry, your health is %d. You can't take the kit! You must have less then %d to take it.", health, maxhealth ); 
		return FMRES_IGNORED;
        }

	/* --| Show a red hud message to client */
        set_hudmessage( 255, 0, 0, -1.0, 0.83, 2, 6.0, 3.0 );
        show_hudmessage( id, "You received %d HP", cvarhealth );
	
	/* Set the health and show some minor things, for fun */
        fm_set_user_health( id, health + cvarhealth );
        emit_sound( id, CHAN_ITEM, SOUND_KIT, VOL_NORM, ATTN_NORM ,0 , PITCH_NORM );
        
	/* --| Show the healthkit item on hud */
        message_begin( MSG_ONE_UNRELIABLE, gGMsgItemPickup, _, id );
        write_string( "item_healthkit" );
        message_end();

	/* --| If cvar for fade is enabled, let's create the fade */
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
		message_end();
        }
	
	/* --| Now we need to remove the entity from floor */
        engfunc( EngFunc_RemoveEntity, ent );

        return FMRES_IGNORED;
}

/* --| Round start, we need to check entity and remove it */
public logevent_round_start()
{
	/* --| If cvar to remove ent on round start is enabled, let's remove the ent */
        if( get_pcvar_num( gToggleRemoveAtRstart ) == 1 )
        {
		new hkit = FM_NULLENT;
		while( ( hkit = fm_find_ent_by_class( hkit, gMedKitClassname ) ) )
		{
			engfunc( EngFunc_RemoveEntity, hkit );
		}
	}	
}

/* --| End of plugin */