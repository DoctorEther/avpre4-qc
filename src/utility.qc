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