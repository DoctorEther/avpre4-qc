
// items
float	IT_AXE					= 2048;		// 1
float	IT_SHOTGUN				= 1;
float	IT_SUPER_SHOTGUN		= 2;
float	IT_NAILGUN				= 4;
float	IT_SUPER_NAILGUN		= 8;
float	IT_GRENADE_LAUNCHER		= 16;
float	IT_ROCKET_LAUNCHER		= 32;
float	IT_LIGHTNING			= 64;			// 8
float	IT_SHELLS				= 128;
float	IT_NAILS				= 256;
float	IT_ROCKETS				= 512;
float	IT_CELLS				= 1024;
float	IT_LAVA_NAILGUN			= 4096;		
float 	IT_LAVA_SUPER_NAILGUN	= 8192;			
float 	IT_MULTI_GRENADE		= 16384;		//15
float	IT_MULTI_ROCKET			= 32768;
float	IT_PLASMA_GUN			= 65536;	
float	IT_KEY1					= 131072;
float	IT_KEY2					= 262144;		
float	IT_INVISIBILITY			= 524288;
float	IT_INVULNERABILITY		= 1048576;
float	IT_SUIT					= 2097152;
float	IT_QUAD					= 4194304;		//23
//ZOID --
float	IT_GRAPPLE				= 0;		// grapple overload, hope it
float	IT_AVIAO				= 8388608;


const float	STAT_HEALTH			= 0;
const float	STAT_FRAGS			= 1;
const float	STAT_WEAPON			= 2;
const float	STAT_AMMO			= 3;
const float	STAT_ARMOR			= 4;
const float	STAT_WEAPONFRAME	= 5;
const float	STAT_SHELLS			= 6;
const float	STAT_NAILS			= 7;
const float	STAT_ROCKETS		= 8;
const float	STAT_CELLS			= 9;
const float	STAT_ACTIVEWEAPON	= 10;
const float	STAT_TOTALSECRETS	= 11;	// hmmm ...
const float	STAT_TOTALMONSTERS	= 12;	// must send this if new monsters are spawned after the map starts
const float	STAT_SECRETS		= 13;	// bumped on client side by svc_foundsecret
const float	STAT_MONSTERS		= 14;	// bumped by svc_killedmonster
const float STAT_ITEMS 			= 15;	// self.items | (self.items2<<23)
										// In order to decode this stat properly, you need to use 
										// getstatbits(STAT_ITEMS,0,23) to read self.items, and 
										// getstatbits(STAT_ITEMS,23,11) to read self.items2 or 
										// getstatbits(STAT_ITEMS,28,4) to read the visible part 
										// of serverflags, whichever is applicable
const float STAT_VIEWHEIGHT		= 16;	// player.view_ofs_z
const float STAT_VIEW2			= 20;	// This stat contains the number of the entity in the server's .view2 field
const float STAT_VIEWZOOM		= 21;	// Scales fov and sensitivity. Part of DP_VIEWZOOM
const float STAT_IDEALPITCH		= 25;
const float STAT_PUNCHANGLE_X	= 26;
const float STAT_PUNCHANGLE_Y	= 27;
const float STAT_PUNCHANGLE_Z	= 28;

/*
const float STAT_USER			= 32; // Custom user stats start here (lower values are reserved for engine use)
const float STAT_KEYCOUNTS		= 32;
const float STAT_CLIENTDATA		= 33;
const float STAT_TINTAMOUNT		= 34;
const float STAT_TINTCOLOR_R	= 35;	// you can send a vector as a stat but there's no accompanying getstatv
const float STAT_TINTCOLOR_G	= 36;	// so we have to send the three components separately and getstatf them
const float STAT_TINTCOLOR_B	= 37;
*/

const float STAT_SKATE_ON		= 35;
const float STAT_SKATE_POINTS	= 36;
const float STAT_SKATE_LAPS		= 37;
float skill;