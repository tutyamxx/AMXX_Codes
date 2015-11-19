/*	Copyright © 2009, tuty
	ESF Admin Giver is free software;
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
#include <amxmisc>
#include <fakemeta>
#include <fun>



/* --| Plugin information */
#define PLUGIN		"ESF Admin Giver"
#define VERSION		"3.4"
#define AUTHOR		"tuty"

/* --| Plugin defines */
#define ACCESS_LVL	ADMIN_KICK
#define FFADE_IN	0x0000
#define TASK_INFO	10.0
#define SOUND_EAT	"buu/candyeat.wav"

/* --| Globals */
new gMsgFade;
new gEnabled;
new gMaxHealth;
new gHealth;
new ADMINname[ 32 char ];
   
/* --| Max health offset */ 
const i_MaxHealth = 142;

/* --| Start the plugin... */
public plugin_init()
{
	/* --| Register the plugin to show on plugins list */
        register_plugin( PLUGIN, VERSION, AUTHOR );

	/* --| Register the admin commands */
        register_concmd( "esf_givesensubeans", "cmdGiveSensuBeam", ACCESS_LVL, "<name> - give to a player a sensu beam" );
        register_concmd( "esf_giveliferegen", "cmdGiveLife", ACCESS_LVL, "<name> - give to a player fulllife" );
	
	/* --| Catch cvar and some message id's */
        gEnabled = register_cvar( "esf_eag", "1" );
        gMsgFade = get_user_msgid( "ScreenFade" );
        gHealth = get_user_msgid( "MaxHealth" );
	gHealth = get_user_msgid( "Health" );
}
    
/* --| Precache the buu sound */ 
public plugin_precache()
{
        precache_sound( SOUND_EAT );
}
    

/* --| When client joined the game... */ 
public client_putinserver( id )
{
	/* --| Check if plugin is enabled. */
        if( get_pcvar_num( gEnabled ) == 1 )
        {
		/* --| Set a little task to show info about plugin */
		set_task( TASK_INFO, "show_info", id );
        }
}
    
/* --| Command for giving the sensu beans to targer */  
public cmdGiveSensuBeam( id, level, cid )
{
	/* --| Check for access and cvar */
        if( !cmd_access( id, level, cid, 2 ) || get_pcvar_num( gEnabled ) == 0 )
        {
		return PLUGIN_HANDLED;
        }
	
	/* --| Read the admin argument.. */
        new argument[ 32 ];
        read_argv( 1, argument, charsmax( argument ) );
        
	/* --| Check for target */
        new player = cmd_target( id, argument, charsmax( argument ) );
	
	/* --| Check if is not a valid target... */
        if( !player ) 
        {
		return PLUGIN_HANDLED;
        }
	
	/* --| Get the admin name */
        get_user_name( id, ADMINname, charsmax( ADMINname ) );
	
	/* --| Show print to target */
        client_print( player, print_chat, "[ESF AG] You got a SensuBeam Bag from Admin: %s", ADMINname );
        console_print( player, "[ESF AG] You got a SensuBeam Bag from Admin: %s", ADMINname );
        
	/* --| We need to give the sensu weapon to player :| */
        give_item( player, "weapon_sensu" );

	/* --| And not give the sensu beans */
        give_item( player, "item_sensubeanbag" );
        give_item( player, "item_sensubeanbag" );
        
	/* --| Emit a sound and set a effect to target */
        emit_sound( player, CHAN_VOICE, SOUND_EAT, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        green_fade( id );
	
        return PLUGIN_HANDLED;
}

/* --| Command for giving player health */
public cmdGiveLife( id, level, cid )
{
	/* --| Check for access and cvar */
        if( !cmd_access( id, level, cid, 2 ) || get_pcvar_num( gEnabled ) == 0 )
        {
		return PLUGIN_HANDLED;
        }

	/* --| Read the admin argument.. */
        new argument[ 32 ];
        read_argv( 1, argument, charsmax( argument ) );
        
	/* --| Check for target */
        new player = cmd_target( id, argument, charsmax( argument ) );
	
	/* --| Check if is not a valid target... */
        if( !player ) 
        {
		return PLUGIN_HANDLED;
        }
	
	/* --| Get the admin name */
        get_user_name( id, ADMINname, charsmax( ADMINname ) );
	
	/* --| Show print to target */
        client_print( player, print_chat, "[ESF AG] You got a FullLife and Regeneration Weapon from Admin: %s", ADMINname );
        console_print( player, "[ESF AG] You got a FullLife and Regeneration Weapon from Admin: %s", ADMINname );
        
	/* --| Set target health to 1000 */
        esf_set_maxhealth( player, 1000 );
        set_user_health( player, 1000 );

	/* --| Emit a sound */
        emit_sound( player, CHAN_VOICE, SOUND_EAT, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
        return PLUGIN_HANDLED;
}
    
/* --| Show the information from task */    
public show_info( id )
{
        client_print( id, print_chat, "-=[ ESF AG ]=-  -= [ This server running Earth Special Forces Admin Giver v%s ]=-  -= [ by %s ] =-", VERSION, AUTHOR );
}
    
/* --| Plugin stocks */
/* --| Stock for player screenfade */  
stock green_fade( index )
{
	message_begin( MSG_ONE_UNRELIABLE, gMsgFade , _, index );
        write_short( 1<<10 );
        write_short( 1<<10 );
        write_short( FFADE_IN );
        write_byte( 0 );
        write_byte( 255 );  
        write_byte( 0 );  
        write_byte( 100 );
        message_end();
}
    
/* --| Usefull stock for setting player maxhealth and health on hud */  
stock esf_set_maxhealth( index, health )
{
        set_pdata_int( index, i_MaxHealth, health );

        message_begin( MSG_ONE_UNRELIABLE, gMaxHealth, _, index );
        write_byte( health );
        message_end();
	
	message_begin( MSG_ONE_UNRELIABLE, gHealth, _, index );
	write_byte( health );
        message_end();
}

/* --| End of plugin */