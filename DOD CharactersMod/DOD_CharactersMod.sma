#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "DOD Characters Mod"
#define VERSION "1.0.4"
#define AUTHOR "tuty"

#define TASK_MENU_DISLPAY_TIME 3.0

new CS_DOD_Enable;
new CS_DOD_RifflemanHP;
new CS_DOD_RifllemanAR;
new CS_DOD_AssaultHP;
new CS_DOD_AssaultAR;
new CS_DOD_SuportHP;
new CS_DOD_SuportAR;
new CS_DOD_SniperHP;
new CS_DOD_SniperAR;
new CS_DOD_MachineGunnerHP;
new CS_DOD_MachineGunnerAR;
new CS_DOD_GameName;
new CS_DOD_SayTextT;
new CS_DOD_DeadFade;
new CS_DOD_EnableDeadFade;
new CS_DOD_EnableGlow;
new CS_DOD_EnableHudHelp;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("dod_character_mod", VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1);
	register_event("SendAudio", "t_win" , "a", "2&%!MRAD_terwin");
        register_event("SendAudio", "ct_win", "a", "2&%!MRAD_ctwin");
	register_event("DeathMsg","death_msg","a");
	register_forward(FM_GetGameDescription,"fw_GameDesc");
	set_task(1.0, "modInfo", 0, "", 0, "b");
	register_menucmd(register_menuid("CSDOD_MENU"), 1023, "characters_menu");
	CS_DOD_Enable = register_cvar("cs_dod_enabled", "1");
	CS_DOD_RifflemanHP = register_cvar("cs_dod_riffleman_hp", "160");
	CS_DOD_RifllemanAR = register_cvar("cs_dod_riffleman_armor", "160");
	CS_DOD_AssaultHP = register_cvar("cs_dod_assault_hp", "180");
	CS_DOD_AssaultAR = register_cvar("cs_dod_assault_armor", "100");
	CS_DOD_SuportHP = register_cvar("cs_dod_suport_hp", "190");
	CS_DOD_SuportAR = register_cvar("cs_dod_suport_armor", "120");
	CS_DOD_SniperHP = register_cvar("cs_dod_sniper_hp", "200");
	CS_DOD_SniperAR = register_cvar("cs_dod_sniper_armor", "200");
	CS_DOD_MachineGunnerHP = register_cvar("cs_dod_mgunner_hp", "250");
	CS_DOD_MachineGunnerAR = register_cvar("cs_dod_mgunner_armor", "250");
	CS_DOD_GameName = register_cvar("cs_dod_game_name", "CS DOD Characters Mod");
	CS_DOD_EnableDeadFade = register_cvar("cs_dod_dead_fade", "1");
	CS_DOD_EnableGlow = register_cvar("cs_dod_character_glow", "1");
	CS_DOD_EnableHudHelp = register_cvar("cs_dod_enablehud_help", "1");
	register_clcmd("say /dodcmhelp", "cmdDodHelp");
	register_clcmd("say_team /dodcmhelp", "cmdDodHelp");
        register_clcmd("autobuy", "clcmd_Buy");
	register_clcmd("rebuy", "clcmd_Buy");
	register_clcmd("buy", "clcmd_Buy");
	register_clcmd("buyequip", "clcmd_Buy");
	register_clcmd("buyammo1", "clcmd_Buy");
	register_clcmd("buyammo2", "clcmd_Buy");
	register_clcmd("cl_setautobuy", "clcmd_Buy");
	register_clcmd("cl_autobuy", "clcmd_Buy");
	CS_DOD_SayTextT = get_user_msgid("SayText");	
	CS_DOD_DeadFade = get_user_msgid("ScreenFade");
}
public plugin_cfg()
{
	if(get_pcvar_num(CS_DOD_Enable) == 0)
		return PLUGIN_HANDLED;

	new configsDir[32],file[192];
	get_configsdir(configsDir, sizeof configsDir - 1);
	formatex(file,sizeof file - 1,"%s/dod_cm.cfg",configsDir);
	
	if(file_exists(file))
	{
		server_cmd("exec %s", file);
	}
	else
	{
		log_amx("[ERROR] DOD CM Configuration file not found!");
		server_print("-----------------------------------------------------");
		server_print("[ERROR] DOD CM Configuration file not found!");
		server_print("-----------------------------------------------------");
	}

	return PLUGIN_CONTINUE;
}		
public fwHamPlayerSpawnPost(id)
{
	if(get_pcvar_num(CS_DOD_Enable) == 0)
		return HAM_SUPERCEDE;
	
	set_task(TASK_MENU_DISLPAY_TIME, "ShowCharacters", id);

	return HAM_IGNORED;
}
public ShowCharacters(id)
{	
	if(!is_user_alive(id) && is_user_bot(id) && is_user_hltv(id))
		return PLUGIN_HANDLED;

	new menu[192];
	new keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5);
	format(menu, 191, "\y( Choose Character ):^n^n^n\r1. \wRiffleman^n\r2. \wAssault^n\r3. \wSuport^n\r4. \wSniper^n\r5. \wMachine Gunner^n^n\y6. \rI don't want nothing!");
	show_menu(id, keys, menu, -1, "CSDOD_MENU");

	return PLUGIN_HANDLED;
}
public characters_menu(id, keys)
{
	if(get_pcvar_num(CS_DOD_EnableGlow) == 0)
		return PLUGIN_HANDLED;

	switch(keys) 
	{
		case 0:  
		{ 
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_m4a1");
			fm_give_item(id, "ammo_556nato");
			fm_give_item(id, "ammo_556nato");
			fm_give_item(id, "ammo_556nato");
			fm_give_item(id, "weapon_hegrenade");
			fm_give_item(id, "weapon_glock18");

			fm_set_user_health(id, get_pcvar_num(CS_DOD_RifflemanHP));
			fm_set_user_armor(id, get_pcvar_num(CS_DOD_RifllemanAR));
			fm_set_rendering(id, kRenderFxGlowShell, 0, 100, 0, kRenderNormal, 170);
	
			color_print(id, "^x01[DCM] You are now a ^x04Riffleman.");
		}
		case 1:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_galil");
			fm_give_item(id, "ammo_556nato");
			fm_give_item(id, "ammo_556nato"); 
			fm_give_item(id, "ammo_556nato");
			fm_give_item(id, "weapon_smokegrenade");
			fm_give_item(id, "weapon_hegrenade");
			fm_give_item(id, "weapon_usp");
			fm_give_item(id, "ammo_45acp");
			fm_give_item(id, "ammo_45acp");
			fm_give_item(id, "ammo_45acp");
			fm_give_item(id, "ammo_45acp");
			fm_give_item(id, "ammo_45acp");
			fm_give_item(id, "ammo_45acp");
			fm_give_item(id, "ammo_45acp");
			fm_give_item(id, "ammo_45acp");
	
			fm_set_user_health(id, get_pcvar_num(CS_DOD_AssaultHP));
			fm_set_user_armor(id, get_pcvar_num(CS_DOD_AssaultAR));
			fm_set_rendering(id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 170);
		
			color_print(id, "^x01[DCM] You are now a^x04 Assault.");
		}
		case 2:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_ak47");
			fm_give_item(id, "ammo_762nato");
			fm_give_item(id, "ammo_762nato");
			fm_give_item(id, "ammo_762nato");
			fm_give_item(id, "weapon_hegrenade");
			fm_give_item(id, "weapon_fiveseven");
			fm_give_item(id, "ammo_57mm");
			fm_give_item(id, "ammo_57mm");
			fm_give_item(id, "ammo_57mm");
			fm_give_item(id, "ammo_57mm");
			
			
			fm_set_user_health(id, get_pcvar_num(CS_DOD_SuportHP));
			fm_set_user_armor(id, get_pcvar_num(CS_DOD_SuportAR));
			fm_set_rendering(id, kRenderFxGlowShell, 124, 252, 0, kRenderNormal, 170);
			
			color_print(id, "^x01[DCM] You are now a ^x04Suport.");
		}
		case 3:
		{
			
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_awp");
			fm_give_item(id, "ammo_338magnum");
			fm_give_item(id, "ammo_338magnum");
			fm_give_item(id, "ammo_338magnum");
			fm_give_item(id, "weapon_deagle");
			fm_give_item(id, "ammo_50ae");
			fm_give_item(id, "ammo_50ae");
			fm_give_item(id, "ammo_50ae");
			fm_give_item(id, "ammo_50ae");
			fm_give_item(id, "ammo_50ae");
			fm_give_item(id, "ammo_50ae");
			fm_give_item(id, "ammo_50ae");
			fm_give_item(id, "weapon_flashbang");	
			fm_give_item(id, "weapon_flashbang");
			
			fm_set_user_health(id, get_pcvar_num(CS_DOD_SniperHP));
			fm_set_user_armor(id, get_pcvar_num(CS_DOD_SniperAR));
			fm_set_rendering(id, kRenderFxGlowShell, 69, 139, 0, kRenderNormal, 170);
			
			color_print(id, "^x01[DCM] You are now a ^x04Sniper.");
		}
		case 4:
		{
			
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_m249");
			fm_give_item(id, "ammo_556natobox");
			fm_give_item(id, "ammo_556natobox");
			fm_give_item(id, "ammo_556natobox");
			fm_give_item(id, "ammo_556natobox");
			fm_give_item(id, "ammo_556natobox");
			fm_give_item(id, "ammo_556natobox");
			fm_give_item(id, "ammo_556natobox");
			fm_give_item(id, "weapon_p228");
			fm_give_item(id, "ammo_357sig");
			fm_give_item(id, "ammo_357sig");
			fm_give_item(id, "ammo_357sig");
			fm_give_item(id, "ammo_357sig");
			fm_give_item(id, "ammo_357sig");
			fm_give_item(id, "ammo_357sig");

			fm_set_user_health(id, get_pcvar_num(CS_DOD_MachineGunnerHP));
			fm_set_user_armor(id, get_pcvar_num(CS_DOD_MachineGunnerAR));
			fm_set_rendering(id, kRenderFxGlowShell, 0, 255, 127, kRenderNormal, 170);
			
			color_print(id, "^x01[DCM] You are now a ^x04Machine Gunner.");
		}
		case 5:
		{
			
			user_kill(id);
			color_print(id, "^x04[DCM] You have died because you didn't select any class!");
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 255);

			return 0;
		}
	}
	return 0;
}
public fw_GameDesc()
{
	if(get_pcvar_num(CS_DOD_Enable) == 0)
		return FMRES_IGNORED;

	new gamename[32];
	get_pcvar_string(CS_DOD_GameName, gamename, 31);
	forward_return(FMV_STRING, gamename);

	return FMRES_SUPERCEDE;
}	
public modInfo()
{
	if(get_pcvar_num(CS_DOD_EnableHudHelp) == 1)
	{
		set_hudmessage(255,255,0,0.75,0.05,0, 1.0, 1.0, 0.1, 0.2, 13);
		show_hudmessage(0, "This server run: DOD Character Mod by tuty^nType /dodcmhelp to know how to play");
	}
	return PLUGIN_CONTINUE;
}
public cmdDodHelp(id)
{
	const SIZE = 1024;
	new msg[SIZE+1],len = 0;
	len += formatex(msg[len], SIZE - len, "<html><body bgcolor=^"black^">");
	len += formatex(msg[len], SIZE - len, "<center><font color=^"white^"><b><h1>DOD Character Mod Help</h1></b></font></center>");
	len += formatex(msg[len], SIZE - len, "<center><font color=^"white^"><b><h1>This is a little gameplay like in Day of Defeat!</h1></b></font></center>");
	len += formatex(msg[len], SIZE - len, "<center><font color=^"blue^"><u>Type /dodcmhelp to open this window!</u></font></center><br/>");
	len += formatex(msg[len], SIZE - len, "<center><font color=^"white^"><b><h3><i>Character's Information:</i></h3></b></font></center><br/>");
	len += formatex(msg[len], SIZE - len, "<font color=^"#4E9258^"><b><u>Riffleman:</u></b></font><font color=^"white^"> Have a M4A1, Knife, HE-Grenade, Glock18</font><br/>");
	len += formatex(msg[len], SIZE - len, "<font color=^"#4CC417^"><b><u>Assault:</u></b></font><font color=^"white^"> Have a Galil, Knife, SmokeGrenade, HE-Grenade, USP</font><br/>");
	len += formatex(msg[len], SIZE - len, "<font color=^"#617C58^"><b><u>Suport:</u></b></font><font color=^"white^"> Have a AK47, Knife, HE-Grenade</font><br/>");
	len += formatex(msg[len], SIZE - len, "<font color=^"#7FE817^"><b><u>Sniper:</u></b></font><font color=^"white^"> Have a AWP, Knife, Deagle, FlashBang/font><br/>");
	len += formatex(msg[len], SIZE - len, "<font color=^"#4AA02C^"><b><u>Machine Gunner:</u></b></font><font color=^"white^"> Have a Machinegun, Knife, P288</font><br/>");
	len += formatex(msg[len], SIZE - len, "</body></html>");

	show_motd(id, msg, "DOD Character Mod Help");
	return PLUGIN_CONTINUE;
}	
public clcmd_Buy(id)
{
	set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0));
	return 0;
}
public client_impulse(id)
{
	return PLUGIN_HANDLED;
}	
public death_msg()
{
	new victim = read_data(2);
	if(get_pcvar_num(CS_DOD_EnableDeadFade) == 1)
	{
		message_begin(MSG_ONE_UNRELIABLE, CS_DOD_DeadFade , {0,0,0}, victim);
		write_short(1<<10);
		write_short(1<<10);
		write_short(0x0000);
		write_byte(0);  //r
		write_byte(0);  //g
		write_byte(0);  //b
		write_byte(111);//alpha
		message_end();	
	}
	return 1;
}
public t_win()
{
	set_hudmessage(255, 0, 0, -1.0, 0.30, 1, 6.0, 8.0);
	show_hudmessage(0, "GERMANS WIN THE ROUND!");
}
public ct_win()
{
	set_hudmessage(0, 0, 255, -1.0, 0.30, 1, 6.0, 8.0);
	show_hudmessage(0, "U.S WIN THE ROUND!");
}	
stock color_print(id, const message[], {Float,Sql,Result,_}:...)
{
  	 new Buffer[128],Buffer2[128];
  	 new players[32], index, num, i;

 	 formatex(Buffer2, sizeof Buffer2 - 1, "%s",message);
 	 vformat(Buffer, sizeof Buffer - 1, Buffer2, 3);
 	 get_players(players, num,"c");
	
 	 if(id)
 	 {
     		message_begin(MSG_ONE_UNRELIABLE, CS_DOD_SayTextT, _, id);
    		write_byte(id);
     		write_string(Buffer);
      		message_end();
   	 }
  	 else
	 {
     		for(i = 0; i < num;i++)
      		{
         		index = players[i];

         		if(!is_user_connected(index))
            			continue;

         		message_begin(MSG_ONE_UNRELIABLE, CS_DOD_SayTextT, _, index);
         		write_byte(index);
         		write_string(Buffer);
         		message_end();
     		}
   	 }
}
