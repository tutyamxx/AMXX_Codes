
/*
	
	====================================================
	Cvaruri....
	====================================================

*/


QuestMod_RegisterCvars( )
{
	register_cvar( "questmod_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED );

	gCvarHighSpeed = register_cvar( "questmod_highspeed", "265" );
	gCvarLowSpeed = register_cvar( "questmod_lowspeed", "230" );
	gCvarLowGrav = register_cvar( "questmod_lowgravity", "0.9" );
	gCvarHealthAdd = register_cvar( "questmod_addhealth", "10" );
	gCvarHealthMax = register_cvar( "questmod_maxhealth", "1000" );
	gCvarDamage = register_cvar( "questmod_damage", "2" );
	gCvarVisibility = register_cvar( "questmod_visibility", "50" );
	gCvarThunderDmg = register_cvar( "questmod_thunderdmg", "10" );
	gCvarThunderInterval = register_cvar( "questmod_thunder_interval", "3" );
	gCvarTeleportInterval = register_cvar( "questmod_teleinterval", "200" );
	gCvarStopTime = register_cvar( "questmod_stoptime", "6" );
	gCvarNormGrav = register_cvar( "questmod_normalgrav", "0.0" );
	gCvarWeedInterval = register_cvar( "questmod_weedinterval", "20" );
	gCvarFlashInterval = register_cvar( "questmod_flashinterval", "5" );
	gCvarScorpionDmg = register_cvar( "questmod_scorpiondmg", "3" );
	gCvarMedicMaxHealth = register_cvar( "questmod_medicmaxhealth", "100" );
	gCvarMedicHealDistance = register_cvar( "questmod_medichealdistance", "300" );
	gCvarScientistTestDamage = register_cvar( "questmod_scientist_dmg", "300" );
	gCvarScientistTestDuration = register_cvar( "questmod_scientist_testdur", "6" );
	gCvarScientistTestDelay = register_cvar( "questmod_scientist_interval", "90" );
	gCvarReptileDmg = register_cvar( "questmod_reptile_dmg", "25" );
	gCvarReptileSpitDistance = register_cvar( "questmod_reptile_spitdist", "1666" );
	gCvarReptileSpitInterval = register_cvar( "questmod_reptile_spitinterval", "30" );
	gCvarSubzeroInterval = register_cvar( "questmod_subzero_interval", "200" );
	gCvarSubzeroDamage = register_cvar( "questmod_subzero_dmg", "400" );
	gCvarSubzeroIceTime = register_cvar( "questmod_subzero_icetime", "3" );
	gCvarFiremanDamage = register_cvar( "questmod_fireman_dmg", "1" );
	gCvarFiremanFireDuration = register_cvar( "questmod_fireman_fireduration", "16" );
	gCvarFiremanInterval = register_cvar( "questmod_fireman_interval", "40" );
	gCvarLiukangBallSpeed = register_cvar( "questmod_liukang_ballspeed", "921" );
	gCvarLiukangBallDamage = register_cvar( "questmod_liukang_balldamage", "50" );
	gCvarLiukangBallRadius = register_cvar( "questmod_liukang_ballradius", "100" );
	gCvarLiuKangBallInterval = register_cvar( "questmod_liukang_ballinterval", "33" );
}
