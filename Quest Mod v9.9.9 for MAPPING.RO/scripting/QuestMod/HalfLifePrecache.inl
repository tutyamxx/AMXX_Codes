
/*
	
	====================================================
	Precache modele si sunete si sprite in Half-Life!
	Nu trebuie downloadate ca le are fiecare client!
	====================================================
	
*/


#define KNIFE_DEFAULT	"models/v_knife.mdl"
#define KNIFE_GORDON	"models/v_crowbar.mdl"
#define KNIFE_PDEF	"models/p_knife.mdl"
#define CRYSTAL_MODEL	"models/crystal.mdl"
#define AGRUNT_MODEL	"models/agrunt.mdl"
#define AGRUNT_MODEL_T	"models/agruntt.mdl"
#define MODEL_SPIT	"sprites/bigspit.spr"
#define GLASS_MODEL	"models/glassgibs.mdl"

#define DIE_SOUND	"scientist/scream1.wav"
#define CRYSTAL_SOUND	"barney/diebloodsucker.wav"
#define ACID_SOUND	"bullchicken/bc_acid1.wav"
#define TELEPORT_FAILED	"leech/leech_bite2.wav"
#define ICE_SOUND	"ambience/particle_suck1.wav"
#define ICE_DIE_SOUND	"weapons/deagle-1.wav"
#define FIREBALL_SOUND	"ambience/flameburst1.wav"

new const gThunderSprite[ ] = "sprites/lgtning.spr";
new const gSpriteTrail[ ] = "sprites/redflare2.spr";
new const gShockWaveSprite[ ] = "sprites/shockwave.spr";
new const gLaserbeamSprite[ ] = "sprites/laserbeam.spr";
new const gSpriteBeamHeall[ ] = "sprites/zbeam3.spr";
new const gSpriteSc2[ ] = "sprites/agrunt1.spr";
new const gAcidAcidSpr[ ] = "sprites/bm1.spr";
new const gBoltSprite[ ] = "sprites/bolt1.spr";
new const gWave1Sprite[ ] = "sprites/gwave1.spr";
new const gIceSmokeSprite[ ] = "sprites/bluejet1.spr";
new const gFireSpriteee[ ] = "sprites/xffloor.spr";
new const gFbExploSprrrr[ ] = "sprites/mushroom.spr";
new const gFbSmokesprrr[ ] = "sprites/steam1.spr";

new const gRootsSounds[ ][ ] = 
{
	"agrunt/ag_pain1.wav",
	"agrunt/ag_pain2.wav",
	"agrunt/ag_pain3.wav"
};

new const gTeleportSounds[ ][ ] =
{
	"plats/heavystop1.wav",
	"plats/heavystop2.wav",
	"plats/squeekstop1.wav"
};

new const gLightSounds[ ][ ] =
{
	"weapons/rocketfire1.wav",
	"roach/rch_smash.wav"
};

new const gScorpionSounds[ ][ ] =
{
	"aslave/slv_word2.wav",
	"aslave/slv_word4.wav",
	"aslave/slv_word5.wav",
	"aslave/slv_word6.wav"
};

new gSpitSounds[ ][ ] = 
{
	"bullchicken/bc_spithit1.wav",
	"bullchicken/bc_spithit2.wav"
};

new gFirePainSounds[ ][ ] =
{
	"scientist/sci_pain1.wav",
	"scientist/sci_pain2.wav",	
	"scientist/sci_pain3.wav",
	"scientist/sci_pain4.wav",
	"scientist/sci_pain7.wav",
	"scientist/sci_pain10.wav"
};

QuestMod_PrecacheFromHalfLife( )
{
	gSpriteIndex = precache_model( gThunderSprite );
	gSpriteIndex2 = precache_model( gSpriteTrail );
	gSpriteIndex3 = precache_model( gShockWaveSprite );
	gSpriteIndex4 = precache_model( gLaserbeamSprite );
	gSpriteBeamHeal = precache_model( gSpriteBeamHeall );
	gAgruntSprite = precache_model( gSpriteSc2 );
	gAcidSprite = precache_model( gAcidAcidSpr );
	gBoltSpritee = precache_model( gBoltSprite );
	gWave = precache_model( gWave1Sprite );
	gIceSmoke = precache_model( gIceSmokeSprite );
	gGlassModel = precache_model( GLASS_MODEL );
	gFireSprite = precache_model( gFireSpriteee );
	gFbExploSprite = precache_model( gFbExploSprrrr );
	gFbSmokeSprite = precache_model( gFbSmokesprrr );
	
	precache_model( KNIFE_GORDON );
	precache_model( CRYSTAL_MODEL );
	precache_model( AGRUNT_MODEL );
	precache_model( AGRUNT_MODEL_T );
	precache_model( MODEL_SPIT );
	precache_model( KNIFE_DEFAULT );
	precache_model( KNIFE_PDEF );
	
	precache_sound( CRYSTAL_SOUND );
	precache_sound( DIE_SOUND );
	precache_sound( ACID_SOUND );
	precache_sound( TELEPORT_FAILED );
	precache_sound( ICE_SOUND );
	precache_sound( ICE_DIE_SOUND );
	precache_sound( FIREBALL_SOUND );
	
	new i;
	
	for( i = 0; i < sizeof gRootsSounds; i++ )
	{
		precache_sound( gRootsSounds[ i ] );
	}
	
	for( i = 0; i < sizeof gTeleportSounds; i++ )
	{
		precache_sound( gTeleportSounds[ i ] );
	}

	for( i = 0; i < sizeof gLightSounds; i++ )
	{
		precache_sound( gLightSounds[ i ] );
	}

	for( i = 0; i < sizeof gScorpionSounds; i++ )
	{
		precache_sound( gScorpionSounds[ i ] );
	}
	
	for( i = 0; i < sizeof gSpitSounds; i++ )
	{
		precache_sound( gSpitSounds[ i ] );
	}
	
	for( i = 0; i < sizeof gFirePainSounds; i++ )
	{	
		precache_sound( gFirePainSounds[ i ] );
	}
	
	gBloodDecals[ 0 ] = engfunc( EngFunc_DecalIndex, "{yblood1" );
	gBloodDecals[ 1 ] = engfunc( EngFunc_DecalIndex, "{yblood2" );
	gBloodDecals[ 2 ] = engfunc( EngFunc_DecalIndex, "{yblood3" );
	gBloodDecals[ 3 ] = engfunc( EngFunc_DecalIndex, "{yblood4" );
	gBloodDecals[ 4 ] = engfunc( EngFunc_DecalIndex, "{yblood5" );
	gBloodDecals[ 5 ] = engfunc( EngFunc_DecalIndex, "{yblood6" );
}
