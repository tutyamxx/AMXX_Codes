
    #include <amxmodx>
    #include <amxmisc>
    #include <fun>
    #include <fakemeta>

    #define PLUGIN 			"Half Life Give Items And Weapons"
    #define VERSION 		"2.0"
    #define AUTHOR 			"tuty"

    #define ACCESS_LEVEL		ADMIN_LEVEL_A

    #define RPG_BPAMMO_OFFSET			315
    #define TRIPMINE_BPAMMO_OFFSET		317
    #define SATCHEL_BPAMMO_OFFSET		318
    #define HORNET_BPAMMO_OFFSET		321
    #define GRENADE_BPAMMO_OFFSET		319
    #define SNARK_BPAMMO_OFFSET			320	
    #define PYTHON_BPAMMO_OFFSET		313
    #define CROSSBOW_BPAMMO_OFFSET		316
    #define GAUSS_EGON_BPAMMO_OFFSET		314	
    #define SHOTGUN_BPAMMO_OFFSET		310 	
    #define GLOCK_MP5_9MM_BPAMMO_OFFSET		311 
    #define CHAINGUN_BPAMMO_OFFSET		312

    public plugin_init()
    {
        register_plugin( PLUGIN, VERSION, AUTHOR );
        register_concmd( "hl_weapon", "cmdGiveWeapon", ACCESS_LEVEL, "<name> <weapon / @ALL> - give player a weapon | @ALL = all weapons" );
        register_concmd( "hl_item", "cmdGiveItem", ACCESS_LEVEL, "<name> <item / @ALL> - give player a item | @ALL = all items" );
    }
    
    
    public cmdGiveWeapon( id, level, cid )
    {
        if( !cmd_access( id, level, cid, 3 ) )
        {
            return PLUGIN_HANDLED;
        }
	
        new arg[ 32 ], wpnarg[ 20 ];
        read_argv( 1, arg, charsmax( arg ) );
        
        new target = cmd_target( id, arg, charsmax( arg ) );
	
        if( !target )
        {
            return PLUGIN_HANDLED;
        }
	
        read_argv( 2, wpnarg, charsmax( wpnarg ) );

        if( equal( wpnarg, "crowbar" ) )
        {
            give_item( target, "weapon_crowbar" );
        }
        
        else if( equal( wpnarg, "hivehand" ) )
        {
            give_item( target, "weapon_hornetgun" );
            set_user_bpammo( target, HLW_HORNETGUN, 8 );
        }
        
        else if( equal( wpnarg, "python" ) )
        {
            give_item( target, "weapon_python" );
            set_user_bpammo( target, HLW_PYTHON, 36 );
        }
        
        else if( equal( wpnarg, "357" ) )
        {
            give_item( target, "weapon_357" );
            set_user_bpammo( target, HLW_PYTHON, 36 );
        }
        
        else if( equal( wpnarg, "crossbow" ) )
        {
            give_item( target, "weapon_crossbow" );
            set_user_bpammo( target, HLW_CROSSBOW, 50 );
        }
        
        else if( equal( wpnarg, "squeak" ) )
        {
            give_item( target, "weapon_snark");
            set_user_bpammo( id, HLW_SNARK, 15 );
        }
        
        else if( equal( wpnarg, "tripmine" ) )
        {
            give_item( target, "weapon_tripmine" );
            set_user_bpammo( target, HLW_TRIPMINE, 5 );
        }
        
        else if( equal( wpnarg, "satchel" ) )
        {
            give_item( target, "weapon_satchel" );
            set_user_bpammo( target, HLW_SATCHEL, 5 );
        }
        
        else if( equal( wpnarg, "handgrenade" ) )
        {
            give_item( target, "weapon_handgrenade" );
            set_user_bpammo( target, HLW_HANDGRENADE, 10 );
        }   
        
        else if( equal( wpnarg, "9mmhandgun" ) )
        {
            give_item( target, "weapon_9mmhandgun" );
            set_user_bpammo( target, HLW_GLOCK, 250 );
        }
        
        else if( equal( wpnarg, "glock" ) )
        {
            give_item( target, "weapon_glock" );
            set_user_bpammo( target, HLW_GLOCK, 250 );
        }
        
        else if( equal( wpnarg, "9mmAR" ) )
        {
            give_item( target, "weapon_9mmAR" );
            set_user_bpammo( target, HLW_MP5, 250 );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
        }
        
        else if( equal( wpnarg, "gauss" ) )
        {
            give_item( target, "weapon_gauss" );
            set_user_bpammo( target, HLW_GAUSS, 100 );
        }
        
        else if( equal( wpnarg, "mp5gun" ) )
        {
            give_item( target, "weapon_mp5" );
            set_user_bpammo( target, HLW_MP5, 250 );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
        }
        
        else if( equal( wpnarg, "egon" ) )
        {
            give_item( target, "weapon_egon" ); 			   
            set_user_bpammo( target, HLW_EGON, 100 );
        }
        
        else if( equal( wpnarg, "rpgrocket" ) )
        {
            give_item( target, "weapon_rpg" );
            set_user_bpammo( target, HLW_RPG, 5 );
        }
        
        else if( equal( wpnarg, "shotgun" ) )
        {
            give_item( target, "weapon_shotgun" );
            set_user_bpammo( target, HLW_SHOTGUN, 125 );
        }
        
        else if( equal( wpnarg, "@ALL" ) )
        {
            give_item( target, "weapon_crowbar" );
            give_item( target, "weapon_hornetgun" );
            set_user_bpammo( target, HLW_HORNETGUN, 8 );
            give_item( target, "weapon_python" );
            set_user_bpammo( target, HLW_PYTHON, 36 );
            give_item( target, "weapon_357" );
            set_user_bpammo( target, HLW_PYTHON, 36 );
            give_item( target, "weapon_crossbow" );
            set_user_bpammo( target, HLW_CROSSBOW, 50 );
            give_item( target, "weapon_snark");
            set_user_bpammo( id, HLW_SNARK, 15 );
            give_item( target, "weapon_tripmine" );
            set_user_bpammo( target, HLW_TRIPMINE, 5 );
            give_item( target, "weapon_satchel" );
            set_user_bpammo( target, HLW_SATCHEL, 5 );
            give_item( target, "weapon_handgrenade" );
            set_user_bpammo( target, HLW_HANDGRENADE, 10 );
            give_item( target, "weapon_9mmhandgun" );
            set_user_bpammo( target, HLW_GLOCK, 250 );
            give_item( target, "weapon_glock" );
            set_user_bpammo( target, HLW_GLOCK, 250 );
            give_item( target, "weapon_9mmAR" );
            set_user_bpammo( target, HLW_MP5, 250 );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "ammo_ARgrenades" );
            give_item( target, "weapon_gauss" );
            set_user_bpammo( target, HLW_GAUSS, 100 );
            give_item( target, "weapon_mp5" );
            set_user_bpammo( target, HLW_MP5, 250 );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "ammo_mp5grenades" );
            give_item( target, "weapon_egon" ); 			   
            set_user_bpammo( target, HLW_EGON, 100 );
            give_item( target, "weapon_rpg" );
            set_user_bpammo( target, HLW_RPG, 5 );
            give_item( target, "weapon_shotgun" );
            set_user_bpammo( target, HLW_SHOTGUN, 125 );
        }
        
        else
        {
            console_print( id, "[HL] Invalid weapon name!" );
            return PLUGIN_HANDLED;
        }
        
        return PLUGIN_HANDLED;
    }
    
    
    public cmdGiveItem( id, level, cid )
    {
        if( !cmd_access( id, level, cid, 3 ) )
        {
            return PLUGIN_HANDLED;
        }
	
        new arg[ 32 ], itemarg[ 20 ];
        read_argv( 1, arg, charsmax( arg ) );
        
        new target = cmd_target( id, arg, charsmax( arg ) );
	
        if( !target )
        {
            return PLUGIN_HANDLED;
        }
	
        read_argv( 2, itemarg, charsmax( itemarg ) );
	
        if( equal( itemarg, "battery" ) )
        {
            give_item( target, "item_battery" );
        }
        
        else if( equal( itemarg, "healthkit" ) )
        {
            give_item( target, "item_healthkit" );
        }
        
        else if( equal( itemarg, "longjump" ) )
        {
            give_item( target, "item_longjump" );
        }
        
        else if( equal( itemarg, "security" ) )
        {
            give_item( target, "item_security" );
        }
        
        else if( equal( itemarg, "antidote" ) )
        {
            give_item( target, "item_antidote" );
        }
        
        else if( equal( itemarg, "@ALL" ) )
        {
            give_item( target, "item_battery" );
            give_item( target, "item_healthkit" );
            give_item( target, "item_longjump" );
            give_item( target, "item_security" );
            give_item( target, "item_antidote" );
        }
        
        else
        {
            console_print( id, "[HL] Invalid item name!" );
            return PLUGIN_HANDLED;
        }
        
        return PLUGIN_HANDLED;
    }
    
    
    stock set_user_bpammo( index, weapon, amount )
    {
        new offset;
        switch( weapon )
        {
            case HLW_GLOCK, HLW_MP5: offset = GLOCK_MP5_9MM_BPAMMO_OFFSET; 
            case HLW_PYTHON: offset = PYTHON_BPAMMO_OFFSET;
            case HLW_CHAINGUN: offset = CHAINGUN_BPAMMO_OFFSET;
            case HLW_CROSSBOW: offset = CROSSBOW_BPAMMO_OFFSET;
            case HLW_SHOTGUN: offset = SHOTGUN_BPAMMO_OFFSET;
            case HLW_RPG: offset = RPG_BPAMMO_OFFSET;
            case HLW_GAUSS, HLW_EGON: offset = GAUSS_EGON_BPAMMO_OFFSET;
            case HLW_HORNETGUN: offset = HORNET_BPAMMO_OFFSET;
            case HLW_HANDGRENADE: offset = GRENADE_BPAMMO_OFFSET;
            case HLW_TRIPMINE: offset = TRIPMINE_BPAMMO_OFFSET;
            case HLW_SATCHEL: offset = SATCHEL_BPAMMO_OFFSET;
            case HLW_SNARK: offset = SNARK_BPAMMO_OFFSET;
        }
        
        set_pdata_int( index, offset, amount );
    }
