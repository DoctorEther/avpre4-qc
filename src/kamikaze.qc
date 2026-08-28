// ==========================================================
// MONSTER_KAMIKAZE (standalone, vanilla-friendly)
// ==========================================================
// - Corre em direção ao player e explode:
//      • por proximidade (82 unidades)
//      • por contato direto com o PLAYER (não outros monstros)
//      • com 1 hit de qualquer arma (versão padrão)
//      • após 3 hits do player (versão TANQUE, spawnflag 1)
// - Explosão padrão:  30 de dano, raio 160
// - Explosão tanque:  40 de dano, raio 160
// - Versão tanque é forte contra monstros (recebe metade)
// - Gibs em dobro ao explodir
// - Grito contínuo enquanto persegue o jogador
//
// SPAWNFLAGS:
//   1 = TANQUE → 125 de vida, explode com 3 hits, mais dano
// ==========================================================


// ------------------------ CAMPOS --------------------------

.float kam_hits;        // contador de tiros do player
.float kam_nextscream;  // cooldown para o grito contínuo


// --------------------- CONSTANTES -------------------------

float KAMIKAZE_ARM_DISTANCE = 82;
float KAMIKAZE_BLAST_DAMAGE = 30;
float KAMIKAZE_BLAST_RADIUS = 160;
float KAMIKAZE_THINK_TIME   = 0.1;

// spawnflag: versão tanque (125 hp, 3 hits, explosão mais forte)
float KAMIKAZE_TANK              = 1;
float KAMIKAZE_TANK_BLAST_DAMAGE = 40;
float KAMIKAZE_TANK_BLAST_RADIUS = 160;

// frames do modelo
float KAMIKAZE_FIRST_FRAME = 0;
float KAMIKAZE_LAST_FRAME  = 17;
float KAMIKAZE_IDLE_FRAME  = 0;


void(float radius, float damage, entity attacker) Kamikaze_RadiusDamage =
{
    float   points;
    float dist;
    entity  head;
    vector  org;

    org = self.origin + '0 0 16';

    head = findradius(org, radius);
    
    while (head)
    {
        if (head != self &&
            !(self.dmg_inflictor.classname == "monster_kamikaze" && head.classname == "monster_kamikaze") && // don't propagate if damage came from another kami
            head.takedamage && head.health > 0)
        {
            dist = vlen(org - (head.origin + (head.mins + head.maxs) * 0.5));

            if (head.classname == "monster_kamikaze") // smaller range for other kamis
                dist = dist*1.5;

            points = damage * (1 - dist / radius);

            if (points > 0)
            {
                if (CanDamage (head, self))
                {   
                    T_Damage (head, self, attacker, points, DMGTYPE_EXPLOSION);
                }
            }
        }
        head = head.chain;
    }
};


float(entity inflictor, entity attacker, float damage, float orig_damage, float dmgtype) kamikaze_damage = {
    // dano de outros monstros: devolve metade (mais resistente)
    if (attacker.flags & FL_MONSTER && attacker.classname != "player")
        return damage * 0.5;
    else
        return damage;
}


// ------------------------ TOUCH ---------------------------
// Regras de toque:
// • Toca player              → explode sempre
// • Toca outro kamikaze      → explode só se o player está
//                              dentro do raio (cadeia útil)
// • Toca gib/corpse          → ignora
// • Toca monstro vivo        → explode
// • Toca world/brush         → ignora


// ---------------------- GIBS EXTRA ------------------------

void() kamikaze_gibs =
{
    ThrowGib ("progs/gib1.mdl", -20);
    ThrowGib ("progs/gib2.mdl", -20);
    ThrowGib ("progs/gib3.mdl", -20);
    ThrowGib ("progs/gib1.mdl", -20);
    ThrowGib ("progs/gib2.mdl", -20);
    ThrowGib ("progs/gib3.mdl", -20);
    ThrowHead("progs/h_gib.mdl", -20);
};


// ------------------- GRITO CONTÍNUO -----------------------

void() kamikaze_scream =
{
    if (time < self.kam_nextscream)
        return;
    sound(self, CHAN_VOICE, "kamikaze/scream.wav", 1, ATTN_NORM);
    self.kam_nextscream = time + 1.5;
};



// --------------------- PROXIMIDADE ------------------------

void() kamikaze_checkdistance =
{
    local float dist;

    if (!self.enemy || self.enemy.health <= 0)
        return;

    dist = vlen(self.origin - self.enemy.origin);

    if (dist <= KAMIKAZE_ARM_DISTANCE){
        //dprint("Enemy too close, detonating\n");
        T_Damage(self, self.enemy, self.enemy, self.health, DMGTYPE_INSTANT);
    }
};


// ------------------------ IDLE ----------------------------

void() kamikaze_idle =
{
    if (self.frame < KAMIKAZE_FIRST_FRAME || self.frame > 4)
        self.frame = KAMIKAZE_IDLE_FRAME;
    else
        self.frame++;

    if (FindTarget())
        return;

    ai_stand();

    self.nextthink = time + KAMIKAZE_THINK_TIME;
    self.think     = kamikaze_idle;
};


// ------------------------ WALK ----------------------------

void() kamikaze_run =
{
    if (!self.enemy || self.enemy.health <= 0)
    {
        if (!FindTarget())
        {
            self.think     = kamikaze_idle;
            self.nextthink = time + KAMIKAZE_THINK_TIME;
            return;
        }
    }

    if (self.frame < 5 || self.frame > KAMIKAZE_LAST_FRAME)
        self.frame = 5;
    else
        self.frame++;

    if (self.frame >= 0 && self.frame <= 4)
        self.frame = 5;

    ai_run(20);

    kamikaze_scream();
    
    self.nextthink = time + KAMIKAZE_THINK_TIME;
    self.think     = kamikaze_run;

    kamikaze_checkdistance();
};


// -------------------- PAIN & DIE --------------------------
//
// VERSÃO PADRÃO (sem spawnflag 1):
//   • Morre com 1 hit de qualquer arma/fonte → explode
//
// VERSÃO TANQUE (spawnflag 1 = KAMIKAZE_TANK):
//   • Player causa hits que contam; explode com 3
//   • NPCs causam metade do dano e não contam pro contador
//

void(entity attacker, float damage) kamikaze_pain =
{
    if (self.spawnflags & KAMIKAZE_TANK)
    {
        self.kam_hits = self.kam_hits + 1;

        if (self.kam_hits >= 3)
            T_Damage(self, self.dmg_inflictor, attacker, self.health, DMGTYPE_INSTANT);
        return;
    }

    
    //T_Damage(self, self.dmg_inflictor, attacker, self.health, DMGTYPE_INSTANT);
};

void() kamikaze_die =
{
    //dprint("Dead, setting up boom think\n");
    self.takedamage = DAMAGE_NO;
    self.nextthink = time + 0.1;
    self.think = kamikaze_boom;
    //kamikaze_boom();
};

void() kamikaze_boom = {
    float blast_damage, blast_radius;

    if (self.spawnflags & KAMIKAZE_TANK)
    {
        blast_damage = KAMIKAZE_TANK_BLAST_DAMAGE;
        blast_radius = KAMIKAZE_TANK_BLAST_RADIUS;
    }
    else
    {
        blast_damage = KAMIKAZE_BLAST_DAMAGE;
        blast_radius = KAMIKAZE_BLAST_RADIUS;
    }

    kamikaze_gibs();

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, self.origin_x);
    WriteCoord(MSG_BROADCAST, self.origin_y);
    WriteCoord(MSG_BROADCAST, self.origin_z);

    Kamikaze_RadiusDamage(blast_radius, blast_damage, self.enemy);

    remove(self);
}

// ------------------------ SPAWN ---------------------------

void() monster_kamikaze =
{
    precache_model("progs/kamikaze.mdl");
    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");
    precache_model("progs/h_gib.mdl");
    precache_sound("kamikaze/scream.wav");

    self.movetype   = MOVETYPE_STEP;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;
    self.flags      = FL_MONSTER;

    setmodel(self, "progs/kamikaze.mdl");
    setsize(self, '-20 -20 -24', '20 20 40');

    self.th_stand = kamikaze_idle;
    self.th_walk  = kamikaze_idle;
    self.th_run   = kamikaze_run;
    self.th_pain  = kamikaze_pain;
    self.th_die   = kamikaze_die;
    self.th_damage = kamikaze_damage;


    self.kam_hits       = 0;
    self.kam_nextscream = 0;
    self.classname      = "monster_kamikaze";
    self.frame          = KAMIKAZE_IDLE_FRAME;

    if (self.spawnflags & KAMIKAZE_TANK)
        self.health = 125;
    else
        self.health = 1;

    walkmonster_start();
};
