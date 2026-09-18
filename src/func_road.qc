void() road_update = {
	//self.origin_x = self.origin_x + self.scrollspeed;
	
	if(self.origin_x < self.returnpos) setorigin(self, [self.origin_x - self.returnpos, self.origin_y, self.origin_z]);
	
	self.nextthink = time + 0.0001;
};

void() func_road = {
	self.movetype = MOVETYPE_FLY;
	self.solid = SOLID_NOT;
	
	precache_model(self.model);
	setmodel(self, self.model);
	
	//setsize(self, '0 0 0', '0 0 0');
	
	self.think = road_update;
	self.nextthink = time + 0.0001;
	self.velocity_x = 72 * self.scrollspeed;
}