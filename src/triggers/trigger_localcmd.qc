.string command;

void() trigger_localcmd_use = {
	localcmd(self.command);
	localcmd("\n");
}

void() trigger_localcmd = {
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	
	setmodel(self, "");
	
	self.use = trigger_localcmd_use;
}