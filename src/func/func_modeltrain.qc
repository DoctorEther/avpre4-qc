
void() modeltrain_use =
{
	if (self.think != func_modeltrain_find)
		return;		// already activated
	modeltrain_next();
};

void() modeltrain_wait =
{
	entity oself = self;
	self = self.enemy;
	SUB_UseTargets();
	self = oself;

	if (self.enemy.wait > 0)
	{
		self.nextthink = getLocalTime() + self.enemy.wait;
		self.think = modeltrain_next;
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else if (self.enemy.wait < 0) {
		self.nextthink = 0;
	}
	else {
		modeltrain_next();
		//self.nextthink = getLocalTime() + 0.1;
	}

	

};

void() modeltrain_next =
{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	if (!self.target)
		objerror ("train_next: no next target");
	if (targ.wait)
		self.wait = targ.wait;
	else
		self.wait = 0;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);

	self.enemy = targ;
	SUB_CalcMove (targ.origin, self.speed, modeltrain_wait);
	
	self.angles = vectoangles(targ.origin - self.origin);
};

void() func_modeltrain_find =

{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	setorigin (self, targ.origin);
	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = self.ltime + 0.1;
		self.think = modeltrain_next;
	}
};

void() func_modeltrain =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");
	if (!self.dmg)
		self.dmg = 2;

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NOCLIP;
	self.use = modeltrain_use;
	self.classname = "modeltrain";
	
	precache_model(self.model);
	setmodel (self, self.model);
	setsize (self, '-16 -16 0', '16 16 56');
	setorigin (self, self.origin);

	
// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = getLocalTime() + 0.1;
	self.think = func_modeltrain_find;
};