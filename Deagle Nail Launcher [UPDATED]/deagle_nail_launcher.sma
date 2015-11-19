/* Credits
* -------------
* 
*	() VEN 
*	() KleeneX
*	() Alka
*  	() Anakin
*
* Changelog
* --------------
*
* Version 2.3 
* --------------
*
* - first release
*
* Version 2.4
* --------------
*
* - added 2 cvars for bonus money and loose money when you kill a teammate
*
*
* Version 2.5
* -------------- 
*
* - optimized code
* - added a cool effect if you make damage to someone or yourself
* 
* Version 2.6
* --------------
*
* - optimized
* - added a smoke effect when nail explosion over
*
* Version 2.7
*
* - added 2 cvars
* - optimized
* - fakemeta only
*
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>

#define OFFSET_MONEY	115
#define ADMIN_CMD ADMIN_BAN
#define fm_find_ent_by_class(%1,%2)	engfunc(EngFunc_FindEntityByString, %1, "classname", %2)


new const PLUGIN[] 	= "Deagle Nail Launcher";
new const VERSION[] 	= "2.7+";
new const AUTH[] 	= "tuty";

new nail_MODEL[] 	= "models/nail.mdl";
new nail_SOUND[]	= "misc/spike1.wav";
new trail[] 		= "sprites/smoke.spr";
new explode[]		= "sprites/zerogxplode.spr";
new smokesZ[]		= "sprites/steam1.spr";
new nail_classname[]	= "deagle_nail";


new Float:was_nail[33];
new  trail2, explode2, smokesZ2;
new g_toggle_enable, g_toggle_speed, g_toggle_delay, g_toggle_trail_width;
new g_toggle_admin_only, g_toggle_damageradius, g_toggle_nail_damage, g_maxplayers;
new gMsgID, gDmsgID, g_toggle_colormode, gMsgIDMoney, g_toggle_moneybonus, g_toggle_loosemoney;
new g_fragbonus, g_loosefrags;

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTH);
	register_forward(FM_Touch, "pfn_touch" );
	register_forward(FM_StartFrame, "server_frame");
	register_logevent("logevent_round_end", 2, "1=Round_End");
	g_toggle_enable = register_cvar("nail_enable", "1");// 1-enabled/2-disabled
	g_toggle_admin_only= register_cvar("nail_admin_only", "0");// set this to 1 from ADMINONLY
	g_toggle_speed = register_cvar("nail_speed","600");// nail speed
	g_toggle_delay = register_cvar("nail_delay","3.0"); // nail delay
	g_toggle_damageradius = register_cvar("nail_damage_radius", "500");// nail explode radius damage
	g_toggle_nail_damage = register_cvar("nail_damage", "200");// nail damage when hit someone
	g_toggle_trail_width = register_cvar("nail_trail_width", "5");// trail width
	g_toggle_colormode = register_cvar("nail_trail_colormode", "1");// 0-grey and 1- team color (default: 1 - team color)
	g_toggle_moneybonus = register_cvar("nail_kill_money_bonus", "1000"); // the kill money bonus xD
	g_toggle_loosemoney = register_cvar("nail_tk_loose_money", "5000");// -money if you kill a teammate :|
	g_fragbonus = register_cvar("nail_fragbonus", "3"); // frag bonus when you kill some1 with nail
	g_loosefrags = register_cvar("nail_loosefrags", "5"); // loose frags when you kill a teammmate :
	
	gMsgID = get_user_msgid("Damage");
	gDmsgID = get_user_msgid("DeathMsg");
	gMsgIDMoney = get_user_msgid("Money");
	g_maxplayers = get_maxplayers();
}
public server_frame()
{
	if(get_pcvar_num(g_toggle_enable) == 0)
		return FMRES_IGNORED;
		
	new id;
	for(id = 1; id <= g_maxplayers; id++)
	{	
		if(is_user_alive(id))
		{
			check_nails(id);
		}
	}
	return FMRES_IGNORED;
}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, nail_MODEL);
	engfunc(EngFunc_PrecacheSound, nail_SOUND);
	trail2 = engfunc(EngFunc_PrecacheModel, trail);
	explode2 = engfunc(EngFunc_PrecacheModel, explode);
	smokesZ2 = engfunc(EngFunc_PrecacheModel, smokesZ);
}
public check_nails(id)
{	
	if(get_pcvar_num(g_toggle_enable) == 0)
		return PLUGIN_HANDLED;
		
	new wpnid = get_user_weapon(id);
	new button = pev(id, pev_button);
	
	if(wpnid == CSW_DEAGLE)
	{	
		if(button & IN_ATTACK2)
		{		
			launch_nail(id);
		}
		
	}
	return PLUGIN_CONTINUE;
}
public launch_nail(id)
{
	if(get_pcvar_num(g_toggle_admin_only) == 1)
	{	
		if(!(get_user_flags(id) & ADMIN_CMD))
		{
			log_amx("[DNL] The plugin has been set just 4 admins!");
			return PLUGIN_HANDLED;
		}
	}
	new Float:nexTime = get_gametime();
	if(was_nail[id] > nexTime)
	{	
		return PLUGIN_CONTINUE;
	}
	else
	{
		new nail = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
		
		if(nail == 0) 
			return PLUGIN_CONTINUE;
		
		set_pev(nail, pev_classname, nail_classname);
		engfunc(EngFunc_SetModel, nail, nail_MODEL);
		set_pev(nail, pev_size, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0});
		set_pev(nail, pev_movetype, MOVETYPE_FLY);
		set_pev(nail, pev_solid, SOLID_BBOX);
		
		new Float:vSrc[3];
		pev(id, pev_origin, vSrc);
		new Float:Aim[3], Float:origin[3];
		velocity_by_aim(id, 64, Aim);
		pev(id,pev_origin,origin);
		
		vSrc[0] += Aim[0];
		vSrc[1] += Aim[1];

		engfunc(EngFunc_SetOrigin, nail, vSrc);
		new Float:velocity[3], Float:angles[3];
		
		velocity_by_aim(id, get_pcvar_num(g_toggle_speed), velocity);
		set_pev(nail, pev_velocity, velocity);
		vector_to_angle(velocity, angles);
		set_pev(nail, pev_angles, angles);
		set_pev(nail, pev_owner,id);
		set_pev(nail, pev_takedamage, 1.0);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(nail);
		write_short(trail2);
		write_byte(25);
		write_byte(get_pcvar_num(g_toggle_trail_width));
		if(get_pcvar_num(g_toggle_colormode))
		{
			new r, g, b;
			switch(get_user_team(id))
			{
				case 1:
				{
					r = 255;
					g = 0; 
					b = 0;
				}
				case 2:
				{
					r = 0;
					g = 0; 
					b = 255;
				}
				default:
				{
					r = 211;
					g = 211; 
					b = 211;
				}
			}
			write_byte(r);
			write_byte(g);
			write_byte(b);
		}
		else 
		{	
			write_byte(211);
			write_byte(211);
			write_byte(211);
		}	
		write_byte(255);
		message_end();

		emit_sound(nail, CHAN_WEAPON, nail_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM);
		was_nail[id] = nexTime + get_pcvar_float(g_toggle_delay);
	}
	return PLUGIN_CONTINUE;
}
public pfn_touch(ptr, ptd)
{	
	if(get_pcvar_num(g_toggle_enable) == 1)
	{
		if(pev_valid(ptr))
		{	
			new classname[32];
			pev(ptr, pev_classname, classname, 31);
		
			if(equal(classname, nail_classname))
			{	
				new Float:fOrigin[3];
				new iOrigin[3];
				pev(ptr, pev_origin, fOrigin);
				FVecIVec(fOrigin,iOrigin);
			
				nail_radius_damage(ptr);
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY,iOrigin);
				write_byte(TE_EXPLOSION);
				write_coord(iOrigin[0]);
				write_coord(iOrigin[1]);
				write_coord(iOrigin[2]);
				write_short(explode2);
				write_byte(30);
				write_byte(15);
				write_byte(0);
				message_end();
			
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_SMOKE);
				write_coord(iOrigin[0]);
				write_coord(iOrigin[1]);
				write_coord(iOrigin[2]);
				write_short(smokesZ2);
				write_byte(40);
				write_byte(5);
				message_end();
				
				engfunc(EngFunc_RemoveEntity, ptr);
			}
		}
	}
}
public logevent_round_end()
{
	if(get_pcvar_num(g_toggle_enable) == 1)
	{
		new ent = -1;
		while((ent = fm_find_ent_by_class(ent, nail_classname)))
			engfunc(EngFunc_RemoveEntity, ent);		
	}
}
stock nail_radius_damage(entity)
{	
	new id = pev(entity, pev_owner);
	
	new i;
	for(i = 1; i <= g_maxplayers; i++)
	{	
		if(is_user_alive(i))
		{	
			new dist = floatround(fm_entity_range(entity,i));
			
			if(dist <= get_pcvar_num(g_toggle_damageradius))
			{	
				new hp = get_user_health(i);
				new Float:damage = get_pcvar_float(g_toggle_nail_damage)-(get_pcvar_float(g_toggle_nail_damage) / get_pcvar_float(g_toggle_damageradius))*float(dist);
				
				new Origin[3];
				get_user_origin(i,Origin);
				if(!get_cvar_num("mp_friendlyfire"))
				{	
					if(get_user_team(id) != get_user_team(i))
					{	
						if(hp > damage)
						{
							nail_take_damage(i, floatround(damage), Origin, DMG_BLAST);
						}
						else
						{
							nail_kill(id, i, "** Deagle-Nail **", 0);
						}
					}
				}
			}
		}
	}
}
stock nail_take_damage(victim,damage,origin[3],bit)
{
	message_begin(MSG_ONE_UNRELIABLE, gMsgID,{0,0,0}, victim);
	write_byte(21);
	write_byte(20);
	write_long(bit);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	message_end();
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); 
	write_byte(TE_LAVASPLASH); 
	write_coord(origin[0]); 
	write_coord(origin[1]); 
	write_coord(origin[2]); 
	message_end(); 
	
	fm_set_user_health(victim, get_user_health(victim) - damage);
}
stock nail_kill(killer, victim, weapon[],headshot)
{
	set_msg_block(gDmsgID , BLOCK_ONCE);
	user_kill(victim, 1);
	set_msg_block(gDmsgID, BLOCK_NOT);
	
	message_begin(MSG_ALL, gDmsgID, {0,0,0}, 0);
	write_byte(killer);
	write_byte(victim);
	write_byte(headshot);
	write_string(weapon);
	message_end();
	
	new money = fm_get_user_money(killer);
	if(get_user_team(killer)!= get_user_team(victim))
	{
		fm_set_user_frags(killer,get_user_frags(killer) + get_pcvar_num(g_fragbonus));
		fm_set_user_money(killer, money + get_pcvar_num(g_toggle_moneybonus));
	} 
	else 
	{
		fm_set_user_frags(killer,get_user_frags(killer) - get_pcvar_num(g_loosefrags));
		fm_set_user_money(killer, money - get_pcvar_num(g_toggle_loosemoney));
	}
 	return 1;
}
stock fm_get_user_money( index )
{
	new money = get_pdata_int(index, OFFSET_MONEY);
	return money;
}
stock fm_set_user_money(index, money, flash = 1)
{
	set_pdata_int(index, OFFSET_MONEY, money);
	fm_set_money(index, money, flash);
	return 1;
}
stock fm_set_money(index, money, flash)
{
	message_begin( MSG_ONE_UNRELIABLE, gMsgIDMoney, {0, 0, 0}, index);
	write_long(money);
	write_byte(flash ? 1 : 0);
	message_end();
	
}
