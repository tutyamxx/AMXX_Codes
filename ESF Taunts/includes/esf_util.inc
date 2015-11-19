/********************************************************************************************
*										            *		 
* 	========================================================			    *
*	|		by tuty and hip_hop_x 		       |			    *	
*	========================================================			    *
*											    *
*	This file is provided as is (no warranties).				 	    *	 
*											    *	
*	========================================================			    *
*	|	contact: Tuty --> tuty_max_boy@yahoo.com       |			    *	
*	|	contact: HipHopX --> hip_hop_x_ax@yahoo.com    |			    *
*	========================================================			    *
*											    *
*	Credits goes to:								    *	
*	----------------								    *	
*		= Zenith77								    *	
*		= Zero									    *
*		= GameBak								    *
*		= ConnorMcLeod		+++++++++					    *
*		= Spunky		+++						    *
*		= hleV			++						    *
*										   	    *
 ********************************************************************************************/

 
 

#if defined _esf_util_included
  #endinput
#endif
#define _esf_util_included

#include <fakemeta>




/*******************************
|				|
|  ID of Weapons in ESF		|
|				|
********************************/

#define ESFW_NONE		0	//  no weapon
#define ESFW_MELEE		1	//  melee weapon
#define ESFW_SWORD		2	//  trunks sword weapon
#define ESFW_KIBLAST		3	//  kitblast weapon
#define ESFW_GENERICBEAM	4	//  genericbeam weapon
#define ESFW_GALLITGUN		5	//  vegeta's gallitgun weapon
#define ESFW_KAMEHAMEHA		6	//  kamehameha weapon
#define ESFW_DESTRUCTODISC	7	//  krillin's destructo disc weapon
#define ESFW_SOLARFLARE		8	//  solar flare weapon
#define ESFW_EYELASER		9	//  piccolo's eye laser o.O
#define ESFW_FRIEZADISC		10 	//  frieza's disc weapon
#define ESFW_SPECIALBEAMCANNON	11	//  piccolo's special beam cannon weapon
#define ESFW_SPIRITBOMB		12	//  goku spirit bomb weapon
#define ESFW_BIGBANG		13	//  vegeta's big bang attack weapon
#define ESFW_FINGERLASER	14	//  frieza's finger lsaer weapon
#define ESFW_FINALFLASH		15	//  vegeta's final flash weapon
#define ESFW_MASENKO		16	//  masenko weapon ( gohan's and piccolo's )
#define ESFW_DEATHBALL		17	//  frieza's death ball weapon
#define ESFW_BURNINGATTACK	18	//  trunks burning attack weapon
#define ESFW_SCATTERBEAM	19	//  scatter beam weapon
#define ESFW_CANDY		20	//  buu's candy weapon
#define ESFW_SCATTERSHOT	21	//  scatter shot weapon
#define ESFW_POWERBEAM		22	//  power beam weapon
#define ESFW_MOUTHBLAST		23	//  mouth blast weapon
#define ESFW_FINISHINGBUSTER	24	//  finishing buster weapon
#define ESFW_SENSU		25	//  sensu weapon ( with this you can eat sensubeans if you have ) 
#define ESFW_DRAGONBALL		26	//  deagonball weapon ( you can hold dragon balls i think.. i never used )
#define ESFW_BODYPART		27	//  idk wtf is this =]
#define ESFW_SHIELDATTACK	28	//  shield attack weapon
#define ESFW_REGENERATION	29	//  buu's regeneration weapon
#define ESFW_RENZOKU		30	//  gohan's scout (renzoku) weapon
#define ESFW_KAMETORPEDO	31	//  kame torpedo weapon :X my favorite :-"
#define ESFW_TELEKINESIS	32	//  piccolo's telekinesis weapon
#define ESFW_FLAMETHROWER	33	//  flamethrower weapon ;]




/*******************************
|				|
|  Weapon Names in ESF		|
|				|
********************************/

/************************
"weapon_melee"			
"weapon_sword"			
"weapon_kiblast"		
"weapon_genericbeam" 		
"weapon_gallitgun"		
"weapon_kamehameha"		
"weapon_destructodisc"		
"weapon_solarflare"		
"weapon_eyelaser"	
"weapon_friezadisc"		
"weapon_specialbeamcannon"	
"weapon_spiritbomb"		
"weapon_bigbang"		
"weapon_fingerlaser"		
"weapon_finalflash"		
"weapon_masenko"		
"weapon_deathball"		
"weapon_burningattack"		
"weapon_scatterbeam"			
"weapon_candy"			
"weapon_scattershot"		
"weapon_powerbeam"		
"weapon_mouthblast"		
"weapon_finishingbuster"	
"weapon_sensu"			
"weapon_dragonball"		
"weapon_bodypart"	
"weapon_shieldattack"		
"weapon_regeneration"		
"weapon_renzoku"		
"weapon_kametorpedo"		
"weapon_telekinesis"		
"weapon_flamethrower"

************************/




/***************************************
|				        |
|   Set KI to a player	       		|
|   Note: if you set KI over 1000,  	|
|   the KI box will have a bigger width |
|   How to use: esf_set_ki( id , 250 )  |
|					|
****************************************/
#define esf_set_ki(%1,%2)	set_pev(%1, pev_fuser4, float(%2))  




/*******************************************
|				            |
|     Set PowerLevel to a player            |
|     How to use: 		            |
|     esf_set_powerlevel( id , 60.000.000 ) |
|				  	    |
********************************************/
#define esf_set_powerlevel(%1,%2)	set_pdata_int(%1, 460, %2)




/****************************************
|				         |
|   Return PowerLevel from a player	 |
|   How to use: esf_get_powerlevel( id ) |
|					 |
*****************************************/
#define esf_get_powerlevel(%1)	get_pdata_int(%1, 460)




/*****************************************
|				          |
|   Return ActualPowerLevel from a player |
|   How to use: esf_get_acpl( id )  	  |
|					  |
******************************************/
#define esf_get_acpl(%1)	get_pdata_int(%1, 463)




/*******************************************
|				            |
|   Set ActualPowerlevel to a player	    |
|   How to use: esf_set_acpl( id, 940000 )  |
|					    |
********************************************/
#define esf_set_acpl(%1, %2)	set_pdata_int(%1, 463, %2)




/*******************************************
|				            |
|   Get MaximumHealth from a player	    |
|   How to use: esf_get_maxhealth( id )	    |
|					    |
********************************************/
#define esf_get_maxhealth(%1)	get_pdata_int(%1, 142)




/*******************************************
|				            |
|   Set Speed to a player		    |
|   How to use: esf_set_speed(id, speed)    |
|					    |
********************************************/
#define esf_set_speed(%1,%2)	set_pdata_int(%1, 462, %2)




/*******************************************
|				            |
|   Get speed from a player		    |
|   How to use: esf_get_speed(id)    	    |
|					    |
********************************************/
#define esf_get_speed(%1)	get_pdata_int(%1, 462)




/********************************************
|				             |
|   Set swoopspeed to a player		     |
|   How to use: esf_set_swoopspeed(id, speed |
|					     |
*********************************************/
#define esf_set_swoopspeed(%1,%2)	set_pev(%1, pev_fuser1, float(%2)) 




/*******************************************
|				            |
|   Get swoopspeed from a player	    |
|   How to use: esf_get_swoopspeed(id)      |
|					    |
********************************************/
#define esf_get_swoopspeed(%1)	pev(%, pev_fuser1)




/*******************************************
|				            |
|   Return if a user is flying		    |
|   How to use: esf_get_fly(id)     	    |
|					    |
********************************************/
#define esf_get_fly(%1)	get_pdata_int(%1, 195)




/*******************************************
|				            |
|   Get turbo from a player		    |
|   How to use: esf_get_turbo(id)     	    |
|					    |
********************************************/
#define esf_get_turbo(%1)	get_pdata_int(%1, 196)




/*******************************************
|				            |
|   Get powerup from a player		    |
|   How to use: esf_get_powerup(id)         |
|					    |
********************************************/
#define esf_get_powerup(%1)	get_pdata_int(%1, 199)




/*******************************************
|				            |
|   Return if a player is swooping	    |
|   How to use: esf_get_swooping(id)        |
|					    |
********************************************/
#define esf_get_swooping(%1)	get_pdata_int(%1, 317)




/*******************************************
|				            |
|   Get's a player attack charge	    |
|   How to use: esf_get_attack_charge(id)   |
|					    |
********************************************/
#define esf_get_attack_charge(%1)	get_pdata_int(%1, 200)




/*******************************************
|				            |
|   Get's a player advanced melee	    |
|   How to use: esf_get_advancedmelee(id)   |
|					    |
********************************************/
#define esf_get_advancedmelee(%1)	get_pdata_int(%1, 298)




/***********************************************************
|				           		    |
|   Return if player is blocking attack from other player   |
|   How to use: esf_get_block(id)   		   	    |
|					    		    |
************************************************************/
#define esf_get_block(%1)	get_pdata_int(%1, 198)




/*******************************************
|				            |
|   Get if player has been thrown into wall |
|   or on ground			    |
|   How to use: esf_get_throw(id)           |
|					    |
********************************************/
#define esf_get_throw(%1)	get_pdata_int(%1, 230)




/*******************************************
|				            |
|   Get deaths from a player  		    |
|   How to use: esf_get_user_deaths(id)     |
|					    |
********************************************/
#define esf_get_user_deaths(%1)		get_pdata_int(%1, 604, 5)




/***************************************
|				        |
|	Return KI from a player         |
|	Note: the maximum KI is 1000!   | 
| 	How to use: esf_get_ki(id)      |
|					|
****************************************/
stock esf_get_ki( index )
{
	if( !is_user_alive( index ) )
	{
		return 0;
	}
	new Float:value;
	pev( index, pev_fuser4, value );
	
	return floatround( value );
}




/***********************************************
|				        	|
|   Set MaximumHealth to a player		|
|   Note: if you set MaximumHealth over 1000,  	|
|   over 1000 HealthBar exchanges!		|
|   HealthBar get's increased :D		|
|   How to use: esf_set_maxhealth(id, 1000)	|
|					 	|
************************************************/
stock esf_set_maxhealth( index, health )
{
	set_pdata_int( index, 142, health );
	message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "MaxHealth" ), { 0, 0, 0 }, index );
	write_byte( health );
	message_end();
}




/*******************************************
|				            |
|   Return player TEAM	  		    |
|   How to use: esf_get_team(id) 	    |
|					    |
********************************************/
stock esf_get_team( index )
{
	new szTeamName[ 2 ];
	get_user_team( index, szTeamName, charsmax( szTeamName ) );

	switch( szTeamName[ 0 ] )
	{
		case 'G': return 1; // if player team is GOOD
		case 'E': return 2; // if player team is EVIL
	}
	return 0;
}




/*******************************
|				|
|  Enum ESF player classes	|
|				|
********************************/
enum
{
        ESF_CLASS_NONE = 0,
 
        ESF_CLASS_BUU,
        ESF_CLASS_GOKU,
        ESF_CLASS_GOHAN,
        ESF_CLASS_KRILLIN,
        ESF_CLASS_FRIEZA,
        ESF_CLASS_PICCOLO,
        ESF_CLASS_TRUNKS,
        ESF_CLASS_VEGETA,
        ESF_CLASS_CELL
};
/*******************************************
|				            |
|   Return PlayerClass from a player	    |
|   How to use: esf_get_player_class( id )  |
|					    |
********************************************/
#define esf_get_player_class(%1)	pev(%1, pev_playerclass)

