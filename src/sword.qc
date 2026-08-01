/*
==============================================================================

SWORD

==============================================================================
*/

$cd /qwork/xpack/models/sword
$origin 0 0 24
$base base
$skin badass3

$frame stand1
//$stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame runb1 runb2 runb3 runb4 runb5 runb6 runb7 runb8

//frame runc1 runc2 runc3 runc4 runc5 runc6

//$frame runattack1 runattack2 runattack3 runattack4 runattack5
//$frame runattack6 runattack7 runattack8 runattack9 runattack10
//$frame runattack11

//$frame pain1 pain2 pain3

//$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9
//$frame painb10 painb11

//frame attack1 attack2 attack3 attack4 attack5 attack6 attack7
//frame attack8 attack9 attack10 attack11

$frame attackb1 attackb2 attackb3 attackb4 attackb5
$frame attackb6 attackb7 attackb8 attackb9 attackb10

//$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
//$frame walk10 walk11 walk12 walk13 walk14

//$frame kneel1 kneel2 kneel3 kneel4 kneel5

//$frame standing2 standing3 standing4 standing5

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9 deathb10 deathb11

void() sword_stand1 = [ $stand1, sword_stand1 ] { ai_stand(); };

void() sword_run1 = [ 1, sword_run2 ] { ai_run(14); };
void() sword_run2 = [ 2, sword_run3 ] { ai_run(14); };
void() sword_run3 = [ 3, sword_run4 ] { ai_run(14); };
void() sword_run4 = [ 4, sword_run5 ] { ai_run(14); };
void() sword_run5 = [ 10, sword_run6 ] { ai_run(14); };
void() sword_run6 = [ 11, sword_run1 ] { ai_run(14); };

void() sword_atk1 = [ 5, sword_atk2 ] { ai_charge(14); sound(self, 0, "knight/sword1.wav", 1, 1);};
void() sword_atk2 = [ 6, sword_atk3 ] { ai_charge(14); };
void() sword_atk3 = [ 7, sword_atk4 ] { ai_charge(14); ai_melee(); };
void() sword_atk4 = [ 8, sword_atk5 ] { ai_charge(14); ai_melee(); };
void() sword_atk5 = [ 9, sword_run1 ] { ai_charge(14); };

//===========================================================================

void() sword_die1 = [ $death1, sword_die2 ] {self.solid = SOLID_NOT;self.ammo_nails = 5;DropBackpack();};
void() sword_die2 = [ $death1, sword_die2 ] {};


void() sword_die =
{


// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}


    // regular death
    self.effects = 0;
    //if (random() < 0.5)
        sword_die1 ();
    //else
    //    sword_dieb1 ();
};


void(entity attacker, float damage) sword_pain =
{}


void() monster_sword =
{
    if (deathmatch)
    {
        remove(self);
        return;
    }

    precache_model("progs/sword.mdl");
    precache_model("progs/h_guard.mdl");

    precache_sound("knight/sword1.wav");
    precache_sound("knight/ksight.wav");
    precache_sound("player/axhit2.wav");

    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;

    setmodel(self, "progs/sword.mdl");

    setsize(self, '-16 -16 -24', '16 16 40');
    self.health = 25;  // Adjusted to 25 health as requested


    self.th_stand = sword_stand1;
    self.th_walk = sword_stand1;
    self.th_run = sword_run1;
    self.th_melee = sword_atk1;
    self.th_die = sword_die;
    self.th_pain = sword_pain;

    walkmonster_start();
};
