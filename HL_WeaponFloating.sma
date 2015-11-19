
#include < amxmodx >

#include < engine >
#include < hamsandwich >

#pragma semicolon 1

new const gHalfLifeItemNames[ ][ ] =
{
	"item_battery", 
	"item_healthkit", 
	"item_longjump", 
	"item_suit"
};

new const gHalfLifeWeaponEntitiesNames[ ][ ] = 
{
	"ammo_357", "ammo_9mmAR", "ammo_9mmbox", "ammo_9mmclip", "ammo_ARgrenades",
	"ammo_buckshot", "ammo_crossbow", "ammo_egonclip", "ammo_gaussclip", "ammo_glockclip",
	"ammo_mp5clip", "ammo_mp5grenades", "ammo_rpgclip", "weaponbox", "weapon_357", 
	"weapon_9mmAR", "weapon_9mmhandgun", "weapon_crossbow", "weapon_egon", "weapon_gauss",
	"weapon_glock", "weapon_handgrenade", "weapon_hornetgun", "weapon_mp5", "weapon_python",
	"weapon_rpg", "weapon_satchel", "weapon_shotgun", "weapon_snark", "weapon_tripmine"
};

new gFloatingWeaponsEnabled;
new gFloatingWeaponsGlow;
new gFloatingWeaponsSpeed;
new gFloatingWeaponsGlowThickness;

public plugin_init( )
{
	register_plugin( "HL Weapons Floating", "2.0.0", "tuty" );

	new i;

	for( i = 0; i < sizeof( gHalfLifeWeaponEntitiesNames ); i++ )
	{
		register_touch( gHalfLifeWeaponEntitiesNames[ i ], "worldspawn", "WeaponsTouchTheGround" );
		register_touch( gHalfLifeWeaponEntitiesNames[ i ], "func_wall", "WeaponsTouchTheGround" );
	}

	for( i = 0; i < sizeof( gHalfLifeItemNames ); i++ )
	{
		RegisterHam( Ham_Respawn, gHalfLifeItemNames[ i ], "bacon_ItemsRespawned" );
	}

	gFloatingWeaponsEnabled = register_cvar( "hl_fw_enabled", "1" );
	gFloatingWeaponsGlow = register_cvar( "hl_fw_glow", "1" );
	gFloatingWeaponsSpeed = register_cvar( "hl_fw_speed", "25.0" );
	gFloatingWeaponsGlowThickness = register_cvar( "hl_fw_glow_thickness", "10.0" );
}

public WeaponsTouchTheGround( iEntity, iWorldspawn )
{
	if( get_pcvar_num( gFloatingWeaponsEnabled ) != 0 
	&& is_valid_ent( iEntity ) )
	{
		FloatAndSpinWeapons( iEntity );
	}
}

public bacon_ItemsRespawned( iEntity )
{
	if( get_pcvar_num( gFloatingWeaponsEnabled ) != 0 )
	{
		entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_TOSS );
		drop_to_floor( iEntity );
		
		FloatAndSpinWeapons( iEntity );
	}
}

public FloatAndSpinWeapons( iEntity )
{
	new Float:flWeaponOrigin[ 3 ];
	entity_get_vector( iEntity, EV_VEC_origin, flWeaponOrigin );
		
	flWeaponOrigin[ 2 ] += 30.0;
	entity_set_origin( iEntity, flWeaponOrigin );

	new Float:flAngles[ 3 ];
	entity_get_vector( iEntity, EV_VEC_angles, flAngles );
	
	flAngles[ 0 ] -= float( random( 80 ) );
	flAngles[ 1 ] += float( random( 50 ) );
	
	entity_set_vector( iEntity, EV_VEC_angles, flAngles );
	entity_set_int( iEntity, EV_INT_movetype, MOVETYPE_NOCLIP );

	set_task( 0.9, "WeaponSpinGoGo", iEntity );
		
	if( get_pcvar_num( gFloatingWeaponsGlow ) == 1 )
	{
		new Float:flRenderColor[ 3 ];
			
		flRenderColor[ 0 ] = random_float( 0.0, 255.0 );
		flRenderColor[ 1 ] = random_float( 0.0, 255.0 );
		flRenderColor[ 2 ] = random_float( 0.0, 255.0 );

		entity_set_int( iEntity, EV_INT_renderfx, kRenderFxGlowShell );
		entity_set_vector( iEntity, EV_VEC_rendercolor, flRenderColor );
		entity_set_float( iEntity, EV_FL_renderamt, get_pcvar_float( gFloatingWeaponsGlowThickness ) );
	}
}

public WeaponSpinGoGo( iEntity )
{
	if( is_valid_ent( iEntity ) )
	{
		new Float:flAvelocity[ 3 ];
		
		flAvelocity[ 0 ] = 0.0;
		flAvelocity[ 1 ] = get_pcvar_float( gFloatingWeaponsSpeed );
		flAvelocity[ 2 ] = 0.0;
		
		entity_set_vector( iEntity, EV_VEC_avelocity, flAvelocity );
	}
}
