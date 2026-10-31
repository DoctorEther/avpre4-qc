// --- SPARKS AND FOV ---------------------------------

void() AV_SkateSparks = {
	if(time < self.skate_fxtime) return;
	
	self.skate_fxtime = time + 0.03;
	
	local vector org = self.origin;
	org_z = self.absmin_z + 2;
	
	local vector dir = self.velocity * -0.02;
	dir_z = 5;
	
	particle(org, dir, 232, 48);
	particle(org, dir + '6 0 3', 224, 32);
	particle(org, dir + '-6 0 3', 232, 32);
	particle(org, dir + '0 6 3', 224, 32);
	particle(org, dir + '0 -6 3', 232, 32);
	particle(org + '0 0 6', '0 0 8', 254, 24);
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if(time < self.skate_grindtime + 0.06) particle(org, '0 0 0', 0, 255);
};

void() AV_SkateFov = {
	local float cur = cvar("fov");
	local float last = cvar("saved2");
	if(last < 0) return;
	
	if(!skate_level){
		if(last > 0 && cur == last) stuffcmd(self, "fov 90\n");
		if(last > 0) cvar_set("saved2", "0");
		return;
	}
	
	if(last > 0 && cur != last){
		cvar_set("saved2", "-1");
		return;
	}
	
	if(last == 0 && cur != 90){
		cvar_set("saved2", "-1");
		return;
	}
	
	local float target;
	if(skate_level) target = 130;
	else target = 110;
	
	if(cur != target){
		if(target == 130) stuffcmd(self, "fov 130\n");
		else stuffcmd(self, "fov 110\n");
	}
	
	if(target == 130) cvar_set("saved2", "130");
	else cvar_set("saved2", "110");
};

// --- SCORE GOALS ------------------------------------

.float skate_goal_points;

void(float need, string name, string msg) AV_SkateGoal = {
	if(self.skate_points < need || self.skate_goal_points >= need) return;
	
	local entity ent = find(world, targetname, name);
	if(!ent) return;
	
	AV_SkatePrintLoc(self, msg, 1, "", "", "");
	
	local entity oself = self;
	activator = self;
	
	while(ent){
		self = ent;
		if(self.use) self.use();
		self = oself;
		
		ent = find(ent, targetname, name);
	}
};

// --- GRIND GHOST ------------------------------------

float(entity a, entity b) AV_SkateOverlap = {
	if(a.absmin_x > b.absmax_x || a.absmax_x < b.absmin_x)	return 0;
	if(a.absmin_y > b.absmax_y || a.absmax_y < b.absmin_y)	return 0;
	if(a.absmin_z > b.absmax_z || a.absmax_z < b.absmin_z)	return 0;
	
	return 1;
};

void() AV_SkateGrindGhost = {
	if((self.skate_flags & SKFL_SKATING) && (self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND)) && self.health > 0){
		if(self.owner != world && (self.owner.flags & FL_MONSTER) && self.owner.health > 0 && AV_SkateOverlap(self, self.owner)) return;
		
		local vector forward = self.velocity;
		forward_z = 0;
		forward = normalize(forward);
		
		local entity best = world;
		local float best_dist = 9999;
		
		local entity m = findradius(self.origin, 140);
		while(m){
			if((m.flags & FL_MONSTER) && m.health > 0 && m != self){
				local float dist = vlen(m.origin - self.origin);
				
				if(((m.origin - self.origin) * forward > -16 || AV_SkateOverlap(self, m)) && dist < best_dist){
					best_dist = dist;
					best = m;
				}
			}
			
			m = m.chain;
		}
		
		if(best != world) self.owner = best;
		else if(self.owner != world){
			if(!AV_SkateOverlap(self, self.owner)) self.owner = world;
		}
		
		return;
	}
	
	if(self.owner != world && (self.owner.flags & FL_MONSTER)){
		if(!AV_SkateOverlap(self, self.owner) || self.owner.health <= 0) self.owner = world;
	}
};

// --- PER FRAME --------------------------------------

void() AV_SkateAirGravity = {
	if((self.skate_flags & SKFL_SKATING) && !(self.flags & FL_ONGROUND) && self.health > 0 && !(self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND | SKFL_WALLRIDE))) self.gravity = 0.76;
	else self.gravity = 1;
};

void() AV_SkateScoreGoals = {
	AV_SkateAirGravity();
	AV_SkateIntroThink();
	AV_SkateRailHold();
	AV_SkateGrindGhost();
	AV_SkateHud();
	AV_SkateBankKeep();
	AV_SkateStoreSpeed();
	
	if(self.skate_points == self.skate_goal_points) return;
	
	AV_SkateGoal(20000, "score_amateur", "$qc_sk_goal_amateur");
	AV_SkateGoal(40000, "score_pro", "$qc_sk_goal_pro");
	AV_SkateGoal(60000, "score_sick", "$qc_sk_goal_sick");
	
	self.skate_goal_points = self.skate_points;
};

// --- SPINNING WHILE FIRING --------------------------

.float skate_spin_frame;

void() AV_SkateSpin = {
	self.frame = 143 + self.skate_spin_frame;
	
	self.skate_spin_frame = self.skate_spin_frame + 1;
	if(self.skate_spin_frame >= 6) self.skate_spin_frame = 0;
};

void() player_nail1 = [103, player_nail2] {
	if(!skate_level){
		player_nail1_campaign();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if(!self.button0){
		player_run();
		return;
	}
	
	AV_SkateSpin();
	
	self.weaponframe = self.weaponframe + 1;
	if((self.weapon == IT_NAILGUN && self.weaponframe == 7) || (self.weapon != IT_NAILGUN && self.weaponframe == 9)) self.weaponframe = 1;
	
	SuperDamageSound();
	W_FireSpikes(4);
	self.attack_finished = time + 0.2;
};

void() player_nail2 = [104, player_nail1] {
	if(!skate_level){
		player_nail2_campaign();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if(!self.button0){
		player_run();
		return;
	}
	
	AV_SkateSpin();
	
	self.weaponframe = self.weaponframe + 1;
	if(self.weaponframe == 9) self.weaponframe = 1;
	
	SuperDamageSound();
	W_FireSpikes(-4);
	self.attack_finished = time + 0.2;
};

void() player_lava_nail1 = [103, player_lava_nail2] {
	if(!skate_level){
		player_lava_nail1_campaign();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if(!self.button0){
		player_run();
		return;
	}
	
	AV_SkateSpin();
	
	self.weaponframe = self.weaponframe + 1;
	if(self.weaponframe == 9) self.weaponframe = 1;
	
	SuperDamageSound();
	W_FireLavaSpikes(4);
	self.attack_finished = time + 0.2;
};

void() player_lava_nail2 = [104, player_lava_nail1] {
	if(!skate_level){
		player_lava_nail2_campaign();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if(!self.button0){
		player_run();
		return;
	}
	
	AV_SkateSpin();
	
	self.weaponframe = self.weaponframe + 1;
	if(self.weaponframe == 9) self.weaponframe = 1;
	
	SuperDamageSound();
	W_FireLavaSpikes(-4);
	self.attack_finished = time + 0.2;
};

void() player_light1 = [105, player_light2] {
	if(!skate_level){
		player_light1_campaign();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if(!self.button0){
		player_run();
		return;
	}
	
	self.weaponframe = self.weaponframe + 1;
	if(self.weaponframe == 5) self.weaponframe = 1;
	
	SuperDamageSound();
	
	if(self.weapon == IT_LIGHTNING){
		AV_SkateSpin();
		W_FireLightning();
		self.attack_finished = time + 0.2;
	}else if(self.weapon == IT_PLASMA_GUN){
		W_FirePlasma();
		player_run();
		return;
	}
};

void() player_light2 = [106, player_light1] {
	if(!skate_level){
		player_light2_campaign();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	if(!self.button0){
		player_run();
		return;
	}
	
	self.weaponframe = self.weaponframe + 1;
	if(self.weaponframe == 5) self.weaponframe = 1;
	
	SuperDamageSound();
	
	if(self.weapon == IT_LIGHTNING){
		AV_SkateSpin();
		W_FireLightning();
		self.attack_finished = time + 0.2;
	}
};

// --- AGGRO PUSH -------------------------------------

.float skate_push_cooldown;

void() AV_SkateAggroEnd = {
	if(self.skate_flags & SKFL_GRINDING || self.skate_grindframe + 0.1 >= time) player_sk_grind5();
	else player_run();
};

void() player_sk_aggro1 = [234, player_sk_aggro2] { self.nextthink = time + 0.035; };
void() player_sk_aggro2 = [235, player_sk_aggro3] { self.nextthink = time + 0.035; };
void() player_sk_aggro3 = [236, player_sk_aggro4] { self.nextthink = time + 0.03; };
void() player_sk_aggro4 = [237, player_sk_aggro5] { self.nextthink = time + 0.06; };
void() player_sk_aggro5 = [238, player_sk_aggro6] { self.nextthink = time + 0.06; };
void() player_sk_aggro6 = [239, player_sk_aggro7] { self.nextthink = time + 0.04; };
void() player_sk_aggro7 = [240, player_sk_aggro8] { self.nextthink = time + 0.04; };
void() player_sk_aggro8 = [241, AV_SkateAggroEnd] { self.nextthink = time + 0.04; };

.float skate_pushed_time;
float skate_push_hit, skate_push_close;

void(entity m, vector fwd, float speed, float grinding) AV_SkatePushOne = {
	if(!(m.flags & FL_MONSTER) || m.health <= 0 || m.skate_pushed_time == time) return;
	
	local vector dir = m.origin - self.origin;
	dir_z = 0;
	
	if(vlen(dir) > 120 && normalize(dir) * fwd < 0.05)	return;
	if(vlen(dir) <= 120 && normalize(dir) * fwd < -0.5)	return;
	
	m.skate_pushed_time = time;
	skate_push_hit = 1;
	if(vlen(dir) < 64) skate_push_close = 1;
	
	m.flags = m.flags - (m.flags & FL_ONGROUND);
	setorigin(m, m.origin + '0 0 4');
	
	local vector side = vec3(0 - fwd_y, fwd_x, 0);
	if(side * dir < 0) side = side * -1;
	if(fabs(normalize(dir) * side) < 0.1 && random() < 0.5) side = side * -1;
	
	if(grinding) m.velocity = side * 720 + fwd * (220 + speed * 0.4) + '0 0 400';
	else m.velocity = fwd * (420 + speed * 0.8) + side * 260 + '0 0 320';
	
	if(m.th_pain){
		local entity oself = self;
		self = m;
		self.th_pain(oself, 1);
		self = oself;
	}
	
	particle(m.origin, fwd * 4, 232, 40);
};

.float skate_push_hit_time;
.float skate_push_window, skate_push_landed;

float() AV_SkatePushScan = {
	local vector h_vel = self.velocity;
	h_vel_z = 0;
	
	local float speed = vlen(h_vel);
	
	makevectors(vec3(0, self.v_angle_y, 0));
	local vector fwd = v_forward;
	if(speed > 100) fwd = normalize(h_vel);
	
	skate_push_hit = 0;
	skate_push_close = 0;
	
	local float grinding = self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND);
	local float reach = min(speed, 900);
	
	local entity m;
	if(grinding) m = findradius(self.origin + fwd * (96 + reach * 0.1), 160 + reach * 0.06);
	else m = findradius(self.origin + fwd * (64 + reach * 0.12), 112 + reach * 0.12);
	
	while(m){
		AV_SkatePushOne(m, fwd, speed, grinding);
		m = m.chain;
	}
	
	m = findradius(self.origin, 120);
	while(m){
		AV_SkatePushOne(m, fwd, speed, grinding);
		m = m.chain;
	}
	
	if(skate_push_hit){
		self.skate_push_hit_time = time;
		self.skate_push_landed = 1;
		
		sound(self, CHAN_AUTO, "player/axhit1.wav", 1, ATTN_NORM);
		
		self.velocity_x = h_vel_x;
		self.velocity_y = h_vel_y;
		
		if(skate_push_close){
			AV_SkateAddTrick("$qc_sk_perfect_push", 400);
			AV_SkateGiveAmmo(1);
			
			self.velocity_x = h_vel_x * 1.15;
			self.velocity_y = h_vel_y * 1.15;
			
			particle(self.origin, '0 0 6', 254, 60);
		}else AV_SkateAddTrick("$qc_sk_aggro_push", 150);
	}
	
	return skate_push_hit;
};

void() AV_SkateAggroPush = {
	AV_SkateGoalsKey();
	
	if(self.impulse != 72){
		if(time < self.skate_push_window && !self.skate_push_landed && self.health > 0) AV_SkatePushScan();
		return;
	}
	
	self.impulse = 0;
	
	if(!(self.skate_flags & SKFL_SKATING))	return;
	if(time < self.skate_push_cooldown)		return;
	
	self.skate_push_cooldown = time + 0.45;
	
	if(self.health > 0) player_sk_aggro1();
	
	sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
	
	self.skate_push_landed = 0;
	self.skate_push_window = time + 0.2;
	AV_SkatePushScan();
};

// --- GRIND ------------------------------------------

.float skate_softrails, skate_rail_z, skate_rail_time;

void() AV_SkateRailHold = {
	if(!world.skate_softrails || self.health <= 0) return;
	if(!(self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND)) || time > self.skate_rail_time + 0.3 || self.skate_grindstuck > time) return;
	if(self.velocity_z > 60) return;
	
	if(self.origin_z < self.skate_rail_z){
		setorigin(self, vec3(self.origin_x, self.origin_y, self.skate_rail_z));
		if(self.velocity_z < 0) self.velocity_z = 0;
	}
};

void() grind_touch = {
	if(self.estate != STATE_ACTIVE)		return;
	if(other.classname != "player")		return;
	if(!other.skate_flags)				return;
	if(other.skate_grindstuck > time)	return;
	if(!(other.skate_flags & (SKFL_STOPPEDGRIND | SKFL_GRINDING)) && other.skate_grindend + 0.25 < time && other.skate_grindbutton < time) return;
	
	if(other.skate_flags & (SKFL_STOPPEDGRIND | SKFL_GRINDING)){
		if(other.velocity_z > 60 && other.skate_grindbutton < time) return;
	}else if(other.velocity_z >= 0 && other.skate_grindbutton < time) return;
	
	//if(other.flags & FL_ONGROUND) return;
	
	if(other.skate_grindframe != time){
		other.skate_grindframe = time;
		other.skate_grindvel = other.velocity;
		other.skate_grindalign = -1;
	}
	
	local float same_grind;
	same_grind = (other.skate_flags & (SKFL_STOPPEDGRIND | SKFL_GRINDING)) || other.skate_grindend + 0.25 >= time;
	
	local vector way = other.skate_grindvel;
	if(same_grind) way = other.skate_grinddir;
	
	local float align = fabs(normalize(vec3(self.dest1_x, self.dest1_y, 0)) * normalize(vec3(way_x, way_y, 0)));
	if(align < other.skate_grindalign) return;
	other.skate_grindalign = align;
	
	if(!(other.skate_flags & (SKFL_STOPPEDGRIND | SKFL_GRINDING))){
		other.skate_grindtime = time;
		
		SUB_CallAsSelf(player_sk_grind1, other);
		
		if(!(other.skate_flags & SKFL_GRINDSOUND)){
			sound(other, CHAN_BODY, "skate/grind.wav", 1, ATTN_NORM);
			other.skate_flags = other.skate_flags | (SKFL_GRINDSOUND);
		}
		
		other.skate_flags = other.skate_flags - (other.skate_flags & (SKFL_ROLLSOUND | SKFL_WALLRIDE));
		
		if(other.skate_grindend + 0.25 < time){
			SUB_CallAsSelf(AV_SkateAddGrind, other);
			sound(other, CHAN_AUTO, "skate/grind_in.wav", 1, ATTN_NORM);
		}
		
		other.skate_grindbutton = 0;
	}
	
	other.skate_flags = other.skate_flags - (other.skate_flags & (SKFL_STOPPEDGRIND));
	other.skate_flags = other.skate_flags | (SKFL_GRINDING);
	other.skate_grind_touch_time = time;
	
	local vector dir = self.dest1;
	
	local float along;
	if(same_grind) along = normalize(vec3(self.dest1_x, self.dest1_y, 0)) * normalize(vec3(other.skate_grinddir_x, other.skate_grinddir_y, 0));
	else{
		along = normalize(vec3(self.dest1_x, self.dest1_y, 0)) * normalize(vec3(other.skate_grindvel_x, other.skate_grindvel_y, 0));
		
		if(fabs(along) < 0.25){
			makevectors(vec3(0, other.v_angle_y, 0));
			along = normalize(vec3(self.dest1_x, self.dest1_y, 0)) * v_forward;
		}
	}
	
	if(along < 0) dir = self.dest2; // invert grind angle if player is coming from the other way
	other.skate_grinddir = dir;
	
	local float spd = max(vlen(other.skate_grindvel), self.speed);
	if(spd > 820) spd = 820;
	
	other.velocity = spd * dir;
	
	local vector suck = self.origin + (self.mins + vec3(self.maxs_x, self.maxs_y, self.mins_z))*0.5 - other.origin - vec3(0, 0, other.mins_z);
	//vector suck = vec3(self.origin_x, self.origin_y, 0) + (vec3(self.mins_x, self.mins_y, 0) + vec3(self.maxs_x, self.maxs_y, 0))*0.5 - vec3(other.origin_x, other.origin_y, 0);
	suck = suck - (dir * (suck * dir));
	//other.velocity += suck * spd * 0.01;
	
	local vector old_origin = other.origin;
	
	local vector flat = normalize(vec3(dir_x, dir_y, 0));
	local vector side = vec3(suck_x, suck_y, 0);
	side = side - (flat * (side * flat));
	
	local vector way_flat = normalize(vec3(other.skate_grindvel_x, other.skate_grindvel_y, 0));
	side = side - (way_flat * (side * way_flat));
	
	if(vlen(side) < AV_SKATE_GRIND_SNAP) setorigin(other, other.origin + side);
	
	other.velocity_z = 0;
	
	if(world.skate_softrails){
		local vector rail_center = self.origin + (self.mins + self.maxs) * 0.5;
		
		local float rail_z = (self.origin_z + self.mins_z - 44 + self.origin_z + self.maxs_z - 63.5) * 0.5;
		local float base_z = rail_z;
		
		local vector rail_dir = vec3(self.dest1_x, self.dest1_y, 0);
		local float rail_len = vlen(rail_dir);
		
		if(rail_len > 0.01){
			rail_dir = rail_dir * (1 / rail_len);
			
			rail_z = rail_z + ((other.origin - rail_center) * rail_dir) * (self.dest1_z / rail_len);
			base_z = rail_z;
			
			local float ahead_z = rail_z + fabs(self.dest1_z / rail_len) * 20;
			if(ahead_z > rail_z) rail_z = min(ahead_z, self.origin_z + self.maxs_z - 63.5);
		}
		
		local float on_ledge = 0;
		
		traceline(vec3(other.origin_x, other.origin_y, base_z + 25), vec3(other.origin_x, other.origin_y, base_z - 8), TRUE, other);
		if(trace_fraction < 1) on_ledge = 1;
		
		local vector rail_side = vec3(-rail_dir_y, rail_dir_x, 0) * 16;
		
		traceline(other.origin + rail_side + vec3(0, 0, base_z + 25 - other.origin_z), other.origin + rail_side + vec3(0, 0, base_z - 8 - other.origin_z), TRUE, other);
		if(trace_fraction < 1 && trace_endpos_z >= base_z - 6) on_ledge = 1;
		
		traceline(other.origin - rail_side + vec3(0, 0, base_z + 25 - other.origin_z), other.origin - rail_side + vec3(0, 0, base_z - 8 - other.origin_z), TRUE, other);
		if(trace_fraction < 1 && trace_endpos_z >= base_z - 6) on_ledge = 1;
		
		if(!on_ledge){
			other.skate_rail_z = rail_z + 25;
			other.skate_rail_time = time;
			
			setorigin(other, vec3(other.origin_x, other.origin_y, other.skate_rail_z));
			return;
		}
		
		other.skate_rail_time = 0;
	}
	
	//other.origin_z = (self.origin_z + self.mins_z) - other.mins_z;
	setorigin(other, other.origin + '0 0 32');
	
	local entity oself = self;
	self = other;
	
	local float on_rail = droptofloor();
	if(on_rail && (pointcontents(self.origin) == CONTENT_SOLID || !droptofloor())) on_rail = FALSE;
	
	self = oself;
	
	if(!on_rail){
		setorigin(other, old_origin);
		
		other.skate_flags = other.skate_flags - (other.skate_flags & (SKFL_GRINDING));
		other.skate_flags = other.skate_flags | (SKFL_STOPPEDGRIND);
		return;
	}
	
	setorigin(other, other.origin + '0 0 8');
	
	//other.angles = vectoangles2(other.velocity);
	//other.angles_x = other.v_angle_x;
	//other.fixangle = 1;
	//dprint3("Grinding velocity: ", vtos(other.velocity), "\n");
};

// --- SCORE LINE -------------------------------------

#define AV_SKATE_HUD_LINE 16

string AV_SKATE_HUD_PADDING = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
float skate_score_goals;
.float skate_hud_time;

string() AV_SkateScoreLine = {
	local float score = rint(self.skate_points);
	if(score == 0) score = 0;
	
	local string line = strcat(" ", ftos(score));
	
	if(skate_score_goals == 0){
		skate_score_goals = 2;
		if(find(world, targetname, "score_amateur") != world) skate_score_goals = 1;
	}
	
	if(skate_score_goals != 1) return line;
	
	if(self.skate_points < 20000) return strcat(line, " / 20000");
	if(self.skate_points < 40000) return strcat(line, " / 40000");
	if(self.skate_points < 60000) return strcat(line, " / 60000");
	
	return strcat(line, "  !!!");
};

void(entity e, string msg) AV_SkatePrint = {
	if(e.classname != "player" || !(e.skate_flags & SKFL_SKATING) || intermission_running){
		builtin_centerprint(e, msg);
		return;
	}
	
	local float lines = 0;
	local float i = 0;
	local float len = strlen(msg);
	
	while(i < len){
		if(str2chr(msg, i) == 10) lines = lines + 1;
		i = i + 1;
	}
	
	local entity oself = self;
	self = e;
	
	if(lines < AV_SKATE_HUD_LINE) msg = strcat(msg, substring(AV_SKATE_HUD_PADDING, 0, AV_SKATE_HUD_LINE - lines));
	else msg = strcat(msg, "\n\n");
	
	loc_centerprint(e, "$qc_sk_hud", msg, "$qc_sk_score", AV_SkateScoreLine());
	
	self = oself;
	
	if(len > 0) e.skate_hud_time = time + max(cvar("scr_centertime"), 1) - 0.1;
};

.float skate_goals_time;

void() AV_SkateHud = {
	if(!(self.skate_flags & SKFL_SKATING) || intermission_running || time < self.skate_hud_time) return;
	
	self.skate_hud_time = time + 1;
	
	if(time < self.skate_goals_time){
		AV_SkatePrintGoals();
		return;
	}
	
	AV_SkatePrint(self, "");
};

void(entity e, string key, float lines, string a0, string a1, string a2) AV_SkatePrintLoc = {
	if(e.classname != "player" || !(e.skate_flags & SKFL_SKATING) || intermission_running){
		loc_centerprint(e, key, a0, a1, a2, "", "", "");
		return;
	}
	
	local string pad = "\n\n";
	if(lines < AV_SKATE_HUD_LINE) pad = substring(AV_SKATE_HUD_PADDING, 0, AV_SKATE_HUD_LINE - lines);
	
	local entity oself = self;
	self = e;
	local string score = AV_SkateScoreLine();
	self = oself;
	
	loc_centerprint(e, key, a0, a1, a2, pad, "$qc_sk_score", score);
	
	e.skate_hud_time = time + max(cvar("scr_centertime"), 1) - 0.1;
};

float(string s) AV_SkateIsLoc = {
	if(str2chr(s, 0) == 36) return 1;
	
	return 0;
};

void(entity e) AV_SkateHoldHud = {
	if(e.classname == "player") e.skate_hud_time = time + max(cvar("scr_centertime"), 1) - 0.1;
};

// --- CENTERPRINT ------------------------------------

void(entity client, string s1) centerprint = {
	if(!skate_level){
		builtin_centerprint(client, s1);
		return;
	}
	
	if(AV_SkateIsLoc(s1)){
		builtin_centerprint(client, s1);
		AV_SkateHoldHud(client);
		return;
	}
	
	AV_SkatePrint(client, s1);
};

void(entity client, string s1, string s2) centerprint2 = {
	if(!skate_level){
		builtin_centerprint2(client, s1, s2);
		return;
	}
	
	if(AV_SkateIsLoc(s1) || AV_SkateIsLoc(s2)){
		builtin_centerprint2(client, s1, s2);
		AV_SkateHoldHud(client);
		return;
	}
	
	AV_SkatePrint(client, strcat(s1, s2));
};

void(entity client, string s1, string s2, string s3) centerprint3 = {
	if(!skate_level){
		builtin_centerprint3(client, s1, s2, s3);
		return;
	}
	
	if(AV_SkateIsLoc(s1) || AV_SkateIsLoc(s2) || AV_SkateIsLoc(s3)){
		builtin_centerprint3(client, s1, s2, s3);
		AV_SkateHoldHud(client);
		return;
	}
	
	AV_SkatePrint(client, strcat(s1, s2, s3));
};

void(entity client, string s1, string s2, string s3, string s4) centerprint4 = {
	if(!skate_level){
		builtin_centerprint4(client, s1, s2, s3, s4);
		return;
	}
	
	if(AV_SkateIsLoc(s1) || AV_SkateIsLoc(s2) || AV_SkateIsLoc(s3) || AV_SkateIsLoc(s4)){
		builtin_centerprint4(client, s1, s2, s3, s4);
		AV_SkateHoldHud(client);
		return;
	}
	
	AV_SkatePrint(client, strcat(s1, s2, s3, s4));
};

void(entity client, string s1, string s2, string s3, string s4, string s5) centerprint5 = {
	if(!skate_level){
		builtin_centerprint5(client, s1, s2, s3, s4, s5);
		return;
	}
	
	if(AV_SkateIsLoc(s1) || AV_SkateIsLoc(s2) || AV_SkateIsLoc(s3) || AV_SkateIsLoc(s4) || AV_SkateIsLoc(s5)){
		builtin_centerprint5(client, s1, s2, s3, s4, s5);
		AV_SkateHoldHud(client);
		return;
	}
	
	AV_SkatePrint(client, strcat(s1, s2, s3, s4, s5));
};

void(entity client, string s1, string s2, string s3, string s4, string s5, string s6) centerprint6 = {
	if(!skate_level){
		builtin_centerprint6(client, s1, s2, s3, s4, s5, s6);
		return;
	}
	
	if(AV_SkateIsLoc(s1) || AV_SkateIsLoc(s2) || AV_SkateIsLoc(s3) || AV_SkateIsLoc(s4) || AV_SkateIsLoc(s5) || AV_SkateIsLoc(s6)){
		builtin_centerprint6(client, s1, s2, s3, s4, s5, s6);
		AV_SkateHoldHud(client);
		return;
	}
	
	AV_SkatePrint(client, strcat(s1, s2, s3, s4, s5, s6));
};

void(entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7) centerprint7 = {
	if(!skate_level){
		builtin_centerprint7(client, s1, s2, s3, s4, s5, s6, s7);
		return;
	}
	
	if(AV_SkateIsLoc(s1) || AV_SkateIsLoc(s2) || AV_SkateIsLoc(s3) || AV_SkateIsLoc(s4) || AV_SkateIsLoc(s5) || AV_SkateIsLoc(s6) || AV_SkateIsLoc(s7)){
		builtin_centerprint7(client, s1, s2, s3, s4, s5, s6, s7);
		AV_SkateHoldHud(client);
		return;
	}
	
	AV_SkatePrint(client, strcat(s1, s2, s3, s4, s5, s6, s7));
};

// --- BANKS AND QUARTER PIPES ------------------------

.float skate_bank_speed, skate_bank_time;
.vector skate_last_velocity, skate_last_origin;
.float skate_snag_time, skate_snag_count;

float(vector normal) AV_SkateSteep = {
	return normal_z < 0.25;
};

void() AV_SkateUnsnag = {
	local float last_z = self.skate_last_velocity_z;
	
	local vector last_vel = self.skate_last_velocity;
	last_vel_z = 0;
	local float last_speed = vlen(last_vel);
	
	local vector cur_vel = self.velocity;
	cur_vel_z = 0;
	local float cur_speed = vlen(cur_vel);
	
	local vector last_origin = self.skate_last_origin;
	self.skate_last_origin = self.origin;
	self.skate_last_velocity = self.velocity;
	
	if(time < self.skate_kick_time + 0.3)																						return;
	if(last_speed < 250 || cur_speed > last_speed * 0.35 || time < self.pausetime || self.on_ladder || self.waterlevel >= 2)	return;
	if(vlen(self.origin - last_origin) > 64)																					return;
	
	if(time > self.skate_snag_time + 0.4) self.skate_snag_count = 0;
	if(self.skate_snag_count >= 4) return;
	
	local vector dir = normalize(last_vel);
	local float clear = 1;
	local vector right = vec3(0 - dir_y, dir_x, 0) * 15;
	
	local float height;
	for(height = -12; height <= 28; height = height + 20){
		traceline(self.origin + vec3(0, 0, height), self.origin + vec3(0, 0, height) + dir * 40, TRUE, self);
		if(trace_fraction < 1 && !trace_startsolid && AV_SkateSteep(trace_plane_normal)) clear = 0;
		
		traceline(self.origin + vec3(0, 0, height) + right, self.origin + vec3(0, 0, height) + right + dir * 40, TRUE, self);
		if(trace_fraction < 1 && !trace_startsolid && AV_SkateSteep(trace_plane_normal)) clear = 0;
		
		traceline(self.origin + vec3(0, 0, height) - right, self.origin + vec3(0, 0, height) - right + dir * 40, TRUE, self);
		if(trace_fraction < 1 && !trace_startsolid && AV_SkateSteep(trace_plane_normal)) clear = 0;
	}
	
	if(!clear) return;
	
	self.skate_snag_time = time;
	self.skate_snag_count = self.skate_snag_count + 1;
	
	setorigin(self, self.origin + '0 0 2');
	
	self.velocity_x = last_vel_x * 0.95;
	self.velocity_y = last_vel_y * 0.95;
	if(self.velocity_z < last_z) self.velocity_z = last_z;
	if(self.velocity_z < 0) self.velocity_z = 0;
	
	self.skate_last_velocity = self.velocity;
};

.vector skate_bank_normal, skate_floor_normal;
.float skate_was_on_ground, skate_bank_normal_time;

.float skate_kick, skate_kick_speed, skate_kick_on, skate_kick_factor, skate_prev_hspeed, skate_cur_hspeed;

float AV_SKATE_BANK_NZ = 0.75;

float(entity e, vector normal) AV_SkateIsBank = {
	local float normal_up = normal_z;
	
	if(e.classname == "func_wall")					return TRUE;
	if(e == world && normal_up < AV_SKATE_BANK_NZ)	return TRUE;
	
	return FALSE;
};

void(vector normal) AV_SkateKick = {
	if(normal_z > 0.95 || normal_z < 0.15 || self.velocity_z < 120) return;
	
	local vector h_normal = normalize(vec3(normal_x, normal_y, 0));
	local vector h_vel = vec3(self.velocity_x, self.velocity_y, 0);
	
	local float perp = h_vel * h_normal;
	if(perp > -100) return;
	
	if(self.movement_x > 50){
		h_vel = h_vel - h_normal * (perp * 0.5);
		self.velocity_z = vlen(vec3(self.velocity_z, perp * 0.866, 0));
	}else{
		h_vel = h_vel - h_normal * (perp * 1.06);
		self.velocity_z = vlen(vec3(self.velocity_z, perp * 0.998, 0));
		
		if(perp < -180 && self.velocity_z < 560) self.velocity_z = 560;
	}
	
	self.velocity_x = h_vel_x;
	self.velocity_y = h_vel_y;
	
	self.skate_kick_time = time;
};

void() AV_SkateBankKeep = {
	if(!(self.skate_flags & SKFL_SKATING) || (self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND)) || time < self.skate_grindend + 0.5 || self.health <= 0){
		self.skate_bank_speed = 0;
		self.skate_last_velocity = '0 0 0';
		self.skate_was_on_ground = 0;
		return;
	}
	
	local float speed = vlen(self.velocity);
	
	if(time > self.skate_kick_on + 0.15){
		self.skate_prev_hspeed = self.skate_cur_hspeed;
		self.skate_cur_hspeed = vlen(vec3(self.velocity_x, self.velocity_y, 0));
	}
	
	AV_SkateUnsnag();
	
	speed = vlen(self.velocity);
	
	if(self.skate_bank_speed > 150 && speed > 1 && self.velocity_z > 20){
		if(self.flags & FL_ONGROUND) self.skate_bank_time = time;
		
		if(time < self.skate_bank_time + 0.3){
			local float want = self.skate_bank_speed - cvar("sv_gravity") * frametime * (self.velocity_z / speed);
			
			if(speed < want && speed > self.skate_bank_speed * 0.5 && self.velocity_z < speed * 0.97){
				self.velocity = self.velocity * (want / speed);
				speed = want;
			}
		}
	}
	
	self.skate_bank_speed = speed;
	
	if(self.flags & FL_ONGROUND){
		traceline(self.origin, self.origin - '0 0 48', TRUE, self);
		
		if(trace_fraction < 1 && trace_ent.skate_kick > 0){
			if(time > self.skate_kick_on + 0.15) self.skate_kick_speed = max(vlen(vec3(self.velocity_x, self.velocity_y, 0)), self.skate_prev_hspeed);
			if(self.skate_kick_speed < 250) self.skate_kick_speed = 250;
			
			self.skate_kick_on = time;
			self.skate_kick_factor = trace_ent.skate_kick;
			
			if(speed > 1 && self.velocity_z > 0){
				self.velocity = self.velocity * (self.skate_kick_speed / speed);
				self.skate_bank_speed = self.skate_kick_speed;
			}
			
			self.skate_was_on_ground = 1;
			self.skate_bank_normal = '0 0 1';
			return;
		}
		
		if(trace_fraction < 1 && !AV_SkateIsBank(trace_ent, trace_plane_normal)) traceline(self.origin + '5 3 0', self.origin + '5 3 -48', TRUE, self);
		
		self.skate_floor_normal = '0 0 1';
		if(trace_fraction < 1 && AV_SkateIsBank(trace_ent, trace_plane_normal)) self.skate_floor_normal = trace_plane_normal;
		
		if(self.skate_floor_normal_z < self.skate_bank_normal_z || time > self.skate_bank_normal_time + 0.2){
			self.skate_bank_normal = self.skate_floor_normal;
			self.skate_bank_normal_time = time;
		}
		
		self.skate_was_on_ground = 1;
	}else{
		if(self.skate_was_on_ground && time < self.skate_kick_on + 0.1 && self.velocity_z > 0){
			local vector h_vel = normalize(vec3(self.velocity_x, self.velocity_y, 0)) * self.skate_kick_speed;
			
			self.velocity_x = h_vel_x;
			self.velocity_y = h_vel_y;
			if(self.velocity_z < self.skate_kick_speed * self.skate_kick_factor) self.velocity_z = self.skate_kick_speed * self.skate_kick_factor;
			
			self.skate_kick_time = time;
			self.skate_kick_on = 0;
		}else if(self.skate_was_on_ground) AV_SkateKick(self.skate_bank_normal);
		
		self.skate_was_on_ground = 0;
	}
};
