
#define AV_SKATE_FRICTION_WMOD 1.04
#define AV_SKATE_FRICTION_SMOD 1.08
#define AV_SKATE_ROTATION_SPEED 0.04
#define AV_SKATE_SPEED_LIMIT 1024
#define AV_SKATE_TRICK_FRAMETIME 0.04
#define AV_SKATE_COMBO_LANDTIME 1
#define AV_SKATE_COMBO_MAXMULT 4
#define AV_SKATE_POINTS_PER_AMMO 500
#define AV_SKATE_GRINDBUTTON_TIME 1
#define AV_SKATE_WALLRIDE_TIME 1.2
#define AV_SKATE_WALLRIDE_SPEED 250
#define AV_SKATE_WALLRIDE_DIST 28
#define AV_SKATE_GRIND_ASSIST 120
#define AV_SKATE_GRIND_SNAP 150
#define AV_SKATE_TILT_MAX 75
#define AV_SKATE_RAMP_BOOST 1.2
#define AV_SKATE_MUSIC_FIRST 2
#define AV_SKATE_MUSIC_LAST 11
#define AV_SKATE_MUSIC_TIME 180

float SKFL_SKATING = 1;
float SKFL_GRINDING = 2;
float SKFL_STOPPEDGRIND = 4;
float SKFL_JUMPED = 8;
float SKFL_TRICK = 16;
float SKFL_WALLRIDE = 32;
float SKFL_GRINDSOUND = 64;
float SKFL_ROLLSOUND = 128;

// --- CAMPAIGN SKATING -------------------------------

void() AV_CampaignSkateUpdate = {
	if(!self.av_skating) return;
	
	if(!(self.flags & FL_ONGROUND)) return;
	
	float framefactor = frametime/0.013888; // baseline is 72fps, modulate parameters according to that

	//DELAY HORIZONTAL FRICTION
	if(self.movement_x || self.movement_y){
		self.velocity_x = self.velocity_x * pow(AV_SKATE_FRICTION_SMOD, framefactor);
		self.velocity_y = self.velocity_y * pow(AV_SKATE_FRICTION_SMOD, framefactor);
	}else{
		self.velocity_x = self.velocity_x * pow(AV_SKATE_FRICTION_WMOD, framefactor);
		self.velocity_y = self.velocity_y * pow(AV_SKATE_FRICTION_WMOD, framefactor);
	}
	
	//ROTATE VELOCITY TOWARDS LOOKING VECTOR
	local vector l_vec, v_vec, r_vec;
	local float s_speed;
	
	l_vec = MovementVector();
	l_vec_z = 0;
	l_vec = normalize(l_vec);
	
	v_vec = self.velocity;
	v_vec_z = 0;
	
	s_speed = vlen(v_vec); //SPEED
	if(s_speed > AV_SKATE_SPEED_LIMIT) s_speed = AV_SKATE_SPEED_LIMIT;
	
	v_vec = normalize(v_vec);
	
	r_vec_x = v_vec_x + (l_vec_x - v_vec_x) * AV_SKATE_ROTATION_SPEED * framefactor;
	r_vec_y = v_vec_y + (l_vec_y - v_vec_y) * AV_SKATE_ROTATION_SPEED * framefactor;
	
	r_vec = normalize(r_vec);
	
	self.velocity_x = r_vec_x * s_speed;
	self.velocity_y = r_vec_y * s_speed;
};

void(entity plr) AV_CampaignSkateOn = {
	entity tmp = self;
	self = plr;

	self.av_skating = TRUE;
	AV_CameraOn();

	setmodel(self, "progs/splayer2.mdl");
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	modelindex_player = self.modelindex;

	self = tmp;
}


void(entity plr) AV_CampaignSkateOff = {
	entity tmp = self;
	self = plr;

	self.av_skating = FALSE;
	AV_CameraOff();

	setmodel(self, "progs/player.mdl");
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	modelindex_player = self.modelindex;

	self = tmp;
}

// --- OLD SKATING ------------------------------------

void() AV_SkateUpdateOld = {
	if (!(self.skate_flags & SKFL_SKATING)) return;
	AV_SkateTilt();
	
	
	if (!(self.skate_flags & SKFL_GRINDING)) {
		skate_extractCommands();
		skate_checkCombos();
	}

	// clears grinding flag
	// if player is still grinding, the trigger itself will set it back again on the same frame
	if (self.skate_flags & SKFL_STOPPEDGRIND) {
		float grindpoints = (time - self.skate_grindtime) * 50;
		self.skate_combo = self.skate_combo + grindpoints;
		self.skate_grindend = time;

		self.skate_grindtime = 0;
		self.skate_flags &~= SKFL_STOPPEDGRIND;
		player_run();
		//self.think = player_run;
		//self.nextthink = time + 0.0001;
	}
	

	if (self.skate_flags & SKFL_GRINDING) {
		self.skate_flags |= SKFL_STOPPEDGRIND;
		self.skate_flags &~= SKFL_GRINDING;
		AV_SkateSparks();
		
		if(vlen(self.origin - self.skate_grindpos) > 4 || time < self.skate_grindtime + 0.1){
			self.skate_grindpos = self.origin;
			self.skate_grindmoved = time;
		}else if(time > self.skate_grindmoved + 0.25){
			self.skate_grindstuck = time + 1;
			self.velocity_z = 200;
		}
	}

	AV_SkateSounds();
	AV_SkateGrindAssist();
	

	if(!(self.flags & FL_ONGROUND)){
		if(!self.skate_takeoff) self.skate_takeoff = time;
		else if(self.skate_takeoff > 0 && time > self.skate_takeoff + 0.05){
			if(self.skate_onramp + 0.2 > self.skate_takeoff && self.velocity_z > 150) self.velocity_z = self.velocity_z * AV_SKATE_RAMP_BOOST;
			self.skate_takeoff = -1;
		}
		
		AV_SkateWallride();
		return;
	}
	
	self.skate_takeoff = 0;
	if(self.velocity_z > 80) self.skate_onramp = time;
	
	self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_WALLRIDE);
	
	if(self.skate_combo_tricks && !(self.skate_flags & SKFL_STOPPEDGRIND)){
		if(!self.skate_landtime) self.skate_landtime = time;
		else if(time > self.skate_landtime + AV_SKATE_COMBO_LANDTIME) AV_SkateEndCombo();
	}

	if (self.skate_flags & SKFL_TRICK) {
		self.skate_flags &~= SKFL_TRICK;
		player_run();
	}
	
	float framefactor = frametime/0.013888; // baseline is 72fps, modulate parameters according to that


	//DELAY HORIZONTAL FRICTION
	local float fric_s = AV_SKATE_FRICTION_SMOD;
	local float fric_w = AV_SKATE_FRICTION_WMOD;
	if(world.skate_friction){
		fric_w = world.skate_friction;
		if(fric_s < fric_w) fric_s = fric_w;
	}
	
	if(self.movement_x || self.movement_y){
		self.velocity_x = self.velocity_x * pow(fric_s, framefactor);
		self.velocity_y = self.velocity_y * pow(fric_s, framefactor);
	}else{
		self.velocity_x = self.velocity_x * pow(fric_w, framefactor);
		self.velocity_y = self.velocity_y * pow(fric_w, framefactor);
	}
	
	if(world.skate_slope){
		traceline(self.origin, self.origin - '0 0 64', TRUE, self);
		
		if(trace_fraction < 1 && trace_plane_normal_z < 0.99 && trace_plane_normal_z > 0.5){
			self.velocity_x = self.velocity_x + trace_plane_normal_x * cvar("sv_gravity") * frametime * world.skate_slope;
			self.velocity_y = self.velocity_y + trace_plane_normal_y * cvar("sv_gravity") * frametime * world.skate_slope;
		}
	}

	
	//dprint3("Movement: ", vtos(self.movement), "\n");
	//ROTATE VELOCITY TOWARDS LOOKING VECTOR
	local vector l_vec, v_vec, r_vec;
	local float s_speed;
	
	l_vec = MovementVector();
	l_vec_z = 0;
	l_vec = normalize(l_vec);
	
	v_vec = self.velocity;
	v_vec_z = 0;
	
	s_speed = vlen(v_vec); //SPEED

	float max_speed = AV_SKATE_SPEED_LIMIT;
	if (world.skate_speed) max_speed = world.skate_speed;

	if (s_speed > max_speed) s_speed = max_speed;
	
	v_vec = normalize(v_vec);
	
	r_vec_x = v_vec_x + (l_vec_x - v_vec_x) * AV_SKATE_ROTATION_SPEED * framefactor;
	r_vec_y = v_vec_y + (l_vec_y - v_vec_y) * AV_SKATE_ROTATION_SPEED * framefactor;
	
	r_vec = normalize(r_vec);
	
	self.velocity_x = r_vec_x * s_speed;
	self.velocity_y = r_vec_y * s_speed;
};



// buffer holds last commands

float CMD_FORWARD = 1;
float CMD_BACK = 2;
float CMD_LEFT = 4;
float CMD_RIGHT = 8;
float CMD_JUMP = 16;
float CMD_ALL_COMMANDS = CMD_FORWARD | CMD_BACK | CMD_LEFT | CMD_RIGHT | CMD_JUMP;
float CMD_OFFGROUND = 32;


float(float offset) skate_getIndex = {
	float idx = self.skate_lastcommand_nextindex + offset;
	return mod(idx, SKATE_LASTCOMMAND_BUFFERSIZE);
};

float(float offset) skate_getCommand = {
	return self.skate_lastcommands[skate_getIndex(offset)];
}

void() skate_clearCommands = {
	self.skate_lastcommand_time = time;
	self.skate_lastcommand_nextindex = 0;
	for (float i = 0; i < SKATE_LASTCOMMAND_BUFFERSIZE; i++) {
		self.skate_lastcommands[i] = 0;
	}
}



void() skate_extractCommands = {
	if (self.skate_lastcommand_time + 0.5 < time) {
		skate_clearCommands();
	}
	
	float currentcommand = 0;
	
	
	if (self.movement_x > 150)// && !(self.skate_lastcommands[lastidx] & CMD_FORWARD))
		currentcommand |= CMD_FORWARD;

	if (self.movement_x < -150)// && !(self.skate_lastcommands[lastidx] & CMD_BACK))
		currentcommand |= CMD_BACK;

	if (self.movement_y > 150)// && !(self.skate_lastcommands[lastidx] & CMD_RIGHT))
		currentcommand |= CMD_RIGHT;

	if (self.movement_y < -150)// && !(self.skate_lastcommands[lastidx] & CMD_LEFT))
		currentcommand |= CMD_LEFT;

	if (self.skate_flags & SKFL_JUMPED)// && !(self.skate_lastcommands[lastidx] & CMD_JUMP))
		currentcommand |= CMD_JUMP;

	self.skate_flags &~= SKFL_JUMPED;

	if (currentcommand && (
			(currentcommand & CMD_ALL_COMMANDS != skate_getCommand(-1) & CMD_ALL_COMMANDS) || // if changed from last command
			!(self.skate_lastcommands[SKATE_LASTCOMMAND_BUFFERSIZE] & CMD_ALL_COMMANDS) // if previous frame had no commands
		)
	) {
		self.skate_lastcommand_time = time;
		
		if (!(self.flags & FL_ONGROUND)) currentcommand |= CMD_OFFGROUND;

		self.skate_lastcommands[self.skate_lastcommand_nextindex] = currentcommand;

		
		dprint2("movement: ", vtos(self.movement));
		dprint3("; idx: ", ftos(self.skate_lastcommand_nextindex), "; command: ");
		if (currentcommand & CMD_FORWARD) dprint("F ");
		if (currentcommand & CMD_BACK) dprint("B ");
		if (currentcommand & CMD_RIGHT) dprint("R ");
		if (currentcommand & CMD_LEFT) dprint("L ");
		if (currentcommand & CMD_JUMP) dprint("J ");
		if (currentcommand & CMD_OFFGROUND) dprint("A ");
		
		dprint("\n");

		self.skate_lastcommand_nextindex = skate_getIndex(1);

	}

	// save current command at last buffer position, regardless if it changed or not
	// this way we can detect sequential commands next iteration
	self.skate_lastcommands[SKATE_LASTCOMMAND_BUFFERSIZE] = currentcommand;
}

void() skate_checkCombos = {
	float idx = self.skate_lastcommand_nextindex;

	// SPIN
	if (
		skate_getCommand(-1) & (CMD_LEFT | CMD_OFFGROUND) == CMD_LEFT | CMD_OFFGROUND &&
		skate_getCommand(-2) & (CMD_BACK | CMD_OFFGROUND) == CMD_BACK | CMD_OFFGROUND &&
		skate_getCommand(-3) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND
		
	) {
		self.skate_flags |= SKFL_TRICK;
		player_sk_spin1();
		skate_clearCommands();
		return;
	}

	// SPIN 2
	if (
		skate_getCommand(-1) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND &&
		skate_getCommand(-2) & (CMD_BACK | CMD_OFFGROUND) == CMD_BACK | CMD_OFFGROUND &&
		skate_getCommand(-3) & (CMD_LEFT | CMD_OFFGROUND) == CMD_LEFT | CMD_OFFGROUND
		
	) {
		self.skate_flags |= SKFL_TRICK;
		player_sk_spin1();
		skate_clearCommands();
		return;
	}

	// flip
	if (
		skate_getCommand(-1) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND &&
		(
			skate_getCommand(-2) & (CMD_LEFT | CMD_OFFGROUND) == CMD_LEFT | CMD_OFFGROUND// ||
			//skate_getCommand(-3) & (CMD_LEFT | CMD_OFFGROUND) == CMD_LEFT | CMD_OFFGROUND
		)
	) {
		self.skate_flags |= SKFL_TRICK;
		player_sk_flip1();
		skate_clearCommands();
		return;
	}

	// FLIP 2
	if (
		skate_getCommand(-1) & (CMD_LEFT | CMD_OFFGROUND) == CMD_LEFT | CMD_OFFGROUND &&
		(
			skate_getCommand(-2) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND// ||
			//skate_getCommand(-3) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND
		)
	) {
		self.skate_flags |= SKFL_TRICK;
		player_sk_flip1();
		skate_clearCommands();
		return;
	}

	// BACKFLIP
	if (
		skate_getCommand(-1) & (CMD_FORWARD | CMD_OFFGROUND) == CMD_FORWARD | CMD_OFFGROUND &&
		skate_getCommand(-2) & (CMD_BACK | CMD_OFFGROUND) == CMD_BACK | CMD_OFFGROUND &&
		skate_getCommand(-3) & (CMD_BACK | CMD_OFFGROUND) == CMD_BACK | CMD_OFFGROUND
		
	) {
		//centerprint2(self, ftos(time), " - Flip started\n");
		self.skate_flags |= SKFL_TRICK;
		player_sk_bflip1();
		//sound (self, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		skate_clearCommands();
		return;
	}
}

void(entity plr) AV_SkateOn = {
	if(!skate_level){
		AV_CampaignSkateOn(plr);
		return;
	}

	entity tmp = self;
	self = plr;

	self.skate_flags |= SKFL_SKATING;
	AV_CameraOn();

	setmodel(self, "progs/splayer2.mdl");
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	//modelindex_player = self.modelindex;
	modelindex_skate = self.modelindex;

	self = tmp;
}

void(entity plr) AV_SkateOff = {
	if(!skate_level){
		AV_CampaignSkateOff(plr);
		return;
	}

	entity tmp = self;
	self = plr;

	self.skate_flags &~= SKFL_SKATING;
	AV_CameraOff();

	setmodel(self, "progs/player.mdl");
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	modelindex_player = self.modelindex;

	self = tmp;
}

void() AV_SwitchSkate = {
	if(!skate_level){
		if(self.av_skating) AV_CampaignSkateOff(self);
		else AV_CampaignSkateOn(self);
		return;
	}

	if (self.skate_flags & SKFL_SKATING)
		AV_SkateOff(self);
	else
		AV_SkateOn(self);
};


//=================================================================================================


void() skate_touch = {
	if (self.estate != STATE_ACTIVE) return;
	if (other.classname != "player") return;
	// state 0 = turns skating ON, state 1 = turns skating OFF
	// so state and av_skating need to be different for trigger to act

	if(!skate_level){
		if(self.state == 0 && !other.av_skating) AV_CampaignSkateOn(other);
		else if(self.state == 1 && other.av_skating) AV_CampaignSkateOff(other);
		return;
	}

	if (self.state == 0 && !(other.skate_flags & SKFL_SKATING)) {
		AV_SkateOn(other);
	}
	else if (self.state == 1 && (other.skate_flags & SKFL_SKATING)) {
		AV_SkateOff(other);
	}
};

void() trigger_skate = {
	InitTrigger();
    self.touch = skate_touch;

	SUB_CheckWaiting();
};

//=================================================================================================

void() trigger_grind = {
	InitTrigger();
    self.touch = grind_touch;
    //dprint2(vtos(self.angles), "\n");
    makevectors([-self.mangle_x, self.mangle_y, self.mangle_z]);
    self.dest1 = v_forward;
	makevectors([-self.mangle_x, self.mangle_y - 180, self.mangle_z]);
	self.dest2 = v_forward;

	if (!self.speed) self.speed = 300;
	SUB_CheckWaiting();
}

void() grind_touch_old = {
	if (self.estate != STATE_ACTIVE) return;
	if (other.classname != "player") return;
	if (!other.skate_flags) return;
	if(other.skate_grindstuck > time) return;
	if(!(other.skate_flags & (SKFL_STOPPEDGRIND | SKFL_GRINDING)) && other.skate_grindend + 0.25 < time && other.skate_grindbutton < time) return;
	if(other.velocity_z >= 0 && other.skate_grindbutton < time) return;
	//if (other.flags & FL_ONGROUND) return;
	
	if(other.skate_grindframe != time){
		other.skate_grindframe = time;
		other.skate_grindvel = other.velocity;
		other.skate_grindalign = -1;
	}
	
	local float same_grind = (other.skate_flags & (SKFL_STOPPEDGRIND | SKFL_GRINDING)) || other.skate_grindend + 0.25 >= time;
	
	local vector way = other.skate_grindvel;
	if(same_grind) way = other.skate_grinddir;
	
	local float align = fabs(normalize([self.dest1_x, self.dest1_y, 0]) * normalize([way_x, way_y, 0]));
	if(align < other.skate_grindalign) return;
	other.skate_grindalign = align;

	if (!(other.skate_flags & (SKFL_STOPPEDGRIND | SKFL_GRINDING))) {
		other.skate_grindtime = time;

		SUB_CallAsSelf(player_sk_grind1, other);

		if(!(other.skate_flags & SKFL_GRINDSOUND)){
			sound(other, CHAN_BODY, "skate/grind.wav", 1, ATTN_NORM);
			other.skate_flags = other.skate_flags | SKFL_GRINDSOUND;
		}
		
		other.skate_flags = other.skate_flags - (other.skate_flags & (SKFL_ROLLSOUND | SKFL_WALLRIDE));
		
		if(other.skate_grindend + 0.25 < time){
			SUB_CallAsSelf(AV_SkateAddGrind, other);
			sound(other, CHAN_AUTO, "skate/grind_in.wav", 1, ATTN_NORM);
		}
		
		other.skate_grindbutton = 0;
	}

	other.skate_flags &~= SKFL_STOPPEDGRIND;
	other.skate_flags |= SKFL_GRINDING;

	vector dir = self.dest1;

	local float along;
	if(same_grind) along = normalize([self.dest1_x, self.dest1_y, 0]) * normalize([other.skate_grinddir_x, other.skate_grinddir_y, 0]);
	else{
		along = normalize([self.dest1_x, self.dest1_y, 0]) * normalize([other.skate_grindvel_x, other.skate_grindvel_y, 0]);
		
		if(fabs(along) < 0.25){
			makevectors([0, other.v_angle_y, 0]);
			along = normalize([self.dest1_x, self.dest1_y, 0]) * v_forward;
		}
	}
	
	if(along < 0) // invert grind angle if player is coming from the other way
		dir = self.dest2;
	other.skate_grinddir = dir;

	local float spd = max(vlen(other.skate_grindvel), self.speed);
	
	
	other.velocity = spd * dir;

	vector suck = self.origin + (self.mins + [self.maxs_x, self.maxs_y, self.mins_z])/2 - other.origin - [0, 0, other.mins_z];
	//vector suck = [self.origin_x, self.origin_y, 0] + ([self.mins_x, self.mins_y, 0] + [self.maxs_x, self.maxs_y, 0])/2 - [other.origin_x, other.origin_y, 0];
	suck -= dir * (suck * dir);
	//other.velocity += suck * spd * 0.01;
	local vector old_origin = other.origin;
	
	local vector flat = normalize([dir_x, dir_y, 0]);
	local vector side = [suck_x, suck_y, 0];
	side = side - flat * (side * flat);
	
	if(vlen(side) < AV_SKATE_GRIND_SNAP)
		setorigin(other, other.origin + side);

	other.velocity_z = 0;

	//other.origin_z = (self.origin_z + self.mins_z) - other.mins_z;
	setorigin(other, other.origin + '0 0 32');
	entity oself = self;
	self = other;
	local float on_rail = droptofloor();
	if(on_rail && (pointcontents(self.origin) == CONTENT_SOLID || !droptofloor())) on_rail = FALSE;
	self = oself;
	
	if(!on_rail){
		setorigin(other, old_origin);
		
		other.skate_flags = other.skate_flags - (other.skate_flags & SKFL_GRINDING);
		other.skate_flags = other.skate_flags | SKFL_STOPPEDGRIND;
		return;
	}

	setorigin(other, other.origin + '0 0 8');

	//other.angles = vectoangles2(other.velocity);
	//other.angles_x = other.v_angle_x;
	//other.fixangle = 1;
	//dprint3("Grinding velocity: ", vtos(other.velocity), "\n");
}

// --- COMBO ------------------------------------------

void(string trickname, float points) AV_SkateAddTrick = {
	if(!(self.skate_flags & SKFL_SKATING)) return;
	
	if(!self.skate_combo_tricks){
		self.skate_combo = 0;
		self.skate_combo_mult = 1;
	}else if(self.skate_combo_mult < AV_SKATE_COMBO_MAXMULT) self.skate_combo_mult = self.skate_combo_mult + 1;
	
	self.skate_combo_tricks = self.skate_combo_tricks + 1;
	self.skate_combo = self.skate_combo + points;
	self.skate_landtime = 0;
	
	AV_SkateGiveAmmo(1);
	
	AV_SkatePrintLoc(self, "$qc_sk_trick", 1, trickname, ftos(points), strcat(ftos(rint(self.skate_combo)), "  x", ftos(self.skate_combo_mult)));
};

void() AV_SkateAddGrind = {
	AV_SkateAddTrick("$qc_sk_grind", 50);
};

void() AV_SkateEndCombo = {
	local float total = rint(self.skate_combo * self.skate_combo_mult);
	self.skate_points = self.skate_points + total;
	
	AV_SkateGiveAmmo(floor(total / AV_SKATE_POINTS_PER_AMMO));
	
	AV_SkatePrintLoc(self, "$qc_sk_combo", 0, ftos(total), "", "");
	
	self.skate_combo = 0;
	self.skate_combo_mult = 0;
	self.skate_combo_tricks = 0;
	self.skate_landtime = 0;
};

void(float amount) AV_SkateGiveAmmo = {
	if(amount < 1) return;
	
	self.ammo_shells1 = self.ammo_shells1 + amount;
	self.ammo_nails1 = self.ammo_nails1 + amount * 2;
	self.ammo_rockets1 = self.ammo_rockets1 + amount;
	self.ammo_cells1 = self.ammo_cells1 + amount;
	self.ammo_lava_nails = self.ammo_lava_nails + amount * 2;
	self.ammo_multi_rockets = self.ammo_multi_rockets + amount;
	self.ammo_plasma = self.ammo_plasma + amount;
	
	local entity oother = other;
	other = self;
	bound_other_ammo();
	other = oother;
	
	local void() oldthink = self.think;
	local float oldnextthink = self.nextthink;
	local float oldframe = self.frame;
	
	W_SetCurrentAmmo();
	
	self.think = oldthink;
	self.nextthink = oldnextthink;
	self.frame = oldframe;
};

void(entity attacker) AV_SkateKillBonus = {
	if(!skate_level)							return;
	if(attacker.classname != "player")			return;
	if(!(attacker.skate_flags & SKFL_SKATING))	return;
	
	local entity oself = self;
	self = attacker;
	AV_SkateAddTrick("$qc_sk_kill", 100);
	self = oself;
};

// --- WALLRIDE ---------------------------------------

void() AV_SkateWallride = {
	if(self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND)) return;
	
	local vector dir = [self.velocity_x, self.velocity_y, 0];
	local float spd = vlen(dir);
	
	if(self.skate_flags & SKFL_WALLRIDE){
		traceline(self.origin, self.origin - self.skate_wallnormal * AV_SKATE_WALLRIDE_DIST, TRUE, self);
		
		if(trace_fraction == 1 || time > self.skate_wallride_time + AV_SKATE_WALLRIDE_TIME || spd < 120){
			self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_WALLRIDE);
			self.skate_wallride_time = time;
			return;
		}
		
		self.velocity = self.velocity - (self.skate_wallnormal * (self.velocity * self.skate_wallnormal) + self.skate_wallnormal * 20);
		if(self.velocity_z < -40) self.velocity_z = -40;
		self.velocity_z = self.velocity_z + cvar("sv_gravity") * frametime * 0.85;
		
		AV_SkateSparks();
		return;
	}
	
	if(time < self.skate_wallride_time + 0.6) return;
	
	local float min_speed = AV_SKATE_WALLRIDE_SPEED;
	if(self.skate_grindbutton > time) min_speed = 120;
	if(spd < min_speed || self.velocity_z < -350) return;
	
	dir = normalize(dir);
	makevectors(vectoangles(dir));
	
	local float side;
	for(side = 1; side > -2; side = side - 2){
		traceline(self.origin, self.origin + v_right * side * AV_SKATE_WALLRIDE_DIST, TRUE, self);
		
		if(trace_fraction < 1 && fabs(trace_plane_normal_z) < 0.3 && fabs(dir * trace_plane_normal) < 0.6){
			self.skate_flags = self.skate_flags | SKFL_WALLRIDE;
			self.skate_wallnormal = trace_plane_normal;
			self.skate_wallride_time = time;
			if(self.velocity_z < 60) self.velocity_z = 60;
			
			if(!(self.skate_flags & SKFL_TRICK)){
				if(side > 0) player_sk_wallr1();
				else player_sk_walll1();
			}
			
			AV_SkateAddTrick("$qc_sk_wallride", 150);
			return;
		}
	}
};

// --- OLD GRIND ASSIST AND SPARKS --------------------

void() AV_SkateGrindAssistOld = {
	if(self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND | SKFL_WALLRIDE))	return;
	if(self.skate_grindstuck > time)											return;
	if(self.skate_grindbutton < time)											return;
	
	local float side = AV_SKATE_GRIND_ASSIST;
	local float above = 110;
	local float below = 56;
	
	local entity best = world;
	local float best_dist = side;
	local float best_z = 0;
	
	local entity rail = findradius(self.origin, 512);
	while(rail){
		if(rail.classname == "trigger_grind" && rail.estate == STATE_ACTIVE){
			local vector center = (rail.absmin + rail.absmax) * 0.5;
			local vector dir = normalize([rail.dest1_x, rail.dest1_y, 0]);
			local float half = (fabs(dir_x) * (rail.absmax_x - rail.absmin_x) + fabs(dir_y) * (rail.absmax_y - rail.absmin_y)) * 0.5;
			
			local float along = (self.origin - center) * dir;
			if(along > half) along = half;
			if(along < -half) along = -half;
			
			local vector point = center + dir * along;
			point_z = center_z + along * rail.dest1_z / vlen([rail.dest1_x, rail.dest1_y, 0]);
			
			local float dist = vlen([self.origin_x - point_x, self.origin_y - point_y, 0]);
			
			if(dist < best_dist && self.origin_z > point_z - 34 - below && self.origin_z < point_z + 26 + above){
				best = rail;
				best_dist = dist;
				best_z = point_z;
			}
		}
		
		rail = rail.chain;
	}
	
	if(!best) return;
	
	local vector old_origin = self.origin;
	if(self.origin_z < best_z - 28) setorigin(self, [self.origin_x, self.origin_y, best_z - 28]);
	
	local entity oself = self;
	local entity oother = other;
	other = self;
	self = best;
	grind_touch();
	self = oself;
	other = oother;
	
	if(!(self.skate_flags & SKFL_GRINDING)) setorigin(self, old_origin);
};

void() AV_SkateSparksOld = {
	if(time < self.skate_fxtime) return;
	
	self.skate_fxtime = time + 0.05;
	
	local vector dir = self.velocity * -0.15;
	dir_z = 60;
	
	particle([self.origin_x, self.origin_y, self.absmin_z + 2], dir, 111, 8);
};

// --- SOUNDS -----------------------------------------

void() AV_SkateSounds = {
	if(self.skate_flags & SKFL_GRINDSOUND){
		if(!(self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND)) && time > self.skate_grindend + 0.1){
			sound(self, CHAN_BODY, "skate/grind_out.wav", 1, ATTN_NORM);
			self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_GRINDSOUND);
		}
		
		return;
	}
	
	if(self.flags & FL_ONGROUND && vlen(self.velocity) > 80){
		if(!(self.skate_flags & SKFL_ROLLSOUND)){
			sound(self, CHAN_BODY, "skate/roll.wav", 0.6, ATTN_NORM);
			self.skate_flags = self.skate_flags | SKFL_ROLLSOUND;
		}
	}else if(self.skate_flags & SKFL_ROLLSOUND){
		sound(self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM);
		self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_ROLLSOUND);
	}
};

// --- MUSIC ------------------------------------------

float(float track) AV_SkateMusicLength = {
	//if(track == 2) return 214;
	return AV_SKATE_MUSIC_TIME;
};

void() AV_SkateMusicPlay = {
	local float songs = AV_SKATE_MUSIC_LAST - AV_SKATE_MUSIC_FIRST + 1;
	
	local float last = self.sounds;
	if(!last) last = cvar("saved4");
	
	if(self.count >= songs){
		self.cnt = 0;
		self.count = 0;
	}
	
	local float track = 0;
	local float tries = 0;
	while(!track && tries < 100){
		local float pick = AV_SKATE_MUSIC_FIRST + floor(random() * songs);
		if(pick > AV_SKATE_MUSIC_LAST) pick = AV_SKATE_MUSIC_LAST;
		
		if((pick != last || songs < 2) && !(self.cnt & pow(2, pick - AV_SKATE_MUSIC_FIRST))) track = pick;
		
		tries = tries + 1;
	}
	
	if(!track) track = AV_SKATE_MUSIC_FIRST;
	
	self.cnt = self.cnt | pow(2, track - AV_SKATE_MUSIC_FIRST);
	self.count = self.count + 1;
	self.sounds = track;
	
	*world_sounds = track;
	
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, track);
	WriteByte(MSG_ALL, track);
	
	self.nextthink = time + AV_SkateMusicLength(track);
};

void() AV_SkateMusicStart = {
	if(!skate_level || !find(world, classname, "trigger_skate")){
		remove(self);
		return;
	}
	
	local float skip = cvar("saved3");
	while(skip > 0){
		random();
		skip = skip - 1;
	}
	
	cvar_set("saved3", ftos(floor(random() * 64)));
	
	self.think = AV_SkateMusicPlay;
	AV_SkateMusicPlay();
	
	cvar_set("saved4", ftos(self.sounds));
};

// --- AMMO RULES -------------------------------------

void() AV_SkateCapAmmo = {
	local entity oother = other;
	other = self;
	bound_other_ammo();
	other = oother;
};

void(vector ammo1, vector ammo2, float ammo3) AV_SkateWeaponPickup = {
	other.ammo_shells1 = ammo1_x;
	other.ammo_nails1 = ammo1_y;
	other.ammo_rockets1 = ammo1_z;
	other.ammo_cells1 = ammo2_x;
	other.ammo_lava_nails = ammo2_y;
	other.ammo_multi_rockets = ammo2_z;
	other.ammo_plasma = ammo3;
	
	if(self.classname == "weapon_supershotgun") other.ammo_shells1 = other.ammo_shells1 + 5;
	else if(self.classname == "weapon_nailgun" || self.classname == "weapon_supernailgun") other.ammo_nails1 = other.ammo_nails1 + 10;
	else if(self.classname == "weapon_grenadelauncher" || self.classname == "weapon_rocketlauncher") other.ammo_rockets1 = other.ammo_rockets1 + 2;
	else if(self.classname == "weapon_lightning") other.ammo_cells1 = other.ammo_cells1 + 10;
};

// --- RAMP TILT --------------------------------------

void() AV_SkateTilt = {
	local float pitch = 0;
	local float roll = 0;
	
	makevectors([0, self.angles_y, 0]);
	traceline(self.origin, self.origin - '0 0 72', TRUE, self);
	
	if(!(self.skate_flags & SKFL_GRINDING) && trace_fraction < 1 && trace_plane_normal_z > 0.2){
		local vector normal = trace_plane_normal;
		
		local vector tangent = vectoangles(v_forward - normal * (v_forward * normal));
		pitch = tangent_x;
		
		tangent = vectoangles(v_right - normal * (v_right * normal));
		roll = tangent_x;
	}else if(vlen([self.velocity_x, self.velocity_y, 0]) > 150){
		local vector path = vectoangles(self.velocity);
		pitch = path_x;
		
		if(self.velocity * v_forward < 0) pitch = 0 - pitch;
	}
	
	if(pitch > 180) pitch = pitch - 360;
	if(roll > 180) roll = roll - 360;
	
	if(pitch > AV_SKATE_TILT_MAX) pitch = AV_SKATE_TILT_MAX;
	if(pitch < 0 - AV_SKATE_TILT_MAX) pitch = 0 - AV_SKATE_TILT_MAX;
	if(roll > AV_SKATE_TILT_MAX) roll = AV_SKATE_TILT_MAX;
	if(roll < 0 - AV_SKATE_TILT_MAX) roll = 0 - AV_SKATE_TILT_MAX;
	
	local float smooth = frametime * 16;
	if(smooth > 1) smooth = 1;
	
	self.skate_tilt_pitch = self.skate_tilt_pitch + (pitch - self.skate_tilt_pitch) * smooth;
	self.skate_tilt_roll = self.skate_tilt_roll + (roll - self.skate_tilt_roll) * smooth;
	
	self.angles_x = self.skate_tilt_pitch;
	self.angles_z = 0 - self.skate_tilt_roll;
};
