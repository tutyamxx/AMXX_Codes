
/* 

	====================================================
	Noile cutite + sprite + modele se vor adauga aici...
	====================================================

*/


#define KNIFE_HULK	"models/royal/v_hulk.mdl"
#define KNIFE_NINJA	"models/royal/v_ninja2.mdl"
#define KNIFE_FLASH	"models/royal/v_flash.mdl"
#define KNIFE_WOLF	"models/royal/v_wolf.mdl"
#define KNIFE_MUTANT	"models/royal/v_mutant2.mdl"
#define KNIFE_PREDATOR	"models/royal/v_predator.mdl"
#define KNIFE_NIGHT	"models/royal/v_night.mdl"
#define KNIFE_STORM	"models/royal/v_storm.mdl"
#define KNIFE_SPECTRU	"models/royal/v_spectru.mdl"
#define KNIFE_WEED	"models/royal/v_weed.mdl"
#define KNIFE_SCORPION	"models/royal/v_scorpion.mdl"
#define KNIFE_MEDIC	"models/royal/v_medic.mdl"
#define KNIFE_SCIENTIST "models/royal/v_scientist2.mdl"
#define KNIFE_REPTILE 	"models/royal/v_reptile.mdl"
#define KNIFE_SUBZERO 	"models/royal/v_subzero.mdl"
#define KNIFE_FIREMAN 	"models/royal/v_fireman.mdl"
#define KNIFE_LIUKANG	"models/royal/v_liukang.mdl"

#define ROOTS_MODEL	"models/roots2.mdl"
#define ICE_MODEL	"models/frostnova.mdl"
#define FIREBALL_MODEL	"models/liukangfb.mdl"

new const gSpritePlus[ ] = "sprites/heal.spr";

QuestMod_Precache( )
{
	gSpriteHeal = precache_model( gSpritePlus );
	
	precache_model( KNIFE_HULK );
	precache_model( KNIFE_NINJA );
	precache_model( KNIFE_FLASH );
	precache_model( KNIFE_WOLF );
	precache_model( KNIFE_MUTANT );
	precache_model( KNIFE_PREDATOR );
	precache_model( KNIFE_NIGHT );
	precache_model( KNIFE_STORM );
	precache_model( KNIFE_SPECTRU );
	precache_model( ROOTS_MODEL );
	precache_model( KNIFE_WEED );
	precache_model( KNIFE_SCORPION );
	precache_model( KNIFE_MEDIC );
	precache_model( KNIFE_SCIENTIST );
	precache_model( KNIFE_REPTILE );
	precache_model( KNIFE_SUBZERO );
	precache_model( KNIFE_FIREMAN );
	precache_model( KNIFE_LIUKANG );
	
	precache_model( ROOTS_MODEL );
	precache_model( ICE_MODEL );
	precache_model( FIREBALL_MODEL );
}
