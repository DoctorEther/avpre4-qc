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
.vector skate_wish_dir, skate_hdir;

.entity skate_upper;
.float skate_upper_twist, skate_upper_lock;

float(float a) skate_sin = #60;
float(float a) skate_cos = #61;
float(float a) skate_sqrt = #62;
float(float y, float x) skate_atan2 = #474;
string(entity e, string key) skate_infokey = #80;
