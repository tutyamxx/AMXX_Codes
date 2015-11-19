#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <fakemeta>
#include <hamsandwich>

new const VERSION[] = "3.0.0"

const ACCESS_LEVEL = ADMIN_LEVEL_A

new Trie:g_tItems

public plugin_init()
{
	register_plugin("Half Life Give Items And Weapons", VERSION, "tuty")

	register_concmd("hl_weapon", "ConCmd_GiveWeapon", ACCESS_LEVEL, "<name> <weapon / @ALL> - give player a weapon | @ALL = all weapons" )
	register_concmd( "hl_item", "ConCmd_GiveItem", ACCESS_LEVEL, "<name> <item / @ALL> - give player a item | @ALL = all items" )

	g_tItems = TrieCreate()

	TrieSetString(g_tItems, "suit", "item_suit")
	TrieSetString(g_tItems, "battery", "item_battery")
	TrieSetString(g_tItems, "antidote", "item_antidote")
	TrieSetString(g_tItems, "security", "item_security")
	TrieSetString(g_tItems, "longjump", "item_longjump")
	TrieSetString(g_tItems, "healthkit", "item_healthkit")
}

public plugin_end()
{
	TrieDestroy( g_tItems )
}

public ConCmd_GiveWeapon( id, level, cid )
{
	if( !cmd_access( id, level, cid, 3 ) )
	{
		return PLUGIN_HANDLED
	}
	
	new szTarget[ 32 ]
	read_argv( 1, szTarget, charsmax( szTarget ) )
        
	new iTarget = cmd_target( id, szTarget, CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE )
	
	if( !iTarget )
	{
		return PLUGIN_HANDLED
	}

	new szWeaponName[ 19 ] = "weapon_"	
	read_argv( 2, szWeaponName[7], charsmax( szWeaponName ) - 7 )

	const WEAPON_CROWBAR = 1
	const WEAPON_SNARK = 15

	new iId

	if( equali(szWeaponName[7], "@ALL") )
	{
		for(iId = WEAPON_CROWBAR; iId<=WEAPON_SNARK; iId++)
		{
			get_weaponname(iId, szWeaponName, charsmax(szWeaponName))
			Give_User_Weapon(iTarget, szWeaponName, iId)
		}
	}
	else if( (iId = get_weaponid(szWeaponName)) > 0 )
	{
		Give_User_Weapon(iTarget, szWeaponName, iId)
	}
	else
	{
		console_print( id, "[HL] Invalid weapon name!" )
	}
	return PLUGIN_HANDLED
}  

Give_User_Weapon(const id, const szWeapon[], const iId)
{
	const URANIUM_MAX_CARRY = 100
	const _9MM_MAX_CARRY = 250
	const _357_MAX_CARRY = 36
	const BUCKSHOT_MAX_CARRY = 125
	const BOLT_MAX_CARRY = 50
	const ROCKET_MAX_CARRY = 5
	const HANDGRENADE_MAX_CARRY = 10
	const SATCHEL_MAX_CARRY = 5
	const TRIPMINE_MAX_CARRY = 5
	const SNARK_MAX_CARRY = 15
	const HORNET_MAX_CARRY = 8
	const M203_GRENADE_MAX_CARRY = 10

	new const g_iMaxAmmo[] = {0, 
		BUCKSHOT_MAX_CARRY, 
		_9MM_MAX_CARRY, 
		M203_GRENADE_MAX_CARRY,
		_357_MAX_CARRY, 
		URANIUM_MAX_CARRY, 
		ROCKET_MAX_CARRY, 
		BOLT_MAX_CARRY, 
		TRIPMINE_MAX_CARRY, 
		SATCHEL_MAX_CARRY, 
		HANDGRENADE_MAX_CARRY,
		SNARK_MAX_CARRY, 
		HORNET_MAX_CARRY
	}

	const XTRA_OFS_PLAYER = 5
	
	const m_rgAmmo_Slot0 = 309

	new iEnt
	if( !user_has_weapon(id, iId) )
	{
		iEnt = give_item(id, szWeapon)
	}
	else
	{
		const m_rgpPlayerItems_Slot0 = 300
		const MAX_ITEM_TYPES = 6

		const XTRA_OFS_WEAPON = 4
		const m_pNext = 29
		const m_iId = 30	

		for(new i=1; i<MAX_ITEM_TYPES; i++)
		{
			iEnt = get_pdata_cbase(id, m_rgpPlayerItems_Slot0 + i, XTRA_OFS_PLAYER)
			while( pev_valid(iEnt) )
        		{
            		if( get_pdata_int(iEnt, m_iId, XTRA_OFS_WEAPON) == iId )
            		{
            			// not sure if break would exit the 2 loops
                		goto set_bpammo
            		}
            		iEnt = get_pdata_cbase(iEnt, m_pNext, XTRA_OFS_WEAPON)
			}
		}
	}

set_bpammo:
	if( iEnt > 0 )
	{
		new iAmmoType
		iAmmoType = ExecuteHam(Ham_Item_PrimaryAmmoIndex, iEnt)
		if( iAmmoType > -1 )
		{
			set_pdata_int(id, m_rgAmmo_Slot0 + iAmmoType, g_iMaxAmmo[iAmmoType], XTRA_OFS_PLAYER)
		}
		iAmmoType = ExecuteHam(Ham_Item_SecondaryAmmoIndex, iEnt)
		if( iAmmoType > -1 )
		{
			set_pdata_int(id, m_rgAmmo_Slot0 + iAmmoType, g_iMaxAmmo[iAmmoType], XTRA_OFS_PLAYER)
		}
	}
}

public ConCmd_GiveItem( id, level, cid )
{
	if( !cmd_access( id, level, cid, 3 ) )
	{
		return PLUGIN_HANDLED
	}
	
	new szTarget[ 32 ]
	read_argv( 1, szTarget, charsmax( szTarget ) )
        
	new iTarget = cmd_target( id, szTarget, CMDTARGET_ALLOW_SELF|CMDTARGET_ONLY_ALIVE )
	
	if( !iTarget )
	{
		return PLUGIN_HANDLED
	}

	new szItem[15]
	read_argv( 2, szItem, charsmax( szItem ) )

	if( equali( szItem, "@ALL" ) )
	{
		give_item( iTarget, "item_battery" )
		give_item( iTarget, "item_healthkit" )
		give_item( iTarget, "item_longjump" )
		give_item( iTarget, "item_security" )
		give_item( iTarget, "item_antidote" )
		give_item( iTarget, "item_suit" )
	}
	else if( TrieGetString(g_tItems, szItem, szItem, charsmax(szItem)) )
	{
		give_item(iTarget, szItem)
	}
	else
	{
		console_print( id, "[HL] Invalid item name!" )
	} 
	return PLUGIN_HANDLED
}