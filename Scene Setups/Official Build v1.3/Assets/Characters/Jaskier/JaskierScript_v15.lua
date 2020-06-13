function	GetTableJaskierScript_v15()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.CameraFunctions = Scripting.Camera()

--LEGACY NAMESPACES
--lua_table.DebugFunctions = Scripting.Debug()
--lua_table.ElementFunctions = Scripting.Elements()
--lua_table.SystemFunctions = Scripting.Systems()
--lua_table.InputFunctions = Scripting.Inputs()

--System
local dt = 0
local game_time = 0

local game_paused = false

--Debug
local keyboard_mode = false
local godmode = false
lua_table.immortal = false

--GO UIDs
local geralt_GO_UID
local jaskier_GO_UID

local jaskier_mesh_GO_UID
local jaskier_pivot_GO_UID

local jaskier_lute_regular_GO_UID
local jaskier_lute_concert_GO_UID
local jaskier_lute_concert_mesh_GO_UID

--Ally Script
local geralt_script

-- Revive GOs
local geralt_revive_GO_UID
local jaskier_revive_GO_UID

	--Particles
	--Jaskier_Guitar (Child of "???"): 0/0/0
	--Jaskier_Ultimate (Child of Jaskier): 0/0/0
	--Jaskier_Ability (Child of ???): 0/0/0

--Scene
--lua_table.level_scene = 0

--Animations
local animation_library = {
	none = "",

	death = "death",
	stand_up = "stand_up_back",

	knockback = "knockback",
	stun = "stun",

	idle = "idle",
	walk = "walk",
	run = "run",

	evade = "evade",
	revive = "revive",

	--Attacks use a string concatenation system (light_1/2/3)

	one_handed_slam = "guitar_slam_one_handed",
	two_handed_slam = "guitar_slam_two_handed",
	concert = "guitar_play_2",
	moonwalk = "moonwalk"
}
local current_animation = animation_library.none

local blending_started_at = 0
lua_table.blend_time_duration = 200	--Animation is marked as ended during blend time, so we use this to ensure we don't care if animations are marked as "ended" inside blend time because for us they aren't

--Particles
local particles_library = {
	none = 0,

	--guitar_particles_GO_UID = 0,

	--Particle Tables
	run_particles_GO_UID_children = {},
	blood_particles_GO_UID_children = {},
	stun_particles_GO_UID_children = {},

	revive_particles_GO_UID_children = {},
	down_particles_GO_UID_children = {},
	death_particles_GO_UID_children = {},

	potion_health_particles_GO_UID_children = {},
	potion_stamina_particles_GO_UID_children = {},
	potion_power_particles_GO_UID_children = {},

	song_circle_GO_UID_children = {},
	song_cone_mov_GO_UID_children = {},
	song_cone_fix_GO_UID_children = {},
	concert_GO_UID_children = {},

	--Standalone Particles

	--FBX Particles
	slash_GO_UID = 0,
	slash_mesh_GO_UID = 0
}
--local current_particles = particles_library.none	--IMPROVE: This could be a table with all currently working particles, but currently too much work for what is worth

--Audio
local audio_library = {
	none = "",

	not_possible = "Play_HUD_No_Stamina",

	death = "Play_Jaskier_death",
	stand_up = "Play_Jaskier_fall_down_get_up",

	-- knockback = "Play_Jaskier_knockback",
	-- stun = "Play_Jaskier_stun",
	hurt = "Play_Jaskier_hit_sound",

	move = "Play_Jaskier_Run_dirt",
	-- move_switch = "Jaskier_walk_run_switch",
	-- walk_state = "Walk",
	-- run_state = "Run",

	evade = "Play_Jaskier_jump",
	ultimate_recharged = "Play_Jaskier_Ultimate_Available",
	concert = "J_Ult",
	revive = "Play_Jaskier_revive",

	attack_miss = "Play_Jaskier_guitar_swing",
	attack_hit = "Play_Jaskier_guitar_smash",

	song_1 = "J_Combo_1",	--One hand line spin
	song_2 = "J_Combo_2",	--Two hand cone
	song_3 = "J_moonwalk",	--Song 3 Start
	song_3_secondary = "J_Combo_3",

	item_potion = "Play_Jaskier_potion_fx",
	potion_pickup = "Play_Potion_pick_up",
	potion_drop = "Play_Potion_drop",

	--voice_boss_fight = "Play_Jaskier_VL_boss_fight",		--Boss fight start
	voice_downed = "Play_Jaskier_VL_death",					--Character death
	voice_battle_start = "Play_Jaskier_VL_start_battle",	--Battle Start
	voice_battle_end = "Play_Jaskier_VL_end_battle",		--Battle End
	--voice_boss_defeated = "Play_Jaskier_VL_killed_boss",	--Boss Death
	voice_low_health = "Play_Jaskier_VL_low_health",		--Low Health
	voice_revive_ally = "Play_Jaskie_VL_revive"				--Revive Ally
}
local current_audio = audio_library.none
local current_paused_audio = audio_library.none

--Areas
local interval_calculation_started_at = 0
local interval_calculation_time = 3000

local enemy_detection_started_at = 0
local enemy_detection_time = 1000
lua_table.enemies_nearby = false
lua_table.enemy_detection_range = 20

--State Machine
local state = {	--The order of the states is relevant to the code, CAREFUL CHANGING IT (Ex: if current_state >= state.idle)
	dead = -4,
	down = -3,

	knocked = -2,
	stunned = -1,

	idle = 0,
	walk = 1,
	run = 2,

	evade = 3,
	ability = 4,	--NOTE: Not used for jaskier
	ultimate = 5,
	item = 6,
	revive = 7,

	light_1 = 8,
	light_2 = 9,
	light_3 = 10,

	medium_1 = 11,
	medium_2 = 12,
	medium_3 = 13,

	heavy_1 = 14,
	heavy_2 = 15,
	heavy_3 = 16,

	song_1 = 17,
	song_2 = 18,
	song_3 = 19
}
lua_table.previous_state = state.idle	-- Previous State
lua_table.current_state = state.idle	-- Current State

--Stats
local must_update_stats = false

--Stats Info
	-- Health
	-- Damage
	-- Velocity	--NOTE: Codewise, both terms "velocity" and "speed" are used, the first for physical movement, the 2nd for timings and animations

	--Vars
		-- _orig: The original value of the character, the baseline value, added manually by design
		-- _mod: The multiplier of the baseline value, the modifier value, always a 0.something
		-- _real: The value used for all calculations, the REAL value, calculated on command and both evaluated and modified with frequency
--

--Health
lua_table.current_health = 0

	--Health Stat
	lua_table.max_health_real = 0
	lua_table.max_health_mod = 1.0
	lua_table.max_health_orig = 200--500

local health_reg_real
lua_table.health_reg_mod = 0.0	-- mod is applied to max_health (reg 10% of your max health)

local near_death_health = 20
local near_death_playing = false

--Damage
	--Damage Stat
	local base_damage_real
	lua_table.base_damage_mod = 1.0
	lua_table.base_damage_orig = 1.0

-- local critical_chance_real
-- lua_table.critical_chance_add = 0
-- lua_table.critical_chance_orig = 0

-- local critical_damage_real
-- lua_table.critical_damage_add = 0
-- lua_table.critical_damage_orig = 2.0

--Items
lua_table.potion_health_prefab = 0
lua_table.potion_stamina_prefab = 0
lua_table.potion_power_prefab = 0
local item_prefabs = {	--Table that saves the prefab values
	0,
	0,
	0
}

lua_table.item_library = {	--Used to flag a readable name with a number id, allows for item indexing based on number
	none = 0,
	health_potion = 1,
	stamina_potion = 2,
	power_potion = 3
}
local item_library_size = 3

local item_effects = {		--Item library and required data to operate
	{ health_recovery = 4, health_regen = 0.1 },
	{ speed_increase = 0.5, energy_regen = 2 },
	{ damage_increase = 0.5, critical_chance_increase = 10 }
}
lua_table.inventory = {	--Character inventory (number of each item)
	3,
	2,
	1
}
lua_table.shared_inventory = {	--Items in inventory that were given by ally (number of each item)
	0,
	0,
	0
}
lua_table.item_selected = lua_table.item_library.health_potion
lua_table.item_type_max = 3
lua_table.item_pickup_range = 2

	--Potions
	lua_table.potion_in_effect = lua_table.item_library.none
	lua_table.potion_duration = 10000	--Duration in ms
	local potion_taken_at = 0
	lua_table.potion_active = false

--Controls
local key_state = {
	key_idle = "IDLE",
	key_down = "DOWN",
	key_repeat = "REPEAT",
	key_up = "UP"
}

local character_ID = {
	geralt = 0,
	jaskier = 1,
	yennefer = 2,
	ciri = 3
}
lua_table.player_ID = 2

lua_table.key_ultimate_1 = "AXIS_TRIGGERLEFT"
lua_table.key_ultimate_2 = "AXIS_TRIGGERRIGHT"

lua_table.key_revive = "BUTTON_LEFTSHOULDER"
lua_table.key_use_item = "BUTTON_RIGHTSHOULDER"

lua_table.key_light = "BUTTON_Y"
lua_table.key_medium = "BUTTON_B"
lua_table.key_evade = "BUTTON_A"
lua_table.key_ability = "BUTTON_X"

lua_table.key_move = "AXIS_LEFT"
lua_table.key_aim = "AXIS_RIGHT"

lua_table.key_pickup_item = "BUTTON_DPAD_UP"
lua_table.key_prev_consumable = "BUTTON_DPAD_LEFT"
lua_table.key_next_consumable = "BUTTON_DPAD_RIGHT"
lua_table.key_drop_consumable = "BUTTON_DPAD_DOWN"

lua_table.key_notdef5 = "BUTTON_BACK"
lua_table.key_notdef6 = "BUTTON_START"

--Inputs
local mov_input = {
	prev_input = { x = 0.0, z = 0.0 },	--Previous frame Input
	real_input = { x = 0.0, z = 0.0 },	--Real Input
	used_input = { x = 0.0, z = 0.0 }	--Input used on character
}

local aim_input = {
	prev_input = { x = 0.0, z = 0.0 },	--Previous frame Input
	real_input = { x = 0.0, z = 0.0 },	--Real Input
	used_input = { x = 0.0, z = 0.0 }	--Input used on character
}

local key_joystick_threshold = 0.25		--As reference, my very fucked up Xbox controller stays at around 2.1 if left IDLE gently (worst), my brand new one stays at 0 no matter what (best)
lua_table.input_walk_threshold = 0.95

--Camera Limitations (IF angle between forward character vector and plane normal > 90º (45º on corners) then all velocities = 0)
local camera_GO
local camera_script

local camera_bounds_ratio = 0.85
local bounds_vector = { x = 0, z = 0 }
local bounds_angle

local off_bounds = false
local left_bounds_at = 0
local left_bounds_time_limit = 3000

--Direction
local rot_y = 0.0
local rec_direction = { x = 0.0, z = 0.0 }	--Used to save a direction when necessary, given by joystick inputs or character rotation

--Movement
lua_table.current_velocity = 0

	--Velocity Stat
	local mov_velocity_stat	-- stat = real / 10. Exclusive to speed, as the numeric balancing is dependant on Physics and not only design
	local run_velocity
	local walk_velocity
	local walk_mod = 0.4
	lua_table.mov_velocity_max_mod = 1.0
	lua_table.mov_velocity_max_orig = 9	--6

lua_table.idle_animation_speed = 30.0	--30.0
lua_table.walk_animation_speed = 40.0	--25.0
lua_table.run_animation_speed = 45.0	--30.0

--Energy
lua_table.current_energy = 0
lua_table.max_energy_real = 0
lua_table.max_energy_mod = 1.0
lua_table.max_energy_orig = 100

local energy_reg_real
lua_table.energy_reg_mod = 1.0
lua_table.energy_reg_orig = 7

--Attacks
	--Layers
	local layers = {
		default = 0,
		player = 1,
		player_attack = 2,
		enemy = 3,
		enemy_attack = 4,
		prop = 5,
		particle_prop = 6,
		item = 7
	}

	--Attack Data
	local attack_effects_ID = {	--Effects ID
		none = 0,
		stun = 1,
		knockback = 2,
		taunt = 3,
		venom = 4
	}
	local attack_effects_durations = {	--Effects Enum
		2000,	--stun
		2000	--knockback
	}
		--Knockback
		local knockback_curr_velocity
		lua_table.knockback_orig_velocity = 10
		lua_table.knockback_acceleration = -6.0

	--Attack Colliders
	local attack_colliders = {												--Transform / Collider Scale
		front_1 = { GO_name = "Jaskier_Front_1", GO_UID = 0, active = false },	--0,2,3 / 4,3,3
		front_2 = { GO_name = "Jaskier_Front_2", GO_UID = 0, active = false },	--

		line_1 = { GO_name = "Jaskier_Line", GO_UID = 0, active = false },		--0,2,4 / 4,3,4
		circle_1 = { GO_name = "Jaskier_Circle_1", GO_UID = 0, active = false },	--0,2,4 / 4,3,4
		circle_2 = { GO_name = "Jaskier_Circle_2", GO_UID = 0, active = false },	--0,2,4 / 4,3,4
		concert = { GO_name = "Jaskier_Concert", GO_UID = 0, active = false }		--0,2,4 / 4,3,4
	}
	--Character Controller: 1.0/2.5/0.05/0.3/45.0

	--Attack Vars
	lua_table.collider_damage = 0						--Collider/Attack Damage
	lua_table.collider_effect = attack_effects_ID.none		--Effect
	lua_table.collider_stun_duration = 0
	lua_table.collider_knockback_speed = 0

	--Attack Feedback
	local enemy_hit_stages = {
		awaiting_attack = -1,
		attack_performed = 0,
		attack_miss = 1,
		attack_hit = 2,
		attack_finished = 3
	}
	local enemy_hit_curr_stage = enemy_hit_stages.awaiting_attack
	local enemy_hit_started_at = 0
	
	local hit_durations = {
		small = 100,
		medium = 200,
		big = 200
	}
	local enemy_hit_duration = hit_durations.small
	
	local controller_shake = {
		small = { intensity = 1.0, duration = 100 },
		medium = { intensity = 1.0, duration = 200 },
		big = { intensity = 1.0, duration = 300 }
	}
	local camera_shake = {
		small = { intensity = 0.1, duration = 0.2 },
		medium = { intensity = 0.2, duration = 0.4 },
		big = { intensity = 0.4, duration = 0.7 },
		yeet = { intensity = 1.5, duration = 3.0 }
	}

	--Attack Inputs
	local rightside = true		-- Last attack side, marks the animation of next attack

	local attack_inputs = {}
	attack_inputs[lua_table.key_light] = false
	attack_inputs[lua_table.key_medium] = false

	local attack_input_given = false
	local attack_input_timeframe = 70	--Milisecond timeframe for a double input (70ms allows by a small margin to have at least 2 frames of input registering on 30fps before overpasing the time limit)
	local attack_input_started_at = 0	--Start of any of the two inputs

	local input_slow_active = false
	local attack_slow_start = 0
	lua_table.animation_slow_speed = 10.0

--Light Attack
lua_table.light_damage = 25.0					--Multiplier of Base Damage

lua_table.light_3_movement_1_velocity = 7.0
lua_table.light_3_movement_1_start = 150
lua_table.light_3_movement_1_end = 400
lua_table.light_3_movement_2_velocity = -6.0
lua_table.light_3_movement_2_start = 600
lua_table.light_3_movement_2_end = 800

lua_table.light_1_block_time = 325			--Input block duration	(block new attacks)
lua_table.light_1_collider_front_start = 300	--Collider activation time
lua_table.light_1_collider_front_end = 400	--Collider deactivation time
lua_table.light_1_duration = 500			--Attack end (return to idle)
lua_table.light_1_animation_speed = 80.0
lua_table.light_1_slow_start = 400

lua_table.light_2_block_time = 225			--Input block duration	(block new attacks)
lua_table.light_2_collider_front_start = 200	--Collider activation time
lua_table.light_2_collider_front_end = 300	--Collider deactivation time
lua_table.light_2_duration = 450			--Attack end (return to idle)
lua_table.light_2_animation_speed = 80.0
lua_table.light_2_slow_start = 350

lua_table.light_3_block_time = 3000			--Input block duration	(block new attacks)
lua_table.light_3_collider_front_start = 300	--Collider activation time
lua_table.light_3_collider_front_end = 400	--Collider deactivation time
lua_table.light_3_duration = 500			--Attack end (return to idle)
lua_table.light_3_animation_speed = 60.0	
--lua_table.light_3_slow_start = 2000

lua_table.light_3 = { 'N', 'L', 'L', 'L' }
lua_table.light_3_size = 3
lua_table.light_3_damage = 34.0
lua_table.light_3_effect = attack_effects_ID.knockback
lua_table.light_3_effect_value = 0

--Medium Attack
lua_table.medium_damage = 50.0					--Multiplier of Base Damage

lua_table.medium_1_movement_velocity = 5.0
lua_table.medium_1_movement_start = 200
lua_table.medium_2_movement_velocity = 3.0
lua_table.medium_2_movement_start = 350
lua_table.medium_3_movement_1_velocity = 4.0
lua_table.medium_3_movement_1_start = 350
lua_table.medium_3_movement_1_end = 600
lua_table.medium_3_movement_2_velocity = -4.0
lua_table.medium_3_movement_2_start = 850
lua_table.medium_3_movement_2_end = 1150

lua_table.medium_1_block_time = 375			--Input block duration	(block new attacks)
lua_table.medium_1_collider_front_start = 350	--Collider activation time
lua_table.medium_1_collider_front_end = 450	--Collider deactivation time
lua_table.medium_1_duration = 425			--Attack end (return to idle)
lua_table.medium_1_animation_speed = 40.0
lua_table.medium_1_slow_start = 500

lua_table.medium_2_block_time = 500			--Input block duration	(block new attacks)
lua_table.medium_2_collider_front_start = 400	--Collider activation time
lua_table.medium_2_collider_front_end = 500	--Collider deactivation time
lua_table.medium_2_duration = 530			--Attack end (return to idle)
lua_table.medium_2_animation_speed = 40.0
lua_table.medium_2_slow_start = 550

lua_table.medium_3_block_time = 3000			--Input block duration	(block new attacks)
lua_table.medium_3_collider_front_start = 450	--Collider activation time
lua_table.medium_3_collider_front_end = 550	--Collider deactivation time
lua_table.medium_3_duration = 600			--Attack end (return to idle)
lua_table.medium_3_animation_speed = 40.0
--lua_table.medium_3_slow_start = 2000

lua_table.medium_3 = { 'N', 'M', 'M', 'M' }
lua_table.medium_3_size = 3
lua_table.medium_3_damage = 64.0
lua_table.medium_3_effect = attack_effects_ID.stun
lua_table.medium_3_effect_value = 100

--Heavy Attack
lua_table.heavy_damage = 75.0				--Multiplier of Base Damage

lua_table.heavy_1_movement_velocity = 3.0
lua_table.heavy_1_movement_start = 250
lua_table.heavy_1_movement_end = 700
lua_table.heavy_2_movement_velocity = 3.0
lua_table.heavy_2_movement_start = 350
lua_table.heavy_3_movement_1_velocity = 3.0
lua_table.heavy_3_movement_1_start = 260
lua_table.heavy_3_movement_1_end = 500
lua_table.heavy_3_movement_2_velocity = -3.0
lua_table.heavy_3_movement_2_start = 1000
lua_table.heavy_3_movement_2_end = 1400

lua_table.heavy_1_block_time = 575			--Input block duration	(block new attacks)
lua_table.heavy_1_collider_front_start = 350	--Collider activation time
lua_table.heavy_1_collider_front_end = 550	--Collider deactivation time
lua_table.heavy_1_duration = 1200			--Attack end (return to idle)
lua_table.heavy_1_animation_speed = 30.0
lua_table.heavy_1_slow_start = 850

lua_table.heavy_2_block_time = 575			--Input block duration	(block new attacks)
lua_table.heavy_2_collider_front_start = 300	--Collider activation time
lua_table.heavy_2_collider_front_end = 450	--Collider deactivation time
lua_table.heavy_2_duration = 830			--Attack end (return to idle)
lua_table.heavy_2_animation_speed = 40.0
lua_table.heavy_2_slow_start = 750

lua_table.heavy_3_block_time = 3000			--Input block duration	(block new attacks)
lua_table.heavy_3_collider_front_start = 650	--Collider activation time
lua_table.heavy_3_collider_front_end = 800	--Collider deactivation time
lua_table.heavy_3_duration = 1000			--Attack end (return to idle)
lua_table.heavy_3_animation_speed = 40.0
--lua_table.heavy_3_slow_start = 2000

lua_table.heavy_3 = { 'N', 'H', 'H', 'H' }
lua_table.heavy_3_size = 3
lua_table.heavy_3_damage = 100.0
lua_table.heavy_3_effect = attack_effects_ID.knockback
lua_table.heavy_3_effect_value = 0

--Evade		
lua_table.evade_velocity = 25			--12
lua_table.evade_cost = 33
lua_table.evade_duration = 800			--1100

lua_table.evade_animation_speed = 60.0	--40

--Ability
lua_table.ability_cooldown = 1000.0

local ability_started_at = 0.0
lua_table.ability_performed = true	--Marks song available with current notes (name is incoherent, kept like this to avoid changing UI code)

--Songs
lua_table.chained_attacks_num = 0				-- Number of attacks done one after the other, chained
lua_table.note_num = 0							-- Starting at 0, increases by 1 for each attack well timed, starting at 4, each new attack will be checked for a succesful combo. Bad timing or performing a combo resets to 0
lua_table.attack_stack = { 'N', 'N', 'N', 'N' }	-- Last 4 attacks performed (0=none, 1=light, 2=heavy). Use push_back tactic.
lua_table.note_stack = { 'N', 'N', 'N', 'N' }	-- Notes based on attacks performed (0=none, 1=light, 2=heavy). Use push_back tactic.

	--Song 1
	lua_table.song_1 = { 'L', 'M', 'L', 'M' }	--Penetrating Line of Damage (Row of colliders in front of jaskier get turned on one right after the other)
	lua_table.song_1_size = 4
	lua_table.song_1_effect_start = 750
	lua_table.song_1_effect_active = false
	lua_table.song_1_duration = 1440
	lua_table.song_1_animation_name = animation_library.one_handed_slam
	lua_table.song_1_animation_speed = 50.0
	lua_table.song_1_damage = 150.0
	lua_table.song_1_status_effect = attack_effects_ID.none
	lua_table.song_1_effect_value = 0

	lua_table.song_1_collider_line_start = 800
	lua_table.song_1_collider_line_end = 1200
	lua_table.song_1_collider_speed = 35.0

	--Song 2
	lua_table.song_2 = { 'M', 'L', 'L', 'M' }	--Large Stun Cone (AoE applied once, gives animation_library.stun effect)
	lua_table.song_2_size = 4
	lua_table.song_2_effect_start = 850
	lua_table.song_2_effect_active = false
	lua_table.song_2_duration = 1700
	lua_table.song_2_animation_name = animation_library.two_handed_slam
	lua_table.song_2_animation_speed = 50.0
	lua_table.song_2_damage = 75.0
	lua_table.song_2_status_effect = attack_effects_ID.stun
	lua_table.song_2_effect_value = 2000

	local song_2_trapezoid = {
		offset_x = 0.1,			--Near segment width (Must be > than 0)
		offset_z = 0.1,			--Near segment forward distance
		range = 10,				--Trapezoid height
		angle = math.rad(60),	--Trapezoid side angles
		point_A = { x = 0, z = 0 },	--Far left
		point_B = { x = 0, z = 0 },	--Far right
		point_C = { x = 0, z = 0 },	--Near right
		point_D = { x = 0, z = 0 }	--Near left
	}
	local song_2_particles_speed = {
		forward = 25,
		y = 15,
		lateral = 75
	}

	--Song 3
	lua_table.song_3 = { 'H', 'L', 'M', 'H' }	--Taunt Moonwalk + Circle Knockback (Both use a circle AoE, first "taunt" scond animation_library.knockback)
	lua_table.song_3_size = 4
	lua_table.song_3_effect_end = 2000
	lua_table.song_3_effect_active = false
	lua_table.song_3_duration = 3700
	lua_table.song_3_animation_name = animation_library.moonwalk
	lua_table.song_3_moonwalk_velocity_mod = 0.6
	lua_table.song_3_animation_speed = 30.0
	lua_table.song_3_damage = 0.0
	lua_table.song_3_status_effect = attack_effects_ID.taunt
	lua_table.song_3_effect_value = 0
	lua_table.song_3_saved_direction = false

	lua_table.song_3_secondary_effect_start = 2850
	lua_table.song_3_secondary_effect_end = 2950
	lua_table.song_3_secondary_effect_active = false
	lua_table.song_3_secondary_animation_name = animation_library.two_handed_slam
	lua_table.song_3_secondary_animation_speed = 50.0
	lua_table.song_3_secondary_damage = 125.0
	lua_table.song_3_secondary_status_effect = attack_effects_ID.knockback
	lua_table.song_3_secondary_effect_value = 0

--Ultimate
lua_table.current_ultimate = 0.0
lua_table.max_ultimate = 100.0

local ultimate_reg_real
lua_table.ultimate_reg_mod = 1.0
lua_table.ultimate_reg_orig = 1.5	--1 minute between ultimates

lua_table.ultimate_active = false

local interval_started_at = 0
lua_table.ultimate_damage_interval = 1100
lua_table.ultimate_effect_end = 3300
lua_table.ultimate_effect_active = false
lua_table.ultimate_duration = 5000
lua_table.ultimate_animation_speed = 30.0
lua_table.ultimate_damage = 100.0
lua_table.ultimate_status_effect = attack_effects_ID.none

lua_table.ultimate_secondary_effect_start = 4150
lua_table.ultimate_secondary_effect_end = 4250
lua_table.ultimate_secondary_effect_active = false
lua_table.ultimate_secondary_animation_speed = 50.0
lua_table.ultimate_secondary_damage = 200.0
lua_table.ultimate_secondary_status_effect = attack_effects_ID.knockback
lua_table.ultimate_secondary_effect_value = 0

--Stand Up	(Standing up from knockbacks or being downed)
lua_table.standing_up_bool = false
lua_table.stand_up_animation_speed = 90.0
lua_table.stand_up_duration = 1500

--Revive/Death
local revive_target				-- Target character script
lua_table.being_revived = false	-- Revival flag (managed by rescuer character)
lua_table.revive_range = 2		-- Revive distance
lua_table.revive_animation_speed = 25.0

lua_table.revive_time = 3000	-- Time to revive
lua_table.down_time = 10000		-- Time until death (restarted by revival attempt)

local pulsation_started_at = 0
local pulsation_interval_duration = 800

lua_table.resurrecting = false
lua_table.falling_down_bool = false
local stopped_death = false		-- Death timer stop flag
lua_table.death_started_at = 0		-- Death timer start
local death_stopped_at = 0		-- Death timer stop
lua_table.revive_started_at = 0		-- Revive timer start

--Actions
local time_since_action = 0			-- Time passed since action performed
local current_action_block_time = 0	-- Duration of input block from current action/event (accept new action inputs)
local current_action_duration = 0	-- Duration of current action/event (return to idle)	WARNING: Only relevant to actions with animation loops
local action_started_at = 0			-- Marks start of actions (and getting revived)

--Idle and Blend Time
local idle_started_at = 0
local idle_blend_finished = false

--Utility BEGIN	----------------------------------------------------------------------------	--IMPROVE: Consider making useful generic methods part of a global script

local function TableLength(table)	--Get TableLength
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
end

local function CompareArrays(table_1, table_2, from, to)	--Compare two tables numerically ordered from point A to B
	local from = from or 1
	local to = to or TableLength(table_1)	--Lua's version of default parameters

	local equal = true

	for i = from, to, 1 do
		if table_1[i] ~= table_2[i] then
			equal = false
			break
		end
	end

	return equal
end

local function CompareTables(table_1, table_2)	--Check if table values are equal
	local equal = true

	if TableLength(table_1) ~= TableLength(table_2) then
		equal = false
	else
		for i, j in pairs(table_1) do
			if table_1[i] ~= table_2[i] then
				equal = false
				break
			end
		end
	end

	return equal
end

local function PushBack(array, new_val)		--Pushes back all values and inserts a new one
	local array_size = TableLength(array)	--Lua's version of default parameters

	for i = 1, array_size - 1, 1 do
		array[i] = array[i + 1]
	end

	array[array_size] = new_val
end

local function PerfGameTime()
	return lua_table.SystemFunctions:GameTime() * 1000
end

--Utility END	----------------------------------------------------------------------------

--Geometry BEGIN	----------------------------------------------------------------------------

local function BidimensionalRotate(x, y, angle)	--REMEMBER: In 2D it's (x,y), but our 3D space translated into horizontal (ground) 2D it's (z,x). Therefore: 3D (Z,X) to 2D (X,Y)
	local new_x = x * math.cos(angle) - y * math.sin(angle)
	local new_y = x * math.sin(angle) + y * math.cos(angle)

	return new_x, new_y
end

local function BidimensionalPointInVectorSide(vec_x1, vec_y1, vec_x2, vec_y2, point_x, point_y)	--Counter-clockwise: If D > 0, the point is on the right side. If D < 0, the point is on the left side. If D = 0, the point is on the line.
	local D = (vec_x2 - vec_x1) * (point_y - vec_y1) - (point_x - vec_x1) * (vec_y2 - vec_y1);
	return D		
end

local function BidimensionalAngleBetweenVectors(vec_x1, vec_y1, vec_x2, vec_y2)
	return math.acos((vec_x1 * vec_x2 + vec_y1 * vec_y2) / (math.sqrt(vec_x1 ^ 2 + vec_y1 ^ 2) + math.sqrt(vec_x2 ^ 2 * vec_y2 ^ 2)))
end

local function GimbalLockWorkaroundY(target_GO)	--TODO: Remove when bug is fixed
	local target_rot = lua_table.TransformFunctions:GetRotation(target_GO)
	if math.abs(target_rot[1]) == 180.0 or math.abs(target_rot[3]) == 180.0
	then
		if target_rot[2] >= 0 then target_rot[2] = 180 - target_rot[2]
		elseif target_rot[2] < 0 then target_rot[2] = -180 - target_rot[2]
		end
	end

	return target_rot[2]
end

--Geometry END	----------------------------------------------------------------------------

--States BEGIN	----------------------------------------------------------------------------

local function GoDefaultState(change_blend_time)
	lua_table.previous_state = lua_table.current_state

	if mov_input.used_input.x ~= 0.0 or mov_input.used_input.z ~= 0.0
	then
		if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)
		then
			lua_table.AnimationFunctions:PlayAnimation(animation_library.run, lua_table.run_animation_speed, jaskier_GO_UID)
			current_animation = animation_library.run

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.move, jaskier_GO_UID)	--TODO-AUDIO: Play run sound
			--lua_table.AudioFunctions:SetAudioSwitch(audio_library.move_switch, audio_library.run_state, jaskier_GO_UID)
			current_audio = audio_library.move

			lua_table.current_velocity = run_velocity
			lua_table.current_state = state.run

			for i = 1, #particles_library.run_particles_GO_UID_children do
				lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
			end
		else
			lua_table.AnimationFunctions:PlayAnimation(animation_library.walk, lua_table.walk_animation_speed, jaskier_GO_UID)
			current_animation = animation_library.walk

			-- lua_table.AudioFunctions:PlayAudioEventGO(audio_library.move, jaskier_GO_UID)	--TODO-AUDIO: Play walk sound
			-- lua_table.AudioFunctions:SetAudioSwitch(audio_library.move_switch, audio_library.walk_state, jaskier_GO_UID)
			-- current_audio = audio_library.move

			lua_table.current_velocity = walk_velocity
			lua_table.current_state = state.walk
		end
	else
		if change_blend_time then
			lua_table.AnimationFunctions:SetBlendTime(0.2, jaskier_GO_UID)
		end

		lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, jaskier_GO_UID)
		current_animation = animation_library.idle

		idle_started_at = game_time
		idle_blend_finished = false
		lua_table.current_state = state.idle
	end
	
	lua_table.chained_attacks_num = 0
	rightside = true
end

--States END	----------------------------------------------------------------------------

--Stats BEGIN	----------------------------------------------------------------------------

local function CalculateStats()
	--Health
	local max_health_increment = lua_table.max_health_orig * lua_table.max_health_mod / lua_table.max_health_real
	lua_table.max_health_real = lua_table.max_health_real * max_health_increment
	lua_table.current_health = lua_table.current_health * max_health_increment

	health_reg_real = lua_table.max_health_real * lua_table.health_reg_mod

	--Damage
	base_damage_real = lua_table.base_damage_orig * lua_table.base_damage_mod
	-- critical_chance_real = lua_table.critical_chance_orig + lua_table.critical_chance_add
	-- critical_damage_real = lua_table.critical_damage_orig + lua_table.critical_damage_add

	--Speed
	run_velocity = lua_table.mov_velocity_max_orig * lua_table.mov_velocity_max_mod
	walk_velocity = run_velocity * walk_mod
	mov_velocity_stat = run_velocity * 0.1

	if lua_table.current_state == state.walk then lua_table.current_velocity = walk_velocity
	elseif lua_table.current_state == state.run then lua_table.current_velocity = run_velocity end

	--Energy
	lua_table.max_energy_real = lua_table.max_energy_orig * lua_table.max_energy_mod
	energy_reg_real = lua_table.energy_reg_orig * lua_table.energy_reg_mod

	--Ultimate
	ultimate_reg_real = lua_table.ultimate_reg_orig * lua_table.ultimate_reg_mod

	--If current values overflow new maximums, limit them
	if lua_table.current_health > lua_table.max_health_real then lua_table.current_health = lua_table.max_health_real end
	if lua_table.current_energy > lua_table.max_energy_real then lua_table.current_energy = lua_table.max_energy_real end
end

--Stats END	----------------------------------------------------------------------------

--Inputs BEGIN	----------------------------------------------------------------------------

local function KeyboardInputs()	--Process Keyboard-to-Controller Inputs
	mov_input.used_input.x, mov_input.used_input.z = 0.0, 0.0
	
	if lua_table.InputFunctions:KeyRepeat("RIGHT")
	then
		mov_input.used_input.x = 1.0
	elseif lua_table.InputFunctions:KeyRepeat("LEFT")
	then
		mov_input.used_input.x = -1.0
	end

	if lua_table.InputFunctions:KeyRepeat("DOWN")
	then
		mov_input.used_input.z = 1.0
	elseif lua_table.InputFunctions:KeyRepeat("UP")
	then
		mov_input.used_input.z = -1.0
	end
end

local function JoystickInputs(key_string, input_table)	--TODO-Inputs: The whole "if same input as last frame, mark forward" doesn't work properly
	input_table.real_input.x = lua_table.InputFunctions:GetAxisValue(lua_table.player_ID, key_string .. "X", 0.01)	--Get accurate inputs
	input_table.real_input.z = lua_table.InputFunctions:GetAxisValue(lua_table.player_ID, key_string .. "Y", 0.01)

	if math.abs(input_table.real_input.x) < key_joystick_threshold and math.abs(input_table.real_input.z) < key_joystick_threshold	--IF both inputs under threshold
	then
	 	input_table.used_input.x, input_table.used_input.z = 0.0, 0.0	--Set used input as idle (0)
	else
		input_table.used_input.x, input_table.used_input.z = input_table.real_input.x, input_table.real_input.z	--Use real input
	end

	input_table.prev_input.x, input_table.prev_input.z = input_table.real_input.x, input_table.real_input.z	--Record previous real input as current one
end

local function RegisterAttackInputs()	--This is used to give a timeframe to press the two attack buttons at the same time, without being necesarily on the exact same frame
	if not attack_inputs[lua_table.key_light] then
		if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_light, key_state.key_down) or keyboard_mode and lua_table.InputFunctions:KeyDown(",")
		then
			attack_inputs[lua_table.key_light] = true
			if not attack_input_given then
				attack_input_started_at = game_time
				attack_input_given = true
			end
		end
	end
	if not attack_inputs[lua_table.key_medium] then
		if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_medium, key_state.key_down) or keyboard_mode and lua_table.InputFunctions:KeyDown(".")
		then
			attack_inputs[lua_table.key_medium] = true
			if not attack_input_given then
				attack_input_started_at = game_time
				attack_input_given = true
			end
		end
	end
end

--Inputs END	----------------------------------------------------------------------------

--Character Colliders BEGIN	----------------------------------------------------------------------------

local function AttackColliderCheck(attack_type, collider_id, collider_num)	--Checks timeframe of current action and activates or deactivates a speficied side collider depending on it
	if time_since_action > lua_table[attack_type .. "_collider_" .. collider_id .. "_start"]		--IF time > start collider
	then
		if time_since_action > lua_table[attack_type .. "_collider_" .. collider_id .. "_end"]	--IF time > end collider
		then
			if attack_colliders[collider_id .. "_" .. collider_num].active	--IF > end time and collider active, deactivate
			then
				lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders[collider_id .. "_" .. collider_num].GO_UID)	--TODO-Colliders: Check
				attack_colliders[collider_id .. "_" .. collider_num].active = false
			end

			--lua_table.SystemFunctions:LOG("Collider Deactivate: " .. attack_type .. "_" .. collider_id)
			
		elseif not attack_colliders[collider_id .. "_" .. collider_num].active	--IF > start time and collider unactive, activate
		then
			lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders[collider_id .. "_" .. collider_num].GO_UID)	--TODO-Colliders: Check
			attack_colliders[collider_id .. "_" .. collider_num].active = true

			if enemy_hit_curr_stage == enemy_hit_stages.awaiting_attack then
				enemy_hit_curr_stage = enemy_hit_stages.attack_performed
			end

		--else
			--lua_table.SystemFunctions:LOG("Collider Active: " .. attack_type .. "_" .. collider_id)
		end
	elseif attack_colliders[collider_id .. "_" .. collider_num].active	--IF > end time and collider active, deactivate
	then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders[collider_id .. "_" .. collider_num].GO_UID)	--TODO-Colliders: Check
		attack_colliders[collider_id .. "_" .. collider_num].active = false
	end
end

local function AttackColliderShutdown()
	if attack_colliders.front_1.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.front_1.GO_UID)	--TODO-Colliders: Check
		attack_colliders.front_1.active = false
	end
	if attack_colliders.front_2.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.front_2.GO_UID)	--TODO-Colliders: Check
		attack_colliders.front_2.active = false
	end

	if attack_colliders.line_1.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.line_1.GO_UID)	--TODO-Colliders: Check
		attack_colliders.line_1.active = false
	end

	if attack_colliders.circle_1.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.circle_1.GO_UID)	--TODO-Colliders: Check
		attack_colliders.circle_1.active = false
	end
	if attack_colliders.circle_2.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.circle_2.GO_UID)	--TODO-Colliders: Check
		attack_colliders.circle_2.active = false
	end

	if attack_colliders.concert.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.concert.GO_UID)	--TODO-Colliders: Check
		attack_colliders.concert.active = false
	end
end

--Character Colliders END	----------------------------------------------------------------------------

--Character Particles BEGIN	----------------------------------------------------------------------------

local function ParticlesShutdown()
	if lua_table.current_state == state.run
	then
		for i = 1, #particles_library.run_particles_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles: Stop movement dust particles
		end

	elseif lua_table.current_state <= state.song_1 and lua_table.current_state >= state.light_1	--IF attack
	then
		lua_table.AnimationFunctions:PlayAnimation(animation_library.evade, lua_table.evade_animation_speed, particles_library.slash_GO_UID)
		lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)

		--lua_table.ParticlesFunctions:StopParticleEmitter(guitar_particles_GO_UID)

	elseif lua_table.current_state == state.song_2
	then
		for i = 1, #particles_library.song_cone_mov_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_cone_mov_GO_UID_children[i])	--TODO-Particles:
		end
		for i = 1, #particles_library.song_cone_fix_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_cone_fix_GO_UID_children[i])	--TODO-Particles:
		end

	elseif lua_table.current_state == state.song_3
	then
		for i = 1, #particles_library.song_circle_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_circle_GO_UID_children[i])	--TODO-Particles:
		end

	elseif lua_table_current_state == state.ultimate
	then
		for i = 1, #particles_library.concert_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.concert_GO_UID_children[i])	--TODO-Particles:
		end

		for i = 1, #particles_library.song_circle_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_circle_GO_UID_children[i])	--TODO-Particles:
		end

	elseif lua_table.current_state == state.stunned
	then
		for i = 1, #particles_library.stun_particles_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.stun_particles_GO_UID_children[i])	--TODO-Particles:
		end
	end
end

--Character Particles END	----------------------------------------------------------------------------

--Character Audio BEGIN	----------------------------------------------------------------------------

local function AudioShutdown()
	lua_table.AudioFunctions:StopAudioEventGO(current_audio, jaskier_GO_UID)
	current_audio = audio_library.none
end

--Character Audio END	----------------------------------------------------------------------------

--Character Movement BEGIN	----------------------------------------------------------------------------

local function CheckMapBoundaries()
	if game_time - interval_calculation_started_at > interval_calculation_time
	then
		local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Look at and set direction from knockback
		if jaskier_pos[2] < -300 then
			lua_table.PhysicsFunctions:SetActiveController(false, jaskier_GO_UID)
			lua_table.PhysicsFunctions:SetActiveController(true, jaskier_GO_UID)

			if geralt_GO_UID ~= nil and geralt_GO_UID ~= 0 then
				local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
				lua_table.PhysicsFunctions:SetCharacterPosition(geralt_pos[1], geralt_pos[2] + 5.0, geralt_pos[3], jaskier_GO_UID)				
			else
				lua_table.PhysicsFunctions:SetCharacterPosition(jaskier_pos[1], 500.0, jaskier_pos[3], jaskier_GO_UID) 
			end
		end
		
		interval_calculation_started_at = game_time
	end
end

local function SaveDirection()
	rot_y = math.rad(GimbalLockWorkaroundY(jaskier_GO_UID))	--TODO: Remove GimbalLock stage when Euler bug is fixed

	if mov_input.used_input.x ~= 0 or mov_input.used_input.z ~= 0	--IF input given, use as direction
	then
		local magnitude = math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)

		local orig_inputs = {	--Transform inputs into unit vector values
			x = mov_input.used_input.x / magnitude,
			z = mov_input.used_input.z / magnitude
		}

		if camera_script.current_camera_orientation ~= nil then
			local camera_Y_rot = math.rad(camera_script.current_camera_orientation)
			rec_direction.x = orig_inputs.z * math.sin(camera_Y_rot) + orig_inputs.x * math.cos(camera_Y_rot)
			rec_direction.z = orig_inputs.z * math.cos(camera_Y_rot) - orig_inputs.x * math.sin(camera_Y_rot)
		else
			rec_direction.x = orig_inputs.x
			rec_direction.z = orig_inputs.z
		end

	else	--IF no input, use character Y angle to move FORWARD
		rec_direction.x, rec_direction.z = math.sin(rot_y), math.cos(rot_y)
	end
end

local function ShakeCamera(duration, magnitude)
	if camera_script ~= nil and camera_script ~= 0 then
		camera_script.camera_shake_duration = duration
		camera_script.camera_shake_magnitude = magnitude
		camera_script.camera_shake_activated = true
	end
end

local function DirectionInBounds(use_Y_angle)	--Every time we try to set a velocity, this is checked first to allow it
	local ret = true
	local vec_x, vec_z

	if off_bounds then
		if use_Y_angle
		then
			rot_y = math.rad(GimbalLockWorkaroundY(jaskier_GO_UID))	--TODO: Remove GimbalLock stage when Euler bug is fixed
			vec_x, vec_z = math.sin(rot_y), math.cos(rot_y)
		else
			vec_x, vec_z = rec_direction.x, rec_direction.z
		end

		--IF angle between character Front (Z) and set Bounds Vector > Bounds Angle, in other words, if direction too far away from what camera requires to stay within bounds
		if BidimensionalAngleBetweenVectors(vec_x, vec_z, bounds_vector.x, bounds_vector.z) > bounds_angle
		then
			ret = false	--Return: movement not approved by camera bounds
		end
	end

	return ret
end

local function CheckCameraBounds()	--Check if we're currently outside the camera's bounds
	--1. Get all necessary data
	local position = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)
	local sides = lua_table.CameraFunctions:GetFrustumPlanesIntersection(position[1], position[2], position[3], camera_bounds_ratio)
	-- { Top, Bot, Left, Right }
	-- 0 == outside, 1 == inside

	--lua_table.SystemFunctions:LOG("Cam Planes: " .. sides[1] .. "_" .. sides[2] .. "_" .. sides[3] .. "_" .. sides[4])

	--2. Restart camera bounds values
	bounds_vector.x = 0
	bounds_vector.z = 0
	bounds_angle = 90

	--3. Generate a vector and change angle depending on planes that we're traspassing (1 plane = 90º, 2 planes = 45º)
	--3.1. Check down/up
	if sides[2] == 0 then
		bounds_vector.z = -1
	elseif sides[1] == 0 then
		bounds_vector.z = 1
	else
		--bounds_angle = bounds_angle + 45
	end

	--3.2. Check left/right
	if sides[3] == 0 then
		bounds_vector.x = 1
	elseif sides[4] == 0 then
		bounds_vector.x = -1
	else
		--bounds_angle = bounds_angle + 45
	end

	--4. If character off bounds, calculate the return angle and flag the off bounds status
	if bounds_vector.x ~= 0 or bounds_vector.z ~= 0 then

		if not off_bounds then left_bounds_at = game_time end
		off_bounds = true
		bounds_angle = math.rad(bounds_angle)

		if camera_script.current_camera_orientation ~= nil then
			local camera_Y_rot = math.rad(camera_script.current_camera_orientation)
			local orig_vector = { x = bounds_vector.x, z = bounds_vector.z }
			bounds_vector.x = orig_vector.z * math.sin(camera_Y_rot) + orig_vector.x * math.cos(camera_Y_rot)
			bounds_vector.z = orig_vector.z * math.cos(camera_Y_rot) - orig_vector.x * math.sin(camera_Y_rot)
		end

		if game_time - left_bounds_at > left_bounds_time_limit and lua_table.current_state > state.idle then
			lua_table.AnimationFunctions:SetBlendTime(0.1, jaskier_GO_UID)

			AttackColliderShutdown()
			ParticlesShutdown()
			AudioShutdown()

			if enemy_hit_curr_stage == enemy_hit_stages.attack_hit
			then
				lua_table.AnimationFunctions:SetAnimationPause(false, jaskier_GO_UID)
				lua_table.AnimationFunctions:SetAnimationPause(false, particles_library.slash_GO_UID)
				enemy_hit_curr_stage = enemy_hit_stages.attack_finished
			end

			local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Look at and set direction from knockback
			lua_table.TransformFunctions:LookAt(jaskier_pos[1] - bounds_vector.x, jaskier_pos[2], jaskier_pos[3] - bounds_vector.z, jaskier_GO_UID)

			local magnitude = math.sqrt(bounds_vector.x ^ 2 + bounds_vector.z ^ 2)
			rec_direction.x = bounds_vector.x / magnitude
			rec_direction.z = bounds_vector.z / magnitude

			knockback_curr_velocity = lua_table.knockback_orig_velocity

			lua_table.AnimationFunctions:PlayAnimation(animation_library.knockback, 60.0, jaskier_GO_UID)
			current_animation = animation_library.knockback
			blending_started_at = game_time	--Manually mark animation swap

			if lua_table.current_health > 0
			then
				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.knockback, jaskier_GO_UID)	--TODO-AUDIO:
				current_audio = audio_library.knockback
			end	--TODO-Audio:

			lua_table.standing_up_bool = false

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.knocked

			current_action_duration = attack_effects_durations[attack_effects_ID.knockback]
			action_started_at = game_time
			lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.medium.intensity, controller_shake.medium.duration)
			ShakeCamera(camera_shake.small.duration, camera_shake.small.intensity)
		end

	else
		off_bounds = false
	end
end

local function MoveCharacter(reversed_rotation, use_camera)	--Bool param used to mark moonwalk mainly
	local magnitude = math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)

	--Move character
	local orig_mov_velocity = {	--Magnitude into vectorial values through input values
		x = lua_table.current_velocity * mov_input.used_input.x / magnitude,
		z = lua_table.current_velocity * mov_input.used_input.z / magnitude
	}

	local mov_velocity = {}
	if camera_script.current_camera_orientation ~= nil and use_camera then
		local camera_Y_rot = math.rad(camera_script.current_camera_orientation)
		mov_velocity.x = orig_mov_velocity.z * math.sin(camera_Y_rot) + orig_mov_velocity.x * math.cos(camera_Y_rot)	--Magnitude into vectorial values through input values
		mov_velocity.z = orig_mov_velocity.z * math.cos(camera_Y_rot) - orig_mov_velocity.x * math.sin(camera_Y_rot)
	else
		mov_velocity.x = orig_mov_velocity.x
		mov_velocity.z = orig_mov_velocity.z
	end

	local position = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Rotate to velocity direction
	if not reversed_rotation then
		lua_table.TransformFunctions:LookAt(position[1] + mov_velocity.x, position[2], position[3] + mov_velocity.z, jaskier_GO_UID)
	else
		lua_table.TransformFunctions:LookAt(position[1] - mov_velocity.x, position[2], position[3] - mov_velocity.z, jaskier_GO_UID)
	end

	if DirectionInBounds(true) then	--Only allow movement if camera bounds allows it
		lua_table.PhysicsFunctions:Move(mov_velocity.x * dt, mov_velocity.z * dt, jaskier_GO_UID)
	end		
end

local function MovementInputs()	--Process Movement Inputs
	if mov_input.used_input.x ~= 0.0 or mov_input.used_input.z ~= 0.0												--IF Movement Input
	then
		lua_table.AnimationFunctions:SetBlendTime(0.1, jaskier_GO_UID)
		
		--Swap between idle and moving
		if lua_table.current_state == state.idle																	--IF Idle
		then
			lua_table.previous_state = lua_table.current_state

			if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF great input
			then
				lua_table.current_velocity = run_velocity
				lua_table.AnimationFunctions:PlayAnimation(animation_library.run, lua_table.run_animation_speed, jaskier_GO_UID)
				current_animation = animation_library.run

				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.move, jaskier_GO_UID)	--TODO-AUDIO: Play run sound
				--lua_table.AudioFunctions:SetAudioSwitch(audio_library.move_switch, audio_library.run_state, jaskier_GO_UID)
				current_audio = audio_library.move

				for i = 1, #particles_library.run_particles_GO_UID_children do
					lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
				end

				lua_table.current_state = state.run
			else																					--IF small input
				lua_table.current_velocity = walk_velocity
				lua_table.AnimationFunctions:PlayAnimation(animation_library.walk, lua_table.walk_animation_speed, jaskier_GO_UID)
				current_animation = animation_library.walk

				-- lua_table.AudioFunctions:PlayAudioEventGO(audio_library.move, jaskier_GO_UID)	--TODO-AUDIO: Play walk sound
				-- lua_table.AudioFunctions:SetAudioSwitch(audio_library.move_switch, audio_library.walk_state, jaskier_GO_UID)
				-- current_audio = audio_library.move

				lua_table.current_state = state.walk
			end

		--Swap between walking and running
		elseif lua_table.current_state == state.walk and lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF walking and big input
		then
			lua_table.current_velocity = run_velocity
			lua_table.AnimationFunctions:PlayAnimation(animation_library.run, lua_table.run_animation_speed, jaskier_GO_UID)
			current_animation = animation_library.run

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.move, jaskier_GO_UID)	--TODO-AUDIO: Play run sound
			--lua_table.AudioFunctions:SetAudioSwitch(audio_library.move_switch, audio_library.run_state, jaskier_GO_UID)
			current_audio = audio_library.move

			for i = 1, #particles_library.run_particles_GO_UID_children do
				lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
			end

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.run
			
		elseif lua_table.current_state == state.run and lua_table.input_walk_threshold > math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF running and small input
		then
			lua_table.current_velocity = walk_velocity
			lua_table.AnimationFunctions:PlayAnimation(animation_library.walk, lua_table.walk_animation_speed, jaskier_GO_UID)
			current_animation = animation_library.walk

			lua_table.AudioFunctions:StopAudioEventGO(audio_library.move, jaskier_GO_UID)	--TODO-AUDIO: Play run sound
			current_audio = audio_library.none
			--lua_table.AudioFunctions:SetAudioSwitch(audio_library.move_switch, audio_library.walk_state, jaskier_GO_UID)	--TODO-AUDIO: Switch to walk

			for i = 1, #particles_library.run_particles_GO_UID_children do
				lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
			end

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.walk
		end

		MoveCharacter(false, true)

	elseif lua_table.current_state == state.run or lua_table.current_state == state.walk
	then
		--Animation to IDLE
		lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, jaskier_GO_UID)
		current_animation = animation_library.idle

		--TODO-AUDIO: Stop current sound event
		lua_table.AudioFunctions:StopAudioEventGO(audio_library.move, jaskier_GO_UID)
		current_audio = audio_library.none

		for i = 1, #particles_library.run_particles_GO_UID_children do
			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
		end

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.idle
	end
end

--Character Movement END	----------------------------------------------------------------------------

--Character Actions BEGIN	----------------------------------------------------------------------------

local function Song_Cone_Effect(trapezoid_table)	--Uses trapezoid because it can adpot varied shapes, including a basic cone
	local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)

	SaveDirection()
	local A_z, A_x = BidimensionalRotate(trapezoid_table.point_A.z, trapezoid_table.point_A.x, rot_y)
	local B_z, B_x = BidimensionalRotate(trapezoid_table.point_B.z, trapezoid_table.point_B.x, rot_y)
	local C_z, C_x = BidimensionalRotate(trapezoid_table.point_C.z, trapezoid_table.point_C.x, rot_y)
	local D_z, D_x = BidimensionalRotate(trapezoid_table.point_D.z, trapezoid_table.point_D.x, rot_y)

	A_x, A_z = A_x + jaskier_pos[1], A_z + jaskier_pos[3]
	B_x, B_z = B_x + jaskier_pos[1], B_z + jaskier_pos[3]
	C_x, C_z = C_x + jaskier_pos[1], C_z + jaskier_pos[3]
	D_x, D_z = D_x + jaskier_pos[1], D_z + jaskier_pos[3]

	local enemy_list = lua_table.PhysicsFunctions:OverlapSphere(jaskier_pos[1], jaskier_pos[2], jaskier_pos[3], trapezoid_table.range, layers.enemy)
	for i = 1, #enemy_list do
		local enemy_pos = lua_table.TransformFunctions:GetPosition(enemy_list[i])

		if BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, enemy_pos[1], enemy_pos[3]) < 0	--If left side of all the trapezoid vectors BC, CD, DA ( \_/ )
		and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, enemy_pos[1], enemy_pos[3]) < 0
		and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, enemy_pos[1], enemy_pos[3]) < 0
		then
			local enemy_script = lua_table.GameObjectFunctions:GetScript(enemy_list[i])
			enemy_script:RequestedTrigger(jaskier_GO_UID)	--TODO-Ability:
		end
	end

	local prop_list = lua_table.PhysicsFunctions:OverlapSphere(jaskier_pos[1], jaskier_pos[2], jaskier_pos[3], trapezoid_table.range, layers.prop)
	for i = 1, #prop_list do
		local prop_pos = lua_table.TransformFunctions:GetPosition(prop_list[i])

		if BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, prop_pos[1], prop_pos[3]) < 0	--If left side of all the trapezoid vectors BC, CD, DA ( \_/ )
		and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, prop_pos[1], prop_pos[3]) < 0
		and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, prop_pos[1], prop_pos[3]) < 0
		then
			local prop_script = lua_table.GameObjectFunctions:GetScript(prop_list[i])
			prop_script:RequestedTrigger(jaskier_GO_UID)	--TODO-Ability:
		end
	end
end

local function PerformSong(song_type)
	local string_match = false

	if lua_table.note_num == lua_table[song_type .. "_size"] and CompareTables(lua_table.note_stack, lua_table[song_type])
	then
		current_action_block_time = lua_table[song_type .. "_duration"]
		current_action_duration = current_action_block_time

		lua_table.AnimationFunctions:PlayAnimation(lua_table[song_type .. "_animation_name"], lua_table[song_type .. "_animation_speed"], jaskier_GO_UID)
		lua_table.AnimationFunctions:PlayAnimation(lua_table[song_type .. "_animation_name"], lua_table[song_type .. "_animation_speed"], particles_library.slash_GO_UID)
		current_animation = song_type .. "_animation_name"

		if song_type == "song_1"
		then
			lua_table.TransformFunctions:SetLocalPosition(0.0, 2.0, 3.0, attack_colliders.line_1.GO_UID)
		elseif song_type == "song_3"
		then
			lua_table.TransformFunctions:RotateObject(0, 180, 0, jaskier_GO_UID)
		end

		lua_table.AudioFunctions:PlayAudioEventGO(audio_library[song_type], jaskier_GO_UID)	--TODO-AUDIO: Play sound of song_type
		current_audio = audio_library[song_type]

		lua_table.collider_damage = base_damage_real * lua_table[song_type .. "_damage"]
		lua_table.collider_effect = lua_table[song_type .. "_status_effect"]

		lua_table.collider_stun_duration, lua_table.collider_knockback_speed = 0, 0
		if lua_table.collider_effect == attack_effects_ID.stun then lua_table.collider_stun_duration = lua_table[song_type .. "_effect_value"]
		elseif lua_table.collider_effect == attack_effects_ID.knockback then lua_table.collider_knockback_speed = lua_table[song_type .. "_effect_value"] end

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state[song_type]

		lua_table[song_type .. "_effect_active"] = false

		string_match = true
	end

	return string_match
end

local function CheckSongs(perform)
	local song_matching = false

	if perform then
		if PerformSong("song_1") or PerformSong("song_2") or PerformSong("song_3") then
			song_matching = true
		end
	elseif lua_table.note_num == lua_table.song_1_size and CompareTables(lua_table.note_stack, lua_table.song_1)
	or lua_table.note_num == lua_table.song_2_size and CompareTables(lua_table.note_stack, lua_table.song_2)
	or lua_table.note_num == lua_table.song_3_size and CompareTables(lua_table.note_stack, lua_table.song_3)
	then
		song_matching = true
	end	

	return song_matching
end

local function AddNote(attack_made)
	PushBack(lua_table.note_stack, attack_made)			--Add new input to stack if song not available
	if lua_table.note_num < 4 then lua_table.note_num = lua_table.note_num + 1 end
end

local function RegisterAttack(attack_made)
	PushBack(lua_table.attack_stack, attack_made)
	if lua_table.ability_performed then 
		AddNote(attack_made)
		lua_table.ability_performed = not CheckSongs(false)
	end
end

local function PerformCombo(combo_type)
	local string_match = false

	if CompareArrays(lua_table.attack_stack, lua_table[combo_type], 2)
	then
		current_action_block_time = lua_table[combo_type .. "_block_time"]
		current_action_duration = lua_table[combo_type .. "_duration"]
		attack_slow_start = 5000

		lua_table.AnimationFunctions:PlayAnimation(combo_type, lua_table[combo_type .. "_animation_speed"], jaskier_GO_UID)
		lua_table.AnimationFunctions:PlayAnimation(combo_type, lua_table[combo_type .. "_animation_speed"], particles_library.slash_GO_UID)
		current_animation = combo_type
		
		lua_table.collider_damage = base_damage_real * lua_table[combo_type .. "_damage"]
		lua_table.collider_effect = lua_table[combo_type .. "_effect"]

		lua_table.collider_stun_duration, lua_table.collider_knockback_speed = 0, 0
		if lua_table.collider_effect == attack_effects_ID.stun then lua_table.collider_stun_duration = lua_table[combo_type .. "_effect_value"]
		elseif lua_table.collider_effect == attack_effects_ID.knockback then lua_table.collider_knockback_speed = lua_table[combo_type .. "_effect_value"] end
		
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state[combo_type]

		string_match = true
	end

	return string_match
end

local function CheckCombos()
	local combo_achieved = false

	lua_table.chained_attacks_num = lua_table.chained_attacks_num + 1
	
	if lua_table.chained_attacks_num == 3 then
		if PerformCombo("light_3") or PerformCombo("medium_3") or PerformCombo("heavy_3") then
			combo_achieved = true
			rightside = true
			lua_table.chained_attacks_num = 0
		else
			lua_table.chained_attacks_num = 1	--IF not combo, then setup so that counter restarts from a the next RIGHT hit
		end
	end

	return combo_achieved
end

local function RegularAttack(attack_type)
	local attack_sound_id 

	if attack_type == "light" then attack_sound_id = 1
	elseif attack_type == "medium" then attack_sound_id = 3
	else attack_sound_id = 2 end

	-- if lua_table.current_state == state.heavy_3 then	--Heavy_3 animation starts and ends on the right, therefore in this particular case we stay on the right
	-- 	rightside = not rightside
	-- end
	
	if rightside	--IF rightside
	then
		-- if lua_table.chained_attacks_num > 2	--IF more than 2 attacks chained
		-- then
		-- 	current_action_block_time = lua_table[attack_type .. "_3_block_time"]	--Set duration of input block (no new actions)
		-- 	current_action_duration = lua_table[attack_type .. "_3_duration"]		--Set duration of the current action (to return to idle/move)

		-- 	lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_3", lua_table[attack_type .. "_3_animation_speed"], jaskier_GO_UID)
		-- 	lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_3", lua_table[attack_type .. "_3_animation_speed"], particles_library.slash_GO_UID)
		-- 	current_animation = attack_type .. "_3"

		-- 	lua_table.AudioFunctions:PlayAudioEventGO(audio_library.attack .. attack_sound_id .. "_3", jaskier_GO_UID, jaskier_GO_UID)	--TODO-AUDIO: Play attack_3 sound
		-- 	current_audio = audio_library.attack .. attack_sound_id .. "_3"

		-- 	attack_slow_start = lua_table[attack_type .. "_3" .. "_slow_start"]

		-- 	lua_table.previous_state = lua_table.current_state
		-- 	lua_table.current_state = state[attack_type .. "_3"]
		-- else
			current_action_block_time = lua_table[attack_type .. "_1_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_1_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_1", lua_table[attack_type .. "_1_animation_speed"], jaskier_GO_UID)
			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_1", lua_table[attack_type .. "_1_animation_speed"], particles_library.slash_GO_UID)
			current_animation = attack_type .. "_1"

			attack_slow_start = lua_table[attack_type .. "_1" .. "_slow_start"]

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state[attack_type .. "_1"]
		-- end
	else			--IF leftside
		current_action_block_time = lua_table[attack_type .. "_2_block_time"]	--Set duration of input block (no new actions)
		current_action_duration = lua_table[attack_type .. "_2_duration"]		--Set duration of the current action (to return to idle/move)

		lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_2", lua_table[attack_type .. "_2_animation_speed"], jaskier_GO_UID)
		lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_2", lua_table[attack_type .. "_2_animation_speed"], particles_library.slash_GO_UID)
		current_animation = attack_type .. "_2"

		attack_slow_start = lua_table[attack_type .. "_2" .. "_slow_start"]

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state[attack_type .. "_2"]
	end

	lua_table.collider_damage = base_damage_real * lua_table[attack_type .. "_damage"]
	lua_table.collider_effect = attack_effects_ID.none
	rightside = not rightside
end

local function PerformEvade()
	action_made = false

	if lua_table.current_energy > lua_table.evade_cost
	then
		action_started_at = game_time							--Set timer start mark
		current_action_block_time = lua_table.evade_duration
		current_action_duration = lua_table.evade_duration
		
		SaveDirection()

		--Do Evade
		local position = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Rotate to direction
		lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, jaskier_GO_UID)

		lua_table.AnimationFunctions:PlayAnimation(animation_library.evade, lua_table.evade_animation_speed, jaskier_GO_UID)
		current_animation = animation_library.evade

		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.evade, jaskier_GO_UID)
		current_audio = audio_library.evade

		lua_table.current_energy = lua_table.current_energy - lua_table.evade_cost

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.evade

		for i = 1, #particles_library.run_particles_GO_UID_children do
			lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
		end

		action_made = true
	else
		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound
	end

	return action_made
end

local function ActionInputs(evade_only)	--Process Action Inputs
	local action_made = false
	local combo_achieved = false
	
	if not evade_only then
		RegisterAttackInputs()	--Check for Attack Inputs

		if attack_input_given then	--IF attack input made
			if game_time - attack_input_started_at > attack_input_timeframe		--IF surpassed double press timeframe
			or attack_inputs[lua_table.key_light] and attack_inputs[lua_table.key_medium]				--IF both buttons have been pressed
			then
				if attack_inputs[lua_table.key_light] and attack_inputs[lua_table.key_medium]		--Both inputs (Heavy)
				then
					action_started_at = game_time		--Set timer start mark

					RegisterAttack('H')
					combo_achieved = CheckCombos()

					if not combo_achieved then
						RegularAttack("heavy")
					end

					SaveDirection()

					local position = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Rotate to direction
					lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, jaskier_GO_UID)

					action_made = true

				elseif attack_inputs[lua_table.key_light]		--Light Input
				then
					action_started_at = game_time		--Set timer start mark

					RegisterAttack('L')
					combo_achieved = CheckCombos()

					if not combo_achieved then
						RegularAttack("light")
					end
					
					SaveDirection()

					local position = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Rotate to direction
					lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, jaskier_GO_UID)

					action_made = true

				elseif attack_inputs[lua_table.key_medium]	--Medium Input
				then
					action_started_at = game_time		--Set timer start mark

					RegisterAttack('M')
					combo_achieved = CheckCombos()

					if not combo_achieved then
						RegularAttack("medium")
					end

					SaveDirection()
			
					local position = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Rotate to direction
					lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, jaskier_GO_UID)
			
					action_made = true
				end

				attack_input_given, attack_inputs[lua_table.key_light], attack_inputs[lua_table.key_medium] = false, false, false
				--local time_between = game_time - attack_input_started_at
				--lua_table.SystemFunctions:LOG("Time Between inputs: " .. time_between)
			end
		else	--IF attack input not made, allow for any other kind of input
			if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_evade, key_state.key_down)	--Evade Input
			then
				action_made = PerformEvade()
				
			elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_ability, key_state.key_down)	--IF cooldown over and Ability Input
			then
				if game_time - ability_started_at >= lua_table.ability_cooldown
				then
					if CheckSongs(true) then
						action_started_at = game_time								--Set timer start mark
						ability_started_at = action_started_at

						lua_table.ability_performed = true
					else
						lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound
					end
					
					lua_table.note_num = 0
					action_made = true
				else
					lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound
				end

			elseif lua_table.current_ultimate >= lua_table.max_ultimate	--Ultimate Success Input
			and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_1, key_state.key_repeat)
			and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_2, key_state.key_repeat)
			then
				action_started_at = game_time							--Set timer start mark
				ultimate_started_at = action_started_at

				current_action_block_time = lua_table.ultimate_duration
				current_action_duration = lua_table.ultimate_duration

				--Do Ultimate
				lua_table.AnimationFunctions:PlayAnimation(animation_library.concert, lua_table.ultimate_animation_speed, jaskier_GO_UID)
				current_animation = animation_library.concert

				lua_table.AnimationFunctions:PlayAnimation(animation_library.concert, lua_table.ultimate_animation_speed, jaskier_lute_concert_GO_UID)
				lua_table.GameObjectFunctions:SetActiveGameObject(true, jaskier_lute_concert_mesh_GO_UID)
				lua_table.GameObjectFunctions:SetActiveGameObject(false, jaskier_lute_regular_GO_UID)

				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.concert, jaskier_GO_UID)
				current_audio = audio_library.concert

				lua_table.collider_damage = base_damage_real * lua_table.ultimate_damage * dt
				lua_table.collider_effect = lua_table.ultimate_status_effect

				lua_table.ultimate_active = true
				lua_table.current_ultimate = 0.0

				lua_table.previous_state = lua_table.current_state
				lua_table.current_state = state.ultimate
				action_made = true

			elseif lua_table.current_ultimate < lua_table.max_ultimate	--Ultimate Failed Input
			and (lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_1, key_state.key_repeat) and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_2, key_state.key_down)
			or lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_1, key_state.key_down) and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_2, key_state.key_repeat))
			then
				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound

			elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_revive, key_state.key_down)	--Revive Input
			then
				local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)

				if geralt_revive_GO_UID ~= nil and geralt_revive_GO_UID ~= 0
				then
					local geralt_revive_pos = lua_table.TransformFunctions:GetPosition(geralt_revive_GO_UID)

					--IF magnitude between Geralt and Jaskier revive is < revive_range
					if math.sqrt((geralt_revive_pos[1] - jaskier_pos[1]) ^ 2 + (geralt_revive_pos[3] - jaskier_pos[3]) ^ 2) < lua_table.revive_range
					then
						revive_target = geralt_script

						if revive_target.current_state == state.down and not revive_target.falling_down_bool and not revive_target.being_revived	--IF player downed and no one reviving
						then
							action_started_at = game_time		--Set timer start mark
							pulsation_started_at = game_time	--Set pulsation start mark
							current_action_block_time = lua_table.revive_time
							current_action_duration = lua_table.revive_time

							--Do Revive
							revive_target.being_revived = true

							lua_table.TransformFunctions:LookAt(geralt_revive_pos[1], jaskier_pos[2], geralt_revive_pos[3], jaskier_GO_UID)
							lua_table.AnimationFunctions:PlayAnimation(animation_library.revive, lua_table.revive_animation_speed, jaskier_GO_UID)
							current_animation = animation_library.revive

							lua_table.AudioFunctions:PlayAudioEventGO(audio_library.voice_revive_ally, jaskier_GO_UID)	--TODO-Audio: Not possible sound
							current_audio = audio_library.voice_revive_ally

							lua_table.previous_state = lua_table.current_state
							lua_table.current_state = state.revive
							action_made = true
						end
					end
					if not action_made then lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID) end	--TODO-Audio: Not possible sound

				else
					--LEGACY REVIVE (used when needed revive GO doesn't exist)
					local downed_list = lua_table.PhysicsFunctions:OverlapSphere(jaskier_pos[1], jaskier_pos[2], jaskier_pos[3], 3.0, layers.player)

					for i = 1, #downed_list do	--Check nearby players
						if downed_list[i] ~= jaskier_GO_UID	--IF player is not me
						then
							revive_target = lua_table.GameObjectFunctions:GetScript(downed_list[i])

							if revive_target.current_state == state.down and not revive_target.falling_down_bool and not revive_target.being_revived	--IF player downed and no one reviving
							then
								action_started_at = game_time		--Set timer start mark
								pulsation_started_at = game_time	--Set pulsation start mark
								current_action_block_time = lua_table.revive_time
								current_action_duration = lua_table.revive_time

								revive_target.being_revived = true

								--Do Revive
								revive_target.being_revived = true

								lua_table.AnimationFunctions:PlayAnimation(animation_library.revive, lua_table.revive_animation_speed, jaskier_GO_UID)
								current_animation = animation_library.revive

								lua_table.AudioFunctions:PlayAudioEventGO(audio_library.voice_revive_ally, jaskier_GO_UID)	--TODO-Audio: Not possible sound
								current_audio = audio_library.voice_revive_ally

								lua_table.previous_state = lua_table.current_state
								lua_table.current_state = state.revive
								action_made = true

								break
							end
						end
					end
					if not action_made then lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID) end	--TODO-Audio: Not possible sound

				end
			end
		end
	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_evade, key_state.key_down)	--Evade Input
	then
		action_made = PerformEvade()
	end

	if action_made 	--IF action performed
	then
		lua_table.AnimationFunctions:SetBlendTime(0.1, jaskier_GO_UID)
		blending_started_at = game_time	--Manually mark animation swap

		AttackColliderShutdown()

		if lua_table.current_state >= state.light_1 and lua_table.current_state <= state.heavy_3 or lua_table.current_state == state.song_1	--IF attack or song_1
		then
			input_slow_active = false
			lua_table.GameObjectFunctions:SetActiveGameObject(true, particles_library.slash_mesh_GO_UID)
			enemy_hit_curr_stage = enemy_hit_stages.awaiting_attack
		else
			lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)
			--lua_table.ParticlesFunctions:StopParticleEmitter(guitar_GO_UID)	--TODO-Particles: Deactivate Particles on Guitar
		end

		if lua_table.previous_state == state.run
		then
			for i = 1, #particles_library.run_particles_GO_UID_children do
				lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
			end
			lua_table.AudioFunctions:StopAudioEventGO(audio_library.move, jaskier_GO_UID)
		end
	end

	return action_made
end

local function ReviveShutdown()	--IF I was reviving, not anymore
	if revive_target ~= nil
	then
		lua_table.AudioFunctions:StopAudioEventGO(audio_library.voice_revive_ally, jaskier_GO_UID)	--TODO-Audio: Not possible sound
		current_audio = audio_library.none

		revive_target.being_revived = false
		revive_target = nil
	end
end

function lua_table:EnemyHit()
	if enemy_hit_curr_stage <= enemy_hit_stages.attack_miss then
		lua_table.AnimationFunctions:SetAnimationPause(true, jaskier_GO_UID)
		lua_table.AnimationFunctions:SetAnimationPause(true, particles_library.slash_GO_UID)

		if enemy_hit_curr_stage == enemy_hit_stages.attack_miss then
			lua_table.AudioFunctions:StopAudioEventGO(audio_library.attack_miss, jaskier_GO_UID)
		end
		
		if lua_table.current_state == state.light_3 then
			enemy_hit_duration = hit_durations.medium
			--current_paused_audio = audio_library.light_3

		elseif lua_table.current_state == state.medium_3 then
			enemy_hit_duration = hit_durations.medium
			--current_paused_audio = audio_library.medium_3

		elseif lua_table.current_state == state.heavy_3 then
			enemy_hit_duration = hit_durations.medium
			--current_paused_audio = audio_library.heavy_3
		else
			enemy_hit_duration = hit_durations.small
		end

		-- current_action_block_time = current_action_block_time + enemy_hit_duration
		-- current_action_duration = current_action_duration + enemy_hit_duration
		action_started_at = action_started_at + enemy_hit_duration
		enemy_hit_started_at = game_time

		if current_paused_audio ~= audio_library.none then
			lua_table.AudioFunctions:PauseAudioEventGO(current_paused_audio, jaskier_GO_UID)
		end

		enemy_hit_curr_stage = enemy_hit_stages.attack_hit
	end
end

--Character Actions END	----------------------------------------------------------------------------

--Character Secondaries BEGIN	----------------------------------------------------------------------------

--Health Potion
local function TakeHealthPotion()
	local ret = true

	if lua_table.current_health < lua_table.max_health_real then
		lua_table.current_health = lua_table.current_health + lua_table.max_health_real / item_effects[lua_table.item_library.health_potion].health_recovery
		lua_table.health_reg_mod = lua_table.health_reg_mod + item_effects[lua_table.item_library.health_potion].health_regen
		
		for i = 1, #particles_library.potion_health_particles_GO_UID_children do
			lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.potion_health_particles_GO_UID_children[i])	--TODO-Particles: Stop movement dust particles
		end

		if lua_table.current_health > lua_table.max_health_real then lua_table.current_health = lua_table.max_health_real end	--IF above max, set to max
	else
		ret = false
	end

	return ret
end

local function EndHealthPotion()
	lua_table.health_reg_mod = lua_table.health_reg_mod - item_effects[lua_table.item_library.health_potion].health_regen

	for i = 1, #particles_library.potion_health_particles_GO_UID_children do
		lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.potion_health_particles_GO_UID_children[i])	--TODO-Particles: Stop movement dust particles
	end
end

--Stamina Potion
local function TakeStaminaPotion()
	lua_table.mov_velocity_max_mod = lua_table.mov_velocity_max_mod + item_effects[lua_table.item_library.stamina_potion].speed_increase
	lua_table.energy_reg_mod = lua_table.energy_reg_mod + item_effects[lua_table.item_library.stamina_potion].energy_regen

	for i = 1, #particles_library.potion_stamina_particles_GO_UID_children do
		lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.potion_stamina_particles_GO_UID_children[i])	--TODO-Particles: Stop movement dust particles
	end

	return true
end

local function EndStaminaPotion()
	lua_table.mov_velocity_max_mod = lua_table.mov_velocity_max_mod - item_effects[lua_table.item_library.stamina_potion].speed_increase
	lua_table.energy_reg_mod = lua_table.energy_reg_mod - item_effects[lua_table.item_library.stamina_potion].energy_regen

	for i = 1, #particles_library.potion_stamina_particles_GO_UID_children do
		lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.potion_stamina_particles_GO_UID_children[i])	--TODO-Particles: Stop movement dust particles
	end
end

--Power Potion
local function TakePowerPotion()
	lua_table.base_damage_mod = lua_table.base_damage_mod + item_effects[lua_table.item_library.power_potion].damage_increase
	--lua_table.critical_chance_add = lua_table.critical_chance_add + item_effects[lua_table.item_library.power_potion].critical_chance_increase

	for i = 1, #particles_library.potion_power_particles_GO_UID_children do
		lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.potion_power_particles_GO_UID_children[i])	--TODO-Particles: Stop movement dust particles
	end

	return true
end

local function EndPowerPotion()
	lua_table.base_damage_mod = lua_table.base_damage_mod - item_effects[lua_table.item_library.power_potion].damage_increase
	--lua_table.critical_chance_add = lua_table.critical_chance_add - item_effects[lua_table.item_library.power_potion].critical_chance_increase

	for i = 1, #particles_library.potion_power_particles_GO_UID_children do
		lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.potion_power_particles_GO_UID_children[i])	--TODO-Particles: Stop movement dust particles
	end
end

--Inventory Swap
local function NextItem()	--Jump to next item you have num > 0 in inventory
	local new_item = lua_table.item_selected + 1

	while new_item ~= lua_table.item_selected do
		if new_item > item_library_size then
			new_item = 1
		end

		if true then--lua_table.inventory[new_item] > 0 then
			lua_table.item_selected = new_item
			return true
		end

		new_item = new_item + 1
	end

	return false
end

local function PrevItem()	--Jump to prev item you have num > 0 in inventory
	local new_item = lua_table.item_selected - 1

	while new_item ~= lua_table.item_selected do
		if new_item < 1 then
			new_item = item_library_size
		end

		if true then--lua_table.inventory[new_item] > 0 then
			lua_table.item_selected = new_item
			return true
		end

		new_item = new_item - 1
	end

	return false
end

--Potion Functions
local function TakePotion()
	if lua_table.inventory[lua_table.item_selected] > 0 then	--IF potions of type left
		local potion_is_taken = true

		if lua_table.item_selected == lua_table.item_library.health_potion then potion_is_taken = TakeHealthPotion()
		elseif lua_table.item_selected == lua_table.item_library.stamina_potion then potion_is_taken = TakeStaminaPotion()
		elseif lua_table.item_selected == lua_table.item_library.power_potion then potion_is_taken = TakePowerPotion()
		end

		if potion_is_taken then
			lua_table.potion_in_effect = lua_table.item_selected	-- Save Potion number id to later use

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.item_potion, jaskier_GO_UID)	--TODO-AUDIO:
			--current_audio = audio_library.item_potion

			potion_taken_at = game_time		--Mark drink time
			lua_table.potion_active = true	--Mark potion in effect

			if lua_table.shared_inventory[lua_table.item_selected] > 0 then
				lua_table.shared_inventory[lua_table.item_selected] = lua_table.shared_inventory[lua_table.item_selected] - 1
				if geralt_score ~= nil then geralt_score[7] = geralt_score[7] + 1 end	--TODO-Score:
			end

			lua_table.inventory[lua_table.item_selected] = lua_table.inventory[lua_table.item_selected] - 1	--Remove potion from inventory
			must_update_stats = true	--Flag stats for update
		else
			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound
		end
	else
		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound
	end
end

local function EndPotion()
	if lua_table.potion_in_effect == lua_table.item_library.health_potion then EndHealthPotion()
	elseif lua_table.potion_in_effect == lua_table.item_library.stamina_potion then EndStaminaPotion()
	elseif lua_table.potion_in_effect == lua_table.item_library.power_potion then EndPowerPotion() end

	lua_table.potion_in_effect = lua_table.item_library.none
	lua_table.potion_active = false	--Mark potion off effect
	must_update_stats = true	--Flag stats for update
end

local function PickupItem()
	local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)
	local nearby_items = lua_table.PhysicsFunctions:OverlapSphere(jaskier_pos[1], jaskier_pos[2], jaskier_pos[3], lua_table.item_pickup_range, layers.item)	--TODO-Potions: Uncomment when layer exists

	local item_picked_up = false
	for i = 1, #nearby_items do
		if nearby_items[i] ~= nil then
			local item_script = lua_table.GameObjectFunctions:GetScript(nearby_items[i])
	
			if item_script.item_id ~= nil and item_script.item_id >= 1 and item_script.item_id <= 3
			then
				if lua_table.inventory[item_script.item_id] < lua_table.item_type_max then
					lua_table.GameObjectFunctions:DestroyGameObject(item_script.myUID)	--Alternative: item_script.GameObjectFunctions:GetMyUID()
					lua_table.AudioFunctions:PlayAudioEventGO(audio_library.potion_pickup, jaskier_GO_UID)	--TODO-Audio: Drop potion sound
		
					if item_script.player_owner ~= nil and item_script.player_owner == geralt_GO_UID then lua_table.shared_inventory[item_script.item_id] = lua_table.shared_inventory[item_script.item_id] + 1 end	--TODO-Score
					lua_table.inventory[item_script.item_id] = lua_table.inventory[item_script.item_id] + 1	--Add potion to inventory
	
					item_picked_up = true
					break
				end
			else
				if item_script.myUID ~= nil then
					lua_table.GameObjectFunctions:DestroyGameObject(item_script.myUID)	--Alternative: item_script.GameObjectFunctions:GetMyUID()
				end
			end
		end
	end

	if not item_picked_up then
		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound
	end
end

local function DropItem()
	if lua_table.inventory[lua_table.item_selected] > 0 then	--IF potions of type left
		local item_GO = 0

		if item_prefabs[lua_table.item_selected] ~= nil and item_prefabs[lua_table.item_selected] ~= 0 then
			local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)
			item_GO = lua_table.SceneFunctions:Instantiate(item_prefabs[lua_table.item_selected], jaskier_pos[1], jaskier_pos[2], jaskier_pos[3], 0.0, 0.0, 0.0) --Instantiate a potion of said type on character Location	
		end
		
		if item_GO ~= nil and item_GO ~= 0 then
			local item_script = lua_table.GameObjectFunctions:GetScript(item_GO)
			if item_script ~= nil and item_script.player_owner ~= nil then item_script.player_owner = jaskier_GO_UID end
		end

		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.potion_drop, jaskier_GO_UID)	--TODO-Audio: Drop potion sound

		if lua_table.shared_inventory[lua_table.item_selected] > 0 then lua_table.shared_inventory[lua_table.item_selected] = lua_table.shared_inventory[lua_table.item_selected] - 1 end	--TODO-Score
		lua_table.inventory[lua_table.item_selected] = lua_table.inventory[lua_table.item_selected] - 1	--Remove potion from inventory
	else
		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID)	--TODO-Audio: Not possible sound
	end
end

local function SecondaryInputs()	--Process Secondary Inputs
	if not lua_table.potion_active then
		if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_use_item, key_state.key_down)		--Take potion
		or keyboard_mode and lua_table.InputFunctions:KeyDown("J")
		then
			TakePotion()

			--if lua_table.inventory[lua_table.item_selected] == 0 then NextItem() end	--IF no more if that type of item, jump to next
		end
	end
	
	if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_prev_consumable, key_state.key_down)	--Previous Consumable
	or keyboard_mode and lua_table.InputFunctions:KeyDown("K")
	then
		if not PrevItem() then lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID) end	--TODO-Audio: Not possible sound
	
	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_next_consumable, key_state.key_down)	--Next Consumable
	or keyboard_mode and lua_table.InputFunctions:KeyDown("L")
	then
		if not NextItem() then lua_table.AudioFunctions:PlayAudioEventGO(audio_library.not_possible, jaskier_GO_UID) end	--TODO-Audio: Not possible sound

	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_pickup_item, key_state.key_down)
	then	--Take Consumable
		PickupItem()
	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_drop_consumable, key_state.key_down)	--Drop Consumable
	then
		DropItem()
	end
end

--Character Secondaries END	----------------------------------------------------------------------------

--Collider Calls BEGIN

function lua_table:Resurrect()
	lua_table.previous_state = state.down
	lua_table.current_state = state.down
	lua_table.current_health = lua_table.max_health_real
	lua_table.current_energy = lua_table.max_energy_real
	lua_table.current_ultimate = 0.0

	lua_table.AnimationFunctions:PlayAnimation(animation_library.stand_up, lua_table.stand_up_animation_speed, jaskier_GO_UID)	--TODO-Animations: Stand up
	current_animation = animation_library.stand_up
	blending_started_at = game_time	--Manually mark animation swap

	lua_table.AudioFunctions:PlayAudioEventGO(audio_library.stand_up, jaskier_GO_UID)
	current_audio = audio_library.stand_up

	lua_table.standing_up_bool = true
	lua_table.resurrecting = true
end

local function Die()

	AttackColliderShutdown()
	ParticlesShutdown()
	AudioShutdown()
	ReviveShutdown()

	lua_table.PhysicsFunctions:SetActiveController(false, jaskier_GO_UID)

	lua_table.death_started_at = game_time

	lua_table.AnimationFunctions:SetBlendTime(0.1, jaskier_GO_UID)
	lua_table.AnimationFunctions:PlayAnimation(animation_library.death, 30.0, jaskier_GO_UID)
	current_animation = animation_library.death
	blending_started_at = game_time	--Manually mark animation swap

	lua_table.AudioFunctions:PlayAudioEventGO(audio_library.death, jaskier_GO_UID)
	current_audio = audio_library.death

	lua_table.AudioFunctions:StopAudioEventGO(audio_library.voice_low_health, jaskier_GO_UID)	--TODO-AUDIO:
	near_death_playing = false

	lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.medium.intensity, controller_shake.medium.duration)

	lua_table.falling_down_bool = true
	lua_table.standing_up_bool = false

	lua_table.enemies_nearby = false

	lua_table.previous_state = lua_table.current_state
	lua_table.current_state = state.down

	if lua_table.potion_active then EndPotion() end				--IF potion in effect, turn off

	--TODO-Audio:
	if lua_table.ultimate_active
	then
		-- lua_table.AudioFunctions:StopAudioEventGO(audio_library.concert, jaskier_GO_UID)
		-- current_audio = audio_library.none
		lua_table.ultimate_active = false
		lua_table.ultimate_effect_active = false
		lua_table.ultimate_secondary_effect_active = false
	end
end

local function ProcessIncomingHit(collider_GO)

	if not godmode and lua_table.current_state < state.song_1 and lua_table.current_state > state.down and lua_table.current_state ~= state.ultimate
	then
		local collider_parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_GO)
		local enemy_script = {}

		if collider_parent ~= 0 then	--IF collider has parent, relevant data is saved on the highest parent in the hierarchy ("the manager")
			-- local tmp_parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_parent)

			-- while tmp_parent ~= 0 do	-- tmp_parent checks if <root> is the current parent of collider_parent, if it is then collider_parent is the highest parent in the hierarchy ("the manager")
			-- 	collider_parent = tmp_parent
			-- 	tmp_parent = lua_table.GameObjectFunctions:GetGameObjectParent(tmp_parent)
			-- end

			enemy_script = lua_table.GameObjectFunctions:GetScript(collider_parent)
			
		else							--IF collider has no parent, data is saved within collider
			enemy_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
		end

		if not lua_table.immortal then
			lua_table.current_health = lua_table.current_health - enemy_script.collider_damage
		end

		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.hurt, jaskier_GO_UID)	--TODO-AUDIO:
		--current_audio = audio_library.hurt

		for i = 1, #particles_library.blood_particles_GO_UID_children do
			lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.blood_particles_GO_UID_children[i])	--TODO-Particles:
		end

		if lua_table.current_health <= 0	--IF has to die
		then
			Die()

		else
			if not near_death_playing and lua_table.current_health < near_death_health then
				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.voice_low_health, jaskier_GO_UID)	--TODO-AUDIO:
				near_death_playing = true
			end

			if enemy_script.collider_effect ~= attack_effects_ID.none and lua_table.current_state >= state.idle	--IF survived, and effect, and ready to take one
			then
				lua_table.AnimationFunctions:SetBlendTime(0.1, jaskier_GO_UID)

				AttackColliderShutdown()
				ParticlesShutdown()
				AudioShutdown()
				ReviveShutdown()

				if enemy_hit_curr_stage == enemy_hit_stages.attack_hit
				then
					lua_table.AnimationFunctions:SetAnimationPause(false, jaskier_GO_UID)
					lua_table.AnimationFunctions:SetAnimationPause(false, particles_library.slash_GO_UID)
					enemy_hit_curr_stage = enemy_hit_stages.attack_finished
				end

				if enemy_script.collider_effect == attack_effects_ID.stun
				then
					lua_table.AnimationFunctions:PlayAnimation(animation_library.stun, 45.0, jaskier_GO_UID)
					current_animation = animation_library.stun

					lua_table.AudioFunctions:PlayAudioEventGO(audio_library.stun, jaskier_GO_UID)	--TODO-AUDIO:
					current_audio = audio_library.stun

					for i = 1, #particles_library.stun_particles_GO_UID_children do
						lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.stun_particles_GO_UID_children[i])	--TODO-Particles:
					end

					lua_table.previous_state = lua_table.current_state
					lua_table.current_state = state.stunned

				elseif enemy_script.collider_effect == attack_effects_ID.knockback
				then
					local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)	--Look at and set direction from knockback
					local knockback_pos

					if collider_parent ~= 0 then
						knockback_pos = lua_table.TransformFunctions:GetPosition(collider_parent)
					else
						knockback_pos = lua_table.TransformFunctions:GetPosition(collider_GO)
					end

					lua_table.TransformFunctions:LookAt(knockback_pos[1], jaskier_pos[2], knockback_pos[3], jaskier_GO_UID)
					
					rec_direction.x = jaskier_pos[1] - knockback_pos[1]
					rec_direction.z = jaskier_pos[3] - knockback_pos[3]
					local magnitude = math.sqrt(rec_direction.x ^ 2 + rec_direction.z ^ 2)
					rec_direction.x = rec_direction.x / magnitude
					rec_direction.z = rec_direction.z / magnitude

					knockback_curr_velocity = lua_table.knockback_orig_velocity

					lua_table.AnimationFunctions:PlayAnimation(animation_library.knockback, 60.0, jaskier_GO_UID)
					current_animation = animation_library.knockback

					lua_table.AudioFunctions:PlayAudioEventGO(audio_library.knockback, jaskier_GO_UID)	--TODO-AUDIO:
					current_audio = audio_library.knockback

					lua_table.standing_up_bool = false

					lua_table.previous_state = lua_table.current_state
					lua_table.current_state = state.knocked
				end

				current_action_duration = attack_effects_durations[enemy_script.collider_effect]
				action_started_at = game_time
				blending_started_at = game_time	--Manually mark animation swap
				lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.medium.intensity, controller_shake.medium.duration)
				ShakeCamera(camera_shake.small.duration, camera_shake.small.intensity)
			end
		end
	end
end

function lua_table:OnTriggerEnter()
	--lua_table.SystemFunctions:LOG("On Trigger Enter")
	
	local collider_GO = 0

	if jaskier_GO_UID ~= nil and jaskier_GO_UID ~= 0 then
		collider_GO = lua_table.PhysicsFunctions:OnTriggerEnter(jaskier_GO_UID)
	end

	if collider_GO ~= nil and collider_GO ~= 0 and lua_table.GameObjectFunctions:GetLayerByID(collider_GO) == layers.enemy_attack	--IF collider is tagged as an enemy attack
	then
		ProcessIncomingHit(collider_GO)
	end
end

function lua_table:OnCollisionEnter()
	--lua_table.SystemFunctions:LOG("On Collision Enter")

	local collider_GO = 0

	if jaskier_GO_UID ~= nil and jaskier_GO_UID ~= 0 then
		collider_GO = lua_table.PhysicsFunctions:OnCollisionEnter(jaskier_GO_UID)
	end

	if collider_GO ~= nil and collider_GO ~= 0 and lua_table.GameObjectFunctions:GetLayerByID(collider_GO) == layers.enemy_attack	--IF collider is tagged as an enemy attack
	then
		ProcessIncomingHit(collider_GO)
	end
end

--Collider Calls END

--Debug BEGIN 	----------------------------------------------------------------------------

local function DebugInputs()
	if lua_table.InputFunctions:KeyRepeat("Left Ctrl") then
		if lua_table.InputFunctions:KeyDown("1")	--God mode
		then
			godmode = not godmode

		elseif lua_table.InputFunctions:KeyDown("2")	--No ability cooldowns
		then
			if lua_table.ability_cooldown > 0.0 then lua_table.ability_cooldown = 0.0
			else lua_table.ability_cooldown = 1000.0 end

		elseif lua_table.InputFunctions:KeyDown("3")	--Insta ultimate
		then
			lua_table.current_ultimate = lua_table.max_ultimate

		elseif lua_table.InputFunctions:KeyDown("5")	--Instakill/Revive Jaskier
		then
			if lua_table.current_health > 0
			then
				lua_table.current_health = lua_table.current_health - 25
				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.hurt, jaskier_GO_UID)	--TODO-AUDIO:
				if lua_table.current_health <= 0 then Die() end

			elseif lua_table.current_state == state.down and not lua_table.falling_down_bool
			then
				lua_table.being_revived = true
			elseif lua_table.current_state == state.dead
			then
				lua_table.PhysicsFunctions:SetActiveController(true, jaskier_GO_UID)
				lua_table.GameObjectFunctions:SetActiveGameObject(true, jaskier_mesh_GO_UID)
				lua_table.GameObjectFunctions:SetActiveGameObject(true, jaskier_pivot_GO_UID)
				lua_table:Start()

				if geralt_GO_UID ~= nil and geralt_GO_UID ~= 0
				then
					local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
					lua_table.PhysicsFunctions:SetCharacterPosition(geralt_pos[1], geralt_pos[2] + 5.0, geralt_pos[3], jaskier_GO_UID)
				end
			end

		elseif lua_table.InputFunctions:KeyDown("7")	--	--Reset character and reposition Jaskier to Geralt
		then
			lua_table.PhysicsFunctions:SetActiveController(false, jaskier_GO_UID)
			lua_table.PhysicsFunctions:SetActiveController(true, jaskier_GO_UID)
			lua_table.GameObjectFunctions:SetActiveGameObject(true, jaskier_mesh_GO_UID)
			lua_table.GameObjectFunctions:SetActiveGameObject(true, jaskier_pivot_GO_UID)
			lua_table:Start()

			if geralt_GO_UID ~= nil and geralt_GO_UID ~= 0
			then
				local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
				lua_table.PhysicsFunctions:SetCharacterPosition(geralt_pos[1], geralt_pos[2] + 5.0, geralt_pos[3], jaskier_GO_UID)
			end

		elseif lua_table.InputFunctions:KeyDown("8")	--Keyboard Mode
		then
			keyboard_mode = not keyboard_mode
		end
	end
end

--Debug END 	----------------------------------------------------------------------------

function lua_table:StartBattle()
	lua_table.AudioFunctions:PlayAudioEventGO(audio_library.voice_battle_start, jaskier_GO_UID)	--TODO-AUDIO:
	lua_table.AudioFunctions:StopAudioEventGO(audio_library.voice_battle_end, jaskier_GO_UID)	--TODO-AUDIO:
end

function lua_table:EndBattle()
	lua_table.AudioFunctions:PlayAudioEventGO(audio_library.voice_battle_end, jaskier_GO_UID)	--TODO-AUDIO:
	lua_table.AudioFunctions:StopAudioEventGO(audio_library.voice_battle_start, jaskier_GO_UID)	--TODO-AUDIO:
end

local function EnemiesNearby()
	local ret = false
	local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)
	local enemy_list = lua_table.PhysicsFunctions:OverlapSphere(jaskier_pos[1], jaskier_pos[2], jaskier_pos[3], lua_table.enemy_detection_range, layers.enemy)
	if enemy_list[1] ~= nil then ret = true end
	return ret
end

local function CheckCombatStatus()
	if game_time - enemy_detection_started_at > enemy_detection_time
	then
		if lua_table.enemies_nearby then
			if not EnemiesNearby() then
				lua_table.enemies_nearby = false

				if geralt_script ~= nil and not geralt_script.enemies_nearby and lua_table.SystemFunctions:RandomNumberInRange(0, 100) < 25 then
					if lua_table.current_state > state.down then lua_table:EndBattle() end
					if geralt_script.current_state > state.down then geralt_script:EndBattle() end
					--lua_table.SystemFunctions:LOG("JASKIER END BATTLE ---------------------")
				end
			end
		else
			if EnemiesNearby() then
				lua_table.enemies_nearby = true
				
				if geralt_script ~= nil and not geralt_script.enemies_nearby and lua_table.SystemFunctions:RandomNumberInRange(0, 100) < 25 then
					if lua_table.current_state > state.down then lua_table:StartBattle() end
					if geralt_script.current_state > state.down then geralt_script:StartBattle() end
					--lua_table.SystemFunctions:LOG("JASKIER START BATTLE ---------------------")
				end
			end
		end

		enemy_detection_started_at = game_time
	end
end

local function CalculateTrapezoid(trapezoid_table)
	trapezoid_table.point_B.x = trapezoid_table.offset_x + math.tan(trapezoid_table.angle) * (trapezoid_table.range - trapezoid_table.offset_z)
	trapezoid_table.point_B.z = trapezoid_table.range

	trapezoid_table.point_A.x = -trapezoid_table.point_B.x
	trapezoid_table.point_A.z = trapezoid_table.range

	trapezoid_table.point_C.x = trapezoid_table.offset_x
	trapezoid_table.point_C.z = trapezoid_table.offset_z

	trapezoid_table.point_D.x = -trapezoid_table.offset_x
	trapezoid_table.point_D.z = trapezoid_table.offset_z
end

--Main Code
function lua_table:Awake()
	lua_table.SystemFunctions:LOG("JaskierScript AWAKE")

	--Scoreboard Setup (if not done yet)
	if jaskier_score == nil then
		jaskier_score = {
			0,  --damage_dealt  --Exception, this numbers value_per_instance ratio is 1:1, since this will collect the real value already
			0,  --minion_kills
			0,  --special_kills
			0,  --incapacitations
			0,  --objects_destroyed
			0,	--chests opened
			0,  --potions_shared
			0   --ally_revived
		}
	end

	--Assign Controller
	if player1_focus ~= nil and player1_focus == character_ID.jaskier then
		lua_table.player_ID = 1
	elseif player2_focus ~= nil and player2_focus == character_ID.jaskier then
		lua_table.player_ID = 2
	end

	--Get GO_UIDs
	geralt_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt")
	jaskier_GO_UID = lua_table.GameObjectFunctions:GetMyUID()

	if geralt_GO_UID ~= 0 then geralt_script = lua_table.GameObjectFunctions:GetScript(geralt_GO_UID) end

	jaskier_mesh_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Mesh")
	jaskier_pivot_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Pivot")

	jaskier_lute_regular_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Lute_Regular")
	jaskier_lute_concert_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Lute_Concert")
	jaskier_lute_concert_mesh_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Lute_Concert_Mesh")

	particles_library.slash_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Slash")
	particles_library.slash_mesh_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Slash_Mesh_Jaskier")

	geralt_revive_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Revive_Pos")
	jaskier_revive_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Revive_Pos")

	lua_table.PhysicsFunctions:SetActiveController(false, jaskier_GO_UID)
	lua_table.PhysicsFunctions:SetActiveController(true, jaskier_GO_UID)

	--Assign Prefabs
	item_prefabs[1] = lua_table.potion_health_prefab
	item_prefabs[2] = lua_table.potion_stamina_prefab
	item_prefabs[3] = lua_table.potion_power_prefab

	--Get Particle Emitters GO_UID
	--guitar_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Guitar")

	particles_library.run_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Run"))
	particles_library.blood_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Blood"))
	particles_library.stun_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Stun"))

	particles_library.revive_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Revive"))
	particles_library.down_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Down"))
	particles_library.death_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Death"))

	particles_library.potion_health_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Health_Potion"))
	particles_library.potion_stamina_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Stamina_Potion"))
	particles_library.potion_power_particles_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Power_Potion"))

	particles_library.song_circle_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Song_Circle"))
	particles_library.song_cone_mov_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Song_Cone_Mov"))
	particles_library.song_cone_fix_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Song_Cone_Fix"))
	particles_library.concert_GO_UID_children = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindGameObject("Jaskier_Song_Concert"))

	--Get attack_colliders GO_UIDs by name
	attack_colliders.front_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.front_1.GO_name)
	attack_colliders.front_2.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.front_2.GO_name)

	attack_colliders.line_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.line_1.GO_name)
	attack_colliders.circle_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.circle_1.GO_name)
	attack_colliders.circle_2.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.circle_2.GO_name)
	attack_colliders.concert.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.concert.GO_name)

	--Camera (Warning: If there's a camera GO, but no script the Engine WILL crash)
	camera_GO = lua_table.GameObjectFunctions:FindGameObject("Camera")
	if camera_GO ~= nil and camera_GO ~= 0
	then
		camera_script = lua_table.GameObjectFunctions:GetScript(camera_GO)
		camera_bounds_ratio = camera_script.Layer_3_FOV_ratio_1
	end

	lua_table.max_health_real = lua_table.max_health_orig	--Necessary for the first CalculateStats()
	CalculateStats()	--Calculate stats based on orig values + modifier

	CalculateTrapezoid(song_2_trapezoid)
end

function lua_table:Start()
	lua_table.SystemFunctions:LOG("JaskierScript START")
	
	--Stop Particle Emitters
	-- for i = 1, #particles_library.run_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_particles_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.blood_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.blood_particles_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.stun_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.stun_particles_GO_UID_children[i])	--TODO-Particles:
	-- end

	-- for i = 1, #particles_library.revive_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.revive_particles_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.down_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.down_particles_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.death_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.death_particles_GO_UID_children[i])	--TODO-Particles:
	-- end

	-- for i = 1, #particles_library.potion_health_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.potion_health_particles_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.potion_stamina_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.potion_stamina_particles_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.potion_power_particles_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.potion_power_particles_GO_UID_children[i])	--TODO-Particles:
	-- end

	-- for i = 1, #particles_library.song_circle_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_circle_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.song_cone_mov_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_cone_mov_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.song_cone_fix_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_cone_fix_GO_UID_children[i])	--TODO-Particles:
	-- end
	-- for i = 1, #particles_library.concert_GO_UID_children do
	-- 	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.concert_GO_UID_children[i])		--TODO-Particles:
	-- end

	--Set Particle GO Animations to for smooth blending to required animations
	lua_table.AnimationFunctions:SetBlendTime(0.1, particles_library.slash_GO_UID)
	lua_table.AnimationFunctions:PlayAnimation(animation_library.evade, lua_table.evade_animation_speed, particles_library.slash_GO_UID)
	
	lua_table.AnimationFunctions:SetBlendTime(0.1, jaskier_lute_concert_GO_UID)
	lua_table.AnimationFunctions:PlayAnimation(animation_library.evade, lua_table.evade_animation_speed, jaskier_lute_concert_GO_UID)

	--Hide GO Particles
	lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)
	lua_table.GameObjectFunctions:SetActiveGameObject(false, jaskier_lute_concert_mesh_GO_UID)

	--Set initial values
	lua_table.previous_state = state.idle
	lua_table.current_state = state.idle
	lua_table.current_health = lua_table.max_health_real
	lua_table.current_energy = lua_table.max_energy_real
	lua_table.current_ultimate = 0.0

	--Default Starting Animations
	lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, jaskier_GO_UID)
	current_animation = animation_library.idle
end

function lua_table:Update()

	if lua_table.SystemFunctions:IsGamePaused() == 0
	then
		if game_paused then
			game_paused = false
		else
			dt = lua_table.SystemFunctions:DT()
			game_time = PerfGameTime()

			DebugInputs()
			if must_update_stats then CalculateStats() end

			CheckMapBoundaries()

			if lua_table.current_state ~= state.dead	--IF not dead (stuff done while downed too)
			then
				CheckCombatStatus()
				CheckCameraBounds()

				--Energy Regeneration
				if lua_table.current_energy < lua_table.max_energy_real then lua_table.current_energy = lua_table.current_energy + energy_reg_real * dt end	--IF can increase, increase energy
				if lua_table.current_energy > lua_table.max_energy_real then lua_table.current_energy = lua_table.max_energy_real end						--IF above max, set to max
				
				if not lua_table.ultimate_active	--IF ultimate offline
				then
					--Ultimate Regeneration
					if lua_table.current_ultimate < lua_table.max_ultimate then
						lua_table.current_ultimate = lua_table.current_ultimate + ultimate_reg_real * dt

						if lua_table.current_ultimate >= lua_table.max_ultimate then
							lua_table.current_ultimate = lua_table.max_ultimate
							lua_table.AudioFunctions:PlayAudioEventGO(audio_library.ultimate_recharged, jaskier_GO_UID)	--TODO-AUDIO:
						end
					end
				elseif lua_table.current_state ~= state.ultimate then
					lua_table.ultimate_active = false
					lua_table.ultimate_effect_active = false
					lua_table.ultimate_secondary_effect_active = false
				end

				if lua_table.potion_active and game_time - potion_taken_at > lua_table.potion_duration then EndPotion() end
			end

			if lua_table.current_state > state.down and lua_table.current_health > 0	--IF alive
			then
				--Health Regeneration
				if health_reg_real > 0	--IF health regen online
				then
					if lua_table.current_health < lua_table.max_health_real then
						lua_table.current_health = lua_table.current_health + health_reg_real * dt
						if lua_table.current_health > lua_table.max_health_real then lua_table.current_health = lua_table.max_health_real end
					end
				end

				--Check low health sound
				if near_death_playing and lua_table.current_health >= near_death_health then
					lua_table.AudioFunctions:StopAudioEventGO(audio_library.voice_low_health, jaskier_GO_UID)	--TODO-AUDIO:
					near_death_playing = false
				end

				--Calculate time of ongoing event (when not idle/walk/run)
				if lua_table.current_state < state.idle or lua_table.current_state > state.run then time_since_action = game_time - action_started_at end

				if lua_table.current_state >= state.idle	--IF acting on free will (idle, attacking)
				then
					--DEBUG
					if keyboard_mode then KeyboardInputs()
					else
						JoystickInputs(lua_table.key_move, mov_input)
						JoystickInputs(lua_table.key_aim, aim_input)
					end

					-- Mark Idle Blend Time Finished
					if lua_table.current_state == state.idle and not idle_blend_finished and game_time - idle_started_at > lua_table.blend_time_duration then idle_blend_finished = true end

					--IF state == idle/move or action_input_block_time has ended (Input-allowed environment)
					if lua_table.current_state == state.idle and idle_blend_finished
					or lua_table.current_state == state.walk or lua_table.current_state == state.run
					or lua_table.current_state > state.run and time_since_action > current_action_block_time
					then
						if ActionInputs(false) then time_since_action = game_time - action_started_at end	-- Recalculate time passed if action performed

					elseif lua_table.current_state >= state.light_1 and lua_table.current_state <= state.heavy_2
					and lua_table.current_state ~= state.light_3 and lua_table.current_state ~= state.medium_3
					and game_time - blending_started_at > lua_table.blend_time_duration
					then
						if ActionInputs(true) then time_since_action = game_time - action_started_at end	-- Recalculate time passed if action performed
					end

					--IF there's no action being performed
					if lua_table.current_state <= state.run
					then
						MovementInputs()	--Movement orders
						SecondaryInputs()	--Minor actions with no timer or special animations

					else	--ELSE (action being performed)
						--LEGACY: time_since_action > current_action_duration
						if time_since_action > lua_table.blend_time_duration	--IF action time > blend time (for blending between actions)
						and game_time - blending_started_at > lua_table.blend_time_duration	--IF blend manual marking > blend time (to manually mark and control animation swaps, optional use)
						and lua_table.AnimationFunctions:CurrentAnimationEnded(jaskier_GO_UID) == 1	--IF animation finished (this only works for non-loop animations)
						then
							local chained_action = false

							if lua_table.current_state == state.revive
							then
								revive_target = nil
							elseif lua_table.current_state == state.song_1
							then
								lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)
								lua_table.song_1_effect_active = false
							elseif lua_table.current_state == state.song_2
							then
								for i = 1, #particles_library.song_cone_mov_GO_UID_children do
									lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_cone_mov_GO_UID_children[i])	--TODO-Particles:
								end
								for i = 1, #particles_library.song_cone_fix_GO_UID_children do
									lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_cone_fix_GO_UID_children[i])	--TODO-Particles:
								end
								lua_table.song_2_effect_active = false
							elseif lua_table.current_state == state.song_3
							then
								for i = 1, #particles_library.song_circle_GO_UID_children do
									lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_circle_GO_UID_children[i])	--TODO-Particles:
								end

								lua_table.song_3_secondary_effect_active = false
							elseif lua_table.current_state == state.ultimate
							then
								lua_table.AudioFunctions:StopAudioEventGO(audio_library.concert, jaskier_GO_UID)
								current_audio = audio_library.none

								for i = 1, #particles_library.song_circle_GO_UID_children do
									lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.song_circle_GO_UID_children[i])	--TODO-Particles:
								end
								lua_table.ultimate_active = false
								lua_table.ultimate_effect_active = false
								lua_table.ultimate_secondary_effect_active = false
							elseif lua_table.current_state >= state.light_1 and lua_table.current_state <= state.heavy_3	--IF attack finished
							then
								if attack_input_given	--IF attack input was given before time ran out, process it instantly
								then
									attack_input_timeframe = 0
									chained_action = ActionInputs(false)
									attack_input_timeframe = 70
								else
									lua_table.AnimationFunctions:PlayAnimation(animation_library.evade, lua_table.evade_animation_speed, particles_library.slash_GO_UID)
									lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)
								end
							end

							AttackColliderShutdown()
							
							if not chained_action then	--IF action not performed automatically after ending previous one, return to idle/move
								--Return to move or idle
								if lua_table.current_state == state.evade or lua_table.current_state == state.revive then
									GoDefaultState(false)	--Don't change BlendDuration
								else
									GoDefaultState(true)	--Change BlendDuration
								end
							end
							
						--ELSE (For all the following): IF action ongoing at the moment
						else
							if lua_table.current_state == state.revive
							then
								if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_revive, key_state.key_up)
								then
									ReviveShutdown()
									GoDefaultState(false)
								elseif game_time - pulsation_started_at > pulsation_interval_duration
								then
									lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.small.intensity, controller_shake.small.duration)
									pulsation_started_at = game_time
								end

							elseif lua_table.current_state == state.evade and DirectionInBounds(true)				--ELSEIF evading
							then
								lua_table.PhysicsFunctions:Move(lua_table.evade_velocity * rec_direction.x * dt, lua_table.evade_velocity * rec_direction.z * dt, jaskier_GO_UID)	--IMPROVE: Speed set on every frame bad?

							elseif lua_table.current_state <= state.heavy_3 and lua_table.current_state >= state.light_1
							then
								if enemy_hit_curr_stage == enemy_hit_stages.attack_performed
								then
									lua_table.AudioFunctions:PlayAudioEventGO(audio_library.attack_miss, jaskier_GO_UID)
									--current_audio = audio_library.attack_miss

									enemy_hit_curr_stage = enemy_hit_stages.attack_miss

								elseif enemy_hit_curr_stage == enemy_hit_stages.attack_hit and game_time - enemy_hit_started_at > enemy_hit_duration
								then
									lua_table.AnimationFunctions:SetAnimationPause(false, jaskier_GO_UID)
									lua_table.AnimationFunctions:SetAnimationPause(false, particles_library.slash_GO_UID)

									if current_paused_audio ~= audio_library.none then
										lua_table.AudioFunctions:ResumeAudioEventGO(current_paused_audio, jaskier_GO_UID)
										current_paused_audio = audio_library.none
									end

									lua_table.AudioFunctions:PlayAudioEventGO(audio_library.attack_hit, jaskier_GO_UID)
									--current_audio = audio_library.attack_hit

									if lua_table.current_state == state.light_3 or lua_table.current_state == state.medium_3 or lua_table.current_state == state.heavy_3 then
										lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.medium.intensity, controller_shake.medium.duration)
									else
										lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.small.intensity, controller_shake.small.duration)
									end

									enemy_hit_curr_stage = enemy_hit_stages.attack_finished
								end

								if lua_table.current_state == state.light_1 or lua_table.current_state == state.light_2 or lua_table.current_state == state.light_3	--IF Light Attacking
								then
									if enemy_hit_curr_stage ~= enemy_hit_stages.attack_hit
									then
										if DirectionInBounds(true) and not input_slow_active then
											if lua_table.current_state == state.light_3 then
												if time_since_action > lua_table.light_3_movement_2_start and time_since_action < lua_table.light_3_movement_2_end
												then
													lua_table.PhysicsFunctions:Move(lua_table.light_3_movement_2_velocity * rec_direction.x * dt, lua_table.light_3_movement_2_velocity * rec_direction.z * dt, jaskier_GO_UID)

												elseif time_since_action > lua_table.light_3_movement_1_start and time_since_action < lua_table.light_3_movement_1_end
												then
													lua_table.PhysicsFunctions:Move(lua_table.light_3_movement_1_velocity * rec_direction.x * dt, lua_table.light_3_movement_1_velocity * rec_direction.z * dt, jaskier_GO_UID)
												end
											end
										end

										--Collider Evaluation
										if lua_table.current_state == state.light_1 then AttackColliderCheck("light_1", "front", 2)
										elseif lua_table.current_state == state.light_2 then AttackColliderCheck("light_2", "front", 2)
										elseif lua_table.current_state == state.light_3 then AttackColliderCheck("light_3", "front", 1) end
									
										--Slow Animation End
										if time_since_action > attack_slow_start and not input_slow_active then 
											lua_table.AnimationFunctions:SetCurrentAnimationSpeed(lua_table.animation_slow_speed, jaskier_GO_UID)
											lua_table.AnimationFunctions:SetCurrentAnimationSpeed(lua_table.animation_slow_speed, particles_library.slash_GO_UID)
											blending_started_at = game_time	--Manually mark animation swap
											input_slow_active = true
										end
									end

								elseif lua_table.current_state == state.medium_1 or lua_table.current_state == state.medium_2 or lua_table.current_state == state.medium_3	--IF Medium Attacking
								then
									if enemy_hit_curr_stage ~= enemy_hit_stages.attack_hit
									then
										if DirectionInBounds(true) and not input_slow_active then
											if lua_table.current_state == state.medium_1 and time_since_action > lua_table.medium_1_movement_start
											then
												lua_table.PhysicsFunctions:Move(lua_table.medium_1_movement_velocity * rec_direction.x * dt, lua_table.medium_1_movement_velocity * rec_direction.z * dt, jaskier_GO_UID)

											elseif lua_table.current_state == state.medium_2 and time_since_action > lua_table.medium_2_movement_start
											then
												lua_table.PhysicsFunctions:Move(lua_table.medium_2_movement_velocity * rec_direction.x * dt, lua_table.medium_2_movement_velocity * rec_direction.z * dt, jaskier_GO_UID)

											elseif lua_table.current_state == state.medium_3 then
												if time_since_action > lua_table.medium_3_movement_2_start and time_since_action < lua_table.medium_3_movement_2_end
												then
													lua_table.PhysicsFunctions:Move(lua_table.medium_3_movement_2_velocity * rec_direction.x * dt, lua_table.medium_3_movement_2_velocity * rec_direction.z * dt, jaskier_GO_UID)

												elseif time_since_action > lua_table.medium_3_movement_1_start and time_since_action < lua_table.medium_3_movement_1_end
												then
													lua_table.PhysicsFunctions:Move(lua_table.medium_3_movement_1_velocity * rec_direction.x * dt, lua_table.medium_3_movement_1_velocity * rec_direction.z * dt, jaskier_GO_UID)
												end
											end
										end
									
										--Collider Evaluation
										if lua_table.current_state == state.medium_1 then AttackColliderCheck("medium_1", "front", 1)
										elseif lua_table.current_state == state.medium_2 then AttackColliderCheck("medium_2", "front", 1)
										elseif lua_table.current_state == state.medium_3 then AttackColliderCheck("medium_3", "front", 1) end

										--Slow Animation End
										if time_since_action > attack_slow_start and not input_slow_active then 
											lua_table.AnimationFunctions:SetCurrentAnimationSpeed(lua_table.animation_slow_speed, jaskier_GO_UID)
											lua_table.AnimationFunctions:SetCurrentAnimationSpeed(lua_table.animation_slow_speed, particles_library.slash_GO_UID)
											blending_started_at = game_time	--Manually mark animation swap
											input_slow_active = true
										end
									end

								elseif lua_table.current_state == state.heavy_1 or lua_table.current_state == state.heavy_2 or lua_table.current_state == state.heavy_3	--IF Heavy Attacking
								then
									if enemy_hit_curr_stage ~= enemy_hit_stages.attack_hit
									then
										if DirectionInBounds(true) and not input_slow_active then
											if lua_table.current_state == state.heavy_1 and time_since_action > lua_table.heavy_1_movement_start and time_since_action < lua_table.heavy_1_movement_end
											then
												lua_table.PhysicsFunctions:Move(lua_table.heavy_1_movement_velocity * rec_direction.x * dt, lua_table.heavy_1_movement_velocity * rec_direction.z * dt, jaskier_GO_UID)

											elseif lua_table.current_state == state.heavy_2 and time_since_action > lua_table.heavy_2_movement_start
											then
												lua_table.PhysicsFunctions:Move(lua_table.heavy_2_movement_velocity * rec_direction.x * dt, lua_table.heavy_2_movement_velocity * rec_direction.z * dt, jaskier_GO_UID)
												
											elseif lua_table.current_state == state.heavy_3 then
												if time_since_action > lua_table.heavy_3_movement_2_start and time_since_action < lua_table.heavy_3_movement_2_end
												then
													lua_table.PhysicsFunctions:Move(lua_table.heavy_3_movement_2_velocity * rec_direction.x * dt, lua_table.heavy_3_movement_2_velocity * rec_direction.z * dt, jaskier_GO_UID)

												elseif time_since_action > lua_table.heavy_3_movement_1_start and time_since_action < lua_table.heavy_3_movement_1_end
												then
													lua_table.PhysicsFunctions:Move(lua_table.heavy_3_movement_1_velocity * rec_direction.x * dt, lua_table.heavy_3_movement_1_velocity * rec_direction.z * dt, jaskier_GO_UID)
												end
											end
										end
									
										--Collider Evaluation
										if lua_table.current_state == state.heavy_1 then AttackColliderCheck("heavy_1", "front", 2)
										elseif lua_table.current_state == state.heavy_2 then AttackColliderCheck("heavy_2", "front", 2)
										elseif lua_table.current_state == state.heavy_3 then AttackColliderCheck("heavy_3", "front", 2) end

										--Slow Animation End
										if time_since_action > attack_slow_start and not input_slow_active then 
											lua_table.AnimationFunctions:SetCurrentAnimationSpeed(lua_table.animation_slow_speed, jaskier_GO_UID)
											lua_table.AnimationFunctions:SetCurrentAnimationSpeed(lua_table.animation_slow_speed, particles_library.slash_GO_UID)
											blending_started_at = game_time	--Manually mark animation swap
											input_slow_active = true
										end
									end
								end

							elseif lua_table.current_state == state.song_1 and time_since_action > lua_table.song_1_effect_start
							then
								if not lua_table.song_1_effect_active then
									lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.big.intensity, controller_shake.big.duration)
									ShakeCamera(camera_shake.small.duration, camera_shake.small.intensity)
									--lua_table.ParticlesFunctions:PlayParticleEmitter(jaskier_song_1_GO_UID)	--TODO-Particles:
									lua_table.song_1_effect_active = true
								end

								--Collider Evaluation
								AttackColliderCheck("song_1", "line", 1)

								if attack_colliders.line_1.active then
									lua_table.TransformFunctions:Translate(0.0, 0.0, lua_table.song_1_collider_speed * dt, attack_colliders.line_1.GO_UID)
								end

							elseif lua_table.current_state == state.song_2 and time_since_action > lua_table.song_2_effect_start
							then
								if not lua_table.song_2_effect_active then
									lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.big.intensity, controller_shake.big.duration)
									ShakeCamera(camera_shake.small.duration, camera_shake.small.intensity)

									SaveDirection()

									--Direct and Activate Note Particles
									for i = 1, #particles_library.song_cone_mov_GO_UID_children do
										lua_table.ParticlesFunctions:SetParticlesVelocity(song_2_particles_speed.forward * rec_direction.x, 0, song_2_particles_speed.forward * rec_direction.z, particles_library.song_cone_mov_GO_UID_children[i])

										lua_table.ParticlesFunctions:SetRandomParticlesVelocity(song_2_particles_speed.lateral * rec_direction.z, song_2_particles_speed.y, song_2_particles_speed.lateral * rec_direction.x,
										-song_2_particles_speed.lateral * rec_direction.z, 0, -song_2_particles_speed.lateral * rec_direction.x,
										particles_library.song_cone_mov_GO_UID_children[i])

										lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.song_cone_mov_GO_UID_children[i])	--TODO-Particles: Activate Aard particles on hand
									end
									for i = 1, #particles_library.song_cone_fix_GO_UID_children do
										lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.song_cone_fix_GO_UID_children[i])	--TODO-Particles: Activate Aard particles on hand
									end

									Song_Cone_Effect(song_2_trapezoid)
									lua_table.song_2_effect_active = true
								end

							elseif lua_table.current_state == state.song_3
							then
								if time_since_action > lua_table.song_3_secondary_effect_start	--IF > effect_start
								then
									if not lua_table.song_3_secondary_effect_active	--IF effect unactive, activate
									then
										lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.big.intensity, controller_shake.big.duration)
										ShakeCamera(camera_shake.small.duration, camera_shake.small.intensity)

										for i = 1, #particles_library.song_circle_GO_UID_children do
											lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.song_circle_GO_UID_children[i])	--TODO-Particles:
										end

										lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.circle_2.GO_UID)	--TODO-Colliders: Check
										attack_colliders.circle_2.active = true

										lua_table.song_3_secondary_effect_active = true
									end

									if attack_colliders.circle_2.active and time_since_action > lua_table.song_3_secondary_effect_end
									then
										lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.circle_2.GO_UID)	--TODO-Colliders: Check
										attack_colliders.circle_2.active = false
									end

								elseif time_since_action > lua_table.song_3_effect_end
								then
									if lua_table.song_3_effect_active
									then
										--Setup for stage_2
										lua_table.AnimationFunctions:PlayAnimation(lua_table.song_3_secondary_animation_name, lua_table.song_3_secondary_animation_speed, jaskier_GO_UID)
										lua_table.AnimationFunctions:PlayAnimation(lua_table.song_3_secondary_animation_name, lua_table.song_3_secondary_animation_speed, particles_library.slash_GO_UID)
										current_animation = lua_table.song_3_secondary_animation_name
										blending_started_at = game_time	--Manually mark animation swap

										lua_table.AudioFunctions:PlayAudioEventGO(audio_library.song_3_secondary, jaskier_GO_UID)
										current_audio = audio_library.song_3_secondary

										lua_table.collider_damage = base_damage_real * lua_table.song_3_secondary_damage
										lua_table.collider_effect = lua_table.song_3_secondary_status_effect

										lua_table.collider_stun_duration, lua_table.collider_knockback_speed = 0, 0
										lua_table.collider_knockback_speed = lua_table.song_3_secondary_effect_value

										lua_table.TransformFunctions:RotateObject(0, 180, 0, jaskier_GO_UID)	--Do 180 to return to orig rotation

										lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.circle_1.GO_UID)	--TODO-Colliders: Check
										attack_colliders.circle_1.active = false

										lua_table.song_3_effect_active = false
									end

								else
									if not lua_table.song_3_effect_active
									then
										--lua_table.ParticlesFunctions:PlayParticleEmitter(jaskier_song_3_GO_UID)	--TODO-Particles:
										lua_table.AudioFunctions:StopAudioEventGO(audio_library.move, jaskier_GO_UID)	--TODO-AUDIO: Stop move sound
										lua_table.current_velocity = lua_table.mov_velocity_max_orig * lua_table.song_3_moonwalk_velocity_mod	--To mark speed of moonwalk

										lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.circle_1.GO_UID)	--TODO-Colliders: Check
										attack_colliders.circle_1.active = true

										lua_table.song_3_saved_direction = false

										lua_table.song_3_effect_active = true
										lua_table.song_3_secondary_effect_active = false
									end

									if mov_input.used_input.x == 0.0 and mov_input.used_input.z == 0.0
									then
										if not lua_table.song_3_saved_direction then
											SaveDirection()
											lua_table.song_3_saved_direction = true
										end

										mov_input.used_input.x, mov_input.used_input.z = -rec_direction.x, -rec_direction.z
									else
										lua_table.song_3_saved_direction = false
									end

									MoveCharacter(true, not lua_table.song_3_saved_direction)
								end

							elseif lua_table.current_state == state.ultimate
							then
								if time_since_action > lua_table.ultimate_secondary_effect_start	--STEP 3
								then
									if not lua_table.ultimate_secondary_effect_active	--IF effect unactive, activate
									then
										for i = 1, #particles_library.song_circle_GO_UID_children do
											lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.song_circle_GO_UID_children[i])	--TODO-Particles:
										end

										lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.concert.GO_UID)	--TODO-Colliders: Check
										attack_colliders.concert.active = true

										lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.big.intensity, controller_shake.big.duration)
										ShakeCamera(camera_shake.medium.duration, camera_shake.medium.intensity)

										lua_table.ultimate_secondary_effect_active = true
									end

									if attack_colliders.concert.active and time_since_action > lua_table.ultimate_secondary_effect_end
									then
										lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.concert.GO_UID)	--TODO-Colliders: Check
										attack_colliders.concert.active = false
									end

								elseif time_since_action > lua_table.ultimate_effect_end	--STEP 2
								then
									if lua_table.ultimate_effect_active
									then
										for i = 1, #particles_library.concert_GO_UID_children do
											lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.concert_GO_UID_children[i])	--TODO-Particles:
										end

										if attack_colliders.concert.active then
											lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.concert.GO_UID)	--TODO-Colliders: Check
											attack_colliders.concert.active = false
										end

										--Setup for stage_2
										lua_table.AnimationFunctions:PlayAnimation(animation_library.two_handed_slam, lua_table.ultimate_secondary_animation_speed, jaskier_GO_UID)
										lua_table.AnimationFunctions:PlayAnimation(animation_library.two_handed_slam, lua_table.ultimate_secondary_animation_speed, particles_library.slash_GO_UID)
										current_animation = animation_library.two_handed_slam
										blending_started_at = game_time	--Manually mark animation swap

										lua_table.AnimationFunctions:PlayAnimation(animation_library.evade, lua_table.evade_animation_speed, jaskier_lute_concert_GO_UID)
										lua_table.GameObjectFunctions:SetActiveGameObject(false, jaskier_lute_concert_mesh_GO_UID)
										lua_table.GameObjectFunctions:SetActiveGameObject(true, jaskier_lute_regular_GO_UID)

										lua_table.collider_damage = base_damage_real * lua_table.ultimate_secondary_damage
										lua_table.collider_effect = lua_table.ultimate_secondary_status_effect

										lua_table.collider_stun_duration, lua_table.collider_knockback_speed = 0, 0
										lua_table.collider_knockback_speed = lua_table.ultimate_secondary_effect_value

										lua_table.ultimate_effect_active = false
									end

								else	--STEP 1
									if not lua_table.ultimate_effect_active then lua_table.ultimate_effect_active = true end	--IF effect unactive, activate
									
									local time_since_last_damage = game_time - interval_started_at
									if not attack_colliders.concert.active and time_since_last_damage > lua_table.ultimate_damage_interval
									then
										lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.concert.GO_UID)	--TODO-Colliders: Check
										attack_colliders.concert.active = true

										for i = 1, #particles_library.concert_GO_UID_children do
											lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.concert_GO_UID_children[i])	--TODO-Particles:
										end

										lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.medium.intensity, controller_shake.medium.duration)
										ShakeCamera(camera_shake.small.duration, camera_shake.small.intensity)
										
										interval_started_at = game_time

									elseif attack_colliders.concert.active and time_since_last_damage > lua_table.ultimate_damage_interval / 2
									then
										lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.concert.GO_UID)	--TODO-Colliders: Check
										attack_colliders.concert.active = false
									end
								end
							end
						end
					end
				else	--IF not acting on free will (action provoqued by something)	
					--IF action ended
					if time_since_action > lua_table.blend_time_duration	--IF action time > blend time (for blending between actions)
					and game_time - blending_started_at > lua_table.blend_time_duration	--IF blend manual marking > blend time (to manually mark and control animation swaps, optional use)
					and (time_since_action > current_action_duration or lua_table.AnimationFunctions:CurrentAnimationEnded(jaskier_GO_UID) == 1)	--IF action time up or animation finished
					then
						local chained_action = false

						if lua_table.current_state == state.knocked	--IF knocked
						then
							if lua_table.standing_up_bool	--IF was standing up
							then
								lua_table.standing_up_bool = false
							else
								lua_table.AnimationFunctions:PlayAnimation(animation_library.stand_up, lua_table.stand_up_animation_speed, jaskier_GO_UID)
								current_animation = animation_library.stand_up
								blending_started_at = game_time	--Manually mark animation swap

								lua_table.AudioFunctions:PlayAudioEventGO(audio_library.stand_up, jaskier_GO_UID)	--TODO-AUDIO:
								current_audio = audio_library.stand_up

								action_started_at = game_time
								current_action_duration = lua_table.stand_up_duration

								chained_action = true
								lua_table.standing_up_bool = true
							end

						elseif lua_table.current_state == state.stunned	then --IF stunned
							for i = 1, #particles_library.stun_particles_GO_UID_children do
								lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.stun_particles_GO_UID_children[i])	--TODO-Particles:
							end
						end

						if not chained_action then	--IF action not performed automatically after ending previous one, return to idle/move
							GoDefaultState(true)	--Change BlendDuration
						end

					else	--IF action ongoing
						if lua_table.current_state == state.knocked and not lua_table.standing_up_bool and DirectionInBounds(false)	--IF currently knocked
						then
							knockback_curr_velocity = knockback_curr_velocity + lua_table.knockback_acceleration * dt
							lua_table.PhysicsFunctions:Move(knockback_curr_velocity * rec_direction.x * dt, knockback_curr_velocity * rec_direction.z * dt, jaskier_GO_UID)
						end
					end
				end

			elseif lua_table.current_state == state.down	--IF currently down
			then
				if lua_table.falling_down_bool
				then
					if game_time - blending_started_at > lua_table.blend_time_duration and lua_table.AnimationFunctions:CurrentAnimationEnded(jaskier_GO_UID) == 1
					then
						for i = 1, #particles_library.down_particles_GO_UID_children do
							lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.down_particles_GO_UID_children[i])	--TODO-Particles:
						end

						lua_table.falling_down_bool = false
					else
						lua_table.death_started_at = game_time
					end
					
				elseif not lua_table.standing_up_bool
				then
					if lua_table.being_revived		--IF flag marks that other player is reviving (controlled by another player)
					then
						if not stopped_death		--IF stop mark hasn't been done yet
						then
							death_stopped_at = game_time			--Mark revival start (for death timer)
							lua_table.revive_started_at = game_time	--Mark revival start (for revival timer)
							pulsation_started_at = game_time		--Mark revival pulsation start

							for i = 1, #particles_library.revive_particles_GO_UID_children do
								lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.revive_particles_GO_UID_children[i])	--TODO-Particles:
							end
							for i = 1, #particles_library.down_particles_GO_UID_children do
								lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.down_particles_GO_UID_children[i])	--TODO-Particles:
							end

							lua_table.AudioFunctions:PlayAudioEventGO(audio_library.revive, jaskier_GO_UID)	--TODO-AUDIO:
							current_audio = audio_library.revive

							stopped_death = true	--Flag death timer stop
						else
							if game_time - pulsation_started_at > pulsation_interval_duration then
								lua_table.InputFunctions:ShakeController(lua_table.player_ID, controller_shake.small.intensity, controller_shake.small.duration)
								pulsation_started_at = game_time
							end

							if game_time - lua_table.revive_started_at > lua_table.revive_time		--IF revival complete
							then
								lua_table.PhysicsFunctions:SetActiveController(true, jaskier_GO_UID)

								lua_table.AnimationFunctions:PlayAnimation(animation_library.stand_up, lua_table.stand_up_animation_speed, jaskier_GO_UID)	--TODO-Animations: Stand up
								current_animation = animation_library.stand_up
								blending_started_at = game_time	--Manually mark animation swap
								
								for i = 1, #particles_library.revive_particles_GO_UID_children do
									lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.revive_particles_GO_UID_children[i])	--TODO-Particles:
								end

								lua_table.AudioFunctions:PlayAudioEventGO(audio_library.stand_up, jaskier_GO_UID)
								current_audio = audio_library.stand_up

								lua_table.standing_up_bool = true
								stopped_death = false
								lua_table.current_health = lua_table.max_health_real / 2	--Get half health
							end
						end
					else								--IF other player isn't reviving
						if stopped_death				--IF death timer was stopped
						then
							lua_table.death_started_at = lua_table.death_started_at + game_time - death_stopped_at	--Resume timer

							for i = 1, #particles_library.revive_particles_GO_UID_children do
								lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.revive_particles_GO_UID_children[i])	--TODO-Particles:
							end
							for i = 1, #particles_library.down_particles_GO_UID_children do
								lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.down_particles_GO_UID_children[i])	--TODO-Particles:
							end

							lua_table.AudioFunctions:StopAudioEventGO(audio_library.revive, jaskier_GO_UID)	--TODO-AUDIO:
							current_audio = audio_library.revive

							stopped_death = false				--Flag timer resuming

						elseif game_time - lua_table.death_started_at > lua_table.down_time	--IF death timer finished
						then
							for i = 1, #particles_library.down_particles_GO_UID_children do
								lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.down_particles_GO_UID_children[i])	--TODO-Particles:
							end
							for i = 1, #particles_library.death_particles_GO_UID_children do
								lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.death_particles_GO_UID_children[i])	--TODO-Particles:
							end

							lua_table.previous_state = lua_table.current_state
							lua_table.current_state = state.dead

							--lua_table.GameObjectFunctions:SetActiveGameObject(false, jaskier_GO_UID)
							lua_table.GameObjectFunctions:SetActiveGameObject(false, jaskier_mesh_GO_UID)
							lua_table.GameObjectFunctions:SetActiveGameObject(false, jaskier_pivot_GO_UID)

							-- if geralt_GO_UID ~= nil
							-- and geralt_GO_UID ~= 0
							-- and lua_table.GameObjectFunctions:GetScript(geralt_GO_UID).current_state <= state.down
							-- and lua_table.level_scene ~= 0
							-- then
							-- 	lua_table.SceneFunctions:LoadScene(lua_table.level_scene)
							-- end
						end
					end
				elseif game_time - blending_started_at > lua_table.blend_time_duration and lua_table.AnimationFunctions:CurrentAnimationEnded(jaskier_GO_UID) == 1
				then
					if lua_table.resurrecting then
						lua_table.resurrecting = false
					else
						for i = 1, #particles_library.revive_particles_GO_UID_children do
							lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.revive_particles_GO_UID_children[i])	--TODO-Particles:
						end
						lua_table.being_revived = false
					end

					if geralt_score ~= nil then geralt_score[8] = geralt_score[8] + 1 end	--TODO-Score:

					lua_table.standing_up_bool = false
					GoDefaultState(true)
				end
			end
		end
	else
		game_paused = true
	end

	--DEBUG LOGS
	--lua_table.SystemFunctions:LOG("Delta Time: " .. dt)
	--lua_table.SystemFunctions:LOG("State: " .. lua_table.current_state)
	--lua_table.SystemFunctions:LOG("Time passed: " .. time_since_action)
	--rot_y = math.rad(GimbalLockWorkaroundY(jaskier_GO_UID))	--TODO: Remove GimbalLock stage when Euler bug is fixed
	--lua_table.SystemFunctions:LOG("Angle Y: " .. rot_y)
	--lua_table.SystemFunctions:LOG("Ultimate: " .. lua_table.current_ultimate)
	--lua_table.SystemFunctions:LOG("Chain num: " .. lua_table.chained_attacks_num)
	--lua_table.SystemFunctions:LOG("Note num: " .. lua_table.note_num)
	--lua_table.SystemFunctions:LOG("Song string: " .. lua_table.note_stack[1] .. ", " .. lua_table.note_stack[2] .. ", " .. lua_table.note_stack[3] .. ", " .. lua_table.note_stack[4])

	--if not lua_table.ability_performed then lua_table.SystemFunctions:LOG("SONG AVAILABLE-----------------------") end
	--if lua_table.being_revived then lua_table.SystemFunctions:LOG("REVIVE TIME: " .. (game_time - lua_table.revive_started_at)) end

	--Animation
	--if lua_table.AnimationFunctions:CurrentAnimationEnded(jaskier_GO_UID) == 1 then lua_table.SystemFunctions:LOG("ANIMATION ENDED. ------------") end
	--if lua_table.AnimationFunctions:CurrentAnimationEnded(jaskier_GO_UID) == 0 then lua_table.SystemFunctions:LOG("ANIMATION ONGOING. ------------") end

	--Audio Tracking
	--lua_table.SystemFunctions:LOG(current_audio)

	--Revive
	-- if lua_table.being_revived then lua_table.SystemFunctions:LOG("Jaskier Being Revived!")
	-- else lua_table.SystemFunctions:LOG("Jaskier not being revived.") end
	--if lua_table.current_state == state.down then lua_table.SystemFunctions:LOG((game_time - lua_table.death_started_at)) end

	-- Enemies Nearby
	--if lua_table.enemies_nearby then lua_table.SystemFunctions:LOG("Jaskier enemies Nearby!")
	--else lua_table.SystemFunctions:LOG("Jaskier enemies not nearby.") end
	
	--Stats LOGS
	--lua_table.SystemFunctions:LOG("Jaskier Health: " .. lua_table.current_health)
	--lua_table.SystemFunctions:LOG("Energy: " .. lua_table.current_energy)

	--Item LOGS
	--lua_table.SystemFunctions:LOG("Jaskier Item: " .. lua_table.item_selected)
	--lua_table.SystemFunctions:LOG("Jaskier Potions Left: " .. lua_table.inventory[1])

	--lua_table.SystemFunctions:LOG("Health Reg: " .. health_reg_real)
	--lua_table.SystemFunctions:LOG("Energy Reg: " .. energy_reg_real)
	--lua_table.SystemFunctions:LOG("Damage: " .. base_damage_real)

	--lua_table.SystemFunctions:LOG("Health Reg Mod: " .. lua_table.health_reg_mod)
	--lua_table.SystemFunctions:LOG("Energy Reg Mod: " .. lua_table.energy_reg_mod)
	--lua_table.SystemFunctions:LOG("Damage Mod: " .. lua_table.base_damage_mod)

	--GameObject Find BEGIN
	-- local target = lua_table.GameObjectFunctions:FindGameObject("gerardo2")
	-- lua_table.SystemFunctions:LOG("UID: " .. target)
	-- target_x, target_y, target_z = lua_table.GameObjectFunctions:GetGameObjectPos(target)

	-- target_x = lua_table.GameObjectFunctions:GetGameObjectPosX(target)
	-- target_y = lua_table.GameObjectFunctions:GetGameObjectPosY(target)
	-- target_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(target)

	-- if target_x ~= nil and target_y ~= nil and target_z ~= nil
	-- then
	-- 	lua_table.SystemFunctions:LOG("Target_x: " .. target_x .. ", Target_y: " .. target_y .. ", Target_z: " .. target_z)
	-- end
	--GameObject Find END

	--Trapezoid Static BEGIN
	-- local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)

	-- SaveDirection()
	-- local A_z, A_x = BidimensionalRotate(song_2_trapezoid.point_A.z, song_2_trapezoid.point_A.x, 0)
	-- local B_z, B_x = BidimensionalRotate(song_2_trapezoid.point_B.z, song_2_trapezoid.point_B.x, 0)
	-- local C_z, C_x = BidimensionalRotate(song_2_trapezoid.point_C.z, song_2_trapezoid.point_C.x, 0)
	-- local D_z, D_x = BidimensionalRotate(song_2_trapezoid.point_D.z, song_2_trapezoid.point_D.x, 0)

	-- --A_x, A_z = A_x + jaskier_pos[1], A_z + jaskier_pos[3]
	-- --B_x, B_z = B_x + jaskier_pos[1], B_z + jaskier_pos[3]
	-- --C_x, C_z = C_x + jaskier_pos[1], C_z + jaskier_pos[3]
	-- --D_x, D_z = D_x + jaskier_pos[1], D_z + jaskier_pos[3]

	-- local magnitude = math.sqrt(jaskier_pos[1] ^ 2 + jaskier_pos[3] ^ 2)

	-- if magnitude < song_2_trapezoid.range
	-- and BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, jaskier_pos[1], jaskier_pos[3]) < 0	--If left side of all the trapezoid vectors BC, CD, DA ( \_/ )
	-- and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, jaskier_pos[1], jaskier_pos[3]) < 0
	-- and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, jaskier_pos[1], jaskier_pos[3]) < 0
	-- then
	-- 	lua_table.SystemFunctions:LOG("Jaskier in Area!!!")
	-- end

	--lua_table.SystemFunctions:LOG("Static Trapezoid: " .. song_2_trapezoid.point_A.x .. "," .. song_2_trapezoid.point_A.z .. " / " .. song_2_trapezoid.point_B.x .. "," .. song_2_trapezoid.point_B.z .. " / " .. song_2_trapezoid.point_C.x .. "," .. song_2_trapezoid.point_C.z .. " / " .. song_2_trapezoid.point_D.x .. "," .. song_2_trapezoid.point_D.z)
	--lua_table.SystemFunctions:LOG("Real Trapezoid: " .. A_x .. "," .. A_z .. " / " .. B_x .. "," .. B_z .. " / " .. C_x .. "," .. C_z .. " / " .. D_x .. "," .. D_z)
	--Trapezoid Static END

	--Trapezoid Dynamic BEGIN
	-- local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)
	-- local enemy_list = lua_table.PhysicsFunctions:OverlapSphere(jaskier_pos[1], jaskier_pos[2], jaskier_pos[3], 10, layers.enemy)

	-- SaveDirection()
	-- local A_z, A_x = BidimensionalRotate(song_2_trapezoid.point_A.z, song_2_trapezoid.point_A.x, rot_y)
	-- local B_z, B_x = BidimensionalRotate(song_2_trapezoid.point_B.z, song_2_trapezoid.point_B.x, rot_y)
	-- local C_z, C_x = BidimensionalRotate(song_2_trapezoid.point_C.z, song_2_trapezoid.point_C.x, rot_y)
	-- local D_z, D_x = BidimensionalRotate(song_2_trapezoid.point_D.z, song_2_trapezoid.point_D.x, rot_y)

	-- A_x, A_z = A_x + jaskier_pos[1], A_z + jaskier_pos[3]
	-- B_x, B_z = B_x + jaskier_pos[1], B_z + jaskier_pos[3]
	-- C_x, C_z = C_x + jaskier_pos[1], C_z + jaskier_pos[3]
	-- D_x, D_z = D_x + jaskier_pos[1], D_z + jaskier_pos[3]

	-- for i = 1, #enemy_list do
	-- 	local enemy_pos = lua_table.TransformFunctions:GetPosition(enemy_list[i])

	-- 	if BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, enemy_pos[1], enemy_pos[3]) < 0	--If left side of all the trapezoid vectors BC, CD, DA ( \_/ )
	-- 	and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, enemy_pos[1], enemy_pos[3]) < 0
	-- 	and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, enemy_pos[1], enemy_pos[3]) < 0
	-- 	then
	-- 		lua_table.SystemFunctions:LOG("Enemy in Area!!!")
	-- 	end
	-- end
	--Trapezoid Dynamic END
end

return lua_table
end