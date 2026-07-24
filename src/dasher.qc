
/*
==============================================================================

DASHER

==============================================================================
*/

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame knee1 knee2 knee3 knee4 knee5 knee6 knee7 knee8 knee9 knee10
$frame knee11

$frame pain1 pain2 pain3

$frame painb1 painb2 painb3 painb4 painb5 painb5a painb6 painb6a painb7 painb7a // 31-40
$frame painb8 //41

$frame punch1 punch2 punch3 punch4 punch5 punch6 punch7 punch8 punch9 punch10

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14

$frame kneel1 kneel2 kneel3 kneel4 kneel5

$frame standing1 standing2 standing3 standing4 standing5

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8 deathb9 deathb10
$frame deathb11

void() dasherCheckForCharge =
{
// check for mad charge
if (!enemy_vis)
	return;
if (time < self.attack_finished)
	return;	
if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
	return;		// too much height change
if ( vlen (self.origin - self.enemy.origin) < 80)
	return;		// use regular attack

// charge		
	SUB_AttackFinished (2);

};



//===========================================================================

void()	dasher_stand1	=[	$stand1,	dasher_stand2	] {ai_stand();};
void()	dasher_stand2	=[	$stand2,	dasher_stand3	] {ai_stand();};
void()	dasher_stand3	=[	$stand3,	dasher_stand4	] {ai_stand();};
void()	dasher_stand4	=[	$stand4,	dasher_stand5	] {ai_stand();};
void()	dasher_stand5	=[	$stand5,	dasher_stand6	] {ai_stand();};
void()	dasher_stand6	=[	$stand6,	dasher_stand7	] {ai_stand();};
void()	dasher_stand7	=[	$stand7,	dasher_stand8	] {ai_stand();};
void()	dasher_stand8	=[	$stand8,	dasher_stand9	] {ai_stand();};
void()	dasher_stand9	=[	$stand9,	dasher_stand1	] {ai_stand();};

//===========================================================================

void()	dasher_walk1	=[	$walk1,		dasher_walk2	] {
dasher_idle_sound();
ai_walk(6);};
void()	dasher_walk2	=[	$walk2,		dasher_walk3	] {ai_walk(14);};
void()	dasher_walk3	=[	$walk3,		dasher_walk4	] {ai_walk(6);};
void()	dasher_walk4	=[	$walk4,		dasher_walk5	] {ai_walk(10);};
void()	dasher_walk5	=[	$walk5,		dasher_walk6	] {ai_walk(14);};
void()	dasher_walk6	=[	$walk6,		dasher_walk7	] {ai_walk(14);};
void()	dasher_walk7	=[	$walk7,		dasher_walk8	] {ai_walk(8);};
void()	dasher_walk8	=[	$walk8,		dasher_walk9	] {ai_walk(6);};
void()	dasher_walk9	=[	$walk9,		dasher_walk10	] {ai_walk(14);};
void()	dasher_walk10	=[	$walk10,	dasher_walk11	] {ai_walk(14);};
void()	dasher_walk11	=[	$walk11,	dasher_walk12	] {ai_walk(14);};
void()	dasher_walk12	=[	$walk12,	dasher_walk13	] {ai_walk(6);};
void()	dasher_walk13	=[	$walk13,	dasher_walk14	] {ai_walk(8);};
void()	dasher_walk14	=[	$walk14,	dasher_walk1	] {ai_walk(10);};

//===========================================================================

void()	dasher_run1	=[	$run1,		dasher_run2	] { //9
	self.touch = SUB_Null;
	self.yaw_speed = 20;
	dasher_idle_sound();
	ai_run (16);
	//dasherCheckForCharge ();
};
void()	dasher_run2		=[	$run2,		dasher_run3	] {ai_run(20);}; //10
void()	dasher_run3		=[	$run3,		dasher_run3a] {nxth(0.05);ai_run(22);}; //11
void()	dasher_run3a	=[	$run3,		dasher_run4	] {nxth(0.05);ai_run(22);}; //11
void()	dasher_run4		=[	$run4,		dasher_run4a] {nxth(0.05);ai_run(15);}; //12
void()	dasher_run4a	=[	$run4,		dasher_run5	] {nxth(0.05);ai_run(15);}; //12
void()	dasher_run5		=[	$run5,		dasher_run6	] {ai_run(26);}; //13
void()	dasher_run6		=[	$run6,		dasher_run7	] {ai_run(18);}; //14
void()	dasher_run7		=[	$run7,		dasher_run8	] {ai_run(24);}; //15
void()	dasher_run8		=[	$run8,		dasher_run8a] {nxth(0.05);ai_run(16);}; //16
void()	dasher_run8a	=[	$run8,		dasher_run1	] {nxth(0.05);ai_run(16);}; //16


//============================================================================

void()	dasher_die1	=[	$death1,	dasher_die2	] {ai_back(2);}; //76
void()	dasher_die2	=[	$death2,	dasher_die3	] {self.solid = SOLID_NOT; ai_back(10);}; //77
void()	dasher_die3	=[	$death3,	dasher_die4	] {ai_back(20);}; //78
void()	dasher_die4	=[	$death4,	dasher_die5	] {ai_back(20);}; //79
void()	dasher_die5	=[	$death5,	dasher_die6	] {ai_back(8);}; //80
void()	dasher_die6	=[	$death6,	dasher_die7	] {ai_back(8);}; //81
void()	dasher_die7	=[	$death7,	dasher_die8	] {ai_back(12);}; //82
void()	dasher_die8	=[	$death8,	dasher_die9	] {ai_back(8);}; //83
void()	dasher_die9	=[	$death9,	dasher_die10] {ai_back(12);} //84
void()	dasher_die10=[	$death10,	dasher_die10] { //85
	// horde merge: fade corpse after a delay
	if (horde_ent)
	{
		self.think = MonsterFade;
		self.nextthink = time + FADETIME;
	}
};


void()	dasher_dieb1	=[	$deathb1,	dasher_dieb2	] {ai_back(2);}; //86
void()	dasher_dieb2	=[	$deathb2,	dasher_dieb3	] {self.solid = SOLID_NOT;ai_back(10);}; //87
void()	dasher_dieb3	=[	$deathb3,	dasher_dieb4	] {ai_back(12);}; //88
void()	dasher_dieb4	=[	$deathb4,	dasher_dieb5	] {ai_back(14);}; //89
void()	dasher_dieb5	=[	$deathb5,	dasher_dieb6	] {ai_back(18);}; //90
void()	dasher_dieb6	=[	$deathb6,	dasher_dieb7	] {ai_back(10);}; //91
void()	dasher_dieb7	=[	$deathb7,	dasher_dieb8	] {ai_back(12);}; //92
void()	dasher_dieb8	=[	$deathb8,	dasher_dieb9	] {ai_back(10);}; //93
void()	dasher_dieb9	=[	$deathb9,	dasher_dieb10	] {ai_back(8);}; //94
void()	dasher_dieb10	=[	$deathb10,	dasher_dieb11	] {ai_back(14);}; //95
void()	dasher_dieb11	=[	$deathb11,	dasher_dieb11	] {  // 96
	// horde merge: fade corpse after a delay
	if (horde_ent)
	{
		self.think = MonsterFade;
		self.nextthink = time + FADETIME;
	}
};

void() dasher_die =
{
	self.touch = SUB_Null;
	kill_dasher_blur();
// check for gib
	if (self.health < -40)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_hellkn.mdl", self.health);
	
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		
		return;
	}

// regular death

	sound (self, CHAN_VOICE, "dasher/death1.wav", 1, ATTN_NORM);

	if (random() > 0.5)
		dasher_die1 ();
	else
		dasher_dieb1 ();
};

//============================================================================

void() dasher_punch_hit =
{
	vector	delta;
	float 	ldmg;

	if (!self.enemy)
		return;	
		
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;
		
	ldmg = 3 + random() * 3;
	T_Damage (self.enemy, self, self, ldmg, DMGTYPE_MELEE);
};


void()	dasher_punch1	=[	$punch1,	dasher_punch2	] {ai_face();}; //42
void()	dasher_punch2	=[	$punch2,	dasher_punch3	] {ai_face();}; //43
void()	dasher_punch3	=[	$punch3,	dasher_punch4	] {ai_face();}; //44
void()	dasher_punch4	=[	$punch4,	dasher_punch5	] {ai_face();}; //45
void()	dasher_punch5	=[	$punch5,	dasher_punch6	] {ai_face();}; //46
void()	dasher_punch6	=[	$punch6,	dasher_punch7	] {ai_charge(20); dasher_punch_hit();}; //47
void()	dasher_punch7	=[	$punch7,	dasher_punch8	] {ai_charge(20); dasher_punch_hit();}; //48
void()	dasher_punch8	=[	$punch8,	dasher_punch9	] { //49
	if (time <= self.attack_finished && vlen(self.enemy.origin - self.origin) < 80) {
		dasher_punch5();
		return;
	}
	SUB_AttackFinished(3);
	ai_face();
};
void()	dasher_punch9	=[	$punch9,	dasher_punch10	] {ai_face();}; //50
void()	dasher_punch10	=[	$punch10,	dasher_run1	] {ai_face();}; //51



//===========================================================================


void() dasher_dash_touch = {
	if (other.takedamage && other.health > 0){
		self.touch = SUB_Null;
		T_Damage (other, self, self, 30, DMGTYPE_MELEE);
		dasher_dash7();
	}
}

void() dasher_dash_start = {
	float spd = 800;
	// predict at only half the speed to give its enemy some leeway
	float leadTime = vlen(self.enemy.origin - self.origin)/spd/2;
	
	self.angles_y = vectoyaw(self.enemy.origin + self.enemy.velocity*leadTime - self.origin);
	makevectors(self.angles);

	self.flags &~= FL_ONGROUND;
	self.velocity = self.pos1 = v_forward * spd;
	self.prev_origin = self.origin;
	self.air_finished = time + 0.1;

	self.dash_time = time + 1;
	self.touch = dasher_dash_touch;
	self.think = dasher_dash_think;
	self.nextthink = time + 0.0001;

	self.sibling.think = update_dasher_blur2;
	self.sibling.sibling.think = update_dasher_blur2;
	self.sibling.sibling.sibling.think = update_dasher_blur2;
}

void() dasher_dash_think = {
	float mvdist;
	// check movement distance every few milliseconds to see if didnt bump into anything
	if (time > self.air_finished) {
		mvdist = vlen([self.origin_x, self.origin_y, 0] - [self.prev_origin_x, self.prev_origin_y, 0]);

		if (mvdist < 70) {
			dasher_dash7();
			return;
		}
		self.air_finished = time + 0.1;
		self.prev_origin = self.origin;
	}
	
	// don't change Z velocity so it stays on the ground
	self.velocity_x = self.pos1_x;
	self.velocity_y = self.pos1_y;
	// remove the onground flag on every frame to let it sliiiide
	self.flags &~= FL_ONGROUND;

	if (time > self.dash_time) {
		dasher_dash7();
		return;
	}

	self.think = dasher_dash_think;
	self.nextthink = time + 0.0001;  //make sure it runs on every server frame
}


void() spawn_dasher_blur = {
	makevectors(self.angles);
	
	entity ent1 = self.sibling = spawn();
	ent1.movetype = MOVETYPE_NOCLIP;
	setmodel(ent1, "progs/dasher.mdl");
	setsize(ent1, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(ent1, self.origin + v_right * 32);

	ent1.think = update_dasher_blur;
	ent1.nextthink = time + 0.0001;
	ent1.air_finished = time + 0.5;
	ent1.owner = self;
	//ent1.velocity = -v_forward*64;
	ent1.frame = self.frame;
	ent1.angles = self.angles;
	ent1.alpha = 0.7;
	ent1.cnt = 1;

	entity ent2 = ent1.sibling = spawn();
	ent2.movetype = MOVETYPE_NOCLIP;
	setmodel(ent2, "progs/dasher.mdl");
	setsize(ent2, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(ent2, self.origin - v_right * 32);
	
	ent2.think = update_dasher_blur;
	ent2.nextthink = time + 0.0001;
	ent2.air_finished = time + 0.5;
	ent2.owner = self;
	//ent2.velocity = v_forward*64;
	ent2.frame = self.frame;
	ent2.angles = self.angles;
	ent2.alpha = 0.7;
	ent2.cnt = 2;

	entity ent3 = ent2.sibling = spawn();
	ent3.movetype = MOVETYPE_NOCLIP;
	setmodel(ent3, "progs/dasher.mdl");
	setsize(ent3, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(ent3, self.origin + v_up * 32);

	ent3.think = update_dasher_blur;
	ent3.nextthink = time + 0.0001;
	ent3.air_finished = time + 0.5;
	ent3.owner = self;
	//ent3.velocity = -v_up*64;
	ent3.frame = self.frame;
	ent3.angles = self.angles;
	ent3.alpha = 0.7;
	ent3.cnt = 3;
}


void() update_dasher_blur = {
	float perc = (self.air_finished - time)/0.5;
	self.angles = self.owner.angles;
	self.frame = self.owner.frame;
	makevectors(self.owner.angles);

	if (self.cnt == 1) {
		setorigin(self, self.owner.origin + v_right * 32*perc);
	}
	else if (self.cnt == 2) {
		setorigin(self, self.owner.origin - v_right * 32*perc);
	}
	else {
		setorigin(self, self.owner.origin + v_up * 32*perc);
	}
	self.think = update_dasher_blur;
	self.nextthink = time + 0.0001;
}

void() update_dasher_blur2 = {
	self.angles = self.owner.angles;
	self.frame = self.owner.frame;
	makevectors(self.owner.angles);

	if (self.cnt == 1) {
		setorigin(self, self.owner.origin - v_forward * 10);
	}
	else if (self.cnt == 2) {
		setorigin(self, self.owner.origin - v_forward * 20);
	}
	else {
		setorigin(self, self.owner.origin - v_forward * 30);
	}
	self.think = update_dasher_blur2;
	self.nextthink = time + 0.0001;
}

void() kill_dasher_blur = {
	entity e = self.sibling;
	if (e) {
		remove(e.sibling.sibling);
		remove(e.sibling);
		remove(e);
	}
	self.sibling = world;
}

void()	dasher_dash1	=[	$knee1,		dasher_dash2	] {
	self.yaw_speed = 100;
	ai_face();
	SUB_AttackFinished(3);
	kill_dasher_blur();
	spawn_dasher_blur();

}; //17
void()	dasher_dash2	=[	$knee2,		dasher_dash3	] {ai_face();}; //18
void()	dasher_dash3	=[	$knee3,		dasher_dash4	] {ai_face();}; //19
void()	dasher_dash4	=[	$knee4,		dasher_dash5	] {ai_face();}; //20
void()	dasher_dash5	=[	$knee5,		dasher_dash6	] {ai_face();}; //21
void()	dasher_dash6	=[	$knee6,		dasher_dash7	] {dasher_dash_start(); }; //22

void()	dasher_dash7	=[	$knee7,		dasher_dash8	] {self.yaw_speed = 20;	kill_dasher_blur(); self.touch = SUB_Null;}; //23
void()	dasher_dash8	=[	$knee8,		dasher_dash9	] {ai_forward(4);}; //24
void()	dasher_dash9	=[	$knee9,		dasher_dash10	] {}; //25
void()	dasher_dash10	=[	$knee10,	dasher_dash11	] {}; //26
void()	dasher_dash11	=[	$knee11,	dasher_run1		] {}; //27

//============================================================================


void(entity attacker, float damage)	dasher_pain =
{
	if (self.pain_finished > time)
		return;
	kill_dasher_blur();
	self.touch = SUB_Null;

	sound (self, CHAN_VOICE, "dasher/pain1.wav", 1, ATTN_NORM);
	
	

	if (time - self.pain_finished > 5)
	{	// allways go into pain frame if it has been a while
		dasher_pain1 ();
		self.pain_finished = time + 3;
		return;
	}
	
	if ((random()*30 > damage) )
		return;		// didn't flinch

	self.pain_finished = time + 3;
	dasher_pain1 ();
};

void()	dasher_pain1	=[	$painb1,		dasher_pain2	]
	{

			sound (self, CHAN_VOICE, "dasher/pain1.wav", 1, ATTN_NORM);
	};
void()	dasher_pain2	=[	$painb2,		dasher_pain3	] {};
void()	dasher_pain3	=[	$painb3,		dasher_pain4	] {};
void()	dasher_pain4	=[	$painb4,		dasher_pain5	] {};
void()	dasher_pain5	=[	$painb5,		dasher_pain6	] {};
void()	dasher_pain6	=[	$painb6,		dasher_pain7	] {};
void()	dasher_pain7	=[	$painb7,		dasher_pain8	] {};
void()	dasher_pain8	=[	$painb8,		dasher_run1		] {};


//============================================================================

void() dasher_idle_sound =
{
	if (random() < 0.2)
	{
		sound (self, CHAN_VOICE, "dasher/idle.wav", 1, ATTN_NORM);
	}
};

void() monster_dasher =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/dasher.mdl");
	precache_model2 ("progs/k_spike.mdl");
	precache_model2 ("progs/h_hellkn.mdl");


	precache_sound2 ("dasher/death1.wav");
	precache_sound2 ("dasher/pain1.wav");
	precache_sound2 ("dasher/sight1.wav");
	precache_sound2 ("dasher/idle.wav");

	
	
	precache_sound2 ("dasher/attack1.wav");
	precache_sound2 ("dasher/grunt.wav");

	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/dasher.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 350;


	self.th_stand = dasher_stand1;
	self.th_walk = dasher_walk1;
	self.th_run = dasher_run1;
	self.th_melee = dasher_punch1;
	self.th_missile = dasher_dash1;
	self.th_pain = dasher_pain;
	self.th_die = dasher_die;

	walkmonster_start ();
	
};
