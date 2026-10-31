// --- SKATE UTIL -------------------------------------

string(...) strcat = #115;

vector(float x, float y, float z) vec3 = {
	local vector v;
	v_x = x;
	v_y = y;
	v_z = z;
	
	return v;
};

.float skate_hspeed, skate_hspeed_time, skate_grind_touch_time;
.float skate_kick_time;
.float skate_push;
