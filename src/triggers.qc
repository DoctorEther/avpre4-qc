/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/




void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};


//=============================================================================

void() SUB_EndWaiting = {
	self.is_waiting = 0;
	self.estate = STATE_ACTIVE;
	if (self.use == SUB_EndWaiting) self.use = self.dormant_use;

	// special case for teleports, makes it ignore the fact that it has a targetname when touched
	if (self.classname == "trigger_teleport") {
		self.is_waiting = -1;
	}
};

void() SUB_CheckWaiting = {
	if (self.is_waiting > 0) {
		self.dormant_use = self.use;
		self.use = SUB_EndWaiting;
		self.estate = STATE_INACTIVE;

	}
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);

		msg_entity = self.enemy;
		WriteByte (MSG_ONE, SVC_ACHIEVEMENT);
		WriteString(MSG_ONE, "ACH_FIND_SECRET");
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_killed =
{
	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use =
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;

	if (other.classname != "player")
		return;
	
// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple =
{
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}

	SUB_CheckWaiting();
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = SUB_UseTargets;
};


//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
	if (!self.message)
		self.message = "$qc_found_secret";
	if (!self.sounds)
		self.sounds = 1;
	
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}

	trigger_multiple ();
};

//=============================================================================


void() counter_use =
{

	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (self.count != 0)
	{
		if (activator.classname == "player"
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "$qc_more_go");
			else if (self.count == 3)
				centerprint (activator, "$qc_three_more");
			else if (self.count == 2)
				centerprint (activator, "$qc_two_more");
			else
				centerprint (activator, "$qc_one_more");
		}
		return;
	}
	
	if (activator.classname == "player"
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "$qc_sequence_completed");
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

void() trigger_skill_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;
	if (other.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	InitTrigger ();
	self.touch = trigger_skill_touch;

	SUB_CheckWaiting();
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != "")
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}

	SUB_CheckWaiting();
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;
};

//============================================================================


void() hurt_retouch = {
	force_retouch = 2;
}

void() hurt_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;

	if (time < other.hurt_started + self.wait)
		return;

	if (other.takedamage) {
		T_Damage (other, self, self, self.dmg, DMGTYPE_GENERIC);
		other.hurt_started = time;
	}

	if (other.flags & FL_CLIENT && other.flags && other.movetype == MOVETYPE_NOCLIP)
		return;

	// From Copper:
	// this is not ideal but all the other solutions are also not ideal: monsters
	// who stand still in a trigger hurt don't catch the trigger, so (for example)
	// enforcers who plant and open fire will be immune to the hurt as long as they
	// stay in one place
	if (other.flags & FL_MONSTER && other.health > 0) {
		// so we have to ask the engine to spam a collision test of everything vs
		// everything else to catch them
		self.think = hurt_retouch;
		self.nextthink = time + self.wait;
	}
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;
	if (!self.wait)
		self.wait = 1;

	SUB_CheckWaiting();
};

//============================================================================

float PUSH_ONCE = 	1;
float PUSH_TOGL = 	2;
float PUSH_ACTIVE =	4;

void() trigger_push_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;
	if (!(self.spawnflags & PUSH_ACTIVE))
		return;
		
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.classname == "MiniGrenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.classname == "MultiGrenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player")
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				sound (other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};

void() trigger_push_use = 
{
	if (self.spawnflags & PUSH_ACTIVE)
		self.spawnflags = self.spawnflags - PUSH_ACTIVE;
	else
		self.spawnflags = self.spawnflags + PUSH_ACTIVE;
};

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE PUSH_TOGL PUSH_ACTIVE
Pushes the player.

speed: velocity of push. (default 1000)
*/
void() trigger_push =
{
	if (self.spawnflags & PUSH_TOGL)
		self.use = trigger_push_use;
	else
		self.spawnflags = self.spawnflags + PUSH_ACTIVE;

	InitTrigger ();
	precache_sound ("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	if (!self.speed)
		self.speed = 1000;

	SUB_CheckWaiting();
};

//============================================================================

void() trigger_monsterjump_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;
	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

	// classname filter
	if (self.message != "" && self.message != other.classname)
		return;

// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;

	SUB_CheckWaiting();
};




/*
=============================================================

trigger_textstory

=============================================================
*/
float TEXTSTORY_SILENT = 1;
float TEXTSTORY_NOFADE = 2;

void(entity controller) textstory_hide = {
	if (!self.enemy || !(self.enemy.flags & FL_CLIENT)) return;

	//self.enemy.suppressCenterPrint = FALSE;
	centerprint(self.enemy, "");

	if (controller.noise2 != "") 
		sound(self.enemy, CHAN_BODY, controller.noise2, 1, ATTN_NORM);
	
	//if (!(controller.spawnflags & TEXTSTORY_NOFADE))
	//	csf_fade_clear(self.enemy, 0.5, 110);
};

void(entity controller) textstory_show = {
	if (!self.enemy || !(self.enemy.flags & FL_CLIENT)) return;

	//self.enemy.suppressCenterPrint = TRUE;
	string msg;

	//if (controller.mapvar && read_mapvar(controller.mapvar)){
	//	msg = controller.message2;
	//}
	//else {
		msg = controller.message;
	//}

	centerprint(self.enemy, msg);

	if (!self.state) {
		if (controller.noise1 != "")
			sound(self.enemy, CHAN_BODY, controller.noise1, 1, ATTN_NORM);

		//if (!(controller.spawnflags & TEXTSTORY_NOFADE))
		//	csf_fade(self.enemy, 160, '0 0 0', 1, 110);
	}


	self.state = 1;
};

//----------------------------------------

void() trigger_textstory_hide = {
	textstory_hide(self);

	self.pain_finished = 0;
	self.enemy = world;
	self.state = 0;
};

void() trigger_textstory_show = {
	textstory_show(self);	

	if (time > self.pain_finished)
		self.think = trigger_textstory_hide;
	else
		self.think = trigger_textstory_show;
	self.nextthink = time + 0.2;

};

void() trigger_textstory_touch = {
	
	if (!(other.flags & FL_CLIENT)) return;
	if (self.estate != STATE_ACTIVE) return;

	// don't show message if another player is already triggering it
	if (other != self.enemy && self.state == 1) return;

	if (self.mangle && !isInAngle(other.v_angle, self.mangle, self.view_ofs))
		return;

	if (!self.pain_finished) {
		self.pain_finished = time + self.wait;
	}

	if (self.attack_finished < time) {

		self.attack_finished = time + 0.1;
		self.enemy = other;

		trigger_textstory_show();
	}
};

void() trigger_textstory = {
	//if (!SUB_InitEntity()) return;
	
	InitTrigger();
	self.touch = trigger_textstory_touch;

	if (self.view_ofs == '0 0 0')
		self.view_ofs = '90 90 0';

	if (self.noise1 == "")
		self.noise1 = "misc/talk.wav";

	if (self.noise2 == "")
		self.noise2 = "misc/null.wav";

	if (self.spawnflags & TEXTSTORY_SILENT) {
		self.noise1 = string_null;
		self.noise2 = string_null;
	}

	if (!self.wait) self.wait = 2;
	
	if (self.noise1 != "")
		precache_sound (self.noise1);
	if (self.noise2 != "")
		precache_sound (self.noise2);

	SUB_CheckWaiting();
};
