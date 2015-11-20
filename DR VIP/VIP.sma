
#include < amxmodx >
#include < amxmisc >

#include < cstrike >
#include < engine >
#include < fakemeta >
#include < fun >
#include < hamsandwich >

#include < stripweapons >
#include < colorchat >

#pragma semicolon 1

#define MAX_PLAYERS		32 + 1
#define MAX_HATS		15
#define TRAIL_LIFE		15.0

#define TASK_VIP		3421312
#define TASK_VIP2		3444423

#define IS_PLAYER(%1)		(1 <= %1 <= gMaxPlayers)
#define SCOREATTRIB_VIP  	( 1 << 2 )

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

new const gVipHats[ MAX_HATS ][ ] =
{
	"models/viphats/awesome.mdl",
	"models/viphats/darth.mdl",
	"models/viphats/devil2.mdl",
	"models/viphats/hellokitty.mdl",
	"models/viphats/jackjack.mdl",
	"models/viphats/mau5.mdl",
	"models/viphats/popeye.mdl",
	"models/viphats/viking.mdl",
	"models/viphats/Spartan.mdl",
	"models/viphats/dunce.mdl",
	"models/viphats/headphones.mdl",
	"models/viphats/jackolantern.mdl",
	"models/viphats/magic.mdl",
	"models/viphats/lemonhead.mdl",
	"models/viphats/vendetta.mdl"
};

new const gVipHatNames[ MAX_HATS ][ ] =
{
	"Awesome",
	"Darth",
	"Devil 2",
	"Hello Kitty",
	"Jack Jack",
	"Mau 5",
	"Popeye",
	"Viking",
	"Spartan",
	"Dunce",
	"Head Phones",
	"Jack O' Lantern",
	"Magic",
	"Lemon Head",
	"Vendetta"
};

new Float:gHatGlowColors[ MAX_HATS ][ 3 ] =
{
	{ 255.0, 255.0, 0.0 },		// Awesome
	{ 10.0, 10.0, 255.0 },		// Darth
	{ 255.0, 127.0, 0.0 },		// Devil 2
	{ 255.0, 20.0, 147.0 },		// Hello Kitty
	{ 255.0, 218.0, 185.0 },	// Jack Jack
	{ 255.0, 0.0, 0.0 },		// Mau 5
	{ 255.0, 255.0, 255.0 },	// Popeye
	{ 255.0, 211.0, 155.0 },	// Viking
	{ 139.0, 69.0, 19.0 },		// Spartan
	{ 245.0, 245.0, 220.0 },	// Dunce
	{ 210.0, 180.0, 140.0 },	// Head Phones
	{ 255.0, 127.0, 36.0 },		// Jackolantern
	{ 133.0, 99.0, 99.0 },		// Magic
	{ 124.0, 252.0, 0.0 },		// Lemonhead
	{ 245.0, 245.0, 245.0 }		// Vendetta
};

new const gOtherRandomColors[ ][ 3 ] =
{
	{ 124, 252, 0 }, { 224, 224, 224 }, { 255, 10, 10 }, { 10, 255, 10 }, { 10, 10, 255 }, { 255, 127, 0 },
	{ 255, 255, 0 }, { 0, 255, 255 }, { 0, 206, 209 }, { 106, 90, 205 }, { 255, 64, 64 }, { 202, 255, 112 },
	{ 0, 250, 154 }, { 127, 255, 0 }, { 255, 140, 0 }, { 255, 140, 0 }, { 240, 128, 128 }, { 255, 165, 0 },
	{ 255, 36, 0 }, { 255, 20, 147 }, { 255, 106, 106 }, { 255, 255, 255 }, { 139, 37, 0 }, { 255, 28, 174 },
	{ 154, 50, 205 }, { 128, 0, 0 }, { 255, 222, 173 }, { 255, 215, 0 }, { 153, 204, 50 }
};

new const gTag[ ] = "[VIP]";

new const gVipModel[ ] = "vip";
new const gJoinSound[ ] = "barney/hellonicesuit.wav";
new const gLeftSound[ ] = "barney/ba_later.wav";

new gCvarVipHealth;
new gCvarVipArmor;
new gCvarVipSpeed;
new gCvarVipDeagleAmmo;
new gCvarVipMoney;

new gHudSync;
new gMaxPlayers;
new gTrailSprite;
new gRingSprite;

new bTrailRandomColor[ MAX_PLAYERS ][ 3 ];
new bPlayerHat[ MAX_PLAYERS ];

new Float:flNextCheck[ MAX_PLAYERS ];

const IN_MOVING = IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_JUMP;

public plugin_init( )
{
	register_plugin( "VIP", "1.0.1", "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_Spawn", 1 );
	RegisterHam( Ham_Player_ResetMaxSpeed, "player", "bacon_ResetMaxSpeed", 1 );
	
	register_forward( FM_CmdStart, "forward_cmdstart" );
	
	register_message( get_user_msgid( "ScoreAttrib" ), "Message_ScoreAttrib" );
	register_event( "DeathMsg", "Hook_Death", "a" );

	register_clcmd( "say /viphats", "CommandVIPHats" );
	register_clcmd( "say_team /viphats", "CommandVIPHats" );
	
	register_clcmd( "say /vipon", "CommandVipOnline" );
	register_clcmd( "say_team /vipon", "CommandVipOnline" );
	
	register_clcmd( "say /buyvip", "CommandShowInfo" );
	register_clcmd( "say_team /buyvip", "CommandShowInfo" );

	gCvarVipHealth = register_cvar( "vip_health", "255" );
	gCvarVipArmor = register_cvar( "vip_armor", "255" );
	gCvarVipSpeed = register_cvar( "vip_speed", "320" );
	gCvarVipDeagleAmmo = register_cvar( "vip_deagle_ammo", "21" );
	gCvarVipMoney = register_cvar( "vip_moneybonus", "1500" );
	
	gHudSync = CreateHudSyncObj( );
	gMaxPlayers = get_maxplayers( );
	
	UTIL_CheckServerLicense( "93.119.26.88:27015", 0 );
}

public plugin_precache( )
{
	new szFormatModel[ 200 ], i;
	formatex( szFormatModel, charsmax( szFormatModel ), "models/player/%s/%s.mdl", gVipModel, gVipModel );

	for( i = 0; i < MAX_HATS; i++ )
	{
		precache_model( gVipHats[ i ] );
	}

	gTrailSprite = precache_model( "sprites/zbeam2.spr" );
	gRingSprite = precache_model( "sprites/shockwave.spr" );

	precache_model( szFormatModel );
	
	precache_sound( gJoinSound );
	precache_sound( gLeftSound );
}

public client_connect( id )
{
	if( bPlayerHat[ id ] > 0 )
	{
		engfunc( EngFunc_RemoveEntity, bPlayerHat[ id ] );
	}

	bPlayerHat[ id ] = 0;
}

public client_disconnect( id )
{
	if( UTIL_IsVIP( id ) )
	{
		new szName[ 32 ];
		get_user_name( id, szName, charsmax( szName ) );

		set_hudmessage( 255, 10, 10, 0.02, 0.24, 1, 6.0, 4.0 );
		ShowSyncHudMsg( 0, gHudSync, "VIP Offline: %s", szName );
		
		client_cmd( 0, "speak ^"%s^"", gLeftSound );
	}
	
	if( bPlayerHat[ id ] > 0 )
	{
		engfunc( EngFunc_RemoveEntity, bPlayerHat[ id ] );
	}

	bPlayerHat[ id ] = 0;

	remove_task( id + TASK_VIP );
	remove_task( id + TASK_VIP2 );
}

public client_putinserver( id )
{
	if( UTIL_IsVIP( id ) )
	{
		new szName[ 32 ];
		get_user_name( id, szName, charsmax( szName ) );

		set_hudmessage( 10, 255, 10, 0.02, 0.24, 1, 6.0, 4.0 );
		ShowSyncHudMsg( 0, gHudSync, "VIP Online: %s", szName );
		
		client_cmd( 0, "speak ^"%s^"", gJoinSound );
	}
}

public CommandVipOnline( id )
{
	new iMenu = menu_create( "\rVIP Online:", "menu_vip" );
	
	new bool:bVipOn = false;
	new szName[ 40 ], szFormatMenu[ 300 ], i;
	
	for( i = 1; i <= gMaxPlayers; i++ )
	{
		if( is_user_bot( i ) )
		{
			continue;
		}
		
		if( is_user_connected( i ) && UTIL_IsVIP( i ) )
		{
			get_user_name( i, szName, charsmax( szName ) );
			formatex( szFormatMenu, charsmax( szFormatMenu ), "\y%s \d(VIP)", szName );
			
			menu_additem( iMenu, szFormatMenu, "" );
			
			bVipOn = true;
		}
	}
	
	if( bVipOn )
	{
		menu_display( id, iMenu );
	}

	else
	{
		ColorChat( id, RED, "^3%s^1 Nu sunt^4 VIP^1 online!", gTag );
		
		menu_destroy( iMenu );
	}
}

public forward_cmdstart( id, handle )
{
	if( !is_user_alive( id ) || !UTIL_IsVIP( id ) )
	{
		return FMRES_IGNORED;
	}
	
	new iButton = get_uc( handle, UC_Buttons );

	if( !( iButton & IN_MOVING ) )
    	{
		new Float:flGameTime = get_gametime();
	
		if( flNextCheck[ id ] < flGameTime )
		{
			UTIL_KillBeamFollow( id );
			UTIL_BeamFollow( id );
		
			flNextCheck[ id ] = flGameTime + ( TRAIL_LIFE / 8.0 );
		}
	}
	
	return FMRES_IGNORED;
}

public CommandShowInfo( id )
{
	const SIZE = 4024;
	new msg[ SIZE + 1 ],len = 0;

	len += formatex( msg[ len ], SIZE - len, "<html><body bgcolor=^"black^">");
	len += formatex( msg[ len ], SIZE - len, "<center><h2><font color=^"#FF6600^">Privilegii VIP</font></h2><br><br>" );
	len += formatex( msg[ len ], SIZE - len, "<ul type=square><font color=^"#c0c0ff^"><li><b>Grenada HE, SG la fiecare spawn</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>%d Armura</b></font>", get_pcvar_num( gCvarVipArmor ) );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>%d Viata</b></font>", get_pcvar_num( gCvarVipHealth ) );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>%d Viteza</b></font>", get_pcvar_num( gCvarVipSpeed ) );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Notificatii speciale cand intrii/iesi de pe server</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>+%d$ la fiecare spawn</b></font>", get_pcvar_num( gCvarVipMoney ) );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Tag VIP in tabela de scor</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Deagle cu %d gloante la fiecare spawn</b></font>", get_pcvar_num( gCvarVipDeagleAmmo ) );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Acces la palarii (/viphats)</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Trail la fiecare spawn (culoare aleatorie)</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Glow la fiecare spawn (culoare aleatorie)</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Slot rezervat pe server</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Efect special la fiecare spawn</b></font>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^"><li><b>Model special de VIP</b></font></ul><br><br><br>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#00c000^"><b>Cum sa devii VIP?</font></b><br><br>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^">Pret VIP: 2 Euro</font><br>" );
	len += formatex( msg[ len ], SIZE - len, "<font color=^"#c0c0ff^">Daca vrei sa cumperi VIP contacteaza Y!M: </font><font color=^"#FF6600^"><b>csblue3@yahoo.com</b></font></center></body></html>" );
	
	show_motd( id, msg, "Privilegii VIP" );
	
	return PLUGIN_CONTINUE;
}

public Message_ScoreAttrib( iMsgID, iDest, iReceiver )
{
	new id = get_msg_arg_int( 1 );
	
	if( is_user_connected( id ) && UTIL_IsVIP( id )  )
	{
		set_msg_arg_int( 2, ARG_BYTE, SCOREATTRIB_VIP );
	}
}

public Hook_Death( )
{
	new iVictim = read_data( 2 );
	
	if( IS_PLAYER( iVictim ) )
	{
		remove_task( iVictim + TASK_VIP );
		remove_task( iVictim + TASK_VIP2 );
	
		set_user_rendering( iVictim );
		cs_reset_user_model( iVictim );
	}
}

public bacon_Spawn( id )
{
	if( is_user_alive( id ) )
	{
		if( UTIL_IsVIP( id ) )
		{
			cs_set_user_model( id, gVipModel );

			set_user_health( id, get_pcvar_num( gCvarVipHealth ) );
			cs_set_user_armor( id, get_pcvar_num( gCvarVipArmor ), CS_ARMOR_VESTHELM );

			new iMoney = cs_get_user_money( id );
			new iMoneyBonus = get_pcvar_num( gCvarVipMoney );

			iMoney = ( iMoney + iMoneyBonus > 16000 ) ? 16000 : iMoney + iMoneyBonus;
			cs_set_user_money( id, iMoney );
			
			if( cs_get_user_team( id ) == CS_TEAM_CT )
			{
				set_task( 1.5, "GiveDeagle", id + TASK_VIP );
			}

			new iGlowIndex = random( sizeof( gOtherRandomColors ) );

			bTrailRandomColor[ id ][ 0 ] = gOtherRandomColors[ iGlowIndex ][ 0 ];
			bTrailRandomColor[ id ][ 1 ] = gOtherRandomColors[ iGlowIndex ][ 1 ];
			bTrailRandomColor[ id ][ 2 ] = gOtherRandomColors[ iGlowIndex ][ 2 ];

			set_task( 1.6, "GiveGrenades", id + TASK_VIP2 );
		
			new iOrigin[ 3 ];
			get_user_origin( id, iOrigin, 0 );
			
			UTIL_WaveFX( iOrigin, 100 );
			UTIL_WaveFX( iOrigin, 150 );
			UTIL_WaveFX( iOrigin, 200 );
		}
	}
}

public GiveDeagle( iTaskid )
{
	new id = iTaskid - TASK_VIP;
	remove_task( id + TASK_VIP );

	if( is_user_connected( id ) && IS_PLAYER( id ) )
	{
		StripWeapons( id, Secondary );

		give_item( id, "weapon_deagle" );
		cs_set_user_bpammo( id, CSW_DEAGLE, get_pcvar_num( gCvarVipDeagleAmmo ) );
	}
}

public GiveGrenades( Taskid )
{
	new id = Taskid - TASK_VIP2;
	remove_task( id + TASK_VIP2 );

	if( is_user_connected( id ) && IS_PLAYER( id ) )
	{
		if( !user_has_weapon( id, CSW_HEGRENADE ) )
		{
			give_item( id, "weapon_hegrenade" );
		}
		
		if( !user_has_weapon( id, CSW_SMOKEGRENADE ) )
		{
			give_item( id, "weapon_smokegrenade" );
		}
		
		new iGlowIndex = random( sizeof( gOtherRandomColors ) );

		set_user_rendering( id, kRenderFxGlowShell, gOtherRandomColors[ iGlowIndex ][ 0 ], gOtherRandomColors[ iGlowIndex ][ 1 ], gOtherRandomColors[ iGlowIndex ][ 2 ], kRenderNormal, 19 );
	}
}

public CommandVIPHats( id )
{
	if( !UTIL_IsVIP( id ) )
	{
		ColorChat( id, RED, "^3%s^1 Nu ai acces la aceasta comanda!", gTag );
		
		return PLUGIN_HANDLED;
	}	

	if( !is_user_alive( id ) )
	{
		ColorChat( id, RED, "^3%s^1 Trebuie sa fii viu ca sa ai acces la aceasta comanda!", gTag );
	
		return PLUGIN_HANDLED;
	}
	
	new idString[ 4 ], i;
	new iMenu = menu_create( "\rPalarii VIP", "menu_Handler" );
	
	for( i = 0; i < MAX_HATS; i++ )
	{
		num_to_str( i, idString, charsmax( idString ) );
		menu_additem( iMenu, gVipHatNames[ i ], idString );
	}
	
	menu_setprop( iMenu, MPROP_EXIT, MEXIT_ALL );
        menu_display( id, iMenu );

        return PLUGIN_HANDLED;
}

public menu_Handler( id, menu, item )
{
	if( item >= 0 )
	{
		new access, callback, idString[ 4 ];
            	menu_item_getinfo( menu, item, access, idString, charsmax( idString ), _, _, callback );

		new i = str_to_num( idString );	
		
		UTIL_SetHat( id, gVipHats[ i ], gHatGlowColors[ i ] );
		ColorChat( id, RED, "^3%s^1 Palarie selectata:^4 %s", gTag, gVipHatNames[ i ] );
		
		menu_destroy( menu );
	}
	
	return PLUGIN_HANDLED;
}

public menu_vip( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		
		return PLUGIN_HANDLED;
	}
	
	menu_display( id, menu );
	
	return PLUGIN_HANDLED;
}

public bacon_ResetMaxSpeed( id )
{
	if( is_user_alive( id ) )
	{
		if( UTIL_IsVIP( id )  )
		{
			new Float:flMaxSpeed = float( get_pcvar_num( gCvarVipSpeed ) );
		
			engfunc( EngFunc_SetClientMaxspeed, id, flMaxSpeed );
			set_pev( id, pev_maxspeed, flMaxSpeed );
		}
	}
}

stock UTIL_IsVIP( id )
{
	if( ( get_user_flags( id ) & ADMIN_CFG ) && ( get_user_flags( id ) & ADMIN_RESERVATION ) ) 
	{
		return 1;
	}
	
	return 0;
}

stock UTIL_SetHat( id, const szModel[ ], Float:flColor[ 3 ] )
{
	remove_entity( bPlayerHat[ id ] );
	new iEntity = bPlayerHat[ id ] = create_entity( "info_target" );
	
	if( pev_valid( iEntity ) )
	{
		engfunc( EngFunc_SetModel, iEntity, szModel );
		set_pev( iEntity, pev_movetype, MOVETYPE_FOLLOW );
		set_pev( iEntity, pev_aiment, id );
		set_pev( iEntity, pev_owner, id );

		set_pev( iEntity, pev_renderfx, kRenderFxGlowShell );
		set_pev( iEntity, pev_rendercolor, flColor );
		set_pev( iEntity, pev_rendermode, kRenderNormal );
		set_pev( iEntity, pev_renderamt, 16.0 );
	}
}
		
stock UTIL_BeamFollow( id )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMFOLLOW );
	write_short( id );
	write_short( gTrailSprite );
	write_byte( floatround( TRAIL_LIFE ) );
	write_byte( 15 );
	write_byte( bTrailRandomColor[ id ][ 0 ] );
	write_byte( bTrailRandomColor[ id ][ 1 ] );
	write_byte( bTrailRandomColor[ id ][ 2 ] );
	write_byte( 200 );
	message_end( );
}

stock UTIL_KillBeamFollow( id )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_KILLBEAM );    
	write_short( id );
	message_end( );
}
		
stock UTIL_WaveFX( iOrigin[ 3 ], addrad )
{
	new iColorIndex = random( sizeof( gOtherRandomColors ) );

	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] - 29 );	
	write_coord( iOrigin[ 0 ] - 50 );	
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ] + addrad );
	write_short( gRingSprite );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 5 );
	write_byte( 5 );
	write_byte( 0 );
	write_byte( gOtherRandomColors[ iColorIndex ][ 0 ] );
	write_byte( gOtherRandomColors[ iColorIndex ][ 1 ] );
	write_byte( gOtherRandomColors[ iColorIndex ][ 2 ] );
	write_byte( 190 );
	write_byte( 0 );
	message_end( );
}


stock UTIL_CheckServerLicense( const szIP[ ], iShutDown = 1 )
{
	new szServerIP[ 50 ];
	get_cvar_string( "ip", szServerIP, charsmax( szServerIP ) );
	
	if( !equal( szServerIP, szIP ) )
	{
		if( iShutDown == 1 )
		{
			server_cmd( "exit" );
		
			log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed...Shutting down...", szIP, szServerIP );
		}
		
		else if( iShutDown == 0 )
		{
			new szFormatFailState[ 250 ];
			formatex( szFormatFailState, charsmax( szFormatFailState ), "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking failed.", szIP, szServerIP );

			set_fail_state( szFormatFailState );
		}
	}
	
	else
	{
		log_amx( "[Steal Guard] License IP: <%s>. Your Server IP is: <%s>. IP Checking verified! DONE.", szIP, szServerIP );
	}
}
