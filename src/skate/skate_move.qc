// --- SKATE MOVEMENT ---------------------------------

float AV_SKATE_PUSH_ACCEL			= 1208;
float AV_SKATE_PUSH_MIN				= 0.95;
float AV_SKATE_UPHILL				= 0.5;
float AV_SKATE_COAST				= 150;
float AV_SKATE_BRAKE				= 650;
float AV_SKATE_FLAT_NZ				= 0.97;
float AV_SKATE_BANK_FRICTION		= 0;
float AV_SKATE_GRIND_HOLD			= 0.25;
float AV_SKATE_GRINDBUTTON_WINDOW	= 0.45;
float AV_SKATE_ASSIST_SIDE			= 52;

float(float a, float b) skate_pow = #97;

float(float base, float push) AV_SkatePushAccel = {
	local float mult = 1;
	if(push > 1) mult = 2 - base / push;
	if(mult < 1) mult = 1;
	
	return AV_SKATE_PUSH_ACCEL * mult;
};

void() AV_SkateUpdate = {
	if(!skate_level){
		AV_CampaignSkateUpdate();
		return;
	}
	
	if(!(self.skate_flags & SKFL_SKATING)) return;
	
#ifdef SKTEST
	if(cvar("temp1")) self.movement_x = cvar("temp1");
	if(cvar("scratch1")) self.movement_y = cvar("scratch1");
#endif
	
	AV_SkateTilt();
	
	if(self.skate_grindbutton > time + AV_SKATE_GRINDBUTTON_WINDOW) self.skate_grindbutton = time + AV_SKATE_GRINDBUTTON_WINDOW;
	
	if(!(self.skate_flags & SKFL_GRINDING)){
		skate_extractCommands();
		skate_checkCombos();
	}
	
	if((self.skate_flags & SKFL_STOPPEDGRIND) && time < self.skate_grind_touch_time + AV_SKATE_GRIND_HOLD && self.skate_grindstuck <= time && self.health > 0){
		local vector grind_dir = self.skate_grinddir;
		grind_dir_z = 0;
		
		if(vlen(grind_dir) > 0.1){
			local float hold_speed = vlen(vec3(self.velocity_x, self.velocity_y, 0));
			if(hold_speed < 100) hold_speed = 100;
			
			grind_dir = normalize(grind_dir);
			
			self.velocity_x = grind_dir_x * hold_speed;
			self.velocity_y = grind_dir_y * hold_speed;
			if(self.velocity_z < 0) self.velocity_z = 0;
			
			self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_STOPPEDGRIND);
			self.skate_flags = self.skate_flags | SKFL_GRINDING;
		}
	}
	
	// clears grinding flag
	// if player is still grinding, the trigger itself will set it back again on the same frame
	if(self.skate_flags & SKFL_STOPPEDGRIND){
		local float grindpoints = (time - self.skate_grindtime) * 50;
		self.skate_combo = self.skate_combo + grindpoints;
		self.skate_grindend = time;
		
		self.skate_grindtime = 0;
		self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_STOPPEDGRIND);
		player_run();
	}
	
	if(self.skate_flags & SKFL_GRINDING){
		self.skate_flags = self.skate_flags | SKFL_STOPPEDGRIND;
		self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_GRINDING);
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
	
	if(self.skate_flags & SKFL_TRICK){
		self.skate_flags = self.skate_flags - (self.skate_flags & SKFL_TRICK);
		player_run();
	}
	
	local float framefactor = frametime / 0.013888; // baseline is 72fps, modulate parameters according to that
	
	local float max_speed = AV_SKATE_SPEED_LIMIT;
	if(world.skate_speed) max_speed = world.skate_speed;
	
	local float push_speed = max_speed * 0.9;
	if(world.skate_push) push_speed = world.skate_push;
	if(push_speed < max_speed * AV_SKATE_PUSH_MIN) push_speed = max_speed * AV_SKATE_PUSH_MIN;
	if(push_speed > max_speed) push_speed = max_speed;
	
	local float h_speed = vlen(vec3(self.velocity_x, self.velocity_y, 0));
	local float base = h_speed;
	if(self.skate_hspeed_time > time - 0.2 && h_speed < self.skate_hspeed * 1.02 + 140) base = self.skate_hspeed;
	
	local float coast = AV_SKATE_COAST;
	if(world.skate_friction > 1.04) coast = AV_SKATE_COAST * 0.8;
	
	traceline(self.origin, self.origin - '0 0 64', TRUE, self);
	local vector normal = trace_plane_normal;
	if(trace_fraction < 1 && normal_z < AV_SKATE_FLAT_NZ) coast = coast * AV_SKATE_BANK_FRICTION;
	
	local float target;
	if(self.skate_flags & SKFL_STOPPEDGRIND) target = h_speed;
	else if(self.movement_x > 50 || (fabs(self.movement_y) > 50 && self.movement_x > -50)){
		if(base < push_speed) target = min(push_speed, base + AV_SkatePushAccel(base, push_speed) * frametime);
		else target = base;
	}else if(self.movement_x < -50){
		makevectors(vec3(0, self.angles_y, 0));
		
		local float dot = 1;
		if(h_speed > 1) dot = (v_forward * vec3(self.velocity_x, self.velocity_y, 0)) / h_speed;
		
		if(dot > 0.5 && h_speed > 40) target = max(0, base - AV_SKATE_BRAKE * 1.4 * frametime);
		else if(dot > 0.5){
			self.velocity_x = 0;
			self.velocity_y = 0;
			h_speed = 0;
			target = 60;
		}else if(base < push_speed) target = min(push_speed, base + AV_SkatePushAccel(base, push_speed) * frametime);
		else target = base - coast * 0.5 * frametime;
	}else target = max(0, base - coast * frametime);
	
	local vector l_vec, v_vec, r_vec;
	
	if(h_speed > 1){
		self.velocity_x = self.velocity_x * (target / h_speed);
		self.velocity_y = self.velocity_y * (target / h_speed);
	}else if(target > 1){
		l_vec = MovementVector();
		l_vec_z = 0;
		
		if(vlen(l_vec) < 0.1){
			makevectors(vec3(0, self.angles_y, 0));
			l_vec = v_forward;
		}
		
		l_vec = normalize(l_vec);
		
		self.velocity_x = l_vec_x * target;
		self.velocity_y = l_vec_y * target;
	}
	
	if(world.skate_slope){
		traceline(self.origin, self.origin - '0 0 64', TRUE, self);
		normal = trace_plane_normal;
		
		if(trace_fraction < 1 && normal_z < 0.99 && normal_z > 0.5){
			local float slope = 1;
			if(self.movement_x > 50 && normal_x * self.velocity_x + normal_y * self.velocity_y < 0) slope = AV_SKATE_UPHILL;
			
			self.velocity_x = self.velocity_x + normal_x * cvar("sv_gravity") * frametime * world.skate_slope * slope;
			self.velocity_y = self.velocity_y + normal_y * cvar("sv_gravity") * frametime * world.skate_slope * slope;
		}
	}
	
	//ROTATE VELOCITY TOWARDS LOOKING VECTOR
	l_vec = MovementVector();
	l_vec_z = 0;
	l_vec = normalize(l_vec);
	
	v_vec = self.velocity;
	v_vec_z = 0;
	
	local float s_speed = vlen(v_vec); //SPEED
	if(s_speed > max_speed) s_speed = max_speed;
	
	v_vec = normalize(v_vec);
	
	r_vec_x = v_vec_x + (l_vec_x - v_vec_x) * AV_SKATE_ROTATION_SPEED * framefactor;
	r_vec_y = v_vec_y + (l_vec_y - v_vec_y) * AV_SKATE_ROTATION_SPEED * framefactor;
	r_vec_z = 0;
	
	r_vec = normalize(r_vec);
	
	self.velocity_x = r_vec_x * s_speed;
	self.velocity_y = r_vec_y * s_speed;
};

void() AV_SkateStoreSpeed = {
	self.skate_hspeed = vlen(vec3(self.velocity_x, self.velocity_y, 0));
	self.skate_hspeed_time = time;
};

void() AV_SkateGrindAssist = {
	if(self.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND | SKFL_WALLRIDE))	return;
	if(self.skate_grindstuck > time)											return;
	if(self.skate_grindbutton < time)											return;
	
	local float above = 110;
	local float below = 56;
	
	local vector h_vel = vec3(self.velocity_x, self.velocity_y, 0);
	local vector ahead = self.origin + h_vel * 0.06;
	h_vel = normalize(h_vel);
	
	local entity best = world;
	local float best_dist = AV_SKATE_ASSIST_SIDE;
	local float best_z = 0;
	
	local entity rail = findradius(self.origin, 400);
	while(rail){
		if(rail.classname == "trigger_grind" && rail.estate == STATE_ACTIVE){
			local vector center = (rail.absmin + rail.absmax) * 0.5;
			local vector dir = normalize(vec3(rail.dest1_x, rail.dest1_y, 0));
			local float half = (fabs(dir_x) * (rail.absmax_x - rail.absmin_x) + fabs(dir_y) * (rail.absmax_y - rail.absmin_y)) * 0.5;
			
			local float along = (ahead - center) * dir;
			if(along > half) along = half;
			if(along < -half) along = -half;
			
			local vector point = center + dir * along;
			point_z = center_z + along * rail.dest1_z / vlen(vec3(rail.dest1_x, rail.dest1_y, 0));
			
			local float dist = vlen(vec3(ahead_x - point_x, ahead_y - point_y, 0));
			
			local float align = fabs(dir * h_vel);
			if(vlen(h_vel) < 0.5) align = 1;
			
			if((align > 0.6 || dist < 20) && dist < best_dist && self.origin_z > point_z - 34 - below && self.origin_z < point_z + 26 + above){
				best = rail;
				best_dist = dist;
				best_z = point_z;
			}
		}
		
		rail = rail.chain;
	}
	
	if(!best) return;
	
	local vector old_origin = self.origin;
	if(self.origin_z < best_z - 28) setorigin(self, vec3(self.origin_x, self.origin_y, best_z - 28));
	
	local entity oself = self;
	local entity oother = other;
	other = self;
	self = best;
	grind_touch();
	self = oself;
	other = oother;
	
	if(!(self.skate_flags & SKFL_GRINDING)) setorigin(self, old_origin);
};
