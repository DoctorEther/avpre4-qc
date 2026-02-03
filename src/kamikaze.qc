// ==========================================================
// MONSTER_KAMIKAZE (standalone, vanilla-friendly)
// ==========================================================
// - Corre em direção ao player e explode:
//      • por proximidade (82 unidades)
//      • por contato direto
//      • após 3 tiros do player (30% menos que 5)
// - Explosão causa 5 de dano, raio 96
// - Forte contra ataques de outros monstros (recebe metade)
// - Gibs em dobro ao explodir
// - Grito contínuo enquanto persegue o jogador
// ==========================================================


// ------------------------ CAMPOS --------------------------

.float kam_hits;        // contador de tiros do player
.float kam_nextscream;  // cooldown para o grito contínuo


// --------------------- CONSTANTES -------------------------

float KAMIKAZE_ARM_DISTANCE = 82;
float KAMIKAZE_BLAST_DAMAGE = 5;
float KAMIKAZE_BLAST_RADIUS = 96;
float KAMIKAZE_THINK_TIME   = 0.1;

// frames do modelo
float KAMIKAZE_FIRST_FRAME = 0;
float KAMIKAZE_LAST_FRAME  = 17;

// idle agora é um loop 0–4
float KAMIKAZE_IDLE_FRAME  = 0;   // primeiro frame de idle


// ---------------- DANO EM ÁREA CUSTOM ---------------------

void(vector org, float radius, float damage, entity attacker) Kamikaze_RadiusDamage =
{
    local entity ent;
    ent = findradius(org, radius);

    while (ent)
    {
        if (ent.takedamage && ent != self)
        {
            T_Damage(ent, attacker, attacker, damage);
        }
        ent = ent.chain;
    }
};


// ---------------------- GIBS EXTRA ------------------------

void() kamikaze_gibs =
{
    ThrowGib ("progs/gib1.mdl", -20);
    ThrowGib ("progs/gib2.mdl", -20);
    ThrowGib ("progs/gib3.mdl", -20);

    // dobra a quantidade
    ThrowGib ("progs/gib1.mdl", -20);
    ThrowGib ("progs/gib2.mdl", -20);
    ThrowGib ("progs/gib3.mdl", -20);

    ThrowHead("progs/h_gib.mdl", -20);
};


// ------------------- GRITO CONTÍNUO -----------------------

void() kamikaze_scream =
{
    // cooldown pro grito não spammar todo frame
    if (time < self.kam_nextscream)
        return;

    // som de grito do kamikaze
    // coloque o .wav em sound/kamikaze/scream.wav
    sound(self, CHAN_VOICE, "kamikaze/scream.wav", 1, ATTN_NORM);

    // toca a cada 1.5s (ajustável)
    self.kam_nextscream = time + 1.5;
};


// ---------------------- EXPLOSÃO --------------------------

void() kamikaze_explode =
{
    local vector org;
    local entity real_attacker;

    if (self.solid == SOLID_NOT)
        return;

    org = self.origin + '0 0 16';

    if (self.enemy)
        real_attacker = self.enemy;
    else
        real_attacker = world;

    self.solid      = SOLID_NOT;
    self.takedamage = DAMAGE_NO;
    self.velocity   = '0 0 0';

    kamikaze_gibs();

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, org_x);
    WriteCoord(MSG_BROADCAST, org_y);
    WriteCoord(MSG_BROADCAST, org_z);

    Kamikaze_RadiusDamage(org, KAMIKAZE_BLAST_RADIUS, KAMIKAZE_BLAST_DAMAGE, real_attacker);

    remove(self);
};


// ------------------------ TOUCH ---------------------------

void() kamikaze_touch =
{
    if (other.takedamage)
        kamikaze_explode();
};


// --------------------- PROXIMIDADE ------------------------

void() kamikaze_checkdistance =
{
    local float dist;

    if (!self.enemy)
        return;

    dist = vlen(self.origin - self.enemy.origin);

    if (dist <= KAMIKAZE_ARM_DISTANCE)
        kamikaze_explode();
};


// ------------------------ IDLE ----------------------------

void() kamikaze_idle =
{
    // loop de idle: frames 0 a 4
    if (self.frame < KAMIKAZE_FIRST_FRAME || self.frame > 4)
        self.frame = KAMIKAZE_IDLE_FRAME;   // 0
    else
        self.frame++;

    if (FindTarget())
        return;

    ai_stand();

    self.nextthink = time + KAMIKAZE_THINK_TIME;
    self.think     = kamikaze_idle;
};


// ------------------------ WALK ----------------------------

void() kamikaze_walk =
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

    // animação: frames 5 a 17 (movimentação)
    if (self.frame < 5 || self.frame > KAMIKAZE_LAST_FRAME)
        self.frame = 5;
    else
        self.frame++;

    // só por segurança, se cair na faixa de idle, pula pra 5
    if (self.frame >= 0 && self.frame <= 4)
        self.frame = 5;

    ai_run(20);

    // grito constante enquanto corre atrás do player
    kamikaze_scream();

    kamikaze_checkdistance();

    self.nextthink = time + KAMIKAZE_THINK_TIME;
    self.think     = kamikaze_walk;
};


// -------------------- PAIN & DIE --------------------------
//
// • Player causa hits que contam
// • Explode com 3 hits do player
// • NPCs causam metade do dano real e não contam pro contador
//

void(entity attacker, float damage) kamikaze_pain =
{
    // dano vindo de outros monstros (crossfire NPC)
    if (attacker && (attacker.flags & FL_MONSTER) && attacker.classname != "player")
    {
        // T_Damage já tirou "damage" da health;
        // devolve 50% pra ele ficar mais tanque contra monstros
        self.health = self.health + (damage * 0.5);
        return;
    }

    // hit válido do player (ou mundo/trap no seu mod)
    self.kam_hits = self.kam_hits + 1;

    // explode com 3 hits (30% menos que 5)
    if (self.kam_hits >= 3)
        kamikaze_explode();
};

void() kamikaze_die =
{
    kamikaze_explode();
};


// ------------------------ SPAWN ---------------------------

void() monster_kamikaze =
{
    precache_model("progs/kamikaze.mdl");

    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");
    precache_model("progs/h_gib.mdl");

    // som do grito
    precache_sound("kamikaze/scream.wav");

    self.movetype   = MOVETYPE_STEP;
    self.solid      = SOLID_SLIDEBOX;

    self.health     = 125;

    self.takedamage = DAMAGE_AIM;
    self.flags      = FL_MONSTER;

    setmodel(self, "progs/kamikaze.mdl");
    setsize(self, '-20 -20 -24', '20 20 40');

    self.th_stand = kamikaze_idle;
    self.th_walk  = kamikaze_walk;
    self.th_run   = kamikaze_walk;
    self.th_pain  = kamikaze_pain;
    self.th_die   = kamikaze_die;

    self.touch = kamikaze_touch;

    self.kam_hits       = 0;
    self.kam_nextscream = 0;
    self.classname      = "monster_kamikaze";

    // começa no primeiro frame do idle (0)
    self.frame = KAMIKAZE_IDLE_FRAME;

    walkmonster_start();
};

