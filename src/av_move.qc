// Declaring it here so we can use normal jump here.
void() PlayerJump;

// --- AVIÃOZINHO PLAYER FIELDS ---------------------

.float		jump_count;

.float		dash_duration;
.float		dash_cooldown;
.float		dash_count;

// FLAG
float	FL_DASHING				= 262144;	// DASHING;


// --- MATH -----------------------------------------

vector() MovementVector =
{
	//Keyboard axis.
	local vector wish = self.movement;
	if(wish_x > 0) wish_x =  1;
	if(wish_x < 0) wish_x = -1;
	if(wish_y > 0) wish_y =  1;
	if(wish_y < 0) wish_y = -1;
	wish = normalize(wish);
	
	if(wish_x == 0 && wish_y == 0) wish_x = 1;
	
	//Looking direction.
	makevectors(self.angles);
	local vector dir = v_forward;
	dir_z = 0;
	dir = normalize(dir);
	
	//Rotated axis.
	local vector mov;
	mov_x = wish_x * dir_x + wish_y * dir_y;
	mov_y = wish_x * dir_y - wish_y * dir_x;

	return mov;
}

void(float speed) PushPlayer =
{
	local vector v = self.velocity;
	v_z = 0;
	
	local vector mov = MovementVector();
	
	local float vel = vlen(v);
	if(vel < speed){
		self.velocity_x = mov_x * speed;
		self.velocity_y = mov_y * speed;
	}else{
		self.velocity_x = mov_x * vel;
		self.velocity_y = mov_y * vel;
	}
}

// --- JUMP -----------------------------------------

void() PlayerDoubleJump = {
	if(self.jump_count == 0 && (self.flags & FL_ONGROUND)){
		PlayerJump();
		return;
	}
	
	if(self.waterlevel >= 2)								return; //Can't double jump in water.
	if(!(self.flags & FL_ONGROUND) && self.jump_count >= 2)	return; // Already jumped twice.
	if(!(self.flags & FL_JUMPRELEASED))						return; // don't pogo stick
	
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	
	if(self.jump_count == 0 && !(self.flags & FL_ONGROUND)) self.jump_count = 1; // Double jump if in air, but has not jumped before.
	
	self.jump_count = self.jump_count + 1;
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	sound(self, CHAN_AUTO, "weapons/r_exp3.wav", 1, ATTN_NORM);
	
	if(vlen(self.movement) > 0) PushPlayer(460);
	self.velocity_z = 380;
};

// --- DASH -----------------------------------------

float AV_DASH_SPEED		= 650.0;
float AV_DASH_DURATION	= 0.2;
float AV_DASH_COOLDOWN	= 1.25;

void() PlayerDash =
{
	if(self.dash_count >= 3) return; //Is dash available?
	
	if(!(self.flags & FL_DASHING)) self.flags = self.flags + FL_DASHING;
	
	self.dash_duration = time + AV_DASH_DURATION;
	self.dash_cooldown = time + AV_DASH_COOLDOWN;
	self.dash_count = self.dash_count + 1;
	
	PushPlayer(AV_DASH_SPEED);
	
	if(self.velocity_z <= 0){
		self.velocity_z = 128;
		
		if(self.flags & FL_ONGROUND){
			self.jump_count = self.jump_count + 1;
			self.flags = self.flags - FL_ONGROUND;
		}
	}
	
	local vector mov = MovementVector();
	mov_x = -mov_x;
	mov_y = -mov_y;
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z - 8);
	
	sound(self, CHAN_AUTO, "weapons/r_exp3.wav", 0.5, ATTN_NORM);
	particle(self.origin + '0 0 8', mov, 0, 10);
}
