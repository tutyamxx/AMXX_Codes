#include <amxmodx>
#include <fakemeta>

//credits anakin[hs] :X:X

#define PLUGIN "Solar Flash"
#define VERSION "3.0"
#define AUTHOR "tuty"

#define ammount 20

new g_solar, g_solartrail, g_solarsprite, g_solarbartime, g_solarglownade, g_solarbartimeoff, g_solarflashtime, g_solarbarttime;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_forward(FM_SetModel,"fw_setmodel",1);
	register_event("ScreenFade","flash_event","be","4=255","5=255","6=255","7>199");
	
	g_solarbartime = get_user_msgid("BarTime");
	
	g_solar = register_cvar("solar_flash", "1"); // enable/disable plugin
	g_solartrail = register_cvar("solar_trail", "1"); //enable/disable trail
	g_solarglownade = register_cvar("solar_glow", "1"); // the nade is orange
	g_solarbartimeoff = register_cvar("solar_bartime", "1"); // enable/disable bartime on fade
	g_solarflashtime = register_cvar("solar_flashtime", "8");// this two must be exactly on same time after you change
	g_solarbarttime = register_cvar("solar_barttime", "8");// read up
	
	
}
public plugin_precache()
{
	g_solarsprite = precache_model("sprites/xbeam3.spr");
}
public fw_setmodel(ent,model[])
{
	if(get_pcvar_num(g_solartrail) == 0) return FMRES_IGNORED;
	
	if(!equali(model,"models/w_flashbang.mdl"))
		return FMRES_IGNORED;
	
	if(get_pcvar_num(g_solarglownade) == 1)
	{
		
		fm_set_rendering(ent ,kRenderFxGlowShell,245,157,57,kRenderNormal,ammount);
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short( ent);
	write_short( g_solarsprite );
	write_byte( 30 );
	write_byte( 9 );
	write_byte( 245 );
	write_byte( 157 );
	write_byte( 57 );
	write_byte( 192 );
	message_end();
	
	return FMRES_IGNORED;
}
			
public flash_event(id)
{
	if(get_pcvar_num(g_solar) == 0) return PLUGIN_CONTINUE;
		
	screen_fade(id, 1, get_pcvar_num(g_solarflashtime), 245, 157 , 57 , 255);

	if(get_pcvar_num(g_solarbartimeoff) == 1)
	{
		
		message_begin(MSG_ONE,g_solarbartime,_,id);
		write_short(get_pcvar_num(g_solarbarttime));
		message_end();
	}
	
	return PLUGIN_CONTINUE;
	
}

fm_set_rendering(index, fx=kRenderFxNone, r=255, g=255, b=255,render=kRenderNormal,amount=16)
{
	set_pev(index, pev_renderfx, fx);
	
	new Float:RenderColor[3];
	RenderColor[0] = float(r);  
	RenderColor[1] = float(g);  
	RenderColor[2] = float(b); 
	
	set_pev(index, pev_rendercolor, RenderColor);
	set_pev(index, pev_rendermode, render);  
	set_pev(index, pev_renderamt, float(amount));
	
	return 1; 
}

stock screen_fade(index, iDuration, iHoldTime, r, g, b, alpha)
{

   	if(!is_user_alive(index))
      		return 0;


   	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, index );
	write_short(fade_units_to_seconds(iDuration));
   	write_short(fade_units_to_seconds(iHoldTime));
   	write_short(0x0000);
   	write_byte(r);
   	write_byte(g);
   	write_byte(b);
   	write_byte(alpha);
   	message_end();

   	return 1;
}
stock fade_units_to_seconds(num) return ((1<<12) * (num));
