void() finale_start =
{
	local entity e;
	local entity pos;

	if (intermission_running)
		return;

	intermission_running = 1;
	intermission_exittime = time + 10000000;

	pos = FindIntermission();

	for(e = world; (e = find(e, classname, "player"));)
	{
		e.view_ofs = '0 0 0';
		e.angles = e.v_angle = pos.mangle;
		e.fixangle = TRUE;
		e.takedamage = DAMAGE_NO;
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NONE;
		e.modelindex = 0;
		setorigin(e, pos.origin);
	}

	WriteByte(MSG_ALL, SVC_FINALE);
	WriteString(MSG_ALL, "");
};

void() trigger_finale_touch =
{
	if (other.classname != "player")
		return;

	finale_start();
};

void() trigger_finale =
{
	InitTrigger();
	self.touch = trigger_finale_touch;
	self.use = finale_start;
};
