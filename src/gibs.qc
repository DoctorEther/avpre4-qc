
void() GibThink = {
	self.alpha -= 0.015;
	if (self.alpha <= 0) {
		if (self.trigger_field.classname == "kick_touch_triggerfield") remove(self.trigger_field);
		SUB_Remove();
		return;
	}
	self.think = GibThink;
	self.nextthink = getLocalTime() + 0.05;
}

vector(float dm) GibVelocityForHealth =
{
	local vector v;
	local float	voom;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 75 + 150 * random();

	voom = max(1, min(10, dm * dm / 5000));
	
	return v * voom;
}

void(entity gib, string gibname) MakeGib =
{
	gib.lifetime_finished = time + 8 + random() * 8;
	gib.th_die = GibThink;
	gib.alpha = 1;
	
	changeModel(gib, gibname);
	gib.type = "gib";
	gib.avelocity = [random(),random(),random()] * 600;

	gib.flags = 0;
}


vector(entity emitter, float dm) GibVelocityFromInflictor = {
	if (!emitter.dmg_inflictor || emitter.dmg_inflictor == emitter)
		return '0 0 0'; 

	float pwr = clamp(dm * dm / 22, 10, 800);
	
	vector addvel = normalize(emitter.origin - emitter.inflictor_origin) * pwr;


	addvel_z *= 0.7;

	// explosions get a little more speed
	if (emitter.deathtype == DMGTYPE_EXPLOSION) {
		addvel_x *= 3;
		addvel_y *= 3;
	}
	else {
		addvel_x *= 2.2;
		addvel_y *= 2.2;
	}

	// Add a bit of velocity from the projectile itself.
	// For a more dramatic effect with high-speed and relatively
	// low damage projectiles that still may gib under quad,
	// like the SNG and the Plasma Gun.
	if (emitter.inflictor_movetype == MOVETYPE_FLYMISSILE && emitter.inflictor_vel != '0 0 0') {
		float projlinvel = vlen(emitter.inflictor_vel);
		addvel += emitter.inflictor_vel * min(projlinvel, 180)/projlinvel;
	}

	return addvel;
}

void(entity gib) capGibVelocity = {
	float linvel = vlen(gib.velocity);

	// limit linear speed
	if (linvel > 550) {
		gib.velocity *= 550 / linvel;
	}

	// cap Z speed so gibs won't go flying too crazily up in the air
	gib.velocity_z = min(500, gib.velocity_z);

}

entity(string gibname, float dm) ThrowGib =
{
	local entity gib;
	vector org;

	org = self.origin;
	
	//org_x = self.origin_x + crandom()*self.size_x/3;
	//org_y = self.origin_y + crandom()*self.size_y/3;
	//org_z = self.origin_z + crandom()*self.size_z/3;
	
	// gibs have to be thinking ballistic projectiles to pass through monsterclip/notrace :(
	
	gib = toss_projectile(org, GibVelocityForHealth(dm), "gib");
	gib.velocity += GibVelocityFromInflictor(self, dm);
	capGibVelocity(gib);

	MakeGib(gib, gibname);
	attachKickField(gib);
	return gib;

}

void(string gibname, float dm) ThrowHead =
{	setmodel (self, gibname);
	self.frame = 0;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_TRIGGER; //make them SOLID_TRIGGER so they can be caught by a trigger_void

	self.view_ofs = '0 0 8';
	self.type = "gib";
	
	self.origin_z = self.absmax_z + 16;
	setorigin(self, self.origin);
	setsize (self, '0 0 0', '0 0 0');
	
	//self.velocity += GibVelocityForHealth(max(dm, -99));
	self.velocity += GibVelocityForHealth(dm);
	self.velocity += GibVelocityFromInflictor(self, dm);
	capGibVelocity(self);

	attachKickField(self);
	
	self.flags &~= FL_ONGROUND;
	self.avelocity = crandom() * '0 600 0';
	self.think = SUB_Null;
}




/*
========
toss_projectile

base ballistic projectile, does not set model, touch, or damage
speed expected to derive from the length of 'vel'
========
*/
entity(vector org, vector vel, string cname) toss_projectile =
{
	entity g;
	g = spawn();
	g.owner = self;
	g.solid = SOLID_BBOX;
	g.movetype = MOVETYPE_BOUNCE;
	g.angles = vectoangles(vel);
	setsize (g, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (g, org);
	g.velocity = g.oldvelocity = vel;
	g.classname = cname;
	
	
	g.think = projectile_toss_think;
	g.nextthink = time;
	g.th_die = SUB_Remove;
	g.lifetime_finished = time + 6;
	//g.touch = projectile_touch_null;
	
	return g;
}

void() projectile_toss_think =
{
	if (time > self.lifetime_finished)
	{
		self.th_die();
		return;
	}
	if (self.velocity == VEC_ORIGIN)	// stopped on the ground
	{
		self.think = self.th_die;
		self.nextthink = self.lifetime_finished;
	//	bprint3("at rest, exploding in ", ftos(self.nextthink), " seconds\n");
		self.th_die = SUB_Null;
		self.lifetime_finished = 0;
		self.solid = SOLID_NOT;
		return;
	}
		
	self.flags &~= FL_ONGROUND;
	self.oldvelocity = self.velocity;
	self.nextthink = time + 0.05;	// 10hz is probably enough, but 20hz is surely twice as good
}

//**********************************************
// Kicking Gibs n Dead Heads
// Based on original code by Ivana Gibson
// Heavily modified by bmFbr
//**********************************************


void() kick_touch = 
{
	local vector v;

	// only a player can kick it
	if (other.classname != "player")
		return;
	
	self.enemy = other;
	//if(self.model == "progs/ball.mdl" && self.classname == "ball") bprint("GOOOOOOOL!!!\n");
	
	//randomize sound
	if (random()< 0.8)
		sound(other, CHAN_ITEM, "zombie/z_hit.wav", 1, ATTN_NORM);
	else
		sound(other, CHAN_ITEM, "zombie/z_miss.wav", 1, ATTN_NORM);

	//define velocity 
	//you can play with these formulas to adjust
	//trajectory
	v_x = other.velocity_x*2 + 50*random();
	v_y = other.velocity_y*2 + 50*random();
	v_z = 250 + 160*random() + (other.velocity_y + other.velocity_x)*0.30;

	self.avelocity_x = crandom()*300;
	self.avelocity_y = crandom()*300;
	self.avelocity_z = crandom()*300;

	self.flags &~= FL_ONGROUND;
	self.velocity = v;
};


void(entity e) attachKickField = {
	e.trigger_field = spawn();
	e.trigger_field.classname = "kick_touch_triggerfield";
	e.trigger_field.solid = SOLID_TRIGGER;
	e.trigger_field.movetype = MOVETYPE_NONE;
	e.trigger_field.owner = e;

	setorigin(e.trigger_field, e.origin);
	setsize(e.trigger_field, '-16 -16 -16','16 16 16');
	
	e.trigger_field.touch = kick_touch_triggerfield;
	e.trigger_field.think = kick_touch_triggerfield_think;
	e.trigger_field.nextthink = time + 0.0001;
}

void() kick_touch_triggerfield_think = {
	setorigin(self, self.owner.origin);

	if (self.owner.velocity == '0 0 0')
		self.nextthink = time + 0.1;
	else
		self.nextthink = time + 0.0001;

	self.think = kick_touch_triggerfield_think;
}

void() kick_touch_triggerfield = 
{
	local vector v;

	// only a player can kick it
	if (other.classname != "player")
		return;

	// don't make dead players kick themselves
	//if (other.health <= 0)
	//	return;
	
	self.enemy = other;
	self.owner.enemy = other;
	
	//randomize sound
	if (random()< 0.8)
		sound(other, 6, "zombie/z_hit.wav", 1, ATTN_NORM);
	else
		sound(other, 6, "zombie/z_miss.wav", 1, ATTN_NORM);

	//define velocity 
	//you can play with these formulas to adjust
	//trajectory
	v_x = other.velocity_x*2 + 50*random();
	v_y = other.velocity_y*2 + 50*random();
	v_z = 250 + 160*random() + (other.velocity_y + other.velocity_x)*0.30;

	float linvel = vlen(v);

	// limit linear speed
	if (linvel > 2000) {
		v *= 2000 / linvel;
	}

	self.owner.avelocity_x = crandom()*300;
	self.owner.avelocity_y = crandom()*300;
	self.owner.avelocity_z = crandom()*300;

	self.owner.flags &~= FL_ONGROUND;
	self.owner.velocity = v;

	self.nextthink = time + 0.0001;

};