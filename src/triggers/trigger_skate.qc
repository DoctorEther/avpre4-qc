.float skate;

void() skate_touch = {
	if(other.classname != "player") return;
	if(self.skate == other.av_skating) return;
	
	local entity tmp = self;
	self = other;
	AV_SwitchCam();
	self = tmp;
};

void() trigger_skate = {
	InitTrigger ();
    self.touch = skate_touch;
};