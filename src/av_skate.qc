
#define AV_SKATE_FRICTION_WMOD 1.04
#define AV_SKATE_FRICTION_SMOD 1.08
#define AV_SKATE_ROTATION_SPEED 0.04
#define AV_SKATE_SPEED_LIMIT 1024

void() AV_SkateUpdate = {
	if(!self.av_skating) return;
	
	skate_extractCommands();
	skate_checkCombos();

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
	if(s_speed > AV_SKATE_SPEED_LIMIT) s_speed = AV_SKATE_SPEED_LIMIT;
	
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

float FLSKATE_JUMPED = 1;

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

	if (self.skate_flags & FLSKATE_JUMPED)// && !(self.skate_lastcommands[lastidx] & CMD_JUMP))
		currentcommand |= CMD_JUMP;

	self.skate_flags &~= FLSKATE_JUMPED;

	if (currentcommand && (
			(currentcommand & 31 != skate_getCommand(-1) & 31) || // if changed from last command
			!(self.skate_lastcommands[SKATE_LASTCOMMAND_BUFFERSIZE] & 31) // if previous frame had no commands
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
		
		/*dprint("; last command: ");
		if (self.skate_lastcommands[lastidx] & CMD_FORWARD) dprint("F ");
		if (self.skate_lastcommands[lastidx] & CMD_BACK) dprint("B ");
		if (self.skate_lastcommands[lastidx] & CMD_RIGHT) dprint("R ");
		if (self.skate_lastcommands[lastidx] & CMD_LEFT) dprint("L ");
		if (self.skate_lastcommands[lastidx] & CMD_JUMP) dprint("J ");
		if (self.skate_lastcommands[lastidx] & CMD_OFFGROUND) dprint("A ");
		*/
		dprint("\n");

		self.skate_lastcommand_nextindex = skate_getIndex(1);

	}

	// save current command at last buffer position, regardless if it changed or not
	// this way we can detect sequential commands next iteration
	self.skate_lastcommands[SKATE_LASTCOMMAND_BUFFERSIZE] = currentcommand;
}

void() skate_checkCombos = {
	float idx = self.skate_lastcommand_nextindex;

	// flip
	if (
		skate_getCommand(-1) & (CMD_LEFT | CMD_OFFGROUND) == CMD_LEFT | CMD_OFFGROUND &&
		(
			skate_getCommand(-2) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND ||
			skate_getCommand(-3) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND
		)
	) {
		centerprint2(self, ftos(time), " - Flip\n");
		//sound (self, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		skate_clearCommands();
		return;
	}

	// flip
	if (
		skate_getCommand(-1) & (CMD_LEFT | CMD_OFFGROUND) == CMD_LEFT | CMD_OFFGROUND &&
		(
			skate_getCommand(-2) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND ||
			skate_getCommand(-3) & (CMD_RIGHT | CMD_OFFGROUND) == CMD_RIGHT | CMD_OFFGROUND
		)
	) {
		centerprint2(self, ftos(time), " - Flip\n");
		//sound (self, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		skate_clearCommands();
		return;
	}
}

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