function GetTableKikimoraScript_v5 ()
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

-----------------------------------------------------------------------------------------
-- Health Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.current_health = 0
lua_table.health = 2000

local is_dead = false

-- Health Percentages for each phase
lua_table.current_health_percentage = 0
lua_table.health_percentage_phase_1 = 100
lua_table.health_percentage_phase_2 = 66
lua_table.health_percentage_phase_3 = 33

lua_table.speed_modificator_phase_2 = 1.5
lua_table.speed_modificator_phase_3 = 2

local damage_received_real = -1
lua_table.damage_received_mod = 1.0
lua_table.damage_received_orig = -1

-----------------------------------------------------------------------------------------
-- Movement Variables
-----------------------------------------------------------------------------------------

-- Distance of player/s to activate the boss
lua_table.awakening_distance = 20
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

-----------------------------------------------------------------------------------------
-- Attacks Variables
-----------------------------------------------------------------------------------------
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
	roar = { att_damage = 0, att_effect = attack_effect.STUN, att_duration = 0, att_anticipation_duration = 0, att_execution_duration = 0, att_recovery_duration = 0, att_cooldown_time = 30, att_cooldown_bool = false, att_timer = 0}
}

local attack_finished = false
local attack_started = true


-----------------------------------------------------------------------------------------
-- Animation Variables
-----------------------------------------------------------------------------------------
local animation = 
{
    idle = { anim_name = "idle", anim_frames = 42, anim_speed = 30, anim_blendtime = 0 },
    
    leash = { anim_name = "leash", anim_frames = 68, anim_speed = 30, anim_blendtime = 0 },
    -- Update when new animations come

    sweep = { anim_name = "sweep", anim_frames = 112, anim_speed = 30, anim_blendtime = 0 },
    -- Update when new animations come
    
	stomp = { anim_name = "stomp", anim_frames = 109, anim_speed = 30, anim_blendtime = 0 },
	roar = { anim_name = "roar", anim_frames = 130, anim_speed = 30, anim_blendtime = 0 }
}

-- -----------------------------------------------------------------------------------------
-- -- Collider Variables
-- -----------------------------------------------------------------------------------------

local attack_collider = --most vars initialized in awake
{
    leash_left_pivot = { coll_name = "Leash_Left_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} }, 
    leash_left = { coll_name = "Leash_Left_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} },

    leash_right_pivot = { coll_name = "Leash_Right_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} }, 
    leash_right = { coll_name = "Leash_Right_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} }, 

    sweep_left_pivot = { coll_name = "Sweep_Left_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} },
    sweep_left = { coll_name = "Sweep_Left_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} },
    
    sweep_right_pivot = { coll_name = "Sweep_Right_Pivot", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} },
    sweep_right = { coll_name = "Sweep_Right_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} },
    
    sweep = { coll_name = "Sweep_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} },
    
    stomp = { coll_name = "Stomp_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} },
    
    roar = { coll_name = "Roar_Attack", coll_UID = 0, coll_active = false, coll_init_pos = {}, coll_final_pos = {}, coll_current_pos = {}, coll_velocity = {}, coll_init_rot = {}, coll_final_rot = {}, coll_current_rot = {}, coll_ang_velocity = {}, coll_init_scale = {}, coll_final_scale = {}, coll_current_scale = {}, coll_growth_velocity = {} }
}

-- Collider Layers
local layers = 
{
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4
}	
lua_table.collider_damage = 0
lua_table.collider_effect = 0

-----------------------------------------------------------------------------------------
-- Game Objects Variables
-----------------------------------------------------------------------------------------

-- Kikimora GO UID
lua_table.my_UID = 0
lua_table.my_position = {}

lua_table.scene_UID = 0

-- Kikimora target GO names
lua_table.geralt_GO = "Geralt"
lua_table.jaskier_GO = "Jaskier"
lua_table.yennefer_GO = "Yennefer"
lua_table.ciri_GO = "Ciri"

-- P1
local P1_id = 0
lua_table.P1_pos = {}
lua_table.P1_script = {}
lua_table.P1_distance = {}
local P1_abs_distance = nil 

-- P2
local P2_id = 0
lua_table.P2_pos = {}
lua_table.P2_script = {}
lua_table.P2_distance = {}
local P2_abs_distance = nil

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
local state_timer = 0
local animation_timer = 0

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
            current_state = state.DEAD
        end

        if lua_table.InputFunctions:KeyDown("l")
        then 
            lua_table.current_health = lua_table.current_health - 200
        end

        if lua_table.InputFunctions:KeyDown("j")
        then 
            current_state = state.AWAKENING
            lua_table.awakened = true
        end
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
            current_state = state.SWAPPING_PHASE
            current_phase = phase.MAD
            start_swapping = true
            lua_table.SystemFunctions:LOG ("Kikimora: Swapping to phase 2")

            -- Updating animations speed
            animation.leash.anim_speed = animation.leash.anim_speed * lua_table.speed_modificator_phase_2
            
            animation.sweep.anim_speed = animation.sweep.anim_speed * lua_table.speed_modificator_phase_2

            animation.stomp.anim_speed = animation.stomp.anim_speed * lua_table.speed_modificator_phase_2

            animation.roar.anim_speed = animation.roar.anim_speed * lua_table.speed_modificator_phase_2

            -- Updating attacks durations

            attack.leash_left.att_duration = animation.leash.anim_frames / animation.leash.anim_speed
            attack.leash_left.att_anticipation_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_left.att_execution_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_left.att_recovery_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
    
            attack.leash_right.att_duration = animation.leash.anim_frames / animation.leash.anim_speed
            attack.leash_right.att_anticipation_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_right.att_execution_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_right.att_recovery_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS

            attack.sweep_left.att_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_left.att_anticipation_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_left.att_execution_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_left.att_recovery_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS

            attack.sweep_right.att_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_right.att_anticipation_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_right.att_execution_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_right.att_recovery_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS

            attack.stomp.att_duration = animation.stomp.anim_frames / animation.stomp.anim_speed
            attack.stomp.att_anticipation_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
            attack.stomp.att_execution_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
            attack.stomp.att_recovery_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
    
            attack.roar.att_duration = animation.roar.anim_frames / animation.roar.anim_speed
            attack.roar.att_anticipation_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS
            attack.roar.att_execution_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS
            attack.roar.att_recovery_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS

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

        end
    -- Checking if inside phase 3 threshold
    elseif lua_table.current_health_percentage <= lua_table.health_percentage_phase_3
    then
        if current_phase ~= phase.ENRAGED
        then
            current_state = state.SWAPPING_PHASE
            current_phase = phase.ENRAGED
            start_swapping = true
            lua_table.SystemFunctions:LOG ("Kikimora: Swapping to phase 3")

            -- Updating animations speed

            animation.leash.anim_speed = animation.leash.anim_speed * lua_table.speed_modificator_phase_3
            
            animation.sweep.anim_speed = animation.sweep.anim_speed * lua_table.speed_modificator_phase_3

            animation.stomp.anim_speed = animation.stomp.anim_speed * lua_table.speed_modificator_phase_3

            animation.roar.anim_speed = animation.roar.anim_speed * lua_table.speed_modificator_phase_3

            -- Updating attacks durations
            attack.leash_left.att_duration = animation.leash.anim_frames / animation.leash.anim_speed
            attack.leash_left.att_anticipation_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_left.att_execution_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_left.att_recovery_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
    
            attack.leash_right.att_duration = animation.leash.anim_frames / animation.leash.anim_speed
            attack.leash_right.att_anticipation_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_right.att_execution_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
            attack.leash_right.att_recovery_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS

            attack.sweep_left.att_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_left.att_anticipation_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_left.att_execution_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_left.att_recovery_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS

            attack.sweep_right.att_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_right.att_anticipation_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_right.att_execution_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
            attack.sweep_right.att_recovery_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS

            attack.stomp.att_duration = animation.stomp.anim_frames / animation.stomp.anim_speed
            attack.stomp.att_anticipation_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
            attack.stomp.att_execution_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
            attack.stomp.att_recovery_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
    
            attack.roar.att_duration = animation.roar.anim_frames / animation.roar.anim_speed
            attack.roar.att_anticipation_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS
            attack.roar.att_execution_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS
            attack.roar.att_recovery_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS

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
                lua_table.AnimationFunctions:PlayAnimation(animation.roar.anim_name, animation.roar.anim_speed, lua_table.my_UID) --FOR NOW

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.roar.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.roar.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.roar.coll_current_pos[x] = attack_collider.roar.coll_init_pos[x]
                attack_collider.roar.coll_current_pos[y] = attack_collider.roar.coll_init_pos[y]
                attack_collider.roar.coll_current_pos[z] = attack_collider.roar.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.roar.coll_current_pos[x], attack_collider.roar.coll_current_pos[y], attack_collider.roar.coll_current_pos[z], attack_collider.roar.coll_UID)
                
                -- Sets collider current rotation to initial rotation
                attack_collider.roar.coll_current_rot[x] = attack_collider.roar.coll_init_rot[x]
                attack_collider.roar.coll_current_rot[y] = attack_collider.roar.coll_init_rot[y]
                attack_collider.roar.coll_current_rot[z] = attack_collider.roar.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.roar.coll_current_rot[x], attack_collider.roar.coll_current_rot[y], attack_collider.roar.coll_current_rot[z], attack_collider.roar.coll_UID)
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
                -- START EXECUTION OF ATTACK ANIMATION

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
                attack.roar.att_cooldown_bool = true
                attack.roar.att_timer = game_time + attack.roar.att_cooldown_time

                attack_finished = true

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
                lua_table.AnimationFunctions:PlayAnimation(animation.stomp.anim_name, animation.stomp.anim_speed, lua_table.my_UID) --FOR NOW

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.stomp.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.stomp.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.stomp.coll_current_pos[x] = attack_collider.stomp.coll_init_pos[x]
                attack_collider.stomp.coll_current_pos[y] = attack_collider.stomp.coll_init_pos[y]
                attack_collider.stomp.coll_current_pos[z] = attack_collider.stomp.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.stomp.coll_current_pos[x], attack_collider.stomp.coll_current_pos[y], attack_collider.stomp.coll_current_pos[z], attack_collider.stomp.coll_UID)
                
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

                lua_table.TransformFunctions:SetPosition(attack_collider.stomp.coll_current_pos[x], attack_collider.stomp.coll_current_pos[y], attack_collider.stomp.coll_current_pos[z], attack_collider.stomp.coll_UID)

                -- Sets damage
                lua_table.collider_damage = attack.stomp.att_damage
                -- Sets effect
                lua_table.collider_effect = attack.stomp.att_effect -- attack_effect.knockback TODO: Figure out how to send knockback to players.
            end

            if game_time > attack_subdivision_timer --Check if execution is finished
            then
                current_attack_subdivision = attack_subdivision.RECOVERY
                -- START EXECUTION OF ATTACK ANIMATION

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.stomp.att_recovery_duration

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                attack.stomp.att_cooldown_bool = true
                attack.stomp.att_timer = game_time + attack.stomp.att_cooldown_time

                attack_finished = true

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

                lua_table.SystemFunctions:LOG ("Kikimora: Stomp Left Finish")
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
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep.anim_name, animation.sweep.anim_speed, lua_table.my_UID) --FOR NOW

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_left.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.sweep_left.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.sweep_left_pivot.coll_current_pos[x] = attack_collider.sweep_left_pivot.coll_init_pos[x]
                attack_collider.sweep_left_pivot.coll_current_pos[y] = attack_collider.sweep_left_pivot.coll_init_pos[y]
                attack_collider.sweep_left_pivot.coll_current_pos[z] = attack_collider.sweep_left_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.sweep_left_pivot.coll_current_pos[x], attack_collider.sweep_left_pivot.coll_current_pos[y], attack_collider.sweep_left_pivot.coll_current_pos[z], attack_collider.sweep_left_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.sweep_left_pivot.coll_current_rot[x] = attack_collider.sweep_left_pivot.coll_init_rot[x]
                attack_collider.sweep_left_pivot.coll_current_rot[y] = attack_collider.sweep_left_pivot.coll_init_rot[y]
                attack_collider.sweep_left_pivot.coll_current_rot[z] = attack_collider.sweep_left_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_left_pivot.coll_current_rot[x], attack_collider.sweep_left_pivot.coll_current_rot[y], attack_collider.sweep_left_pivot.coll_current_rot[z], attack_collider.sweep_left_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_left.coll_current_pos[x] = attack_collider.sweep_left.coll_init_pos[x]
                attack_collider.sweep_left.coll_current_pos[y] = attack_collider.sweep_left.coll_init_pos[y]
                attack_collider.sweep_left.coll_current_pos[z] = attack_collider.sweep_left.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.sweep_left.coll_current_pos[x], attack_collider.sweep_left.coll_current_pos[y], attack_collider.sweep_left.coll_current_pos[z], attack_collider.sweep_left.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_left.coll_current_rot[x] = attack_collider.sweep_left.coll_init_rot[x]
                attack_collider.sweep_left.coll_current_rot[y] = attack_collider.sweep_left.coll_init_rot[y]
                attack_collider.sweep_left.coll_current_rot[z] = attack_collider.sweep_left.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_left.coll_current_rot[x], attack_collider.sweep_left.coll_current_rot[y], attack_collider.sweep_left.coll_current_rot[z], attack_collider.sweep_left.coll_UID)
            
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
                -- START EXECUTION OF ATTACK ANIMATION

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_left.att_recovery_duration

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                attack.sweep_left.att_cooldown_bool = true
                attack.sweep_left.att_timer = game_time + attack.sweep_left.att_cooldown_time

                attack_finished = true

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
                lua_table.AnimationFunctions:PlayAnimation(animation.sweep.anim_name, animation.sweep.anim_speed, lua_table.my_UID) --FOR NOW

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_right.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.sweep_right.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.sweep_right_pivot.coll_current_pos[x] = attack_collider.sweep_right_pivot.coll_init_pos[x]
                attack_collider.sweep_right_pivot.coll_current_pos[y] = attack_collider.sweep_right_pivot.coll_init_pos[y]
                attack_collider.sweep_right_pivot.coll_current_pos[z] = attack_collider.sweep_right_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.sweep_right_pivot.coll_current_pos[x], attack_collider.sweep_right_pivot.coll_current_pos[y], attack_collider.sweep_right_pivot.coll_current_pos[z], attack_collider.sweep_right_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.sweep_right_pivot.coll_current_rot[x] = attack_collider.sweep_right_pivot.coll_init_rot[x]
                attack_collider.sweep_right_pivot.coll_current_rot[y] = attack_collider.sweep_right_pivot.coll_init_rot[y]
                attack_collider.sweep_right_pivot.coll_current_rot[z] = attack_collider.sweep_right_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_right_pivot.coll_current_rot[x], attack_collider.sweep_right_pivot.coll_current_rot[y], attack_collider.sweep_right_pivot.coll_current_rot[z], attack_collider.sweep_right_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_right.coll_current_pos[x] = attack_collider.sweep_right.coll_init_pos[x]
                attack_collider.sweep_right.coll_current_pos[y] = attack_collider.sweep_right.coll_init_pos[y]
                attack_collider.sweep_right.coll_current_pos[z] = attack_collider.sweep_right.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.sweep_right.coll_current_pos[x], attack_collider.sweep_right.coll_current_pos[y], attack_collider.sweep_right.coll_current_pos[z], attack_collider.sweep_right.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.sweep_right.coll_current_rot[x] = attack_collider.sweep_right.coll_init_rot[x]
                attack_collider.sweep_right.coll_current_rot[y] = attack_collider.sweep_right.coll_init_rot[y]
                attack_collider.sweep_right.coll_current_rot[z] = attack_collider.sweep_right.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.sweep_right.coll_current_rot[x], attack_collider.sweep_right.coll_current_rot[y], attack_collider.sweep_right.coll_current_rot[z], attack_collider.sweep_right.coll_UID)
            
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
                -- START EXECUTION OF ATTACK ANIMATION

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.sweep_right.att_recovery_duration

                -- Deactivates Collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                attack.sweep_right.att_cooldown_bool = true
                attack.sweep_right.att_timer = game_time + attack.sweep_right.att_cooldown_time

                attack_finished = true

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
                lua_table.AnimationFunctions:PlayAnimation(animation.leash.anim_name, animation.leash.anim_speed, lua_table.my_UID) --FOR NOW

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_left.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.leash_left.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.leash_left_pivot.coll_current_pos[x] = attack_collider.leash_left_pivot.coll_init_pos[x]
                attack_collider.leash_left_pivot.coll_current_pos[y] = attack_collider.leash_left_pivot.coll_init_pos[y]
                attack_collider.leash_left_pivot.coll_current_pos[z] = attack_collider.leash_left_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.leash_left_pivot.coll_current_pos[x], attack_collider.leash_left_pivot.coll_current_pos[y], attack_collider.leash_left_pivot.coll_current_pos[z], attack_collider.leash_left_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.leash_left_pivot.coll_current_rot[x] = attack_collider.leash_left_pivot.coll_init_rot[x]
                attack_collider.leash_left_pivot.coll_current_rot[y] = attack_collider.leash_left_pivot.coll_init_rot[y]
                attack_collider.leash_left_pivot.coll_current_rot[z] = attack_collider.leash_left_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_left_pivot.coll_current_rot[x], attack_collider.leash_left_pivot.coll_current_rot[y], attack_collider.leash_left_pivot.coll_current_rot[z], attack_collider.leash_left_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.leash_left.coll_current_pos[x] = attack_collider.leash_left.coll_init_pos[x]
                attack_collider.leash_left.coll_current_pos[y] = attack_collider.leash_left.coll_init_pos[y]
                attack_collider.leash_left.coll_current_pos[z] = attack_collider.leash_left.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.leash_left.coll_current_pos[x], attack_collider.leash_left.coll_current_pos[y], attack_collider.leash_left.coll_current_pos[z], attack_collider.leash_left.coll_UID)
                
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

            if game_time > attack_subdivision_timer --Check if execution is finished
            then
                current_attack_subdivision = attack_subdivision.RECOVERY
                -- START EXECUTION OF ATTACK ANIMATION

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_left.att_recovery_duration

                -- Deactivate collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                attack.leash_left.att_cooldown_bool = true
                attack.leash_left.att_timer = game_time + attack.leash_left.att_cooldown_time

                attack_finished = true

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

                lua_table.SystemFunctions:LOG ("Kikimora: Leash Left Finish")
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
                lua_table.AnimationFunctions:PlayAnimation(animation.leash.anim_name, animation.leash.anim_speed, lua_table.my_UID) --FOR NOW

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_right.att_execution_duration

                -- Activates collider                               
                lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_collider.leash_right.coll_UID)
                
                -- Sets collider_pivot current position to initial position
                attack_collider.leash_right_pivot.coll_current_pos[x] = attack_collider.leash_right_pivot.coll_init_pos[x]
                attack_collider.leash_right_pivot.coll_current_pos[y] = attack_collider.leash_right_pivot.coll_init_pos[y]
                attack_collider.leash_right_pivot.coll_current_pos[z] = attack_collider.leash_right_pivot.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.leash_right_pivot.coll_current_pos[x], attack_collider.leash_right_pivot.coll_current_pos[y], attack_collider.leash_right_pivot.coll_current_pos[z], attack_collider.leash_right_pivot.coll_UID)
                
                -- Sets collider_pivot current rotation to initial rotation
                attack_collider.leash_right_pivot.coll_current_rot[x] = attack_collider.leash_right_pivot.coll_init_rot[x]
                attack_collider.leash_right_pivot.coll_current_rot[y] = attack_collider.leash_right_pivot.coll_init_rot[y]
                attack_collider.leash_right_pivot.coll_current_rot[z] = attack_collider.leash_right_pivot.coll_init_rot[z]
                
                lua_table.TransformFunctions:SetObjectRotation(attack_collider.leash_right_pivot.coll_current_rot[x], attack_collider.leash_right_pivot.coll_current_rot[y], attack_collider.leash_right_pivot.coll_current_rot[z], attack_collider.leash_right_pivot.coll_UID)
                
                -- Sets collider current position to initial position
                attack_collider.leash_right.coll_current_pos[x] = attack_collider.leash_right.coll_init_pos[x]
                attack_collider.leash_right.coll_current_pos[y] = attack_collider.leash_right.coll_init_pos[y]
                attack_collider.leash_right.coll_current_pos[z] = attack_collider.leash_right.coll_init_pos[z]
                
                lua_table.TransformFunctions:SetPosition(attack_collider.leash_right.coll_current_pos[x], attack_collider.leash_right.coll_current_pos[y], attack_collider.leash_right.coll_current_pos[z], attack_collider.leash_right.coll_UID)
                
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

            if game_time > attack_subdivision_timer --Check if execution is finished
            then
                current_attack_subdivision = attack_subdivision.RECOVERY
                -- START EXECUTION OF ATTACK ANIMATION

                -- Execution Timer
                attack_subdivision_timer = game_time + attack.leash_right.att_recovery_duration

                -- Deactivates Collider
                lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)
            end
        end

        --RECOVERY SUBDIVISION
        if current_attack_subdivision == attack_subdivision.RECOVERY
        then
            if game_time >= attack_subdivision_timer --Checks if attack finished
            then
                attack.leash_right.att_cooldown_bool = true
                attack.leash_right.att_timer = game_time + attack.leash_right.att_cooldown_time

                attack_finished = true

                current_attack_type = attack_type.TO_BE_DETERMINED
                current_attack_subdivision = attack_subdivision.TO_BE_DETERMINED

                lua_table.SystemFunctions:LOG ("Kikimora: Leash Right Finish")
            end
        end
    end
end

local function HandleAttacks()

    -- For now kikimora will always want to attack (except when all attacks are on cooldown)
    if current_state ~= state.ATTACKING and current_state ~= state.AWAKENING and current_state ~= state.SWAPPING_PHASE and current_state ~= state.UNACTIVE and current_state ~= state.DEAD
    then
        -- And will always use this priority (in order to avoid spam of the same attack they have different cooldowns, The higher the priority the higher the cooldown)
        -- Using elseif so only executes one (mental note, had a lapsus)
        if attack.roar.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleRoarAttack()

        elseif attack.stomp.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleStompAttack()

        elseif attack.sweep_left.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleSweepLeftAttack()

        elseif attack.sweep_right.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleSweepRightAttack()

        elseif attack.leash_right.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleLeashLeftAttack()

        elseif attack.leash_right.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleLeashRightAttack()
        end

    elseif current_state == state.ATTACKING -- if already attacking
    then
        if current_attack_type == attack_type.ATTACKING_ROAR
        then
            HandleRoarAttack()
        end

        if current_attack_type == attack_type.ATTACKING_STOMP
        then
            HandleStompAttack()
        end

        if current_attack_type == attack_type.ATTACKING_SWEEP_LEFT
        then
            HandleSweepLeftAttack()
        end

        if current_attack_type == attack_type.ATTACKING_SWEEP_RIGHT
        then
            HandleSweepRightAttack()
        end

        if current_attack_type == attack_type.ATTACKING_LEASH_LEFT
        then
            HandleLeashLeftAttack()
        end

        if current_attack_type == attack_type.ATTACKING_LEASH_RIGHT
        then
            HandleLeashRightAttack()
        end
    end

    -- Updating state maybe should do it in handle states

    -- Updating cooldowns
    if attack.roar.att_cooldown_bool == true
    then
        if game_time >= attack.roar.att_timer and attack.roar.att_timer ~= 0
        then
            attack.roar.att_cooldown_bool = false
        end
    end

    if attack.stomp.att_cooldown_bool == true
    then
        if game_time >= attack.stomp.att_timer and attack.stomp.att_timer ~= 0
        then
            attack.stomp.att_cooldown_bool = false
        end
    end

    if attack.sweep_left.att_cooldown_bool == true
    then
        if game_time >= attack.sweep_left.att_timer and attack.sweep_left.att_timer ~= 0
        then
            attack.sweep_left.att_cooldown_bool = false
        end
    end

    if attack.sweep_right.att_cooldown_bool == true
    then
        if game_time >= attack.sweep_right.att_timer and attack.sweep_right.att_timer ~= 0
        then
            attack.sweep_right.att_cooldown_bool = false
        end
    end

    if attack.leash_left.att_cooldown_bool == true
    then
        if game_time >= attack.leash_left.att_timer and attack.leash_left.att_timer ~= 0
        then
            attack.leash_left.att_cooldown_bool = false
        end
    end

    if attack.leash_right.att_cooldown_bool == true
    then
        if game_time >= attack.leash_right.att_timer and attack.leash_right.att_timer ~= 0
        then
            attack.leash_right.att_cooldown_bool = false
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
        state_timer = game_time + 5 -- duration of awakening animation
        -- PLAY AWAKENING ANIMATION
    end

    if current_state == state.AWAKENING
    then
        if game_time >= state_timer
        then
            current_state = state.IDLE
            lua_table.SystemFunctions:LOG ("Kikimora: AWAKENING ended now idle")
        end
    end

    if current_state == state.IDLE
    then
        if game_time >= state_timer
        then
            lua_table.AnimationFunctions:PlayAnimation(animation.idle.anim_name, animation.idle.anim_speed, lua_table.my_UID)
            state_timer = game_time + (animation.idle.anim_frames / animation.idle.anim_speed)
        end
    end

    if current_state == state.ATTACKING
    then
        if attack_finished == true
        then 
            attack_finished = false
            current_state = state.IDLE
            lua_table.SystemFunctions:LOG ("Kikimora: Attacks on cooldown now idle")
        end
    end

    if current_state == state.MOVING
    then
        -- Not moving for now
    end

    if current_state == state.JUMPING
    then
        -- Not jumping for now
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
            -- This is while I don't have a Swapping phase animation (maybe with a stun + roar would make the same effect)
            lua_table.AnimationFunctions:PlayAnimation(animation.roar.anim_name, animation.roar.anim_speed / 2, lua_table.my_UID) -- It will have a times 2 duration
            animation_timer = game_time + attack.roar.att_duration * 2
            start_swapping = false
        end
    
        if game_time >= animation_timer
        then 
            current_state = state.IDLE
        end
    end

    if current_state == state.SPAWNING_MINIONS
    then
        -- Play spaawning minions animation
    end

    if lua_table.current_health <= 0
    then 
        current_state = state.DEAD
    end

    if current_state == state.DEAD
    then
        -- Play death animation
        -- DESPAWN BOSS
        -- CALL SCENE FUNCTION TO MAIN MENU
        -- Shut all particles
        lua_table.awakened = false
        lua_table.GameObjectFunctions:SetActiveGameObject(false, lua_table.my_UID)
        
        if lua_table.scene_UID ~= 0
        then
            lua_table.SeceneFunctions:LoadScene(lua_table.scene_UID)
        end
    end
end

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Kikimora Script on AWAKE")
	
	-- Get my own UID
    lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()

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
	-- Attacks Init
    ---------------------------------------------------------------------------

    -- Attacks duartion
    attack.leash_left.att_duration = animation.leash.anim_frames / animation.leash.anim_speed
    attack.leash_left.att_anticipation_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
    attack.leash_left.att_execution_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
    attack.leash_left.att_recovery_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
    
    attack.leash_right.att_duration = animation.leash.anim_frames / animation.leash.anim_speed
    attack.leash_right.att_anticipation_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
    attack.leash_right.att_execution_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS
    attack.leash_right.att_recovery_duration = animation.leash.anim_frames / animation.leash.anim_speed --UPDATE WHEN ANIMATIONS

    attack.sweep_left.att_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
    attack.sweep_left.att_anticipation_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
    attack.sweep_left.att_execution_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
    attack.sweep_left.att_recovery_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS

    attack.sweep_right.att_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
    attack.sweep_right.att_anticipation_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
    attack.sweep_right.att_execution_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS
    attack.sweep_right.att_recovery_duration = animation.sweep.anim_frames / animation.sweep.anim_speed --UPDATE WHEN ANIMATIONS

    attack.stomp.att_duration = animation.stomp.anim_frames / animation.stomp.anim_speed
    attack.stomp.att_anticipation_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
    attack.stomp.att_execution_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
    attack.stomp.att_recovery_duration = animation.stomp.anim_frames / animation.stomp.anim_speed --UPDATE WHEN ANIMATIONS
    
    attack.roar.att_duration = animation.roar.anim_frames / animation.roar.anim_speed
    attack.roar.att_anticipation_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS
    attack.roar.att_execution_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS
    attack.roar.att_recovery_duration = animation.roar.anim_frames / animation.roar.anim_speed --UPDATE WHEN ANIMATIONS
    
    ---------------------------------------------------------------------------
	-- Attack Colliders Init
    ---------------------------------------------------------------------------
    
    -- Attack colliders UIDs 
    attack_collider.roar.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.roar.coll_name)

    attack_collider.stomp.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.stomp.coll_name)

    attack_collider.sweep_left_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_left_pivot.coll_name)
    attack_collider.sweep_left.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_left.coll_name)

    attack_collider.sweep_right_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_right_pivot.coll_name)
    attack_collider.sweep_right.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.sweep_right.coll_name)

    attack_collider.leash_left_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_left_pivot.coll_name)
    attack_collider.leash_left.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_left.coll_name)

    attack_collider.leash_right_pivot.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_right_pivot.coll_name)
    attack_collider.leash_right.coll_UID = lua_table.GameObjectFunctions:FindGameObject(attack_collider.leash_right.coll_name)


    -- Setting them unactive
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.stomp.coll_UID)
    attack_collider.stomp.coll_active = false

    --lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left_pivot.coll_UID)
    --attack_collider.sweep_left_pivot.coll_active = false
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_left.coll_UID)
    attack_collider.sweep_left.coll_active = false

    --lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right_pivot.coll_UID)
    --attack_collider.sweep_right_pivot.coll_active = false
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.sweep_right.coll_UID)
    attack_collider.sweep_right.coll_active = false

    --lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left_pivot.coll_UID)
    --attack_collider.leash_left_pivot.coll_active = false
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_left.coll_UID)
    attack_collider.leash_left.coll_active = false

    --lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right_pivot.coll_UID)
    --attack_collider.leash_right_pivot.coll_active = false
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.leash_right.coll_UID)
    attack_collider.leash_right.coll_active = false

    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_collider.roar.coll_UID)
    attack_collider.roar.coll_active = false

    -- Setting positions, rotations, velocities and angular velocities(only depend on att_execution_duration)

    attack_collider.leash_left_pivot.coll_init_pos[x] = 5
    attack_collider.leash_left_pivot.coll_init_pos[y] = 0
    attack_collider.leash_left_pivot.coll_init_pos[z] = 5
    attack_collider.leash_left_pivot.coll_final_pos[x] = 5
    attack_collider.leash_left_pivot.coll_final_pos[y] = 0
    attack_collider.leash_left_pivot.coll_final_pos[z] = 5
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

    attack_collider.leash_left.coll_init_pos[x] = 15
    attack_collider.leash_left.coll_init_pos[y] = 0
    attack_collider.leash_left.coll_init_pos[z] = 0
    attack_collider.leash_left.coll_final_pos[x] = 15
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
    attack_collider.leash_left.coll_init_scale[x] = 30
    attack_collider.leash_left.coll_init_scale[y] = 5
    attack_collider.leash_left.coll_init_scale[z] = 5
    attack_collider.leash_left.coll_final_scale[x] = 30
    attack_collider.leash_left.coll_final_scale[y] = 5
    attack_collider.leash_left.coll_final_scale[z] = 5
    attack_collider.leash_left.coll_growth_velocity[x] = (attack_collider.leash_left.coll_init_scale[x] - attack_collider.leash_left.coll_final_scale[x]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_growth_velocity[y] = (attack_collider.leash_left.coll_init_scale[y] - attack_collider.leash_left.coll_final_scale[y]) / attack.leash_left.att_execution_duration 
    attack_collider.leash_left.coll_growth_velocity[z] = (attack_collider.leash_left.coll_init_scale[z] - attack_collider.leash_left.coll_final_scale[z]) / attack.leash_left.att_execution_duration

    attack_collider.leash_right_pivot.coll_init_pos[x] = -5
    attack_collider.leash_right_pivot.coll_init_pos[y] = 0
    attack_collider.leash_right_pivot.coll_init_pos[z] = 5
    attack_collider.leash_right_pivot.coll_final_pos[x] = -5
    attack_collider.leash_right_pivot.coll_final_pos[y] = 0
    attack_collider.leash_right_pivot.coll_final_pos[z] = 5
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

    attack_collider.leash_right.coll_init_pos[x] = -15
    attack_collider.leash_right.coll_init_pos[y] = 0
    attack_collider.leash_right.coll_init_pos[z] = 0
    attack_collider.leash_right.coll_final_pos[x] = -15
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
    attack_collider.leash_right.coll_init_scale[x] = 30
    attack_collider.leash_right.coll_init_scale[y] = 5
    attack_collider.leash_right.coll_init_scale[z] = 5
    attack_collider.leash_right.coll_final_scale[x] = 30
    attack_collider.leash_right.coll_final_scale[y] = 5
    attack_collider.leash_right.coll_final_scale[z] = 5
    attack_collider.leash_right.coll_growth_velocity[x] = (attack_collider.leash_right.coll_init_scale[x] - attack_collider.leash_right.coll_final_scale[x]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right.coll_growth_velocity[y] = (attack_collider.leash_right.coll_init_scale[y] - attack_collider.leash_right.coll_final_scale[y]) / attack.leash_right.att_execution_duration 
    attack_collider.leash_right.coll_growth_velocity[z] = (attack_collider.leash_right.coll_init_scale[z] - attack_collider.leash_right.coll_final_scale[z]) / attack.leash_right.att_execution_duration

    attack_collider.sweep_left_pivot.coll_init_pos[x] = 0
    attack_collider.sweep_left_pivot.coll_init_pos[y] = 0
    attack_collider.sweep_left_pivot.coll_init_pos[z] = 0
    attack_collider.sweep_left_pivot.coll_final_pos[x] = 0
    attack_collider.sweep_left_pivot.coll_final_pos[y] = 0
    attack_collider.sweep_left_pivot.coll_final_pos[z] = 0
    attack_collider.sweep_left_pivot.coll_velocity[x] = (attack_collider.sweep_left_pivot.coll_final_pos[x] - attack_collider.sweep_left_pivot.coll_init_pos[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left_pivot.coll_velocity[y] = (attack_collider.sweep_left_pivot.coll_final_pos[y] - attack_collider.sweep_left_pivot.coll_init_pos[y]) / attack.sweep_left.att_execution_duration
    attack_collider.sweep_left_pivot.coll_velocity[z] = (attack_collider.sweep_left_pivot.coll_final_pos[z] - attack_collider.sweep_left_pivot.coll_init_pos[z]) / attack.sweep_left.att_execution_duration
    attack_collider.sweep_left_pivot.coll_init_rot[x] = 0
    attack_collider.sweep_left_pivot.coll_init_rot[y] = 0
    attack_collider.sweep_left_pivot.coll_init_rot[z] = 0
    attack_collider.sweep_left_pivot.coll_final_rot[x] = 0
    attack_collider.sweep_left_pivot.coll_final_rot[y] = -89
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

    attack_collider.sweep_left.coll_init_pos[x] = 15
    attack_collider.sweep_left.coll_init_pos[y] = 0
    attack_collider.sweep_left.coll_init_pos[z] = 0
    attack_collider.sweep_left.coll_final_pos[x] = 15
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
    attack_collider.sweep_left.coll_init_scale[x] = 30
    attack_collider.sweep_left.coll_init_scale[y] = 3
    attack_collider.sweep_left.coll_init_scale[z] = 3 
    attack_collider.sweep_left.coll_final_scale[x] = 30
    attack_collider.sweep_left.coll_final_scale[y] = 3
    attack_collider.sweep_left.coll_final_scale[z] = 3
    attack_collider.sweep_left.coll_growth_velocity[x] = (attack_collider.sweep_left.coll_init_scale[x] - attack_collider.sweep_left.coll_final_scale[x]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_growth_velocity[y] = (attack_collider.sweep_left.coll_init_scale[y] - attack_collider.sweep_left.coll_final_scale[y]) / attack.sweep_left.att_execution_duration 
    attack_collider.sweep_left.coll_growth_velocity[z] = (attack_collider.sweep_left.coll_init_scale[z] - attack_collider.sweep_left.coll_final_scale[z]) / attack.sweep_left.att_execution_duration

    attack_collider.sweep_right_pivot.coll_init_pos[x] = 0
    attack_collider.sweep_right_pivot.coll_init_pos[y] = 0
    attack_collider.sweep_right_pivot.coll_init_pos[z] = 0
    attack_collider.sweep_right_pivot.coll_final_pos[x] = 0
    attack_collider.sweep_right_pivot.coll_final_pos[y] = 0
    attack_collider.sweep_right_pivot.coll_final_pos[z] = 0
    attack_collider.sweep_right_pivot.coll_velocity[x] = (attack_collider.sweep_right_pivot.coll_final_pos[x] - attack_collider.sweep_right_pivot.coll_init_pos[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right_pivot.coll_velocity[y] = (attack_collider.sweep_right_pivot.coll_final_pos[y] - attack_collider.sweep_right_pivot.coll_init_pos[y]) / attack.sweep_right.att_execution_duration
    attack_collider.sweep_right_pivot.coll_velocity[z] = (attack_collider.sweep_right_pivot.coll_final_pos[z] - attack_collider.sweep_right_pivot.coll_init_pos[z]) / attack.sweep_right.att_execution_duration
    attack_collider.sweep_right_pivot.coll_init_rot[x] = 0
    attack_collider.sweep_right_pivot.coll_init_rot[y] = 0
    attack_collider.sweep_right_pivot.coll_init_rot[z] = 0
    attack_collider.sweep_right_pivot.coll_final_rot[x] = 0
    attack_collider.sweep_right_pivot.coll_final_rot[y] = 89
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
    
    attack_collider.sweep_right.coll_init_pos[x] = -15
    attack_collider.sweep_right.coll_init_pos[y] = 0
    attack_collider.sweep_right.coll_init_pos[z] = 0
    attack_collider.sweep_right.coll_final_pos[x] = -15
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
    attack_collider.sweep_right.coll_init_scale[x] = 30
    attack_collider.sweep_right.coll_init_scale[y] = 3
    attack_collider.sweep_right.coll_init_scale[z] = 3 
    attack_collider.sweep_right.coll_final_scale[x] = 30
    attack_collider.sweep_right.coll_final_scale[y] = 3
    attack_collider.sweep_right.coll_final_scale[z] = 3
    attack_collider.sweep_right.coll_growth_velocity[x] = (attack_collider.sweep_right.coll_init_scale[x] - attack_collider.sweep_right.coll_final_scale[x]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_growth_velocity[y] = (attack_collider.sweep_right.coll_init_scale[y] - attack_collider.sweep_right.coll_final_scale[y]) / attack.sweep_right.att_execution_duration 
    attack_collider.sweep_right.coll_growth_velocity[z] = (attack_collider.sweep_right.coll_init_scale[z] - attack_collider.sweep_right.coll_final_scale[z]) / attack.sweep_right.att_execution_duration

    attack_collider.stomp.coll_init_pos[x] = 0
    attack_collider.stomp.coll_init_pos[y] = 8
    attack_collider.stomp.coll_init_pos[z] = 12
    attack_collider.stomp.coll_final_pos[x] = 0
    attack_collider.stomp.coll_final_pos[y] = 0
    attack_collider.stomp.coll_final_pos[z] = 12
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
    attack_collider.stomp.coll_init_scale[x] = 8
    attack_collider.stomp.coll_init_scale[y] = 1
    attack_collider.stomp.coll_init_scale[z] = 12 
    attack_collider.stomp.coll_final_scale[x] = 8
    attack_collider.stomp.coll_final_scale[y] = 1
    attack_collider.stomp.coll_final_scale[z] = 12
    attack_collider.stomp.coll_growth_velocity[x] = (attack_collider.stomp.coll_init_scale[x] - attack_collider.stomp.coll_final_scale[x]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_growth_velocity[y] = (attack_collider.stomp.coll_init_scale[y] - attack_collider.stomp.coll_final_scale[y]) / attack.stomp.att_execution_duration 
    attack_collider.stomp.coll_growth_velocity[z] = (attack_collider.stomp.coll_init_scale[z] - attack_collider.stomp.coll_final_scale[z]) / attack.stomp.att_execution_duration

    attack_collider.roar.coll_init_pos[x] = 0
    attack_collider.roar.coll_init_pos[y] = 0
    attack_collider.roar.coll_init_pos[z] = 18
    attack_collider.roar.coll_final_pos[x] = 0
    attack_collider.roar.coll_final_pos[y] = 0
    attack_collider.roar.coll_final_pos[z] = 18
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
    attack_collider.roar.coll_init_scale[x] = 40
    attack_collider.roar.coll_init_scale[y] = 10
    attack_collider.roar.coll_init_scale[z] = 30 
    attack_collider.roar.coll_final_scale[x] = 40
    attack_collider.roar.coll_final_scale[y] = 10
    attack_collider.roar.coll_final_scale[z] = 30
    attack_collider.roar.coll_growth_velocity[x] = (attack_collider.roar.coll_init_scale[x] - attack_collider.roar.coll_final_scale[x]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_growth_velocity[y] = (attack_collider.roar.coll_init_scale[y] - attack_collider.roar.coll_final_scale[y]) / attack.roar.att_execution_duration 
    attack_collider.roar.coll_growth_velocity[z] = (attack_collider.roar.coll_init_scale[z] - attack_collider.roar.coll_final_scale[z]) / attack.roar.att_execution_duration

    ---------------------------------------------------------------------------
	-- Health Init
    ---------------------------------------------------------------------------

    lua_table.current_health = lua_table.health
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("Kikimora Script START")
    --lua_table.ParticlesFunctions:ActivateParticlesEmission(lua_table.my_UID)
    --lua_table.my_position = lua_table.GameObjectFunctions:GetPosition(lua_table.my_UID)
    
    --If scale doens't change over time
    
    --lua_table.TransformFunctions:SetScale(attack_collider.stomp.coll_init_scale[x], attack_collider.stomp.coll_init_scale[y], attack_collider.stomp.coll_init_scale[z], attack_collider.stomp.coll_name)
    --lua_table.TransformFunctions:SetScale(attack_collider.roar.coll_init_scale[x], attack_collider.roar.coll_init_scale[y], attack_collider.roar.coll_init_scale[z], attack_collider.roar.coll_name)

    HandlePlayerPosition()
    HandleStates()

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()
    game_time = PerfGameTime()

    lua_table.my_position = lua_table.TransformFunctions:GetPosition(lua_table.my_UID)

    HandlePlayerPosition()
    HandlePhases()
    HandleStates()
    HandleAttacks()
    DebugInputs()

    -- Debug Logs
    lua_table.SystemFunctions:LOG ("Kikimora Health: " .. lua_table.current_health)
    lua_table.SystemFunctions:LOG ("Kikimora Health Percentage : " .. lua_table.current_health_percentage)
    lua_table.SystemFunctions:LOG ("Kikimora Phase: " .. current_phase)
    lua_table.SystemFunctions:LOG ("Kikimora State: " .. current_state)
    lua_table.SystemFunctions:LOG ("Kikimora Attack Type: " .. current_attack_type)
    lua_table.SystemFunctions:LOG ("Kikimora Attack Subdivision: " .. current_attack_subdivision)
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.my_UID)

	local collider_parent_GO
	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)

	if layer == layers.player_attack  --Checks if its player attack collider layer
	then
		collider_parent_GO = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		lua_table.collider_parent_script = lua_table.GameObjectFunctions:GetScript(collider_parent_GO)

		damage_received = lua_table.collider_parent_script.collider_damage

		lua_table.SystemFunctions:LOG ("Kikimora: damage received: ".. damage_received)

        lua_table.current_health = lua_table.current_health - damage_received
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
    local collider = lua_table.PhysicsFunctions:OnCollisionEnter(lua_table.my_UID)
	-- lua_table.SystemFunctions:LOG("T:" .. collider)
end
	return lua_table
end

