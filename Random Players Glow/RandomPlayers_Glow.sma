/*	Copyright © 2010, tuty
	Random Players Glow is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Teleport Destination Angles Editor; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/



#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >
#include < fun >

#pragma semicolon 1

#define PLUGIN_VERSION	"1.0.0"

#define ADMIN_ACCESS	ADMIN_CFG

new gGlowEnabled;
new gGlowAdminOnly;
new gGlowThickness;

new gRandomColors[ 3 ];

public plugin_init()
{
	register_plugin( "Random Players Glow", PLUGIN_VERSION, "tuty" );
	
	RegisterHam( Ham_Spawn, "player", "bacon_PlayerSpawn", 1 );
	
	gGlowEnabled = register_cvar( "playersglow_enabled", "1" );
	gGlowAdminOnly = register_cvar( "playersglow_admin_only", "0" );
	gGlowThickness = register_cvar( "playersglow_thickness", "10" );
}

public bacon_PlayerSpawn( id )
{
	if( get_pcvar_num( gGlowEnabled ) != 0 )
	{
		new iThickness = get_pcvar_num( gGlowThickness );
		
		gRandomColors[ 0 ] = random_num( 0, 255 );
		gRandomColors[ 1 ] = random_num( 0, 255 );
		gRandomColors[ 2 ] = random_num( 0, 255 );
		
		if( is_user_alive( id ) )
		{
			if( get_pcvar_num( gGlowAdminOnly ) == 1 )
			{
				if( get_user_flags( id ) & ADMIN_ACCESS )
				{
					set_user_rendering( id, kRenderFxGlowShell, gRandomColors[ 0 ], gRandomColors[ 1 ], gRandomColors[ 2 ], kRenderNormal, iThickness );
				}
			}
			
			set_user_rendering( id, kRenderFxGlowShell, gRandomColors[ 0 ], gRandomColors[ 1 ], gRandomColors[ 2 ], kRenderNormal, iThickness );
		}
	}
}
