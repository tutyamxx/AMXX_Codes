
    #include <amxmodx>
    #include <amxmisc>
    #include <fakemeta>
    #include <fakemeta_util>
    #include <esfmodels>

    /*
    Credits: hip_hop_x
         jim_yang
    */

    #define PLUGIN_NAME     "ESF Mr. Satan"
    #define PLUGIN_VERSION  "1.4a"
    #define PLUGIN_AUTHOR   "tuty"

    #define TRANSFORM_SOUND "satan/w_1.wav"
    #define TRANSFORM_NO    "satan/s_3.wav"
    #define TRAIL_SPR       "sprites/laserbeam.spr"
    #define TRANSFORM_SPR   "sprites/spotlight01.spr"

    #define esf_set_powerlevel(%1,%2)   set_pdata_int(%1, 460, %2)
    #define esf_get_powerlevel(%1)  get_pdata_int(%1, 460)
    #define esf_set_ki(%1,%2)   set_pev(%1, pev_fuser4, float(%2))

    new 
    enabledcvar, satanki, satanhealth, 
    satanpowerlevel, minimumpl, trailspr, transform;
    
    new is_user_satan[ 33 ];

    public plugin_init()
    {
        register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
        register_cvar( "esf_satan_version", PLUGIN_VERSION, FCVAR_SERVER );
        register_forward( FM_PlayerPostThink, "fw_pt", 0 );
        register_event( "ResetHUD", "event_hud_reset", "be" );
        register_event( "DeathMsg", "reset_model", "b" );
        register_message( get_user_msgid( "Powerup" ), "Powerup_Color" );
        
        register_clcmd( "mrsatan", "set_satan" );
        
        enabledcvar = register_cvar( "esf_satan", "1" );
        satanki = register_cvar( "esf_satan_ki", "600" );
        satanhealth = register_cvar( "esf_satan_health", "105" );
        satanpowerlevel = register_cvar( "esf_satan_powerlevel", "1000" );
        minimumpl = register_cvar( "esf_player_minimum_pl", "1000000" );
    }
    
    
    public plugin_precache()
    {
        precache_model( "models/player/satan/satan.mdl" );
        precache_sound( TRANSFORM_SOUND );
        precache_sound( TRANSFORM_NO );
        trailspr = precache_model( TRAIL_SPR );
        transform = precache_model( TRANSFORM_SPR );
    }
    
    
    public client_connect( id )
    {
        is_user_satan[ id ] = false;
    }
    
    
    public client_disconnect( id )
    {	
        is_user_satan[ id ] = false;
    }	
    
    
    public set_satan( id )
    {
        if( get_pcvar_num( enabledcvar ) == 0 || !is_user_alive( id ) || is_user_bot( id ) )
        {
            return PLUGIN_HANDLED;
        }
	
        new PowerLevel = esf_get_powerlevel( id );
        
        if( PowerLevel > get_pcvar_num( minimumpl ) && !is_user_satan[ id ] )
        {
            new power = esf_get_powerlevel( id );
		
            is_user_satan[ id ] = true;
            esf_clear_model( id );
            
            fm_strip_user_weapons( id );
            fm_give_item( id, "weapon_melee" );
            fm_give_item( id, "weapon_sensu" );
            fm_give_item( id, "weapon_solarflare" );
            fm_give_item( id, "weapon_eyelaser" );
            fm_give_item( id, "weapon_scatterbeam" );
            fm_give_item( id, "weapon_burningattack" );
            esf_set_model( id, "models/player/satan/satan.mdl" );
            fm_set_user_health( id, get_pcvar_num( satanhealth ) );
            esf_set_ki( id, get_pcvar_num( satanki ) );
            esf_set_powerlevel( id, get_pcvar_num( satanpowerlevel ) + power - 1 );
            fm_set_rendering( id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 20 );
            esf_transform( id );
            emit_sound( id, CHAN_VOICE, TRANSFORM_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        }
    
        else
        {
            emit_sound( id, CHAN_VOICE, TRANSFORM_NO, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );	
            return PLUGIN_HANDLED;
        }
	
        return PLUGIN_HANDLED;
    }
    
    
    public fw_pt( id ) 
    {
        if( get_pcvar_num( enabledcvar ) == 0 || !is_user_alive( id ) || is_user_bot( id ) )
        {
            return FMRES_IGNORED;
        }   
	
        new model[ 30 ];
        get_user_info( id, "model", model, charsmax( model ) );
	
        new ki = esf_get_ki( id );
        
        if( contain( model, "satan" ) && is_user_satan[ id ] )
        {
            esf_trail( id );
            
            if( ki < 500 )
            {
                esf_set_ki( id, 1000 ); 
            }
        }
        
        return FMRES_IGNORED;
    }
    
    
    public Powerup_Color()
    {
        if( get_pcvar_num( enabledcvar ) == 0 )
        {
            return;
        }

        new id = get_msg_arg_int( 1 );
        
        if( is_user_satan[ id ] )
        {
            set_msg_arg_int( 2, ARG_BYTE, 255 ); 
            set_msg_arg_int( 3, ARG_BYTE, 0 ); 
            set_msg_arg_int( 4, ARG_BYTE, 0 );
        }
        
        return;
    }		
    
    
    public event_hud_reset( id )
    {
        if( get_pcvar_num( enabledcvar ) == 1 )
        {
            is_user_satan[ id ] = false;
            esf_clear_model( id );
        }
    }
    
    
    public reset_model( id )
    {
        if( get_pcvar_num( enabledcvar ) == 1 )
        {
            is_user_satan[ id ] = false;
            fm_set_rendering( id );
            esf_clear_model( id );
        }
    }	
    
    
    stock esf_trail( index )
    {
        message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
        write_byte( TE_BEAMFOLLOW );
        write_short( index );
        write_short( trailspr );
        write_byte( 10 );
        write_byte( 5 );
        write_byte( 255 )
        write_byte( 0 );
        write_byte( 0 );
        write_byte( 90 );
        message_end();
    }
    
    
    stock esf_transform( index )
    {
        new ori[ 3 ];
        get_user_origin( index, ori );

        message_begin( MSG_PVS, SVC_TEMPENTITY, ori );
        write_byte( TE_BEAMCYLINDER );
        write_coord( ori[ 0 ] );
        write_coord( ori[ 1 ] );
        write_coord( ori[ 2 ] + 10 );
        write_coord( ori[ 0 ] );
        write_coord( ori[ 1 ] );
        write_coord( ori[ 2 ] + 10 + 80 );
        write_short( transform );
        write_byte( 0 );
        write_byte( 0 );
        write_byte( 3 );
        write_byte( 60 );
        write_byte( 0 );
        write_byte( 255 );
        write_byte( 0 );
        write_byte( 0 );
        write_byte( 190 );
        write_byte( 0 );
        message_end();
	
        message_begin( MSG_PVS, SVC_TEMPENTITY, ori );
        write_byte( TE_BEAMCYLINDER );
        write_coord( ori[ 0 ] );
        write_coord( ori[ 1 ] );
        write_coord( ori[ 2 ] );
        write_coord( ori[ 0 ] );
        write_coord( ori[ 1 ] );
        write_coord( ori[ 2 ] + 385 );
        write_short( transform );
        write_byte( 0 );
        write_byte( 0 );
        write_byte( 4 );
        write_byte( 60 );
        write_byte( 0 );
        write_byte( 200 );
        write_byte( 100 );
        write_byte( 0 );
        write_byte( 200 );
        write_byte( 0 );
        message_end();

        message_begin( MSG_PVS, SVC_TEMPENTITY, ori );
        write_byte( TE_IMPLOSION );
        write_coord( ori[ 0 ] );
        write_coord( ori[ 1 ] );
        write_coord( ori[ 2 ] );
        write_byte( 255 );
        write_byte( 255 );
        write_byte( 20 );
        message_end();
    }	

    
    stock esf_get_ki( id )
    {
        if( !is_user_alive( id ) )
        {
            return 0;
        }
        
        new Float:value;
        pev( id, pev_fuser4, value );
	
        return floatround( value );
    }
