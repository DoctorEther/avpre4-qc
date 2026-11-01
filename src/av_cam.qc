.entity	av_camera;
.float	av_camera_active;

.float	av_camera_dist;
.float	pvsflags;

float AV_CAMERA_PVS_IGNORE = 3;

float AV_CAMERA_DIST = 64;
float AV_CAMERA_HEIGHT = 54;
float AV_CAMERA_CLEARANCE = 14;
float AV_CAMERA_RETURN = 6;

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
	
	traceline(self.origin, self.origin + '0 0 1' * AV_CAMERA_HEIGHT, TRUE, self);
	vector pivot = self.origin + '0 0 1' * AV_CAMERA_HEIGHT;
	if(trace_fraction < 1.0)
		pivot = self.origin + '0 0 1' * max(0, AV_CAMERA_HEIGHT * trace_fraction - AV_CAMERA_CLEARANCE);
	
	makevectors(self.v_angle);
	vector back = '0 0 0' - v_forward;
	
	traceline(pivot, pivot + back * AV_CAMERA_DIST, TRUE, self);
	float dist = AV_CAMERA_DIST * trace_fraction;
	if(trace_fraction < 1.0){
		float facing = fabs(back * trace_plane_normal);
		if(facing < 0.25) facing = 0.25;
		dist = max(0, dist - AV_CAMERA_CLEARANCE / facing);
	}
	
	if(dist < self.av_camera_dist) self.av_camera_dist = dist;
	else self.av_camera_dist = self.av_camera_dist + (dist - self.av_camera_dist) * min(1, frametime * AV_CAMERA_RETURN);
	
	vector cam = pivot + back * self.av_camera_dist;
	cam = AV_CameraClearance(cam, '1 0 0');
	cam = AV_CameraClearance(cam, '-1 0 0');
	cam = AV_CameraClearance(cam, '0 1 0');
	cam = AV_CameraClearance(cam, '0 -1 0');
	cam = AV_CameraClearance(cam, '0 0 1');
	cam = AV_CameraClearance(cam, '0 0 -1');
	
	traceline(pivot, cam, TRUE, self);
	if(trace_fraction < 1.0 || pointcontents(cam) == CONTENT_SOLID)
		cam = pivot + (cam - pivot) * max(0, trace_fraction - 0.1);
	if(pointcontents(cam) == CONTENT_SOLID)
		cam = pivot;
	
	setorigin(self.av_camera, cam);
};

vector(vector cam, vector axis) AV_CameraClearance = {
	traceline(cam, cam + axis * AV_CAMERA_CLEARANCE, TRUE, self);
	if(trace_fraction < 1.0 && !trace_startsolid)
		cam = cam - axis * (AV_CAMERA_CLEARANCE * (1 - trace_fraction));
	
	return cam;
};

void() AV_CameraOn = {
	if (!self.av_camera) AV_InitCam();
	self.av_camera_active = TRUE;
	self.av_camera_dist = AV_CAMERA_DIST;
	
	self.av_camera.solid = SOLID_NOT;
	self.av_camera.movetype = MOVETYPE_FLY;
	self.av_camera.pvsflags = AV_CAMERA_PVS_IGNORE;
	
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