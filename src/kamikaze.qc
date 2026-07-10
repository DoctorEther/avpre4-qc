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


// ---------------- DANO EM ÁREA CUSTOM ---------------------
// Kamikazes vizinhos NÃO recebem T_Damage aqui — eles são
// detonados via touch/proximidade quando a onda de explosão
// chega neles, evitando que o enemy deles seja corrompido.

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
        if (head != self && head.classname != "monster_kamikaze" &&
            head.takedamage && head.health > 0)
        {
            dist   = vlen(org - (head.origin + (head.mins + head.maxs) * 0.5));
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

void() kamikaze_touch =
{

    if (other == world)
        return;

    // ignora gibs e corpos no chão
    if (other.type == "gib")
        return;

    // ignora entidades sem vida (corpos de monstros mortos)
    if (other.health <= 0 && other.classname != "player")
        return;

    // contato direto com o player: explode sempre
    if (other.classname == "player")
    {
        T_Damage(self, other, other, self.health, DMGTYPE_INSTANT);
        return;
    }

    // contato com outro kamikaze: só explode se o player
    // estiver dentro do raio desta posição
    if (other.classname == "monster_kamikaze")
    {
        if (!self.enemy || self.enemy.health <= 0)
            return;

        float player_dist = vlen(self.origin - self.enemy.origin);

        if (player_dist <= KAMIKAZE_BLAST_RADIUS)
            T_Damage(self, other, other, self.health, DMGTYPE_INSTANT);

        return;
    }

    // monstro vivo ou outra entidade que tome dano
    if (other.takedamage)
        T_Damage(self, other, other, self.health, DMGTYPE_INSTANT);
};


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

    if (dist <= KAMIKAZE_ARM_DISTANCE)
        T_Damage(self, self.enemy, self.enemy, self.health, DMGTYPE_INSTANT);
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
    kamikaze_checkdistance();

    self.nextthink = time + KAMIKAZE_THINK_TIME;
    self.think     = kamikaze_run;
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

    // versão padrão: qualquer hit explode
    if (attacker && attacker != world) {
        self.enemy = attacker;
    }
    
    T_Damage(self, self.dmg_inflictor, attacker, self.health, DMGTYPE_INSTANT);
};

void() kamikaze_die =
{
    local vector org;
    local entity real_attacker;
    local float  blast_damage;
    local float  blast_radius;

    if (self.solid == SOLID_NOT)
        return;

    // captura tudo ANTES de mutar qualquer campo do self

    if (self.enemy)
        real_attacker = self.enemy;
    else
        real_attacker = world;

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

    self.solid      = SOLID_NOT;
    self.takedamage = DAMAGE_NO;
    self.velocity   = '0 0 0';

    kamikaze_gibs();

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, org_x);
    WriteCoord(MSG_BROADCAST, org_y);
    WriteCoord(MSG_BROADCAST, org_z);

    Kamikaze_RadiusDamage(blast_radius, blast_damage, real_attacker);

    remove(self);
};


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

    self.touch = kamikaze_touch;

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
