
    #include <amxmodx>
    #include <esf_util>

    #define PLUGIN_NAME 		"ESF Taunts"
    #define PLUGIN_VERSION 		"1.1"
    #define PLUGIN_AUTHOR 		"tuty"

    new gTauntEnabled;
    new gTauntDelay;
    new Float:gLastTaunt[ 33 ];

    new Buu_Taunts[][] = 
    {
        "t_taunt/buu/btaunt1.wav", "t_taunt/buu/btaunt2.wav", 
        "t_taunt/buu/btaunt3.wav", "t_taunt/buu/btaunt4.wav" 
    };

    
    new Goku_Taunts[][] = 
    {
        "t_taunt/goku/gtaunt1.wav", "t_taunt/goku/gtaunt2.wav", 
        "t_taunt/goku/gtaunt3.wav", "t_taunt/goku/gtaunt4.wav" 
    };

    
    new Gohan_Taunts[][] = 
    {
        "t_taunt/gohan/gotaunt1.wav", "t_taunt/gohan/gotaunt2.wav", 
        "t_taunt/gohan/gotaunt3.wav", "t_taunt/gohan/gotaunt4.wav" 
    };

    
    new Krillin_Taunts[][] = 
    {
        "t_taunt/krillin/ktaunt1.wav", "t_taunt/krillin/ktaunt2.wav", 
        "t_taunt/krillin/ktaunt3.wav", "t_taunt/krillin/ktaunt4.wav" 
    };

    
    new Frieza_Taunts[][] =
    {
        "t_taunt/frieza/ftaunt1.wav", "t_taunt/frieza/ftaunt2.wav",
        "t_taunt/frieza/ftaunt3.wav", "t_taunt/frieza/ftaunt4.wav" 
    };

    
    new Piccolo_Taunts[][] = 
    {
        "t_taunt/piccolo/ptaunt1.wav", "t_taunt/piccolo/ptaunt2.wav", 
        "t_taunt/piccolo/ptaunt3.wav", "t_taunt/piccolo/ptaunt4.wav" 
    };

    new Trunks_Taunts[][] = 
    {
        "t_taunt/trunks/trtaunt1.wav", "t_taunt/trunks/trtaunt2.wav", 
        "t_taunt/trunks/trtaunt3.wav", "t_taunt/trunks/trtaunt4.wav" 
    };
	
    
    new Vegeta_Taunts[][] = 
    {
        "t_taunt/vegeta/vtaunt1.wav", "t_taunt/vegeta/vtaunt2.wav",
        "t_taunt/vegeta/vtaunt3.wav", "t_taunt/vegeta/vtaunt4.wav" 
    };	

    
    new Cell_Taunts[][] = 
    {
        "t_taunt/cell/ctaunt1.wav", "t_taunt/cell/ctaunt2.wav", 
        "t_taunt/cell/ctaunt3.wav", "t_taunt/cell/ctaunt4.wav"
    };
    
	
    public plugin_init()
    {
        register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR );
        register_clcmd( "taunt", "cmdTaunt" );
        gTauntEnabled = register_cvar( "esf_taunt_enabled", "1" );
        gTauntDelay = register_cvar( "esf_taunt_delay", "10.0" );
    }
    
    
    public plugin_precache()
    {
        new i;
        for( i = 0; i < sizeof Buu_Taunts; i++ )
        {
            precache_sound( Buu_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Goku_Taunts; i++ )
        {
            precache_sound( Goku_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Gohan_Taunts; i++ )
        {
            precache_sound( Gohan_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Krillin_Taunts; i++ )
        {
            precache_sound( Krillin_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Frieza_Taunts; i++ )
        {
            precache_sound( Frieza_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Piccolo_Taunts; i++ )
        {
            precache_sound( Piccolo_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Trunks_Taunts; i++ )
        {
            precache_sound( Trunks_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Vegeta_Taunts; i++ )
        {
            precache_sound( Vegeta_Taunts[ i ] );
        }
	
        for( i = 0; i < sizeof Cell_Taunts; i++ )
        {
            precache_sound( Cell_Taunts[ i ] );
        }
    }
    
    
    public cmdTaunt( id )
    {
        if( get_pcvar_num( gTauntEnabled ) == 1 )
        {
            new Float:TauntTime = get_gametime();
		
            if( TauntTime - gLastTaunt[ id ] < get_pcvar_float( gTauntDelay ) )
            {
                return PLUGIN_HANDLED;
            }

            gLastTaunt[ id ] = TauntTime;
		
            switch( esf_get_player_class( id ) )
            {
                case ESF_CLASS_BUU:
                {
                    emit_sound( id, CHAN_VOICE, Buu_Taunts[ random_num( 0, charsmax( Buu_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_GOKU:
                {
                    emit_sound( id, CHAN_VOICE, Goku_Taunts[ random_num( 0, charsmax( Goku_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_GOHAN:
                {
                    emit_sound( id, CHAN_VOICE, Gohan_Taunts[ random_num( 0, charsmax( Gohan_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_KRILLIN:
                {
                    emit_sound( id, CHAN_VOICE, Krillin_Taunts[ random_num( 0, charsmax( Krillin_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_FRIEZA:
                {
                    emit_sound( id, CHAN_VOICE, Frieza_Taunts[ random_num( 0, charsmax( Frieza_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_PICCOLO:
                {
                    emit_sound( id, CHAN_VOICE, Piccolo_Taunts[ random_num( 0, charsmax( Piccolo_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_TRUNKS:
                {
                    emit_sound( id, CHAN_VOICE, Trunks_Taunts[ random_num( 0, charsmax( Trunks_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_VEGETA:
                {
                    emit_sound( id, CHAN_VOICE, Vegeta_Taunts[ random_num( 0, charsmax( Vegeta_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                case ESF_CLASS_CELL:
                {
                    emit_sound( id, CHAN_VOICE, Cell_Taunts[ random_num( 0, charsmax( Cell_Taunts ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }
            }
        }

        return PLUGIN_HANDLED;
    }
