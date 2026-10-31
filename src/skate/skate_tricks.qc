float AV_SKATE_FAST_FRAMETIME = 0.0272;

// --- KICKFLIP ---------------------------------------

void()	player_sk_flip1 =	[162, player_sk_flip2	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip2 =	[163, player_sk_flip3	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip3 =	[164, player_sk_flip4	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip4 =	[165, player_sk_flip5	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip5 =	[166, player_sk_flip6	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip6 =	[167, player_sk_flip7	] {
	self.nextthink = time + AV_SKATE_FAST_FRAMETIME;
	
	if(self.skate_flags & SKFL_TRICK){
		self.skate_flags = self.skate_flags - SKFL_TRICK;
		AV_SkateAddTrick("$qc_sk_kickflip", 200);
	}
};
void()	player_sk_flip7 =	[168, player_sk_flip8	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip8 =	[169, player_sk_flip9	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip9 =	[170, player_sk_flip10	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip10 =	[171, player_sk_flip11	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip11 =	[172, player_sk_flip12	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip12 =	[173, player_run		] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };

// --- 360 --------------------------------------------

void()	player_sk_spin1 =	[174, player_sk_spin2	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin2 =	[175, player_sk_spin3	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin3 =	[176, player_sk_spin4	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin4 =	[177, player_sk_spin5	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin5 =	[178, player_sk_spin6	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin6 =	[179, player_sk_spin7	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin7 =	[180, player_sk_spin8	] {
	self.nextthink = time + AV_SKATE_FAST_FRAMETIME;
	
	if(self.skate_flags & SKFL_TRICK){
		self.skate_flags = self.skate_flags - SKFL_TRICK;
		AV_SkateAddTrick("$qc_sk_spin", 500);
	}
};
void()	player_sk_spin8 =	[181, player_sk_spin9	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin9 =	[182, player_sk_spin10	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin10 =	[183, player_sk_spin11	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin11 =	[184, player_sk_spin12	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin12 =	[185, player_sk_spin13	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin13 =	[186, player_sk_spin14	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin14 =	[187, player_run		] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };

// --- BACKFLIP ---------------------------------------

void()	player_sk_bflip1 =	[188, player_sk_bflip2	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip2 =	[189, player_sk_bflip3	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip3 =	[190, player_sk_bflip4	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip4 =	[191, player_sk_bflip5	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip5 =	[192, player_sk_bflip6	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip6 =	[193, player_sk_bflip7	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip7 =	[194, player_sk_bflip8	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip8 =	[195, player_sk_bflip9	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip9 =	[196, player_sk_bflip10	] {
	self.nextthink = time + AV_SKATE_FAST_FRAMETIME;
	
	if(self.skate_flags & SKFL_TRICK){
		self.skate_flags = self.skate_flags - SKFL_TRICK;
		AV_SkateAddTrick("$qc_sk_backflip", 800);
	}
};
void()	player_sk_bflip10 =	[197, player_sk_bflip11	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip11 =	[198, player_sk_bflip12	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip12 =	[199, player_sk_bflip13	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip13 =	[200, player_sk_bflip14	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip14 =	[201, player_sk_bflip15	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip15 =	[202, player_sk_bflip16	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip16 =	[203, player_run		] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
