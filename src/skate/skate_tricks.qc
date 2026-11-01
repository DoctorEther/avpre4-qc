float AV_SKATE_FAST_FRAMETIME = 0.0136;

// --- KICKFLIP ---------------------------------------

void()	player_sk_flip1 =	[242, player_sk_flip2	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip2 =	[243, player_sk_flip3	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip3 =	[244, player_sk_flip4	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip4 =	[245, player_sk_flip5	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip5 =	[246, player_sk_flip6	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip6 =	[247, player_sk_flip7	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip7 =	[248, player_sk_flip8	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip8 =	[249, player_sk_flip9	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip9 =	[250, player_sk_flip10	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip10 =	[251, player_sk_flip11	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip11 =	[252, player_sk_flip12	] {
	self.nextthink = time + AV_SKATE_FAST_FRAMETIME;
	
	if(self.skate_flags & SKFL_TRICK){
		self.skate_flags = self.skate_flags - SKFL_TRICK;
		AV_SkateAddTrick("$qc_sk_kickflip", 200);
	}
};
void()	player_sk_flip12 =	[253, player_sk_flip13	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip13 =	[254, player_sk_flip14	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip14 =	[255, player_sk_flip15	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip15 =	[256, player_sk_flip16	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip16 =	[257, player_sk_flip17	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip17 =	[258, player_sk_flip18	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip18 =	[259, player_sk_flip19	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip19 =	[260, player_sk_flip20	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip20 =	[261, player_sk_flip21	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip21 =	[262, player_sk_flip22	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip22 =	[263, player_sk_flip23	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_flip23 =	[264, player_run		] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };

// --- 360 --------------------------------------------

void()	player_sk_spin1 =	[265, player_sk_spin2	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin2 =	[266, player_sk_spin3	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin3 =	[267, player_sk_spin4	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin4 =	[268, player_sk_spin5	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin5 =	[269, player_sk_spin6	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin6 =	[270, player_sk_spin7	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin7 =	[271, player_sk_spin8	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin8 =	[272, player_sk_spin9	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin9 =	[273, player_sk_spin10	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin10 =	[274, player_sk_spin11	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin11 =	[275, player_sk_spin12	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin12 =	[276, player_sk_spin13	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin13 =	[277, player_sk_spin14	] {
	self.nextthink = time + AV_SKATE_FAST_FRAMETIME;
	
	if(self.skate_flags & SKFL_TRICK){
		self.skate_flags = self.skate_flags - SKFL_TRICK;
		AV_SkateAddTrick("$qc_sk_spin", 500);
	}
};
void()	player_sk_spin14 =	[278, player_sk_spin15	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin15 =	[279, player_sk_spin16	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin16 =	[280, player_sk_spin17	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin17 =	[281, player_sk_spin18	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin18 =	[282, player_sk_spin19	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin19 =	[283, player_sk_spin20	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin20 =	[284, player_sk_spin21	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin21 =	[285, player_sk_spin22	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin22 =	[286, player_sk_spin23	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin23 =	[287, player_sk_spin24	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin24 =	[288, player_sk_spin25	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin25 =	[289, player_sk_spin26	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin26 =	[290, player_sk_spin27	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_spin27 =	[291, player_run		] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };

// --- BACKFLIP ---------------------------------------

void()	player_sk_bflip1 =	[292, player_sk_bflip2	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip2 =	[293, player_sk_bflip3	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip3 =	[294, player_sk_bflip4	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip4 =	[295, player_sk_bflip5	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip5 =	[296, player_sk_bflip6	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip6 =	[297, player_sk_bflip7	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip7 =	[298, player_sk_bflip8	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip8 =	[299, player_sk_bflip9	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip9 =	[300, player_sk_bflip10	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip10 =	[301, player_sk_bflip11	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip11 =	[302, player_sk_bflip12	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip12 =	[303, player_sk_bflip13	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip13 =	[304, player_sk_bflip14	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip14 =	[305, player_sk_bflip15	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip15 =	[306, player_sk_bflip16	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip16 =	[307, player_sk_bflip17	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip17 =	[308, player_sk_bflip18	] {
	self.nextthink = time + AV_SKATE_FAST_FRAMETIME;
	
	if(self.skate_flags & SKFL_TRICK){
		self.skate_flags = self.skate_flags - SKFL_TRICK;
		AV_SkateAddTrick("$qc_sk_backflip", 800);
	}
};
void()	player_sk_bflip18 =	[309, player_sk_bflip19	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip19 =	[310, player_sk_bflip20	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip20 =	[311, player_sk_bflip21	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip21 =	[312, player_sk_bflip22	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip22 =	[313, player_sk_bflip23	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip23 =	[314, player_sk_bflip24	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip24 =	[315, player_sk_bflip25	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip25 =	[316, player_sk_bflip26	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip26 =	[317, player_sk_bflip27	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip27 =	[318, player_sk_bflip28	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip28 =	[319, player_sk_bflip29	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip29 =	[320, player_sk_bflip30	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip30 =	[321, player_sk_bflip31	] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
void()	player_sk_bflip31 =	[322, player_run		] { self.nextthink = time + AV_SKATE_FAST_FRAMETIME; };
