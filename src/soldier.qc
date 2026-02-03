/*
==============================================================================
SOLDIER / PLAYER
NAIL GRUNT VARIANT - MOTOQUEIRO (Biker on motorcycle)

Este inimigo representa um bandido em uma moto atirando enquanto passa.
Comportamentos de moto implementados:
- Velocidade variável (18-34 unidades/frame simulando aceleração)
- Giros bruscos (45-110 graus, como manobras de moto)
- Drive-by shooting (atira enquanto passa em alta velocidade lateral)
- Derrapagens e ziguezagues constantes
- Nunca fica parado - sempre em movimento
- Dano ultra-reduzido (15% chance de disparo + spread alto)
- Sistema anti-infighting para evitar atingir aliados

VERSÃO: Ataque em movimento, dano reduzido 95%+, comportamento veicular
==============================================================================
*/
// Forward declarations to avoid "Unknown value" errors
void() army_fire;
void() army_firenails;
void() army_natk1;
void() army_atk1;
void() army_run1;
float() army_check_safe_to_fire;

$cd id1/models/soldier3
$origin 0 -6 24
$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11
$frame load1 load2 load3 load4 load5 load6 load7 load8 load9 load10 load11
$frame pain1 pain2 pain3 pain4 pain5 pain6
$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14
$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10
$frame painc11 painc12 painc13
$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9
$frame prowl_1 prowl_2 prowl_3 prowl_4 prowl_5 prowl_6 prowl_7 prowl_8
$frame prowl_9 prowl_10 prowl_11 prowl_12 prowl_13 prowl_14 prowl_15 prowl_16
$frame prowl_17 prowl_18 prowl_19 prowl_20 prowl_21 prowl_22 prowl_23 prowl_24

//==============================================================================
/*
================
FUNÇÃO DE SEGURANÇA MELHORADA - CUIDADO COM INFIGHTING
Retorna TRUE se é seguro, FALSE se tem aliado em risco
================
*/
float() army_check_safe_to_fire =
{
    local vector spot1, spot2;
    local entity head;
    local float dist_to_enemy;
    local vector enemy_dir;
    local vector test_dir;
    
    if (!self.enemy)
        return FALSE;
    
    // Calcula distância ao inimigo
    dist_to_enemy = vlen(self.enemy.origin - self.origin);
    enemy_dir = normalize(self.enemy.origin - self.origin);
    
    // Posição dos olhos
    spot1 = self.origin + self.view_ofs;
    spot2 = self.enemy.origin + self.enemy.view_ofs;
    
    // VERIFICAÇÃO 1: Traceline direta ao inimigo
    traceline(spot1, spot2, FALSE, self);
    
    // Se acertou um aliado diretamente, NÃO ATIRA
    if (trace_ent != self.enemy && trace_ent.health > 0)
    {
        if (trace_ent.classname == self.classname)
            return FALSE;
    }
    
    // VERIFICAÇÃO 2: Cone de 60 graus na frente com margem de segurança
    makevectors(self.angles);
    head = findradius(self.origin, 300);
    
    while (head)
    {
        if (head.classname == self.classname && head != self && head.health > 0)
        {
            local vector ally_dir;
            local float ally_dist;
            local float dot_product;
            
            ally_dir = normalize(head.origin - self.origin);
            ally_dist = vlen(head.origin - self.origin);
            
            // Produto escalar: cone de 60 graus (dot > 0.5)
            dot_product = ally_dir * enemy_dir;
            
            // Se aliado está no cone de fogo
            if (dot_product > 0.5)
            {
                // Margem de segurança generosa: 120 unidades
                if (ally_dist < dist_to_enemy + 120)
                {
                    // Verifica linha de visão ao aliado
                    traceline(spot1, head.origin + head.view_ofs, FALSE, self);
                    
                    if (trace_fraction > 0.9 || trace_ent == head)
                    {
                        return FALSE; // BLOQUEADO
                    }
                }
            }
            
            // ZONA CRÍTICA: Aliado muito próximo (70 unidades)
            if (ally_dist < 70)
            {
                // Se está minimamente na frente (cone de 90 graus)
                if (dot_product > 0.3)
                {
                    return FALSE; // Muito arriscado!
                }
            }
        }
        head = head.chain;
    }
    
    // VERIFICAÇÃO 3: Teste em 3 raios do cone (esquerda, centro, direita)
    local float i;
    local vector test_end;
    
    for (i = -1; i <= 1; i = i + 1)
    {
        test_dir = v_forward + (v_right * (i * 0.2));
        test_dir = normalize(test_dir);
        test_end = spot1 + test_dir * dist_to_enemy;
        
        traceline(spot1, test_end, FALSE, self);
        
        if (trace_ent.health > 0 && trace_ent.classname == self.classname)
        {
            return FALSE; // Aliado em um dos raios!
        }
    }
    
    return TRUE; // SEGURO PARA ATIRAR
};

/*
================
SOLDIER CODE
================
*/
void() army_stand1 =[ $stand1, army_stand2 ] {ai_stand();};
void() army_stand2 =[ $stand2, army_stand3 ] {ai_stand();};
void() army_stand3 =[ $stand3, army_stand4 ] {ai_stand();};
void() army_stand4 =[ $stand4, army_stand5 ] {ai_stand();};
void() army_stand5 =[ $stand5, army_stand6 ] {ai_stand();};
void() army_stand6 =[ $stand6, army_stand7 ] {ai_stand();};
void() army_stand7 =[ $stand7, army_stand8 ] {ai_stand();};
void() army_stand8 =[ $stand8, army_stand1 ] {ai_stand();};

void() army_walk1 =[ $prowl_1, army_walk2 ] {
    if (random() < 0.2)
        sound(self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
    ai_walk(1);
};
void() army_walk2 =[ $prowl_2, army_walk3 ] {ai_walk(1);};
void() army_walk3 =[ $prowl_3, army_walk4 ] {ai_walk(1);};
void() army_walk4 =[ $prowl_4, army_walk5 ] {ai_walk(1);};
void() army_walk5 =[ $prowl_5, army_walk6 ] {ai_walk(2);};
void() army_walk6 =[ $prowl_6, army_walk7 ] {ai_walk(3);};
void() army_walk7 =[ $prowl_7, army_walk8 ] {ai_walk(4);};
void() army_walk8 =[ $prowl_8, army_walk9 ] {ai_walk(4);};
void() army_walk9 =[ $prowl_9, army_walk10 ] {ai_walk(2);};
void() army_walk10 =[ $prowl_10, army_walk11 ] {ai_walk(2);};
void() army_walk11 =[ $prowl_11, army_walk12 ] {ai_walk(2);};
void() army_walk12 =[ $prowl_12, army_walk13 ] {ai_walk(1);};
void() army_walk13 =[ $prowl_13, army_walk14 ] {ai_walk(0);};
void() army_walk14 =[ $prowl_14, army_walk15 ] {ai_walk(1);};
void() army_walk15 =[ $prowl_15, army_walk16 ] {ai_walk(1);};
void() army_walk16 =[ $prowl_16, army_walk17 ] {ai_walk(1);};
void() army_walk17 =[ $prowl_17, army_walk18 ] {ai_walk(3);};
void() army_walk18 =[ $prowl_18, army_walk19 ] {ai_walk(3);};
void() army_walk19 =[ $prowl_19, army_walk20 ] {ai_walk(3);};
void() army_walk20 =[ $prowl_20, army_walk21 ] {ai_walk(3);};
void() army_walk21 =[ $prowl_21, army_walk22 ] {ai_walk(2);};
void() army_walk22 =[ $prowl_22, army_walk23 ] {ai_walk(1);};
void() army_walk23 =[ $prowl_23, army_walk24 ] {ai_walk(1);};
void() army_walk24 =[ $prowl_24, army_walk1 ] {ai_walk(1);};

void() army_run1 =[ $run1, army_run2 ] {
    if (random() < 0.2)
        sound(self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
    ai_run(11);
};
void() army_run2 =[ $run2, army_run3 ] {ai_run(15);};
void() army_run3 =[ $run3, army_run4 ] {ai_run(10);};
void() army_run4 =[ $run4, army_run5 ] {ai_run(10);};
void() army_run5 =[ $run5, army_run6 ] {ai_run(8);};
void() army_run6 =[ $run6, army_run7 ] {ai_run(15);};
void() army_run7 =[ $run7, army_run8 ] {ai_run(10);};
void() army_run8 =[ $run8, army_run1 ] {ai_run(8);};

// NAILGRUNT RUN - COMPORTAMENTO DE MOTO (separado do soldier normal)
void() nailgrunt_run1 =[ $run1, nailgrunt_run2 ] {
    local entity head;
    local float ally_count;
    local float move_speed;
    local float turn_chance;

    if (random() < 0.2)
        sound(self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);

    // MOTO: Velocidade ALTA e variável
    move_speed = 22 + (random() * 13); // Entre 22-35 de velocidade

    // SEMPRE faz movimento lateral (moto nunca vai reto)
    if (random() < 0.8)
    {
        if (random() < 0.5)
            walkmove(self.ideal_yaw + (60 + random() * 40), 22);
        else
            walkmove(self.ideal_yaw - (60 + random() * 40), 22);
    }

    // Giro constante tipo moto
    turn_chance = random();
    if (turn_chance < 0.4)
        self.ideal_yaw = self.ideal_yaw + (30 + random() * 50);
    else if (turn_chance < 0.8)
        self.ideal_yaw = self.ideal_yaw - (30 + random() * 50);

    // Conta quantos aliados estão próximos
    ally_count = 0;
    head = findradius(self.origin, 100);
    while (head)
    {
        if (head.classname == self.classname && head != self && head.health > 0)
        {
            ally_count = ally_count + 1;

            // DERRAPAGEM BRUSCA ao detectar aliado
            if (vlen(self.origin - head.origin) < 80)
            {
                makevectors(self.angles);
                if (random() < 0.5)
                {
                    walkmove(self.ideal_yaw + (90 + random() * 30), 31);
                    self.ideal_yaw = self.ideal_yaw + 90;
                }
                else
                {
                    walkmove(self.ideal_yaw - (90 + random() * 30), 31);
                    self.ideal_yaw = self.ideal_yaw - 90;
                }
            }
        }
        head = head.chain;
    }

    // Manobra evasiva radical se muito aglomerado
    if (ally_count >= 2)
    {
        walkmove(self.ideal_yaw + 180, 27);
        self.ideal_yaw = self.ideal_yaw + 180;
        if (random() < 0.5)
            walkmove(self.ideal_yaw + 90, 22);
        else
            walkmove(self.ideal_yaw - 90, 22);
    }

    ai_run(move_speed);
};
void() nailgrunt_run2 =[ $run2, nailgrunt_run3 ] {
    ai_run(27 + (random() * 10));
    if (random() < 0.7)
    {
        if (random() < 0.5)
            walkmove(self.ideal_yaw + (40 + random() * 30), 18);
        else
            walkmove(self.ideal_yaw - (40 + random() * 30), 18);
    }
    if (random() < 0.5)
        self.ideal_yaw = self.ideal_yaw + (random() * 60 - 30);
};
void() nailgrunt_run3 =[ $run3, nailgrunt_run4 ] {
    ai_run(25 + (random() * 9));
    if (random() < 0.5)
        walkmove(self.ideal_yaw + 75, 16);
    else
        walkmove(self.ideal_yaw - 75, 16);
};
void() nailgrunt_run4 =[ $run4, nailgrunt_run5 ] {
    ai_run(28 + (random() * 10));
    if (random() < 0.6)
    {
        if (random() < 0.5)
        {
            walkmove(self.ideal_yaw + 65, 19);
            self.ideal_yaw = self.ideal_yaw + 40;
        }
        else
        {
            walkmove(self.ideal_yaw - 65, 19);
            self.ideal_yaw = self.ideal_yaw - 40;
        }
    }
};
void() nailgrunt_run5 =[ $run5, nailgrunt_run6 ] {
    ai_run(23 + (random() * 12));
    walkmove(self.ideal_yaw + 50, 13);
    walkmove(self.ideal_yaw - 50, 13);
};
void() nailgrunt_run6 =[ $run6, nailgrunt_run7 ] {
    ai_run(31 + (random() * 9));
    if (random() < 0.4)
    {
        if (random() < 0.5)
        {
            self.ideal_yaw = self.ideal_yaw + (70 + random() * 40);
            walkmove(self.ideal_yaw, 25);
        }
        else
        {
            self.ideal_yaw = self.ideal_yaw - (70 + random() * 40);
            walkmove(self.ideal_yaw, 25);
        }
    }
};
void() nailgrunt_run7 =[ $run7, nailgrunt_run8 ] {
    ai_run(27 + (random() * 7));
    if (random() < 0.7)
    {
        walkmove(self.ideal_yaw + 45, 18);
        walkmove(self.ideal_yaw - 90, 18);
        walkmove(self.ideal_yaw + 45, 18);
    }
};
void() nailgrunt_run8 =[ $run8, nailgrunt_run1 ] {
    ai_run(25 + (random() * 12));
    if (random() < 0.6)
    {
        if (random() < 0.5)
        {
            walkmove(self.ideal_yaw + 80, 22);
            self.ideal_yaw = self.ideal_yaw + 50;
        }
        else
        {
            walkmove(self.ideal_yaw - 80, 22);
            self.ideal_yaw = self.ideal_yaw - 50;
        }
    }
};

// Shotgun attack - SOLDIER NORMAL (sem modificações, como o original)
void() army_atk1 =[ $shoot1, army_atk2 ] {ai_face();};
void() army_atk2 =[ $shoot2, army_atk3 ] {ai_face();};
void() army_atk3 =[ $shoot3, army_atk4 ] {ai_face();};
void() army_atk4 =[ $shoot4, army_atk5 ] {ai_face();};
void() army_atk5 =[ $shoot5, army_atk6 ] {
    ai_face();
    army_fire();
    self.effects = self.effects | EF_MUZZLEFLASH;
};
void() army_atk6 =[ $shoot6, army_atk7 ] {ai_face();};
void() army_atk7 =[ $shoot7, army_atk8 ] {
    ai_face();
    SUB_CheckRefire(army_atk1);
};
void() army_atk8 =[ $shoot8, army_atk9 ] {ai_face();};
void() army_atk9 =[ $shoot9, army_run1 ] {ai_face();};

// Nailgun attack - DRIVE-BY SHOOTING EXTREMO (Moto em alta velocidade - 10% mais lento)
void() army_natk1 =[ $shoot1, army_natk2 ] {
    ai_face();
    self.count = 0;
    
    // ACELERA MUITO lateralmente (aproximação agressiva)
    if (random() < 0.5)
        walkmove(self.ideal_yaw + (80 + random() * 30), 36); // 36 (era 40)
    else
        walkmove(self.ideal_yaw - (80 + random() * 30), 36);
    
    // Gira bruscamente
    if (random() < 0.6)
    {
        if (random() < 0.5)
            self.ideal_yaw = self.ideal_yaw + 60;
        else
            self.ideal_yaw = self.ideal_yaw - 60;
    }
    
    if (!army_check_safe_to_fire())
    {
        nailgrunt_run1();
        return;
    }
};
void() army_natk2 =[ $shoot2, army_natk3 ] {
    ai_face();
    // Movimento circular tipo moto contornando alvo
    walkmove(self.ideal_yaw + 95, 31); // 31 (era 35)
    walkmove(self.ideal_yaw - 180, 13); // 13 (era 15)
    
    // Giro contínuo
    self.ideal_yaw = self.ideal_yaw + (40 + random() * 30);
};
void() army_natk3 =[ $shoot3, army_natk4 ] {
    ai_face();
    
    // MOVIMENTO CAÓTICO: Múltiplos movimentos simultâneos
    local entity head;
    local vector strafe_dir;
    local float best_angle;
    local float turn_angle;
    
    // Giro amplo + movimento (wheeling)
    turn_angle = 90 + (random() * 60); // 90-150 graus
    
    if (random() < 0.5)
    {
        walkmove(self.ideal_yaw + turn_angle, 40); // 40 (era 45)
        self.ideal_yaw = self.ideal_yaw + 70;
    }
    else
    {
        walkmove(self.ideal_yaw - turn_angle, 40);
        self.ideal_yaw = self.ideal_yaw - 70;
    }
    
    // Segundo movimento (drift composto)
    walkmove(self.ideal_yaw + 180, 18); // 18 (era 20)
    walkmove(self.ideal_yaw + 90, 22); // 22 (era 25)
    
    // Afasta de aliados COM VELOCIDADE MÁXIMA
    head = findradius(self.origin, 120);
    while (head)
    {
        if (head.classname == self.classname && head != self && head.health > 0)
        {
            if (vlen(self.origin - head.origin) < 100)
            {
                makevectors(self.angles);
                strafe_dir = normalize(self.origin - head.origin);

                if (strafe_dir * v_right > 0)
                    best_angle = self.ideal_yaw - 110;
                else
                    best_angle = self.ideal_yaw + 110;

                // Fuga em alta velocidade
                walkmove(best_angle, 40); // 40 (era 45)
                walkmove(best_angle + 45, 27); // 27 (era 30)
                
                // Gira 180 graus (manobra radical)
                if (random() < 0.6)
                    self.ideal_yaw = self.ideal_yaw + 180;
            }
        }
        head = head.chain;
    }
};
void() army_natk4 =[ $shoot4, army_natk5 ] {
    ai_face();
    // PRIMEIRO TIRO em velocidade máxima
    if (army_check_safe_to_fire())
    {
        army_firenails();
        self.count = 1;
    }
    // Movimento em L (curva + lateral)
    walkmove(self.ideal_yaw + 95, 34); // 34 (era 38)
    walkmove(self.ideal_yaw + 180, 22); // 22 (era 25)
    
    // Gira enquanto atira
    self.ideal_yaw = self.ideal_yaw + (50 + random() * 40);
};
void() army_natk5 =[ $shoot5, army_natk6 ] {
    ai_face();
    // SEGUNDO TIRO durante curva fechada
    if (self.count >= 1 && army_check_safe_to_fire())
    {
        army_firenails();
        self.count = 2;
    }
    // Curva de 120 graus em alta velocidade
    if (random() < 0.5)
    {
        walkmove(self.ideal_yaw + 120, 36); // 36 (era 40)
        self.ideal_yaw = self.ideal_yaw + 80;
    }
    else
    {
        walkmove(self.ideal_yaw - 120, 36);
        self.ideal_yaw = self.ideal_yaw - 80;
    }
    
    // Movimento adicional (drift)
    walkmove(self.ideal_yaw + 90, 27); // 27 (era 30)
};
void() army_natk6 =[ $shoot6, army_natk7 ] {
    ai_face();
    // TERCEIRO TIRO durante manobra complexa
    if (self.count >= 2 && army_check_safe_to_fire())
    {
        army_firenails();
        self.count = 3;
    }
    // Manobra em zigzag extremo
    walkmove(self.ideal_yaw + 180, 27); // 27 (era 30)
    walkmove(self.ideal_yaw + 90, 31); // 31 (era 35)
    walkmove(self.ideal_yaw - 180, 22); // 22 (era 25)
    
    // Giro de 180 graus (volta correndo)
    self.ideal_yaw = self.ideal_yaw + (150 + random() * 60);
};
void() army_natk7 =[ $shoot7, army_natk8 ] {
    ai_face();
    // Aceleração de fuga + ziguezague
    walkmove(self.ideal_yaw, 31); // 31 (era 35)
    
    if (random() < 0.7)
    {
        if (random() < 0.5)
        {
            walkmove(self.ideal_yaw + 70, 27); // 27 (era 30)
            self.ideal_yaw = self.ideal_yaw + 60;
        }
        else
        {
            walkmove(self.ideal_yaw - 70, 27);
            self.ideal_yaw = self.ideal_yaw - 60;
        }
    }
};
void() army_natk8 =[ $shoot8, army_natk9 ] {
    ai_face();
    // Fuga em alta velocidade com slalom
    ai_run(36); // 36 (era 40)
    
    // Slalom triplo
    walkmove(self.ideal_yaw + 60, 27); // 27 (era 30)
    walkmove(self.ideal_yaw - 120, 27);
    walkmove(self.ideal_yaw + 60, 27);
    
    // Giro final
    if (random() < 0.5)
        self.ideal_yaw = self.ideal_yaw + (70 + random() * 50);
    else
        self.ideal_yaw = self.ideal_yaw - (70 + random() * 50);
};
void() army_natk9 =[ $shoot9, nailgrunt_run1 ] {
    ai_face();
    self.count = 0;
    if (random() < 0.2 && army_check_safe_to_fire())
        SUB_CheckRefire(army_natk1);
};

void() army_pain1 =[ $pain1, army_pain2 ] {};
void() army_pain2 =[ $pain2, army_pain3 ] {};
void() army_pain3 =[ $pain3, army_pain4 ] {};
void() army_pain4 =[ $pain4, army_pain5 ] {};
void() army_pain5 =[ $pain5, army_pain6 ] {};
void() army_pain6 =[ $pain6, army_run1 ] {ai_pain(1);};

void() army_painb1 =[ $painb1, army_painb2 ] {};
void() army_painb2 =[ $painb2, army_painb3 ] {ai_painforward(13);};
void() army_painb3 =[ $painb3, army_painb4 ] {ai_painforward(9);};
void() army_painb4 =[ $painb4, army_painb5 ] {};
void() army_painb5 =[ $painb5, army_painb6 ] {};
void() army_painb6 =[ $painb6, army_painb7 ] {};
void() army_painb7 =[ $painb7, army_painb8 ] {};
void() army_painb8 =[ $painb8, army_painb9 ] {};
void() army_painb9 =[ $painb9, army_painb10 ] {};
void() army_painb10 =[ $painb10, army_painb11 ] {};
void() army_painb11 =[ $painb11, army_painb12 ] {};
void() army_painb12 =[ $painb12, army_painb13 ] {ai_pain(2);};
void() army_painb13 =[ $painb13, army_painb14 ] {};
void() army_painb14 =[ $painb14, army_run1 ] {};

void() army_painc1 =[ $painc1, army_painc2 ] {};
void() army_painc2 =[ $painc2, army_painc3 ] {ai_pain(1);};
void() army_painc3 =[ $painc3, army_painc4 ] {};
void() army_painc4 =[ $painc4, army_painc5 ] {};
void() army_painc5 =[ $painc5, army_painc6 ] {ai_painforward(1);};
void() army_painc6 =[ $painc6, army_painc7 ] {ai_painforward(1);};
void() army_painc7 =[ $painc7, army_painc8 ] {};
void() army_painc8 =[ $painc8, army_painc9 ] {ai_pain(1);};
void() army_painc9 =[ $painc9, army_painc10 ] {ai_painforward(4);};
void() army_painc10 =[ $painc10, army_painc11 ] {ai_painforward(3);};
void() army_painc11 =[ $painc11, army_painc12 ] {ai_painforward(6);};
void() army_painc12 =[ $painc12, army_painc13 ] {ai_painforward(8);};
void() army_painc13 =[ $painc13, army_run1 ] {};

void(entity attacker, float damage) army_pain =
{
    local float r;
    if (self.pain_finished > time)
        return;
    r = random();
    if (r < 0.2)
    {
        self.pain_finished = time + 0.6;
        army_pain1();
        sound(self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
    }
    else if (r < 0.6)
    {
        self.pain_finished = time + 1.1;
        army_painb1();
        sound(self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
    }
    else
    {
        self.pain_finished = time + 1.1;
        army_painc1();
        sound(self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
    }
};

void() army_fire =
{
    local vector dir;
    local entity en;
    ai_face();
    sound(self, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);
    
    // Fire somewhat behind the player, so a dodging player is harder to hit
    en = self.enemy;
    dir = en.origin - en.velocity * 0.2;
    dir = normalize(dir - self.origin);
    
    // SOLDIER NORMAL: Dano original, sem modificações
    FireBullets(4, dir, '0.1 0.1 0');
};

void() army_firenails =
{
    local vector dir;
    local entity target;
    local vector spot1, spot2;

    target = self.enemy;
    spot1 = self.origin + self.view_ofs;
    spot2 = target.origin + target.view_ofs;

    traceline(spot1, spot2, FALSE, self);

    if (trace_ent != target)
        return;

    sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
    self.effects = self.effects | EF_MUZZLEFLASH;

    dir = target.origin - target.velocity * 0.2;
    dir = normalize(dir - self.origin);
    
    // DANO MUITO REDUZIDO: Apenas 15% de chance de disparar prego
    // E quando dispara, é com precisão reduzida
    if (random() < 0.15)
    {
        // Adiciona spread aleatório ao disparo
        local vector spread;
        spread_x = (random() - 0.5) * 0.3;
        spread_y = (random() - 0.5) * 0.3;
        spread_z = (random() - 0.5) * 0.3;
        dir = normalize(dir + spread);
        
        launch_spike(self.origin + '0 0 16', dir);
    }
};

void() army_die1 =[ $death1, army_die2 ] {};
void() army_die2 =[ $death2, army_die3 ] {};
void() army_die3 =[ $death3, army_die4 ] {
    self.solid = SOLID_NOT;
    self.ammo_nails = 10;
    DropBackpack();
};
void() army_die4 =[ $death4, army_die5 ] {};
void() army_die5 =[ $death5, army_die6 ] {};
void() army_die6 =[ $death6, army_die7 ] {};
void() army_die7 =[ $death7, army_die8 ] {};
void() army_die8 =[ $death8, army_die9 ] {};
void() army_die9 =[ $death9, army_die10 ] {};
void() army_die10 =[ $death10, army_die10 ] {};

void() army_cdie1 =[ $deathc1, army_cdie2 ] {};
void() army_cdie2 =[ $deathc2, army_cdie3 ] {ai_back(5);};
void() army_cdie3 =[ $deathc3, army_cdie4 ] {
    self.solid = SOLID_NOT;
    self.ammo_nails = 10;
    DropBackpack();
    ai_back(4);
};
void() army_cdie4 =[ $deathc4, army_cdie5 ] {ai_back(13);};
void() army_cdie5 =[ $deathc5, army_cdie6 ] {ai_back(3);};
void() army_cdie6 =[ $deathc6, army_cdie7 ] {ai_back(4);};
void() army_cdie7 =[ $deathc7, army_cdie8 ] {};
void() army_cdie8 =[ $deathc8, army_cdie9 ] {};
void() army_cdie9 =[ $deathc9, army_cdie10 ] {};
void() army_cdie10 =[ $deathc10, army_cdie11 ] {};
void() army_cdie11 =[ $deathc11, army_cdie11 ] {};

void() army_die =
{
    if (self.health < -35)
    {
        sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
        ThrowHead("progs/h_guard.mdl", self.health);
        ThrowGib("progs/gib1.mdl", self.health);
        ThrowGib("progs/gib2.mdl", self.health);
        ThrowGib("progs/gib3.mdl", self.health);
        self.ammo_nails = 10;
        DropBackpack();
        return;
    }
    sound(self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
    if (random() < 0.5)
        army_die1();
    else
        army_cdie1();
};

/*QUAKED monster_nailgrunt (1 0 0) (-16 -16 -24) (16 16 40) Ambush
MOTOQUEIRO - Bandido em moto com nailgun
*/
void() monster_nailgrunt =
{
    if (deathmatch)
    {
        remove(self);
        return;
    }

    // Nailgrunt must match this file's frame list ($cd soldier3)
    precache_model("progs/soldier3.mdl");
    precache_model("progs/h_guard.mdl");
    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");
    precache_sound("soldier/death1.wav");
    precache_sound("soldier/idle.wav");
    precache_sound("soldier/pain1.wav");
    precache_sound("soldier/pain2.wav");
    precache_sound("soldier/sattck1.wav");
    precache_sound("soldier/sight1.wav");
    precache_sound("player/udeath.wav");
    precache_sound("weapons/spike2.wav");

    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;

    setmodel(self, "progs/soldier3.mdl");

    setsize(self, '-16 -16 -24', '16 16 40');
    self.health = 30;

    self.th_stand = army_stand1;
    self.th_walk = army_walk1;
    self.th_run = nailgrunt_run1; // USA FUNÇÕES SEPARADAS DE MOTO
    self.th_missile = army_natk1;
    self.th_pain = army_pain;
    self.th_die = army_die;

    walkmonster_start();
};

/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_army =
{
    if (deathmatch)
    {
        remove(self);
        return;
    }
    precache_model("progs/soldier.mdl");
    precache_model("progs/h_guard.mdl");
    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");
    precache_sound("soldier/death1.wav");
    precache_sound("soldier/idle.wav");
    precache_sound("soldier/pain1.wav");
    precache_sound("soldier/pain2.wav");
    precache_sound("soldier/sattck1.wav");
    precache_sound("soldier/sight1.wav");
    precache_sound("player/udeath.wav");

    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;
    setmodel(self, "progs/soldier.mdl");
    setsize(self, '-16 -16 -24', '16 16 40');
    self.health = 30;

    self.th_stand = army_stand1;
    self.th_walk = army_walk1;
    self.th_run = army_run1;
    self.th_missile = army_atk1;
    self.th_pain = army_pain;
    self.th_die = army_die;

    walkmonster_start();
};
