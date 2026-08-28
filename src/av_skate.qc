
#define AV_SKATE_FRICTION_WMOD 1.04
#define AV_SKATE_FRICTION_SMOD 1.08
#define AV_SKATE_ROTATION_SPEED 0.04
#define AV_SKATE_SPEED_LIMIT 1024

void() AV_SkateUpdate = {
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

void(entity plr) AV_SkateOn = {
	entity tmp = self;
	self = plr;

	self.av_skating = TRUE;
	AV_CameraOn();

	setmodel(self, "progs/splayer.mdl");
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	modelindex_player = self.modelindex;

	self = tmp;
}

void(entity plr) AV_SkateOff = {
	entity tmp = self;
	self = plr;

	self.av_skating = FALSE;
	AV_CameraOff();

	setmodel(self, "progs/player.mdl");
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	modelindex_player = self.modelindex;

	self = tmp;
}

void() AV_SwitchSkate = {
	if (self.av_skating)
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

	if (self.state == 0 && !other.av_skating) {
		AV_SkateOn(other);
	}
	else if (self.state == 1 && other.av_skating) {
		AV_SkateOff(other);
	}
};

void() trigger_skate = {
	InitTrigger();
    self.touch = skate_touch;

	SUB_CheckWaiting();
};