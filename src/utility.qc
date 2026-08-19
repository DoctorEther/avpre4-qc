void(string s, string ss) dprint2 = 
	{ dprint(s); dprint(ss); }
void(string s, string ss, string sss) dprint3 = 
	{ dprint(s); dprint(ss); dprint(sss); }
void(string s, string ss, string sss, string ssss) dprint4 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); }
void(string s, string ss, string sss, string ssss, string sssss) dprint5 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); dprint(sssss); }
void(string s, string ss, string sss, string ssss, string sssss, string ssssss) dprint6 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); dprint(sssss); dprint(ssssss);}
void(string s, string ss, string sss, string ssss, string sssss, string ssssss, string sssssss) dprint7 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); dprint(sssss); dprint(ssssss); dprint(sssssss);}
void(string s, string ss, string sss, string ssss, string sssss, string ssssss, string sssssss, string ssssssss) dprint8 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); dprint(sssss); dprint(ssssss); dprint(sssssss); dprint(ssssssss); }
void(string s, string ss, string sss, string ssss, string sssss, string ssssss, string sssssss, string ssssssss, string sssssssss) dprint9 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); dprint(sssss); dprint(ssssss); dprint(sssssss); dprint(ssssssss); dprint(sssssssss); }

/*
=============
SUB_CallAsSelf

wrap the self/oself shuffle for code cleanliness elsewhere
===============
*/
void(void() fun, entity newself) SUB_CallAsSelf =
{
	local entity oself;
	
	oself = self;
	self = newself;
	fun();
	self = oself;	
}


entity(vector org, .string fld, string match, float aliveonly) findClosest = {
	entity closest, next;
	float closestdist, nextdist;

	closestdist = 99999999;
	
	next = find(world, fld, match);	
	while (next) {
		if ((aliveonly && next.health > 0) || !aliveonly) {
			nextdist = vlen(next.origin - org);
			if (nextdist < closestdist) {
				closestdist = nextdist;
				closest = next;
			}
		}
		next = find(next, fld, match);
	}
	return closest;
};

/*
Gets the correct time value depending on entity movetype. MOVETYPE_PUSH ents needs to use
'self.ltime' instead of simply 'time' for setting thinks
*/
float() getLocalTime = {
	if (self.movetype == MOVETYPE_PUSH) return self.ltime;
	else return time;
}

float(entity e) getEntityTime = {
	if (e.movetype == MOVETYPE_PUSH) return e.ltime;
	else return time;
}


float (entity e1, entity e2) SolidsTouching =
{
	if (e1.mins_x > e2.maxs_x) {
		return FALSE;
	}
	if (e1.mins_y > e2.maxs_y){
		return FALSE;
	}
	if (e1.mins_z > e2.maxs_z){
		return FALSE;
	}
	if (e1.maxs_x < e2.mins_x){
		return FALSE;
	}
	if (e1.maxs_y < e2.mins_y){
		return FALSE;
	}
	if (e1.maxs_z < e2.mins_z){
		return FALSE;
	}

	return TRUE;
};

void(entity ent, string mdl) changeModel =
{
	local vector sz,smin,smax;
	sz = ent.size;
	smin = ent.mins;
	smax = ent.maxs;
	
	setmodel(ent, mdl);
	
	if (sz == VEC_ORIGIN)
		setsize(ent, VEC_ORIGIN, VEC_ORIGIN);
	else
		setsize(ent, smin, smax);
}

float(float a, float b) min = { if (a <= b) return a; return b; }
float(float a, float b) max = { if (a >= b) return a; return b; }


/*
 * clamp
 *
 * Limits the given value to the given range.
 *
 * value: A number
 *
 * minValue: The minimum value of the range
 *
 * maxValue: The maximum value of the range
 *
 * Returns: A number within the given range.
 */
float(float value, float minValue, float maxValue) clamp = {
	if (value > maxValue) {
		return maxValue;
	}
	else if (value < minValue) {
		return minValue;
	}

	return value;
};

float(float a) saturate = { return clamp(a, 0, 1); }

vector(vector a, vector b) cross_product = {
	vector ret;
	ret_x = a_y*b_z - a_z*b_y;
	ret_y = a_z*b_x - a_x*b_z;
	ret_z = a_x*b_y - a_y*b_x;
	return ret;
}


vector(float num) SinCos =
{
	local vector angle, vf, vu, vr, result;

	vf = v_forward;
	vu = v_up;
	vr = v_right;

	angle = '0 1 0' * num;
	makevectors(angle);
	result = [v_forward_y, v_forward_x, v_forward_y / v_forward_x];   // technically SinCosTan

	v_forward = vf;
	v_up = vu;
	v_right = vr;

	return result;
}

float(float num) sin =
{
	vector temp;
	temp = SinCos(num);
	return temp_x;
}

float(float num) cos =
{
	vector temp;
	temp = SinCos(num);
	return temp_y;
}

float(float num) tan =
{
	vector temp;
	temp = SinCos(num);
	return temp_x / temp_y;
}
 

// rotates B around A
vector(vector b, vector a, float r) rotateVectorAround =
{
	float sin, cos, dot;
	vector cross, temp;
	
	cross = cross_product(a, b);
	dot = a*b;
	
	temp = SinCos(r);
	sin = temp_x;
	cos = temp_y;
	
	return b*cos + cross*sin + a*dot*(1-cos);
}

void(float val) nxth = {self.nextthink = getLocalTime() + val;}



// high precision vectoyaw/atan2
// (bxy + y^2) / (x^2 + 2bxy + y^2)
// b = 0.596227
float(vector vec) vectoyaw2 = {
    float b = 0.596227;

    // Extract the sign bits
    float ux_s  =  vec_x < 0 ? -1 : 1;
    float uy_s  =  vec_y < 0 ? -1 : 1;

    // Determine the quadrant offset
    float q;
    if (ux_s >= 0 && uy_s >= 0) q = 0;
    else if (ux_s < 0 && uy_s >= 0) q = 1;
    else if (ux_s < 0 && uy_s < 0) q = 2;
    else q = 3;

    // Calculate the arctangent in the first quadrant
    float bxy_a = fabs( b * vec_x * vec_y );
    float num = bxy_a + vec_y * vec_y;
    float atan_1q =  num / ( vec_x * vec_x + bxy_a + num );

    // Translate it to the proper quadrant
    float uatan_2q = ux_s < 0 ? 1 - atan_1q : atan_1q;
    if (q >= 2) uatan_2q = 1 - uatan_2q;
    return (q + uatan_2q) * 90;
}

// high precision vectoangles
vector(vector vec) vectoangles2 = {
	float yaw, forward, pitch;
	
	if (vec_x == 0 && vec_y == 0)
	{
		yaw = 0;
		if (vec_z > 0) pitch = 90;
		else pitch = 270;
	}
	else {
		yaw = vectoyaw2(vec);
		forward = vlen([vec_x, vec_y, 0]);
		pitch = vectoyaw2([forward, vec_z, 0]);
	}
	return [pitch, yaw, 0];
}



// normalizes an angle vector to the 0/+359 range
vector(vector ang) normalizeAngles = {
	ang_x = ang_x - floor(ang_x/360) * 360;
	ang_y = ang_y - floor(ang_y/360) * 360;
	ang_z = ang_z - floor(ang_z/360) * 360;

	return ang;
};

// normalizes an angle vector to the -180/+179 range
vector(vector ang) normalizeAngles180 = {
	ang_x = ang_x - floor((ang_x+180)/360) * 360;
	ang_y = ang_y - floor((ang_y+180)/360) * 360;
	ang_z = ang_z - floor((ang_z+180)/360) * 360;

	return ang;
};



//faster version of id's anglemod
float(float v) anglemod =
{
	return v - floor(v/360) * 360;
}

float(float v) anglemod180 =
{
	return v - floor((v+180)/360) * 360;
}

float(float anga, float angb) angledif =
{
	float dif;
	dif = fabs(anga - angb);
	if (dif > 180)
		dif = 360 - dif;
	return dif;
}

vector(vector anga, vector angb) anglesdif =
{
	vector dif;
	dif = anga - angb;
	if (dif_x > 180)
		dif_x = 360 - dif_x;
	if (dif_y > 180)
		dif_y = 360 - dif_y;
	if (dif_z > 180)
		dif_z = 360 - dif_z;
	return dif;
}

float(vector ang, vector base_ang, vector offset) isInAngle = {
	if (angledif(ang_x, anglemod180(base_ang_x)) > offset_x || angledif(ang_y, anglemod180(base_ang_y)) > offset_y)
		return FALSE;
	else
		return TRUE;
};