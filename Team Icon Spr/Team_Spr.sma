
    #include <amxmodx>
    #include <amxmisc>

    #define PLUGIN_NAME     "Team Icon Spr"
    #define PLUGIN_VERSION  "1.0.4"
    #define PLUGIN_AUTHOR   "tuty"

    #define CT_SPRITE 	"sprites/teamspr/ct_blue.spr"
    #define T_SPRITE 	"sprites/teamspr/t_red.spr"

    new g_ct_blue_spr;
    new g_t_red_spr;
    new g_sprtime;
    new g_plugin_mode;
    new g_cvarvalue;

    public plugin_init()
    {
        register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
        register_event( "DeathMsg", "remove_spr", "a" );
        register_logevent( "logevent_round_start", 2, "1=Round_Start" );
        register_clcmd( "say /teamspr", "CreateSprite" );
        register_clcmd( "say_team /teamspr", "CreateSprite" );
        register_clcmd( "say /delspr", "RemoveSprite" );
        register_clcmd( "say_team /delspr", "RemoveSprite" );
        g_sprtime = register_cvar( "teamspr_sprite_time", "32767" );
        g_plugin_mode = register_cvar( "teamspr_mode", "1" );
        register_dictionary( "teamspr.txt" );
    }
    
    
    public plugin_precache()
    {
        g_ct_blue_spr = precache_model( CT_SPRITE );
        g_t_red_spr = precache_model( T_SPRITE );
    }
    
    
    public logevent_round_start()
    {
        g_cvarvalue = get_pcvar_num( g_plugin_mode );
        new players[ 32 ], num, i;
        get_players( players, num );
        
        for( i = 0; i < num; i++ ) 
        {
            if( !is_user_alive( players[ i ] ) )
            {
                continue;
            }
		
            switch( g_cvarvalue )
            {
                case 0: return PLUGIN_HANDLED;
                case 1: Remove( players[ i ] );
                case 2:
                {
                    message_begin( MSG_ALL, SVC_TEMPENTITY );
                    write_byte( TE_PLAYERATTACHMENT );
                    write_byte( players[ i ] );
                    write_coord( 45 );
                    write_short( ( get_user_team( players[ i ] ) == 1 ) ? g_t_red_spr : g_ct_blue_spr ); 
                    write_short( get_pcvar_num( g_sprtime ) );
                    message_end();
                }
            }
        }
        
        return PLUGIN_CONTINUE;
    }
    
    
    public CreateSprite( id )
    {
        g_cvarvalue = get_pcvar_num( g_plugin_mode );
        
        if( g_cvarvalue == 0 )
        {
            client_print( id, print_chat, "%L", id, "CANNOT_CREATE" );
            client_cmd( id, "speak buttons/blip1.wav" );
            Remove( id );
            
            return PLUGIN_HANDLED;
        }
        
        else if( g_cvarvalue != 1 )
        {
            client_print( id, print_chat, "%L", id, "ALLREADY_HAVE" );
            client_cmd( id, "speak buttons/blip1.wav" );
            
            return PLUGIN_HANDLED;
        }
        
        message_begin( MSG_ALL, SVC_TEMPENTITY );
        write_byte( TE_PLAYERATTACHMENT );
        write_byte( id );
        write_coord( 45 );
        write_short( ( get_user_team( id ) == 1 ) ? g_t_red_spr : g_ct_blue_spr ); 
        write_short( get_pcvar_num( g_sprtime ) );
        message_end();
	
        client_print( id, print_chat, "%L", id, "SUCCESSFULLY_CREATED" );
        client_cmd( id, "speak fvox/activated.wav" );
        
        return PLUGIN_CONTINUE;
    }
    
    
    public RemoveSprite( id )
    {
        g_cvarvalue = get_pcvar_num( g_plugin_mode );
        
        if( g_cvarvalue == 0 )
        {
            client_print( id, print_chat, "%L", id, "CANNOT_CREATE" );
            client_cmd( id, "speak buttons/blip1.wav" );
            
            return PLUGIN_HANDLED;
        }
        
        else if( g_cvarvalue != 1 )
        {
            client_print( id, print_chat, "%L", id, "MUST_STAY_UP" );
            client_cmd( id, "speak buttons/blip1.wav" );
            
            return PLUGIN_HANDLED;
        }	
        
        Remove( id );
        client_print( id, print_chat, "%L", id, "SUCCESSFULLY_DELETED" );
        client_cmd( id, "speak fvox/deactivated.wav" );
        
        return PLUGIN_CONTINUE;
    }
    
    
    public remove_spr()
    {
        Remove( read_data( 2 ) );
    }
    
    
    stock Remove( index )
    {
        message_begin( MSG_ALL, SVC_TEMPENTITY );
        write_byte( TE_KILLPLAYERATTACHMENTS );
        write_byte( index );
        message_end();
    }
    