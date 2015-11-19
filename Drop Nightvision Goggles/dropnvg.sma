
    #include <amxmodx>
    #include <fakemeta>

    #define PLUGIN_NAME     "Drop Nvg"
    #define PLUGIN_VERSION  "3.1"
    #define PLUGIN_AUTHOR   "tuty"

    #define MINSZ		Float:{ -23.160000, -13.660000, -0.050000 }
    #define MAXSZ		Float:{ 11.470000, 12.780000, 6.720000 }
    #define HAS_NVGS		(1<<0)
    #define USES_NVGS		(1<<8)
    #define NVG_MODEL		"models/w_nvg.mdl"
    #define PICKUP_SOUND 	"items/gunpickup2.wav"
    #define SOUND_NVGOFF 	"items/nvg_off.wav"
    #define SOUND_DROPNVG	"common/bodydrop2.wav"
    #define get_user_nvg(%1)    (get_pdata_int(%1,OFFSET_NVGOGGLES) & HAS_NVGS)
    
    new bHasNVG[ 33 ];
    new gDropNvg;
    new gMessageNVG;
    new gEnableHud;
    new gDropOnDie;
    
    const OFFSET_NVGOGGLES = 129;
    const LINUX_OFFSET_DIFF = 5;

    new const gNVGClassname[] = "nvg_box";
    new Float:gRenderColor[ 3 ] = { 34.0, 139.0, 34.0 };

    public plugin_init()
    {
        register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
        register_forward( FM_Touch, "ForwardTouch" );
        register_logevent( "logevent_round_start", 2, "1=Round_Start" );
        register_event( "DeathMsg","drop_nvg","a" );
        register_clcmd( "dropnvg", "CommandDropNvg" );

        gDropNvg = register_cvar( "drop_nvg", "1" );
        gEnableHud = register_cvar( "drop_nvg_hud", "1" );
        gDropOnDie = register_cvar( "drop_nvg_on_death", "1" );

        gMessageNVG = get_user_msgid( "NVGToggle" );
        register_dictionary( "dropnvg.txt" );
    }
    
    
    public plugin_precache()
    {
        precache_model( NVG_MODEL );
        precache_sound( PICKUP_SOUND );
        precache_sound( SOUND_NVGOFF );
        precache_sound( SOUND_DROPNVG );
    }	
    
    
    public CommandDropNvg( id )
    {
        if( !get_pcvar_num( gDropNvg ) )
        {
            client_print( id, print_center, "%L", id, "CANNOT_DROP_NVG" );
            return PLUGIN_HANDLED;
        }

        if( !is_user_alive( id ) )
        {
            client_print( id, print_center, "%L", id, "MUST_BE_ALIVE" );
            return PLUGIN_HANDLED;
        }

        if( !get_user_nvg( id ) )
        {
            client_print( id, print_center, "%L", id, "DONT_HAVE_NVG" );
            return PLUGIN_HANDLED;
        }

        set_user_nvg( id, 0 );

        new Float:iVelocity[ 3 ], Float:iOrigin[ 3 ];
        velocity_by_aim( id, random_num( 99, 201 ), iVelocity ); 
        pev( id, pev_origin, iOrigin );

        iOrigin[ 0 ] += iVelocity[ 0 ];
        iOrigin[ 1 ] += iVelocity[ 1 ];
	
        new nvgent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
        set_pev( nvgent, pev_classname, gNVGClassname );
        engfunc( EngFunc_SetModel, nvgent, NVG_MODEL );
        engfunc( EngFunc_SetSize, nvgent, MINSZ, MAXSZ );
        set_pev( nvgent, pev_solid, SOLID_BBOX );
        set_pev( nvgent, pev_movetype, MOVETYPE_TOSS );
        set_pev( nvgent, pev_origin, iOrigin );
        engfunc( EngFunc_DropToFloor, nvgent );
        emit_sound( id, CHAN_WEAPON, SOUND_DROPNVG, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
	
        bHasNVG[ id ] = false;
        set_rendering( nvgent, kRenderFxGlowShell, gRenderColor, kRenderNormal, 70.0 );
        remove_user_nvg( id );
        client_print( id, print_center, "%L", id, "NVG_ON_FLOOR" );

        return PLUGIN_HANDLED;
    }
    
    
    public ForwardTouch( ent, id )
    {
        if( !get_pcvar_num( gDropNvg )  || !pev_valid( ent ) )
        {
            return FMRES_IGNORED;
        }

        new Classname[ 32 ];
        pev( ent, pev_classname, Classname, charsmax( Classname ) );

        if( equal( Classname, gNVGClassname ) )
        {
            if( get_user_nvg( id ) )
            {
                client_print( id, print_center, "%L", id, "ALLREADY_HAVE_NVG" );
                return FMRES_IGNORED;
            }
    
            bHasNVG[ id ] = true; 
            set_user_nvg( id, 1 );

            client_print( id, print_center, "%L", id, "PICK_UP_NVG" );
            emit_sound( id, CHAN_WEAPON, PICKUP_SOUND, VOL_NORM , ATTN_NORM , 0 , PITCH_NORM );
            set_pev( ent, pev_flags, FL_KILLME );
        }

        return FMRES_IGNORED;
    }
    
    
    public logevent_round_start()
    {
        if( get_pcvar_num( gDropNvg ) == 1 )
        {
            new nvgent = FM_NULLENT;
            while( ( nvgent = engfunc( EngFunc_FindEntityByString, nvgent, "classname", gNVGClassname ) ) )
            {
                set_pev( nvgent, pev_flags, FL_KILLME );
            }
        }
    }
    
    
    public drop_nvg()
    {
        new id = read_data( 2 );

        if( get_pcvar_num( gDropOnDie ) != 0 )
        {
            if( get_user_nvg( id ) )
            {
                new Float:iOrigin[ 3 ];
                pev( id, pev_origin, iOrigin );
	
                new nvgent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
                iOrigin[ 2 ] -= 36; 
                engfunc( EngFunc_SetOrigin, nvgent, iOrigin );
	
                if( !pev_valid( nvgent ) )
                {
                    return PLUGIN_HANDLED;
                }

                engfunc( EngFunc_SetModel, nvgent, NVG_MODEL );
                set_pev( nvgent, pev_classname, gNVGClassname );
                dllfunc( DLLFunc_Spawn, nvgent );
                set_pev( nvgent, pev_solid, SOLID_BBOX );
                set_pev( nvgent, pev_movetype, MOVETYPE_NONE );
                engfunc( EngFunc_SetSize, nvgent, MINSZ, MAXSZ );
                engfunc( EngFunc_DropToFloor, nvgent );
                bHasNVG[ id ] = false;
                set_rendering( nvgent, kRenderFxGlowShell, gRenderColor, kRenderNormal, 70.0 );
                remove_user_nvg( id ); 
            }
        }
        
        return PLUGIN_HANDLED;
    }
    
    
    public client_putinserver( id )
    {
        if( get_pcvar_num( gEnableHud ) == 1 )
        {
            set_task( 14.0, "ShowHudInfo", id );
        }
    }
    
    
    public ShowHudInfo( id )
    {
        set_hudmessage( 255, 170, 0, -1.0, 0.10, 1, 6.0, 12.0 );
        show_hudmessage( id, "%L", id, "INFO_HUD_NVG" );
    }
    
    
    stock set_user_nvg( index, nvgoggles = 1 )
    {
        if( nvgoggles )
        {
            set_pdata_int( index, OFFSET_NVGOGGLES, get_pdata_int( index, OFFSET_NVGOGGLES ) | HAS_NVGS );
        }

        else
        {
            set_pdata_int( index, OFFSET_NVGOGGLES, get_pdata_int( index, OFFSET_NVGOGGLES ) & ~HAS_NVGS );
        }
    }
    
    
    stock remove_user_nvg( index )
    {
        new iNvgs = get_pdata_int( index, OFFSET_NVGOGGLES, LINUX_OFFSET_DIFF );

        if( !iNvgs )
        {
            return;
        }

        if( iNvgs & USES_NVGS )
        {
            emit_sound( index, CHAN_ITEM, SOUND_NVGOFF, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

            emessage_begin( MSG_ONE_UNRELIABLE, gMessageNVG, _, index );
            ewrite_byte( 0 );
            emessage_end();
        }

        set_pdata_int( index, OFFSET_NVGOGGLES, 0, LINUX_OFFSET_DIFF );
    }  
    
    
    stock set_rendering( iEnt, iRenderFx=kRenderFxNone, Float:flRenderColor[3]={255.0,255.0,255.0}, iRender=kRenderNormal, Float:flAmount=16.0 )
    {
    	set_pev( iEnt, pev_renderfx, iRenderFx );
    	set_pev( iEnt, pev_rendercolor, flRenderColor );
        set_pev( iEnt, pev_rendermode, iRender );
    	set_pev( iEnt, pev_renderamt, flAmount );
    } 
