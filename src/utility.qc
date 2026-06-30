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