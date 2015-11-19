
#include < amxmodx >
#include < fun >

#define MAX_PLAYERS		32 + 1

enum
{
	r,
	g,
	b
};

new const gGlowColors[ ][ ] = 
{
	{  -1 ,  -1 ,  -1 },
	{ 255 , 255 , 255 },	// ESFW_MELEE
	{ 255 , 255 , 255 },	// ESFW_SWORD
	{   0 , 255 , 255 },	// ESFW_KIBLAST
	{   0 ,   0 , 255 },	// ESFW_GENERICBEAM
	{ 199 ,  21 , 133 },	// ESFW_GALLITGUN
	{   0 , 255 , 255 },	// ESFW_KAMEHAMEHA
	{ 255 , 255 ,   0 },	// ESFW_DESTRUCTODISC
	{ 255 , 255 , 255 },	// ESFW_SOLARFLARE
	{ 199 ,  21 , 133 },	// ESFW_EYELASER
	{ 199 ,  21 , 133 },	// ESFW_FRIEZADISC
	{ 255 , 255 ,   0 },	// ESFW_SPECIALBEAMCANNON
	{   0 ,   0 , 255 },	// ESFW_SPIRITBOMB
	{   0 ,   0 , 255 },	// ESFW_BIGBANG
	{ 199 ,  21 , 133 },	// ESFW_FINGERLASER
	{ 255 , 255 ,   0 },	// ESFW_FINALFLASH
	{ 255 , 255 ,   0 },	// ESFW_MASENKO
	{ 205 ,  92 ,  92 },	// ESFW_DEATHBALL
	{ 255 , 255 ,   0 },	// ESFW_BURNINGATTACK
	{   0 ,   0 , 255 },	// ESFW_SCATTERBEAM
	{ 255 ,  20 , 147 },	// ESFW_CANDY
	{   0 , 255 , 255 },	// ESFW_SCATTERSHOT
	{   0 ,   0 , 255 },	// ESFW_POWERBEAM
	{ 255 ,  20 , 147 },	// ESFW_MOUTHBLAST
	{ 255 ,  20 , 147 },	// ESFW_FINISHINGBUSTER
	{ 210 , 105 ,  30 },	// ESFW_SENSU
	{ 255 , 165 ,   0 },	// ESFW_DRAGONBALL
	{   0 , 255 ,   0 },	// ESFW_BODYPART
	{   0 , 255 ,   0 },	// ESFW_SHIELDATTACK
	{ 255 ,  20 , 147 },	// ESFW_REGENERATION
	{   0 , 255 ,   0 },	// ESFW_RENZOKU
	{   0 , 255 , 255 },	// ESFW_KAMETORPEDO
	{ 255 , 255 , 255 },	// ESFW_TELEKINESIS
	{ 255 ,   0 ,   0 } 	// ESFW_FLAMETHROWER
};

new gGlowingEnabled;
new gGlowTickness;

new gCurWeapon[ MAX_PLAYERS ];
new gBot[ MAX_PLAYERS ];

public plugin_init()
{
	register_plugin( "ESF Glow by Weapon", "4.0.0", "tuty" );
	
	register_event( "CurWeapon", "Hook_CurWeapon", "be", "1=1" );
	
	gGlowingEnabled = register_cvar( "esf_glow", "1" );
	gGlowTickness = register_cvar( "esf_glow_tickness", "70" );
}

public client_putinserver( id )
{
	gBot[ id ] = is_user_bot( id );
}

public Hook_CurWeapon( id )
{
	if( get_pcvar_num( gGlowingEnabled ) != 1 || gBot[ id ] )
	{
		return;
	}
	
	new iCurWeapon = read_data( 2 );

	if( iCurWeapon == gCurWeapon[ id ] )
	{
		return;
	}

	gCurWeapon[ id ] = iCurWeapon;
	set_user_rendering( id, kRenderFxGlowShell, gGlowColors[ iCurWeapon ][ r ], gGlowColors[ iCurWeapon ][ g ], gGlowColors[ iCurWeapon ][ b ], kRenderNormal, get_pcvar_num( gGlowTickness ) );
}
