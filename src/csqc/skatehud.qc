/*void(vector pos, float value, float threshhold, float style) Hud_DrawLargeValue =
{
	float c;
	float len;
	string s;
	if (value < 0)
		value = 0;	//hrm
	if (value>999)
		value = 999;

	//for (len = 0; len < 3; len++) {
	//	drawpic(pos+ len * '24 0 0', "gfx/numbk_non", '24 24 0', '1 1 1', 1, 0);
	//}

	s = ftos(floor(value));
	len = strlen(s);

	pos_x += 24 * (3-len);
	
	if (value <= threshhold)
	{	//use alternate (red) numbers

		while(len>0)
		{
			len--;
			c = str2chr(s, len);

			if (style == 2)
				drawpic(pos+len * '24 0 0', anumber2[c-'0'], '24 24 0', '1 1 1', 1, 0);
			else
				drawpic(pos+len * '24 0 0', anumber[c-'0'], '24 24 0', '1 1 1', 1, 0);
		}
	}
	else
	{	//use normal numbers

		while(len>0)
		{
			len--;
			c = str2chr(s, len);

			if (style == 2)
				drawpic(pos+len * '24 0 0', number2[c-'0'], '24 24 0', '1 1 1', 1, 0);
			else
				drawpic(pos+len * '24 0 0', number[c-'0'], '24 24 0', '1 1 1', 1, 0);
		}
	}
};*/


void(vector screensize, float scoreboard) CSQC_DrawHud =
{
	float st_skate = getstatf(STAT_SKATE_ON);

	if (getstatf(STAT_SKATE_ON) > 0)
		drawstring([screensize_x/2 - 30, screensize_y/2, 0], "$yes", '10 10 10', '1 1 1', 1, 0);
		//drawrawstring(screensize/2, "SKATE!!!", '10 10 10', '1 1 1', 1, 0);
	/*HUD_UpdateStats();
	if (intermission || coopdata == -1) return;
	float viewsize = cvar("viewsize");
	Hud_DrawTint(screensize);
	
	if (viewsize > 110)
		return;

	vector pos;
	baralpha = cvar("scr_sbaralpha");
	hudstyle = max(cvar("saved1"), cvar("hudstyle"));	// catch ironwail hud cvar
	float margin, exp;

	exp = (viewsize <= 100);

	if (hudstyle)
	{
		margin = 4 * (floor(screensize_y / 120) - 1);
		
		if (scoreboard || stat_health <= 0)
		{
			Hud_DrawLevelInfoBar([screensize_x / 2, screensize_y] - '160 24');
			if (deathmatch)
			{
				Hud_DrawRankings([screensize_x / 2 - 160, screensize_y / 2 - 120]);
			}
			else if (screensize_x >= 500 && stat_health > 0)
			{
				Hud_DrawModernLeft([margin, screensize_y - margin], exp);
				Hud_DrawModernRight([screensize_x - margin, screensize_y - margin], exp);
			}
		}
		else
		{
			Hud_DrawModernLeft([margin, screensize_y - margin], exp);
			Hud_DrawModernCenter([screensize_x / 2, screensize_y - margin], exp);
			Hud_DrawModernRight([screensize_x - margin, screensize_y - margin], exp);
		}
		if (exp)
		{
			if ((deathmatch && !(scoreboard || stat_health <= 0)) || coop)
				Hud_DrawMultiplayer([margin, floor(screensize_y * 0.3)], '0 12', MP_MEDIUM);
			Hud_DrawModernWeapons([screensize_x, floor(screensize_y * 0.4)]);
		}		
	}
	else
	{
		pos = screensize;
		pos_x = screensize_x / 2;
		if (scoreboard || stat_health <= 0)
		{
			Hud_DrawLevelInfoBar(pos - '160 24');
			if (coop || deathmatch)
				Hud_DrawRankings([screensize_x / 2 - 160, screensize_y / 2 - 120]);
		}
		else
			Hud_DrawSBar(pos - '160 24');
		
		if (exp)
			Hud_DrawIBar(pos - '160 48');
	}
	*/
};
