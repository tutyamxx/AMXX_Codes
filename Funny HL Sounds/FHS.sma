
    #include <amxmodx>
    #include <amxmisc>
    #pragma semicolon 1

    #define MAX_HLSOUNDS	97

    #define PLUGIN_NAME		"Funny HL Sounds Menu"
    #define PLUGIN_VERSION	"2.0"

    new const gMenuItem[ MAX_HLSOUNDS ][ 111 ];
    new const gCommandSound[ MAX_HLSOUNDS ][ 50 ];

    new giNum;
    new gPluginEnabled;
    new gAdminOnly;
    new gSoundsDelay;
    new gAdvertiseTime;
    new gEnableAdvertise;
    new Float:gLastUsed[ 33 ];

    public plugin_init()
    {
        register_plugin( PLUGIN_NAME, PLUGIN_VERSION, "tuty" );

        register_clcmd( "fhsmenu", "ShowDamnMenu" );
        register_clcmd( "say /fhshelp", "ShowDamnHelp" );
        register_clcmd( "say_team /fhshelp", "ShowDamnHelp" );
	
        gPluginEnabled = register_cvar( "fhs_enabled", "1" );
        gAdminOnly = register_cvar( "fhs_admin", "0" );
        gEnableAdvertise = register_cvar( "fhs_advertise", "1" );
        gSoundsDelay = register_cvar( "fhs_delay", "10" );
        gAdvertiseTime = register_cvar( "fhs_advertise_time", "7" );

        register_dictionary( "FHS.txt" );
    }
    
    
    public plugin_cfg()
    {
        new szConfigDir[ 64 ], iFile[ 64 ];

        get_configsdir( szConfigDir, charsmax( szConfigDir ) );
        formatex( iFile, charsmax( iFile ), "%s/FHS.ini", szConfigDir );
	
        if( !file_exists( iFile ) )
        {
            write_file( iFile, " ", -1 );
            server_print( "File '%s' doesn't exist. Creating one now.", iFile );
        }
	
        new szBuffer[ 128 ];
        new szFile = fopen( iFile, "rt" );

        while( !feof( szFile ) )
        {
            fgets( szFile, szBuffer, charsmax( szBuffer ) );

            if( szBuffer[ 0 ] == '#' )
            {
                continue;
            }
		
            parse( szBuffer, gMenuItem[ giNum ], sizeof gMenuItem[] - 1, gCommandSound[ giNum ], sizeof gCommandSound[] - 1 );
            giNum++;
		
            if( giNum >= MAX_HLSOUNDS )
            {
                break;
            }
        }

        fclose( szFile );
    }
    
    
    public client_putinserver( id )
    {
        if( get_pcvar_num( gPluginEnabled ) != 0 && get_pcvar_num( gEnableAdvertise ) != 0 )
        {
            set_task( float( get_pcvar_num( gAdvertiseTime ) ), "showAdvertiseMessage", id );
        }
    }
    
    
    public showAdvertiseMessage( id )
    {
        client_print( id, print_chat, "[FHS] %L", id, "FHS_ADVERTISE_1" );
        client_print( id, print_chat, "[FHS] %L", id, "FHS_ADVERTISE_2" );
    }
    
    
    public ShowDamnHelp( id )
    {
        if( get_pcvar_num( gPluginEnabled ) == 0 )
        {
            client_print( id, print_chat, "[FHS] %L", id, "FHS_DISABLED" );
            return PLUGIN_CONTINUE;
        }
	
        const SIZE = 1024;
        new msg[ SIZE + 1 ], len = 0;

        len += formatex( msg[ len ], SIZE - len, "<html><body bgcolor=^"black^">" );
        len += formatex( msg[ len ], SIZE - len, "<center><font color=^"white^"><b><h1>%L</h1></b></font></center><br/><br/><br/>", id, "FHS_TITLE" );
        len += formatex( msg[ len ], SIZE - len, "<center><font color=^"white^"><b> %L</b></font></center><br/>", id, "FHS_MOTD_LN1" );
        len += formatex( msg[ len ], SIZE - len, "<center><font color=^"white^"><b> %L.</b></font></center><br/>", id, "FHS_MOTD_LN2" );
        len += formatex( msg[ len ], SIZE - len, "<center><font color=^"white^"><b> %L.</b></font></center><br/>", id, "FHS_MOTD_LN3" );
        len += formatex( msg[ len ], SIZE - len, "<center><font color=^"white^"><b> %L.</b></font></center>", id, "FHS_MOTD_LN4" );
        len += formatex( msg[ len ], SIZE - len, "</body></html>" );
	
        show_motd( id, msg, "Funny HL Sounds HELP" );

        return PLUGIN_CONTINUE;
    }	

	
    public ShowDamnMenu( id )
    {
        if( get_pcvar_num( gPluginEnabled ) == 0 )
        {
            client_print( id, print_chat, "[FHS] %L", id, "FHS_DISABLED" );
            return PLUGIN_HANDLED;
        }
	
        if( get_pcvar_num( gAdminOnly ) == 1 )
        {
            if( !is_user_admin( id ) )
            {
                client_print( id, print_chat, "[FHS] %L", id, "FHS_ADMIN_ONLY" );
                return PLUGIN_HANDLED;
            }
        }
	
        new idString[ 4 ];
        new menu = menu_create( "\rFunny HL Sounds", "menu_handle" );

        for( new i = 0; i < MAX_HLSOUNDS; i++ )
        {
            num_to_str( i, idString, charsmax( idString ) );
            menu_additem( menu, gMenuItem[ i ], idString );
        }

        menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
        menu_display( id, menu );

        return PLUGIN_HANDLED;
    }
    
    
    public menu_handle( id, menu, item )
    {
        if( item >= 0 ) 
        {
            new access, callback, idString[ 4 ];
            menu_item_getinfo( menu, item, access, idString, charsmax( idString ), _, _, callback );
		
            new i = str_to_num( idString );	
		
            new menu, newmenu, page;
            player_menu_info( id, menu, newmenu, page );
		
            new Float:fGameTime = get_gametime();
            new iTime = get_pcvar_num( gSoundsDelay );

            if( fGameTime - gLastUsed[ id ] < iTime )
            {
                client_print( id, print_chat, "[FHS] %L", id, "FHS_WAIT", iTime );
                menu_display( id, menu, page );

                return PLUGIN_HANDLED;
            }

            gLastUsed[ id ] = fGameTime;

            client_cmd( 0, "speak ^"%s.wav^"", gCommandSound[ i ] );
            menu_display( id, menu, page );
        }
	
        return PLUGIN_HANDLED;	
    }
