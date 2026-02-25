.float tracknum;
.string soundorigin;
.string soundsubtitle;

void() music_use =
{
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, self.tracknum); // CD start track
	WriteByte (MSG_ALL, self.tracknum); // CD end track
};

void() trigger_cdtrack =
{
	if (!self.tracknum){ sprint(self, "trigger_cdtrack(): 'tracknum' is not set.\n"); return; }
	
	InitTrigger();
	self.use = music_use;
};

void() soundplayer_use =
{
	sound(activator, MOVETYPE_FLY, self.soundorigin, TRUE, FALSE);
	if (self.soundsubtitle)
	{
		centerprint(activator, self.soundsubtitle);
	}
};

void() trigger_soundplayer =
{
	InitTrigger();
	precache_sound(self.soundorigin);
	self.use = soundplayer_use;
};
