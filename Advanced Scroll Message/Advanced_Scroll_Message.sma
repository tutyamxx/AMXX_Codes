
    /* AMX Mod X script.
    *
    *   Advanced ScrollMessage With More Cvars
    *   Copyright (C) 2009 tuty
    *   Original author AMXX Dev Team
    *
    *   This program is free software; you can redistribute it and/or
    *   modify it under the terms of the GNU General Public License
    *   as published by the Free Software Foundation; either version 2
    *   of the License, or (at your option) any later version.
    *
    *   This program is distributed in the hope that it will be useful,
    *   but WITHOUT ANY WARRANTY; without even the implied warranty of
    *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    *   GNU General Public License for more details.
    *
    *   You should have received a copy of the GNU General Public License
    *   along with this program; if not, write to the Free Software
    *   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    *
    *   In addition, as a special exception, the author gives permission to
    *   link the code of this program with the Half-Life Game Engine ("HL
    *   Engine") and Modified Game Libraries ("MODs") developed by Valve,
    *   L.L.C ("Valve"). You must obey the GNU General Public License in all
    *   respects for all of the code used other than the HL Engine and MODs
    *   from Valve. If you modify this file, you may extend this exception
    *   to your version of the file, but you are not obligated to do so. If
    *   you do not wish to do so, delete this exception statement from your
    *   version.
    *
    */

    #include <amxmodx>
    #include <amxmisc>

    #define PLUGIN_NAME     "Advanced Scroll Message"
    #define PLUGIN_AUTHOR   "AMXX Dev Team / tuty"

    #define SPEED 0.3
    #define SCROLLMSG_SIZE	512
    #pragma semicolon 1

    new gStartPosition;
    new gEndPosition;
    new gScrollMsg[ SCROLLMSG_SIZE ];
    new gDisplayMsg[ SCROLLMSG_SIZE ];
    new gLength;
    new gFrequency;
    new gMessageColor;
    new gScrollMsgMode;
    new gHostnameP;
    new Float:gX_Position;

    public plugin_init()
    {
        register_plugin( PLUGIN_NAME, AMXX_VERSION_STR, PLUGIN_AUTHOR );
        register_dictionary( "scrollmsg.txt" );
        register_dictionary( "common.txt" );
        register_srvcmd( "amx_scrollmsg", "setMessage" );
        gScrollMsgMode = register_cvar( "amx_scrollmessage_mode", "1" );		 // 1 default, 2 random colors, 3 color controled by cvar 4 random colors on every new message...
        gMessageColor = register_cvar( "amx_scrollmessage_color", "0 0 255" );	 // RGB format (use spaces)
        gHostnameP = get_cvar_pointer( "hostname" );
    }
    
    
    public showMsg()
    {
        new a = gStartPosition;
        new i = 0;
        
        while( a < gEndPosition )
        {
            gDisplayMsg[ i++ ] = gScrollMsg[ a++ ];
        }
	
        gDisplayMsg[ i ] = 0;
	
        if( gEndPosition < gLength )
        {
            gEndPosition++;
        }
        
        if( gX_Position > 0.35 )
        {
            gX_Position -= 0.0063;
        }
        
        else
        {
            gStartPosition++;
            gX_Position = 0.35;
        }
        
        new r, g, b;
        switch( get_pcvar_num( gScrollMsgMode ) )
        {
            case 1: 
            {
                r = 200;
                g = 100;
                b = 0;
            }
            
            case 2:
            {
                r = random( 255 );
                g = random( 255 );
                b = random( 255 );
            }
            
            case 3:
            {
                new Color[ 10 ], rgb[ 3 ][ 4 ];
                get_pcvar_string( gMessageColor, Color, charsmax(Color) );
                
                parse( Color, rgb[ 0 ], 3 , rgb[ 1 ], 3 , rgb[ 2 ], 3 );
                r = clamp( str_to_num( rgb[ 0 ] ) , 0, 255 );
                g = clamp( str_to_num( rgb[ 1 ] ) , 0, 255 );
                b = clamp( str_to_num( rgb[ 2 ] ) , 0, 255 );
            }	
        }
		
        set_hudmessage( r, g, b, gX_Position, 0.90, 0, SPEED, SPEED, 0.05, 0.05, 2 );
        show_hudmessage( 0, "%s", gDisplayMsg );
    }
    
    
    public msgInit()
    {
        gEndPosition = 1;
        gStartPosition = 0;
        gX_Position = 0.65;
	
        new hostname[ 64 ];
        get_pcvar_string( gHostnameP, hostname, charsmax( hostname ) );
        replace( gScrollMsg, SCROLLMSG_SIZE - 1, "%hostname%", hostname );
	
        gLength = strlen( gScrollMsg );
	
        set_task( SPEED, "showMsg", 123, "", 0, "a", gLength + 48 );
        console_print(0, "%s", gScrollMsg );
    }
    
    
    public setMessage()
    {
        remove_task( 123 );		
        read_argv( 1, gScrollMsg, SCROLLMSG_SIZE - 1 );
        gLength = strlen( gScrollMsg );
	
        new MyTime[ 32 ];
        read_argv( 2, MyTime, charsmax( MyTime ) );
        gFrequency = str_to_num( MyTime );
        
        if( gFrequency > 0 )
        {
            new Minimal = floatround( ( gLength + 48 ) * ( SPEED + 0.1 ) );
            
            if( gFrequency < Minimal )
            {
                server_print( "%L", LANG_SERVER, "MIN_FREQ", Minimal );
                gFrequency = Minimal;
            }  
            
            server_print( "%L", LANG_SERVER, "MSG_FREQ", gFrequency / 60, gFrequency % 60 );
            set_task( float( gFrequency ), "msgInit", 123, "", 0, "b" );
        }
        
        else
        {
            server_print( "%L", LANG_SERVER, "MSG_DISABLED" );
        }
        
        return PLUGIN_HANDLED;
    }
