// --- SKATE GOALS ------------------------------------

.string goaltype;
.float goalvalue;
.float goal_done, goal_start_count;
.float goal_selected, goal_nav_dir;
.entity goal_counter;

float skate_intro;
float skate_intro_index, skate_intro_time, skate_intro_phase;
vector skate_intro_from, skate_intro_to, skate_intro_look, skate_intro_look_from, skate_intro_angles;
entity skate_intro_goal, skate_intro_player;

void() AV_SkateGoalUse = {
	self.goal_done = 1;
};

void() AV_SkateGoalInit = {
	if(self.goaltype == "counter"){
		self.goal_counter = find(world, targetname, self.target);
		if(self.goal_counter) self.goal_start_count = self.goal_counter.count;
	}
};

void() info_skate_goal = {
	self.use = AV_SkateGoalUse;
	self.think = AV_SkateGoalInit;
	self.nextthink = time + 0.3;
};

// --- GOALS LIST -------------------------------------

string skate_goal_progress;

float(entity g) AV_SkateGoalDone = {
	skate_goal_progress = "";
	
	if(g.goaltype == "counter"){
		local entity e = g.goal_counter;
		if(!e || e.classname != "trigger_counter") return 1;
		
		if(g.goal_start_count > 0) skate_goal_progress = strcat(" (", ftos(g.goal_start_count - e.count), "/", ftos(g.goal_start_count), ")");
		return 0;
	}
	
	if(g.goaltype == "removed"){
		if(find(world, targetname, g.target) == world) return 1;
		return 0;
	}
	
	if(g.goaltype == "score"){
		if(self.skate_points >= g.goalvalue) return 1;
		return 0;
	}
	
	if(g.goaltype == "fired") return g.goal_done;
	
	return 0;
};

string skate_goal_arg0, skate_goal_arg1, skate_goal_arg2, skate_goal_arg3, skate_goal_arg4, skate_goal_arg5, skate_goal_buffer;
float skate_goal_arg_count;

void(string a) AV_SkateGoalArg = {
	if(skate_goal_arg_count == 0) skate_goal_arg0 = a;
	else if(skate_goal_arg_count == 1) skate_goal_arg1 = a;
	else if(skate_goal_arg_count == 2) skate_goal_arg2 = a;
	else if(skate_goal_arg_count == 3) skate_goal_arg3 = a;
	else if(skate_goal_arg_count == 4) skate_goal_arg4 = a;
	else if(skate_goal_arg_count == 5) skate_goal_arg5 = a;
	else skate_goal_arg5 = "\n...";
	
	skate_goal_arg_count = skate_goal_arg_count + 1;
};

void() AV_SkateGoalFlush = {
	if(skate_goal_buffer != ""){
		AV_SkateGoalArg(skate_goal_buffer);
		skate_goal_buffer = "";
	}
};

string(float value) AV_SkateScoreName = {
	if(value == 20000) return "AMATEUR 20000";
	if(value == 40000) return "PRO 40000";
	if(value == 60000) return "SICK 60000";
	
	return ftos(value);
};

void() AV_SkatePrintGoals = {
	local float count = 0;
	local float scores = 0;
	
	skate_goal_arg_count = 0;
	skate_goal_buffer = "";
	
	skate_goal_arg0 = "";
	skate_goal_arg1 = "";
	skate_goal_arg2 = "";
	skate_goal_arg3 = "";
	skate_goal_arg4 = "";
	skate_goal_arg5 = "";
	
	local entity g = find(world, classname, "info_skate_goal");
	while(g){
		if(!(g.spawnflags & 2)){
			count = count + 1;
			
			if(g.goaltype == "score"){
				if(!scores){
					scores = 1;
					
					local entity h = find(world, classname, "info_skate_goal");
					while(h){
						if(!(h.spawnflags & 2) && h.goaltype == "score"){
							if(AV_SkateGoalDone(h)) skate_goal_buffer = strcat(skate_goal_buffer, "\n[OK] ", AV_SkateScoreName(h.goalvalue));
							else skate_goal_buffer = strcat(skate_goal_buffer, "\n[  ] ", AV_SkateScoreName(h.goalvalue));
						}
						
						h = find(h, classname, "info_skate_goal");
					}
				}
			}else if(AV_SkateIsLoc(g.message)){
				AV_SkateGoalFlush();
				
				if(g.goaltype != "info" && AV_SkateGoalDone(g)) AV_SkateGoalArg(strcat(g.message, "_ok"));
				else AV_SkateGoalArg(strcat(g.message, "_todo"));
			}else if(g.goaltype == "info") skate_goal_buffer = strcat(skate_goal_buffer, "\n      ", g.message);
			else if(AV_SkateGoalDone(g)) skate_goal_buffer = strcat(skate_goal_buffer, "\n[OK] ", g.message);
			else skate_goal_buffer = strcat(skate_goal_buffer, "\n[  ] ", g.message, skate_goal_progress);
		}
		
		g = find(g, classname, "info_skate_goal");
	}
	
	AV_SkateGoalFlush();
	
	if(count == 0){
		AV_SkatePrintLoc(self, "$qc_sk_nogoals", 1, "", "", "");
		return;
	}
	
	if(AV_SkateHudActive(self)) AV_SkateSendText(self, AV_SKATE_SLOT_GOALS, "$qc_sk_goals_all", skate_goal_arg0, skate_goal_arg1, skate_goal_arg2, skate_goal_arg3, skate_goal_arg4, skate_goal_arg5);
	else loc_centerprint(self, "$qc_sk_goals_all", skate_goal_arg0, skate_goal_arg1, skate_goal_arg2, skate_goal_arg3, skate_goal_arg4, skate_goal_arg5);
	
#ifdef SKTEST
	bprint("GOALS[", skate_goal_arg0, "|", skate_goal_arg1, "|", skate_goal_arg2, "|", skate_goal_arg3);
	bprint("|", skate_goal_arg4, "|", skate_goal_arg5, "]\n");
#endif
};

void() AV_SkateGoalsKey = {
	if(self.impulse == 74){
		self.impulse = 0;
		self.skate_goals_time = time + 8;
		AV_SkatePrintGoals();
	}
};

// --- INTRO FLYOVER ----------------------------------

entity(entity from) AV_SkateNextCamGoal = {
	local entity g = find(from, classname, "info_skate_goal");
	while(g && (g.spawnflags & 1)) g = find(g, classname, "info_skate_goal");
	
	return g;
};

entity(entity to) AV_SkatePrevCamGoal = {
	local entity prev = world;
	
	local entity g = AV_SkateNextCamGoal(world);
	while(g && g != to){
		prev = g;
		g = AV_SkateNextCamGoal(g);
	}
	
	return prev;
};

vector(entity g) AV_SkateCamSpot = {
	local vector look = g.origin + '0 0 32';
	
	local vector dir = skate_intro_player.origin - look;
	dir_z = 0;
	if(vlen(dir) < 1) dir = '1 0 0';
	dir = normalize(dir);
	
	local vector spot = look + dir * 360 + '0 0 260';
	
	traceline(look, spot, TRUE, world);
	if(trace_fraction < 1) spot = trace_endpos + normalize(look - spot) * 24;
	
	return spot;
};

float() AV_SkateIntroRunning = {
	return skate_intro == 1 && self == skate_intro_player;
};

void(entity plr) AV_SkateIntroEnd = {
	skate_intro = 2;
	
	local entity oself = self;
	self = plr;
	
	self.movetype = MOVETYPE_WALK;
	self.flags = self.flags - (self.flags & FL_NOTARGET);
	self.takedamage = 2;
	
	self.v_angle = skate_intro_angles;
	self.angles = skate_intro_angles;
	self.fixangle = 1;
	
	AV_CameraOn();
	
	self.skate_goals_time = time + 8;
	AV_SkatePrintGoals();
	
	self = oself;
};

void() AV_SkateIntroStart = {
	if(!(self.skate_flags & SKFL_SKATING)){
		skate_intro = 2;
		return;
	}
	
	local entity g = AV_SkateNextCamGoal(world);
	if(!g){
		skate_intro = 2;
		return;
	}
	
	if(!self.av_camera){
		skate_intro = 2;
		return;
	}
	
	skate_intro = 1;
	skate_intro_player = self;
	skate_intro_goal = g;
	skate_intro_phase = 0;
	skate_intro_time = time;
	skate_intro_index = 1;
	skate_intro_angles = self.v_angle;
	
	self.av_camera_active = 0;
	
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.flags = self.flags | FL_NOTARGET;
	self.takedamage = 0;
	
	skate_intro_from = self.origin + '0 0 400';
	skate_intro_look_from = self.origin;
	skate_intro_to = AV_SkateCamSpot(g);
	skate_intro_look = g.origin + '0 0 32';
};

void() AV_SkateIntroThink = {
	if(skate_intro == 0){
		if(cvar("temp1") == 1){
			skate_intro = 2;
			return;
		}
		
		if(time > 1.0 && (self.skate_flags & SKFL_SKATING)) AV_SkateIntroStart();
		else if(time > 5) skate_intro = 2;
		
		return;
	}
	
	if(skate_intro != 1 || self != skate_intro_player) return;
	
	if(self.button2 || self.button0){
		AV_SkateIntroEnd(self);
		return;
	}
	
	local float nav = 0;
	if(self.movement_y < -150) nav = -1;
	else if(self.movement_y > 150) nav = 1;
	
	local entity g;
	if(nav != 0 && nav != self.goal_nav_dir){
		if(nav > 0) g = AV_SkateNextCamGoal(skate_intro_goal);
		else g = AV_SkatePrevCamGoal(skate_intro_goal);
		
		if(g){
			skate_intro_from = self.av_camera.origin;
			skate_intro_look_from = skate_intro_look;
			
			skate_intro_goal = g;
			skate_intro_index = skate_intro_index + nav;
			skate_intro_phase = 0;
			skate_intro_time = time;
			
			skate_intro_to = AV_SkateCamSpot(g);
			skate_intro_look = g.origin + '0 0 32';
		}
	}
	
	self.goal_nav_dir = nav;
	
	local float travel = 0.9;
	local float hold = 1.5;
	
	local float frac = (time - skate_intro_time) / travel;
	if(frac > 1) frac = 1;
	frac = frac * frac * (3 - 2 * frac);
	
	local vector pos = skate_intro_from + (skate_intro_to - skate_intro_from) * frac;
	local vector look = skate_intro_look_from + (skate_intro_look - skate_intro_look_from) * frac;
	
	setorigin(self.av_camera, pos);
	
	self.v_angle = vectoangles(look - pos);
	self.v_angle_x = 0 - self.v_angle_x;
	self.angles = self.v_angle;
	self.fixangle = 1;
	
	if(skate_intro_phase == 0 && time > skate_intro_time + travel * 0.6){
		skate_intro_phase = 1;
		
		local float count = 0;
		g = AV_SkateNextCamGoal(world);
		while(g){
			count = count + 1;
			g = AV_SkateNextCamGoal(g);
		}
		
		if(AV_SkateHudActive(self)) AV_SkateSendText(self, AV_SKATE_SLOT_INTRO, "$qc_sk_intro", ftos(skate_intro_index), ftos(count), skate_intro_goal.message, "", "", "");
		else loc_centerprint(self, "$qc_sk_intro", ftos(skate_intro_index), ftos(count), skate_intro_goal.message);
		self.skate_hud_time = time + 2;
	}
	
	if(time > skate_intro_time + travel + hold){
		g = AV_SkateNextCamGoal(skate_intro_goal);
		if(!g){
			AV_SkateIntroEnd(self);
			return;
		}
		
		skate_intro_from = pos;
		skate_intro_look_from = skate_intro_look;
		
		skate_intro_goal = g;
		skate_intro_index = skate_intro_index + 1;
		skate_intro_phase = 0;
		skate_intro_time = time;
		
		skate_intro_to = AV_SkateCamSpot(g);
		skate_intro_look = g.origin + '0 0 32';
	}
};
