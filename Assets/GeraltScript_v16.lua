function	GetTableGeraltScript_v16()
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

--Debug
local keyboard_mode = false
local godmode = false

--GO UIDs
local geralt_GO_UID
local jaskier_GO_UID

-- Revive GOs
local geralt_revive_GO_UID
local jaskier_revive_GO_UID

--Current Level GO
lua_table.level_scene = 0

	--Particles
	--Geralt_Sword (Child of "Sword"): 70/25/0
	--Geralt_Ultimate (Child of Geralt): 0/0/0
	--Geralt_Ability (Child of Left Hand): 0/0/0

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
	ability = "aard",
	ultimate = "potion_boost",
	revive = "revive"

	--Attacks use a string concatenation system (light_1/2/3)
	--Combos use a string concatenation system (combo_1/2/3)
}
local current_animation = animation_library.none

local blending_started_at = 0
lua_table.blend_time_duration = 200	--Animation is marked as ended during blend time, so we use this to ensure we don't care if animations are marked as "ended" inside blend time because for us they aren't

--Particles
local particles_library = {
	none = 0,

	--sword_particles_GO_UID = 0,
	run_dust_GO_UID = 0,
	ultimate_effect_particles_GO_UID = 0,
	ultimate_scream_particles_GO_UID = 0,
	aard_hand_particles_GO_UID = 0,

	health_potion_particles_GO_UID = 0,
	stamina_potion_particles_GO_UID = 0,
	power_potion_particles_GO_UID = 0,

	slash_GO_UID = 0,
	slash_mesh_GO_UID = 0,

	aard_cone_GO_UID = 0,
	aard_cone_mesh_GO_UID = 0,

	aard_circle_GO_UID = 0,
	aard_circle_mesh_GO_UID = 0
}
--local current_particles = particles_library.none	--IMPROVE: This could be a table with all currently working particles, but currently too much work for what is worth

--Audio
local audio_library = {
	none = "",

	death = "Play_Geralt_death",
	stand_up = "Play_Geralt_stand_up",

	knockback = "Play_Geralt_knockback",
	stun = "Play_Geralt_stun",

	walk = "Play_Geralt_walk",
	run = "Play_Geralt_run",

	evade = "Play_Geralt_roll",
	aard = "Play_Geralt_aard_2",
	ultimate = "Play_Geralt_potion",
	revive = "Play_Geralt_revive",

	--For regular attacks it's Play_Geralt_attack_1_1, _1_2, _2_1, _2_2, etc
	attack = "Play_Geralt_attack_",

	combo_1 = "Play_Geralt_attack_4",
	combo_2 = "Play_Geralt_attack_5",
	combo_3 = "Play_Geralt_attack_6"
}
local current_audio = audio_library.none

--Areas
local enemy_detection_started_at = 0
local enemy_detection_time = 1000
lua_table.enemies_nearby = false
lua_table.enemy_detection_range = 20

--State Machine
local state = {	--The order of the states is relevant to the code, CAREFUL CHANGING IT (Ex: if curr_state >= state.idle)
	dead = -4,
	down = -3,

	knocked = -2,
	stunned = -1,

	idle = 0,
	walk = 1,
	run = 2,

	evade = 3,
	ability = 4,
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

	combo_1 = 17,
	combo_2 = 18,
	combo_3 = 19,
	combo_4 = 20
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

--Damage
	--Damage Stat
	local base_damage_real
	lua_table.base_damage_mod = 1.0
	lua_table.base_damage_orig = 30

local critical_chance_real
lua_table.critical_chance_add = 0
lua_table.critical_chance_orig = 0

local critical_damage_real
lua_table.critical_damage_add = 0
lua_table.critical_damage_orig = 2.0

--Items
lua_table.item_library = {	--Used to flag a readable name with a number id, allows for item indexing based on number
	health_potion = 1,
	stamina_potion = 2,
	power_potion = 3
}
local item_library_size = 3

local item_effects = {		--Item library and required data to operate
	{ health_recovery = 4, health_regen = 0.1 },
	{ speed_increase = 0.5, energy_regen = 2 },
	{ damage_increase = 1, critical_chance_increase = 10 },
}
lua_table.inventory = {	--Character inventory (number of each item)
	3,
	2,
	1
}
lua_table.item_selected = lua_table.item_library.health_potion
lua_table.item_type_max = 3

	--Potions
	lua_table.potion_in_effect = 0
	lua_table.potion_duration = 5000	--Duration in ms
	local potion_taken_at = 0
	lua_table.potion_active = false

--Controls
local key_state = {
	key_idle = "IDLE",
	key_down = "DOWN",
	key_repeat = "REPEAT",
	key_up = "UP"
}

lua_table.player_ID = 1

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

--lua_table.key_pickup_item = "BUTTON_DPAD_UP"
lua_table.key_prev_consumable = "BUTTON_DPAD_LEFT"
lua_table.key_next_consumable = "BUTTON_DPAD_RIGHT"
--lua_table.key_drop_consumable = "BUTTON_DPAD_DOWN"

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
local camera_bounds_ratio = 0.85
local off_bounds = false
local bounds_vector = { x = 0, z = 0 }
local bounds_angle

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
lua_table.walk_animation_speed = 45.0	--30.0
lua_table.run_animation_speed = 35.0	--20.0

--Energy
lua_table.current_energy = 0
lua_table.max_energy_real = 0
lua_table.max_energy_mod = 1.0
lua_table.max_energy_orig = 100

local energy_reg_real
lua_table.energy_reg_mod = 1.0
lua_table.energy_reg_orig = 5

--Attacks
	--Layers
	local layers = {
		default = 0,
		player = 1,
		player_attack = 2,
		enemy = 3,
		enemy_attack = 4
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
		1500,	--knockback	(Uses standup_time to get up)
	}
		--Knockback
		local knockback_curr_velocity
		lua_table.knockback_orig_velocity = 10
		lua_table.knockback_acceleration = -6.0

	--Attack Colliders
	local attack_colliders = {												-- Transform / Collider Scale
		front_1 = { GO_name = "Geralt_Front_1", GO_UID = 0, active = false },	-- 0,2,3 / 4,3,3
		front_2 = { GO_name = "Geralt_Front_2", GO_UID = 0, active = false },	-- 
		front_3 = { GO_name = "Geralt_Front_3", GO_UID = 0, active = false },	-- 

		back_1 = { GO_name = "Geralt_Back", GO_UID = 0, active = false },		-- 0,2,-2 / 3,3,2
		left_1 = { GO_name = "Geralt_Left", GO_UID = 0, active = false },		-- 3,2,0.5 / 2,3,4
		right_1 = { GO_name = "Geralt_Right", GO_UID = 0, active = false },	-- -3,2,0.5 / 2,3,4

		aard_circle_1 = { GO_name = "Geralt_Aard_Collider", GO_UID = 0, active = false }
	}
	--Character Controller: 1.0/2.5/0.05/0.3/45.0

	--Attack collider activation
	--Light and Heavy Attacks: Front
	--Combo 1: Body -> Right -> Front -> Left -> Back
	--Combo 2: Left -> Right -> Front
	--Combo 3: Front -> Right
	--Combo 4: ???

	--Attack Vars
	lua_table.collider_damage = 0						--Collider/Attack Damage
	lua_table.collider_effect = attack_effects_ID.none		--Effect
	--lua_table.collider_effect_value = 0				--Effect relevant value (Velocity, venom damage, etc)
	--lua_table.collider_effect_duration = 0			--Effect duration

	--Attack Inputs
	local rightside = true		-- Last attack side, marks the animation of next attack

	local attack_inputs = {}
	attack_inputs[lua_table.key_light] = false
	attack_inputs[lua_table.key_medium] = false

	local attack_input_given = false
	local attack_input_timeframe = 70	--Milisecond timeframe for a double input (70ms allows by a small margin to have at least 2 frames of input registering on 30fps before overpasing the time limit)
	local attack_input_started_at = 0	--Start of any of the two inputs

--NOTE: The visual slow for both characters lasts ~430ms * 30/anim_speed
--Light Attack
lua_table.light_damage = 1.0					--Multiplier of Base Damage
lua_table.light_movement_velocity = 3.0
lua_table.light_1_movement_velocity = 1.5

lua_table.light_1_block_time = 300			--Input block duration	(block new attacks)
lua_table.light_1_collider_front_start = 100	--Collider activation time
lua_table.light_1_collider_front_end = 200	--Collider deactivation time
lua_table.light_1_duration = 750			--Attack end (return to idle)
lua_table.light_1_animation_speed = 50.0	--Slow time: 320ms

lua_table.light_2_block_time = 300			--Input block duration	(block new attacks)
lua_table.light_2_collider_front_start = 100	--Collider activation time
lua_table.light_2_collider_front_end = 200	--Collider deactivation time
lua_table.light_2_duration = 750			--Attack end (return to idle)
lua_table.light_2_animation_speed = 50.0	--Slow time: 320ms

lua_table.light_3_block_time = 300			--Input block duration	(block new attacks)
lua_table.light_3_collider_front_start = 100	--Collider activation time
lua_table.light_3_collider_front_end = 200	--Collider deactivation time
lua_table.light_3_duration = 850			--Attack end (return to idle)
lua_table.light_3_animation_speed = 50.0	--Slow time: 320ms

--Medium Attack
lua_table.medium_damage = 1.5					--Multiplier of Base Damage
lua_table.medium_movement_velocity = 1.0
lua_table.medium_3_movement_velocity = 3.0

lua_table.medium_1_block_time = 400			--Input block duration	(block new attacks)
lua_table.medium_1_collider_front_start = 300	--Collider activation time
lua_table.medium_1_collider_front_end = 400	--Collider deactivation time
lua_table.medium_1_duration = 1100			--Attack end (return to idle)
lua_table.medium_1_animation_speed = 60.0	--Slow time: 370ms

lua_table.medium_2_block_time = 200			--Input block duration	(block new attacks)
lua_table.medium_2_collider_front_start = 100	--Collider activation time
lua_table.medium_2_collider_front_end = 200	--Collider deactivation time
lua_table.medium_2_duration = 900			--Attack end (return to idle)
lua_table.medium_2_animation_speed = 50.0	--Slow time: 370ms

lua_table.medium_3_block_time = 600			--Input block duration	(block new attacks)
lua_table.medium_3_collider_front_start = 500	--Collider activation time
lua_table.medium_3_collider_front_end = 600	--Collider deactivation time
lua_table.medium_3_duration = 1300			--Attack end (return to idle)
lua_table.medium_3_animation_speed = 50.0	--Slow time: 370ms

--Heavy Attack
lua_table.heavy_damage = 2.0				--Multiplier of Base Damage
lua_table.heavy_movement_velocity = 3.5
lua_table.heavy_1_movement_velocity_start = 2.0

lua_table.heavy_1_movement_start_1 = 200
lua_table.heavy_1_movement_start_2 = 700
lua_table.heavy_1_block_time = 700			--Input block duration	(block new attacks)
lua_table.heavy_1_collider_front_start = 600	--Collider activation time
lua_table.heavy_1_collider_front_end = 700	--Collider deactivation time
lua_table.heavy_1_duration = 1200			--Attack end (return to idle)
lua_table.heavy_1_animation_speed = 40.0	--Slow time: 430ms

lua_table.heavy_2_block_time = 300			--Input block duration	(block new attacks)
lua_table.heavy_2_collider_front_start = 200	--Collider activation time
lua_table.heavy_2_collider_front_end = 300	--Collider deactivation time
lua_table.heavy_2_duration = 1000			--Attack end (return to idle)
lua_table.heavy_2_animation_speed = 40.0	--Slow time: 430ms

lua_table.heavy_3_block_time = 600			--Input block duration	(block new attacks)
lua_table.heavy_3_collider_front_start = 500	--Collider activation time
lua_table.heavy_3_collider_front_end = 600	--Collider deactivation time
lua_table.heavy_3_duration = 1600			--Attack end (return to idle)
lua_table.heavy_3_animation_speed = 40.0	--Slow time: 430ms

--Evade		
lua_table.evade_velocity = 18			--12
lua_table.evade_cost = 33				--33
lua_table.evade_duration = 800			--1100

lua_table.evade_animation_speed = 45.0	--30.0

--Ability
lua_table.ability_push_velocity = 160
lua_table.ability_cooldown = 5000.0

local ability_started_at = 0.0
lua_table.ability_performed = false
lua_table.ability_start = 300.0
lua_table.ability_duration = 800.0

lua_table.ability_animation_speed = 70.0

lua_table.ability_offset_x = 0.1			--Near segment width (Must be > than 0)
lua_table.ability_offset_z = 0.1			--Near segment forward distance
lua_table.ability_range = 15				--Trapezoid height
lua_table.ability_angle = math.rad(30.0)	--Trapezoid opening angle

local ability_trapezoid = {
	point_A = { x = 0, z = 0 },	--Far left
	point_B = { x = 0, z = 0 },	--Far right
	point_C = { x = 0, z = 0 },	--Near right
	point_D = { x = 0, z = 0 }	--Near left
}

--Ultimate
lua_table.current_ultimate = 0.0
lua_table.max_ultimate = 100.0

local ultimate_reg_real
lua_table.ultimate_reg_mod = 1.0
lua_table.ultimate_reg_orig = 10	--Ideally, 2 or something similar

local ultimate_started_at = 0.0
lua_table.ultimate_duration = 3600
lua_table.ultimate_scream_start = 2500
lua_table.ultimate_animation_speed = 45.0

local ultimate_effect_started_at = 0.0
lua_table.ultimate_effect_duration = 10000

lua_table.ultimate_health_reg_increase = 0.2
lua_table.ultimate_energy_reg_increase = 1.0	--These numbers + to their correspondant "_mod" values and stats are calculated again
lua_table.ultimate_damage_mod_increase = 1.0

lua_table.ultimate_active = false

--Stand Up	(Standing up from knockbacks or being downed)
lua_table.standing_up_bool = false
lua_table.stand_up_animation_speed = 150.0

--Revive/Death
local revive_target				-- Target character script
lua_table.revive_range = 2		-- Revive distance
lua_table.revive_time = 3000	-- Time to revive
lua_table.down_time = 10000		-- Time until death (restarted by revival attempt)
lua_table.revive_animation_speed = 25.0

lua_table.being_revived = false	-- Revival flag (managed by rescuer character)

local stopped_death = false		-- Death timer stop flag
lua_table.death_started_at = 0		-- Death timer start
local death_stopped_at = 0		-- Death timer stop
lua_table.revive_started_at = 0		-- Revive timer start

--Actions
local time_since_action = 0			-- Time passed since action performed
local current_action_block_time = 0	-- Duration of input block from current action/event (accept new action inputs)
local current_action_duration = 0	-- Duration of current action/event (return to idle)	WARNING: Only relevant to actions with animation loops
local action_started_at = 0			-- Marks start of actions (and getting revived)

--Combos
lua_table.combo_num = 0							-- Starting at 0, increases by 1 for each attack well timed, starting at 4, each new attack will be checked for a succesful combo. Bad timing or performing a combo resets to 0
lua_table.combo_stack = { 'N', 'N', 'N', 'N' }	-- Last 4 attacks performed (0=none, 1=light, 2=heavy). Use push_back tactic.

lua_table.combo_1 = { 'L', 'L', 'L', 'L' }--{ 'L', 'L', 'H', 'M' }	--Slide Attack
lua_table.combo_1_size = 4
lua_table.combo_1_damage = 2.0	--slide + 4 hits
lua_table.combo_1_duration = 1500
lua_table.combo_1_animation_speed = 35.0
lua_table.combo_1_movement_velocity = 6.5

lua_table.combo_1_collider_right_start = 900	--Collider activation time
lua_table.combo_1_collider_right_end = 1000		--Collider deactivation time
lua_table.combo_1_collider_front_start = 1000	--Collider activation time
lua_table.combo_1_collider_front_end = 1080		--Collider deactivation time
lua_table.combo_1_collider_left_start = 1080	--Collider activation time
lua_table.combo_1_collider_left_end = 1150		--Collider deactivation time
lua_table.combo_1_collider_back_start = 1150	--Collider activation time
lua_table.combo_1_collider_back_end = 1220		--Collider deactivation time

lua_table.combo_2 = { 'M', 'M', 'M', 'M' }--{ 'M', 'H', 'M', 'L' }	--High Spin
lua_table.combo_2_size = 4
lua_table.combo_2_damage = 3.5	--3 hit
lua_table.combo_2_duration = 1400
lua_table.combo_2_animation_speed = 30.0
lua_table.combo_2_movement_velocity = 5.0

lua_table.combo_2_collider_left_start = 500		--Collider activation time
lua_table.combo_2_collider_left_end = 600		--Collider deactivation time
lua_table.combo_2_collider_right_start = 800	--Collider activation time
lua_table.combo_2_collider_right_end = 900		--Collider deactivation time
lua_table.combo_2_collider_front_start = 1200	--Collider activation time
lua_table.combo_2_collider_front_end = 1400		--Collider deactivation time

lua_table.combo_3 = { 'H', 'H', 'H', 'H' }--{ 'H', 'M', 'L', 'H' }	--Jump Attack
lua_table.combo_3_size = 4
lua_table.combo_3_damage = 4.0	--1 hit		--IMPROVE: + stun
lua_table.combo_3_duration = 1800
lua_table.combo_3_animation_speed = 30.0
lua_table.combo_3_movement_velocity = 5.0

lua_table.combo_3_collider_front_start = 1100	--Collider activation time
lua_table.combo_3_collider_front_end = 1200		--Collider deactivation time
lua_table.combo_3_collider_right_start = 1200	--Collider activation time
lua_table.combo_3_collider_right_end = 1300		--Collider deactivation time

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

local function GimbalLockWorkaroundY(param_rot_y)	--TODO: Remove when bug is fixed
	if math.abs(lua_table.TransformFunctions:GetRotation(geralt_GO_UID)[1]) == 180.0
	then
		if param_rot_y >= 0 then param_rot_y = 180 - param_rot_y
		elseif param_rot_y < 0 then param_rot_y = -180 - param_rot_y
		end
	end

	return param_rot_y
end

--Geometry END	----------------------------------------------------------------------------

--States BEGIN	----------------------------------------------------------------------------

local function GoDefaultState(change_blend_time)
	if change_blend_time == nil then change_blend_time = true end

	lua_table.previous_state = lua_table.current_state

	if mov_input.used_input.x ~= 0.0 or mov_input.used_input.z ~= 0.0
	then
		if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)
		then
			lua_table.AnimationFunctions:PlayAnimation(animation_library.run, lua_table.run_animation_speed, geralt_GO_UID)
			current_animation = animation_library.run

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.run, geralt_GO_UID)	--TODO-AUDIO: Play run sound
			current_audio = audio_library.run

			lua_table.current_velocity = run_velocity
			lua_table.current_state = state.run

			lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_dust_GO_UID)	--TODO-Particles: Activate movement dust particles
		else
			lua_table.AnimationFunctions:PlayAnimation(animation_library.walk, lua_table.walk_animation_speed, geralt_GO_UID)
			current_animation = animation_library.walk

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.walk, geralt_GO_UID)	--TODO-AUDIO: Play walk sound
			current_audio = audio_library.walk

			lua_table.current_velocity = walk_velocity
			lua_table.current_state = state.walk
		end
	else
		if change_blend_time then
			lua_table.AnimationFunctions:SetBlendTime(0.5, geralt_GO_UID)
		end

		lua_table.AnimationFunctions:SetBlendTime(0.1, particles_library.slash_GO_UID)
		lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, geralt_GO_UID)
		current_animation = animation_library.idle
		
		lua_table.current_state = state.idle
	end

	lua_table.combo_num = 0
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
	critical_chance_real = lua_table.critical_chance_orig + lua_table.critical_chance_add
	critical_damage_real = lua_table.critical_damage_orig + lua_table.critical_damage_add

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

local function DebugInputs()
	if lua_table.InputFunctions:KeyRepeat("Left Ctrl") then
		if lua_table.InputFunctions:KeyDown("1")	--God mode
		then
			godmode = not godmode

		elseif lua_table.InputFunctions:KeyDown("2")	--No ability cooldowns
		then
			if lua_table.ability_cooldown > 0.0 then lua_table.ability_cooldown = 0.0
			else lua_table.ability_cooldown = 5000.0 end

		elseif lua_table.InputFunctions:KeyDown("3")	--Insta ultimate
		then
			lua_table.current_ultimate = lua_table.max_ultimate

		elseif lua_table.InputFunctions:KeyDown("4")	--Instakill/Revive/Respawn Geralt
		then
			if lua_table.current_health > 0 then lua_table.current_health = 0
			elseif lua_table.current_state == state.down then lua_table.being_revived = true 
			elseif lua_table.current_state == state.dead
			then
				lua_table.GameObjectFunctions:SetActiveGameObject(true, lua_table.GameObjectFunctions:FindGameObject("Geralt_Mesh"))
				lua_table.GameObjectFunctions:SetActiveGameObject(true, lua_table.GameObjectFunctions:FindGameObject("Geralt_Pivot"))
				lua_table:Start()

				if jaskier_GO_UID ~= nil and jaskier_GO_UID ~= 0
				then
					local jaskier_pos = lua_table.TransformFunctions:GetPosition(jaskier_GO_UID)
					lua_table.PhysicsFunctions:SetCharacterPosition(jaskier_pos[1], jaskier_pos[2] + 5.0, jaskier_pos[3], geralt_GO_UID)
				end
			end

		elseif lua_table.InputFunctions:KeyDown("6")	--Keyboard Mode
		then
			keyboard_mode = not keyboard_mode
		end
	end
end

local function KeyboardInputs()	--Process Keyboard-to-Controller Inputs
	mov_input.used_input.x, mov_input.used_input.z = 0.0, 0.0
	
	if lua_table.InputFunctions:KeyRepeat("D")
	then
		mov_input.used_input.x = 1.0
	elseif lua_table.InputFunctions:KeyRepeat("A")
	then
		mov_input.used_input.x = -1.0
	end

	if lua_table.InputFunctions:KeyRepeat("S")
	then
		mov_input.used_input.z = 1.0
	elseif lua_table.InputFunctions:KeyRepeat("W")
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
		if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_light, key_state.key_down) or keyboard_mode and lua_table.InputFunctions:KeyDown("V")
		then
			attack_inputs[lua_table.key_light] = true
			if not attack_input_given then
				attack_input_started_at = game_time
				attack_input_given = true
			end
		end
	end
	if not attack_inputs[lua_table.key_medium] then
		if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_medium, key_state.key_down) or keyboard_mode and lua_table.InputFunctions:KeyDown("B")
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
		--else
			--lua_table.SystemFunctions:LOG("Collider Active: " .. attack_type .. "_" .. collider_id)
		end
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
	if attack_colliders.front_3.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.front_3.GO_UID)	--TODO-Colliders: Check
		attack_colliders.front_3.active = false
	end

	if attack_colliders.back_1.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.back_1.GO_UID)	--TODO-Colliders: Check
		attack_colliders.back_1.active = false
	end
	if attack_colliders.left_1.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.left_1.GO_UID)	--TODO-Colliders: Check
		attack_colliders.left_1.active = false
	end
	if attack_colliders.right_1.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.right_1.GO_UID)	--TODO-Colliders: Check
		attack_colliders.right_1.active = false
	end

	if attack_colliders.aard_circle_1.active then
		lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.aard_circle_1.GO_UID)	--TODO-Colliders: Check
		attack_colliders.aard_circle_1.active = false
	end
end

--Character Colliders END	----------------------------------------------------------------------------

--Character Particles BEGIN	----------------------------------------------------------------------------

local function ParticlesShutdown(full)	--Full marks wether the particle shutdown is total, or just parcial (ultimate particles appear even when stunned/knocked back)
	lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)
	lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.aard_cone_mesh_GO_UID)
	lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.aard_circle_mesh_GO_UID)

	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_dust_GO_UID)
	--lua_table.ParticlesFunctions:StopParticleEmitter(sword_particles_GO_UID)
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.aard_hand_particles_GO_UID)
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.ultimate_scream_particles_GO_UID)

	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.health_potion_particles_GO_UID)
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.stamina_potion_particles_GO_UID)
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.power_potion_particles_GO_UID)

	if full then lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.ultimate_effect_particles_GO_UID) end
end

--Character Particles END	----------------------------------------------------------------------------

--Character Audio BEGIN	----------------------------------------------------------------------------

local function AudioShutdown()
	lua_table.AudioFunctions:StopAudioEventGO(current_audio, geralt_GO_UID)
	current_audio = audio_library.none
end

--Character Audio END	----------------------------------------------------------------------------

--Character Movement BEGIN	----------------------------------------------------------------------------

local function SaveDirection()
	if mov_input.used_input.x ~= 0 or mov_input.used_input.z ~= 0	--IF input given, use as direction
	then
		local magnitude = math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)

		rec_direction.x = mov_input.used_input.x / magnitude
		rec_direction.z = mov_input.used_input.z / magnitude
	else															--IF no input, use Y angle to move FORWARD
		----------------------------------------------
		--NOTE: This a more step-by-step of the line below
		--rot_y = lua_table.TransformFunctions:GetRotationY()	--Used to move the character FORWARD, velocity applied later on Update()
		--rot_y = GimbalLockWorkaroundY(rot_y)
		--rot_y = math.rad(rot_y)
		----------------------------------------------

		rot_y = math.rad(GimbalLockWorkaroundY(lua_table.TransformFunctions:GetRotation(geralt_GO_UID)[2]))	--TODO: Remove GimbalLock stage when Euler bug is fixed

		rec_direction.x = math.sin(rot_y)
		rec_direction.z = math.cos(rot_y)
	end
end

local function DirectionInBounds()	--Every time we try to set a velocity, this is checked first to allow it
	local ret = true

	if off_bounds then
		rot_y = math.rad(GimbalLockWorkaroundY(lua_table.TransformFunctions:GetRotation(geralt_GO_UID)[2]))	--TODO: Remove GimbalLock stage when Euler bug is fixed
		
		--lua_table.SystemFunctions:LOG("Angle Between: " .. math.deg(BidimensionalAngleBetweenVectors(math.sin(rot_y), math.cos(rot_y), bounds_vector.x, bounds_vector.z)))

		--IF angle between character Front (Z) and set Bounds Vector > Bounds Angle, in other words, if direction too far away from what camera requires to stay within bounds
		if BidimensionalAngleBetweenVectors(math.sin(rot_y), math.cos(rot_y), bounds_vector.x, bounds_vector.z) > bounds_angle
		then
			ret = false	--Return: movement not approved by camera bounds
		end
	end

	return ret
end

local function CheckCameraBounds()	--Check if we're currently outside the camera's bounds
	--1. Get all necessary data
	local position = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
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
		bounds_angle = math.rad(bounds_angle)
		off_bounds = true
	else
		off_bounds = false
	end
end

local function MoveCharacter()
	local magnitude = math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)

	--Move character
	local mov_velocity = {	--Magnitude into vectorial values through input values
		x = lua_table.current_velocity * mov_input.used_input.x / magnitude,
		z = lua_table.current_velocity * mov_input.used_input.z / magnitude
	}

	local position = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)	--Rotate to velocity direction
	lua_table.TransformFunctions:LookAt(position[1] + mov_velocity.x, position[2], position[3] + mov_velocity.z, geralt_GO_UID)

	if DirectionInBounds()	--Only allow movement if camera bounds allows it
	then
		lua_table.PhysicsFunctions:Move(mov_velocity.x * dt, mov_velocity.z * dt, geralt_GO_UID)
	end		
end

local function MovementInputs()	--Process Movement Inputs
	if mov_input.used_input.x ~= 0.0 or mov_input.used_input.z ~= 0.0												--IF Movement Input
	then
		lua_table.AnimationFunctions:SetBlendTime(0.1, geralt_GO_UID)

		--Swap between idle and moving
		if lua_table.current_state == state.idle																	--IF Idle
		then
			lua_table.previous_state = lua_table.current_state

			if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF great input
			then
				lua_table.current_velocity = run_velocity
				lua_table.AnimationFunctions:PlayAnimation(animation_library.run, lua_table.run_animation_speed, geralt_GO_UID)
				current_animation = animation_library.run

				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.run, geralt_GO_UID)	--TODO-AUDIO: Play run sound
				current_audio = audio_library.run

				lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_dust_GO_UID)	--TODO-Particles: Activate movement dust particles

				lua_table.current_state = state.run
			else																					--IF small input
				lua_table.current_velocity = walk_velocity
				lua_table.AnimationFunctions:PlayAnimation(animation_library.walk, lua_table.walk_animation_speed, geralt_GO_UID)
				current_animation = animation_library.walk

				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.walk, geralt_GO_UID)	--TODO-AUDIO: Play walk sound
				current_audio = audio_library.walk

				lua_table.current_state = state.walk
			end

		--Swap between walking and running
		elseif lua_table.current_state == state.walk and lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF walking and big input
		then
			lua_table.current_velocity = run_velocity
			lua_table.AnimationFunctions:PlayAnimation(animation_library.run, lua_table.run_animation_speed, geralt_GO_UID)
			current_animation = animation_library.run

			lua_table.AudioFunctions:StopAudioEventGO(audio_library.walk, geralt_GO_UID)
			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.run, geralt_GO_UID)	--TODO-AUDIO: Play run sound
			current_audio = audio_library.run

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.run

			lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_dust_GO_UID)	--TODO-Particles: Activate movement dust particles
			
		elseif lua_table.current_state == state.run and lua_table.input_walk_threshold > math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF running and small input
		then
			lua_table.current_velocity = walk_velocity
			lua_table.AnimationFunctions:PlayAnimation(animation_library.walk, lua_table.walk_animation_speed, geralt_GO_UID)
			current_animation = animation_library.walk

			lua_table.AudioFunctions:StopAudioEventGO(audio_library.run, geralt_GO_UID)
			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.walk, geralt_GO_UID)	--TODO-AUDIO: Play walk sound
			current_audio = audio_library.walk

			lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_dust_GO_UID)	--TODO-Particles: Deactivate movement dust particles

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.walk
		end
		
		MoveCharacter()

	elseif lua_table.current_state == state.run or lua_table.current_state == state.walk
	then
		--Animation to IDLE
		lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, geralt_GO_UID)
		current_animation = animation_library.idle

		--TODO-AUDIO: Stop current sound event
		if lua_table.current_state == state.run then lua_table.AudioFunctions:StopAudioEventGO(audio_library.run, geralt_GO_UID)
		else lua_table.AudioFunctions:StopAudioEventGO(audio_library.walk, geralt_GO_UID) end
		current_audio = audio_library.none

		lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_dust_GO_UID)	--TODO-Particles: Deactivate movement dust particles
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.idle
	end
end

--Character Movement END	----------------------------------------------------------------------------

--Character Actions BEGIN	----------------------------------------------------------------------------

local function PerformCombo(combo_type)
	local string_match = false

	if lua_table.combo_num >= lua_table[combo_type .. "_size"] and CompareTables(lua_table.combo_stack, lua_table[combo_type])
	then
		current_action_block_time = lua_table[combo_type .. "_duration"]
		current_action_duration = current_action_block_time

		lua_table.AnimationFunctions:PlayAnimation(combo_type, lua_table[combo_type .. "_animation_speed"], geralt_GO_UID)
		lua_table.AnimationFunctions:PlayAnimation(combo_type, lua_table[combo_type .. "_animation_speed"], particles_library.slash_GO_UID)
		current_animation = combo_type

		--TODO-AUDIO: Play sound of combo_type
		if combo_type == "combo_1" then
			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.combo_1, geralt_GO_UID)
			current_audio = audio_library.combo_1

		elseif combo_type == "combo_2"
		then
			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.combo_2, geralt_GO_UID)
			current_audio = audio_library.combo_2

		elseif combo_type == "combo_3" then
			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.combo_3, geralt_GO_UID)
			current_audio = audio_library.combo_3
		end
		
		lua_table.collider_damage = base_damage_real * lua_table[combo_type .. "_damage"]
		lua_table.collider_effect = attack_effects_ID.none

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state[combo_type]

		string_match = true
	end

	return string_match
end

local function CheckCombos()
	local combo_achieved = false

	lua_table.combo_num = lua_table.combo_num + 1
	if lua_table.combo_num > 3 then			--IF 4+ attacks
		if PerformCombo("combo_1") or PerformCombo("combo_2") or PerformCombo("combo_3") then
			lua_table.InputFunctions:ShakeController(lua_table.player_ID, 1.0, current_action_duration)
			combo_achieved = true
			lua_table.combo_num = 0
		end
	end

	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_dust_GO_UID)				--TODO-Particles: Deactivate movement dust particles
	--lua_table.ParticlesFunctions:PlayParticleEmitter(sword_particles_GO_UID)	--TODO-Particles: Turn on particles on Sword

	return combo_achieved
end

local function RegularAttack(attack_type)
	local attack_sound_id 

	if attack_type == "light" then attack_sound_id = 1
	elseif attack_type == "medium" then attack_sound_id = 2
	else attack_sound_id = 3 end

	if lua_table.current_state == state.heavy_3 or lua_table.current_state == state.medium_3 then	--Exceptions that don't change side
		rightside = not rightside
	end

	if rightside	--IF rightside
	then
		if lua_table.combo_num > 2	--IF more than 2 succesful attacks
		then
			current_action_block_time = lua_table[attack_type .. "_3_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_3_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_3", lua_table[attack_type .. "_3_animation_speed"], geralt_GO_UID)
			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_3", lua_table[attack_type .. "_3_animation_speed"], particles_library.slash_GO_UID)
			current_animation = attack_type .. "_3"

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.attack .. attack_sound_id .. "_3", geralt_GO_UID)	--TODO-AUDIO: Play attack_3 sound
			current_audio = audio_library.attack .. attack_sound_id .. "_3"

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state[attack_type .. "_3"]
		else
			current_action_block_time = lua_table[attack_type .. "_1_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_1_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_1", lua_table[attack_type .. "_1_animation_speed"], geralt_GO_UID)
			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_1", lua_table[attack_type .. "_1_animation_speed"], particles_library.slash_GO_UID)
			current_animation = attack_type .. "_1"

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.attack .. attack_sound_id .. "_1", geralt_GO_UID)	--TODO-AUDIO: Play attack_1 sound
			current_audio = audio_library.attack .. attack_sound_id .. "_1"

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state[attack_type .. "_1"]
		end
	else			--IF leftside
		current_action_block_time = lua_table[attack_type .. "_2_block_time"]	--Set duration of input block (no new actions)
		current_action_duration = lua_table[attack_type .. "_2_duration"]		--Set duration of the current action (to return to idle/move)

		lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_2", lua_table[attack_type .. "_2_animation_speed"], geralt_GO_UID)
		lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_2", lua_table[attack_type .. "_2_animation_speed"], particles_library.slash_GO_UID)
		current_animation = attack_type .. "_2"

		lua_table.AudioFunctions:PlayAudioEventGO(audio_library.attack .. attack_sound_id .. "_2", geralt_GO_UID)	--TODO-AUDIO: Play attack_2 sound
		current_audio = audio_library.attack .. attack_sound_id .. "_2"

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state[attack_type .. "_2"]
	end
	
	lua_table.collider_damage = base_damage_real * lua_table[attack_type .. "_damage"]
	lua_table.collider_effect = attack_effects_ID.none
	rightside = not rightside
end

local function AardPush()
	--1. Collect colliders of all enemies inside a radius
	local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
	local enemy_list = lua_table.PhysicsFunctions:OverlapSphere(geralt_pos[1], geralt_pos[2], geralt_pos[3], lua_table.ability_range, layers.enemy)

	--2. Transform ability trapezoid to Geralt's current rotation
	SaveDirection()
	local A_z, A_x = BidimensionalRotate(ability_trapezoid.point_A.z, ability_trapezoid.point_A.x, rot_y)
	local B_z, B_x = BidimensionalRotate(ability_trapezoid.point_B.z, ability_trapezoid.point_B.x, rot_y)
	local C_z, C_x = BidimensionalRotate(ability_trapezoid.point_C.z, ability_trapezoid.point_C.x, rot_y)
	local D_z, D_x = BidimensionalRotate(ability_trapezoid.point_D.z, ability_trapezoid.point_D.x, rot_y)

	--3. Translate the local trapezoid positions to global coordinates
	A_x, A_z = A_x + geralt_pos[1], A_z + geralt_pos[3]
	B_x, B_z = B_x + geralt_pos[1], B_z + geralt_pos[3]
	C_x, C_z = C_x + geralt_pos[1], C_z + geralt_pos[3]
	D_x, D_z = D_x + geralt_pos[1], D_z + geralt_pos[3]

	--4. We must check that the enemy is inside the AoE
	for i = 1, #enemy_list do
		local enemy_pos = lua_table.TransformFunctions:GetPosition(enemy_list[i])

		if BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, enemy_pos[1], enemy_pos[3]) < 0	--If left side of all the trapezoid vectors BC, CD, DA ( \_/ )
		and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, enemy_pos[1], enemy_pos[3]) < 0
		and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, enemy_pos[1], enemy_pos[3]) < 0
		then
			local enemy_script = lua_table.GameObjectFunctions:GetScript(enemy_list[i])
			enemy_script:RequestedTrigger(geralt_GO_UID)	--TODO-Ability:
		end
	end
end

local function ActionInputs()	--Process Action Inputs
	local action_made = false
	local combo_achieved = false

	RegisterAttackInputs()	--Check for Attack Inputs

	if attack_input_given then	--IF attack input made
		if game_time - attack_input_started_at > attack_input_timeframe		--IF surpassed double press timeframe
		or attack_inputs[lua_table.key_light] and attack_inputs[lua_table.key_medium]				--IF both buttons have been pressed
		then
			if attack_inputs[lua_table.key_light] and attack_inputs[lua_table.key_medium]		--Both inputs (Heavy)
			then
				action_started_at = game_time		--Set timer start mark
				PushBack(lua_table.combo_stack, 'H')			--Add new input to stack

				combo_achieved = CheckCombos()

				if not combo_achieved	--If no combo was achieved with the input, do the attack normally
				then
					RegularAttack("heavy")
				end

				SaveDirection()

				local position = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)	--Rotate to direction
				lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, geralt_GO_UID)

				action_made = true

			elseif attack_inputs[lua_table.key_light]		--Light Input
			then
				action_started_at = game_time		--Set timer start mark
				PushBack(lua_table.combo_stack, 'L')			--Add new input to stack

				combo_achieved = CheckCombos()

				if not combo_achieved	--If no combo was achieved with the input, do the attack normally
				then
					RegularAttack("light")
				end

				SaveDirection()

				local position = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)	--Rotate to direction
				lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, geralt_GO_UID)

				action_made = true

			elseif attack_inputs[lua_table.key_medium]	--Medium Input
			then
				action_started_at = game_time		--Set timer start mark
				PushBack(lua_table.combo_stack, 'M')			--Add new input to stack

				combo_achieved = CheckCombos()

				if not combo_achieved	--If no combo was achieved with the input, do the attack normally
				then
					RegularAttack("medium")
				end

				SaveDirection()

				local position = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)	--Rotate to direction
				lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, geralt_GO_UID)

				action_made = true

			end

			attack_input_given, attack_inputs[lua_table.key_light], attack_inputs[lua_table.key_medium] = false, false, false
			--local time_between = game_time - attack_input_started_at
			--lua_table.SystemFunctions:LOG("Time Between inputs: " .. time_between)
		end
	else	--IF attack input not made, allow for any other kind of input
		if lua_table.current_energy >= lua_table.evade_cost and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_evade, key_state.key_down)	--Evade Input
		then
			action_started_at = game_time							--Set timer start mark
			current_action_block_time = lua_table.evade_duration
			current_action_duration = lua_table.evade_duration

			SaveDirection()

			-- Do Evade
			local position = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)	--Rotate to direction
			lua_table.TransformFunctions:LookAt(position[1] + rec_direction.x, position[2], position[3] + rec_direction.z, geralt_GO_UID)

			lua_table.AnimationFunctions:PlayAnimation(animation_library.evade, lua_table.evade_animation_speed, geralt_GO_UID)
			current_animation = animation_library.evade

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.evade, geralt_GO_UID)	--TODO-AUDIO: Ultimate Sound
			current_audio = audio_library.evade

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.evade
			
			lua_table.current_energy = lua_table.current_energy - lua_table.evade_cost

			lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.run_dust_GO_UID)	--TODO-Particles: Activate movement dust particles

			action_made = true
			
		elseif game_time - ability_started_at >= lua_table.ability_cooldown and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_ability, key_state.key_down)	--IF cooldown over and Ability Input
		then
			action_started_at = game_time								--Set timer start mark
			ability_started_at = action_started_at

			current_action_block_time = lua_table.ability_duration
			current_action_duration = lua_table.ability_duration

			lua_table.collider_damage = 0
			lua_table.collider_effect = attack_effects_ID.knockback

			lua_table.ability_performed = false	--The ability itself is done later to fit with the animation, this marks that it needs to be done

			-- Do Aard
			lua_table.AnimationFunctions:PlayAnimation(animation_library.ability, lua_table.ability_animation_speed, geralt_GO_UID)
			lua_table.AnimationFunctions:PlayAnimation(animation_library.ability, lua_table.ability_animation_speed, particles_library.aard_cone_GO_UID)
			lua_table.AnimationFunctions:PlayAnimation(animation_library.ability, lua_table.ability_animation_speed, particles_library.aard_circle_GO_UID)
			current_animation = animation_library.ability

			lua_table.AnimationFunctions:SetBlendTime(0.1, particles_library.aard_cone_GO_UID)
			lua_table.AnimationFunctions:SetBlendTime(0.1, particles_library.aard_circle_GO_UID)
			
			lua_table.GameObjectFunctions:SetActiveGameObject(true, particles_library.aard_cone_mesh_GO_UID)
			lua_table.GameObjectFunctions:SetActiveGameObject(true, particles_library.aard_circle_mesh_GO_UID)

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.aard, geralt_GO_UID)	--TODO-AUDIO: Ability Sound
			current_audio = audio_library.aard

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.ability

			action_made = true

		elseif lua_table.current_ultimate >= lua_table.max_ultimate
		and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_1, key_state.key_repeat)
		and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_2, key_state.key_repeat)	--Ultimate Input
		then
			action_started_at = game_time							--Set timer start mark
			ultimate_started_at = action_started_at

			current_action_block_time = lua_table.ultimate_duration
			current_action_duration = lua_table.ultimate_duration

			--Do Ultimate
			lua_table.AnimationFunctions:PlayAnimation(animation_library.ultimate, lua_table.ultimate_animation_speed, geralt_GO_UID)
			current_animation = animation_library.ultimate

			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.ultimate, geralt_GO_UID)	--TODO-AUDIO: Ultimate Sound
			current_audio = audio_library.ultimate

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.ultimate
			action_made = true

		-- elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_use_item, key_state.key_down)	--Object Input
		-- then
		-- 	action_started_at = game_time							--Set timer start mark

		-- 	--Do Use_Object
		-- 	lua_table.previous_state = lua_table.current_state
		-- 	lua_table.current_state = state.item
		-- 	action_made = true

		elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_revive, key_state.key_down)	--Revive Input
		then
			local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)

			if jaskier_revive_GO_UID ~= nil and jaskier_revive_GO_UID ~= 0
			then
				local jaskier_revive_pos = lua_table.TransformFunctions:GetPosition(jaskier_revive_GO_UID)

				--IF magnitude between Geralt and Jaskier revive is < revive_range
				if math.sqrt((jaskier_revive_pos[1] - geralt_pos[1]) ^ 2 + (jaskier_revive_pos[3] - geralt_pos[3]) ^ 2) < lua_table.revive_range
				then
					revive_target = lua_table.GameObjectFunctions:GetScript(jaskier_GO_UID)
	
					if revive_target.current_state == state.down and not revive_target.being_revived	--IF player downed and no one reviving
					then
						action_started_at = game_time	--Set timer start mark
						current_action_block_time = lua_table.revive_time
						current_action_duration = lua_table.revive_time

						--Do Revive
						revive_target.being_revived = true
	
						lua_table.TransformFunctions:LookAt(jaskier_revive_pos[1], geralt_pos[2], jaskier_revive_pos[3], geralt_GO_UID)
						lua_table.AnimationFunctions:PlayAnimation(animation_library.revive, lua_table.revive_animation_speed, geralt_GO_UID)
						current_animation = animation_library.revive

						lua_table.AudioFunctions:PlayAudioEventGO(audio_library.revive, geralt_GO_UID)	--TODO-AUDIO:
						current_audio = audio_library.revive
	
						lua_table.previous_state = lua_table.current_state
						lua_table.current_state = state.revive
						action_made = true
					end
				end
			else
				--LEGACY REVIVE (used when needed revive GO doesn't exist)
				local downed_list = lua_table.PhysicsFunctions:OverlapSphere(geralt_pos[1], geralt_pos[2], geralt_pos[3], 3.0, layers.player)
	
				for i = 1, #downed_list do	--Check nearby players
					if downed_list[i] ~= geralt_GO_UID	--IF player is not me
					then
						revive_target = lua_table.GameObjectFunctions:GetScript(downed_list[i])
	
						if revive_target.current_state == state.down and not revive_target.being_revived	--IF player downed and no one reviving
						then
							action_started_at = game_time	--Set timer start mark
							current_action_block_time = lua_table.revive_time
							current_action_duration = lua_table.revive_time
	
							--Do Revive
							revive_target.being_revived = true
	
							lua_table.AnimationFunctions:PlayAnimation(animation_library.revive, lua_table.revive_animation_speed, geralt_GO_UID)
							current_animation = animation_library.revive

							lua_table.AudioFunctions:PlayAudioEventGO(audio_library.revive, geralt_GO_UID)	--TODO-AUDIO: Ultimate Sound
							current_audio = audio_library.revive

							lua_table.previous_state = lua_table.current_state
							lua_table.current_state = state.revive
							action_made = true
	
							break
						end
					end
				end
			end			
		end
	end

	if action_made 	--IF action performed
	then
		lua_table.AnimationFunctions:SetBlendTime(0.1, geralt_GO_UID)
		blending_started_at = game_time
		
		AttackColliderShutdown()

		if lua_table.current_state <= state.combo_4 and lua_table.current_state >= state.light_1	--IF attack
		then
			lua_table.AnimationFunctions:SetBlendTime(0.1, particles_library.slash_GO_UID)
			lua_table.GameObjectFunctions:SetActiveGameObject(true, particles_library.slash_mesh_GO_UID)
		else
			lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)
			--lua_table.ParticlesFunctions:StopParticleEmitter(sword_particles_GO_UID)	--TODO-Particles: Deactivate Particles on Sword
		end
		
		if lua_table.previous_state == state.walk or lua_table.previous_state == state.run
		then
			if lua_table.current_state ~= state.evade then lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_dust_GO_UID) end	--TODO-Particles: Deactivate Dust Particles

			if lua_table.previous_state == state.walk then lua_table.AudioFunctions:StopAudioEventGO(audio_library.walk, geralt_GO_UID)
			elseif lua_table.previous_state == state.run then lua_table.AudioFunctions:StopAudioEventGO(audio_library.run, geralt_GO_UID)
			end
		end
	end

	return action_made
end

local function UltimateState(active)
	local ultimate_stat_mod = 1
	if not active then ultimate_stat_mod = -1 end

	lua_table.health_reg_mod = lua_table.health_reg_mod + lua_table.ultimate_health_reg_increase * ultimate_stat_mod
	lua_table.energy_reg_mod = lua_table.energy_reg_mod + lua_table.ultimate_energy_reg_increase * ultimate_stat_mod
	lua_table.base_damage_mod = lua_table.base_damage_mod + lua_table.ultimate_damage_mod_increase * ultimate_stat_mod

	if active then
		lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.ultimate_effect_particles_GO_UID)	--TODO-Particles: Activate ultimate particles
	else
		lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.ultimate_effect_particles_GO_UID)	--TODO-Particles: Deactivate ultimate particles
		lua_table.AudioFunctions:StopAudioEventGO(audio_library.ultimate, geralt_GO_UID)	--TODO-AUDIO: Ultimate Sound
		current_audio = audio_library.none
	end

	must_update_stats = true
	lua_table.ultimate_active = active
end

local function ReviveShutdown()	--IF I was reviving, not anymore
	if revive_target ~= nil
	then
		lua_table.AudioFunctions:StopAudioEventGO(audio_library.revive, geralt_GO_UID)	--TODO-AUDIO: Ultimate Sound
		current_audio = audio_library.none
		revive_target.being_revived = false
		revive_target = nil
	end
end

--Character Actions END	----------------------------------------------------------------------------

--Character Secondaries BEGIN	----------------------------------------------------------------------------

--Health Potion
local function TakeHealthPotion()
	lua_table.current_health = lua_table.current_health + lua_table.max_health_real / item_effects[lua_table.item_library.health_potion].health_recovery
	lua_table.health_reg_mod = lua_table.health_reg_mod + item_effects[lua_table.item_library.health_potion].health_regen
	
	lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.health_potion_particles_GO_UID)

	if lua_table.current_health > lua_table.max_health_real then lua_table.current_health = lua_table.max_health_real end	--IF above max, set to max
end

local function EndHealthPotion()
	lua_table.health_reg_mod = lua_table.health_reg_mod - item_effects[lua_table.item_library.health_potion].health_regen

	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.health_potion_particles_GO_UID)
end

--Stamina Potion
local function TakeStaminaPotion()
	lua_table.mov_velocity_max_mod = lua_table.mov_velocity_max_mod + item_effects[lua_table.item_library.stamina_potion].speed_increase
	lua_table.energy_reg_mod = lua_table.energy_reg_mod + item_effects[lua_table.item_library.stamina_potion].energy_regen

	lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.stamina_potion_particles_GO_UID)
end

local function EndStaminaPotion()
	lua_table.mov_velocity_max_mod = lua_table.mov_velocity_max_mod - item_effects[lua_table.item_library.stamina_potion].speed_increase
	lua_table.energy_reg_mod = lua_table.energy_reg_mod - item_effects[lua_table.item_library.stamina_potion].energy_regen

	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.stamina_potion_particles_GO_UID)
end

--Power Potion
local function TakePowerPotion()
	lua_table.base_damage_mod = lua_table.base_damage_mod + item_effects[lua_table.item_library.power_potion].damage_increase
	lua_table.critical_chance_add = lua_table.critical_chance_add + item_effects[lua_table.item_library.power_potion].critical_chance_increase

	lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.power_potion_particles_GO_UID)
end

local function EndPowerPotion()
	lua_table.base_damage_mod = lua_table.base_damage_mod - item_effects[lua_table.item_library.power_potion].damage_increase
	lua_table.critical_chance_add = lua_table.critical_chance_add - item_effects[lua_table.item_library.power_potion].critical_chance_increase

	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.power_potion_particles_GO_UID)
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
local function TakePotion(potion_id)
	if lua_table.inventory[potion_id] > 0 then	--IF potions of type left

		if lua_table.item_selected == lua_table.item_library.health_potion then TakeHealthPotion()
		elseif lua_table.item_selected == lua_table.item_library.stamina_potion then TakeStaminaPotion()
		elseif lua_table.item_selected == lua_table.item_library.power_potion then TakePowerPotion() end

		lua_table.potion_in_effect = potion_id	-- Save Potion number id to later use

		potion_taken_at = game_time		--Mark drink time
		lua_table.potion_active = true	--Mark potion in effect

		lua_table.inventory[potion_id] = lua_table.inventory[potion_id] - 1	--Remove potion from inventory
		must_update_stats = true	--Flag stats for update
	else
		--TODO-Audio: Play some sound to indicate not possible
	end
end

local function EndPotion()
	if lua_table.potion_in_effect == lua_table.item_library.health_potion then EndHealthPotion()
	elseif lua_table.potion_in_effect == lua_table.item_library.stamina_potion then EndStaminaPotion()
	elseif lua_table.potion_in_effect == lua_table.item_library.power_potion then EndPowerPotion() end

	lua_table.potion_active = false	--Mark potion off effect
	must_update_stats = true	--Flag stats for update
end

local function SecondaryInputs()	--Process Secondary Inputs
	if not lua_table.potion_active then
		if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_use_item, key_state.key_down)		--Take potion
		or keyboard_mode and lua_table.InputFunctions:KeyDown("R")
		then
			TakePotion(lua_table.item_selected)

			--if lua_table.inventory[lua_table.item_selected] == 0 then NextItem() end	--IF no more if that type of item, jump to next
		end
	end
	
	if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_prev_consumable, key_state.key_down)	--Previous Consumable
	or keyboard_mode and lua_table.InputFunctions:KeyDown("Q")
	then
		if not PrevItem() then	--TODO-Audio: Make not possible sound
		end
	
	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_next_consumable, key_state.key_down)	--Next Consumable
	or keyboard_mode and lua_table.InputFunctions:KeyDown("E")
	then
		if not NextItem() then	--TODO-Audio: Make not possible sound
		end
	end
end

--Character Secondaries END	----------------------------------------------------------------------------

--Collider Calls BEGIN

local function ProcessIncomingHit(collider_GO)
	local collider_parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_GO)
	local enemy_script = {}

	if collider_parent ~= 0 then	--IF collider has parent, data is saved on parent (it means the collider is repurposed for different damages)
		enemy_script = lua_table.GameObjectFunctions:GetScript(collider_parent)
	else							--IF collider has no parent, data is saved within collider
		enemy_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
	end

	lua_table.current_health = lua_table.current_health - enemy_script.collider_damage

	if enemy_script.collider_effect ~= attack_effects_ID.none and lua_table.current_state >= state.idle	--IF effect and ready to take one
	then
		lua_table.AnimationFunctions:SetBlendTime(0.1, geralt_GO_UID)

		AttackColliderShutdown()
		ParticlesShutdown(false)
		AudioShutdown()
		ReviveShutdown()

		if enemy_script.collider_effect == attack_effects_ID.stun
		then
			lua_table.AnimationFunctions:PlayAnimation(animation_library.stun, 45.0, geralt_GO_UID)
			current_animation = animation_library.stun

			if lua_table.current_health > 0
			then
				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.stun, geralt_GO_UID)	--TODO-AUDIO:
				current_audio = audio_library.stun
			end	--TODO-Audio:

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.stunned

		elseif enemy_script.collider_effect == attack_effects_ID.knockback
		then
			SaveDirection()
			knockback_curr_velocity = lua_table.knockback_orig_velocity

			lua_table.AnimationFunctions:PlayAnimation(animation_library.knockback, 60.0, geralt_GO_UID)
			current_animation = animation_library.knockback

			if lua_table.current_health > 0
			then
				lua_table.AudioFunctions:PlayAudioEventGO(audio_library.knockback, geralt_GO_UID)	--TODO-AUDIO:
				current_audio = audio_library.knockback
			end	--TODO-Audio:

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.knocked
		end

		current_action_duration = attack_effects_durations[enemy_script.collider_effect]
		action_started_at = game_time
		lua_table.InputFunctions:ShakeController(lua_table.player_ID, 1.0, current_action_duration)
	end
end

function lua_table:OnTriggerEnter()
	lua_table.SystemFunctions:LOG("On Trigger Enter")
	
	local collider_GO = lua_table.PhysicsFunctions:OnTriggerEnter(geralt_GO_UID)

	if not godmode and lua_table.current_state > state.down and lua_table.GameObjectFunctions:GetLayerByID(collider_GO) == layers.enemy_attack	--IF collider is tagged as an enemy attack
	then
		ProcessIncomingHit(collider_GO)
	end
end

function lua_table:OnCollisionEnter()
	lua_table.SystemFunctions:LOG("On Collision Enter")

	local collider_GO = lua_table.PhysicsFunctions:OnCollisionEnter(geralt_GO_UID)

	if not godmode and lua_table.current_state > state.down and lua_table.GameObjectFunctions:GetLayerByID(collider_GO) == layers.enemy_attack	--IF collider is tagged as an enemy attack
	then
		ProcessIncomingHit(collider_GO)
	end
end

--Collider Calls END

local function CalculateAbilityTrapezoid()
	ability_trapezoid.point_B.x = lua_table.ability_offset_x + math.tan(lua_table.ability_angle) * (lua_table.ability_range - lua_table.ability_offset_z)
	ability_trapezoid.point_B.z = lua_table.ability_range

	ability_trapezoid.point_A.x = -ability_trapezoid.point_B.x
	ability_trapezoid.point_A.z = lua_table.ability_range

	ability_trapezoid.point_C.x = lua_table.ability_offset_x
	ability_trapezoid.point_C.z = lua_table.ability_offset_z

	ability_trapezoid.point_D.x = -lua_table.ability_offset_x
	ability_trapezoid.point_D.z = lua_table.ability_offset_z
end

--Main Code
function lua_table:Awake()
	lua_table.SystemFunctions:LOG("GeraltScript AWAKE")

	--Get GO_UIDs
	geralt_GO_UID = lua_table.GameObjectFunctions:GetMyUID()
	jaskier_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier")

	particles_library.slash_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Slash")
	particles_library.slash_mesh_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Slash_Mesh_Geralt")

	particles_library.aard_cone_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Aard_Cone")
	particles_library.aard_cone_mesh_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Aard_Cone_Mesh")
	
	particles_library.aard_circle_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Aard_Circle")
	particles_library.aard_circle_mesh_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Aard_Circle_Mesh")

	geralt_revive_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Revive")
	jaskier_revive_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Revive")

	--Get Particle Emitters GO_UID
	--sword_particles_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Sword")
	particles_library.run_dust_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Run_Dust")
	particles_library.aard_hand_particles_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Ability")
	particles_library.ultimate_effect_particles_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Ultimate_Effect")
	particles_library.ultimate_scream_particles_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Ultimate_Scream")

	particles_library.health_potion_particles_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Health_Potion")
	particles_library.stamina_potion_particles_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Stamina_Potion")
	particles_library.power_potion_particles_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Power_Potion")

	--Stop Particle Emitters
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_dust_GO_UID)
	--lua_table.ParticlesFunctions:StopParticleEmitter(sword_particles_GO_UID)			--TODO-Particles: Uncomment when ready
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.aard_hand_particles_GO_UID)	--TODO-Particles: Uncomment when ready
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.ultimate_effect_particles_GO_UID)	--TODO-Particles: Uncomment when ready
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.ultimate_scream_particles_GO_UID)	--TODO-Particles: Uncomment when ready

	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.health_potion_particles_GO_UID)
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.stamina_potion_particles_GO_UID)
	lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.power_potion_particles_GO_UID)

	--Hide GO Particles
	lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)
	lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.aard_cone_mesh_GO_UID)
	lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.aard_circle_mesh_GO_UID)

	--Set Particle GO Animations to for smooth blending to required animations
	lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, particles_library.slash_GO_UID)
	lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, particles_library.aard_cone_GO_UID)
	lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, particles_library.aard_circle_GO_UID)

	--Get attack_colliders GO_UIDs by name
	attack_colliders.front_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.front_1.GO_name)
	attack_colliders.front_2.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.front_2.GO_name)
	attack_colliders.front_3.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.front_3.GO_name)

	attack_colliders.back_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.back_1.GO_name)
	attack_colliders.left_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.left_1.GO_name)
	attack_colliders.right_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.right_1.GO_name)

	attack_colliders.aard_circle_1.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.aard_circle_1.GO_name)

	--Camera (Warning: If there's a camera GO, but no script the Engine WILL crash)
	local camera_GO = lua_table.GameObjectFunctions:FindGameObject("Camera")
	if camera_GO ~= nil and camera_GO ~= 0 then camera_bounds_ratio = lua_table.GameObjectFunctions:GetScript(camera_GO).Layer_3_FOV_ratio_1	end

	lua_table.max_health_real = lua_table.max_health_orig	--Necessary for the first CalculateStats()
	CalculateStats()	--Calculate stats based on orig values + modifier

	CalculateAbilityTrapezoid()
end

function lua_table:Start()
	lua_table.SystemFunctions:LOG("GeraltScript START")

	-- Set initial values
	lua_table.previous_state = state.idle
	lua_table.current_state = state.idle
	lua_table.current_health = lua_table.max_health_real
	lua_table.current_energy = lua_table.max_energy_real
	lua_table.current_ultimate = 0.0

	-- Default Starting animations
	lua_table.AnimationFunctions:PlayAnimation(animation_library.idle, lua_table.idle_animation_speed, geralt_GO_UID)
	current_animation = animation_library.idle
end

function lua_table:Update()

	dt = lua_table.SystemFunctions:DT()
	game_time = PerfGameTime()

	DebugInputs()

	if game_time - enemy_detection_started_at > enemy_detection_time
	then
		local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
		local enemy_list = lua_table.PhysicsFunctions:OverlapSphere(geralt_pos[1], geralt_pos[2], geralt_pos[3], lua_table.enemy_detection_range, layers.enemy)

		if lua_table.enemies_nearby then
			if enemy_list[1] == nil then lua_table.enemies_nearby = false end
		else
			if enemy_list[1] ~= nil then lua_table.enemies_nearby = true end
		end

		enemy_detection_started_at = game_time
	end

	if must_update_stats then CalculateStats() end
	CheckCameraBounds()

	if lua_table.current_state ~= state.dead	--IF not dead (stuff done while downed too)
	then
		--Energy Regeneration
		if lua_table.current_energy < lua_table.max_energy_real then lua_table.current_energy = lua_table.current_energy + energy_reg_real * dt end	--IF can increase, increase energy
		if lua_table.current_energy > lua_table.max_energy_real then lua_table.current_energy = lua_table.max_energy_real end						--IF above max, set to max
		
		if not lua_table.ultimate_active	--IF ultimate offline
		then
			--Ultimate Regeneration
			if lua_table.current_ultimate < lua_table.max_ultimate then lua_table.current_ultimate = lua_table.current_ultimate + ultimate_reg_real * dt end	--IF can increase, increase ultimate
			if lua_table.current_ultimate > lua_table.max_ultimate then lua_table.current_ultimate = lua_table.max_ultimate end									--IF above max, set to max
		end
		
		if lua_table.ability_performed and game_time - ability_started_at >= lua_table.ability_cooldown	--IF ability cooldown finished, mark for UI
		then
			lua_table.ability_performed = false
		end

		if lua_table.potion_active and game_time - potion_taken_at > lua_table.potion_duration then EndPotion(lua_table.potion_in_effect) end
	end

	if lua_table.current_state > state.down	--IF alive
	then
		if lua_table.current_health <= 0	--IF has to die
		then
			AttackColliderShutdown()							--IF any attack colliders on, turn off
			ParticlesShutdown(true)
			AudioShutdown()
			ReviveShutdown()

			lua_table.death_started_at = game_time

			lua_table.AnimationFunctions:SetBlendTime(0.1, geralt_GO_UID)
			lua_table.AnimationFunctions:PlayAnimation(animation_library.death, 30.0, geralt_GO_UID)
			current_animation = animation_library.death
			
			lua_table.AudioFunctions:PlayAudioEventGO(audio_library.death, geralt_GO_UID)	--TODO-AUDIO:
			current_audio = audio_library.death

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.down

			lua_table.standing_up_bool = false
			if lua_table.potion_active then EndPotion(lua_table.potion_in_effect) end				--IF potion in effect, turn off
			if lua_table.ultimate_active then UltimateState(false) end	--IF ultimate on, go off
		else								--IF still lives
			--Health Regeneration
			if health_reg_real > 0	--IF health regen online
			then
				if lua_table.current_health < lua_table.max_health_real then lua_table.current_health = lua_table.current_health + health_reg_real * dt end	--IF can increase, increase health
				if lua_table.current_health > lua_table.max_health_real then lua_table.current_health = lua_table.max_health_real end						--IF above max, set to max
			end

			if lua_table.ultimate_active and game_time - ultimate_effect_started_at >= lua_table.ultimate_effect_duration	--IF ultimate online and time up!
			then
				UltimateState(false)	--Ultimate turn off (stats back to normal)
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

				--IF state == idle/move or action_input_block_time has ended (Input-allowed environment)
				if lua_table.current_state <= state.run or time_since_action > current_action_block_time
				then
					ActionInputs()
				end

				--IF there's no action being performed
				if lua_table.current_state <= state.run
				then
					MovementInputs()	--Movement orders
					SecondaryInputs()	--Minor actions with no timer or special animations

				else	--ELSE (action being performed)
					if lua_table.current_state == state.ultimate and not lua_table.ultimate_active and time_since_action > lua_table.ultimate_scream_start	--IF ultimate state, ultimate unactive, and scream started
					then
						lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.ultimate_scream_particles_GO_UID)	--TODO-Particles: Activate ultimate particles
						UltimateState(true)	--Ultimate turn on (boost stats)

						lua_table.current_ultimate = 0.0
						ultimate_effect_started_at = game_time
					end

					--IF action ended	--LEGACY: time_since_action > current_action_duration
					if time_since_action > lua_table.blend_time_duration	--IF action time > blend time (for blending between actions)
					and game_time - blending_started_at > lua_table.blend_time_duration	--IF blend manual marking > blend time (to manually mark and control animation swaps, optional use)
					and lua_table.AnimationFunctions:CurrentAnimationEnded(geralt_GO_UID) == 1	--IF animation finished (this only works for non-loop animations)
					then
						local chained_action = false

						if lua_table.current_state == state.revive
						then
							lua_table.AudioFunctions:StopAudioEventGO(audio_library.revive, geralt_GO_UID)
							current_audio = audio_library.none
							revive_target = nil
						elseif lua_table.current_state == state.evade
						then
							lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.run_dust_GO_UID)
						elseif lua_table.current_state == state.ability
						then
							lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.aard_cone_mesh_GO_UID)
							lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.aard_circle_mesh_GO_UID)

							lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.aard_circle_1.GO_UID)
							attack_colliders.aard_circle_1.active = false

							lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.aard_hand_particles_GO_UID)	--TODO-Particles: Deactivate Aard particles on hand
						elseif lua_table.current_state == state.ultimate
						then
							lua_table.ParticlesFunctions:StopParticleEmitter(particles_library.ultimate_scream_particles_GO_UID)	--TODO-Particles: Activate ultimate particles
						elseif lua_table.current_state >= state.light_1 and lua_table.current_state <= state.heavy_3	--IF attack finished
						then
							lua_table.GameObjectFunctions:SetActiveGameObject(false, particles_library.slash_mesh_GO_UID)

							if attack_input_given	--IF attack input was given before time ran out, process it instantly
							then
								attack_input_timeframe = 0
								chained_action = ActionInputs()
								attack_input_timeframe = 70
							end

							--lua_table.ParticlesFunctions:StopParticleEmitter(sword_particles_GO_UID)	--TODO-Particles: Deactivate Particles on Sword
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
					elseif lua_table.current_state == state.revive and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_revive, key_state.key_up)
					then
						ReviveShutdown()
						GoDefaultState(false)

					elseif lua_table.current_state == state.evade and DirectionInBounds()	--ELSEIF evading
					then
						lua_table.PhysicsFunctions:Move(lua_table.evade_velocity * rec_direction.x * dt, lua_table.evade_velocity * rec_direction.z * dt, geralt_GO_UID)

					elseif lua_table.current_state == state.ability and not lua_table.ability_performed and time_since_action > lua_table.ability_start
					then
						AardPush()
						SaveDirection()

						--Activate Aard Sphere Collider
						lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.aard_circle_1.GO_UID)
						attack_colliders.aard_circle_1.active = true

						--Direct Aard Particles
						--lua_table.ParticlesFunctions:SetParticlesVelocity(50 * rec_direction.x, 0, 50 * rec_direction.z, particles_library.aard_hand_particles_GO_UID)
						--lua_table.ParticlesFunctions:SetRandomParticlesVelocity(50 * rec_direction.z, 0, 50 * rec_direction.x, particles_library.aard_hand_particles_GO_UID)
						--lua_table.ParticlesFunctions:PlayParticleEmitter(particles_library.aard_hand_particles_GO_UID)	--TODO-Particles: Activate Aard particles on hand

						lua_table.ability_performed = true

					elseif lua_table.current_state == state.evade and DirectionInBounds()				--ELSEIF evading
					then
						lua_table.PhysicsFunctions:Move(lua_table.evade_velocity * rec_direction.x * dt, lua_table.evade_velocity * rec_direction.z * dt, geralt_GO_UID)	--IMPROVE: Speed set on every frame bad?

					elseif lua_table.current_state == state.light_1 or lua_table.current_state == state.light_2 or lua_table.current_state == state.light_3	--IF Light Attacking
					then
						if DirectionInBounds() and time_since_action < current_action_block_time	--IF in bounds
						then
							if lua_table.current_state == state.light_1 then
								lua_table.PhysicsFunctions:Move(lua_table.light_1_movement_velocity * rec_direction.x * dt, lua_table.light_1_movement_velocity * rec_direction.z * dt, geralt_GO_UID)
							else
								lua_table.PhysicsFunctions:Move(lua_table.light_movement_velocity * rec_direction.x * dt, lua_table.light_movement_velocity * rec_direction.z * dt, geralt_GO_UID)
							end
						end

						--Collider Evaluation
						if lua_table.current_state == state.light_1 then AttackColliderCheck("light_1", "front", 1)
						elseif lua_table.current_state == state.light_2 then AttackColliderCheck("light_2", "front", 1)
						elseif lua_table.current_state == state.light_3 then AttackColliderCheck("light_3", "front", 1)
						end

					elseif lua_table.current_state == state.medium_1 or lua_table.current_state == state.medium_2 or lua_table.current_state == state.medium_3	--IF Medium Attacking
					then
						if DirectionInBounds() and time_since_action < current_action_block_time	--IF in bounds
						then
							if lua_table.current_state == state.medium_3 then
								lua_table.PhysicsFunctions:Move(lua_table.medium_3_movement_velocity * rec_direction.x * dt, lua_table.medium_3_movement_velocity * rec_direction.z * dt, geralt_GO_UID)
							else
								lua_table.PhysicsFunctions:Move(lua_table.medium_movement_velocity * rec_direction.x * dt, lua_table.medium_movement_velocity * rec_direction.z * dt, geralt_GO_UID)
							end
						end

						--Collider Evaluation
						if lua_table.current_state == state.medium_1 then AttackColliderCheck("medium_1", "front", 2)
						elseif lua_table.current_state == state.medium_2 then AttackColliderCheck("medium_2", "front", 2)
						elseif lua_table.current_state == state.medium_3 then AttackColliderCheck("medium_3", "front", 3)
						end

					elseif lua_table.current_state == state.heavy_1 or lua_table.current_state == state.heavy_2 or lua_table.current_state == state.heavy_3	--IF Heavy Attacking
					then
						if DirectionInBounds()
						then
							if lua_table.current_state == state.heavy_1
							then
								if time_since_action > lua_table.heavy_1_movement_start_2 and time_since_action < current_action_block_time then
									lua_table.PhysicsFunctions:Move(lua_table.heavy_movement_velocity * rec_direction.x * dt, lua_table.heavy_movement_velocity * rec_direction.z * dt, geralt_GO_UID)
								elseif time_since_action > lua_table.heavy_1_movement_start_1 then
									lua_table.PhysicsFunctions:Move(lua_table.heavy_1_movement_velocity_start * rec_direction.x * dt, lua_table.heavy_1_movement_velocity_start * rec_direction.z * dt, geralt_GO_UID)
								end
								
							elseif time_since_action < current_action_block_time
							then
								lua_table.PhysicsFunctions:Move(lua_table.heavy_movement_velocity * rec_direction.x * dt, lua_table.heavy_movement_velocity * rec_direction.z * dt, geralt_GO_UID)
							end
						end

						-- DEBUG SETCURRENTANIMATION
						-- if time_since_action > 800 then lua_table.AnimationFunctions:SetCurrentAnimationSpeed(5.0, geralt_GO_UID)
						-- elseif time_since_action > 400 then lua_table.AnimationFunctions:SetCurrentAnimationSpeed(15.0, geralt_GO_UID)
						-- else lua_table.AnimationFunctions:SetCurrentAnimationSpeed(30.0, geralt_GO_UID) end

						--Collider Evaluation
						if lua_table.current_state == state.heavy_1 then AttackColliderCheck("heavy_1", "front", 2)
						elseif lua_table.current_state == state.heavy_2 then AttackColliderCheck("heavy_2", "front", 2)
						elseif lua_table.current_state == state.heavy_3 then AttackColliderCheck("heavy_3", "front", 2)
						end

					elseif lua_table.current_state == state.combo_1
					then
						if DirectionInBounds() and time_since_action < current_action_block_time then lua_table.PhysicsFunctions:Move(lua_table.combo_1_movement_velocity * rec_direction.x * dt, lua_table.combo_1_movement_velocity * rec_direction.z * dt, geralt_GO_UID) end
						
						--Collider Evaluation
						AttackColliderCheck("combo_1", "right", 1)
						AttackColliderCheck("combo_1", "front", 1)
						AttackColliderCheck("combo_1", "left", 1)
						AttackColliderCheck("combo_1", "back", 1)

					elseif lua_table.current_state == state.combo_2
					then
						if DirectionInBounds() and time_since_action < current_action_block_time then lua_table.PhysicsFunctions:Move(lua_table.combo_2_movement_velocity * rec_direction.x * dt, lua_table.combo_2_movement_velocity * rec_direction.z * dt, geralt_GO_UID) end
						
						--Collider Evaluation
						AttackColliderCheck("combo_2", "left", 1)
						AttackColliderCheck("combo_2", "right", 1)
						AttackColliderCheck("combo_2", "front", 1)

					elseif lua_table.current_state == state.combo_3
					then
						if DirectionInBounds() and time_since_action < current_action_block_time then lua_table.PhysicsFunctions:Move(lua_table.combo_3_movement_velocity * rec_direction.x * dt, lua_table.combo_3_movement_velocity * rec_direction.z * dt, geralt_GO_UID) end

						--Collider Evaluation
						AttackColliderCheck("combo_3", "front", 1)

					end
				end
			else	--IF not acting on free will (action provoqued by something)	
				--IF action ended
				if time_since_action > lua_table.blend_time_duration	--IF action time > blend time (for blending between actions)
				and game_time - blending_started_at > lua_table.blend_time_duration	--IF blend manual marking > blend time (to manually mark and control animation swaps, optional use)
				and lua_table.AnimationFunctions:CurrentAnimationEnded(geralt_GO_UID) == 1	--IF animation finished (this only works for non-loop animations)
				then
					local chained_action = false

					if lua_table.current_state == state.knocked	--IF knocked
					then
						if lua_table.standing_up_bool	--IF was standing up
						then
							lua_table.standing_up_bool = false
						else
							lua_table.AnimationFunctions:PlayAnimation(animation_library.stand_up, lua_table.stand_up_animation_speed, geralt_GO_UID)
							current_animation = animation_library.stand_up

							blending_started_at = game_time	--Manually mark animation swap

							lua_table.AudioFunctions:PlayAudioEventGO(audio_library.stand_up, geralt_GO_UID)	--TODO-AUDIO:
							current_audio = audio_library.stand_up

							chained_action = true
							lua_table.standing_up_bool = true
						end
					end

					if not chained_action then	--IF action not performed automatically after ending previous one, return to idle/move
						--Return to move or idle
						if lua_table.current_state == state.evade then
							GoDefaultState(false)	--Don't change BlendDuration
						else
							GoDefaultState(true)	--Change BlendDuration
						end
					end

				else	--IF action ongoing
					if lua_table.current_state == state.stunned and time_since_action > current_action_duration	--IF currently stunned and time passed
					then
						GoDefaultState(true)
		
					elseif lua_table.current_state == state.knocked and not lua_table.standing_up_bool	--IF currently knocked
					then
						knockback_curr_velocity = knockback_curr_velocity + lua_table.knockback_acceleration * dt
						lua_table.PhysicsFunctions:Move(knockback_curr_velocity * -rec_direction.x * dt, knockback_curr_velocity * -rec_direction.z * dt, geralt_GO_UID)
					end
				end
			end
		end
	elseif lua_table.current_state == state.down	--IF currently down
	then
		if not lua_table.standing_up_bool
		then
			if lua_table.being_revived		--IF flag marks that other player is reviving (controlled by another player)
			then
				if not stopped_death		--IF stop mark hasn't been done yet
				then
					death_stopped_at = game_time			--Mark revival start (for death timer)
					lua_table.revive_started_at = death_stopped_at	--Mark revival start (for revival timer)
					stopped_death = true					--Flag death timer stop

				elseif game_time - lua_table.revive_started_at > lua_table.revive_time		--IF revival complete
				then
					lua_table.AnimationFunctions:PlayAnimation(animation_library.stand_up, lua_table.stand_up_animation_speed, geralt_GO_UID)	--TODO-Animations: Stand up
					current_animation = animation_library.stand_up

					blending_started_at = game_time

					lua_table.AudioFunctions:PlayAudioEventGO(audio_library.stand_up, geralt_GO_UID)	--TODO-AUDIO: Stand Up Sound
					current_audio = audio_library.stand_up
					lua_table.standing_up_bool = true

					stopped_death = false
					lua_table.current_health = lua_table.max_health_real / 2	--Get half health
				end
			else								--IF other player isn't reviving
				if stopped_death				--IF death timer was stopped
				then
					lua_table.death_started_at = lua_table.death_started_at + game_time - death_stopped_at	--Resume timer
					stopped_death = false				--Flag timer resuming

				elseif game_time - lua_table.death_started_at > lua_table.down_time	--IF death timer finished
				then
					lua_table.previous_state = lua_table.current_state
					lua_table.current_state = state.dead					--Kill character
					--lua_table.GameObjectFunctions:SetActiveGameObject(false, geralt_GO_UID)	--Disable character
					lua_table.GameObjectFunctions:SetActiveGameObject(false, lua_table.GameObjectFunctions:FindGameObject("Geralt_Mesh"))
					lua_table.GameObjectFunctions:SetActiveGameObject(false, lua_table.GameObjectFunctions:FindGameObject("Geralt_Pivot"))

					if jaskier_GO_UID ~= nil
					and jaskier_GO_UID ~= 0
					and lua_table.GameObjectFunctions:GetScript(jaskier_GO_UID).current_state <= state.down
					and lua_table.level_scene ~= 0
					then
						lua_table.SceneFunctions:LoadScene(lua_table.level_scene)
					end
				end
			end
		elseif game_time - blending_started_at > lua_table.blend_time_duration and lua_table.AnimationFunctions:CurrentAnimationEnded(geralt_GO_UID) == 1
		then
			lua_table.standing_up_bool, lua_table.being_revived = false, false
			GoDefaultState(true)
		end
	end

	--DEBUG LOGS
	--lua_table.SystemFunctions:LOG("Delta Time: " .. dt)
	--lua_table.SystemFunctions:LOG("State: " .. lua_table.current_state)
	lua_table.SystemFunctions:LOG("Time passed: " .. time_since_action)
	--rot_y = math.rad(GimbalLockWorkaroundY(lua_table.TransformFunctions:GetRotation()[2]))	--TODO: Remove GimbalLock stage when Euler bug is fixed
	--lua_table.SystemFunctions:LOG("Angle Y: " .. rot_y)
	--lua_table.SystemFunctions:LOG("Ultimate: " .. lua_table.current_ultimate)
	--lua_table.SystemFunctions:LOG("Combo num: " .. lua_table.combo_num)
	--lua_table.SystemFunctions:LOG("Combo string: " .. lua_table.combo_stack[1] .. ", " .. lua_table.combo_stack[2] .. ", " .. lua_table.combo_stack[3] .. ", " .. lua_table.combo_stack[4])

	--Attack inputs
	--if attack_input_given then lua_table.SystemFunctions:LOG("ATTACK INPUT GIVEN ----------------") end
	--if attack_inputs[lua_table.key_light] then lua_table.SystemFunctions:LOG("BUTTON <Y> INPUTED ----------------") end
	--if attack_inputs[lua_table.key_medium] then lua_table.SystemFunctions:LOG("BUTTON <B> INPUTED ----------------") end

	--Animation
	--if lua_table.AnimationFunctions:CurrentAnimationEnded(geralt_GO_UID) == 1 then lua_table.SystemFunctions:LOG("ANIMATION ENDED. ------------") end
	--if lua_table.AnimationFunctions:CurrentAnimationEnded(geralt_GO_UID) == 0 then lua_table.SystemFunctions:LOG("ANIMATION ONGOING. ------------") end

	--Revive
	-- if lua_table.being_revived then lua_table.SystemFunctions:LOG("Jaskier Being Revived!")
	-- else lua_table.SystemFunctions:LOG("Jaskier not being revived.") end

	-- Enemies Nearby
	--if lua_table.enemies_nearby then lua_table.SystemFunctions:LOG("Enemies Nearby!")
	--else lua_table.SystemFunctions:LOG("Enemies not nearby.") end

	--Item LOGS
	--lua_table.SystemFunctions:LOG("Geralt Item: " .. lua_table.item_selected)
	--lua_table.SystemFunctions:LOG("Geralt Health Potions Left: " .. lua_table.inventory[1])
	--lua_table.SystemFunctions:LOG("Geralt Energy Potions Left: " .. lua_table.inventory[2])
	--lua_table.SystemFunctions:LOG("Geralt Damage Potions Left: " .. lua_table.inventory[3])

	--Stats LOGS
	--lua_table.SystemFunctions:LOG("Geralt Health: " .. lua_table.current_health)
	--lua_table.SystemFunctions:LOG("Energy: " .. lua_table.current_energy)

	--lua_table.SystemFunctions:LOG("Health Reg: " .. health_reg_real)
	--lua_table.SystemFunctions:LOG("Energy Reg: " .. energy_reg_real)
	--lua_table.SystemFunctions:LOG("Damage: " .. base_damage_real)

	--lua_table.SystemFunctions:LOG("Health Reg Mod: " .. lua_table.health_reg_mod)
	--lua_table.SystemFunctions:LOG("Energy Reg Mod: " .. lua_table.energy_reg_mod)
	--lua_table.SystemFunctions:LOG("Damage Mod: " .. lua_table.base_damage_mod)

	--lua_table.SystemFunctions:LOG("Velocity Speed: " .. lua_table.mov_velocity_max_mod)
	--lua_table.SystemFunctions:LOG("Critical Chance: " .. lua_table.critical_chance_add)

	--Trapezoid Global BEGIN
	-- local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
	-- local A_x, A_z = ability_trapezoid.point_A.x + geralt_pos[1], ability_trapezoid.point_A.z + geralt_pos[3]
	-- local B_x, B_z = ability_trapezoid.point_B.x + geralt_pos[1], ability_trapezoid.point_B.z + geralt_pos[3]
	-- local C_x, C_z = ability_trapezoid.point_C.x + geralt_pos[1], ability_trapezoid.point_C.z + geralt_pos[3]
	-- local D_x, D_z = ability_trapezoid.point_D.x + geralt_pos[1], ability_trapezoid.point_D.z + geralt_pos[3]

	-- lua_table.SystemFunctions:LOG("Ability Trapezoid: " .. ability_trapezoid.point_A.x .. "," .. ability_trapezoid.point_A.z .. " / " .. ability_trapezoid.point_B.x .. "," .. ability_trapezoid.point_B.z .. " / " .. ability_trapezoid.point_C.x .. "," .. ability_trapezoid.point_C.z .. " / " .. ability_trapezoid.point_D.x .. "," .. ability_trapezoid.point_D.z)
	-- lua_table.SystemFunctions:LOG("Real Trapezoid: " .. A_x .. "," .. A_z .. " / " .. B_x .. "," .. B_z .. " / " .. C_x .. "," .. C_z .. " / " .. D_x .. "," .. D_z)

	-- local target = lua_table.GameObjectFunctions:FindGameObject("gerardo2")
	-- local target_x = lua_table.GameObjectFunctions:GetGameObjectPosX(target)
	-- local target_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(target)

	-- if math.sqrt((target_x - geralt_pos[1]) ^ 2 + (target_z - geralt_pos[3]) ^ 2) <= lua_table.ability_range	--IF on the left side of all vectors + within the OverlapSphere = inside AoE
	-- and BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, target_x, target_z) < 0
	-- and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, target_x, target_z) < 0
	-- and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, target_x, target_z) < 0
	-- then
	-- 	lua_table.SystemFunctions:LOG("TARGET INSIDE")
	-- else
	-- 	lua_table.SystemFunctions:LOG("TARGET OUTSIDE")
	-- end
	--Trapezoid Global END

	--Trapezoid Local BEGIN
	-- local geralt_pos = lua_table.TransformFunctions:GetPosition(geralt_GO_UID)
	-- local A_x, A_z = ability_trapezoid.point_A.x, ability_trapezoid.point_A.z
	-- local B_x, B_z = ability_trapezoid.point_B.x, ability_trapezoid.point_B.z
	-- local C_x, C_z = ability_trapezoid.point_C.x, ability_trapezoid.point_C.z
	-- local D_x, D_z = ability_trapezoid.point_D.x, ability_trapezoid.point_D.z

	-- lua_table.SystemFunctions:LOG("Ability Trapezoid: " .. ability_trapezoid.point_A.x .. "," .. ability_trapezoid.point_A.z .. " / " .. ability_trapezoid.point_B.x .. "," .. ability_trapezoid.point_B.z .. " / " .. ability_trapezoid.point_C.x .. "," .. ability_trapezoid.point_C.z .. " / " .. ability_trapezoid.point_D.x .. "," .. ability_trapezoid.point_D.z)
	-- lua_table.SystemFunctions:LOG("Real Trapezoid: " .. A_x .. "," .. A_z .. " / " .. B_x .. "," .. B_z .. " / " .. C_x .. "," .. C_z .. " / " .. D_x .. "," .. D_z)

	-- if BidimensionalPointInVectorSide(A_x, A_z, B_x, B_z, geralt_pos[1], geralt_pos[3]) < 0	--IF on the left side of all vectors + within the OverlapSphere = inside AoE
	-- and BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, geralt_pos[1], geralt_pos[3]) < 0
	-- and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, geralt_pos[1], geralt_pos[3]) < 0
	-- and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, geralt_pos[1], geralt_pos[3]) < 0
	-- --if geralt_pos[1] > A_x and geralt_pos[1] < B_x and geralt_pos[3] > C_z and geralt_pos[3] < A_z
	-- then
	-- 	lua_table.SystemFunctions:LOG("TARGET INSIDE")
	-- else
	-- 	lua_table.SystemFunctions:LOG("TARGET OUTSIDE")
	-- end
	-- lua_table.SystemFunctions:LOG("G_x: " .. geralt_pos[1] .. ", G_z: " .. geralt_pos[3])
	--Trapezoid Local END

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
end

return lua_table
end