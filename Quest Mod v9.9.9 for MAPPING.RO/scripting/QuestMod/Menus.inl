
/*
	
	====================================================
	Meniul cu cutite si info despre ele aici!
	====================================================

*/


QuestMod_Menus( )
{
	register_clcmd( "say /quest", "commandShowQuest" );
	register_clcmd( "say_team /quest", "commandShowQuest" );
	
	register_clcmd( "say /class", "commandShowAllClass" );
	register_clcmd( "say_team /class", "commandShowAllClass" );
}

public commandShowQuest( id )
{
	if( !is_user_alive( id ) )
	{
		UTIL_ColorPrint( id, "^4[QuestMod]^1 Nu poti sa iti selectezi Quest-ul cat timp esti mort!" );
		return PLUGIN_HANDLED;
	}

	if( bChoose[ id ] == 1 )
	{
		UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales odata un Quest runda asta !" );
		return PLUGIN_HANDLED;
	}
	
	new szFormatExMenu[ 2000 + 1 ];
	formatex( szFormatExMenu, charsmax( szFormatExMenu ), "\rAlege-ti QUESTUL^n^nPentru a afla ce face fiecare erou tasteaza in chat \w/abilitati^n\rDaca iti place serverul adauga la favorite \wdr.mapping.ro\R\r" );

	new menu = menu_create( szFormatExMenu, "menu_handler" );
	
	new szFormatMenuEx[ 2000 ];
	
	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "WolfMan \y[Damage dublu + Viteza mai mica: %d]", get_pcvar_num( gCvarLowSpeed ) );
	menu_additem( menu, szFormatMenuEx, "1", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Ninja \y[Nu se aud pasii + 1 Smoke]" );
	menu_additem( menu, szFormatMenuEx, "2", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Flash \y[Viteza mai mare: %d]", get_pcvar_num( gCvarHighSpeed ) );
	menu_additem( menu, szFormatMenuEx, "3", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Hulk \y[Gravitatie 700]" );
	menu_additem( menu, szFormatMenuEx, "4", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Mutant \y[Regenerare viata pana la %d]", get_pcvar_num( gCvarHealthMax ) );
	menu_additem( menu, szFormatMenuEx, "5", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Predator \y[Invizibilitate %d%%]", UTIL_GetPercent( get_pcvar_num( gCvarVisibility ), 255 ) );
	menu_additem( menu, szFormatMenuEx, "6", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Nightcrawler \y[Teleportare]" );
	menu_additem( menu, szFormatMenuEx, "7", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Storm \y[Fulgere]" );
	menu_additem( menu, szFormatMenuEx, "8", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Spectru \y[Blind 2 Sec la toata echipa adversa]" );
	menu_additem( menu, szFormatMenuEx, "9", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Weed Man \y[Opresti un inamic %d secunde]", get_pcvar_num( gCvarStopTime ) );
	menu_additem( menu, szFormatMenuEx, "10", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Normal \y[Cutit normal, fara puteri]" );
	menu_additem( menu, szFormatMenuEx, "11", 0 );
	
	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Scorpion \y[Tragi inamicul langa tine]" );
	menu_additem( menu, szFormatMenuEx, "12", 0 );
	
	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Medic \y[Vindeci viata coechipierilor]" );
	menu_additem( menu, szFormatMenuEx, "13", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Gordon Freeman \y[Primesti doar jumatate din daunele primite]" );
	menu_additem( menu, szFormatMenuEx, "14", 0 );
	
	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Scientist \y[Esueaza un test stiintific pe inamic] \rDoar pentru OWNERI" );
	menu_additem( menu, szFormatMenuEx, "15", ADMIN_QUEST_ACCESS );
	
	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Reptile \y[Scuipa cu Acid]" );
	menu_additem( menu, szFormatMenuEx, "16", 0 );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Sub Zero \y[Ingheata inamicul si explodeaza] \rDoar pentru OWNERI" );
	menu_additem( menu, szFormatMenuEx, "17", ADMIN_QUEST_ACCESS );

	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Fireman \y[Arde inamicul %d secunde]", get_pcvar_num( gCvarFiremanFireDuration ) );
	menu_additem( menu, szFormatMenuEx, "18", 0 );
	
	formatex( szFormatMenuEx, charsmax( szFormatMenuEx ), "Liu Kang \y[Arunca cu bile de foc] \rDoar pentru OWNERI" );
	menu_additem( menu, szFormatMenuEx, "19", ADMIN_QUEST_ACCESS );

	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu, 0 );
	
	return PLUGIN_CONTINUE;
}

public menu_handler( id, menu, item )
{
	if( item == MENU_EXIT )
    	{
        	menu_destroy( menu );
        	return PLUGIN_HANDLED;
    	}
	
	new iData[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, iData, charsmax( iData ), iName, charsmax( iName ), callback );

	new key = str_to_num( iData );

	switch( key )
	{
		case 1:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3WolfMan" );

			SetKnifePower( id, 4 );
			menu_destroy( menu );
			set_task( 0.6, "GetSomeSpeed", id );
		}
		
		case 2:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Ninja" );

			SetKnifePower( id, 2 );
			menu_destroy( menu );
			set_task( 0.6, "GetNoFootSteps", id );
		}
		
		case 3:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Flash" );

			SetKnifePower( id, 3 );
			menu_destroy( menu );
			set_task( 0.6, "GetSpeedAha", id );
		}
		
		case 4:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Hulk" );

			SetKnifePower( id, 1 );
			menu_destroy( menu );
			set_task( 0.6, "GetGravity", id );
		}
		
		case 5:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Mutant" );

			SetKnifePower( id, 0 );
			menu_destroy( menu );
			set_task( TASK_INTERVAL , "task_healing", id + 312812, _,_, "b" );
		}
		
		case 6:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Predator" );

			SetKnifePower( id, 5 );
			menu_destroy( menu ); 
			set_task( 0.6, "GetInvisible", id );
		}
		
		case 7:
		{			     
			client_cmd( id, "bind v ^"teleport^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Nightcrawler" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"v^"^1 pentru a folosi teleport !" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Daca teleportarea esueaza mai incearca odata!" );
			
			SetKnifePower( id, 6 );
			menu_destroy( menu );
		}
		
		case 8:
		{
			client_cmd( id, "bind v ^"+thunder^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Storm" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"v^"^1 pentru a folosi fulgerul !" );

			SetKnifePower( id, 7 );
			menu_destroy( menu );
		}
		
		case 9:
		{
			client_cmd( id, "bind v ^"flash^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Spectru" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"v^"^1 pentru a folosi blind !" );

			SetKnifePower( id, 8 );
		}
		
		case 10:
		{
			client_cmd( id, "bind v ^"roots^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Weed Man" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"v^"^1 pentru a folosi iarba sa blochezi inamicul !" );
			
			SetKnifePower( id, 9 );
		}
		
		case 11:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Normal" );

			SetKnifePower( id, 10 );
			menu_destroy( menu ); 
		}
		
		case 12:
		{
			client_cmd( id, "bind v ^"+scorpion^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Scorpion" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"v^"^1 ca sa tragi inamicul spre tine !" );
		
			SetKnifePower( id, 11 );
			menu_destroy( menu );
		}
		
		case 13:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Medic" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"E^"^1 ca sa vindeci coechipierii !" );
		
			SetKnifePower( id, 12 );
			menu_destroy( menu );
		}
		
		case 14:
		{
			client_cmd( id, "bind v ^"none^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Gordon Freeman" );
			
			SetKnifePower( id, 13 );
			menu_destroy( menu );
		}
		
		case 15:
		{
			client_cmd( id, "bind v ^"sciencetest^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Scientist" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"V^"^1 ca sa ranesti adversarul cu un test care esueaza !" );
			
			SetKnifePower( id, 14 );
			menu_destroy( menu );
		}
		
		case 16:
		{
			client_cmd( id, "bind v ^"acidspit^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Reptile" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"V^"^1 ca sa scuipi cu acid!" );
			
			SetKnifePower( id, 15 );
			menu_destroy( menu );
		}
		
		case 17:
		{
			client_cmd( id, "bind v ^"ice^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Sub Zero" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"V^"^1 ca sa ingheti inamicul!" );
			
			SetKnifePower( id, 16 );
			menu_destroy( menu );
		}
		
		case 18:
		{
			client_cmd( id, "bind v ^"fire^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Fire Man" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"V^"^1 ca sa ii dai foc inamicului!" );
			
			SetKnifePower( id, 17 );
			menu_destroy( menu );
		}
		
		case 19:
		{
			client_cmd( id, "bind v ^"fireball^"" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Ai ales Questul -> ^3Liu Kang" );
			UTIL_ColorPrint( id, "^4[QuestMod]^1 Apasa^4 ^"V^"^1 ca sa arunci cu bile de foc!" );
			
			SetKnifePower( id, 18 );
			menu_destroy( menu );
		}
	}		
	
	bChoose[ id ] = 1;
	UTIL_SaveData( id );

    	return PLUGIN_HANDLED;
}

public commandShowAllClass( id )
{
	client_cmd( id, "toggleconsole" );

	console_print( id, "====================================" );
	console_print( id, "-=[ Numele ]=- | -=[ Nume Quest Luat ]=-" );
	console_print( id, "====================================" );
		
	new iPlayers[ 32 ], iNum, i, iPlayersId;
	get_players( iPlayers, iNum, "ch" );
	
	for( i = 0; i < iNum; i++ )
	{
		iPlayersId = iPlayers[ i ];
		
		new szPlayersName[ 32 ];
		get_user_name( iPlayersId, szPlayersName, charsmax( szPlayersName ) );
		
		new szClassNameForAll[ 60 ];
		
		switch( gKnifeModel[ iPlayersId ] )
		{
			case 0:	szClassNameForAll = "Mutant";
			case 1:	szClassNameForAll = "Hulk";
			case 2:	szClassNameForAll = "Ninja";
			case 3:	szClassNameForAll = "Flash";
			case 4:	szClassNameForAll = "Wolfman";
			case 5:	szClassNameForAll = "Predator";
			case 6:	szClassNameForAll = "Night Crawler";
			case 7:	szClassNameForAll = "Storm";
			case 8:	szClassNameForAll = "Spectru";
			case 9:	szClassNameForAll = "Weed Man";
			case 10: szClassNameForAll = "Normal";
			case 11: szClassNameForAll = "Scorpion";
			case 12: szClassNameForAll = "Medic";
			case 13: szClassNameForAll = "Gordon Freeman";
			case 14: szClassNameForAll = "Scientist";
			case 15: szClassNameForAll = "Reptile";
			case 16: szClassNameForAll = "Sub Zero";
			case 17: szClassNameForAll = "Fireman";
			case 18: szClassNameForAll = "Liu Kang";
		}
		
		console_print( id, "%s =-> [%s]", szPlayersName, szClassNameForAll );
	}
	
	console_print( id, "====================================" );
	
	return PLUGIN_CONTINUE;
}
