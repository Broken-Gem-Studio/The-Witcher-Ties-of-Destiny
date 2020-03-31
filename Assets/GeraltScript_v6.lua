function	GetTableGeraltScript_v6()
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

--LEGACY NAMESPACES
--lua_table.DebugFunctions = Scripting.Debug()
--lua_table.ElementFunctions = Scripting.Elements()
--lua_table.SystemFunctions = Scripting.Systems()
--lua_table.InputFunctions = Scripting.Inputs()

--State Machine
local state = {	--The order of the states is relevant to the code, CAREFUL CHANGING IT (Ex: if curr_state >= state.run)
	dead = -2,
	down = -1,

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

	heavy_1 = 11,
	heavy_2 = 12,
	heavy_3 = 13,

	combo_1 = 14,
	combo_2 = 15,
	combo_3 = 16,
}
lua_table.previous_state = state.idle	-- Previous State
lua_table.current_state = state.idle	-- Current State

--Stats
local must_update_stats = false

--Stats Info
	-- Health
	-- Damage
	-- Speed

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
	lua_table.max_health_orig = 500

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

lua_table.key_interact = "BUTTON_LEFTSHOULDER"
lua_table.key_use_item = "BUTTON_RIGHTSHOULDER"

lua_table.key_light = "BUTTON_X"
lua_table.key_heavy = "BUTTON_Y"
lua_table.key_evade = "BUTTON_A"
lua_table.key_ability = "BUTTON_B"

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
lua_table.input_walk_threshold = 0.8

--Camera Limitations (IF angle between forward character vector and plane normal > 90º (45º on corners) then all velocities = 0)
local camera_bounds_ratio = 0.85
local off_bounds = false
local bounds_vector = { x = 0, z = 0 }
local bounds_angle

--Movement
local rec_direction = { x = 0.0, z = 0.0 }	--Used to save a direction when necessary, given by joystick inputs or character rotation

local rot_y = 0.0

local mov_speed = { x = 0.0, z = 0.0 }

	--Speed Stat
	local mov_speed_stat	-- stat = real / 10. Exclusive to speed, as the numeric balancing is dependant on Physics and not only design
	local mov_speed_max_real
	lua_table.mov_speed_max_mod = 1.0
	lua_table.mov_speed_max_orig = 5000	--Was 60.0 before dt

lua_table.idle_animation_speed = 30.0
lua_table.walk_animation_speed = 30.0
lua_table.run_animation_speed = 20.0

--Energy
lua_table.current_energy = 0
lua_table.max_energy_real = 0
lua_table.max_energy_mod = 1.0
lua_table.max_energy_orig = 100

local energy_reg_real
lua_table.energy_reg_mod = 1.0
lua_table.energy_reg_orig = 10	--This is 5 per second aprox.

--Attacks
local rightside = true								-- Last attack side, marks the animation of next attack

local attack_effects = {	--Not definitive, but as showcase
	none = 0,
	stun = 1,
	knockback = 2,
	provoke = 3,
	venom = 4
}
lua_table.collider_damage = 0
lua_table.collider_effect = attack_effects.none

local active_colliders = {
	front = false,
	back = false,
	left = false,
	right = false
}

	--Collider Notes (GO X,Y,Z / Coll size X,Y,Z)
	--Front: 0,20,25 / 20,25,18
	--Back: 0,20,-20 / 20,25,10
	--Left: 20,20,5 / 10,25,20
	--Right: -20,20,5 / 10,25,20
	--Body: 0,20,0 / 20,40,20

	--Light and Heavy Attacks: Front
	--Combo 1: Body -> Right -> Front -> Left -> Back
	--Combo 2: Left -> Right -> Front
	--Combo 3: Front -> Right?
	
--Light Attack
lua_table.light_damage = 1.0					--Multiplier of Base Damage
lua_table.light_cost = 5

lua_table.light_movement_speed = 1000.0

lua_table.light_1_block_time = 500			--Input block duration	(block new attacks)
lua_table.light_1_collider_front_start = 500	--Collider activation time
lua_table.light_1_collider_front_end = 600	--Collider deactivation time
lua_table.light_1_combo_start = 600			--Combo timeframe start
lua_table.light_1_combo_end = 900			--Combo timeframe end
lua_table.light_1_duration = 1100			--Attack end (return to idle)
lua_table.light_1_animation_speed = 30.0

lua_table.light_2_block_time = 400			--Input block duration	(block new attacks)
lua_table.light_2_collider_front_start = 400	--Collider activation time
lua_table.light_2_collider_front_end = 500	--Collider deactivation time
lua_table.light_2_combo_start = 500			--Combo timeframe start
lua_table.light_2_combo_end = 800			--Combo timeframe end
lua_table.light_2_duration = 1000			--Attack end (return to idle)
lua_table.light_2_animation_speed = 30.0

lua_table.light_3_block_time = 500			--Input block duration	(block new attacks)
lua_table.light_3_collider_front_start = 450	--Collider activation time
lua_table.light_3_collider_front_end = 550	--Collider deactivation time
lua_table.light_3_combo_start = 600			--Combo timeframe start
lua_table.light_3_combo_end = 900			--Combo timeframe end
lua_table.light_3_duration = 1500			--Attack end (return to idle)
lua_table.light_3_animation_speed = 30.0		--IMPROVE: Attack 3 animaton includes a return to idle, which differs from the other animations, we might have to cut it for homogeinity with the rest

--Heavy Attack
lua_table.heavy_damage = 1.666				--Multiplier of Base Damage
lua_table.heavy_cost = 10

lua_table.heavy_movement_speed = 700.0

lua_table.heavy_1_block_time = 900			--Input block duration	(block new attacks)
lua_table.heavy_1_collider_front_start = 900	--Collider activation time
lua_table.heavy_1_collider_front_end = 1000	--Collider deactivation time
lua_table.heavy_1_combo_start = 1100			--Combo timeframe start
lua_table.heavy_1_combo_end = 1500			--Combo timeframe end
lua_table.heavy_1_duration = 1600			--Attack end (return to idle)
lua_table.heavy_1_animation_speed = 30.0

lua_table.heavy_2_block_time = 400			--Input block duration	(block new attacks)
lua_table.heavy_2_collider_front_start = 350	--Collider activation time
lua_table.heavy_2_collider_front_end = 450	--Collider deactivation time
lua_table.heavy_2_combo_start = 600			--Combo timeframe start
lua_table.heavy_2_combo_end = 900			--Combo timeframe end
lua_table.heavy_2_duration = 1000			--Attack end (return to idle)
lua_table.heavy_2_animation_speed = 30.0

lua_table.heavy_3_block_time = 800			--Input block duration	(block new attacks)
lua_table.heavy_3_collider_front_start = 700	--Collider activation time
lua_table.heavy_3_collider_front_end = 800	--Collider deactivation time
lua_table.heavy_3_combo_start = 1000			--Combo timeframe start
lua_table.heavy_3_combo_end = 1500			--Combo timeframe end
lua_table.heavy_3_duration = 2200			--Attack end (return to idle)
lua_table.heavy_3_animation_speed = 30.0		--IMPROVE: Attack 3 animaton includes a return to idle, which differs from the other animations, we might have to cut it for homogeinity with the rest

--Evade		
lua_table.evade_velocity = 12500.0	--Was 200 before dt
lua_table.evade_cost = 20
lua_table.evade_duration = 800

lua_table.evade_animation_speed = 40.0

--Ability
lua_table.ability_push_velocity = 10000
lua_table.ability_cost = 30
lua_table.ability_cooldown = 5000.0

local ability_started_at = 0.0
lua_table.ability_performed = false
lua_table.ability_start = 300.0
lua_table.ability_duration = 800.0

lua_table.ability_animation_speed = 70.0

lua_table.ability_offset_x = 0.1	--Near segment width (Must be > than 0)
lua_table.ability_offset_z = 10		--Near segment forward distance
lua_table.ability_range = 100		--Trapezoid height
lua_table.ability_angle = math.rad(45)

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

local ultimate_active = false

--Revive/Death
lua_table.revive_time = 5000	-- Time to revive
lua_table.down_time = 10000		-- Time until death (restarted by revival attempt)

lua_table.being_revived = false	-- Revival flag (managed by rescuer character)

local stopped_death = false		-- Death timer stop flag
local death_started_at = 0		-- Death timer start
local death_stopped_at = 0		-- Death timer stop
local revive_started_at = 0		-- Revive timer start

--Actions
local time_since_action = 0			-- Time passed since action performed
local current_action_block_time = 0	-- Duration of input block from current action/event (accept new action inputs)
local current_action_duration = 0	-- Duration of current action/event (return to idle)
local action_started_at = 0			-- Marks start of actions (and getting revived)

--Combos
lua_table.combo_cost_divider = 2			-- Reduction of cost of attacks if attack timed correctly

local combo_num = 0							-- Starting at 0, increases by 1 for each attack well timed, starting at 4, each new attack will be checked for a succesful combo. Bad timing or performing a combo resets to 0
local combo_stack = { 'N', 'N', 'N', 'N' }	-- Last 4 attacks performed (0=none, 1=light, 2=heavy). Use push_back tactic.

local combo_1 = { 'H', 'L', 'L', 'L' }	--Slide Attack
lua_table.combo_1_damage = 2.0	--slide + 4 hits
lua_table.combo_1_cost = 25
lua_table.combo_1_duration = 1500
lua_table.combo_1_animation_speed = 35.0
lua_table.combo_1_movement_speed = 4000.0

lua_table.combo_1_collider_body_start = 200		--Collider activation time
lua_table.combo_1_collider_body_end = 700		--Collider deactivation time
lua_table.combo_1_collider_right_start = 900	--Collider activation time
lua_table.combo_1_collider_right_end = 1000		--Collider deactivation time
lua_table.combo_1_collider_front_start = 1000	--Collider activation time
lua_table.combo_1_collider_front_end = 1080		--Collider deactivation time
lua_table.combo_1_collider_left_start = 1080	--Collider activation time
lua_table.combo_1_collider_left_end = 1150		--Collider deactivation time
lua_table.combo_1_collider_back_start = 1150	--Collider activation time
lua_table.combo_1_collider_back_end = 1220		--Collider deactivation time


local combo_2 = { 'L', 'L', 'L', 'H' }	--High Spin
lua_table.combo_2_damage = 2.5	--3 hit
lua_table.combo_2_cost = 30
lua_table.combo_2_duration = 1400
lua_table.combo_2_animation_speed = 30.0
lua_table.combo_2_movement_speed = 3000.0

lua_table.combo_2_collider_left_start = 500		--Collider activation time
lua_table.combo_2_collider_left_end = 600		--Collider deactivation time
lua_table.combo_2_collider_right_start = 800	--Collider activation time
lua_table.combo_2_collider_right_end = 900		--Collider deactivation time
lua_table.combo_2_collider_front_start = 1200	--Collider activation time
lua_table.combo_2_collider_front_end = 1400		--Collider deactivation time

local combo_3 = { 'L', 'H', 'H', 'L' }	--Jump Attack
lua_table.combo_3_damage = 3.0	--1 hit		--IMPROVE: + stun
lua_table.combo_3_cost = 40
lua_table.combo_3_duration = 1800
lua_table.combo_3_animation_speed = 30.0
lua_table.combo_3_movement_speed = 3000.0

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
	if math.abs(lua_table.TransformFunctions:GetRotationX()) == 180.0
	then
		if param_rot_y >= 0 then param_rot_y = 90 + 90 - param_rot_y
		elseif param_rot_y < 0 then param_rot_y = -90 + -90 - param_rot_y
		end
	end

	return param_rot_y
end

--Geometry END	----------------------------------------------------------------------------

--States BEGIN	----------------------------------------------------------------------------

local function GoDefaultState()
	lua_table.previous_state = lua_table.current_state

	if mov_input.used_input.x ~= 0.0 or mov_input.used_input.z ~= 0.0
	then
		if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)
		then
			lua_table.AnimationFunctions:PlayAnimation("run", lua_table.run_animation_speed)
			--lua_table.AudioFunctions:PlayStepSound()	--TODO-AUDIO: Play run sound
			lua_table.current_state = state.run
		else
			lua_table.AnimationFunctions:PlayAnimation("walk", lua_table.walk_animation_speed)
			--lua_table.AudioFunctions:PlayStepSound()	--TODO-AUDIO: Play walk sound
			lua_table.current_state = state.walk
		end
	else
		lua_table.AnimationFunctions:PlayAnimation("idle", lua_table.idle_animation_speed)
		--lua_table.AudioFunctions:StopStepSound()	--TODO-AUDIO: Stop current sound event
		lua_table.current_state = state.idle
		lua_table.ParticlesFunctions:DeactivateParticlesEmission()	--Deactivate movement dust particles
	end
	
	rightside = true
end

local function CheckIncomingDamage()
	local collision_enter = {}--lua_table.PhysicsFunctions:OnCollisionEnter()	--TODO: Uncomment when working

	for num, go_uid in ipairs(collision_enter) do	--Iterate all UIDs of collisions that Geralt collider has entered for the first time
		local layer = lua_table.GameObjectFunctions:GetGameObjectLayer()

		if layer == "enemy_attack"	--IF collider is tagged as an enemy attack
		then
			local collider_parent = lua_table.GameObjectFunctions:GetGameObjectParent(go_uid)
			local enemy_script = {}

			if collider_parent ~= 0 then	--IF collider has parent, data is saved on parent (it means the collider is repurposed)
				enemy_script = lua_table.GameObjectFunctions:GetScript(collider_parent)
			else							--IF collider has no parent, data is saved within collider
				enemy_script = lua_table.GameObjectFunctions:GetScript(go_uid)
			end

			lua_table.current_health = lua_table.current_health - enemy_script.collider_damage

			if enemy_script.collider_effect ~= attack_effects.none
			then
				--TODO: React to special effect
			end
		end
	end

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
	mov_speed_max_real = lua_table.mov_speed_max_orig * lua_table.mov_speed_max_mod
	mov_speed_stat = mov_speed_max_real * 0.1

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

local function JoystickInputs(key_string, input_table)
	input_table.real_input.x = lua_table.InputFunctions:GetAxisValue(lua_table.player_ID, key_string .. "X", 0.01)	--Get accurate inputs
	input_table.real_input.z = lua_table.InputFunctions:GetAxisValue(lua_table.player_ID, key_string .. "Y", 0.01)

	if input_table.real_input.x == input_table.prev_input.x and input_table.real_input.z == input_table.prev_input.z	--IF both inputs exactly the same as last frame
	and math.abs(input_table.real_input.x) < key_joystick_threshold and math.abs(input_table.real_input.z) < key_joystick_threshold			--and IF  both inputs under joystick threshold
	then
	 	input_table.used_input.x, input_table.used_input.z = 0.0, 0.0	--Set used input as idle (0)
	else
		input_table.used_input.x, input_table.used_input.z = input_table.real_input.x, input_table.real_input.z	--Use real input
	end

	input_table.prev_input.x, input_table.prev_input.z = input_table.real_input.x, input_table.real_input.z	--Record previous real input as current one
end

local function KeyboardInputs()	--Process Debug Keyboard Inputs
	mov_input.used_input.x, mov_input.used_input.z = 0.0, 0.0
	
	if lua_table.InputFunctions:KeyRepeat("D")
	then
		mov_input.used_input.x = 2.0
	elseif lua_table.InputFunctions:KeyRepeat("A")
	then
		mov_input.used_input.x = -2.0
	end
	
	if lua_table.InputFunctions:KeyRepeat("S")
	then
		mov_input.used_input.z = -2.0
	elseif lua_table.InputFunctions:KeyRepeat("W")
	then
		mov_input.used_input.z = 2.0
	end
end

--Inputs END	----------------------------------------------------------------------------

--Character Movement BEGIN	----------------------------------------------------------------------------

local function SaveDirection()
	if mov_input.used_input.x ~= 0 and mov_input.used_input.z ~= 0	--IF input given, use as direction
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

		rot_y = math.rad(GimbalLockWorkaroundY(lua_table.TransformFunctions:GetRotationY()))	--TODO: Remove GimbalLock stage when Euler bug is fixed

		rec_direction.x = math.sin(rot_y)
		rec_direction.z = math.cos(rot_y)
	end
end

local function DirectionInBounds()	--Every time we try to set a velocity, this is checked first to allow it
	local ret = true

	if off_bounds then
		rot_y = math.rad(GimbalLockWorkaroundY(lua_table.TransformFunctions:GetRotationY()))	--TODO: Remove GimbalLock stage when Euler bug is fixed
		
		lua_table.SystemFunctions:LOG("Angle Between: " .. math.deg(BidimensionalAngleBetweenVectors(math.sin(rot_y), math.cos(rot_y), bounds_vector.x, bounds_vector.z)))

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
	local pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()
	local side_top, side_bottom, side_left, side_right
	side_top = lua_table.GameObjectFunctions:GetTopFrustumIntersection(pos_x, pos_y, pos_z, camera_bounds_ratio)
	side_bottom = lua_table.GameObjectFunctions:GetBottomFrustumIntersection(pos_x, pos_y, pos_z, camera_bounds_ratio)
	side_left = lua_table.GameObjectFunctions:GetLeftFrustumIntersection(pos_x, pos_y, pos_z, camera_bounds_ratio)
	side_right = lua_table.GameObjectFunctions:GetRightFrustumIntersection(pos_x, pos_y, pos_z, camera_bounds_ratio)
	-- 0 == outside, 1 == inside

	lua_table.SystemFunctions:LOG("Cam Planes: " .. side_top .. "_" .. side_bottom .. "_" .. side_left .. "_" .. side_right)

	--2. Restart camera bounds values
	bounds_vector.x = 0
	bounds_vector.z = 0
	bounds_angle = 90

	--3. Generate a vector and change angle depending on planes that we're traspassing (1 plane = 90º, 2 planes = 45º)
	--3.1. Check down/up
	if side_bottom == 0 then
		bounds_vector.z = -1
	elseif side_top == 0 then
		bounds_vector.z = 1
	else
		--bounds_angle = bounds_angle + 45
	end

	--3.2. Check left/right
	if side_left == 0 then
		bounds_vector.x = 1
	elseif side_right == 0 then
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

local function MovementInputs()	--Process Movement Inputs
	if mov_input.used_input.x ~= 0.0 or mov_input.used_input.z ~= 0.0												--IF Movement Input
	then
		--Swap between idle and moving
		if lua_table.current_state == state.idle																	--IF Idle
		then
			lua_table.previous_state = lua_table.current_state

			if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF great input
			then
				lua_table.AnimationFunctions:PlayAnimation("run", lua_table.run_animation_speed)
				--lua_table.AudioFunctions:PlayStepSound()	--TODO-AUDIO: Play run sound
				lua_table.current_state = state.run
			else																					--IF small input
				lua_table.AnimationFunctions:PlayAnimation("walk", lua_table.walk_animation_speed)
				--lua_table.AudioFunctions:PlayStepSound()	--TODO-AUDIO: Play walk sound
				lua_table.current_state = state.walk
			end

			lua_table.ParticlesFunctions:ActivateParticlesEmission()	--Activate movement dust particles

		--Swap between walking and running
		elseif lua_table.current_state == state.walk and lua_table.input_walk_threshold < math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF walking and big input
		then
			lua_table.AnimationFunctions:PlayAnimation("run", lua_table.run_animation_speed)
			--lua_table.AudioFunctions:PlayStepSound()	--TODO-AUDIO: Play run sound
			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.run
		elseif lua_table.current_state == state.run and lua_table.input_walk_threshold > math.sqrt(mov_input.used_input.x ^ 2 + mov_input.used_input.z ^ 2)	--IF running and small input
		then
			lua_table.AnimationFunctions:PlayAnimation("walk", lua_table.walk_animation_speed)
			--lua_table.AudioFunctions:PlayStepSound()	--TODO-AUDIO: Play walk sound
			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.walk
		end

		--Move character
		mov_speed.x = mov_speed_max_real * mov_input.used_input.x	--Joystick input directly translates to speed, no acceleration
		mov_speed.z = mov_speed_max_real * mov_input.used_input.z

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to velocity direction
		lua_table.TransformFunctions:LookAt(pos_x + mov_speed.x, pos_y, pos_z + mov_speed.z)

		if DirectionInBounds()	--Only allow movement if camera bounds allows it
		then
			lua_table.PhysicsFunctions:Move(mov_speed.x * dt, mov_speed.z * dt)
		end

	elseif lua_table.current_state == state.run or lua_table.current_state == state.walk
	then
		--Animation to IDLE
		lua_table.AnimationFunctions:PlayAnimation("idle", lua_table.idle_animation_speed)
		--lua_table.AudioFunctions:StopStepSound()	--TODO-AUDIO: Stop current sound event
		lua_table.ParticlesFunctions:DeactivateParticlesEmission()	--Deactivate movement dust particles
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.idle
	end
end

--Character Movement END	----------------------------------------------------------------------------

--Character Actions BEGIN	----------------------------------------------------------------------------

local function CheckCombo()	--Check combo performed	(ATTENTION: This should handle the animation, setting timers, bla bla)
	local string_match = false

	if lua_table.current_energy > lua_table.combo_1_cost and CompareTables(combo_stack, combo_1)
	then
		current_action_block_time = lua_table.combo_1_duration
		current_action_duration = lua_table.combo_1_duration

		lua_table.current_energy = lua_table.current_energy - lua_table.combo_1_cost

		lua_table.AnimationFunctions:PlayAnimation("combo_1", lua_table.combo_1_animation_speed)	--Slide
		--TODO-AUDIO: Play sound of combo_1

		lua_table.collider_damage = base_damage_real * lua_table.combo_1_damage

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.combo_1

		string_match = true
	elseif lua_table.current_energy > lua_table.combo_2_cost and CompareTables(combo_stack, combo_2)
	then
		current_action_block_time = lua_table.combo_2_duration
		current_action_duration = lua_table.combo_2_duration

		lua_table.current_energy = lua_table.current_energy - lua_table.combo_2_cost
		
		lua_table.AnimationFunctions:PlayAnimation("combo_2", lua_table.combo_2_animation_speed)	--Spin
		--TODO-AUDIO: Play sound of combo_2
		
		lua_table.collider_damage = base_damage_real * lua_table.combo_2_damage

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.combo_2

		string_match = true
	elseif lua_table.current_energy > lua_table.combo_3_cost and CompareTables(combo_stack, combo_3)
	then
		current_action_block_time = lua_table.combo_3_duration
		current_action_duration = lua_table.combo_3_duration

		lua_table.current_energy = lua_table.current_energy - lua_table.combo_3_cost
		
		lua_table.AnimationFunctions:PlayAnimation("combo_3", lua_table.combo_3_animation_speed)	--Jump
		--TODO-AUDIO: Play sound of combo_3
		
		lua_table.collider_damage = base_damage_real * lua_table.combo_3_damage

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.combo_3

		string_match = true
	end

	return string_match
end

local function TimedAttack(attack_cost)
	local combo_achieved = false

	if lua_table.current_state <= state.run		--IF Idle or Moving
	then
		combo_num = 1					--Register combo start
		lua_table.current_energy = lua_table.current_energy - attack_cost

	elseif lua_table.current_state == state.light_1 and time_since_action > lua_table.light_1_combo_start and time_since_action < lua_table.light_1_combo_end
	or lua_table.current_state == state.light_2 and time_since_action > lua_table.light_2_combo_start and time_since_action < lua_table.light_2_combo_end
	or lua_table.current_state == state.light_3 and time_since_action > lua_table.light_3_combo_start and time_since_action < lua_table.light_3_combo_end
	or lua_table.current_state == state.heavy_1 and time_since_action > lua_table.heavy_1_combo_start and time_since_action < lua_table.heavy_1_combo_end
	or lua_table.current_state == state.heavy_2 and time_since_action > lua_table.heavy_2_combo_start and time_since_action < lua_table.heavy_2_combo_end
	or lua_table.current_state == state.heavy_3 and time_since_action > lua_table.heavy_3_combo_start and time_since_action < lua_table.heavy_3_combo_end
	then
		combo_num = combo_num + 1
		lua_table.current_energy = lua_table.current_energy - attack_cost / lua_table.combo_cost_divider

		if combo_num > 3 then			--IF 4+ goods attacks
			combo_achieved = CheckCombo()
			if combo_achieved then
				combo_num = 0
			end
		end
	else
		combo_num = 1	--Not good timing since last attack
		lua_table.current_energy = lua_table.current_energy - attack_cost
	end

	--TODO-Particles: Turn on particles on Sword
	lua_table.ParticlesFunctions:DeactivateParticlesEmission()	--Deactivate movement dust particles

	return combo_achieved
end

local function RegularAttack(attack_type)

	if lua_table.current_state == state.heavy_3 then	--Heavy_3 animation starts and ends on the right, therefore in this particular case we stay on the right
		rightside = not rightside
	end

	if rightside	--IF rightside
	then
		if combo_num > 2	--IF more than 2 succesful attacks
		then
			current_action_block_time = lua_table[attack_type .. "_3_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_3_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_3", lua_table[attack_type .. "_3_animation_speed"])
			--lua_table.AudioFunctions:PlayAttackSound()	--TODO-AUDIO: Play attack_3 sound (light or heavy)

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state[attack_type .. "_3"]
		else
			current_action_block_time = lua_table[attack_type .. "_1_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_1_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_1", lua_table[attack_type .. "_1_animation_speed"])
			--lua_table.AudioFunctions:PlayAttackSound()	--TODO-AUDIO: Play attack_1 sound (light or heavy)

			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state[attack_type .. "_1"]
		end
	else			--IF leftside
		current_action_block_time = lua_table[attack_type .. "_2_block_time"]	--Set duration of input block (no new actions)
		current_action_duration = lua_table[attack_type .. "_2_duration"]		--Set duration of the current action (to return to idle/move)

		lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_2", lua_table[attack_type .. "_2_animation_speed"])
		--lua_table.AudioFunctions:PlayAttackSound()	--TODO-AUDIO: Play attack_2 sound (light or heavy)

		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state[attack_type .. "_2"]
	end

	lua_table.collider_damage = base_damage_real * lua_table[attack_type .. "_damage"]
	rightside = not rightside
end

local function AardPush()
	--1. Collect colliders of all enemies inside a radius
	local geralt_pos_x, geralt_pos_y, geralt_pos_z = lua_table.TransformFunctions:GetPosition()
	enemy_list = lua_table.PhysicsFunctions:OverlapSphere(geralt_pos_x, geralt_pos_y, geralt_pos_z, lua_table.ability_range, "enemy", false)

	--REMOVE: Workaround which artificially places a GO in the list
	-- local enemy_list = {}
	-- local target = lua_table.GameObjectFunctions:FindGameObject("gerardo2")
	-- local target_x = lua_table.GameObjectFunctions:GetGameObjectPosX(target)
	-- local target_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(target)

	-- if math.sqrt((target_x - geralt_pos_x) ^ 2 + (target_z - geralt_pos_z) ^ 2) <= lua_table.ability_range then
	-- 	enemy_list[1] = target
	-- end

	--2. Transform ability trapezoid to Geralt's current rotation
	SaveDirection()
	local A_z, A_x = BidimensionalRotate(ability_trapezoid.point_A.z, ability_trapezoid.point_A.x, rot_y)
	local B_z, B_x = BidimensionalRotate(ability_trapezoid.point_B.z, ability_trapezoid.point_B.x, rot_y)
	local C_z, C_x = BidimensionalRotate(ability_trapezoid.point_C.z, ability_trapezoid.point_C.x, rot_y)
	local D_z, D_x = BidimensionalRotate(ability_trapezoid.point_D.z, ability_trapezoid.point_D.x, rot_y)

	--3. Translate the local trapezoid positions to global coordinates
	A_x, A_z = A_x + geralt_pos_x, A_z + geralt_pos_z
	B_x, B_z = B_x + geralt_pos_x, B_z + geralt_pos_z
	C_x, C_z = C_x + geralt_pos_x, C_z + geralt_pos_z
	D_x, D_z = D_x + geralt_pos_x, D_z + geralt_pos_z

	--4. We must check that the enemy is inside the AoE
	for k, v in pairs(enemy_list) do
		local enemy_pos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(v)
		local enemy_pos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(v)

		if BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, target_x, target_z) < 0	--If left side of all the trapezoid vectors BC, CD, DA ( \_/ )
		and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, target_x, target_z) < 0
		and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, target_x, target_z) < 0
		then
			local direction_x, direction_z = enemy_pos_x - geralt_pos_x, enemy_pos_z - geralt_pos_z	--4.1. If inside, find direction Geralt->Enemy and apply velocity in that direction
			local magnitude = math.sqrt(direction_x ^ 2 + direction_z ^ 2)
			--lua_table.PhysicsFunctions:Move(lua_table.ability_push_velocity * direction_x / magnitude * dt, lua_table.ability_push_velocity * direction_z / magnitude * dt)
			--TODO: Stun enemy
			--TODO: Set Enemy Linear Velocity
		end
	end
end

local function ActionInputs()	--Process Action Inputs
	local input_given = false
	local combo_achieved = false
	
	if lua_table.current_energy >= lua_table.light_cost and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_light, key_state.key_down)		--Light Input
	then
		action_started_at = game_time		--Set timer start mark
		PushBack(combo_stack, 'L')			--Add new input to stack

		combo_achieved = TimedAttack(lua_table.light_cost)

		if not combo_achieved	--If no combo was achieved with the input, do the attack normally
		then
			RegularAttack("light")
		end

		SaveDirection()

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to direction
		lua_table.TransformFunctions:LookAt(pos_x + rec_direction.x, pos_y, pos_z + rec_direction.z)

		input_given = true

	elseif lua_table.current_energy >= lua_table.heavy_cost and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_heavy, key_state.key_down)	--Heavy Input
	then
		action_started_at = game_time		--Set timer start mark
		PushBack(combo_stack, 'H')			--Add new input to stack

		combo_achieved = TimedAttack(lua_table.heavy_cost)

		if not combo_achieved	--If no combo was achieved with the input, do the attack normally
		then
			RegularAttack("heavy")
		end

		SaveDirection()

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to direction
		lua_table.TransformFunctions:LookAt(pos_x + rec_direction.x, pos_y, pos_z + rec_direction.z)

		input_given = true

	elseif lua_table.current_energy >= lua_table.evade_cost and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_evade, key_state.key_down)	--Evade Input
	then
		action_started_at = game_time							--Set timer start mark
		current_action_block_time = lua_table.evade_duration
		current_action_duration = lua_table.evade_duration

		SaveDirection()

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to direction
		lua_table.TransformFunctions:LookAt(pos_x + rec_direction.x, pos_y, pos_z + rec_direction.z)

		lua_table.AnimationFunctions:PlayAnimation("evade", lua_table.evade_animation_speed)
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.evade
		
		lua_table.current_energy = lua_table.current_energy - lua_table.evade_cost

		lua_table.ParticlesFunctions:ActivateParticlesEmission()	--Activate movement dust particles

		input_given = true
		
	elseif game_time - ability_started_at >= lua_table.ability_cooldown
	and lua_table.current_energy > lua_table.ability_cost
	and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_ability, key_state.key_down)	--IF cooldown over and Ability Input
	then
		action_started_at = game_time								--Set timer start mark
		ability_started_at = action_started_at

		current_action_block_time = lua_table.ability_duration
		current_action_duration = lua_table.ability_duration

		lua_table.AnimationFunctions:PlayAnimation("ability", lua_table.ability_animation_speed)
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.ability

		lua_table.ability_performed = false	--The ability itself and energy cost reduction is done later to fit with the animation, this marks that it needs to be done
		input_given = true

	elseif lua_table.current_ultimate >= lua_table.max_ultimate
	and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_1, key_state.key_repeat)
	and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_2, key_state.key_repeat)	--Ultimate Input
	then
		action_started_at = game_time							--Set timer start mark
		ultimate_started_at = action_started_at

		current_action_block_time = lua_table.ultimate_duration
		current_action_duration = lua_table.ultimate_duration

		--Do Ultimate
		lua_table.AnimationFunctions:PlayAnimation("ultimate", lua_table.ultimate_animation_speed)
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.ultimate
		input_given = true

	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_use_item, key_state.key_down)	--Object Input
	then
		action_started_at = game_time							--Set timer start mark

		--Do Use_Object
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.item
		input_given = true

	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_interact, key_state.key_down)	--Revive Input
	then
		action_started_at = game_time							--Set timer start mark

		--Do Revive
		lua_table.previous_state = lua_table.current_state
		lua_table.current_state = state.revive
		input_given = true
	end

	if input_given and not (lua_table.current_state <= state.combo_3 and lua_table.current_state >= state.light_1)	--IF input given and is not an attack
	then
		--TODO-Particles: Deactivate Particles on Sword
	end

	return input_given
end

local function UltimateState(active)
	local ultimate_stat_mod = 1
	if not active then ultimate_stat_mod = -1 end

	lua_table.health_reg_mod = lua_table.health_reg_mod + lua_table.ultimate_health_reg_increase * ultimate_stat_mod
	lua_table.energy_reg_mod = lua_table.energy_reg_mod + lua_table.ultimate_energy_reg_increase * ultimate_stat_mod
	lua_table.base_damage_mod = lua_table.base_damage_mod + lua_table.ultimate_damage_mod_increase * ultimate_stat_mod

	if active then
		--TODO-Particles: Activate ultimate particles
	else
		--TODO-Particles: Deactivate ultimate particles
	end

	must_update_stats = true
	ultimate_active = active
end

--Character Actions END	----------------------------------------------------------------------------

--Character Colliders BEGIN	----------------------------------------------------------------------------

local function AttackColliderCheck(attack_type, attack_num, collider_side)	--Checks timeframe of current action and activates or deactivates a speficied side collider depending on it
	if time_since_action > lua_table[attack_type .. "_" .. attack_num .. "_collider_" .. collider_side .. "_start"]		--IF time > start collider
	then
		if time_since_action > lua_table[attack_type .. "_" .. attack_num .. "_collider_" .. collider_side .. "_end"]	--IF time > end collider
		then
			if active_colliders[collider_side]	--IF > end time and collider active, deactivate
			then
				--TODO: Deactivate Geralt "side .. _collider" GO
				active_colliders[collider_side] = false
			end

			--lua_table.SystemFunctions:LOG("Collider Deactive: " .. attack_type .. "_" .. attack_num .. "_" .. collider_side)
			
		elseif not active_colliders[collider_side]	--IF > start time and collider unactive, activate
		then
			--TODO: Activate Geralt "side .. _collider" GO
			active_colliders[collider_side] = true
		--else
			--lua_table.SystemFunctions:LOG("Collider Active: " .. attack_type .. "_" .. attack_num .. "_" .. collider_side)
		end
	end
end

local function AttackColliderShutdown()
	if active_colliders.front then
		--TODO: Deactivate front collider
		active_colliders.front = false
	end
	if active_colliders.back then
		--TODO: Deactivate back collider
		active_colliders.back = false
	end
	if active_colliders.left then
		--TODO: Deactivate left collider
		active_colliders.left = false
	end
	if active_colliders.right then
		--TODO: Deactivate right collider
		active_colliders.right = false
	end
end

--Character Colliders END	----------------------------------------------------------------------------

--Character Secondaries BEGIN	----------------------------------------------------------------------------

local function SecondaryInputs()	--Process Secondary Inputs
	if lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_pickup_item, key_state.key_down)			--Pickup Item
	then
		--IF consumable (increase counter)
		--ELSEIF gear (replace current gear)
	
	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_prev_consumable, key_state.key_down)	--Previous Consumable
	then
		--GO TO PREV CONSUMABLE
	
	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_next_consumable, key_state.key_down)	--Next Consumable
	then
		--GO TO NEXT CONSUMABLE

	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_drop_consumable, key_state.key_down)	--Drop Consumable
	then
		--DROP CURRENT CONSUMABLE
	end
end

--Character Secondaries END	----------------------------------------------------------------------------

--Collider Calls BEGIN
function lua_table:OnTriggerEnter()
	lua_table.SystemFunctions:LOG("On Trigger Enter")
end

function lua_table:OnCollisionEnter()
	lua_table.SystemFunctions:LOG("On Collision Enter")
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

	camera_bounds_ratio = lua_table.GameObjectFunctions:GetScript(lua_table.GameObjectFunctions:FindGameObject("Camera")).Layer_3_FOV_ratio_1

	lua_table.max_health_real = lua_table.max_health_orig	--Necessary for the first CalculateStats()
	CalculateStats()	--Calculate stats based on orig values + modifier

	--Set initial values
	lua_table.current_health = lua_table.max_health_real
	lua_table.current_energy = lua_table.max_energy_real
	lua_table.current_ultimate = 0.0

	CalculateAbilityTrapezoid()
end

function lua_table:Start()
    lua_table.SystemFunctions:LOG("GeraltScript START")
end

function lua_table:Update()

	dt = lua_table.SystemFunctions:DT()
	game_time = PerfGameTime()

	if must_update_stats then CalculateStats() end

	CheckCameraBounds()
	CheckIncomingDamage()

	if lua_table.current_state ~= state.dead	--IF not dead (stuff done while downed too)
	then
		if not ultimate_active	--IF ultimate offline
		then
			--Ultimate Regeneration
			if lua_table.current_ultimate < lua_table.max_ultimate then lua_table.current_ultimate = lua_table.current_ultimate + ultimate_reg_real * dt end	--IF can increase, increase ultimate
			if lua_table.current_ultimate > lua_table.max_ultimate then lua_table.current_ultimate = lua_table.max_ultimate end									--IF above max, set to max
		end

		if lua_table.ability_performed and game_time - ability_started_at >= lua_table.ability_cooldown	--IF ability cooldown finished, mark for UI
		then
			lua_table.ability_performed = false
		end
	end

	if lua_table.current_state >= state.idle	--IF alive
	then
		if lua_table.current_health <= 0
		then
			lua_table.AnimationFunctions:PlayAnimation("death", 30.0)
			death_started_at = game_time
			lua_table.previous_state = lua_table.current_state
			lua_table.current_state = state.down

			if ultimate_active then UltimateState(false) end	--IF ultimate on, go off
			AttackColliderShutdown()							--IF any attack colliders on, turn off
		else
			--DEBUG
			--KeyboardInputs()

			--Joystick Inputs
			JoystickInputs(lua_table.key_move, mov_input)
			JoystickInputs(lua_table.key_aim, aim_input)

			--Health Regeneration
			if health_reg_real > 0	--IF health regen online
			then
				if lua_table.current_health < lua_table.max_health_real then lua_table.current_health = lua_table.current_health + health_reg_real * dt end	--IF can increase, increase health
				if lua_table.current_health > lua_table.max_health_real then lua_table.current_health = lua_table.max_health_real end						--IF above max, set to max
			end

			--Energy Regeneration
			if lua_table.current_energy < lua_table.max_energy_real then lua_table.current_energy = lua_table.current_energy + energy_reg_real * dt end	--IF can increase, increase energy
			if lua_table.current_energy > lua_table.max_energy_real then lua_table.current_energy = lua_table.max_energy_real end						--IF above max, set to max

			if ultimate_active and game_time - ultimate_effect_started_at >= lua_table.ultimate_effect_duration	--IF ultimate online and time up!
			then
				UltimateState(false)	--Ultimate turn off (stats back to normal)
			end

			--IF action currently going on, check action timer
			if lua_table.current_state > state.run
			then
				time_since_action = game_time - action_started_at
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
				--SecondaryInputs()	--Minor actions with no timer or special animations

			else	--ELSE (action being performed)
				time_since_action = game_time - action_started_at

				if lua_table.current_state == state.ultimate and not ultimate_active and time_since_action > lua_table.ultimate_scream_start	--IF ultimate state, ultimate unactive, and scream started
				then
					UltimateState(true)	--Ultimate turn on (boost stats)

					lua_table.current_ultimate = 0.0
					ultimate_effect_started_at = game_time
				end

				if time_since_action > current_action_duration	--IF action duration up
				then
					if lua_table.current_state >= state.light_1 and lua_table.current_state <= state.combo_3	--IF attack finished
					then
						--TODO-Particles: Deactivate Particles on Sword
					elseif lua_table.current_state == state.ability
					then
						--TODO-Particles: Deactivate Aard particles on hand
					end

					GoDefaultState()	--Return to move or idle

				elseif lua_table.current_state == state.ability and not lua_table.ability_performed and time_since_action > lua_table.ability_start
				then
					--AardPush()	--TODO: Uncomment when it works
					--TODO-Particles: Activate Aard particles on hand
					lua_table.current_energy = lua_table.current_energy - lua_table.ability_cost
					lua_table.ability_performed = true

				elseif lua_table.current_state == state.evade and DirectionInBounds()				--ELSEIF evading
				then
					lua_table.PhysicsFunctions:Move(lua_table.evade_velocity * rec_direction.x * dt, lua_table.evade_velocity * rec_direction.z * dt)	--IMPROVE: Speed set on every frame bad?

				elseif lua_table.current_state == state.light_1 or lua_table.current_state == state.light_2 or lua_table.current_state == state.light_3	--IF Light Attacking
				then
					if lua_table.current_state ~= state.light_1 and not (lua_table.current_state == state.light_3 and time_since_action > lua_table.light_3_combo_end) and DirectionInBounds()	--IF not light_1 and outside return to idle of light_3	--IMPROVE: Maybe just cut the return to idle part?
					then
						lua_table.PhysicsFunctions:Move(lua_table.light_movement_speed * rec_direction.x * dt, lua_table.light_movement_speed * rec_direction.z * dt)
					end

					--Collider Evaluation
					if lua_table.current_state == state.light_1 then AttackColliderCheck("light", 1, "front")
					elseif lua_table.current_state == state.light_2 then AttackColliderCheck("light", 2, "front")
					elseif lua_table.current_state == state.light_3 then AttackColliderCheck("light", 3, "front")
					end

				elseif lua_table.current_state == state.heavy_1 or lua_table.current_state == state.heavy_2 or lua_table.current_state == state.heavy_3	--IF Heavy Attacking
				then
					if not (lua_table.current_state == state.heavy_3 and time_since_action > lua_table.heavy_3_combo_end) and DirectionInBounds()	--IF outside return to idle of heavy_3	--IMPROVE: Maybe just cut the return to idle part?
					then
						lua_table.PhysicsFunctions:Move(lua_table.heavy_movement_speed * rec_direction.x * dt, lua_table.heavy_movement_speed * rec_direction.z * dt)
					end

					--Collider Evaluation
					if lua_table.current_state == state.heavy_1 then AttackColliderCheck("heavy", 1, "front")
					elseif lua_table.current_state == state.heavy_2 then AttackColliderCheck("heavy", 2, "front")
					elseif lua_table.current_state == state.heavy_3 then AttackColliderCheck("heavy", 3, "front")
					end

				elseif lua_table.current_state == state.combo_1 and DirectionInBounds()
				then
					lua_table.PhysicsFunctions:Move(lua_table.combo_1_movement_speed * rec_direction.x * dt, lua_table.combo_1_movement_speed * rec_direction.z * dt)
					
					--Collider Evaluation
					AttackColliderCheck("combo", 1, "right")
					AttackColliderCheck("combo", 1, "front")
					AttackColliderCheck("combo", 1, "left")
					AttackColliderCheck("combo", 1, "back")

				elseif lua_table.current_state == state.combo_2 and DirectionInBounds()
				then
					lua_table.PhysicsFunctions:Move(lua_table.combo_2_movement_speed * rec_direction.x * dt, lua_table.combo_2_movement_speed * rec_direction.z * dt)
					
					--Collider Evaluation
					AttackColliderCheck("combo", 2, "left")
					AttackColliderCheck("combo", 2, "right")
					AttackColliderCheck("combo", 2, "front")

				elseif lua_table.current_state == state.combo_3 and DirectionInBounds()
				then
					lua_table.PhysicsFunctions:Move(lua_table.combo_3_movement_speed * rec_direction.x * dt, lua_table.combo_3_movement_speed * rec_direction.z * dt)

					--Collider Evaluation
					AttackColliderCheck("combo", 3, "front")

				end
			end
		end
	elseif lua_table.current_state == state.down	--IF currently down
	then
		if lua_table.being_revived		--IF flag marks that other player is reviving (controlled by another player)
		then
			if not stopped_death		--IF stop mark hasn't been done yet
			then
				death_stopped_at = game_time			--Mark revival start (for death timer)
				stopped_death = true					--Flag death timer stop
				revive_started_at = death_stopped_at	--Mark revival start (for revival timer)

			elseif game_time - revive_started_at > lua_table.revive_time		--IF revival complete
			then
				lua_table.current_health = lua_table.max_health_real / 2	--Get half health
				GoDefaultState()						--Return to move or idle
			end
		else								--IF other player isn't reviving
			if stopped_death				--IF death timer was stopped
			then
				death_started_at = death_started_at + game_time - death_stopped_at	--Resume timer
				stopped_death = false				--Flag timer resuming

			elseif game_time - death_started_at > lua_table.down_time	--IF death timer finished
			then
				lua_table.previous_state = lua_table.current_state
				lua_table.current_state = state.dead			--Kill character
				--lua_table.Functions:Deactivate()	--Disable character
			end
		end
	end

	--DEBUG LOGS
	--lua_table.SystemFunctions:LOG("Delta Time: " .. dt)
	lua_table.SystemFunctions:LOG("State: " .. lua_table.current_state)
	lua_table.SystemFunctions:LOG("Time passed: " .. time_since_action)
	--rot_y = math.rad(GimbalLockWorkaroundY(lua_table.TransformFunctions:GetRotationY()))	--TODO: Remove GimbalLock stage when Euler bug is fixed
	--lua_table.SystemFunctions:LOG("Angle Y: " .. rot_y)
	--lua_table.SystemFunctions:LOG("Ultimate: " .. lua_table.current_ultimate)
	--lua_table.SystemFunctions:LOG("Combo num: " .. combo_num)
	--lua_table.SystemFunctions:LOG("Combo string: " .. combo_stack[1] .. ", " .. combo_stack[2] .. ", " .. combo_stack[3] .. ", " .. combo_stack[4])

	--Stats LOGS
	--lua_table.SystemFunctions:LOG("Health: " .. lua_table.current_health)
	--lua_table.SystemFunctions:LOG("Energy: " .. lua_table.current_energy)

	--lua_table.SystemFunctions:LOG("Health Reg: " .. health_reg_real)
	--lua_table.SystemFunctions:LOG("Energy Reg: " .. energy_reg_real)
	--lua_table.SystemFunctions:LOG("Damage: " .. base_damage_real)

	--lua_table.SystemFunctions:LOG("Health Reg Mod: " .. lua_table.health_reg_mod)
	--lua_table.SystemFunctions:LOG("Energy Reg Mod: " .. lua_table.energy_reg_mod)
	--lua_table.SystemFunctions:LOG("Damage Mod: " .. lua_table.base_damage_mod)

	--Trapezoid Global BEGIN
	-- local geralt_pos_x, geralt_pos_y, geralt_pos_z = lua_table.TransformFunctions:GetPosition()
	-- local A_x, A_z = ability_trapezoid.point_A.x + geralt_pos_x, ability_trapezoid.point_A.z + geralt_pos_z
	-- local B_x, B_z = ability_trapezoid.point_B.x + geralt_pos_x, ability_trapezoid.point_B.z + geralt_pos_z
	-- local C_x, C_z = ability_trapezoid.point_C.x + geralt_pos_x, ability_trapezoid.point_C.z + geralt_pos_z
	-- local D_x, D_z = ability_trapezoid.point_D.x + geralt_pos_x, ability_trapezoid.point_D.z + geralt_pos_z

	-- lua_table.SystemFunctions:LOG("Ability Trapezoid: " .. ability_trapezoid.point_A.x .. "," .. ability_trapezoid.point_A.z .. " / " .. ability_trapezoid.point_B.x .. "," .. ability_trapezoid.point_B.z .. " / " .. ability_trapezoid.point_C.x .. "," .. ability_trapezoid.point_C.z .. " / " .. ability_trapezoid.point_D.x .. "," .. ability_trapezoid.point_D.z)
	-- lua_table.SystemFunctions:LOG("Real Trapezoid: " .. A_x .. "," .. A_z .. " / " .. B_x .. "," .. B_z .. " / " .. C_x .. "," .. C_z .. " / " .. D_x .. "," .. D_z)

	-- local target = lua_table.GameObjectFunctions:FindGameObject("gerardo2")
	-- local target_x = lua_table.GameObjectFunctions:GetGameObjectPosX(target)
	-- local target_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(target)

	-- if math.sqrt((target_x - geralt_pos_x) ^ 2 + (target_z - geralt_pos_z) ^ 2) <= lua_table.ability_range	--IF on the left side of all vectors + within the OverlapSphere = inside AoE
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
	-- local geralt_pos_x, geralt_pos_y, geralt_pos_z = lua_table.TransformFunctions:GetPosition()
	-- local A_x, A_z = ability_trapezoid.point_A.x, ability_trapezoid.point_A.z
	-- local B_x, B_z = ability_trapezoid.point_B.x, ability_trapezoid.point_B.z
	-- local C_x, C_z = ability_trapezoid.point_C.x, ability_trapezoid.point_C.z
	-- local D_x, D_z = ability_trapezoid.point_D.x, ability_trapezoid.point_D.z

	-- lua_table.SystemFunctions:LOG("Ability Trapezoid: " .. ability_trapezoid.point_A.x .. "," .. ability_trapezoid.point_A.z .. " / " .. ability_trapezoid.point_B.x .. "," .. ability_trapezoid.point_B.z .. " / " .. ability_trapezoid.point_C.x .. "," .. ability_trapezoid.point_C.z .. " / " .. ability_trapezoid.point_D.x .. "," .. ability_trapezoid.point_D.z)
	-- lua_table.SystemFunctions:LOG("Real Trapezoid: " .. A_x .. "," .. A_z .. " / " .. B_x .. "," .. B_z .. " / " .. C_x .. "," .. C_z .. " / " .. D_x .. "," .. D_z)

	-- if BidimensionalPointInVectorSide(A_x, A_z, B_x, B_z, geralt_pos_x, geralt_pos_z) < 0	--IF on the left side of all vectors + within the OverlapSphere = inside AoE
	-- and BidimensionalPointInVectorSide(B_x, B_z, C_x, C_z, geralt_pos_x, geralt_pos_z) < 0
	-- and BidimensionalPointInVectorSide(C_x, C_z, D_x, D_z, geralt_pos_x, geralt_pos_z) < 0
	-- and BidimensionalPointInVectorSide(D_x, D_z, A_x, A_z, geralt_pos_x, geralt_pos_z) < 0
	-- --if geralt_pos_x > A_x and geralt_pos_x < B_x and geralt_pos_z > C_z and geralt_pos_z < A_z
	-- then
	-- 	lua_table.SystemFunctions:LOG("TARGET INSIDE")
	-- else
	-- 	lua_table.SystemFunctions:LOG("TARGET OUTSIDE")
	-- end
	-- lua_table.SystemFunctions:LOG("G_x: " .. geralt_pos_x .. ", G_z: " .. geralt_pos_z)
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