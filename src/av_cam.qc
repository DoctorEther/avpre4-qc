.entity	av_camera;
.float	av_camera_active;

float AV_CAMERA_DIST = 64;
float AV_CAMERA_PADDING = 12;

void() AV_InitCam = {
	if (!self.av_camera) {
		self.av_camera = spawn();
		self.av_camera.classname = "av_camera";

	}

	msg_entity = self;
	WriteByte (MSG_ONE, 5);
	WriteEntity (MSG_ONE, self);
}

void() AV_CamUpdate = {
	if (!self.av_camera_active) return;

	if (!self.av_camera || self.av_camera.movetype == MOVETYPE_NONE)
		AV_CameraOn();
	
	/*msg_entity = self;
	WriteByte(MSG_ONE, 5);
	WriteEntity(MSG_ONE, self.av_camera);
	*/

	self.weaponmodel = "";
	
	vector view_org, view_end;
	makevectors(self.v_angle);
	view_org = self.origin + '0 0 32';
	view_end = view_org + (v_forward * - (AV_CAMERA_DIST + AV_CAMERA_PADDING));
	
	vector padding_dir = normalize(view_org - view_end);
	
	traceline(view_org, view_end, TRUE, self);
	if(trace_fraction < 1.0)
		view_end = trace_endpos + padding_dir * AV_CAMERA_PADDING;
	else
		view_end = view_end + padding_dir * AV_CAMERA_PADDING;
	
	setorigin(self.av_camera, view_end);
};

void() AV_CameraOn = {
	if (!self.av_camera) AV_InitCam();
	self.av_camera_active = TRUE;

	self.av_camera.solid = SOLID_NOT;
	self.av_camera.movetype = MOVETYPE_FLY;

	// camera entity needs to have a model otherwise it bugs out
	setmodel(self.av_camera, "progs/eyes.mdl");
	setsize(self.av_camera, '0 0 0', '0 0 0');
	
	msg_entity = self;
	WriteByte(MSG_ONE, 5);
	WriteEntity(MSG_ONE, self.av_camera);
	
	AV_CamUpdate();
}

void() AV_CameraOff = {
	if (!self.av_camera) AV_InitCam();
	self.av_camera_active = FALSE;

	self.av_camera.solid = SOLID_NOT;
	self.av_camera.movetype = MOVETYPE_NONE;
	
	setmodel(self.av_camera, "");
	setsize(self.av_camera, '0 0 0', '0 0 0');
	
	msg_entity = self;
	WriteByte (MSG_ONE, 5);
	WriteEntity (MSG_ONE, self);
	
	W_SetCurrentAmmo();

}

void() AV_SwitchCam = {
	self.av_camera_active = !self.av_camera_active;
	
	if (self.av_camera_active) AV_CameraOn();
	else AV_CameraOff();
};