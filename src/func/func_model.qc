.vector mdl_size;
float FUNC_MODEL_NOTSOLID = 1;

void() func_model = {
	precache_model(self.model);
	setmodel(self, self.model);
	
	vector smin, smax;
	smin_x = -self.mdl_size_x / 2;
	smin_y = -self.mdl_size_y / 2;
	smin_z = 0;
	smax_x = -smin_x;
	smax_y = -smin_y;
	smax_z = self.mdl_size_z;
	
	if (self.spawnflags & FUNC_MODEL_NOTSOLID)
		self.solid = SOLID_NOT;
	else
		self.solid = SOLID_SLIDEBOX;
			
		
	setsize(self, smin, smax);
}