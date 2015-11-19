/*	Copyright © 2009, tuty
	All Snipers Crosshair is free software;
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

/* --| Force the semicolon on every end line */
#pragma semicolon 1

/* --| Plugin information */
#define PLUGIN 		"All Snipers Crosshair"
#define VERSION 	"3.1"
#define AUTHOR 		"tuty"

/* --| Globals */
new gEnabled;
new gMsgCrosshair;

/* --| Starting the plugin */
public plugin_init()
{
	/* --| Registering the plugin to show on plugin list */
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	/* --| Register the cur weapon event to catch snipers */
        register_event( "CurWeapon", "Event_CurWeapon_Snipers", "be", "1=1", "2=3", "2=13", "2=18", "2=24" );
        
	/* --| Cvar and catch the message id */
        gEnabled = register_cvar( "snipers_crosshair", "1" );
        gMsgCrosshair = get_user_msgid( "Crosshair" );
}
    
/* --| Let's check for our sniper weapons and show the crosshair */
public Event_CurWeapon_Snipers( id )
{
	/* --| If plugin is enabled, let's show the crosshair */
        if( get_pcvar_num( gEnabled ) == 1 )
        {
		/* --| Show the crosshair */
		show_crosshair( id, 1 );
        }
}
    
/* --| Stock for setting the crosshair status. 1 - on, 0 - off */  
stock show_crosshair( index, status )
{
        message_begin( MSG_ONE_UNRELIABLE, gMsgCrosshair, _, index );
        write_byte( status );
        message_end();
}

/* --| End of plugin */