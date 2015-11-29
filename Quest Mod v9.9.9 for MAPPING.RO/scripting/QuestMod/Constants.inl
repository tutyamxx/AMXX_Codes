
/*
	
	====================================================
	Constante, globale, booleanuri si definitii aici!
	====================================================

*/


#define PLUGIN_VERSION		"9.9.9"

#define FFADE_IN    		0x0000
#define TASK_INTERVAL		4.0
#define INVALID_PLAYER		-1
#define ACIDSPIT_ENTID		88177
#define MAX_PLAYERS		32 + 1
#define MAX_FAIL_TELEPORTS	3
#define BREAK_GLASS		0x01

#define ADMIN_QUEST_ACCESS	ADMIN_CFG

#define TASKID_HEALING		312812
#define TASKID_SCORPION		100031
#define TASKID_ROOTS		988998
#define TASKID_TELEPORT		222331
#define TASKID_CRYSTAL		431239
#define TASKID_SCIENCE		112207
#define TASKID_SUBZERO		137916
#define TASKID_FIREMAN		133761

new gSpriteIndex;
new gMessageScreenFade;
new gMessageScreenShake;
new gMessageSayText;
new gClCorpseMessage;
new gMaxPlayers;
new gSpriteIndex2;
new gSpriteIndex3;
new gSpriteIndex4;
new gSpriteHeal;
new gSpriteBeamHeal;
new gAcidSprite;
new gHudSync1;
new gHudSync2;
new gAgruntSprite;
new gBoltSpritee;
new gWave;
new gGlassModel;
new gIceSmoke;
new gFireSprite;
new gFbExploSprite;
new gFbSmokeSprite;

new bool:bIsHigh[ MAX_PLAYERS ];
new gKnifeModel[ MAX_PLAYERS ];
new bChoose[ MAX_PLAYERS ];
new bGrabTarget[ MAX_PLAYERS ];

new Float:bflLastUsed[ MAX_PLAYERS ];
new Float:bflLastUsed2[ MAX_PLAYERS ];
new Float:bflLastUsed3[ MAX_PLAYERS ];
new Float:bflLastUsed4[ MAX_PLAYERS ];
new Float:bflLastUsed5[ MAX_PLAYERS ];
new Float:bflLastUsed6[ MAX_PLAYERS ];
new Float:bflLastUsed7[ MAX_PLAYERS ];
new Float:bflLastUsed8[ MAX_PLAYERS ];
new Float:bflLastUsed9[ MAX_PLAYERS ];

new Float:bflLastHealed[ MAX_PLAYERS ];

new bTeleportFailedCount[ MAX_PLAYERS ];
new gBloodDecals[ 6 ];

new Float:gSpitColor[ 3 ] = { 255.0, 170.0, 42.0 };

new gCvarHighSpeed;
new gCvarLowSpeed;
new gCvarLowGrav;
new gCvarNormGrav;
new gCvarHealthAdd;
new gCvarHealthMax;
new gCvarDamage;
new gCvarVisibility;
new gCvarThunderDmg;
new gCvarTeleportInterval;
new gCvarThunderInterval;
new gCvarStopTime;
new gCvarWeedInterval;
new gCvarFlashInterval;
new gCvarScorpionDmg;
new gCvarMedicMaxHealth;
new gCvarMedicHealDistance;
new gCvarScientistTestDamage;
new gCvarScientistTestDuration;
new gCvarScientistTestDelay;
new gCvarReptileDmg;
new gCvarReptileSpitDistance;
new gCvarReptileSpitInterval;
new gCvarSubzeroInterval;
new gCvarSubzeroDamage;
new gCvarSubzeroIceTime;
new gCvarFiremanDamage;
new gCvarFiremanFireDuration;
new gCvarFiremanInterval;
new gCvarLiukangBallSpeed;
new gCvarLiukangBallDamage;
new gCvarLiukangBallRadius;
new gCvarLiuKangBallInterval;
