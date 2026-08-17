
/*
=============================================================

target_setstate

=============================================================
*/
float SETSTATE_CLOSEALLDOORS = 2;
float SETSTATE_DONTRESETBUTTON = 4;

float SETSTATE_TOGGLE_ACTIVE = 0;
float SETSTATE_FORCE_ACTIVE = 1;
float SETSTATE_FORCE_INACTIVE = 2;
float SETSTATE_TOGGLE_VISIBLE = 3;
float SETSTATE_FORCE_INVISIBLE = 4;

float(entity e) entity_get_state = {
	if (e.classname == "func_door") return e.owner.estate;
	else return e.estate;
};

void(entity e) entity_set_state_hide = {

	if (e.classname == "func_door") {
		entity master = e.owner;
		e = master;
		do {
			e.estate_orig_solid = e.solid;
			e.estate_orig_move = e.movetype;
			e.estate_orig_mdlindex = e.modelindex;

			e.modelindex = 0;
			e.solid = SOLID_NOT;
			if (e.movetype == SOLID_BSP) e.movetype = MOVETYPE_NONE;
			setorigin(e, e.origin); // relink

			e = e.enemy;
		} while (e != master && e != world);

		return;
	}

	e.estate_orig_solid = e.solid;
	e.estate_orig_move = e.movetype;
	e.estate_orig_mdlindex = e.modelindex;

	e.modelindex = 0;
	e.solid = SOLID_NOT;
	if (e.movetype == SOLID_BSP) e.movetype = MOVETYPE_NONE;
	setorigin(e, e.origin); // relink
}

void(entity e) entity_set_state_unhide = {
	if (e.classname == "func_door") {
		entity master = e.owner;
		e = master;
		do {
			e.modelindex = e.estate_orig_mdlindex;
			e.solid = e.estate_orig_solid;
			e.movetype = e.estate_orig_move;
			setorigin(e, e.origin); // relink

			e = e.enemy;
		} while (e != master && e != world);

		return;
	}

	e.modelindex = e.estate_orig_mdlindex;
	e.solid = e.estate_orig_solid;
	e.movetype = e.estate_orig_move;
	setorigin(e, e.origin); // relink
}

void(entity e, float state, float flags) entity_set_state = {
	
	if (e.th_setstate){
		entity oself = self;
		self = e;
		self.th_setstate(state, flags);
		self = oself;
	}
	else {
		e.estate = state;
	}

	if (e.is_waiting > 0 && state == STATE_ACTIVE) {
		SUB_CallAsSelf(SUB_EndWaiting, e);
	}

	//if (e.touch && e.touch != SUB_Null) {
	//	force_retouch = 2;
	//}
};

void(string matchstring, .string matchfield, float action, float flags) target_setstate_set_target = {
	local entity t;

	t = find(world, matchfield, matchstring);
	while (t != world) {
		if (!(t.classname == "func_door" && t.owner != t)) {

			/*
			toggle active:
			invisible -> active
			active -> inactive
			inactive -> active

			toggle visible:
			invisible -> active
			active -> invisible
			inactive -> invisible
			*/
			float currentstate = entity_get_state(t);

			if (action == SETSTATE_TOGGLE_ACTIVE) {
				
				if (currentstate == STATE_INVISIBLE) {
					entity_set_state_unhide(t);
					entity_set_state(t, STATE_ACTIVE, flags);
				}
				else if (currentstate == STATE_ACTIVE) {
					entity_set_state(t, STATE_INACTIVE, flags);
				}
				else {
					entity_set_state(t, STATE_ACTIVE, flags);
				}
			}
			
			if (action == SETSTATE_FORCE_ACTIVE) {
				if (currentstate == STATE_INVISIBLE)
					entity_set_state_unhide(t);

				entity_set_state(t, STATE_ACTIVE, flags);
			}

			if (action == SETSTATE_FORCE_INACTIVE) {
				if (currentstate == STATE_INVISIBLE)
					entity_set_state_unhide(t);

				entity_set_state(t, STATE_INACTIVE, flags);
			}

			if (action == SETSTATE_TOGGLE_VISIBLE) {
				if (currentstate == STATE_INVISIBLE) {
					entity_set_state_unhide(t);
					entity_set_state(t, STATE_ACTIVE, flags);
				}
				else if (currentstate == STATE_ACTIVE || currentstate == STATE_INACTIVE) {
					entity_set_state_hide(t);
					entity_set_state(t, STATE_INVISIBLE, flags);
				}

			}

			if (action == SETSTATE_FORCE_INVISIBLE) {
				if (currentstate != STATE_INVISIBLE)
					entity_set_state_hide(t);

				entity_set_state(t, STATE_INVISIBLE, flags);
			}

		}
		t = find(t, matchfield, matchstring);
	}
};

void(float action) target_setstate_set_alltargets = {
	if (self.target && self.target != "") {
		target_setstate_set_target(self.target, targetname, action, self.spawnflags);
		target_setstate_set_target(self.target, targetname2, action, self.spawnflags);
	}
	if (self.target2 && self.target2 != "") {
		target_setstate_set_target(self.target2, targetname, action, self.spawnflags);
		target_setstate_set_target(self.target2, targetname2, action, self.spawnflags);
	}
	if (self.target3 && self.target3 != "") {
		target_setstate_set_target(self.target3, targetname, action, self.spawnflags);
		target_setstate_set_target(self.target3, targetname2, action, self.spawnflags);
	}
	if (self.target4 && self.target4 != "") {
		target_setstate_set_target(self.target4, targetname, action, self.spawnflags);
		target_setstate_set_target(self.target4, targetname2, action, self.spawnflags);
	}
};

inline void() target_setstate_use = {
	target_setstate_set_alltargets(self.style);
};

void() target_setstate_startoff_think = {
	//if (door_setup_finished) {
		if (self.style == 3 || self.style == 4) target_setstate_set_alltargets(SETSTATE_FORCE_INVISIBLE);
		else target_setstate_set_alltargets(SETSTATE_FORCE_INACTIVE);
	//}
	//else { // not finished yet? wait a bit longer
	//	self.think = target_setstate_startoff_think;
	//	self.nextthink = time + 0.1;
	//}
};

void() target_setstate = {
	//if (!SUB_InitEntity()) return;
	
	self.use = target_setstate_use;

	if (self.spawnflags & START_OFF) {
		// wait a bit while doors finish being set up
		self.think = target_setstate_startoff_think;
		self.nextthink = time + 0.5;
	}
};
