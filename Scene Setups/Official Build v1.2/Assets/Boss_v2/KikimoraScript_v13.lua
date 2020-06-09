function GetTableKikimoraScript_v13 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.AudioFunctions = Scripting.Audio ()
lua_table.AnimationFunctions = Scripting.Animations ()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.SeceneFunctions = Scripting.Scenes()
lua_table.MaterialsFunctions = Scripting.Materials()

-----------------------------------------------------------------------------------------
-- Health Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.current_health = 0
lua_table.health = 15000

local is_dead = false
lua_table.despawn_time = 15

-- Health Percentages for each phase
lua_table.current_health_percentage = 0
lua_table.health_percentage_phase_1 = 100
lua_table.health_percentage_phase_2 = 66
lua_table.health_percentage_phase_3 = 33

lua_table.attack_pattern_cooldown_phase_1 = 5
lua_table.attack_pattern_cooldown_phase_2 = 4
lua_table.attack_pattern_cooldown_phase_3 = 3

lua_table.speed_modificator_base = 1.25      -- This affect all anims speed
lua_table.speed_modificator_phase_2 = 1.2  -- This affect only attack speeds (adds up with base)
lua_table.speed_modificator_phase_3 = 1.4   -- This affect only attack speeds (adds up with base)

lua_table.hits_received = 0
lua_table.critical_hits_received = 0

lua_table.damage_received = 0
local damage_received_real = -1
lua_table.damage_received_mod = 1.5
lua_table.damage_received_orig = -1

-----------------------------------------------------------------------------------------
-- Movement Variables
-----------------------------------------------------------------------------------------

-- Distance of player/s to activate the boss
lua_table.awakening_distance = 15
local player_in_awakening_distance = false

-----------------------------------------------------------------------------------------
-- Phases & States Variables
-----------------------------------------------------------------------------------------

local phase = -- not in use rn
{
	CHILL = 1,      -- phase 1
	MAD = 2, 		-- phase 2
	ENRAGED = 3     -- phase 3
}
local current_phase = phase.CHILL -- Should initialize at awake(?)

lua_table.awakened = false -- bool for other scripts
lua_table.dead = false

local state =  
{
    UNACTIVE = -1,

    DEAD = 0,

    AWAKENING = 1,
    
	IDLE = 2,
    MOVING = 3,
    
    ATTACKING = 4,
    
	JUMPING = 8,
    TAUNTING = 9,

	STUNNED = 10,
    SWAPPING_PHASE = 11,
    
    SPAWNING_MINIONS = 12
}
local current_state = state.UNACTIVE -- Should initialize at awake(?)

local start_swapping = false
local finish_swapping = false

local jumping_state = 
{
    TO_BE_DETERMINED = 0,

    UPWARDS = 1,
    LEVITATING = 2,
    DOWNWARDS = 3,
}
local current_jumping_state = jumping_state.TO_BE_DETERMINED

local start_jumping = false
local finish_jumping = false

local jumping_position = 
{
    FRONT = 1,
    LEFT_SIDE = 2,
    RIGHT_SIDE = 3,
}
local current_jumping_position = jumping_position.FRONT

-----------------------------------------------------------------------------------------
-- Attacks Variables
-----------------------------------------------------------------------------------------

local attack_pattern = 
{
    TO_BE_DETERMINED = 0,

    PATTERN_STOMPY = 1,         -- Stomp, Right Sweep, Left Sweep, Stomp
    PATTERN_SIDE_TO_SIDE = 2,   -- Left Leash, Right Sweep, Left Sweep, Right Leash
    SCREAM_SWEEP = 3            -- Roar, Sweep

}
local current_attack_pattern = attack_pattern.TO_BE_DETERMINED

local attack_pattern_cooldown = lua_table.attack_pattern_cooldown_phase_1 
local attack_pattern_cooldown_bool = false
local attack_pattern_timer = 0
local attack_counter = 0

local attack_type = 
{
    TO_BE_DETERMINED = 0,

    ATTACKING_LEASH_LEFT = 2,
    ATTACKING_LEASH_RIGHT = 3,
    ATTACKING_STOMP = 4,
    ATTACKING_SWEEP = 5,
    ATTACKING_SWEEP_LEFT = 6,
    ATTACKING_SWEEP_RIGHT = 7,
    ATTACKING_ROAR = 8
}
local current_attack_type = attack_type.TO_BE_DETERMINED

local attack_subdivision = 
{
    TO_BE_DETERMINED = 0,

    ANTICIPATION = 1,
    EXECUTION = 2,
    RECOVERY = 3
}
local current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

local attack_effect = --Not definitive, but as showcase
{	
	NONE = 0,
	STUN = 1,
	KNOCKBACK = 2,
	TAUNT = 3,
	VENOM = 4
}

local attack = 
{
    leash_left = { att_damage = 40, att_effect = attack_effect.KNOCKBACK, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 5, att_cooldown_bool = false, att_timer = 0},
    leash_right = { att_damage = 40, att_effect = attack_effect.KNOCKBACK, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 5, att_cooldown_bool = false, att_timer = 0},

    sweep = { att_damage = 30, att_effect = attack_effect.KNOCKBACK, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 11, att_cooldown_bool = false, att_timer = 0},
    sweep_left = { att_damage = 30, att_effect = attack_effect.KNOCKBACK, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 25, att_cooldown_bool = false, att_timer = 0},
    sweep_right = { att_damage = 30, att_effect = attack_effect.KNOCKBACK, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 25, att_cooldown_bool = false, att_timer = 0},

	stomp = { att_damage = 50, att_effect = attack_effect.KNOCKBACK, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 16, att_cooldown_bool = false, att_timer = 0},
	roar = { att_damage = 0, att_effect = attack_effect.STUN, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 30, att_cooldown_bool = false, att_timer = 0},

    jump = { att_damage = 0, att_effect = attack_effect.KNOCKBACK, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 30, att_cooldown_bool = false, att_timer = 0},
}

local attack_finished = false
local attack_started = true


-----------------------------------------------------------------------------------------
-- Animation Variables
-----------------------------------------------------------------------------------------
local animation = 
{
    awakening = { anim_name = "awakening", anim_frames = 59, anim_speed = 30, anim_blendtime = 0 },

    jump = { anim_name = "jump", anim_frames = 56, anim_speed = 30, anim_blendtime = 0 },

    swap_phase = { anim_name = "swap_phase", anim_frames = 135, anim_speed = 30, anim_blendtime = 0 },
    
    idle = { anim_name = "idle", anim_frames = 42, anim_speed = 30, anim_blendtime = 0 },
    
    death = { anim_name = "death", anim_frames = 138, anim_speed = 30, anim_blendtime = 0 },

    leash = { anim_name = "leash", anim_frames = 68, anim_speed = 30, anim_blendtime = 0 }, --unused

    leash_left_anticipation = { anim_name = "leash_left_anticipation", anim_frames = 118, anim_speed = 30, anim_blendtime = 0 },
    leash_left_execution = { anim_name = "leash_left_execution", anim_frames = 7, anim_speed = 30, anim_blendtime = 0 },
    leash_left_recovery = { anim_name = "leash_left_recovery", anim_frames = 57, anim_speed = 30, anim_blendtime = 0 },
    
    leash_right_anticipation = { anim_name = "leash_right_anticipation", anim_frames = 118, anim_speed = 30, anim_blendtime = 0 },
    leash_right_execution = { anim_name = "leash_right_execution", anim_frames = 8, anim_speed = 30, anim_blendtime = 0 },
    leash_right_recovery = { anim_name = "leash_right_recovery", anim_frames = 56, anim_speed = 30, anim_blendtime = 0 },
    
    sweep_anticipation = { anim_name = "sweep_anticipation", anim_frames = 57, anim_speed = 30, anim_blendtime = 0 },
    sweep_execution = { anim_name = "sweep_execution", anim_frames = 13, anim_speed = 30, anim_blendtime = 0 },
    sweep_recovery = { anim_name = "sweep_recovery", anim_frames = 39, anim_speed = 30, anim_blendtime = 0 },
    
    sweep_left_anticipation = { anim_name = "sweep_left_anticipation", anim_frames = 59, anim_speed = 30, anim_blendtime = 0 },
    sweep_left_execution = { anim_name = "sweep_left_execution", anim_frames = 5, anim_speed = 30, anim_blendtime = 0 },
    sweep_left_recovery = { anim_name = "sweep_left_recovery", anim_frames = 34, anim_speed = 30, anim_blendtime = 0 },
    
    sweep_right_anticipation = { anim_name = "sweep_right_anticipation", anim_frames = 57, anim_speed = 30, anim_blendtime = 0 },
    sweep_right_execution = { anim_name = "sweep_right_execution", anim_frames = 5, anim_speed = 30, anim_blendtime = 0 },
    sweep_right_recovery = { anim_name = "sweep_right_recovery", anim_frames = 34, anim_speed = 30, anim_blendtime = 0 },
    
    stomp_anticipation = { anim_name = "stomp_anticipation", anim_frames = 34, anim_speed = 20, anim_blendtime = 0 }, -- custom speed
    stomp_execution = { anim_name = "stomp_execution", anim_frames = 20, anim_speed = 30, anim_blendtime = 0 },
    stomp_recovery = { anim_name = "stomp_recovery", anim_frames = 52, anim_speed = 30, anim_blendtime = 0 },
    
    roar_anticipation = { anim_name = "roar_anticipation", anim_frames = 28, anim_speed = 30, anim_blendtime = 0 },
    roar_execution = { anim_name = "roar_execution", anim_frames = 75, anim_speed = 30, anim_blendtime = 0 },
    roar_recovery = { anim_name = "roar_recovery", anim_frames = 32, anim_speed = 30, anim_blendtime = 0 },
}

-----------------------------------------------------------------------------------------
-- Collider Variables
-----------------------------------------------------------------------------------------

local attack_collider = --most vars initialized in awake
{
    leash_left_pivot = { coll_name = "Leash_Left_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} }, 
    leash_left = { coll_name = "Leash_Left_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },

    leash_right_pivot = { coll_name = "Leash_Right_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} }, 
    leash_right = { coll_name = "Leash_Right_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },

    sweep_left_pivot = { coll_name = "Sweep_Left_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },
    sweep_left = { coll_name = "Sweep_Left_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },
    
    sweep_right_pivot = { coll_name = "Sweep_Right_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },
    sweep_right = { coll_name = "Sweep_Right_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },
    
    sweep = { coll_name = "Sweep_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },
    
    stomp = { coll_name = "Stomp_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },
    
    roar = { coll_name = "Roar_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },

    jump = { coll_name = "Jump_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {0, 0, 0}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {0, 0, 0}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {0, 0, 0}, coll_growth_velocity = {} },
}

-- Collider Layers
local layers = 
{
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4,
    prop = 5,
    particles_prop = 6,
}	
lua_table.collider_damage = 0
lua_table.collider_effect = 0

-----------------------------------------------------------------------------------------
-- Particles Variables
-----------------------------------------------------------------------------------------

local particles = 
{
    scream = { part_name = "KikimoraScream", part_UID = 0, part_active = false, part_pos = {} },

    dustcloud_stomp_left = { part_name = "DustCloud_Stomp_Left", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    dustcloud_stomp_right = { part_name = "DustCloud_Stomp_Right", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
  
    dustcloud_leash_left = { part_name = "DustCloud_Leash_Left", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    dustcloud_leash_right = { part_name = "DustCloud_Leash_Right", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    
    kiki_sweep_particle_left = { part_name = "Kiki_Sweep_Particle_Left", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} }, --this has childs??
    kiki_sweep_particle_right = { part_name = "Kiki_Sweep_Particle_Right", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    kiki_sweep_left_particle = { part_name = "Kiki_Sweep_Left_Particle", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    kiki_sweep_right_particle = { part_name = "Kiki_Sweep_Right_Particle", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    jump_area = { part_name = "Jump_Area", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    rage_aura_1 = { part_name = "Rage_Aura_1", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    rage_aura_2 = { part_name = "Rage_Aura_2", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    head_blood_hit = { part_name = "Head_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    left_leg_1_blood_hit = { part_name = "Left_Leg_1_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    left_leg_2_blood_hit = { part_name = "Left_Leg_2_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    left_leg_3_blood_hit = { part_name = "Left_Leg_3_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    left_leg_4_blood_hit = { part_name = "Left_Leg_4_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    right_leg_1_blood_hit = { part_name = "Right_Leg_1_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    right_leg_2_blood_hit = { part_name = "Right_Leg_2_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    right_leg_3_blood_hit = { part_name = "Right_Leg_3_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    right_leg_4_blood_hit = { part_name = "Right_Leg_4_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    death_blood = { part_name = "Death_Blood", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
}

lua_table.left_leg_1_hit = false
lua_table.left_leg_2_hit = false
lua_table.left_leg_3_hit = false
lua_table.left_leg_4_hit = false

lua_table.right_leg_1_hit = false
lua_table.right_leg_2_hit = false
lua_table.right_leg_3_hit = false
lua_table.right_leg_4_hit = false
-----------------------------------------------------------------------------------------
-- Game Objects Variables
-----------------------------------------------------------------------------------------

-- Kikimora GO UID
local my_UID = 0
lua_table.my_position = {}
lua_table.my_rotation = {}
local my_mesh_UID = 0
lua_table.mesh_GO = "Kikimora_Low"
lua_table.my_material_GO = "Kikimora_mat.mat"
lua_table.hit_material_GO = "HitMaterial.mat"


lua_table.jump_pos_1 = {}
lua_table.jump_rot_1 = {}

lua_table.jump_pos_2 = {}
lua_table.jump_rot_2 = {}

lua_table.jump_pos_3 = {}
lua_table.jump_rot_3 = {}

lua_table.scene_UID = 0

-- Kikimora target GO names
lua_table.geralt_GO = "Geralt"
lua_table.jaskier_GO = "Jaskier"
lua_table.yennefer_GO = "Yennefer"
lua_table.ciri_GO = "Ciri"

lua_table.camera_GO = "Camera"
local camera_UID = 0
lua_table.camera_script = {}

-- P1
local P1_id = 0
lua_table.P1_pos = {}
lua_table.P1_script = {}
lua_table.P1_distance = {}
local P1_abs_distance = nil 
local P1_timer_under_boss = -1
local P1_under_boss_waiting = false

-- P2
local P2_id = 0
lua_table.P2_pos = {}
lua_table.P2_script = {}
lua_table.P2_distance = {}
local P2_abs_distance = nil
local P2_timer_under_boss = -1
local P2_under_boss_waiting = false

lua_table.collider_parent_script = {}

-- I use this for visual pleasure (so I can write lua_table.P1_pos[x] instead of lua_table.P1_pos[1])  )
local x = 1
local y = 2
local z = 3

-----------------------------------------------------------------------------------------
-- Timers
-----------------------------------------------------------------------------------------

local game_time = 0
local attack_timer = 0
local attack_subdivision_timer = 0
local jump_timer = 0
local jump_timer_up = 0
local jump_timer_down = 0
local jump_attack_timer = 0
local state_timer = 0
local animation_timer = 0
local awakening_timer = 0.5 
local attack_tired_timer = -1
local hit_material_timer = 0

lua_table.hit_time = 0.1
lua_table.stomp_tired_time = 3
lua_table.leash_tired_time = 4
lua_table.under_time = 3 --seconds
lua_table.jump_delay_up = 0.5 --seconds
lua_table.jump_delay_down = 3

local randy = 0

local awakening_audio_played = false
local death_audio_played = false
local got_hit = false

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

local function PerfGameTime()
	return lua_table.SystemFunctions:GameTime()-- * 1000
end

local function DebugInputs()
	if lua_table.InputFunctions:KeyRepeat("Left Ctrl") then
		if lua_table.InputFunctions:KeyDown("k")	--Instakill Boss
        then
            if lua_table.awakened == true
            then
                lua_table.current_health = 0
            end
        end

        if lua_table.InputFunctions:KeyDown("l")
        then 
            lua_table.current_health = lua_table.current_health - 2000
        end

        if lua_table.InputFunctions:KeyDown("j")
        then 
            player_in_awakening_distance = true
        end

        if lua_table.InputFunctions:KeyDown("h")
        then 
            current_state = state.JUMPING
            start_jumping = true
        end

        -- if lua_table.InputFunctions:KeyDown("g")
        -- then 
        --     current_state = state.AWAKENING
        --     lua_table.current_health = lua_table.health
        --     lua_table.awakened = true
        --     lua_table.dead = false
        -- end
	end
end

local function HandlePhases()

    -- Calculate health percentage
    lua_table.current_health_percentage = (lua_table.current_health / lua_table.health) * 100

    -- Checking if inside phase 2 threshold
    if  lua_table.current_health_percentage <= lua_table.health_percentage_phase_2 and lua_table.current_health_percentage >= lua_table.health_percentage_phase_3
    then
        -- Should only enter once
        if current_phase ~= phase.MAD 
        then
            -- Setting colliders unactive
            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)
            attack_collider.stomp.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep.coll_UID)
            attack_collider.sweep.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
            attack_collider.sweep_left.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
            attack_collider.sweep_right.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)
            attack_collider.leash_left.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)
            attack_collider.leash_right.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.roar.coll_UID)
            attack_collider.roar.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.jump.coll_UID)
            attack_collider.jump.coll_active = false

            --Updating states
            current_state = state.SWAPPING_PHASE
            current_phase = phase.MAD
            start_swapping = true
            lua_table.SystemFunctions:LOG ("Kikimora: Swapping to phase 2")

            -- Updating cooldown
            attack_pattern_cooldown = lua_table.attack_pattern_cooldown_phase_2

            -- Updating animations speed
            animation.leash_left_anticipation.anim_speed = animation.leash_left_anticipation.anim_speed * lua_table.speed_modificator_phase_2
            animation.leash_left_execution.anim_speed = animation.leash_left_execution.anim_speed * lua_table.speed_modificator_phase_2
            animation.leash_left_recovery.anim_speed = animation.leash_left_recovery.anim_speed * lua_table.speed_modificator_phase_2
    
            animation.leash_right_anticipation.anim_speed = animation.leash_right_anticipation.anim_speed * lua_table.speed_modificator_phase_2
            animation.leash_right_execution.anim_speed = animation.leash_right_execution.anim_speed * lua_table.speed_modificator_phase_2
            animation.leash_right_recovery.anim_speed = animation.leash_right_recovery.anim_speed * lua_table.speed_modificator_phase_2

            animation.sweep_anticipation.anim_speed = animation.sweep_anticipation.anim_speed * lua_table.speed_modificator_phase_2
            animation.sweep_execution.anim_speed = animation.sweep_execution.anim_speed * lua_table.speed_modificator_phase_2
            animation.sweep_recovery.anim_speed = animation.sweep_recovery.anim_speed * lua_table.speed_modificator_phase_2
    
            animation.sweep_left_anticipation.anim_speed = animation.sweep_left_anticipation.anim_speed * lua_table.speed_modificator_phase_2
            animation.sweep_left_execution.anim_speed = animation.sweep_left_execution.anim_speed * lua_table.speed_modificator_phase_2
            animation.sweep_left_recovery.anim_speed = animation.sweep_left_recovery.anim_speed * lua_table.speed_modificator_phase_2
    
            animation.sweep_right_anticipation.anim_speed = animation.sweep_right_anticipation.anim_speed * lua_table.speed_modificator_phase_2
            animation.sweep_right_execution.anim_speed = animation.sweep_right_execution.anim_speed * lua_table.speed_modificator_phase_2
            animation.sweep_right_recovery.anim_speed = animation.sweep_right_recovery.anim_speed * lua_table.speed_modificator_phase_2
    
            animation.stomp_anticipation.anim_speed = animation.stomp_anticipation.anim_speed * lua_table.speed_modificator_phase_2
            animation.stomp_execution.anim_speed = animation.stomp_execution.anim_speed * lua_table.speed_modificator_phase_2
            animation.stomp_recovery.anim_speed = animation.stomp_recovery.anim_speed * lua_table.speed_modificator_phase_2
    
            animation.roar_anticipation.anim_speed = animation.roar_anticipation.anim_speed * lua_table.speed_modificator_phase_2
            animation.roar_execution.anim_speed = animation.roar_execution.anim_speed * lua_table.speed_modificator_phase_2
            animation.roar_recovery.anim_speed = animation.roar_recovery.anim_speed * lua_table.speed_modificator_phase_2

            -- Updating attacks durations
            attack.leash_left.att_anticipation_duration = animation.leash_left_anticipation.anim_frames / animation.leash_left_anticipation.anim_speed 
            attack.leash_left.att_execution_duration = animation.leash_left_execution.anim_frames / animation.leash_left_execution.anim_speed 
            attack.leash_left.att_recovery_duration = animation.leash_left_recovery.anim_frames / animation.leash_left_recovery.anim_speed 
    
            attack.leash_right.att_anticipation_duration = animation.leash_right_anticipation.anim_frames / animation.leash_right_anticipation.anim_speed 
            attack.leash_right.att_execution_duration = animation.leash_right_execution.anim_frames / animation.leash_right_execution.anim_speed 
            attack.leash_right.att_recovery_duration = animation.leash_right_recovery.anim_frames / animation.leash_right_recovery.anim_speed 

            attack.sweep.att_anticipation_duration = animation.sweep_anticipation.anim_frames / animation.sweep_anticipation.anim_speed 
            attack.sweep.att_execution_duration = animation.sweep_execution.anim_frames / animation.sweep_execution.anim_speed 
            attack.sweep.att_recovery_duration = animation.sweep_recovery.anim_frames / animation.sweep_recovery.anim_speed 

            attack.sweep_left.att_anticipation_duration = animation.sweep_left_anticipation.anim_frames / animation.sweep_left_anticipation.anim_speed 
            attack.sweep_left.att_execution_duration = animation.sweep_left_execution.anim_frames / animation.sweep_left_execution.anim_speed 
            attack.sweep_left.att_recovery_duration = animation.sweep_left_recovery.anim_frames / animation.sweep_left_recovery.anim_speed 

            attack.sweep_right.att_anticipation_duration = animation.sweep_right_anticipation.anim_frames / animation.sweep_right_anticipation.anim_speed 
            attack.sweep_right.att_execution_duration = animation.sweep_right_execution.anim_frames / animation.sweep_right_execution.anim_speed 
            attack.sweep_right.att_recovery_duration = animation.sweep_right_recovery.anim_frames / animation.sweep_right_recovery.anim_speed 

            attack.stomp.att_anticipation_duration = animation.stomp_anticipation.anim_frames / animation.stomp_anticipation.anim_speed
            attack.stomp.att_execution_duration = animation.stomp_execution.anim_frames / animation.stomp_execution.anim_speed 
            attack.stomp.att_recovery_duration = animation.stomp_recovery.anim_frames / animation.stomp_recovery.anim_speed 

            attack.roar.att_anticipation_duration = animation.roar_anticipation.anim_frames / animation.roar_anticipation.anim_speed 
            attack.roar.att_execution_duration = animation.roar_execution.anim_frames / animation.roar_execution.anim_speed 
            attack.roar.att_recovery_duration = animation.roar_recovery.anim_frames / animation.roar_recovery.anim_speed

            -- Updating attacks velocities (a lot of lines are actually not useful BUT this will work no matter what values ara changed in the future)
            attack_collider.leash_left_pivot.coll_velocity[x] = (attack_collider.leash_left_pivot.coll_final_pos[x] - attack_collider.leash_left_pivot.coll_init_pos[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_velocity[y] = (attack_collider.leash_left_pivot.coll_final_pos[y] - attack_collider.leash_left_pivot.coll_init_pos[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_velocity[z] = (attack_collider.leash_left_pivot.coll_final_pos[z] - attack_collider.leash_left_pivot.coll_init_pos[z]) / attack.leash_left.att_execution_duration
            attack_collider.leash_left_pivot.coll_ang_velocity[x] = (attack_collider.leash_left_pivot.coll_final_rot[x] - attack_collider.leash_left_pivot.coll_init_rot[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_ang_velocity[y] = (attack_collider.leash_left_pivot.coll_final_rot[y] - attack_collider.leash_left_pivot.coll_init_rot[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_ang_velocity[z] = (attack_collider.leash_left_pivot.coll_final_rot[z] - attack_collider.leash_left_pivot.coll_init_rot[z]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_growth_velocity[x] = (attack_collider.leash_left_pivot.coll_init_scale[x] - attack_collider.leash_left_pivot.coll_final_scale[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_growth_velocity[y] = (attack_collider.leash_left_pivot.coll_init_scale[y] - attack_collider.leash_left_pivot.coll_final_scale[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_growth_velocity[z] = (attack_collider.leash_left_pivot.coll_init_scale[z] - attack_collider.leash_left_pivot.coll_final_scale[z]) / attack.leash_left.att_execution_duration

            attack_collider.leash_left.coll_velocity[x] = (attack_collider.leash_left.coll_final_pos[x] - attack_collider.leash_left.coll_init_pos[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_velocity[y] = (attack_collider.leash_left.coll_final_pos[y] - attack_collider.leash_left.coll_init_pos[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_velocity[z] = (attack_collider.leash_left.coll_final_pos[z] - attack_collider.leash_left.coll_init_pos[z]) / attack.leash_left.att_execution_duration
            attack_collider.leash_left.coll_ang_velocity[x] = (attack_collider.leash_left.coll_final_rot[x] - attack_collider.leash_left.coll_init_rot[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_ang_velocity[y] = (attack_collider.leash_left.coll_final_rot[y] - attack_collider.leash_left.coll_init_rot[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_ang_velocity[z] = (attack_collider.leash_left.coll_final_rot[z] - attack_collider.leash_left.coll_init_rot[z]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_growth_velocity[x] = (attack_collider.leash_left.coll_init_scale[x] - attack_collider.leash_left.coll_final_scale[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_growth_velocity[y] = (attack_collider.leash_left.coll_init_scale[y] - attack_collider.leash_left.coll_final_scale[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_growth_velocity[z] = (attack_collider.leash_left.coll_init_scale[z] - attack_collider.leash_left.coll_final_scale[z]) / attack.leash_left.att_execution_duration

            attack_collider.leash_right_pivot.coll_velocity[x] = (attack_collider.leash_right_pivot.coll_final_pos[x] - attack_collider.leash_right_pivot.coll_init_pos[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_velocity[y] = (attack_collider.leash_right_pivot.coll_final_pos[y] - attack_collider.leash_right_pivot.coll_init_pos[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_velocity[z] = (attack_collider.leash_right_pivot.coll_final_pos[z] - attack_collider.leash_right_pivot.coll_init_pos[z]) / attack.leash_right.att_execution_duration
            attack_collider.leash_right_pivot.coll_ang_velocity[x] = (attack_collider.leash_right_pivot.coll_final_rot[x] - attack_collider.leash_right_pivot.coll_init_rot[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_ang_velocity[y] = (attack_collider.leash_right_pivot.coll_final_rot[y] - attack_collider.leash_right_pivot.coll_init_rot[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_ang_velocity[z] = (attack_collider.leash_right_pivot.coll_final_rot[z] - attack_collider.leash_right_pivot.coll_init_rot[z]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_growth_velocity[x] = (attack_collider.leash_right_pivot.coll_init_scale[x] - attack_collider.leash_right_pivot.coll_final_scale[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_growth_velocity[y] = (attack_collider.leash_right_pivot.coll_init_scale[y] - attack_collider.leash_right_pivot.coll_final_scale[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_growth_velocity[z] = (attack_collider.leash_right_pivot.coll_init_scale[z] - attack_collider.leash_right_pivot.coll_final_scale[z]) / attack.leash_right.att_execution_duration

            attack_collider.leash_right.coll_velocity[x] = (attack_collider.leash_right.coll_final_pos[x] - attack_collider.leash_right.coll_init_pos[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_velocity[y] = (attack_collider.leash_right.coll_final_pos[y] - attack_collider.leash_right.coll_init_pos[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_velocity[z] = (attack_collider.leash_right.coll_final_pos[z] - attack_collider.leash_right.coll_init_pos[z]) / attack.leash_right.att_execution_duration
            attack_collider.leash_right.coll_ang_velocity[x] = (attack_collider.leash_right.coll_final_rot[x] - attack_collider.leash_right.coll_init_rot[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_ang_velocity[y] = (attack_collider.leash_right.coll_final_rot[y] - attack_collider.leash_right.coll_init_rot[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_ang_velocity[z] = (attack_collider.leash_right.coll_final_rot[z] - attack_collider.leash_right.coll_init_rot[z]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_growth_velocity[x] = (attack_collider.leash_right.coll_init_scale[x] - attack_collider.leash_right.coll_final_scale[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_growth_velocity[y] = (attack_collider.leash_right.coll_init_scale[y] - attack_collider.leash_right.coll_final_scale[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_growth_velocity[z] = (attack_collider.leash_right.coll_init_scale[z] - attack_collider.leash_right.coll_final_scale[z]) / attack.leash_right.att_execution_duration

            attack_collider.sweep.coll_velocity[x] = (attack_collider.sweep.coll_final_pos[x] - attack_collider.sweep.coll_init_pos[x]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_velocity[y] = (attack_collider.sweep.coll_final_pos[y] - attack_collider.sweep.coll_init_pos[y]) / attack.sweep.att_execution_duration
            attack_collider.sweep.coll_velocity[z] = (attack_collider.sweep.coll_final_pos[z] - attack_collider.sweep.coll_init_pos[z]) / attack.sweep.att_execution_duration
            attack_collider.sweep.coll_ang_velocity[x] = (attack_collider.sweep.coll_final_rot[x] - attack_collider.sweep.coll_init_rot[x]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_ang_velocity[y] = (attack_collider.sweep.coll_final_rot[y] - attack_collider.sweep.coll_init_rot[y]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_ang_velocity[z] = (attack_collider.sweep.coll_final_rot[z] - attack_collider.sweep.coll_init_rot[z]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_growth_velocity[x] = (attack_collider.sweep.coll_init_scale[x] - attack_collider.sweep.coll_final_scale[x]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_growth_velocity[y] = (attack_collider.sweep.coll_init_scale[y] - attack_collider.sweep.coll_final_scale[y]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_growth_velocity[z] = (attack_collider.sweep.coll_init_scale[z] - attack_collider.sweep.coll_final_scale[z]) / attack.sweep.att_execution_duration

            attack_collider.sweep_left_pivot.coll_velocity[x] = (attack_collider.sweep_left_pivot.coll_final_pos[x] - attack_collider.sweep_left_pivot.coll_init_pos[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_velocity[y] = (attack_collider.sweep_left_pivot.coll_final_pos[y] - attack_collider.sweep_left_pivot.coll_init_pos[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_velocity[z] = (attack_collider.sweep_left_pivot.coll_final_pos[z] - attack_collider.sweep_left_pivot.coll_init_pos[z]) / attack.sweep_left.att_execution_duration
            attack_collider.sweep_left_pivot.coll_ang_velocity[x] = (attack_collider.sweep_left_pivot.coll_final_rot[x] - attack_collider.sweep_left_pivot.coll_init_rot[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_ang_velocity[y] = (attack_collider.sweep_left_pivot.coll_final_rot[y] - attack_collider.sweep_left_pivot.coll_init_rot[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_ang_velocity[z] = (attack_collider.sweep_left_pivot.coll_final_rot[z] - attack_collider.sweep_left_pivot.coll_init_rot[z]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_growth_velocity[x] = (attack_collider.sweep_left_pivot.coll_init_scale[x] - attack_collider.sweep_left_pivot.coll_final_scale[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_growth_velocity[y] = (attack_collider.sweep_left_pivot.coll_init_scale[y] - attack_collider.sweep_left_pivot.coll_final_scale[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_growth_velocity[z] = (attack_collider.sweep_left_pivot.coll_init_scale[z] - attack_collider.sweep_left_pivot.coll_final_scale[z]) / attack.sweep_left.att_execution_duration

            attack_collider.sweep_left.coll_velocity[x] = (attack_collider.sweep_left.coll_final_pos[x] - attack_collider.sweep_left.coll_init_pos[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_velocity[y] = (attack_collider.sweep_left.coll_final_pos[y] - attack_collider.sweep_left.coll_init_pos[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_velocity[z] = (attack_collider.sweep_left.coll_final_pos[z] - attack_collider.sweep_left.coll_init_pos[z]) / attack.sweep_left.att_execution_duration
            attack_collider.sweep_left.coll_ang_velocity[x] = (attack_collider.sweep_left.coll_final_rot[x] - attack_collider.sweep_left.coll_init_rot[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_ang_velocity[y] = (attack_collider.sweep_left.coll_final_rot[y] - attack_collider.sweep_left.coll_init_rot[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_ang_velocity[z] = (attack_collider.sweep_left.coll_final_rot[z] - attack_collider.sweep_left.coll_init_rot[z]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_growth_velocity[x] = (attack_collider.sweep_left.coll_init_scale[x] - attack_collider.sweep_left.coll_final_scale[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_growth_velocity[y] = (attack_collider.sweep_left.coll_init_scale[y] - attack_collider.sweep_left.coll_final_scale[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_growth_velocity[z] = (attack_collider.sweep_left.coll_init_scale[z] - attack_collider.sweep_left.coll_final_scale[z]) / attack.sweep_left.att_execution_duration

            attack_collider.sweep_right_pivot.coll_velocity[x] = (attack_collider.sweep_right_pivot.coll_final_pos[x] - attack_collider.sweep_right_pivot.coll_init_pos[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_velocity[y] = (attack_collider.sweep_right_pivot.coll_final_pos[y] - attack_collider.sweep_right_pivot.coll_init_pos[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_velocity[z] = (attack_collider.sweep_right_pivot.coll_final_pos[z] - attack_collider.sweep_right_pivot.coll_init_pos[z]) / attack.sweep_right.att_execution_duration
            attack_collider.sweep_right_pivot.coll_ang_velocity[x] = (attack_collider.sweep_right_pivot.coll_final_rot[x] - attack_collider.sweep_right_pivot.coll_init_rot[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_ang_velocity[y] = (attack_collider.sweep_right_pivot.coll_final_rot[y] - attack_collider.sweep_right_pivot.coll_init_rot[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_ang_velocity[z] = (attack_collider.sweep_right_pivot.coll_final_rot[z] - attack_collider.sweep_right_pivot.coll_init_rot[z]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_growth_velocity[x] = (attack_collider.sweep_right_pivot.coll_init_scale[x] - attack_collider.sweep_right_pivot.coll_final_scale[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_growth_velocity[y] = (attack_collider.sweep_right_pivot.coll_init_scale[y] - attack_collider.sweep_right_pivot.coll_final_scale[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_growth_velocity[z] = (attack_collider.sweep_right_pivot.coll_init_scale[z] - attack_collider.sweep_right_pivot.coll_final_scale[z]) / attack.sweep_right.att_execution_duration

            attack_collider.sweep_right.coll_velocity[x] = (attack_collider.sweep_right.coll_final_pos[x] - attack_collider.sweep_right.coll_init_pos[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_velocity[y] = (attack_collider.sweep_right.coll_final_pos[y] - attack_collider.sweep_right.coll_init_pos[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_velocity[z] = (attack_collider.sweep_right.coll_final_pos[z] - attack_collider.sweep_right.coll_init_pos[z]) / attack.sweep_right.att_execution_duration
            attack_collider.sweep_right.coll_ang_velocity[x] = (attack_collider.sweep_right.coll_final_rot[x] - attack_collider.sweep_right.coll_init_rot[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_ang_velocity[y] = (attack_collider.sweep_right.coll_final_rot[y] - attack_collider.sweep_right.coll_init_rot[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_ang_velocity[z] = (attack_collider.sweep_right.coll_final_rot[z] - attack_collider.sweep_right.coll_init_rot[z]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_growth_velocity[x] = (attack_collider.sweep_right.coll_init_scale[x] - attack_collider.sweep_right.coll_final_scale[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_growth_velocity[y] = (attack_collider.sweep_right.coll_init_scale[y] - attack_collider.sweep_right.coll_final_scale[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_growth_velocity[z] = (attack_collider.sweep_right.coll_init_scale[z] - attack_collider.sweep_right.coll_final_scale[z]) / attack.sweep_right.att_execution_duration
            
            attack_collider.stomp.coll_velocity[x] = (attack_collider.stomp.coll_final_pos[x] - attack_collider.stomp.coll_init_pos[x]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_velocity[y] = (attack_collider.stomp.coll_final_pos[y] - attack_collider.stomp.coll_init_pos[y]) / attack.stomp.att_execution_duration
            attack_collider.stomp.coll_velocity[z] = (attack_collider.stomp.coll_final_pos[z] - attack_collider.stomp.coll_init_pos[z]) / attack.stomp.att_execution_duration
            attack_collider.stomp.coll_ang_velocity[x] = (attack_collider.stomp.coll_final_rot[x] - attack_collider.stomp.coll_init_rot[x]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_ang_velocity[y] = (attack_collider.stomp.coll_final_rot[y] - attack_collider.stomp.coll_init_rot[y]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_ang_velocity[z] = (attack_collider.stomp.coll_final_rot[z] - attack_collider.stomp.coll_init_rot[z]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_growth_velocity[x] = (attack_collider.stomp.coll_init_scale[x] - attack_collider.stomp.coll_final_scale[x]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_growth_velocity[y] = (attack_collider.stomp.coll_init_scale[y] - attack_collider.stomp.coll_final_scale[y]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_growth_velocity[z] = (attack_collider.stomp.coll_init_scale[z] - attack_collider.stomp.coll_final_scale[z]) / attack.stomp.att_execution_duration

            attack_collider.roar.coll_velocity[x] = (attack_collider.roar.coll_final_pos[x] - attack_collider.roar.coll_init_pos[x]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_velocity[y] = (attack_collider.roar.coll_final_pos[y] - attack_collider.roar.coll_init_pos[y]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_velocity[z] = (attack_collider.roar.coll_final_pos[z] - attack_collider.roar.coll_init_pos[z]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_ang_velocity[x] = (attack_collider.roar.coll_final_rot[x] - attack_collider.roar.coll_init_rot[x]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_ang_velocity[y] = (attack_collider.roar.coll_final_rot[y] - attack_collider.roar.coll_init_rot[y]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_ang_velocity[z] = (attack_collider.roar.coll_final_rot[z] - attack_collider.roar.coll_init_rot[z]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_growth_velocity[x] = (attack_collider.roar.coll_init_scale[x] - attack_collider.roar.coll_final_scale[x]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_growth_velocity[y] = (attack_collider.roar.coll_init_scale[y] - attack_collider.roar.coll_final_scale[y]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_growth_velocity[z] = (attack_collider.roar.coll_init_scale[z] - attack_collider.roar.coll_final_scale[z]) / attack.roar.att_execution_duration
            
            -- Partciles PLAY
            lua_table.ParticlesFunctions:PlayParticleEmitter(particles.rage_aura_1.part_UID)
        end
    -- Checking if inside phase 3 threshold
    elseif lua_table.current_health_percentage <= lua_table.health_percentage_phase_3
    then
        if current_phase ~= phase.ENRAGED
        then
            -- Setting colliders unactive
            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)
            attack_collider.stomp.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep.coll_UID)
            attack_collider.sweep.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
            attack_collider.sweep_left.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
            attack_collider.sweep_right.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)
            attack_collider.leash_left.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)
            attack_collider.leash_right.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.roar.coll_UID)
            attack_collider.roar.coll_active = false

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.jump.coll_UID)
            attack_collider.jump.coll_active = false

            --Updating states
            current_state = state.SWAPPING_PHASE
            current_phase = phase.ENRAGED
            start_swapping = true
            lua_table.SystemFunctions:LOG ("Kikimora: Swapping to phase 3")

            -- Updating cooldown
            attack_pattern_cooldown = lua_table.attack_pattern_cooldown_phase_3

            -- Updating animations speed
            animation.leash_left_anticipation.anim_speed = animation.leash_left_anticipation.anim_speed * lua_table.speed_modificator_phase_3
            animation.leash_left_execution.anim_speed = animation.leash_left_execution.anim_speed * lua_table.speed_modificator_phase_3
            animation.leash_left_recovery.anim_speed = animation.leash_left_recovery.anim_speed * lua_table.speed_modificator_phase_3
    
            animation.leash_right_anticipation.anim_speed = animation.leash_right_anticipation.anim_speed * lua_table.speed_modificator_phase_3
            animation.leash_right_execution.anim_speed = animation.leash_right_execution.anim_speed * lua_table.speed_modificator_phase_3
            animation.leash_right_recovery.anim_speed = animation.leash_right_recovery.anim_speed * lua_table.speed_modificator_phase_3

            animation.sweep_anticipation.anim_speed = animation.sweep_anticipation.anim_speed * lua_table.speed_modificator_phase_3
            animation.sweep_execution.anim_speed = animation.sweep_execution.anim_speed * lua_table.speed_modificator_phase_3
            animation.sweep_recovery.anim_speed = animation.sweep_recovery.anim_speed * lua_table.speed_modificator_phase_3
    
            animation.sweep_left_anticipation.anim_speed = animation.sweep_left_anticipation.anim_speed * lua_table.speed_modificator_phase_3
            animation.sweep_left_execution.anim_speed = animation.sweep_left_execution.anim_speed * lua_table.speed_modificator_phase_3
            animation.sweep_left_recovery.anim_speed = animation.sweep_left_recovery.anim_speed * lua_table.speed_modificator_phase_3
    
            animation.sweep_right_anticipation.anim_speed = animation.sweep_right_anticipation.anim_speed * lua_table.speed_modificator_phase_3
            animation.sweep_right_execution.anim_speed = animation.sweep_right_execution.anim_speed * lua_table.speed_modificator_phase_3
            animation.sweep_right_recovery.anim_speed = animation.sweep_right_recovery.anim_speed * lua_table.speed_modificator_phase_3
    
            animation.stomp_anticipation.anim_speed = animation.stomp_anticipation.anim_speed * lua_table.speed_modificator_phase_3
            animation.stomp_execution.anim_speed = animation.stomp_execution.anim_speed * lua_table.speed_modificator_phase_3
            animation.stomp_recovery.anim_speed = animation.stomp_recovery.anim_speed * lua_table.speed_modificator_phase_3
    
            animation.roar_anticipation.anim_speed = animation.roar_anticipation.anim_speed * lua_table.speed_modificator_phase_3
            animation.roar_execution.anim_speed = animation.roar_execution.anim_speed * lua_table.speed_modificator_phase_3
            animation.roar_recovery.anim_speed = animation.roar_recovery.anim_speed * lua_table.speed_modificator_phase_3

            -- Updating attacks durations
            attack.leash_left.att_anticipation_duration = animation.leash_left_anticipation.anim_frames / animation.leash_left_anticipation.anim_speed 
            attack.leash_left.att_execution_duration = animation.leash_left_execution.anim_frames / animation.leash_left_execution.anim_speed 
            attack.leash_left.att_recovery_duration = animation.leash_left_recovery.anim_frames / animation.leash_left_recovery.anim_speed 
    
            attack.leash_right.att_anticipation_duration = animation.leash_right_anticipation.anim_frames / animation.leash_right_anticipation.anim_speed 
            attack.leash_right.att_execution_duration = animation.leash_right_execution.anim_frames / animation.leash_right_execution.anim_speed 
            attack.leash_right.att_recovery_duration = animation.leash_right_recovery.anim_frames / animation.leash_right_recovery.anim_speed 

            attack.sweep.att_anticipation_duration = animation.sweep_anticipation.anim_frames / animation.sweep_anticipation.anim_speed 
            attack.sweep.att_execution_duration = animation.sweep_execution.anim_frames / animation.sweep_execution.anim_speed 
            attack.sweep.att_recovery_duration = animation.sweep_recovery.anim_frames / animation.sweep_recovery.anim_speed 

            attack.sweep_left.att_anticipation_duration = animation.sweep_left_anticipation.anim_frames / animation.sweep_left_anticipation.anim_speed 
            attack.sweep_left.att_execution_duration = animation.sweep_left_execution.anim_frames / animation.sweep_left_execution.anim_speed 
            attack.sweep_left.att_recovery_duration = animation.sweep_left_recovery.anim_frames / animation.sweep_left_recovery.anim_speed 

            attack.sweep_right.att_anticipation_duration = animation.sweep_right_anticipation.anim_frames / animation.sweep_right_anticipation.anim_speed 
            attack.sweep_right.att_execution_duration = animation.sweep_right_execution.anim_frames / animation.sweep_right_execution.anim_speed 
            attack.sweep_right.att_recovery_duration = animation.sweep_right_recovery.anim_frames / animation.sweep_right_recovery.anim_speed 

            attack.stomp.att_anticipation_duration = animation.stomp_anticipation.anim_frames / animation.stomp_anticipation.anim_speed
            attack.stomp.att_execution_duration = animation.stomp_execution.anim_frames / animation.stomp_execution.anim_speed 
            attack.stomp.att_recovery_duration = animation.stomp_recovery.anim_frames / animation.stomp_recovery.anim_speed 

            attack.roar.att_anticipation_duration = animation.roar_anticipation.anim_frames / animation.roar_anticipation.anim_speed 
            attack.roar.att_execution_duration = animation.roar_execution.anim_frames / animation.roar_execution.anim_speed 
            attack.roar.att_recovery_duration = animation.roar_recovery.anim_frames / animation.roar_recovery.anim_speed

            -- Updating attacks velocities (a lot of lines are actually not useful BUT this will work no matter what values ara changed in the future)
            attack_collider.leash_left_pivot.coll_velocity[x] = (attack_collider.leash_left_pivot.coll_final_pos[x] - attack_collider.leash_left_pivot.coll_init_pos[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_velocity[y] = (attack_collider.leash_left_pivot.coll_final_pos[y] - attack_collider.leash_left_pivot.coll_init_pos[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_velocity[z] = (attack_collider.leash_left_pivot.coll_final_pos[z] - attack_collider.leash_left_pivot.coll_init_pos[z]) / attack.leash_left.att_execution_duration
            attack_collider.leash_left_pivot.coll_ang_velocity[x] = (attack_collider.leash_left_pivot.coll_final_rot[x] - attack_collider.leash_left_pivot.coll_init_rot[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_ang_velocity[y] = (attack_collider.leash_left_pivot.coll_final_rot[y] - attack_collider.leash_left_pivot.coll_init_rot[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_ang_velocity[z] = (attack_collider.leash_left_pivot.coll_final_rot[z] - attack_collider.leash_left_pivot.coll_init_rot[z]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_growth_velocity[x] = (attack_collider.leash_left_pivot.coll_init_scale[x] - attack_collider.leash_left_pivot.coll_final_scale[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_growth_velocity[y] = (attack_collider.leash_left_pivot.coll_init_scale[y] - attack_collider.leash_left_pivot.coll_final_scale[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left_pivot.coll_growth_velocity[z] = (attack_collider.leash_left_pivot.coll_init_scale[z] - attack_collider.leash_left_pivot.coll_final_scale[z]) / attack.leash_left.att_execution_duration

            attack_collider.leash_left.coll_velocity[x] = (attack_collider.leash_left.coll_final_pos[x] - attack_collider.leash_left.coll_init_pos[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_velocity[y] = (attack_collider.leash_left.coll_final_pos[y] - attack_collider.leash_left.coll_init_pos[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_velocity[z] = (attack_collider.leash_left.coll_final_pos[z] - attack_collider.leash_left.coll_init_pos[z]) / attack.leash_left.att_execution_duration
            attack_collider.leash_left.coll_ang_velocity[x] = (attack_collider.leash_left.coll_final_rot[x] - attack_collider.leash_left.coll_init_rot[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_ang_velocity[y] = (attack_collider.leash_left.coll_final_rot[y] - attack_collider.leash_left.coll_init_rot[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_ang_velocity[z] = (attack_collider.leash_left.coll_final_rot[z] - attack_collider.leash_left.coll_init_rot[z]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_growth_velocity[x] = (attack_collider.leash_left.coll_init_scale[x] - attack_collider.leash_left.coll_final_scale[x]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_growth_velocity[y] = (attack_collider.leash_left.coll_init_scale[y] - attack_collider.leash_left.coll_final_scale[y]) / attack.leash_left.att_execution_duration 
            attack_collider.leash_left.coll_growth_velocity[z] = (attack_collider.leash_left.coll_init_scale[z] - attack_collider.leash_left.coll_final_scale[z]) / attack.leash_left.att_execution_duration

            attack_collider.leash_right_pivot.coll_velocity[x] = (attack_collider.leash_right_pivot.coll_final_pos[x] - attack_collider.leash_right_pivot.coll_init_pos[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_velocity[y] = (attack_collider.leash_right_pivot.coll_final_pos[y] - attack_collider.leash_right_pivot.coll_init_pos[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_velocity[z] = (attack_collider.leash_right_pivot.coll_final_pos[z] - attack_collider.leash_right_pivot.coll_init_pos[z]) / attack.leash_right.att_execution_duration
            attack_collider.leash_right_pivot.coll_ang_velocity[x] = (attack_collider.leash_right_pivot.coll_final_rot[x] - attack_collider.leash_right_pivot.coll_init_rot[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_ang_velocity[y] = (attack_collider.leash_right_pivot.coll_final_rot[y] - attack_collider.leash_right_pivot.coll_init_rot[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_ang_velocity[z] = (attack_collider.leash_right_pivot.coll_final_rot[z] - attack_collider.leash_right_pivot.coll_init_rot[z]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_growth_velocity[x] = (attack_collider.leash_right_pivot.coll_init_scale[x] - attack_collider.leash_right_pivot.coll_final_scale[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_growth_velocity[y] = (attack_collider.leash_right_pivot.coll_init_scale[y] - attack_collider.leash_right_pivot.coll_final_scale[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right_pivot.coll_growth_velocity[z] = (attack_collider.leash_right_pivot.coll_init_scale[z] - attack_collider.leash_right_pivot.coll_final_scale[z]) / attack.leash_right.att_execution_duration

            attack_collider.leash_right.coll_velocity[x] = (attack_collider.leash_right.coll_final_pos[x] - attack_collider.leash_right.coll_init_pos[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_velocity[y] = (attack_collider.leash_right.coll_final_pos[y] - attack_collider.leash_right.coll_init_pos[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_velocity[z] = (attack_collider.leash_right.coll_final_pos[z] - attack_collider.leash_right.coll_init_pos[z]) / attack.leash_right.att_execution_duration
            attack_collider.leash_right.coll_ang_velocity[x] = (attack_collider.leash_right.coll_final_rot[x] - attack_collider.leash_right.coll_init_rot[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_ang_velocity[y] = (attack_collider.leash_right.coll_final_rot[y] - attack_collider.leash_right.coll_init_rot[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_ang_velocity[z] = (attack_collider.leash_right.coll_final_rot[z] - attack_collider.leash_right.coll_init_rot[z]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_growth_velocity[x] = (attack_collider.leash_right.coll_init_scale[x] - attack_collider.leash_right.coll_final_scale[x]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_growth_velocity[y] = (attack_collider.leash_right.coll_init_scale[y] - attack_collider.leash_right.coll_final_scale[y]) / attack.leash_right.att_execution_duration 
            attack_collider.leash_right.coll_growth_velocity[z] = (attack_collider.leash_right.coll_init_scale[z] - attack_collider.leash_right.coll_final_scale[z]) / attack.leash_right.att_execution_duration

            attack_collider.sweep.coll_velocity[x] = (attack_collider.sweep.coll_final_pos[x] - attack_collider.sweep.coll_init_pos[x]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_velocity[y] = (attack_collider.sweep.coll_final_pos[y] - attack_collider.sweep.coll_init_pos[y]) / attack.sweep.att_execution_duration
            attack_collider.sweep.coll_velocity[z] = (attack_collider.sweep.coll_final_pos[z] - attack_collider.sweep.coll_init_pos[z]) / attack.sweep.att_execution_duration
            attack_collider.sweep.coll_ang_velocity[x] = (attack_collider.sweep.coll_final_rot[x] - attack_collider.sweep.coll_init_rot[x]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_ang_velocity[y] = (attack_collider.sweep.coll_final_rot[y] - attack_collider.sweep.coll_init_rot[y]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_ang_velocity[z] = (attack_collider.sweep.coll_final_rot[z] - attack_collider.sweep.coll_init_rot[z]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_growth_velocity[x] = (attack_collider.sweep.coll_init_scale[x] - attack_collider.sweep.coll_final_scale[x]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_growth_velocity[y] = (attack_collider.sweep.coll_init_scale[y] - attack_collider.sweep.coll_final_scale[y]) / attack.sweep.att_execution_duration 
            attack_collider.sweep.coll_growth_velocity[z] = (attack_collider.sweep.coll_init_scale[z] - attack_collider.sweep.coll_final_scale[z]) / attack.sweep.att_execution_duration

            attack_collider.sweep_left_pivot.coll_velocity[x] = (attack_collider.sweep_left_pivot.coll_final_pos[x] - attack_collider.sweep_left_pivot.coll_init_pos[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_velocity[y] = (attack_collider.sweep_left_pivot.coll_final_pos[y] - attack_collider.sweep_left_pivot.coll_init_pos[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_velocity[z] = (attack_collider.sweep_left_pivot.coll_final_pos[z] - attack_collider.sweep_left_pivot.coll_init_pos[z]) / attack.sweep_left.att_execution_duration
            attack_collider.sweep_left_pivot.coll_ang_velocity[x] = (attack_collider.sweep_left_pivot.coll_final_rot[x] - attack_collider.sweep_left_pivot.coll_init_rot[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_ang_velocity[y] = (attack_collider.sweep_left_pivot.coll_final_rot[y] - attack_collider.sweep_left_pivot.coll_init_rot[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_ang_velocity[z] = (attack_collider.sweep_left_pivot.coll_final_rot[z] - attack_collider.sweep_left_pivot.coll_init_rot[z]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_growth_velocity[x] = (attack_collider.sweep_left_pivot.coll_init_scale[x] - attack_collider.sweep_left_pivot.coll_final_scale[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_growth_velocity[y] = (attack_collider.sweep_left_pivot.coll_init_scale[y] - attack_collider.sweep_left_pivot.coll_final_scale[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left_pivot.coll_growth_velocity[z] = (attack_collider.sweep_left_pivot.coll_init_scale[z] - attack_collider.sweep_left_pivot.coll_final_scale[z]) / attack.sweep_left.att_execution_duration

            attack_collider.sweep_left.coll_velocity[x] = (attack_collider.sweep_left.coll_final_pos[x] - attack_collider.sweep_left.coll_init_pos[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_velocity[y] = (attack_collider.sweep_left.coll_final_pos[y] - attack_collider.sweep_left.coll_init_pos[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_velocity[z] = (attack_collider.sweep_left.coll_final_pos[z] - attack_collider.sweep_left.coll_init_pos[z]) / attack.sweep_left.att_execution_duration
            attack_collider.sweep_left.coll_ang_velocity[x] = (attack_collider.sweep_left.coll_final_rot[x] - attack_collider.sweep_left.coll_init_rot[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_ang_velocity[y] = (attack_collider.sweep_left.coll_final_rot[y] - attack_collider.sweep_left.coll_init_rot[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_ang_velocity[z] = (attack_collider.sweep_left.coll_final_rot[z] - attack_collider.sweep_left.coll_init_rot[z]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_growth_velocity[x] = (attack_collider.sweep_left.coll_init_scale[x] - attack_collider.sweep_left.coll_final_scale[x]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_growth_velocity[y] = (attack_collider.sweep_left.coll_init_scale[y] - attack_collider.sweep_left.coll_final_scale[y]) / attack.sweep_left.att_execution_duration 
            attack_collider.sweep_left.coll_growth_velocity[z] = (attack_collider.sweep_left.coll_init_scale[z] - attack_collider.sweep_left.coll_final_scale[z]) / attack.sweep_left.att_execution_duration

            attack_collider.sweep_right_pivot.coll_velocity[x] = (attack_collider.sweep_right_pivot.coll_final_pos[x] - attack_collider.sweep_right_pivot.coll_init_pos[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_velocity[y] = (attack_collider.sweep_right_pivot.coll_final_pos[y] - attack_collider.sweep_right_pivot.coll_init_pos[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_velocity[z] = (attack_collider.sweep_right_pivot.coll_final_pos[z] - attack_collider.sweep_right_pivot.coll_init_pos[z]) / attack.sweep_right.att_execution_duration
            attack_collider.sweep_right_pivot.coll_ang_velocity[x] = (attack_collider.sweep_right_pivot.coll_final_rot[x] - attack_collider.sweep_right_pivot.coll_init_rot[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_ang_velocity[y] = (attack_collider.sweep_right_pivot.coll_final_rot[y] - attack_collider.sweep_right_pivot.coll_init_rot[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_ang_velocity[z] = (attack_collider.sweep_right_pivot.coll_final_rot[z] - attack_collider.sweep_right_pivot.coll_init_rot[z]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_growth_velocity[x] = (attack_collider.sweep_right_pivot.coll_init_scale[x] - attack_collider.sweep_right_pivot.coll_final_scale[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_growth_velocity[y] = (attack_collider.sweep_right_pivot.coll_init_scale[y] - attack_collider.sweep_right_pivot.coll_final_scale[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right_pivot.coll_growth_velocity[z] = (attack_collider.sweep_right_pivot.coll_init_scale[z] - attack_collider.sweep_right_pivot.coll_final_scale[z]) / attack.sweep_right.att_execution_duration

            attack_collider.sweep_right.coll_velocity[x] = (attack_collider.sweep_right.coll_final_pos[x] - attack_collider.sweep_right.coll_init_pos[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_velocity[y] = (attack_collider.sweep_right.coll_final_pos[y] - attack_collider.sweep_right.coll_init_pos[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_velocity[z] = (attack_collider.sweep_right.coll_final_pos[z] - attack_collider.sweep_right.coll_init_pos[z]) / attack.sweep_right.att_execution_duration
            attack_collider.sweep_right.coll_ang_velocity[x] = (attack_collider.sweep_right.coll_final_rot[x] - attack_collider.sweep_right.coll_init_rot[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_ang_velocity[y] = (attack_collider.sweep_right.coll_final_rot[y] - attack_collider.sweep_right.coll_init_rot[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_ang_velocity[z] = (attack_collider.sweep_right.coll_final_rot[z] - attack_collider.sweep_right.coll_init_rot[z]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_growth_velocity[x] = (attack_collider.sweep_right.coll_init_scale[x] - attack_collider.sweep_right.coll_final_scale[x]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_growth_velocity[y] = (attack_collider.sweep_right.coll_init_scale[y] - attack_collider.sweep_right.coll_final_scale[y]) / attack.sweep_right.att_execution_duration 
            attack_collider.sweep_right.coll_growth_velocity[z] = (attack_collider.sweep_right.coll_init_scale[z] - attack_collider.sweep_right.coll_final_scale[z]) / attack.sweep_right.att_execution_duration
            
            attack_collider.stomp.coll_velocity[x] = (attack_collider.stomp.coll_final_pos[x] - attack_collider.stomp.coll_init_pos[x]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_velocity[y] = (attack_collider.stomp.coll_final_pos[y] - attack_collider.stomp.coll_init_pos[y]) / attack.stomp.att_execution_duration
            attack_collider.stomp.coll_velocity[z] = (attack_collider.stomp.coll_final_pos[z] - attack_collider.stomp.coll_init_pos[z]) / attack.stomp.att_execution_duration
            attack_collider.stomp.coll_ang_velocity[x] = (attack_collider.stomp.coll_final_rot[x] - attack_collider.stomp.coll_init_rot[x]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_ang_velocity[y] = (attack_collider.stomp.coll_final_rot[y] - attack_collider.stomp.coll_init_rot[y]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_ang_velocity[z] = (attack_collider.stomp.coll_final_rot[z] - attack_collider.stomp.coll_init_rot[z]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_growth_velocity[x] = (attack_collider.stomp.coll_init_scale[x] - attack_collider.stomp.coll_final_scale[x]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_growth_velocity[y] = (attack_collider.stomp.coll_init_scale[y] - attack_collider.stomp.coll_final_scale[y]) / attack.stomp.att_execution_duration 
            attack_collider.stomp.coll_growth_velocity[z] = (attack_collider.stomp.coll_init_scale[z] - attack_collider.stomp.coll_final_scale[z]) / attack.stomp.att_execution_duration

            attack_collider.roar.coll_velocity[x] = (attack_collider.roar.coll_final_pos[x] - attack_collider.roar.coll_init_pos[x]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_velocity[y] = (attack_collider.roar.coll_final_pos[y] - attack_collider.roar.coll_init_pos[y]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_velocity[z] = (attack_collider.roar.coll_final_pos[z] - attack_collider.roar.coll_init_pos[z]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_ang_velocity[x] = (attack_collider.roar.coll_final_rot[x] - attack_collider.roar.coll_init_rot[x]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_ang_velocity[y] = (attack_collider.roar.coll_final_rot[y] - attack_collider.roar.coll_init_rot[y]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_ang_velocity[z] = (attack_collider.roar.coll_final_rot[z] - attack_collider.roar.coll_init_rot[z]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_growth_velocity[x] = (attack_collider.roar.coll_init_scale[x] - attack_collider.roar.coll_final_scale[x]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_growth_velocity[y] = (attack_collider.roar.coll_init_scale[y] - attack_collider.roar.coll_final_scale[y]) / attack.roar.att_execution_duration 
            attack_collider.roar.coll_growth_velocity[z] = (attack_collider.roar.coll_init_scale[z] - attack_collider.roar.coll_final_scale[z]) / attack.roar.att_execution_duration
        
            -- Partciles STOP
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.rage_aura_1.part_UID)
            -- Partciles PLAY
            lua_table.ParticlesFunctions:PlayParticleEmitter(particles.rage_aura_2.part_UID)
        end
    end
end

local function HandleRoarAttack()
    -- Handles Roar Attack

    --First only enters
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_ROAR
        attack_timer = game_time + attack.roar.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Roar Left Start")

        if current_attack_subdivision == attack_subdivision.TO_BE_DETERMINED
        then
            current_attack_subdivision = attack_subdivision.ANTICIPATION
            
            -- START ANTICIPATION OF ATTACK ANIMATION
            lua_table.AnimationFunctions:PlayAnimation(animation.roar_anticipation.anim_name, animation.roar_anticipation.anim_speed, my_UID) 
            
            attack_subdivision_timer = game_time + attack.roar.att_anticipation_duration 
        end
    end

    if current_attack_type == attack_type.ATTACKING_ROAR -- Checks if is started
    then
        -- ANTICIPATION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.ANTICIPATION 
        then
            if game_time > attack_subdivision_timer --Check if anticipation is finished
            then
                current_attack_subdivision = attack_subdivision.EXECUTION
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.roar_execution.anim_name, animation.roar_execution.anim_speed, my_UID)

                -- ACTIVATE PARTICLE
                lua_table.ParticlesFunctions:PlayParticleEmitter(particles.scream.part_UID)

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.roar.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.roar.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.roar.coll_current_pos[x] = attack_collider.roar.coll_init_pos[x]
                attack_collider.roar.coll_current_pos[y] = attack_collider.roar.coll_init_pos[y]
                attack_collider.roar.coll_current_pos[z] = attack_collider.roar.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.roar.coll_current_pos[x], attack_collider.roar.coll_current_pos[y], attack_collider.roar.coll_current_pos[z], attack_collider.roar.coll_UID)
                
                -- Sets collider current rotation to initial rotation
                attack_collider.roar.coll_current_rot[x] = attack_collider.roar.coll_init_rot[x]
                attack_collider.roar.coll_current_rot[y] = attack_collider.roar.coll_init_rot[y]
                attack_collider.roar.coll_current_rot[z] = attack_collider.roar.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.roar.coll_current_rot[x], attack_collider.roar.coll_current_rot[y], attack_collider.roar.coll_current_rot[z], attack_collider.roar.coll_UID)
            
                -- AUDIO PLAY
                lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_scream", my_UID)
            end
        end

        --EXECUTION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.EXECUTION
        then
            if game_time <= attack_subdivision_timer --Checks if ongoing
            then
                -- Sets damage
                lua_table.collider_damage = attack.roar.att_damage
                -- Sets effect
                lua_table.collider_effect = attack.roar.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time > attack_subdivision_timer --Check if execution is finished
            then
                current_attack_subdivision = attack_subdivision.RECOVERY
                
                -- START RECOVERY OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.roar_recovery.anim_name, animation.roar_execution.anim_speed, my_UID) 

                -- DEACTIVATE PARTICLE
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.scream.part_UID)

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.roar.att_recovery_duration

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.roar.coll_UID)
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                --attack.roar.att_cooldown_bool = true
                --attack.roar.att_timer = game_time + attack.roar.att_cooldown_time

                attack_finished = true
                attack_counter = attack_counter + 1

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

                lua_table.SystemFunctions:LOG ("Kikimora: Roar Left Finish")
            end
        end
    end
end

local function HandleStompAttack()
    -- Handles Stomp Attack

    --First only enters
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_STOMP
        attack_timer = game_time + attack.stomp.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Stomp Left Start")

        if current_attack_subdivision == attack_subdivision.TO_BE_DETERMINED
        then
            current_attack_subdivision = attack_subdivision.ANTICIPATION
            
            -- START ANTICIPATION OF ATTACK ANIMATION
            lua_table.AnimationFunctions:PlayAnimation(animation.stomp_anticipation.anim_name, animation.stomp_anticipation.anim_speed, my_UID)
            
            attack_subdivision_timer = game_time + attack.stomp.att_anticipation_duration 
        end
    end

    if current_attack_type == attack_type.ATTACKING_STOMP -- Checks if is started
    then
        -- ANTICIPATION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.ANTICIPATION 
        then
            if game_time > attack_subdivision_timer --Check if anticipation is finished
            then
                current_attack_subdivision = attack_subdivision.EXECUTION
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.stomp_execution.anim_name, animation.stomp_execution.anim_speed, my_UID)

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.stomp.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.stomp.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.stomp.coll_current_pos[x] = attack_collider.stomp.coll_init_pos[x]
                attack_collider.stomp.coll_current_pos[y] = attack_collider.stomp.coll_init_pos[y]
                attack_collider.stomp.coll_current_pos[z] = attack_collider.stomp.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.stomp.coll_current_pos[x], attack_collider.stomp.coll_current_pos[y], attack_collider.stomp.coll_current_pos[z], attack_collider.stomp.coll_UID)
                
                -- Sets collider current rotation to initial rotation
                attack_collider.stomp.coll_current_rot[x] = attack_collider.stomp.coll_init_rot[x]
                attack_collider.stomp.coll_current_rot[y] = attack_collider.stomp.coll_init_rot[y]
                attack_collider.stomp.coll_current_rot[z] = attack_collider.stomp.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.stomp.coll_current_rot[x], attack_collider.stomp.coll_current_rot[y], attack_collider.stomp.coll_current_rot[z], attack_collider.stomp.coll_UID)
            end
        end

        --EXECUTION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.EXECUTION
        then
            if game_time <= attack_subdivision_timer --Checks if ongoing
            then
                -- Updates current collider_pivot rotation (have to do it individually bc (*dt))
                attack_collider.stomp.coll_current_pos[x] = attack_collider.stomp.coll_current_pos[x] + attack_collider.stomp.coll_velocity[x] * dt
                attack_collider.stomp.coll_current_pos[y] = attack_collider.stomp.coll_current_pos[y] + attack_collider.stomp.coll_velocity[y] * dt
                attack_collider.stomp.coll_current_pos[z] = attack_collider.stomp.coll_current_pos[z] + attack_collider.stomp.coll_velocity[z] * dt

                lua_table.TransformFunctions:SetLocalPosition(attack_collider.stomp.coll_current_pos[x], attack_collider.stomp.coll_current_pos[y], attack_collider.stomp.coll_current_pos[z], attack_collider.stomp.coll_UID)

                -- Sets damage
                lua_table.collider_damage = attack.stomp.att_damage
                -- Sets effect
                lua_table.collider_effect = attack.stomp.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time >= attack_subdivision_timer and attack_tired_timer == -1 --Check if execution is finished
            then
                attack_tired_timer = game_time + lua_table.stomp_tired_time

                -- ACTIVATE PARTICLES
                lua_table.ParticlesFunctions:PlayParticleEmitter(particles.dustcloud_stomp_left.part_UID)
                lua_table.ParticlesFunctions:PlayParticleEmitter(particles.dustcloud_stomp_right.part_UID)

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)

                -- AUDIO PLAY
                lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_lash", my_UID)
            end

            if game_time >= attack_tired_timer and attack_tired_timer ~= -1--Check if execution is finished
            then
                attack_tired_timer = -1

                current_attack_subdivision = attack_subdivision.RECOVERY

                -- START RECOVERY OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.stomp_recovery.anim_name, animation.stomp_recovery.anim_speed, my_UID)
                
                -- Execution Timer
                attack_subdivision_timer = game_time + attack.stomp.att_recovery_duration    
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                --attack.stomp.att_cooldown_bool = true
                --attack.stomp.att_timer = game_time + attack.stomp.att_cooldown_time

                -- DEACTIVATE PARTICLES
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.dustcloud_stomp_left.part_UID)
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.dustcloud_stomp_right.part_UID)
                
                attack_finished = true
                attack_counter = attack_counter + 1

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

                lua_table.SystemFunctions:LOG ("Kikimora: Stomp Left Finish")
            end
        end
    end
end

local function HandleSweepAttack()
    -- Handles Sweep Attack

    --First only enters
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_SWEEP
        attack_timer = game_time + attack.sweep.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Sweep Start")

        if current_attack_subdivision == attack_subdivision.TO_BE_DETERMINED
        then
            current_attack_subdivision = attack_subdivision.ANTICIPATION
            
            -- START ANTICIPATION OF ATTACK ANIMATION
            lua_table.AnimationFunctions:PlayAnimation(animation.sweep_anticipation.anim_name, animation.sweep_anticipation.anim_speed, my_UID)
            
            attack_subdivision_timer = game_time + attack.sweep.att_anticipation_duration 
        end
    end

    if current_attack_type == attack_type.ATTACKING_SWEEP -- Checks if is started
    then
        -- ANTICIPATION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.ANTICIPATION 
        then
            if game_time > attack_subdivision_timer --Check if anticipation is finished
            then
                current_attack_subdivision = attack_subdivision.EXECUTION
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep_execution.anim_name, animation.sweep_execution.anim_speed, my_UID) 

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.sweep.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.sweep.coll_current_pos[x] = attack_collider.sweep.coll_init_pos[x]
                attack_collider.sweep.coll_current_pos[y] = attack_collider.sweep.coll_init_pos[y]
                attack_collider.sweep.coll_current_pos[z] = attack_collider.sweep.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.sweep.coll_current_pos[x], attack_collider.sweep.coll_current_pos[y], attack_collider.sweep.coll_current_pos[z], attack_collider.sweep.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.sweep.coll_current_rot[x] = attack_collider.sweep.coll_init_rot[x]
                attack_collider.sweep.coll_current_rot[y] = attack_collider.sweep.coll_init_rot[y]
                attack_collider.sweep.coll_current_rot[z] = attack_collider.sweep.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep.coll_current_rot[x], attack_collider.sweep.coll_current_rot[y], attack_collider.sweep.coll_current_rot[z], attack_collider.sweep.coll_UID)
                
                -- ACTIVATE PARTCLES 
                for i = 1, #particles.kiki_sweep_particle_left.part_childs do
                    lua_table.ParticlesFunctions:PlayParticleEmitter(particles.kiki_sweep_particle_left.part_childs[i])
                end

                -- AUDIO PLAY
                if current_phase == phase.CHILL
                then
                    lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_sweep", my_UID)
                elseif current_phase == phase.MAD
                then
                    lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_sweep_phase_2", my_UID)
                elseif current_phase == phase.ENRAGED
                then
                    lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_sweep_phase_3", my_UID)
                end
            end
        end

        --EXECUTION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.EXECUTION
        then
            if game_time <= attack_subdivision_timer --Checks if ongoing
            then
                -- Updates current collider_pivot rotation (have to do it individually bc (*dt))
                attack_collider.sweep.coll_current_pos[x] = attack_collider.sweep.coll_current_pos[x] + attack_collider.sweep.coll_velocity[x] * dt
                attack_collider.sweep.coll_current_pos[y] = attack_collider.sweep.coll_current_pos[y] + attack_collider.sweep.coll_velocity[y] * dt
                attack_collider.sweep.coll_current_pos[z] = attack_collider.sweep.coll_current_pos[z] + attack_collider.sweep.coll_velocity[z] * dt

                lua_table.TransformFunctions:SetLocalPosition(attack_collider.sweep.coll_current_pos[x], attack_collider.sweep.coll_current_pos[y], attack_collider.sweep.coll_current_pos[z], attack_collider.sweep.coll_UID)

                -- Sets damage
                lua_table.collider_damage = attack.sweep.att_damage
                -- Sets effect
                lua_table.collider_effect = attack.sweep.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time > attack_subdivision_timer --Check if execution is finished
            then
                current_attack_subdivision = attack_subdivision.RECOVERY
                
                -- START RECOVERY OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep_recovery.anim_name, animation.sweep_recovery.anim_speed, my_UID) 

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep.att_recovery_duration

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep.coll_UID)
            
                --DEACTIVATE PARTCLES 
                for i = 1, #particles.kiki_sweep_particle_left.part_childs do
                    lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_particle_left.part_childs[i])
                end
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                --attack.sweep_left.att_cooldown_bool = true
                --attack.sweep_left.att_timer = game_time + attack.sweep_left.att_cooldown_time

                attack_finished = true
                attack_counter = attack_counter + 1

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED
            end
        end
    end
end

local function HandleSweepLeftAttack()
    -- Handles Sweep Attack

    --First only enters
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_SWEEP_LEFT
        attack_timer = game_time + attack.sweep_left.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Sweep Left Start")

        if current_attack_subdivision == attack_subdivision.TO_BE_DETERMINED
        then
            current_attack_subdivision = attack_subdivision.ANTICIPATION
            
            -- START ANTICIPATION OF ATTACK ANIMATION
            lua_table.AnimationFunctions:PlayAnimation(animation.sweep_left_anticipation.anim_name, animation.sweep_left_anticipation.anim_speed, my_UID)
            
            attack_subdivision_timer = game_time + attack.sweep_left.att_anticipation_duration 
        end
    end

    if current_attack_type == attack_type.ATTACKING_SWEEP_LEFT -- Checks if is started
    then
        -- ANTICIPATION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.ANTICIPATION 
        then
            if game_time > attack_subdivision_timer --Check if anticipation is finished
            then
                current_attack_subdivision = attack_subdivision.EXECUTION
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep_left_execution.anim_name, animation.sweep_left_execution.anim_speed, my_UID) 

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_left.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.sweep_left.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.sweep_left_pivot.coll_current_pos[x] = attack_collider.sweep_left_pivot.coll_init_pos[x]
                attack_collider.sweep_left_pivot.coll_current_pos[y] = attack_collider.sweep_left_pivot.coll_init_pos[y]
                attack_collider.sweep_left_pivot.coll_current_pos[z] = attack_collider.sweep_left_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.sweep_left_pivot.coll_current_pos[x], attack_collider.sweep_left_pivot.coll_current_pos[y], attack_collider.sweep_left_pivot.coll_current_pos[z], attack_collider.sweep_left_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.sweep_left_pivot.coll_current_rot[x] = attack_collider.sweep_left_pivot.coll_init_rot[x]
                attack_collider.sweep_left_pivot.coll_current_rot[y] = attack_collider.sweep_left_pivot.coll_init_rot[y]
                attack_collider.sweep_left_pivot.coll_current_rot[z] = attack_collider.sweep_left_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_left_pivot.coll_current_rot[x], attack_collider.sweep_left_pivot.coll_current_rot[y], attack_collider.sweep_left_pivot.coll_current_rot[z], attack_collider.sweep_left_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_left.coll_current_pos[x] = attack_collider.sweep_left.coll_init_pos[x]
                attack_collider.sweep_left.coll_current_pos[y] = attack_collider.sweep_left.coll_init_pos[y]
                attack_collider.sweep_left.coll_current_pos[z] = attack_collider.sweep_left.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.sweep_left.coll_current_pos[x], attack_collider.sweep_left.coll_current_pos[y], attack_collider.sweep_left.coll_current_pos[z], attack_collider.sweep_left.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_left.coll_current_rot[x] = attack_collider.sweep_left.coll_init_rot[x]
                attack_collider.sweep_left.coll_current_rot[y] = attack_collider.sweep_left.coll_init_rot[y]
                attack_collider.sweep_left.coll_current_rot[z] = attack_collider.sweep_left.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_left.coll_current_rot[x], attack_collider.sweep_left.coll_current_rot[y], attack_collider.sweep_left.coll_current_rot[z], attack_collider.sweep_left.coll_UID)
                
                -- ACTIVATE PARTCLES 
                for i = 1, #particles.kiki_sweep_left_particle.part_childs do
                    lua_table.ParticlesFunctions:PlayParticleEmitter(particles.kiki_sweep_left_particle.part_childs[i])
                end

                -- AUDIO PLAY
                lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_sweep", my_UID)

            end
        end

        --EXECUTION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.EXECUTION
        then
            if game_time <= attack_subdivision_timer --Checks if ongoing
            then
                -- Updates current collider_pivot rotation (have to do it individually bc (*dt))
                attack_collider.sweep_left_pivot.coll_current_rot[x] = attack_collider.sweep_left_pivot.coll_current_rot[x] + attack_collider.sweep_left_pivot.coll_ang_velocity[x] * dt
                attack_collider.sweep_left_pivot.coll_current_rot[y] = attack_collider.sweep_left_pivot.coll_current_rot[y] + attack_collider.sweep_left_pivot.coll_ang_velocity[y] * dt
                attack_collider.sweep_left_pivot.coll_current_rot[z] = attack_collider.sweep_left_pivot.coll_current_rot[z] + attack_collider.sweep_left_pivot.coll_ang_velocity[z] * dt

                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_left_pivot.coll_current_rot[x], attack_collider.sweep_left_pivot.coll_current_rot[y], attack_collider.sweep_left_pivot.coll_current_rot[z], attack_collider.sweep_left_pivot.coll_UID)

                -- Sets damage
                lua_table.collider_damage = attack.sweep_left.att_damage
                -- Sets effect
                lua_table.collider_effect = attack.sweep_left.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time > attack_subdivision_timer --Check if execution is finished
            then
                current_attack_subdivision = attack_subdivision.RECOVERY
                
                -- START RECOVERY OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep_left_recovery.anim_name, animation.sweep_left_recovery.anim_speed, my_UID) 

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_left.att_recovery_duration

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
                
                -- DEACTIVATE PARTCLES
                for i = 1, #particles.kiki_sweep_left_particle.part_childs do
                    lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_left_particle.part_childs[i])
                end
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                --attack.sweep_left.att_cooldown_bool = true
                --attack.sweep_left.att_timer = game_time + attack.sweep_left.att_cooldown_time

                attack_finished = true
                attack_counter = attack_counter + 1

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

                lua_table.SystemFunctions:LOG ("Kikimora: Sweep Left Finish")
            end
        end
    end
end

local function HandleSweepRightAttack()
    -- Handles Sweep Attack
    
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_SWEEP_RIGHT
        attack_timer = game_time + attack.sweep_right.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Sweep Right Start")

        if current_attack_subdivision == attack_subdivision.TO_BE_DETERMINED
        then
            current_attack_subdivision = attack_subdivision.ANTICIPATION
            
            -- START ANTICIPATION OF ATTACK ANIMATION
            lua_table.AnimationFunctions:PlayAnimation(animation.sweep_right_anticipation.anim_name, animation.sweep_right_anticipation.anim_speed, my_UID)
            
            -- Anticipation Timer
            attack_subdivision_timer = game_time + attack.sweep_right.att_anticipation_duration 
        end
    end

    if current_attack_type == attack_type.ATTACKING_SWEEP_RIGHT -- Checks if is started
    then
        -- ANTICIPATION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.ANTICIPATION 
        then
            if game_time > attack_subdivision_timer --Check if anticipation is finished
            then
                current_attack_subdivision = attack_subdivision.EXECUTION
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep_right_execution.anim_name, animation.sweep_right_execution.anim_speed, my_UID)

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_right.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.sweep_right.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.sweep_right_pivot.coll_current_pos[x] = attack_collider.sweep_right_pivot.coll_init_pos[x]
                attack_collider.sweep_right_pivot.coll_current_pos[y] = attack_collider.sweep_right_pivot.coll_init_pos[y]
                attack_collider.sweep_right_pivot.coll_current_pos[z] = attack_collider.sweep_right_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.sweep_right_pivot.coll_current_pos[x], attack_collider.sweep_right_pivot.coll_current_pos[y], attack_collider.sweep_right_pivot.coll_current_pos[z], attack_collider.sweep_right_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.sweep_right_pivot.coll_current_rot[x] = attack_collider.sweep_right_pivot.coll_init_rot[x]
                attack_collider.sweep_right_pivot.coll_current_rot[y] = attack_collider.sweep_right_pivot.coll_init_rot[y]
                attack_collider.sweep_right_pivot.coll_current_rot[z] = attack_collider.sweep_right_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_right_pivot.coll_current_rot[x], attack_collider.sweep_right_pivot.coll_current_rot[y], attack_collider.sweep_right_pivot.coll_current_rot[z], attack_collider.sweep_right_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_right.coll_current_pos[x] = attack_collider.sweep_right.coll_init_pos[x]
                attack_collider.sweep_right.coll_current_pos[y] = attack_collider.sweep_right.coll_init_pos[y]
                attack_collider.sweep_right.coll_current_pos[z] = attack_collider.sweep_right.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.sweep_right.coll_current_pos[x], attack_collider.sweep_right.coll_current_pos[y], attack_collider.sweep_right.coll_current_pos[z], attack_collider.sweep_right.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_right.coll_current_rot[x] = attack_collider.sweep_right.coll_init_rot[x]
                attack_collider.sweep_right.coll_current_rot[y] = attack_collider.sweep_right.coll_init_rot[y]
                attack_collider.sweep_right.coll_current_rot[z] = attack_collider.sweep_right.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_right.coll_current_rot[x], attack_collider.sweep_right.coll_current_rot[y], attack_collider.sweep_right.coll_current_rot[z], attack_collider.sweep_right.coll_UID)
                
                -- ACTIVATE PARTCLES 
                for i = 1, #particles.kiki_sweep_right_particle.part_childs do
                    lua_table.ParticlesFunctions:PlayParticleEmitter(particles.kiki_sweep_right_particle.part_childs[i])
                end

                -- AUDIO PLAY
                lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_sweep", my_UID)
            end
        end

        --EXECUTION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.EXECUTION
        then
            if game_time <= attack_subdivision_timer --Checks if ongoing
            then
                -- Updates current collider_pivot rotation (have to do it individually bc (*dt))
                attack_collider.sweep_right_pivot.coll_current_rot[x] = attack_collider.sweep_right_pivot.coll_current_rot[x] + attack_collider.sweep_right_pivot.coll_ang_velocity[x] * dt
                attack_collider.sweep_right_pivot.coll_current_rot[y] = attack_collider.sweep_right_pivot.coll_current_rot[y] + attack_collider.sweep_right_pivot.coll_ang_velocity[y] * dt
                attack_collider.sweep_right_pivot.coll_current_rot[z] = attack_collider.sweep_right_pivot.coll_current_rot[z] + attack_collider.sweep_right_pivot.coll_ang_velocity[z] * dt

                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_right_pivot.coll_current_rot[x], attack_collider.sweep_right_pivot.coll_current_rot[y], attack_collider.sweep_right_pivot.coll_current_rot[z], attack_collider.sweep_right_pivot.coll_UID)

                -- Sets damage
                lua_table.collider_damage = attack.sweep_right.att_damage
                
                -- Sets effect
                lua_table.collider_effect = attack.sweep_right.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time > attack_subdivision_timer --Check if execution is finished
            then
                current_attack_subdivision = attack_subdivision.RECOVERY
                
                -- START RECOVERY OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep_right_recovery.anim_name, animation.sweep_right_recovery.anim_speed, my_UID)

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_right.att_recovery_duration

                -- Deactivates Collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
           
                -- DEACTIVATE PARTCLES 
                for i = 1, #particles.kiki_sweep_right_particle.part_childs do
                    lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_right_particle.part_childs[i])
                end
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                --attack.sweep_right.att_cooldown_bool = true
                --attack.sweep_right.att_timer = game_time + attack.sweep_right.att_cooldown_time

                attack_finished = true
                attack_counter = attack_counter + 1

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

                lua_table.SystemFunctions:LOG ("Kikimora: Sweep Right Finish")
            end
        end
    end
end

local function HandleLeashLeftAttack()
    -- Handles Leash Attack

    --First only enters
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_LEASH_LEFT
        attack_timer = game_time + attack.leash_left.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Leash Left Start")

        if current_attack_subdivision == attack_subdivision.TO_BE_DETERMINED
        then
            current_attack_subdivision = attack_subdivision.ANTICIPATION
            
            -- START ANTICIPATION OF ATTACK ANIMATION
            lua_table.AnimationFunctions:PlayAnimation(animation.leash_left_anticipation.anim_name, animation.leash_left_anticipation.anim_speed, my_UID)
            
            attack_subdivision_timer = game_time + attack.leash_left.att_anticipation_duration 
        end
    end

    if current_attack_type == attack_type.ATTACKING_LEASH_LEFT -- Checks if is started
    then
        -- ANTICIPATION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.ANTICIPATION 
        then
            if game_time > attack_subdivision_timer --Check if anticipation is finished
            then
                current_attack_subdivision = attack_subdivision.EXECUTION
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.leash_left_execution.anim_name, animation.leash_left_execution.anim_speed, my_UID)

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_left.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.leash_left.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.leash_left_pivot.coll_current_pos[x] = attack_collider.leash_left_pivot.coll_init_pos[x]
                attack_collider.leash_left_pivot.coll_current_pos[y] = attack_collider.leash_left_pivot.coll_init_pos[y]
                attack_collider.leash_left_pivot.coll_current_pos[z] = attack_collider.leash_left_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.leash_left_pivot.coll_current_pos[x], attack_collider.leash_left_pivot.coll_current_pos[y], attack_collider.leash_left_pivot.coll_current_pos[z], attack_collider.leash_left_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.leash_left_pivot.coll_current_rot[x] = attack_collider.leash_left_pivot.coll_init_rot[x]
                attack_collider.leash_left_pivot.coll_current_rot[y] = attack_collider.leash_left_pivot.coll_init_rot[y]
                attack_collider.leash_left_pivot.coll_current_rot[z] = attack_collider.leash_left_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_left_pivot.coll_current_rot[x], attack_collider.leash_left_pivot.coll_current_rot[y], attack_collider.leash_left_pivot.coll_current_rot[z], attack_collider.leash_left_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.leash_left.coll_current_pos[x] = attack_collider.leash_left.coll_init_pos[x]
                attack_collider.leash_left.coll_current_pos[y] = attack_collider.leash_left.coll_init_pos[y]
                attack_collider.leash_left.coll_current_pos[z] = attack_collider.leash_left.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.leash_left.coll_current_pos[x], attack_collider.leash_left.coll_current_pos[y], attack_collider.leash_left.coll_current_pos[z], attack_collider.leash_left.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.leash_left.coll_current_rot[x] = attack_collider.leash_left.coll_init_rot[x]
                attack_collider.leash_left.coll_current_rot[y] = attack_collider.leash_left.coll_init_rot[y]
                attack_collider.leash_left.coll_current_rot[z] = attack_collider.leash_left.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_left.coll_current_rot[x], attack_collider.leash_left.coll_current_rot[y], attack_collider.leash_left.coll_current_rot[z], attack_collider.leash_left.coll_UID)     
            end
        end

        --EXECUTION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.EXECUTION
        then
            if game_time <= attack_subdivision_timer --Checks if ongoing
            then
                -- Updates current collider_pivot rotation (have to do it individually bc (*dt))
                attack_collider.leash_left_pivot.coll_current_rot[x] = attack_collider.leash_left_pivot.coll_current_rot[x] + attack_collider.leash_left_pivot.coll_ang_velocity[x] * dt
                attack_collider.leash_left_pivot.coll_current_rot[y] = attack_collider.leash_left_pivot.coll_current_rot[y] + attack_collider.leash_left_pivot.coll_ang_velocity[y] * dt
                attack_collider.leash_left_pivot.coll_current_rot[z] = attack_collider.leash_left_pivot.coll_current_rot[z] + attack_collider.leash_left_pivot.coll_ang_velocity[z] * dt

                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_left_pivot.coll_current_rot[x], attack_collider.leash_left_pivot.coll_current_rot[y], attack_collider.leash_left_pivot.coll_current_rot[z], attack_collider.leash_left_pivot.coll_UID)

                -- Sets damage
                lua_table.collider_damage = attack.leash_left.att_damage
                -- Sets effect
                lua_table.collider_effect = attack.leash_left.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time >= attack_subdivision_timer and attack_tired_timer == -1 --Check if execution is finished
            then
                attack_tired_timer = game_time + lua_table.leash_tired_time
                
                -- ACTIVATE PARTICLES
                lua_table.ParticlesFunctions:PlayParticleEmitter(particles.dustcloud_leash_left.part_UID)

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)

                -- AUDIO PLAY
                lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_lash", my_UID)
            end

            if game_time >= attack_tired_timer and attack_tired_timer ~= -1--Check if execution is finished
            then
                attack_tired_timer = -1
                current_attack_subdivision = attack_subdivision.RECOVERY

                -- START RECOVERY OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.leash_left_recovery.anim_name, animation.leash_left_recovery.anim_speed, my_UID)
                
                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_left.att_recovery_duration
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                --attack.leash_left.att_cooldown_bool = true
                --attack.leash_left.att_timer = game_time + attack.leash_left.att_cooldown_time

                -- DEACTIVATE PARTICLES
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.dustcloud_leash_left.part_UID)

                attack_finished = true
                attack_counter = attack_counter + 1

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED
            end
        end
    end
end

local function HandleLeashRightAttack()
    -- Handles Leash Attack
    
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_LEASH_RIGHT
        attack_timer = game_time + attack.leash_right.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Leash Right Start")

        if current_attack_subdivision == attack_subdivision.TO_BE_DETERMINED
        then
            current_attack_subdivision = attack_subdivision.ANTICIPATION
            
            -- START ANTICIPATION OF ATTACK ANIMATION
            lua_table.AnimationFunctions:PlayAnimation(animation.leash_right_anticipation.anim_name, animation.leash_right_anticipation.anim_speed, my_UID)
            
            -- Anticipation Timer
            attack_subdivision_timer = game_time + attack.leash_right.att_anticipation_duration 
        end
    end

    if current_attack_type == attack_type.ATTACKING_LEASH_RIGHT -- Checks if is started
    then
        -- ANTICIPATION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.ANTICIPATION 
        then
            if game_time > attack_subdivision_timer --Check if anticipation is finished
            then
                current_attack_subdivision = attack_subdivision.EXECUTION
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.leash_right_execution.anim_name, animation.leash_right_execution.anim_speed, my_UID)

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_right.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.leash_right.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.leash_right_pivot.coll_current_pos[x] = attack_collider.leash_right_pivot.coll_init_pos[x]
                attack_collider.leash_right_pivot.coll_current_pos[y] = attack_collider.leash_right_pivot.coll_init_pos[y]
                attack_collider.leash_right_pivot.coll_current_pos[z] = attack_collider.leash_right_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.leash_right_pivot.coll_current_pos[x], attack_collider.leash_right_pivot.coll_current_pos[y], attack_collider.leash_right_pivot.coll_current_pos[z], attack_collider.leash_right_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.leash_right_pivot.coll_current_rot[x] = attack_collider.leash_right_pivot.coll_init_rot[x]
                attack_collider.leash_right_pivot.coll_current_rot[y] = attack_collider.leash_right_pivot.coll_init_rot[y]
                attack_collider.leash_right_pivot.coll_current_rot[z] = attack_collider.leash_right_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_right_pivot.coll_current_rot[x], attack_collider.leash_right_pivot.coll_current_rot[y], attack_collider.leash_right_pivot.coll_current_rot[z], attack_collider.leash_right_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.leash_right.coll_current_pos[x] = attack_collider.leash_right.coll_init_pos[x]
                attack_collider.leash_right.coll_current_pos[y] = attack_collider.leash_right.coll_init_pos[y]
                attack_collider.leash_right.coll_current_pos[z] = attack_collider.leash_right.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetLocalPosition(attack_collider.leash_right.coll_current_pos[x], attack_collider.leash_right.coll_current_pos[y], attack_collider.leash_right.coll_current_pos[z], attack_collider.leash_right.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.leash_right.coll_current_rot[x] = attack_collider.leash_right.coll_init_rot[x]
                attack_collider.leash_right.coll_current_rot[y] = attack_collider.leash_right.coll_init_rot[y]
                attack_collider.leash_right.coll_current_rot[z] = attack_collider.leash_right.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_right.coll_current_rot[x], attack_collider.leash_right.coll_current_rot[y], attack_collider.leash_right.coll_current_rot[z], attack_collider.leash_right.coll_UID)

            end
        end

        --EXECUTION SUBDIVISION
        if current_attack_subdivision == attack_subdivision.EXECUTION
        then
            if game_time <= attack_subdivision_timer --Checks if ongoing
            then
                -- Updates current collider_pivot rotation (have to do it individually bc (*dt))
                attack_collider.leash_right_pivot.coll_current_rot[x] = attack_collider.leash_right_pivot.coll_current_rot[x] + attack_collider.leash_right_pivot.coll_ang_velocity[x] * dt
                attack_collider.leash_right_pivot.coll_current_rot[y] = attack_collider.leash_right_pivot.coll_current_rot[y] + attack_collider.leash_right_pivot.coll_ang_velocity[y] * dt
                attack_collider.leash_right_pivot.coll_current_rot[z] = attack_collider.leash_right_pivot.coll_current_rot[z] + attack_collider.leash_right_pivot.coll_ang_velocity[z] * dt

                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_right_pivot.coll_current_rot[x], attack_collider.leash_right_pivot.coll_current_rot[y], attack_collider.leash_right_pivot.coll_current_rot[z], attack_collider.leash_right_pivot.coll_UID)

                -- Sets damage
                lua_table.collider_damage = attack.leash_right.att_damage
                
                -- Sets effect
                lua_table.collider_effect = attack.leash_right.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time >= attack_subdivision_timer and attack_tired_timer == -1 --Check if execution is finished
            then
                attack_tired_timer = game_time + lua_table.leash_tired_time

                -- ACTIVATE PARTICLES
                lua_table.ParticlesFunctions:PlayParticleEmitter(particles.dustcloud_leash_right.part_UID)
            end

            if game_time >= attack_tired_timer and attack_tired_timer ~= -1--Check if execution is finished
            then
                attack_tired_timer = -1

                current_attack_subdivision = attack_subdivision.RECOVERY
                
                -- START EXECUTION OF ATTACK ANIMATION
                lua_table.AnimationFunctions:PlayAnimation(animation.leash_right_recovery.anim_name, animation.leash_right_recovery.anim_speed, my_UID)
                
                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_right.att_recovery_duration

                -- Deactivates Collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)

                -- DEACTIVATE PARTICLES
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.dustcloud_leash_right.part_UID)

                -- AUDIO PLAY
                lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_lash", my_UID)   
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                --attack.leash_right.att_cooldown_bool = true
                --attack.leash_right.att_timer = game_time + attack.leash_right.att_cooldown_time
                
                attack_finished = true
                attack_counter = attack_counter + 1

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED      
            end
        end
    end
end

local function HandleAttacks()

    -- For now kikimora will always want to attack (except when all attacks are on cooldown)
    if current_state~= state.JUMPING and current_state ~= state.ATTACKING and current_state ~= state.AWAKENING and current_state ~= state.SWAPPING_PHASE and current_state ~= state.UNACTIVE and current_state ~= state.DEAD
    then
        if current_attack_pattern == attack_pattern.TO_BE_DETERMINED and attack_pattern_cooldown_bool == false
        then
            randy = math.random(1,3)

            if randy == 1
            then
                current_attack_pattern = attack_pattern.PATTERN_STOMPY

            elseif randy == 2
            then
                current_attack_pattern = attack_pattern.PATTERN_SIDE_TO_SIDE

            elseif randy == 3
            then
                current_attack_pattern = attack_pattern.SCREAM_SWEEP

            end

            if current_attack_pattern == attack_pattern.PATTERN_STOMPY
            then
                current_state = state.ATTACKING
                HandleStompAttack() -- The first attack of the pattern
                attack_counter = 0
    
            elseif current_attack_pattern == attack_pattern.PATTERN_SIDE_TO_SIDE
            then
                current_state = state.ATTACKING
                HandleLeashLeftAttack() -- The first attack of the pattern
                attack_counter = 0

            elseif current_attack_pattern == attack_pattern.SCREAM_SWEEP
            then
                current_state = state.ATTACKING
                HandleRoarAttack() -- The first attack of the pattern
                attack_counter = 0
    
            end
        end

    elseif current_state == state.ATTACKING -- if already attacking
    then
        if current_attack_pattern == attack_pattern.PATTERN_STOMPY
        then 
            if attack_counter == 0
            then
                HandleStompAttack()

            elseif attack_counter == 1
            then
                HandleSweepLeftAttack()

            elseif attack_counter == 2
            then
                HandleSweepRightAttack()

            elseif attack_counter == 3
            then
                HandleStompAttack()

            elseif attack_counter == 4
            then
                attack_pattern_cooldown_bool = true
                attack_pattern_timer = game_time + attack_pattern_cooldown

                current_attack_pattern = attack_pattern.TO_BE_DETERMINED
            end
            
        elseif current_attack_pattern == attack_pattern.PATTERN_SIDE_TO_SIDE
        then
            if attack_counter == 0
            then
                HandleLeashLeftAttack()

            elseif attack_counter == 1
            then
                HandleSweepRightAttack()

            elseif attack_counter == 2
            then
                HandleSweepLeftAttack()

            elseif attack_counter == 3
            then
                HandleLeashRightAttack()

            elseif attack_counter == 4
            then
                attack_pattern_cooldown_bool = true
                attack_pattern_timer = game_time + attack_pattern_cooldown

                current_attack_pattern = attack_pattern.TO_BE_DETERMINED
            end

        elseif current_attack_pattern == attack_pattern.SCREAM_SWEEP
        then
            if attack_counter == 0
            then
                HandleRoarAttack()

            elseif attack_counter == 1
            then
                HandleSweepAttack()

            elseif attack_counter == 2
            then
                attack_pattern_cooldown_bool = true
                attack_pattern_timer = game_time + attack_pattern_cooldown

                current_attack_pattern = attack_pattern.TO_BE_DETERMINED
            end
        end
    end

    -- Updating cooldowns
    if attack_pattern_cooldown_bool == true
    then
        if game_time >= attack_pattern_timer
        then
            attack_pattern_cooldown_bool = false
        end
    end
end

local function HandleJump()

    -- First entry only
    if start_jumping == true
    then
        -- Resetting stats
        current_attack_pattern = attack_pattern.TO_BE_DETERMINED
        current_attack_type = attack_type.TO_BE_DETERMINED
        current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

        -- Setting colliders unactive
        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)
        attack_collider.stomp.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep.coll_UID)
        attack_collider.sweep.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
        attack_collider.sweep_left.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
        attack_collider.sweep_right.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)
        attack_collider.leash_left.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)
        attack_collider.leash_right.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.roar.coll_UID)
        attack_collider.roar.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.jump.coll_UID)
        attack_collider.jump.coll_active = false

        -- Particles STOP (ATTACKS ONLY)
        lua_table.ParticlesFunctions:StopParticleEmitter(particles.scream.part_UID) 
        for i = 1, #particles.kiki_sweep_particle_left.part_childs do
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_particle_left.part_childs[i])
        end
        for i = 1, #particles.kiki_sweep_particle_right.part_childs do
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_particle_right.part_childs[i])
        end
        for i = 1, #particles.kiki_sweep_left_particle.part_childs do
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_left_particle.part_childs[i])
        end
        
        start_jumping = false

        lua_table.AnimationFunctions:PlayAnimation(animation.jump.anim_name, animation.jump.anim_speed, my_UID)

        current_jumping_state = jumping_state.UPWARDS

        local jump_duration = animation.jump.anim_frames / animation.jump.anim_speed

        jump_timer_up = game_time + jump_duration + lua_table.jump_delay_up
        jump_timer_down = game_time + jump_duration + lua_table.jump_delay_up + lua_table.jump_delay_down
    end

    -- When finishes upwards movement
    if game_time >= jump_timer_up and current_jumping_state == jumping_state.UPWARDS
    then

        if current_jumping_position == jumping_position.FRONT
        then
            randy = math.random(1,2)
            
            if randy == 1 -- Jumping Left Side
            then
                current_jumping_position = jumping_position.LEFT_SIDE

                -- Get my position
                lua_table.TransformFunctions:SetPosition(lua_table.jump_pos_2[x], lua_table.jump_pos_2[y], lua_table.jump_pos_2[z], my_UID)
                lua_table.my_position = lua_table.jump_pos_2

                -- Get my rotation
                lua_table.TransformFunctions:SetObjectRotation(lua_table.jump_rot_2[x], lua_table.jump_rot_2[y], lua_table.jump_rot_2[z], my_UID)
                lua_table.my_rotation = lua_table.jump_rot_2

                -- Set Camera Orientation
                lua_table.camera_script.camera_orientation = lua_table.jump_rot_2[y]
                
            elseif randy == 2 -- Jumping Right Side
            then
                current_jumping_position = jumping_position.RIGHT_SIDE

                -- Get my position
                lua_table.TransformFunctions:SetPosition(lua_table.jump_pos_3[x], lua_table.jump_pos_3[y], lua_table.jump_pos_3[z], my_UID)
                lua_table.my_position = lua_table.jump_pos_3

                -- Get my rotation
                lua_table.TransformFunctions:SetObjectRotation(lua_table.jump_rot_3[x], lua_table.jump_rot_3[y], lua_table.jump_rot_3[z], my_UID)
                lua_table.my_rotation = lua_table.jump_rot_3

                -- Set Camera Orientation
                lua_table.camera_script.camera_orientation = lua_table.jump_rot_3[y]
            end

        elseif current_jumping_position == jumping_position.LEFT_SIDE
        then
            randy = math.random(1,2)
            
            if randy == 1 -- Jumping Front Side
            then
                current_jumping_position = jumping_position.FRONT

                -- Get my position
                lua_table.TransformFunctions:SetPosition(lua_table.jump_pos_1[x], lua_table.jump_pos_1[y], lua_table.jump_pos_1[z], my_UID)
                lua_table.my_position = lua_table.jump_pos_1

                -- Get my rotation
                lua_table.TransformFunctions:SetObjectRotation(lua_table.jump_rot_1[x], lua_table.jump_rot_1[y], lua_table.jump_rot_1[z], my_UID)
                lua_table.my_rotation = lua_table.jump_rot_1

                -- Set Camera Orientation
                lua_table.camera_script.camera_orientation = lua_table.jump_rot_1[y]
                
            elseif randy == 2 -- Jumping Right Side
            then
                current_jumping_position = jumping_position.RIGHT_SIDE

                -- Get my position
                lua_table.TransformFunctions:SetPosition(lua_table.jump_pos_3[x], lua_table.jump_pos_3[y], lua_table.jump_pos_3[z], my_UID)
                lua_table.my_position = lua_table.jump_pos_3

                -- Get my rotation
                lua_table.TransformFunctions:SetObjectRotation(lua_table.jump_rot_3[x], lua_table.jump_rot_3[y], lua_table.jump_rot_3[z], my_UID)
                lua_table.my_rotation = lua_table.jump_rot_3

                -- Set Camera Orientation
                lua_table.camera_script.camera_orientation = lua_table.jump_rot_3[y]
            end

        elseif current_jumping_position == jumping_position.RIGHT_SIDE
        then
            randy = math.random(1,2)
            
            if randy == 1 -- Jumping Left Side
            then
                current_jumping_position = jumping_position.LEFT_SIDE

                -- Get my position
                lua_table.TransformFunctions:SetPosition(lua_table.jump_pos_2[x], lua_table.jump_pos_2[y], lua_table.jump_pos_2[z], my_UID)
                lua_table.my_position = lua_table.jump_pos_2

                -- Get my rotation
                lua_table.TransformFunctions:SetObjectRotation(lua_table.jump_rot_2[x], lua_table.jump_rot_2[y], lua_table.jump_rot_2[z], my_UID)
                lua_table.my_rotation = lua_table.jump_rot_2

                -- Set Camera Orientation
                lua_table.camera_script.camera_orientation = lua_table.jump_rot_2[y]
                
            elseif randy == 2 -- Jumping Front Side
            then
                current_jumping_position = jumping_position.FRONT

                -- Get my position
                lua_table.TransformFunctions:SetPosition(lua_table.jump_pos_1[x], lua_table.jump_pos_1[y], lua_table.jump_pos_1[z], my_UID)
                lua_table.my_position = lua_table.jump_pos_1

                -- Get my rotation
                lua_table.TransformFunctions:SetObjectRotation(lua_table.jump_rot_1[x], lua_table.jump_rot_1[y], lua_table.jump_rot_1[z], my_UID)
                lua_table.my_rotation = lua_table.jump_rot_1

                -- Set Camera Orientation
                lua_table.camera_script.camera_orientation = lua_table.jump_rot_1[y]
            end
        end
        current_jumping_state = jumping_state.LEVITATING

        -- Partciles PLAY
        for i = 1, #particles.jump_area.part_childs do
            lua_table.ParticlesFunctions:PlayParticleEmitter(particles.jump_area.part_childs[i])
        end
    end

    -- When starts falling
    if game_time >= jump_timer_down and current_jumping_state == jumping_state.LEVITATING
    then
        lua_table.AnimationFunctions:PlayAnimation(animation.awakening.anim_name, animation.awakening.anim_speed, my_UID)

        current_jumping_state = jumping_state.DOWNWARDS

        local awakening_duration = animation.awakening.anim_frames / animation.awakening.anim_speed

        animation_timer = game_time + awakening_timer

        jump_timer = game_time + awakening_duration

        -- Partciles STOP
        for i = 1, #particles.jump_area.part_childs do
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.jump_area.part_childs[i])
        end
    end

    -- When Hits the ground
    if game_time >= animation_timer + 0.5 and awakening_audio_played == false
    then
        awakening_audio_played = true

        -- Sets damage
        lua_table.collider_damage = attack.jump.att_damage
        -- Sets effect
        lua_table.collider_effect = attack.jump.att_effect

        -- Collider active
        lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.jump.coll_UID)
        attack_collider.jump.coll_active = true

        -- AUDIO PLAY
        lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_damaged", my_UID)
    end

    -- When finishes downwards movement animation
    if game_time >= jump_timer and current_jumping_state == jumping_state.DOWNWARDS
    then
        current_jumping_state = jumping_state.TO_BE_DETERMINED

        finish_jumping = true
        awakening_audio_played = false

        -- Collider unactive
        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.jump.coll_UID)
        attack_collider.jump.coll_active = false
    end
end

local function HandleHits()
    
    got_hit = false

    -- Hit (Legs)
    if lua_table.hits_received > 0
    then
        for i = lua_table.hits_received, 0, -1 do
            lua_table.hits_received = lua_table.hits_received - 1
            lua_table.current_health = lua_table.current_health - lua_table.damage_received
        end
            -- AUDIO PLAY
        lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_damaged", my_UID)

        got_hit = true
    end
    
    -- Critical hit (Head)
    if lua_table.critical_hits_received > 0
    then 
        for i = lua_table.critical_hits_received, 0, -1 do
            lua_table.critical_hits_received = lua_table.critical_hits_received - 1
            lua_table.current_health = lua_table.current_health - (lua_table.damage_received * lua_table.damage_received_mod)
        end

        -- AUDIO PLAY
        lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_damaged", my_UID)

        -- Partciles PLAY
        for i = 1, #particles.head_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.head_blood_hit.part_childs[i])
        end
        got_hit = true
    end

    if got_hit == true
    then
        lua_table.MaterialsFunctions:SetMaterialByName(lua_table.hit_material_GO, my_mesh_UID)

        hit_material_timer = game_time + lua_table.hit_time
    end

    if game_time >= hit_material_timer
    then
        lua_table.MaterialsFunctions:SetMaterialByName(lua_table.my_material_GO, my_mesh_UID)
    end
    
    -- Left Legs Particle Emmiters PLAY
    if lua_table.left_leg_1_hit == true
    then
        lua_table.left_leg_1_hit = false
        for i = 1, #particles.left_leg_1_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.left_leg_1_blood_hit.part_childs[i])
	    end
    end
    if lua_table.left_leg_2_hit == true
    then
        lua_table.left_leg_2_hit = false
        for i = 1, #particles.left_leg_2_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.left_leg_2_blood_hit.part_childs[i])
	    end
    end
    if lua_table.left_leg_3_hit == true
    then
        lua_table.left_leg_3_hit = false
        for i = 1, #particles.left_leg_3_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.left_leg_3_blood_hit.part_childs[i])
	    end
    end
    if lua_table.left_leg_4_hit == true
    then
        lua_table.left_leg_4_hit = false
        for i = 1, #particles.left_leg_4_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.left_leg_4_blood_hit.part_childs[i])
	    end
    end

    -- Right Legs Particle Emmiters PLAY
    if lua_table.right_leg_1_hit == true
    then
        lua_table.right_leg_1_hit = false
        for i = 1, #particles.right_leg_1_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.right_leg_1_blood_hit.part_childs[i])
	    end
    end
    if lua_table.right_leg_2_hit == true
    then
        lua_table.right_leg_2_hit = false
        for i = 1, #particles.right_leg_2_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.right_leg_2_blood_hit.part_childs[i])
	    end
    end
    if lua_table.right_leg_3_hit == true
    then
        lua_table.right_leg_3_hit = false
        for i = 1, #particles.right_leg_3_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.right_leg_3_blood_hit.part_childs[i])
	    end
    end
    if lua_table.right_leg_4_hit == true
    then
        lua_table.right_leg_4_hit = false
        for i = 1, #particles.right_leg_4_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.right_leg_4_blood_hit.part_childs[i])
	    end
    end      
end

local function HandlePlayerPosition()

	if P1_id ~= 0
	then
		-- Gets position from Player 1 gameobject Id
		lua_table.P1_pos = lua_table.TransformFunctions:GetPosition(P1_id)

		if lua_table.P1_pos[x] == nil or lua_table.P1_pos[y] == nil or lua_table.P1_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Player 1 position nil")
		else
			-- Checks player proximity 
			if current_state == state.UNACTIVE
			then
                -- Calculates distance
                lua_table.P1_distance[x] = lua_table.my_position[x] - lua_table.P1_pos[x]
                lua_table.P1_distance[y] = lua_table.my_position[y] - lua_table.P1_pos[y]
                lua_table.P1_distance[z] = lua_table.my_position[z] - lua_table.P1_pos[z]
            
				P1_abs_distance = math.sqrt((lua_table.P1_distance[x] * lua_table.P1_distance[x]) + (lua_table.P1_distance[z] * lua_table.P1_distance[z]))

				if P1_abs_distance ~= nil and P1_abs_distance <= lua_table.awakening_distance
				then
					player_in_awakening_distance = true
					lua_table.SystemFunctions:LOG ("Kikimora: SHOULD AWAKEN")
				end 
			end
		end
	end

	if P2_id ~= 0
	then
		-- Gets position from Player 2 gameobject Id
		lua_table.P2_pos = lua_table.TransformFunctions:GetPosition(P2_id)

		if lua_table.P2_pos[x] == nil or lua_table.P2_pos[y] == nil or lua_table.P2_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Player 2 position nil")
		else
			-- Checks player proximity 
			if current_state == state.UNACTIVE
			then
                --Calculates distance
                lua_table.P2_distance[x] = lua_table.my_position[x] - lua_table.P2_pos[x]
                lua_table.P2_distance[y] = lua_table.my_position[y] - lua_table.P2_pos[y]
                lua_table.P2_distance[z] = lua_table.my_position[z] - lua_table.P2_pos[z]

				P2_abs_distance = math.sqrt((lua_table.P2_distance[x] * lua_table.P2_distance[x]) + (lua_table.P2_distance[z] * lua_table.P2_distance[z]))

				if P2_abs_distance ~= nil and P2_abs_distance <= lua_table.awakening_distance
				then
					player_in_awakening_distance = true
					lua_table.SystemFunctions:LOG ("Kikimora: SHOULD AWAKEN")
				end 
			end
		end
    end
end

local function HandleStates()
    -- State Unactive to Awaken
    if current_state == state.UNACTIVE and player_in_awakening_distance == true --Check if player in range and start awakening
    then 
        lua_table.awakened = true
        current_state = state.AWAKENING 
        lua_table.SystemFunctions:LOG ("Kikimora: AWAKENED")

        -- PLAY AWAKENING ANIMATION
        lua_table.AnimationFunctions:PlayAnimation(animation.awakening.anim_name, animation.awakening.anim_speed, my_UID)

        local awakening_duration = animation.awakening.anim_frames / animation.awakening.anim_speed

        animation_timer = game_time + awakening_timer
        -- Timer of awakening duration
        state_timer = game_time + awakening_duration -- duration of awakening animation

    end

    if current_state == state.AWAKENING
    then

        if game_time >= animation_timer
        then
            lua_table.GameObjectFunctions:SetActiveGameObject(true, my_mesh_UID)
        end

        if game_time >= animation_timer + 0.5 and awakening_audio_played == false
        then
            awakening_audio_played = true
            -- AUDIO PLAY
            lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_damaged", my_UID)
        end

        if game_time >= state_timer
        then
            awakening_audio_played = false
            current_state = state.IDLE
            lua_table.SystemFunctions:LOG ("Kikimora: AWAKENING ended now idle")
        end
    end

    if current_state == state.IDLE
    then
        if game_time >= state_timer
        then
            lua_table.AnimationFunctions:PlayAnimation(animation.idle.anim_name, animation.idle.anim_speed, my_UID)
            state_timer = game_time + (animation.idle.anim_frames / animation.idle.anim_speed)
        end
    end

    if current_state == state.ATTACKING
    then
        if attack_pattern_cooldown_bool == true
        then
            current_state = state.IDLE
            lua_table.SystemFunctions:LOG ("Kikimora: Attacks on cooldown now idle")
        end
    end

    if current_state == state.MOVING
    then
        -- Not moving for now
    end

    if game_time >= P1_timer_under_boss and P1_timer_under_boss ~= -1 
    or game_time >= P2_timer_under_boss and P2_timer_under_boss ~= -1
    then
        P1_timer_under_boss = -1
        P2_timer_under_boss = -1

        current_state = state.JUMPING
        start_jumping = true
    end
    --
        if P1_under_boss_waiting == true and current_state ~= state.JUMPING
        then  
            P1_timer_under_boss = game_time + lua_table.under_time
            P1_under_boss_waiting = false
        end

        if P2_under_boss_waiting == true and current_state ~= state.JUMPING
        then  
            P1_timer_under_boss = game_time + lua_table.under_time
            P1_under_boss_waiting = false
        end
    --
    if current_state == state.JUMPING
    then
        HandleJump()

        if finish_jumping == true
        then
            current_state = state.IDLE
            finish_jumping = false
        end
    end

    if current_state == state.TAUNTING
    then
        -- Not taunting for now
    end

    if current_state == state.STUNNED
    then
        -- Not stunned for now
    end

    if current_state == state.SWAPPING_PHASE
    then
        if start_swapping == true
        then

            start_swapping = false

            -- Resetting stats
            current_attack_pattern = attack_pattern.TO_BE_DETERMINED
            current_attack_type = attack_type.TO_BE_DETERMINED
            current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

            lua_table.ParticlesFunctions:StopParticleEmitter(particles.scream.part_UID)
            for i = 1, #particles.kiki_sweep_particle_left.part_childs do
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_particle_left.part_childs[i])
            end
            for i = 1, #particles.kiki_sweep_particle_right.part_childs do
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_particle_right.part_childs[i])
            end
            for i = 1, #particles.kiki_sweep_left_particle.part_childs do
                lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_left_particle.part_childs[i])
            end

            -- This is while I don't have a Swapping phase animation (maybe with a stun + roar would make the same effect)
            lua_table.AnimationFunctions:PlayAnimation(animation.swap_phase.anim_name, animation.swap_phase.anim_speed, my_UID)

            local swap_phase_duration = animation.swap_phase.anim_frames / animation.swap_phase.anim_speed

            animation_timer = game_time + swap_phase_duration
    
            -- AUDIO PLAY
            lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_scream_1", my_UID)
            
        end
    
        if game_time >= animation_timer
        then 
            current_state = state.JUMPING
            start_jumping = true
        end
    end

    if current_state == state.SPAWNING_MINIONS
    then
        -- Play spaawning minions animation
    end

    if lua_table.current_health <= 0 and current_state ~= state.DEAD
    then 
        current_state = state.DEAD

        -- Resetting stats
        current_attack_pattern = attack_pattern.TO_BE_DETERMINED
        current_attack_type = attack_type.TO_BE_DETERMINED
        current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

        -- Setting colliders unactive
        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)
        attack_collider.stomp.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep.coll_UID)
        attack_collider.sweep.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
        attack_collider.sweep_left.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
        attack_collider.sweep_right.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)
        attack_collider.leash_left.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)
        attack_collider.leash_right.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.roar.coll_UID)
        attack_collider.roar.coll_active = false

        lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.jump.coll_UID)
        attack_collider.jump.coll_active = false

        -- Partciles STOP
        lua_table.ParticlesFunctions:StopParticleEmitter(particles.rage_aura_2.part_UID)
        lua_table.ParticlesFunctions:StopParticleEmitter(particles.scream.part_UID)
        for i = 1, #particles.kiki_sweep_particle_left.part_childs do
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_particle_left.part_childs[i])
        end
        for i = 1, #particles.kiki_sweep_particle_right.part_childs do
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_particle_right.part_childs[i])
        end
        for i = 1, #particles.kiki_sweep_left_particle.part_childs do
            lua_table.ParticlesFunctions:StopParticleEmitter(particles.kiki_sweep_left_particle.part_childs[i])
        end

        -- Play death animation
        lua_table.AnimationFunctions:PlayAnimation(animation.death.anim_name, animation.death.anim_speed, my_UID)

        -- Particles PLAY
        for i = 1, #particles.death_blood.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.death_blood.part_childs[i])
	    end

        -- AUDIO PLAY
        lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_death", my_UID)

        local death_duration = animation.death.anim_frames / animation.death.anim_speed
        
        animation_timer = game_time + death_duration

        state_timer = game_time + lua_table.despawn_time
    end

    if current_state == state.DEAD
    then
        -- Resetting stats
        current_attack_pattern = attack_pattern.TO_BE_DETERMINED
        current_attack_type = attack_type.TO_BE_DETERMINED
        current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

        if game_time >= animation_timer and death_audio_played == false
        then  
            death_audio_played = true

            -- Shut all particles
            lua_table.awakened = false
            
            -- AUDIO PLAY
            lua_table.AudioFunctions:PlayAudioEventGO("Play_Kikimora_lash", my_UID)
        end

        if game_time >= state_timer
        then
            -- DESPAWN BOSS
            --  lua_table.GameObjectFunctions:SetActiveGameObject(false, my_mesh_UID)
        
            if lua_table.scene_UID ~= 0
            then
                lua_table.SeceneFunctions:LoadScene(lua_table.scene_UID)
            end

            lua_table.dead = true
        end
    end
end

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Kikimora Script on AWAKE")
	
	-- Get my own UID
    my_UID = lua_table.GameObjectFunctions:GetMyUID()

    lua_table.jump_pos_1[x] = 966
    lua_table.jump_pos_1[y] = 11
    lua_table.jump_pos_1[z] = -696

    lua_table.jump_rot_1[x] = 0
    lua_table.jump_rot_1[y] = -19
    lua_table.jump_rot_1[z] = 0

    lua_table.jump_pos_2[x] = 930
    lua_table.jump_pos_2[y] = 10.5
    lua_table.jump_pos_2[z] = -675.5
    
    lua_table.jump_rot_2[x] = 0
    lua_table.jump_rot_2[y] = 83
    lua_table.jump_rot_2[z] = 0

    lua_table.jump_pos_3[x] = 988
    lua_table.jump_pos_3[y] = 11
    lua_table.jump_pos_3[z] = -679.5
    
    lua_table.jump_rot_3[x] = 0
    lua_table.jump_rot_3[y] = -82
    lua_table.jump_rot_3[z] = 0

    -- Get my position
    lua_table.TransformFunctions:SetPosition(lua_table.jump_pos_1[x], lua_table.jump_pos_1[y], lua_table.jump_pos_1[z], my_UID)
    lua_table.my_position = lua_table.jump_pos_1

    -- Get my rotation
    lua_table.TransformFunctions:SetObjectRotation(lua_table.jump_rot_1[x], lua_table.jump_rot_1[y], lua_table.jump_rot_1[z], my_UID)
    lua_table.my_rotation = lua_table.jump_rot_1

    -- Get my own mesh
    my_mesh_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.mesh_GO)

    -- Setting mesh unactive
    lua_table.GameObjectFunctions:SetActiveGameObject(false, my_mesh_UID)

    -- Get camera UID
    camera_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.camera_GO)
    
    -- Get camera script
    if camera_UID ~= 0
    then
        lua_table.camera_script = lua_table.GameObjectFunctions:GetScript(camera_UID)
    end

	---------------------------------------------------------------------------
	-- Player UIDs
	---------------------------------------------------------------------------

	-- Player 1 id
	P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt_GO)	-- first checks if Geralt available

	if P1_id ~= 0
	then 
		lua_table.SystemFunctions:LOG ("Kikimora: Player 1 id successfully recieved (Geralt)")

		-- Player 1 script (only if successfull id)
		lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

		-- Player 2 id
		P2_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) --If Geralt available checks for Jaskier as player 2

		if P2_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 2 id, check name of game object inside script")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Player 2 id successfully recieved (Jaskier)")

			-- Player 2 script (only if successfull id)
			lua_table.P2_script = lua_table.GameObjectFunctions:GetScript(P2_id)
		end
	else
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) -- If Geralt not available checks for Jaskier

		if P1_id ~= 0
		then 
			lua_table.SystemFunctions:LOG ("Kikimora: Player 1 id successfully recieved (Jaskier)")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 1 id")
		end
    end

    ---------------------------------------------------------------------------
	-- Animations Init
    ---------------------------------------------------------------------------

    -- Animation Speeds
    animation.awakening.anim_speed = animation.awakening.anim_speed * lua_table.speed_modificator_base

    animation.jump.anim_speed =  animation.jump.anim_speed * lua_table.speed_modificator_base

    animation.swap_phase.anim_speed = animation.swap_phase.anim_speed * lua_table.speed_modificator_base
    
    animation.idle.anim_speed = animation.idle.anim_speed * lua_table.speed_modificator_base
    
    animation.death.anim_speed = animation.death.anim_speed * lua_table.speed_modificator_base

    animation.leash.anim_speed = animation.leash.anim_speed * lua_table.speed_modificator_base

    animation.leash_left_anticipation.anim_speed = animation.leash_left_anticipation.anim_speed * lua_table.speed_modificator_base
    animation.leash_left_execution.anim_speed = animation.leash_left_execution.anim_speed * lua_table.speed_modificator_base
    animation.leash_left_recovery.anim_speed = animation.leash_left_recovery.anim_speed * lua_table.speed_modificator_base
    
    animation.leash_right_anticipation.anim_speed = animation.leash_right_anticipation.anim_speed * lua_table.speed_modificator_base 
    animation.leash_right_execution.anim_speed = animation.leash_right_execution.anim_speed * lua_table.speed_modificator_base
    animation.leash_right_recovery.anim_speed = animation.leash_right_recovery.anim_speed * lua_table.speed_modificator_base
    
    animation.sweep_anticipation.anim_speed = animation.sweep_anticipation.anim_speed * lua_table.speed_modificator_base
    animation.sweep_execution.anim_speed = animation.sweep_execution.anim_speed * lua_table.speed_modificator_base
    animation.sweep_recovery.anim_speed = animation.sweep_recovery.anim_speed * lua_table.speed_modificator_base
    
    animation.sweep_left_anticipation.anim_speed = animation.sweep_left_anticipation.anim_speed * lua_table.speed_modificator_base 
    animation.sweep_left_execution.anim_speed = animation.sweep_left_execution.anim_speed * lua_table.speed_modificator_base 
    animation.sweep_left_recovery.anim_speed = animation.sweep_left_recovery.anim_speed * lua_table.speed_modificator_base 
    
    animation.sweep_right_anticipation.anim_speed = animation.sweep_right_anticipation.anim_speed * lua_table.speed_modificator_base 
    animation.sweep_right_execution.anim_speed = animation.sweep_right_execution.anim_speed * lua_table.speed_modificator_base 
    animation.sweep_right_recovery.anim_speed = animation.sweep_right_recovery.anim_speed * lua_table.speed_modificator_base 
    
    animation.stomp_anticipation.anim_speed = animation.stomp_anticipation.anim_speed * lua_table.speed_modificator_base 
    animation.stomp_execution.anim_speed = animation.stomp_execution.anim_speed * lua_table.speed_modificator_base 
    animation.stomp_recovery.anim_speed = animation.stomp_recovery.anim_speed * lua_table.speed_modificator_base 
    
    animation.roar_anticipation.anim_speed = animation.roar_anticipation.anim_speed * lua_table.speed_modificator_base 
    animation.roar_execution.anim_speed = animation.roar_execution.anim_speed * lua_table.speed_modificator_base 
    animation.roar_recovery.anim_speed = animation.roar_recovery.anim_speed * lua_table.speed_modificator_base 


    ---------------------------------------------------------------------------
	-- Attacks Init
    ---------------------------------------------------------------------------

    -- Attacks duartion
    attack.leash_left.att_anticipation_duration = animation.leash_left_anticipation.anim_frames / animation.leash_left_anticipation.anim_speed 
    attack.leash_left.att_execution_duration = animation.leash_left_execution.anim_frames / animation.leash_left_execution.anim_speed 
    attack.leash_left.att_recovery_duration = animation.leash_left_recovery.anim_frames / animation.leash_left_recovery.anim_speed 
    
    attack.leash_right.att_anticipation_duration = animation.leash_right_anticipation.anim_frames / animation.leash_right_anticipation.anim_speed 
    attack.leash_right.att_execution_duration = animation.leash_right_execution.anim_frames / animation.leash_right_execution.anim_speed 
    attack.leash_right.att_recovery_duration = animation.leash_right_recovery.anim_frames / animation.leash_right_recovery.anim_speed 

    attack.sweep.att_anticipation_duration = animation.sweep_anticipation.anim_frames / animation.sweep_anticipation.anim_speed 
    attack.sweep.att_execution_duration = animation.sweep_execution.anim_frames / animation.sweep_execution.anim_speed 
    attack.sweep.att_recovery_duration = animation.sweep_recovery.anim_frames / animation.sweep_recovery.anim_speed 

    attack.sweep_left.att_anticipation_duration = animation.sweep_left_anticipation.anim_frames / animation.sweep_left_anticipation.anim_speed 
    attack.sweep_left.att_execution_duration = animation.sweep_left_execution.anim_frames / animation.sweep_left_execution.anim_speed 
    attack.sweep_left.att_recovery_duration = animation.sweep_left_recovery.anim_frames / animation.sweep_left_recovery.anim_speed 

    attack.sweep_right.att_anticipation_duration = animation.sweep_right_anticipation.anim_frames / animation.sweep_right_anticipation.anim_speed 
    attack.sweep_right.att_execution_duration = animation.sweep_right_execution.anim_frames / animation.sweep_right_execution.anim_speed 
    attack.sweep_right.att_recovery_duration = animation.sweep_right_recovery.anim_frames / animation.sweep_right_recovery.anim_speed 

    attack.stomp.att_anticipation_duration = animation.stomp_anticipation.anim_frames / animation.stomp_anticipation.anim_speed
    attack.stomp.att_execution_duration = animation.stomp_execution.anim_frames / animation.stomp_execution.anim_speed 
    attack.stomp.att_recovery_duration = animation.stomp_recovery.anim_frames / animation.stomp_recovery.anim_speed 

    attack.roar.att_anticipation_duration = animation.roar_anticipation.anim_frames / animation.roar_anticipation.anim_speed 
    attack.roar.att_execution_duration = animation.roar_execution.anim_frames / animation.roar_execution.anim_speed 
    attack.roar.att_recovery_duration = animation.roar_recovery.anim_frames / animation.roar_recovery.anim_speed 
    
    ---------------------------------------------------------------------------
	-- Attack Colliders Init
    ---------------------------------------------------------------------------
    
    -- Attack colliders UIDs 
    attack_collider.roar.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.roar.coll_name)

    attack_collider.stomp.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.stomp.coll_name)

    attack_collider.sweep.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep.coll_name)

    attack_collider.sweep_left_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_left_pivot.coll_name)
    attack_collider.sweep_left.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_left.coll_name)

    attack_collider.sweep_right_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_right_pivot.coll_name)
    attack_collider.sweep_right.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_right.coll_name)

    attack_collider.leash_left_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_left_pivot.coll_name)
    attack_collider.leash_left.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_left.coll_name)

    attack_collider.leash_right_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_right_pivot.coll_name)
    attack_collider.leash_right.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_right.coll_name)

    attack_collider.jump.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.jump.coll_name)




    -- Setting them unactive
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)
    attack_collider.stomp.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep.coll_UID)
    attack_collider.sweep.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
    attack_collider.sweep_left.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
    attack_collider.sweep_right.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)
    attack_collider.leash_left.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)
    attack_collider.leash_right.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.roar.coll_UID)
    attack_collider.roar.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.jump.coll_UID)
    attack_collider.jump.coll_active = false

    -- Setting positions, rotations, velocities and angular velocities(only depend on att_execution_duration)

    attack_collider.leash_left_pivot.coll_init_pos[x] = 0
    attack_collider.leash_left_pivot.coll_init_pos[y] = 0
    attack_collider.leash_left_pivot.coll_init_pos[z] = 4
    attack_collider.leash_left_pivot.coll_final_pos[x] = 0
    attack_collider.leash_left_pivot.coll_final_pos[y] = 0
    attack_collider.leash_left_pivot.coll_final_pos[z] = 4
    attack_collider.leash_left_pivot.coll_velocity[x] = (attack_collider.leash_left_pivot.coll_final_pos[x] - attack_collider.leash_left_pivot.coll_init_pos[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_velocity[y] = (attack_collider.leash_left_pivot.coll_final_pos[y] - attack_collider.leash_left_pivot.coll_init_pos[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_velocity[z] = (attack_collider.leash_left_pivot.coll_final_pos[z] - attack_collider.leash_left_pivot.coll_init_pos[z]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_init_rot[x] = 0
    attack_collider.leash_left_pivot.coll_init_rot[y] = -45
    attack_collider.leash_left_pivot.coll_init_rot[z] = 60
    attack_collider.leash_left_pivot.coll_final_rot[x] = 0
    attack_collider.leash_left_pivot.coll_final_rot[y] = -45
    attack_collider.leash_left_pivot.coll_final_rot[z] = 0
    attack_collider.leash_left_pivot.coll_ang_velocity[x] = (attack_collider.leash_left_pivot.coll_final_rot[x] - attack_collider.leash_left_pivot.coll_init_rot[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_ang_velocity[y] = (attack_collider.leash_left_pivot.coll_final_rot[y] - attack_collider.leash_left_pivot.coll_init_rot[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_ang_velocity[z] = (attack_collider.leash_left_pivot.coll_final_rot[z] - attack_collider.leash_left_pivot.coll_init_rot[z]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_init_scale[x] = 1
    attack_collider.leash_left_pivot.coll_init_scale[y] = 1
    attack_collider.leash_left_pivot.coll_init_scale[z] = 1
    attack_collider.leash_left_pivot.coll_final_scale[x] = 1
    attack_collider.leash_left_pivot.coll_final_scale[y] = 1
    attack_collider.leash_left_pivot.coll_final_scale[z] = 1
    attack_collider.leash_left_pivot.coll_growth_velocity[x] = (attack_collider.leash_left_pivot.coll_init_scale[x] - attack_collider.leash_left_pivot.coll_final_scale[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_growth_velocity[y] = (attack_collider.leash_left_pivot.coll_init_scale[y] - attack_collider.leash_left_pivot.coll_final_scale[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left_pivot.coll_growth_velocity[z] = (attack_collider.leash_left_pivot.coll_init_scale[z] - attack_collider.leash_left_pivot.coll_final_scale[z]) / attack.leash_left.att_execution_duration

    attack_collider.leash_left.coll_init_pos[x] = 6
    attack_collider.leash_left.coll_init_pos[y] = 0
    attack_collider.leash_left.coll_init_pos[z] = 0
    attack_collider.leash_left.coll_final_pos[x] = 6
    attack_collider.leash_left.coll_final_pos[y] = 0
    attack_collider.leash_left.coll_final_pos[z] = 0
    attack_collider.leash_left.coll_velocity[x] = (attack_collider.leash_left.coll_final_pos[x] - attack_collider.leash_left.coll_init_pos[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_velocity[y] = (attack_collider.leash_left.coll_final_pos[y] - attack_collider.leash_left.coll_init_pos[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_velocity[z] = (attack_collider.leash_left.coll_final_pos[z] - attack_collider.leash_left.coll_init_pos[z]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_init_rot[x] = 0
    attack_collider.leash_left.coll_init_rot[y] = 0
    attack_collider.leash_left.coll_init_rot[z] = 0
    attack_collider.leash_left.coll_final_rot[x] = 0
    attack_collider.leash_left.coll_final_rot[y] = 0
    attack_collider.leash_left.coll_final_rot[z] = 0
    attack_collider.leash_left.coll_ang_velocity[x] = (attack_collider.leash_left.coll_final_rot[x] - attack_collider.leash_left.coll_init_rot[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_ang_velocity[y] = (attack_collider.leash_left.coll_final_rot[y] - attack_collider.leash_left.coll_init_rot[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_ang_velocity[z] = (attack_collider.leash_left.coll_final_rot[z] - attack_collider.leash_left.coll_init_rot[z]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_init_scale[x] = 12
    attack_collider.leash_left.coll_init_scale[y] = 3
    attack_collider.leash_left.coll_init_scale[z] = 3
    attack_collider.leash_left.coll_final_scale[x] = 12
    attack_collider.leash_left.coll_final_scale[y] = 3
    attack_collider.leash_left.coll_final_scale[z] = 3
    attack_collider.leash_left.coll_growth_velocity[x] = (attack_collider.leash_left.coll_init_scale[x] - attack_collider.leash_left.coll_final_scale[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_growth_velocity[y] = (attack_collider.leash_left.coll_init_scale[y] - attack_collider.leash_left.coll_final_scale[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_growth_velocity[z] = (attack_collider.leash_left.coll_init_scale[z] - attack_collider.leash_left.coll_final_scale[z]) / attack.leash_left.att_execution_duration

    attack_collider.leash_right_pivot.coll_init_pos[x] = 0
    attack_collider.leash_right_pivot.coll_init_pos[y] = 0
    attack_collider.leash_right_pivot.coll_init_pos[z] = 4
    attack_collider.leash_right_pivot.coll_final_pos[x] = 0
    attack_collider.leash_right_pivot.coll_final_pos[y] = 0
    attack_collider.leash_right_pivot.coll_final_pos[z] = 4
    attack_collider.leash_right_pivot.coll_velocity[x] = (attack_collider.leash_right_pivot.coll_final_pos[x] - attack_collider.leash_right_pivot.coll_init_pos[x]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_velocity[y] = (attack_collider.leash_right_pivot.coll_final_pos[y] - attack_collider.leash_right_pivot.coll_init_pos[y]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_velocity[z] = (attack_collider.leash_right_pivot.coll_final_pos[z] - attack_collider.leash_right_pivot.coll_init_pos[z]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_init_rot[x] = 0
    attack_collider.leash_right_pivot.coll_init_rot[y] = 45
    attack_collider.leash_right_pivot.coll_init_rot[z] = -60
    attack_collider.leash_right_pivot.coll_final_rot[x] = 0
    attack_collider.leash_right_pivot.coll_final_rot[y] = 45
    attack_collider.leash_right_pivot.coll_final_rot[z] = 0
    attack_collider.leash_right_pivot.coll_ang_velocity[x] = (attack_collider.leash_right_pivot.coll_final_rot[x] - attack_collider.leash_right_pivot.coll_init_rot[x]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_ang_velocity[y] = (attack_collider.leash_right_pivot.coll_final_rot[y] - attack_collider.leash_right_pivot.coll_init_rot[y]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_ang_velocity[z] = (attack_collider.leash_right_pivot.coll_final_rot[z] - attack_collider.leash_right_pivot.coll_init_rot[z]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_init_scale[x] = 1
    attack_collider.leash_right_pivot.coll_init_scale[y] = 1
    attack_collider.leash_right_pivot.coll_init_scale[z] = 1
    attack_collider.leash_right_pivot.coll_final_scale[x] = 1
    attack_collider.leash_right_pivot.coll_final_scale[y] = 1
    attack_collider.leash_right_pivot.coll_final_scale[z] = 1
    attack_collider.leash_right_pivot.coll_growth_velocity[x] = (attack_collider.leash_right_pivot.coll_init_scale[x] - attack_collider.leash_right_pivot.coll_final_scale[x]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_growth_velocity[y] = (attack_collider.leash_right_pivot.coll_init_scale[y] - attack_collider.leash_right_pivot.coll_final_scale[y]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right_pivot.coll_growth_velocity[z] = (attack_collider.leash_right_pivot.coll_init_scale[z] - attack_collider.leash_right_pivot.coll_final_scale[z]) / attack.leash_right.att_execution_duration

    attack_collider.leash_right.coll_init_pos[x] = -6
    attack_collider.leash_right.coll_init_pos[y] = 0
    attack_collider.leash_right.coll_init_pos[z] = 0
    attack_collider.leash_right.coll_final_pos[x] = -6
    attack_collider.leash_right.coll_final_pos[y] = 0
    attack_collider.leash_right.coll_final_pos[z] = 0
    attack_collider.leash_right.coll_velocity[x] = (attack_collider.leash_right.coll_final_pos[x] - attack_collider.leash_right.coll_init_pos[x]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right.coll_velocity[y] = (attack_collider.leash_right.coll_final_pos[y] - attack_collider.leash_right.coll_init_pos[y]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right.coll_velocity[z] = (attack_collider.leash_right.coll_final_pos[z] - attack_collider.leash_right.coll_init_pos[z]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right.coll_init_rot[x] = 0
    attack_collider.leash_right.coll_init_rot[y] = 0
    attack_collider.leash_right.coll_init_rot[z] = 0
    attack_collider.leash_right.coll_final_rot[x] = 0
    attack_collider.leash_right.coll_final_rot[y] = 0
    attack_collider.leash_right.coll_final_rot[z] = 0
    attack_collider.leash_right.coll_ang_velocity[x] = (attack_collider.leash_right.coll_final_rot[x] - attack_collider.leash_right.coll_init_rot[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_right.coll_ang_velocity[y] = (attack_collider.leash_right.coll_final_rot[y] - attack_collider.leash_right.coll_init_rot[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_right.coll_ang_velocity[z] = (attack_collider.leash_right.coll_final_rot[z] - attack_collider.leash_right.coll_init_rot[z]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_right.coll_init_scale[x] = 12
    attack_collider.leash_right.coll_init_scale[y] = 3
    attack_collider.leash_right.coll_init_scale[z] = 3
    attack_collider.leash_right.coll_final_scale[x] = 12
    attack_collider.leash_right.coll_final_scale[y] = 3
    attack_collider.leash_right.coll_final_scale[z] = 3
    attack_collider.leash_right.coll_growth_velocity[x] = (attack_collider.leash_right.coll_init_scale[x] - attack_collider.leash_right.coll_final_scale[x]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right.coll_growth_velocity[y] = (attack_collider.leash_right.coll_init_scale[y] - attack_collider.leash_right.coll_final_scale[y]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right.coll_growth_velocity[z] = (attack_collider.leash_right.coll_init_scale[z] - attack_collider.leash_right.coll_final_scale[z]) / attack.leash_right.att_execution_duration

    attack_collider.sweep.coll_init_pos[x] = 7
    attack_collider.sweep.coll_init_pos[y] = 0
    attack_collider.sweep.coll_init_pos[z] = 7
    attack_collider.sweep.coll_final_pos[x] = -12
    attack_collider.sweep.coll_final_pos[y] = 0
    attack_collider.sweep.coll_final_pos[z] = 7
    attack_collider.sweep.coll_velocity[x] = (attack_collider.sweep.coll_final_pos[x] - attack_collider.sweep.coll_init_pos[x]) / attack.sweep.att_execution_duration 
    attack_collider.sweep.coll_velocity[y] = (attack_collider.sweep.coll_final_pos[y] - attack_collider.sweep.coll_init_pos[y]) / attack.sweep.att_execution_duration
    attack_collider.sweep.coll_velocity[z] = (attack_collider.sweep.coll_final_pos[z] - attack_collider.sweep.coll_init_pos[z]) / attack.sweep.att_execution_duration
    attack_collider.sweep.coll_init_rot[x] = 0
    attack_collider.sweep.coll_init_rot[y] = 0
    attack_collider.sweep.coll_init_rot[z] = 0
    attack_collider.sweep.coll_final_rot[x] = 0
    attack_collider.sweep.coll_final_rot[y] = 0
    attack_collider.sweep.coll_final_rot[z] = 0
    attack_collider.sweep.coll_ang_velocity[x] = (attack_collider.sweep.coll_final_rot[x] - attack_collider.sweep.coll_init_rot[x]) / attack.sweep.att_execution_duration 
    attack_collider.sweep.coll_ang_velocity[y] = (attack_collider.sweep.coll_final_rot[y] - attack_collider.sweep.coll_init_rot[y]) / attack.sweep.att_execution_duration 
    attack_collider.sweep.coll_ang_velocity[z] = (attack_collider.sweep.coll_final_rot[z] - attack_collider.sweep.coll_init_rot[z]) / attack.sweep.att_execution_duration 
    attack_collider.sweep.coll_init_scale[x] = 5
    attack_collider.sweep.coll_init_scale[y] = 3
    attack_collider.sweep.coll_init_scale[z] = 11
    attack_collider.sweep.coll_final_scale[x] = 5
    attack_collider.sweep.coll_final_scale[y] = 3
    attack_collider.sweep.coll_final_scale[z] = 11
    attack_collider.sweep.coll_growth_velocity[x] = (attack_collider.sweep.coll_init_scale[x] - attack_collider.sweep.coll_final_scale[x]) / attack.sweep.att_execution_duration 
    attack_collider.sweep.coll_growth_velocity[y] = (attack_collider.sweep.coll_init_scale[y] - attack_collider.sweep.coll_final_scale[y]) / attack.sweep.att_execution_duration 
    attack_collider.sweep.coll_growth_velocity[z] = (attack_collider.sweep.coll_init_scale[z] - attack_collider.sweep.coll_final_scale[z]) / attack.sweep.att_execution_duration

    attack_collider.sweep_left_pivot.coll_init_pos[x] = 0
    attack_collider.sweep_left_pivot.coll_init_pos[y] = 0
    attack_collider.sweep_left_pivot.coll_init_pos[z] = 1
    attack_collider.sweep_left_pivot.coll_final_pos[x] = 0
    attack_collider.sweep_left_pivot.coll_final_pos[y] = 0
    attack_collider.sweep_left_pivot.coll_final_pos[z] = 1
    attack_collider.sweep_left_pivot.coll_velocity[x] = (attack_collider.sweep_left_pivot.coll_final_pos[x] - attack_collider.sweep_left_pivot.coll_init_pos[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left_pivot.coll_velocity[y] = (attack_collider.sweep_left_pivot.coll_final_pos[y] - attack_collider.sweep_left_pivot.coll_init_pos[y]) / attack.sweep_left.att_execution_duration
    attack_collider.sweep_left_pivot.coll_velocity[z] = (attack_collider.sweep_left_pivot.coll_final_pos[z] - attack_collider.sweep_left_pivot.coll_init_pos[z]) / attack.sweep_left.att_execution_duration
    attack_collider.sweep_left_pivot.coll_init_rot[x] = 0
    attack_collider.sweep_left_pivot.coll_init_rot[y] = 0
    attack_collider.sweep_left_pivot.coll_init_rot[z] = 0
    attack_collider.sweep_left_pivot.coll_final_rot[x] = 0
    attack_collider.sweep_left_pivot.coll_final_rot[y] = -120
    attack_collider.sweep_left_pivot.coll_final_rot[z] = 0
    attack_collider.sweep_left_pivot.coll_ang_velocity[x] = (attack_collider.sweep_left_pivot.coll_final_rot[x] - attack_collider.sweep_left_pivot.coll_init_rot[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left_pivot.coll_ang_velocity[y] = (attack_collider.sweep_left_pivot.coll_final_rot[y] - attack_collider.sweep_left_pivot.coll_init_rot[y]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left_pivot.coll_ang_velocity[z] = (attack_collider.sweep_left_pivot.coll_final_rot[z] - attack_collider.sweep_left_pivot.coll_init_rot[z]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left_pivot.coll_init_scale[x] = 1
    attack_collider.sweep_left_pivot.coll_init_scale[y] = 1
    attack_collider.sweep_left_pivot.coll_init_scale[z] = 1 
    attack_collider.sweep_left_pivot.coll_final_scale[x] = 1
    attack_collider.sweep_left_pivot.coll_final_scale[y] = 1
    attack_collider.sweep_left_pivot.coll_final_scale[z] = 1
    attack_collider.sweep_left_pivot.coll_growth_velocity[x] = (attack_collider.sweep_left_pivot.coll_init_scale[x] - attack_collider.sweep_left_pivot.coll_final_scale[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left_pivot.coll_growth_velocity[y] = (attack_collider.sweep_left_pivot.coll_init_scale[y] - attack_collider.sweep_left_pivot.coll_final_scale[y]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left_pivot.coll_growth_velocity[z] = (attack_collider.sweep_left_pivot.coll_init_scale[z] - attack_collider.sweep_left_pivot.coll_final_scale[z]) / attack.sweep_left.att_execution_duration

    attack_collider.sweep_left.coll_init_pos[x] = 7.5
    attack_collider.sweep_left.coll_init_pos[y] = 0
    attack_collider.sweep_left.coll_init_pos[z] = 0
    attack_collider.sweep_left.coll_final_pos[x] = 7.5
    attack_collider.sweep_left.coll_final_pos[y] = 0
    attack_collider.sweep_left.coll_final_pos[z] = 0
    attack_collider.sweep_left.coll_velocity[x] = (attack_collider.sweep_left.coll_final_pos[x] - attack_collider.sweep_left.coll_init_pos[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_velocity[y] = (attack_collider.sweep_left.coll_final_pos[y] - attack_collider.sweep_left.coll_init_pos[y]) / attack.sweep_left.att_execution_duration
    attack_collider.sweep_left.coll_velocity[z] = (attack_collider.sweep_left.coll_final_pos[z] - attack_collider.sweep_left.coll_init_pos[z]) / attack.sweep_left.att_execution_duration
    attack_collider.sweep_left.coll_init_rot[x] = 0
    attack_collider.sweep_left.coll_init_rot[y] = 0
    attack_collider.sweep_left.coll_init_rot[z] = 0
    attack_collider.sweep_left.coll_final_rot[x] = 0
    attack_collider.sweep_left.coll_final_rot[y] = 0
    attack_collider.sweep_left.coll_final_rot[z] = 0
    attack_collider.sweep_left.coll_ang_velocity[x] = (attack_collider.sweep_left.coll_final_rot[x] - attack_collider.sweep_left.coll_init_rot[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_ang_velocity[y] = (attack_collider.sweep_left.coll_final_rot[y] - attack_collider.sweep_left.coll_init_rot[y]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_ang_velocity[z] = (attack_collider.sweep_left.coll_final_rot[z] - attack_collider.sweep_left.coll_init_rot[z]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_init_scale[x] = 7
    attack_collider.sweep_left.coll_init_scale[y] = 3
    attack_collider.sweep_left.coll_init_scale[z] = 3 
    attack_collider.sweep_left.coll_final_scale[x] = 7
    attack_collider.sweep_left.coll_final_scale[y] = 3
    attack_collider.sweep_left.coll_final_scale[z] = 3
    attack_collider.sweep_left.coll_growth_velocity[x] = (attack_collider.sweep_left.coll_init_scale[x] - attack_collider.sweep_left.coll_final_scale[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_growth_velocity[y] = (attack_collider.sweep_left.coll_init_scale[y] - attack_collider.sweep_left.coll_final_scale[y]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_growth_velocity[z] = (attack_collider.sweep_left.coll_init_scale[z] - attack_collider.sweep_left.coll_final_scale[z]) / attack.sweep_left.att_execution_duration

    attack_collider.sweep_right_pivot.coll_init_pos[x] = 0
    attack_collider.sweep_right_pivot.coll_init_pos[y] = 0
    attack_collider.sweep_right_pivot.coll_init_pos[z] = 1
    attack_collider.sweep_right_pivot.coll_final_pos[x] = 0
    attack_collider.sweep_right_pivot.coll_final_pos[y] = 0
    attack_collider.sweep_right_pivot.coll_final_pos[z] = 1
    attack_collider.sweep_right_pivot.coll_velocity[x] = (attack_collider.sweep_right_pivot.coll_final_pos[x] - attack_collider.sweep_right_pivot.coll_init_pos[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right_pivot.coll_velocity[y] = (attack_collider.sweep_right_pivot.coll_final_pos[y] - attack_collider.sweep_right_pivot.coll_init_pos[y]) / attack.sweep_right.att_execution_duration
    attack_collider.sweep_right_pivot.coll_velocity[z] = (attack_collider.sweep_right_pivot.coll_final_pos[z] - attack_collider.sweep_right_pivot.coll_init_pos[z]) / attack.sweep_right.att_execution_duration
    attack_collider.sweep_right_pivot.coll_init_rot[x] = 0
    attack_collider.sweep_right_pivot.coll_init_rot[y] = 0
    attack_collider.sweep_right_pivot.coll_init_rot[z] = 0
    attack_collider.sweep_right_pivot.coll_final_rot[x] = 0
    attack_collider.sweep_right_pivot.coll_final_rot[y] = 120
    attack_collider.sweep_right_pivot.coll_final_rot[z] = 0
    attack_collider.sweep_right_pivot.coll_ang_velocity[x] = (attack_collider.sweep_right_pivot.coll_final_rot[x] - attack_collider.sweep_right_pivot.coll_init_rot[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right_pivot.coll_ang_velocity[y] = (attack_collider.sweep_right_pivot.coll_final_rot[y] - attack_collider.sweep_right_pivot.coll_init_rot[y]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right_pivot.coll_ang_velocity[z] = (attack_collider.sweep_right_pivot.coll_final_rot[z] - attack_collider.sweep_right_pivot.coll_init_rot[z]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right_pivot.coll_init_scale[x] = 1
    attack_collider.sweep_right_pivot.coll_init_scale[y] = 1
    attack_collider.sweep_right_pivot.coll_init_scale[z] = 1 
    attack_collider.sweep_right_pivot.coll_final_scale[x] = 1
    attack_collider.sweep_right_pivot.coll_final_scale[y] = 1
    attack_collider.sweep_right_pivot.coll_final_scale[z] = 1
    attack_collider.sweep_right_pivot.coll_growth_velocity[x] = (attack_collider.sweep_right_pivot.coll_init_scale[x] - attack_collider.sweep_right_pivot.coll_final_scale[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right_pivot.coll_growth_velocity[y] = (attack_collider.sweep_right_pivot.coll_init_scale[y] - attack_collider.sweep_right_pivot.coll_final_scale[y]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right_pivot.coll_growth_velocity[z] = (attack_collider.sweep_right_pivot.coll_init_scale[z] - attack_collider.sweep_right_pivot.coll_final_scale[z]) / attack.sweep_right.att_execution_duration
    
    attack_collider.sweep_right.coll_init_pos[x] = -7.5
    attack_collider.sweep_right.coll_init_pos[y] = 0
    attack_collider.sweep_right.coll_init_pos[z] = 0
    attack_collider.sweep_right.coll_final_pos[x] = -7.5
    attack_collider.sweep_right.coll_final_pos[y] = 0
    attack_collider.sweep_right.coll_final_pos[z] = 0
    attack_collider.sweep_right.coll_velocity[x] = (attack_collider.sweep_right.coll_final_pos[x] - attack_collider.sweep_right.coll_init_pos[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_velocity[y] = (attack_collider.sweep_right.coll_final_pos[y] - attack_collider.sweep_right.coll_init_pos[y]) / attack.sweep_right.att_execution_duration
    attack_collider.sweep_right.coll_velocity[z] = (attack_collider.sweep_right.coll_final_pos[z] - attack_collider.sweep_right.coll_init_pos[z]) / attack.sweep_right.att_execution_duration
    attack_collider.sweep_right.coll_init_rot[x] = 0
    attack_collider.sweep_right.coll_init_rot[y] = 0
    attack_collider.sweep_right.coll_init_rot[z] = 0
    attack_collider.sweep_right.coll_final_rot[x] = 0
    attack_collider.sweep_right.coll_final_rot[y] = 0
    attack_collider.sweep_right.coll_final_rot[z] = 0
    attack_collider.sweep_right.coll_ang_velocity[x] = (attack_collider.sweep_right.coll_final_rot[x] - attack_collider.sweep_right.coll_init_rot[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_ang_velocity[y] = (attack_collider.sweep_right.coll_final_rot[y] - attack_collider.sweep_right.coll_init_rot[y]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_ang_velocity[z] = (attack_collider.sweep_right.coll_final_rot[z] - attack_collider.sweep_right.coll_init_rot[z]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_init_scale[x] = 7
    attack_collider.sweep_right.coll_init_scale[y] = 3
    attack_collider.sweep_right.coll_init_scale[z] = 3 
    attack_collider.sweep_right.coll_final_scale[x] = 7
    attack_collider.sweep_right.coll_final_scale[y] = 3
    attack_collider.sweep_right.coll_final_scale[z] = 3
    attack_collider.sweep_right.coll_growth_velocity[x] = (attack_collider.sweep_right.coll_init_scale[x] - attack_collider.sweep_right.coll_final_scale[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_growth_velocity[y] = (attack_collider.sweep_right.coll_init_scale[y] - attack_collider.sweep_right.coll_final_scale[y]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_growth_velocity[z] = (attack_collider.sweep_right.coll_init_scale[z] - attack_collider.sweep_right.coll_final_scale[z]) / attack.sweep_right.att_execution_duration

    attack_collider.stomp.coll_init_pos[x] = 0
    attack_collider.stomp.coll_init_pos[y] = 12
    attack_collider.stomp.coll_init_pos[z] = 10
    attack_collider.stomp.coll_final_pos[x] = 0
    attack_collider.stomp.coll_final_pos[y] = 0
    attack_collider.stomp.coll_final_pos[z] = 10
    attack_collider.stomp.coll_velocity[x] = (attack_collider.stomp.coll_final_pos[x] - attack_collider.stomp.coll_init_pos[x]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_velocity[y] = (attack_collider.stomp.coll_final_pos[y] - attack_collider.stomp.coll_init_pos[y]) / attack.stomp.att_execution_duration
    attack_collider.stomp.coll_velocity[z] = (attack_collider.stomp.coll_final_pos[z] - attack_collider.stomp.coll_init_pos[z]) / attack.stomp.att_execution_duration
    attack_collider.stomp.coll_init_rot[x] = 0
    attack_collider.stomp.coll_init_rot[y] = 0
    attack_collider.stomp.coll_init_rot[z] = 0
    attack_collider.stomp.coll_final_rot[x] = 0
    attack_collider.stomp.coll_final_rot[y] = 0
    attack_collider.stomp.coll_final_rot[z] = 0
    attack_collider.stomp.coll_ang_velocity[x] = (attack_collider.stomp.coll_final_rot[x] - attack_collider.stomp.coll_init_rot[x]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_ang_velocity[y] = (attack_collider.stomp.coll_final_rot[y] - attack_collider.stomp.coll_init_rot[y]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_ang_velocity[z] = (attack_collider.stomp.coll_final_rot[z] - attack_collider.stomp.coll_init_rot[z]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_init_scale[x] = 10
    attack_collider.stomp.coll_init_scale[y] = 1
    attack_collider.stomp.coll_init_scale[z] = 12 
    attack_collider.stomp.coll_final_scale[x] = 10
    attack_collider.stomp.coll_final_scale[y] = 1
    attack_collider.stomp.coll_final_scale[z] = 12
    attack_collider.stomp.coll_growth_velocity[x] = (attack_collider.stomp.coll_init_scale[x] - attack_collider.stomp.coll_final_scale[x]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_growth_velocity[y] = (attack_collider.stomp.coll_init_scale[y] - attack_collider.stomp.coll_final_scale[y]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_growth_velocity[z] = (attack_collider.stomp.coll_init_scale[z] - attack_collider.stomp.coll_final_scale[z]) / attack.stomp.att_execution_duration

    attack_collider.roar.coll_init_pos[x] = 0
    attack_collider.roar.coll_init_pos[y] = 0
    attack_collider.roar.coll_init_pos[z] = 13
    attack_collider.roar.coll_final_pos[x] = 0
    attack_collider.roar.coll_final_pos[y] = 0
    attack_collider.roar.coll_final_pos[z] = 13
    attack_collider.roar.coll_velocity[x] = (attack_collider.roar.coll_final_pos[x] - attack_collider.roar.coll_init_pos[x]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_velocity[y] = (attack_collider.roar.coll_final_pos[y] - attack_collider.roar.coll_init_pos[y]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_velocity[z] = (attack_collider.roar.coll_final_pos[z] - attack_collider.roar.coll_init_pos[z]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_init_rot[x] = 0
    attack_collider.roar.coll_init_rot[y] = 0
    attack_collider.roar.coll_init_rot[z] = 0
    attack_collider.roar.coll_final_rot[x] = 0
    attack_collider.roar.coll_final_rot[y] = 0
    attack_collider.roar.coll_final_rot[z] = 0
    attack_collider.roar.coll_ang_velocity[x] = (attack_collider.roar.coll_final_rot[x] - attack_collider.roar.coll_init_rot[x]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_ang_velocity[y] = (attack_collider.roar.coll_final_rot[y] - attack_collider.roar.coll_init_rot[y]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_ang_velocity[z] = (attack_collider.roar.coll_final_rot[z] - attack_collider.roar.coll_init_rot[z]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_init_scale[x] = 10
    attack_collider.roar.coll_init_scale[y] = 10
    attack_collider.roar.coll_init_scale[z] = 20 
    attack_collider.roar.coll_final_scale[x] = 10
    attack_collider.roar.coll_final_scale[y] = 10
    attack_collider.roar.coll_final_scale[z] = 20
    attack_collider.roar.coll_growth_velocity[x] = (attack_collider.roar.coll_init_scale[x] - attack_collider.roar.coll_final_scale[x]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_growth_velocity[y] = (attack_collider.roar.coll_init_scale[y] - attack_collider.roar.coll_final_scale[y]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_growth_velocity[z] = (attack_collider.roar.coll_init_scale[z] - attack_collider.roar.coll_final_scale[z]) / attack.roar.att_execution_duration

    ---------------------------------------------------------------------------
	-- Particles Init
    ---------------------------------------------------------------------------

    particles.scream.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.scream.part_name)
    
    particles.dustcloud_stomp_left.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.dustcloud_stomp_left.part_name)
    particles.dustcloud_stomp_right.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.dustcloud_stomp_right.part_name)
    
    particles.dustcloud_leash_left.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.dustcloud_leash_left.part_name)
    particles.dustcloud_leash_right.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.dustcloud_leash_right.part_name)
   
    particles.kiki_sweep_particle_left.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.kiki_sweep_particle_left.part_name)
    particles.kiki_sweep_particle_left.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.kiki_sweep_particle_left.part_UID)
    particles.kiki_sweep_particle_right.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.kiki_sweep_particle_right.part_name)
  
    particles.kiki_sweep_left_particle.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.kiki_sweep_left_particle.part_name)
    particles.kiki_sweep_left_particle.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.kiki_sweep_left_particle.part_UID)
    particles.kiki_sweep_right_particle.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.kiki_sweep_right_particle.part_name)
    particles.kiki_sweep_right_particle.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.kiki_sweep_right_particle.part_UID)

    particles.jump_area.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.jump_area.part_name)
    particles.jump_area.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.jump_area.part_UID)

    particles.rage_aura_1.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.rage_aura_1.part_name)
    particles.rage_aura_2.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.rage_aura_2.part_name)

    particles.head_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.head_blood_hit.part_name)
	particles.head_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.head_blood_hit.part_UID)

    particles.left_leg_1_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.left_leg_1_blood_hit.part_name)
    particles.left_leg_1_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.left_leg_1_blood_hit.part_UID)
    particles.left_leg_2_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.left_leg_2_blood_hit.part_name)
    particles.left_leg_2_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.left_leg_2_blood_hit.part_UID)
    particles.left_leg_3_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.left_leg_3_blood_hit.part_name)
    particles.left_leg_3_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.left_leg_3_blood_hit.part_UID)
    particles.left_leg_4_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.left_leg_4_blood_hit.part_name)
    particles.left_leg_4_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.left_leg_4_blood_hit.part_UID)

    particles.right_leg_1_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.right_leg_1_blood_hit.part_name)
    particles.right_leg_1_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.right_leg_1_blood_hit.part_UID)
    particles.right_leg_2_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.right_leg_2_blood_hit.part_name)
    particles.right_leg_2_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.right_leg_2_blood_hit.part_UID)
    particles.right_leg_3_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.right_leg_3_blood_hit.part_name)
    particles.right_leg_3_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.right_leg_3_blood_hit.part_UID)
    particles.right_leg_4_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.right_leg_4_blood_hit.part_name)
    particles.right_leg_4_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.right_leg_4_blood_hit.part_UID)

    particles.death_blood.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.death_blood.part_name)
    particles.death_blood.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.death_blood.part_UID)
  
    ---------------------------------------------------------------------------
	-- Health Init
    ---------------------------------------------------------------------------

    lua_table.current_health = lua_table.health
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("Kikimora Script START")
    --lua_table.ParticlesFunctions:ActivateParticlesEmission(my_UID)
    --lua_table.my_position = lua_table.GameObjectFunctions:GetPosition(my_UID)
    
    --If scale doens't change over time
    
    --lua_table.TransformFunctions:SetScale(attack_collider.stomp.coll_init_scale[x], attack_collider.stomp.coll_init_scale[y], attack_collider.stomp.coll_init_scale[z], attack_collider.stomp.coll_name)
    --lua_table.TransformFunctions:SetScale(attack_collider.roar.coll_init_scale[x], attack_collider.roar.coll_init_scale[y], attack_collider.roar.coll_init_scale[z], attack_collider.roar.coll_name)

    ---------------------------------------------------------------------------
    HandlePlayerPosition()
    HandleStates()

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()
    game_time = PerfGameTime()

    lua_table.my_position = lua_table.TransformFunctions:GetPosition(my_UID)
    -- Debug state
    --current_state = state.IDLE

    HandlePlayerPosition()
    HandlePhases()
    HandleStates()
    HandleAttacks()
    HandleHits()
    DebugInputs()

    -- Debug Logs
    lua_table.SystemFunctions:LOG ("Kikimora Health: " .. lua_table.current_health)
    lua_table.SystemFunctions:LOG ("Kikimora Health Percentage : " .. lua_table.current_health_percentage)
    --lua_table.SystemFunctions:LOG ("Kikimora Phase: " .. current_phase)
    --lua_table.SystemFunctions:LOG ("Kikimora State: " .. current_state)
    --lua_table.SystemFunctions:LOG ("Kikimora Attack Pattern: " .. current_attack_pattern)
    --lua_table.SystemFunctions:LOG ("Kikimora Attack Type: " .. current_attack_type)
    --lua_table.SystemFunctions:LOG ("Kikimora Attack Subdivision: " .. current_attack_subdivision)

    
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(my_UID)
	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)

	if layer == layers.player  --Checks if its player collider layer
	then
        -- CHECK IF PLAYER UNDER
        if collider == P1_id 
        then
            if current_state ~= state.JUMPING
            then
                P1_timer_under_boss = game_time + lua_table.under_time
            else
                P1_under_boss_waiting = true
            end
        end

        if collider == P2_id
        then
            if current_state ~= state.JUMPING
            then
                P2_timer_under_boss = game_time + lua_table.under_time
            else
                P2_under_boss_waiting = true
            end
        end
    end
end

function lua_table:OnTriggerExit()
	local collider = lua_table.PhysicsFunctions:OnTriggerExit(my_UID)
	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)

	if layer == layers.player --Checks if its player collider layer
	then
        -- CHECK IF PLAYER UNDER
        if collider == P1_id
        then
            P1_timer_under_boss = -1
            P1_under_boss_waiting = false
        end

        if collider == P2_id
        then
            P2_timer_under_boss = -1
            P2_under_boss_waiting = false
        end
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
    local collider = lua_table.PhysicsFunctions:OnCollisionEnter(my_UID)
	-- lua_table.SystemFunctions:LOG("T:" .. collider)
end
	return lua_table
end

