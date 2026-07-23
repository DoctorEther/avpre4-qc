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
