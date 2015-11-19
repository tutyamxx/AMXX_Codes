
    #include <amxmodx>
    #include <amxmisc>
    #include <cstrike>
    
    #pragma semicolon 1

    #define PLUGIN	"[POST] MESSAGE TYPE"
    #define VERSION	"2.0"
    #define AUTHOR	"tuty"

    #define ADVERTISE_TIME	10.0

    new gPluginOn;
    new gAvertise;
    new gMessageCost;
    new gMessageSayText;
    new gMaxPlayers;

    public plugin_init()
    {
        register_plugin( PLUGIN, VERSION, AUTHOR );
        gPluginOn = register_cvar( "amx_postmessage", "1" ); 		
        gAvertise = register_cvar( "amx_postmessage_avertise", "1" );	
        gMessageCost = register_cvar( "amx_postmessage_cost", "10" ); 
        
        register_clcmd( "say", "hook_say_cmd" );
        register_clcmd( "say_team", "hook_say_cmd" );
        
        gMessageSayText = get_user_msgid( "SayText" );
        gMaxPlayers = get_maxplayers();
        register_dictionary( "postmessage.txt" );
    }
    
    
    public client_putinserver( id )
    {
        if( get_pcvar_num( gAvertise ) == 1 )
        {
            set_task( ADVERTISE_TIME, "show_message", id );
        }
    }
    
    
    public hook_say_cmd( id )
    {
        new check_prefix[ 6 ];
        read_argv( 1, check_prefix, charsmax( check_prefix ) );
	
        if( !equal( check_prefix, "/POST ", 5 ) )
        {
            return PLUGIN_CONTINUE;
        }
		
        if( !get_pcvar_num( gPluginOn ) )
        {
            client_print( id, print_chat, "%L", id, "MESSAGE_DISABLED" );
            return PLUGIN_HANDLED;
        }
        
        new said[ 256 ], name[ 32 ];
        read_args( said, charsmax( said ) );  
        remove_quotes( said );
        trim( said );
        replace( said, charsmax( said ), check_prefix, "" ); 
	
        get_user_name( id, name , charsmax( name ) ); 
        
        if( !is_user_alive( id ) )
        {
            client_print( id, print_chat, "%L", id, "NOT_ALIVE" );
            return PLUGIN_HANDLED;
        }
        
        new money = cs_get_user_money( id );
        new cost = get_pcvar_num( gMessageCost );
        
        if( money < cost )
        {
            client_print( id, print_chat, "%L", id, "DONT_HAVE_MONEY" );
            return PLUGIN_HANDLED;
        }
        
        color_print( 0, "^x01[%s]^x04 [ %s ]: [ %s ]", (get_user_team(id) == 1) ? "T" : "CT" , name, said );
        cs_set_user_money( id, money - cost, 1 );
        return PLUGIN_HANDLED;
    }
    
    
    public show_message( id )
    {
        client_print( id, print_chat, "%L", id, "ADVERTISE_MESSAGE" );
        client_print( id, print_chat, "%L", id, "ADVERTISE_MESSAGE2", get_pcvar_num( gMessageCost ) );
        console_print( id, "%L", id, "ADVERTISE_MESSAGE" );
        console_print( id, "%L", id, "ADVERTISE_MESSAGE2", get_pcvar_num( gMessageCost ) );
    }
    
    
    stock color_print( id, const message[], { Float, Sql, Result,_}:... )
    {
        new Buffer[ 128 ], Buffer2[ 128 ];
        formatex(Buffer2, charsmax( Buffer2 ), "%s", message );
        vformat( Buffer, charsmax( Buffer ), Buffer2, 3 );
        
        if( id )
        {
     		message_begin( MSG_ONE_UNRELIABLE, gMessageSayText, _, id );
    		write_byte( id );
     		write_string( Buffer );
      		message_end();
        }
        
        else
        {
     		for( new i = 1; i <= gMaxPlayers; i++ )
      		{

         		if( !is_user_connected( i ) )
                {
            		continue;
                }
				
         		message_begin( MSG_ONE_UNRELIABLE, gMessageSayText, _, i );
         		write_byte( i );
         		write_string( Buffer );
         		message_end();
            }
        }
    }
