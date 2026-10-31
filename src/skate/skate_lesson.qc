// --- SKATE LESSONS ----------------------------------

.string lesson;
.float lesson_done, lesson_message_time, lesson_grind_time;

float(entity p) AV_SkateLessonOk = {
	local float h_speed = vlen(vec3(p.velocity_x, p.velocity_y, 0));
	
	if(self.lesson == "push") return h_speed >= self.goalvalue;
	
	if(self.lesson == "brake"){
		if(self.cnt == 0){
			if(h_speed >= 300) self.cnt = 1;
			return 0;
		}
		
		return h_speed < 60;
	}
	
	if(self.lesson == "back"){
		makevectors(vec3(0, p.v_angle_y, 0));
		return (v_forward * vec3(p.velocity_x, p.velocity_y, 0)) < 0 - self.goalvalue;
	}
	
	if(self.lesson == "trick") return p.frame == self.goalvalue;
	if(self.lesson == "vert") return !(p.flags & FL_ONGROUND) && p.origin_z - 24 > self.goalvalue;
	if(self.lesson == "wallride") return (p.skate_flags & SKFL_WALLRIDE) != 0;
	
	if(self.lesson == "grind"){
		if(!(p.skate_flags & (SKFL_GRINDING | SKFL_STOPPEDGRIND))){
			self.lesson_grind_time = 0;
			return 0;
		}
		
		if(!self.lesson_grind_time) self.lesson_grind_time = time;
		return time >= self.lesson_grind_time + self.goalvalue;
	}
	
	if(self.lesson == "aggro") return p.skate_push_hit_time > time - 0.5;
	if(self.lesson == "combo") return p.skate_combo >= self.goalvalue;
	if(self.lesson == "score") return p.skate_points >= self.goalvalue;
	if(self.lesson == "goalskey") return p.skate_goals_time > time;
	
	return 1;
};

void() AV_SkateLessonThink = {
	self.nextthink = time + 0.02;
	
	if(self.lesson_done)	return;
	if(skate_intro == 1)	return;
	
	local entity p = find(world, classname, "player");
	while(p){
		if(p.health > 0 && p.absmin_x <= self.absmax_x && p.absmax_x >= self.absmin_x && p.absmin_y <= self.absmax_y && p.absmax_y >= self.absmin_y && p.absmin_z <= self.absmax_z && p.absmax_z >= self.absmin_z){
			if(AV_SkateLessonOk(p)){
				self.lesson_done = 1;
				p.skate_goals_time = 0;
				
				if(self.netname != "") centerprint(p, self.netname);
				sound(p, CHAN_AUTO, "misc/secret.wav", 1, ATTN_NORM);
				activator = p;
				
				local string msg = self.message;
				self.message = "";
				SUB_UseTargets();
				self.message = msg;
				
				return;
			}
			
			if(time > self.lesson_message_time && self.message != ""){
				self.lesson_message_time = time + 4;
				centerprint(p, self.message);
			}
		}
		
		p = find(p, classname, "player");
	}
};

void() trigger_skate_lesson = {
	InitTrigger();
	
	self.touch = SUB_Null;
	self.think = AV_SkateLessonThink;
	self.nextthink = time + 1;
	
	precache_sound("misc/secret.wav");
};
