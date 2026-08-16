.entity		feijao_manager;

void(entity e) feijao_manager_spawn = {
	if (e.feijao_manager.classname == "feijao_manager")
		return;

	entity mgr = spawn();
	mgr.classname = "feijao_manager";
	mgr.owner = e;

	setmodel(mgr, "progs/feijao_overlay_large.mdl");
	setsize(mgr, '0 0 0', '0 0 0');
	
	if (e.size_x > 32)
		mgr.scale = 1;
	else
		mgr.scale = 0.7;
	//	setmodel(mgr, "progs/feijao_overlay_small.mdl");
	mgr.movetype = MOVETYPE_NOCLIP;
	setsize(mgr, '0 0 0', '0 0 0');
	setorigin(mgr, e.origin);
	mgr.cnt = random() * 180;
	mgr.angles = e.angles;
	mgr.angles_y += mgr.cnt;
	e.feijao_manager = mgr;
	mgr.think = feijao_manager_think;
	mgr.nextthink = time + 0.0001;
}

void(entity e) feijao_manager_remove = {
	if (e.feijao_manager.classname != "feijao_manager")
		return;

	remove (e.feijao_manager);
	e.feijao_manager = world;
}

void() feijao_manager_explode =
{
	entity tgt = self.owner;
		
	/*if (tgt.health <= 0){	
		feijao_manager_remove(self.owner);
		return;
	}*/
	setorigin(self, self.owner.origin);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	float damage = min(self.count, 20) * 9;
	float range_mult = max(1, 60/damage); // mininum 60units range

	T_RadiusDamage (self, self.enemy, damage, range_mult, DMGTYPE_EXPLOSION, 0);

	tgt.effects = 0;
	
	feijao_manager_remove(self.owner);
}

void() feijao_manager_think = {
	if (self.owner.health <= 0) {
		setmodel(self, "");
		setsize(self, '0 0 0', '0 0 0');
	}

	if (time > self.attack_finished) {
		feijao_manager_explode();
		return;
	}
	self.frame = min(self.count, 11);
	setorigin(self, self.owner.origin);
	self.angles = self.owner.angles;
	self.angles_y += self.cnt;
	self.nextthink = time + 0.0001;
}

float AV_FEIJAO_TIME = 0.5;

void() feijao_touch = {
	
	if (other.solid == SOLID_TRIGGER) return;

	if (pointcontents(self.origin) == CONTENT_SKY || !other.takedamage) {
		remove(self);
		return; 
	}
	
	spawn_touchblood (9);
	T_Damage (other, self, self.owner, 4, DMGTYPE_BALLISTIC);
	
	// don't stick to shootable buttons, doors etc
	if (other.takedamage != DAMAGE_AIM) {
		remove(self);
		return;
	}

	feijao_manager_spawn(other); // spawns controller if doesn't exist
	other.feijao_manager.enemy = self.owner;
	if (other.feijao_manager.count < 30) {
		other.feijao_manager.count++;
		other.feijao_manager.attack_finished = time + AV_FEIJAO_TIME;
	}
	else
		other.feijao_manager.attack_finished = time + 0.001;
			
	
	other.effects = EF_DIMLIGHT;
	
	remove(self);
};

void(vector org, vector dir) feijao_launch = {
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	//newmis.effects = EF_DIMLIGHT;
	
	newmis.touch = feijao_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireFeijao = {
	local vector	dir;
	
	sound (self, CHAN_WEAPON, "weapons/feijoada.wav", 1, ATTN_NORM);

	self.currentammo = self.ammo_lava_nails = self.ammo_lava_nails - 1;
	UpdateAmmoCounts(self);

	dir = aim (self, 1024);
	feijao_launch (self.origin + '0 0 16', dir);
	newmis.touch = feijao_touch;
	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	self.punchangle_x = -2;
}
