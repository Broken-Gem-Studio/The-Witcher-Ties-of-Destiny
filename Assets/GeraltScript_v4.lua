function	GetTableGeraltScript_v4()
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
local state = {
	dead = -2,
	down = -1,

	idle = 0,
	walk = 1,
	run = 2,

	light_1 = 3,
	light_2 = 4,
	light_3 = 5,

	heavy_1 = 6,
	heavy_2 = 7,
	heavy_3 = 8,

	combo_1 = 9,
	combo_2 = 10,
	combo_3 = 11,
	combo_4 = 12,

	evade = 13,
	ability = 14,
	ultimate = 15,
	item = 16,
	revive = 17
}
local previous_state = state.idle	-- Previous State
local current_state = state.idle	-- Current State

local must_update_stats = false
--Stats
	-- Health
	-- Damage
	-- Speed

	--Vars
		-- _orig: The original value of the character, the baseline value, added manually by design
		-- _mod: The multiplier of the baseline value, the modifier value, always a 0.something
		-- _real: The value used for all calculations, the REAL value, calculated on command and both evaluated and modified with frequency
--

--Health
local current_health = 0

	--Health Stat
	local max_health_real
	local max_health_mod = 1.0
	lua_table.max_health_orig = 500

local health_reg_real
local health_reg_mod = 0.0	-- mod is applied to max_health (reg 10% of your max health)

--Damage
	--Damage Stat
	local base_damage_real
	local base_damage_mod = 1.0
	lua_table.base_damage_orig = 30

local critical_chance_real
local critical_chance_add = 0
lua_table.critical_chance_orig = 0

local critical_damage_real
local critical_damage_add = 0
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
	prev_input_x = 0.0,	--Previous frame Input
	prev_input_z = 0.0,
	
	real_input_x = 0.0,	--Real Input
	real_input_z = 0.0,
	
	used_input_x = 0.0,	--Input used on character
	used_input_z = 0.0
}

local aim_input = {
	prev_input_x = 0.0,	--Previous frame Input
	prev_input_z = 0.0,
	
	real_input_x = 0.0,	--Real Input
	real_input_z = 0.0,
	
	used_input_x = 0.0,	--Input used on character
	used_input_z = 0.0
}

local key_joystick_threshold = 0.25		--As reference, my very fucked up Xbox controller stays at around 2.1 if left IDLE gently (worst), my brand new one stays at 0 no matter what (best)
lua_table.input_walk_threshold = 0.8

--Movement
local rec_direction_x = 0.0	--Used to save a direction when necessary, given by joystick inputs or character rotation
local rec_direction_y = 0.0

local rot_y = 0.0

local mov_speed_x = 0.0
local mov_speed_z = 0.0

	--Speed Stat
	local mov_speed_stat	-- stat = real / 10. Exclusive to speed, as the numeric balancing is dependant on Physics and not only design
	local mov_speed_max_real
	local mov_speed_max_mod = 1.0
	lua_table.mov_speed_max_orig = 5000	--Was 60.0 before dt

lua_table.idle_animation_speed = 30.0
lua_table.walk_animation_speed = 30.0
lua_table.run_animation_speed = 20.0

--Energy
local current_energy = 0
local max_energy_real
local max_energy_mod = 1.0
lua_table.max_energy_orig = 100

local energy_reg_real
local energy_reg_mod = 1.0
lua_table.energy_reg_orig = 10	--This is 5 per second aprox.

--Attacks
local rightside = true								-- Last attack side, marks the animation of next attack

--Light Attack
lua_table.light_attack_damage = 1.0					--Multiplier of Base Damage
lua_table.light_attack_cost = 5

lua_table.light_attack_movement_speed = 1000.0

lua_table.light_attack_1_block_time = 500			--Input block duration	(block new attacks)
lua_table.light_attack_1_combo_start = 600			--Combo timeframe start
lua_table.light_attack_1_combo_end = 900			--Combo timeframe end
lua_table.light_attack_1_duration = 1100			--Attack end (return to idle)
lua_table.light_attack_1_animation_speed = 30.0

lua_table.light_attack_2_block_time = 400			--Input block duration	(block new attacks)
lua_table.light_attack_2_combo_start = 500			--Combo timeframe start
lua_table.light_attack_2_combo_end = 800			--Combo timeframe end
lua_table.light_attack_2_duration = 1000			--Attack end (return to idle)
lua_table.light_attack_2_animation_speed = 30.0

lua_table.light_attack_3_block_time = 500			--Input block duration	(block new attacks)
lua_table.light_attack_3_combo_start = 600			--Combo timeframe start
lua_table.light_attack_3_combo_end = 900			--Combo timeframe end
lua_table.light_attack_3_duration = 1500			--Attack end (return to idle)
lua_table.light_attack_3_animation_speed = 30.0		--IMPROVE: Attack 3 animaton includes a return to idle, which differs from the other animations, we might have to cut it for homogeinity with the rest

--Heavy Attack
lua_table.heavy_attack_damage = 1.666				--Multiplier of Base Damage
lua_table.heavy_attack_cost = 10

lua_table.heavy_attack_movement_speed = 700.0

lua_table.heavy_attack_1_block_time = 900			--Input block duration	(block new attacks)
lua_table.heavy_attack_1_combo_start = 1100			--Combo timeframe start
lua_table.heavy_attack_1_combo_end = 1500			--Combo timeframe end
lua_table.heavy_attack_1_duration = 1600			--Attack end (return to idle)
lua_table.heavy_attack_1_animation_speed = 30.0

lua_table.heavy_attack_2_block_time = 400			--Input block duration	(block new attacks)
lua_table.heavy_attack_2_combo_start = 600			--Combo timeframe start
lua_table.heavy_attack_2_combo_end = 900			--Combo timeframe end
lua_table.heavy_attack_2_duration = 1000			--Attack end (return to idle)
lua_table.heavy_attack_2_animation_speed = 30.0

lua_table.heavy_attack_3_block_time = 800			--Input block duration	(block new attacks)
lua_table.heavy_attack_3_combo_start = 1000			--Combo timeframe start
lua_table.heavy_attack_3_combo_end = 1500			--Combo timeframe end
lua_table.heavy_attack_3_duration = 2200			--Attack end (return to idle)
lua_table.heavy_attack_3_animation_speed = 30.0		--IMPROVE: Attack 3 animaton includes a return to idle, which differs from the other animations, we might have to cut it for homogeinity with the rest

--Evade		
lua_table.evade_velocity = 12500.0	--Was 200 before dt
lua_table.evade_cost = 20
lua_table.evade_duration = 800

lua_table.evade_animation_speed = 40.0

--Ability
lua_table.ability_cost = 30
lua_table.ability_cooldown = 5000.0
lua_table.ability_duration = 800.0
lua_table.ability_push_velocity = 10000

local ability_started_at = 0.0
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
local current_ultimate = 0.0
local max_ultimate = 100.0

local ultimate_reg_real
local ultimate_reg_mod = 1.0
lua_table.ultimate_reg_orig = 10	--Ideally, 2 or something similar

local ultimate_started_at = 0.0
lua_table.ultimate_duration = 3600
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
lua_table.combo_1_damage = 2.0	--slide + 1 hit
lua_table.combo_1_cost = 25
lua_table.combo_1_duration = 1500
lua_table.combo_1_animation_speed = 35.0
lua_table.combo_1_movement_speed = 4000.0

local combo_2 = { 'L', 'L', 'L', 'H' }	--High Spin
lua_table.combo_2_damage = 2.5	--1 hit		--IMPROVE: 2 hits
lua_table.combo_2_cost = 30
lua_table.combo_2_duration = 1400
lua_table.combo_2_animation_speed = 30.0
lua_table.combo_2_movement_speed = 3000.0

local combo_3 = { 'L', 'H', 'H', 'L' }	--Jump Attack
lua_table.combo_3_damage = 3.0	--1 hit		--IMPROVE: stun
lua_table.combo_3_cost = 40
lua_table.combo_3_duration = 1800
lua_table.combo_3_animation_speed = 30.0
lua_table.combo_3_movement_speed = 3000.0

-- local combo_4 = { 'H', 'H', 'L', 'H' }	--Concussive Blows
-- lua_table.combo_4_duration = 2000
-- lua_table.combo_4_animation_speed = 50.0
-- lua_table.combo_4_movement_speed = 10.0

--Methods: Utility	--IMPROVE: Consider making useful generic methods part of a global script
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

local function BidimensionalRotate(x, y, angle)	--REMEMBER: In 2D it's (x,y), but our 3D space translated into horizontal (ground) 2D it's (z,x). Therefore: 3D (Z,X) to 2D (X,Y)
	local new_x = x * math.cos(angle) - y * math.sin(angle)
	local new_y = x * math.sin(angle) + y * math.cos(angle)

	return new_x, new_y
end

local function BidimensionalPointInVectorSide(vec_x1, vec_y1, vec_x2, vec_y2, point_x, point_y)	--Counter-clockwise: If D > 0, the point is on the right side. If D < 0, the point is on the left side. If D = 0, the point is on the line.
	local D = (vec_x2 - vec_x1) * (point_y - vec_y1) - (point_x - vec_x1) * (vec_y2 - vec_y1);
	return D		
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

--Methods: Specific
local function GoDefaultState()
	previous_state = current_state

	if mov_input.used_input_x ~= 0.0 or mov_input.used_input_z ~= 0.0
	then
		if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input_x ^ 2 + mov_input.used_input_z ^ 2)
		then
			lua_table.AnimationFunctions:PlayAnimation("run", lua_table.run_animation_speed)
			lua_table.AudioFunctions:PlayStepSound()
			current_state = state.run
		else
			lua_table.AnimationFunctions:PlayAnimation("walk", lua_table.walk_animation_speed)
			lua_table.AudioFunctions:PlayStepSound()
			current_state = state.walk
		end
	else
		lua_table.AnimationFunctions:PlayAnimation("idle", lua_table.idle_animation_speed)
		lua_table.AudioFunctions:StopStepSound()
		current_state = state.idle
		lua_table.ParticlesFunctions:DeactivateParticlesEmission()	--IMPROVE: Make particle emission more complex than de/activating
	end

	rightside = true
end

--Methods: Inputs
local function JoystickInputs(key_string, input_table)
	input_table.real_input_x = lua_table.InputFunctions:GetAxisValue(lua_table.player_ID, key_string .. "X", 0.01)	--Get accurate inputs
	input_table.real_input_z = lua_table.InputFunctions:GetAxisValue(lua_table.player_ID, key_string .. "Y", 0.01)

	if input_table.real_input_x == input_table.prev_input_x and input_table.real_input_z == input_table.prev_input_z	--IF both inputs exactly the same as last frame
	and math.abs(input_table.real_input_x) < key_joystick_threshold and math.abs(input_table.real_input_z) < key_joystick_threshold			--and IF  both inputs under joystick threshold
	then
	 	input_table.used_input_x, input_table.used_input_z = 0.0, 0.0	--Set used input as idle (0)
	else
		input_table.used_input_x, input_table.used_input_z = input_table.real_input_x, input_table.real_input_z	--Use real input
	end

	input_table.prev_input_x, input_table.prev_input_z = input_table.real_input_x, input_table.real_input_z	--Record previous real input as current one
end

local function KeyboardInputs()	--Process Debug Keyboard Inputs
	mov_input.used_input_x, mov_input.used_input_z = 0.0, 0.0
	
	if lua_table.InputFunctions:KeyRepeat("D")
	then
		mov_input.used_input_x = 2.0
	elseif lua_table.InputFunctions:KeyRepeat("A")
	then
		mov_input.used_input_x = -2.0
	end
	
	if lua_table.InputFunctions:KeyRepeat("S")
	then
		mov_input.used_input_z = -2.0
	elseif lua_table.InputFunctions:KeyRepeat("W")
	then
		mov_input.used_input_z = 2.0
	end
end

local function SaveDirection()
	if mov_input.used_input_x ~= 0 and mov_input.used_input_z ~= 0	--IF input given, use as direction
	then
		local magnitude = math.sqrt(mov_input.used_input_x ^ 2 + mov_input.used_input_z ^ 2)

		rec_direction_x = mov_input.used_input_x / magnitude
		rec_direction_z = mov_input.used_input_z / magnitude
	else															--IF no input, use Y angle to move FORWARD
		----------------------------------------------
		--NOTE: This a more step-by-step of the line below
		--rot_y = lua_table.TransformFunctions:GetRotationY()	--Used to move the character FORWARD, velocity applied later on Update()
		--rot_y = GimbalLockWorkaroundY(rot_y)
		--rot_y = math.rad(rot_y)
		----------------------------------------------

		rot_y = math.rad(GimbalLockWorkaroundY(lua_table.TransformFunctions:GetRotationY()))	--TODO: Remove GimbalLock stage when Euler bug is fixed

		rec_direction_x = math.sin(rot_y)
		rec_direction_z = math.cos(rot_y)
	end
end

local function MovementInputs()	--Process Movement Inputs
	if mov_input.used_input_x ~= 0.0 or mov_input.used_input_z ~= 0.0														--IF Movement Input
	then
		if current_state == state.idle																--IF Idle
		then
			previous_state = current_state

			if lua_table.input_walk_threshold < math.sqrt(mov_input.used_input_x ^ 2 + mov_input.used_input_z ^ 2)		--IF great input
			then
				lua_table.AnimationFunctions:PlayAnimation("run", lua_table.run_animation_speed)
				lua_table.AudioFunctions:PlayStepSound()
				current_state = state.run
			else																					--IF small input
				lua_table.AnimationFunctions:PlayAnimation("walk", lua_table.walk_animation_speed)
				lua_table.AudioFunctions:PlayStepSound()
				current_state = state.walk
			end
		elseif current_state == state.walk and lua_table.input_walk_threshold < math.sqrt(mov_input.used_input_x ^ 2 + mov_input.used_input_z ^ 2)	--IF walking and big input
		then
			lua_table.AnimationFunctions:PlayAnimation("run", lua_table.run_animation_speed)
			lua_table.AudioFunctions:PlayStepSound()
			previous_state = current_state
			current_state = state.run
		elseif current_state == state.run and lua_table.input_walk_threshold > math.sqrt(mov_input.used_input_x ^ 2 + mov_input.used_input_z ^ 2)	--IF running and small input
		then
			lua_table.AnimationFunctions:PlayAnimation("walk", lua_table.walk_animation_speed)
			lua_table.AudioFunctions:PlayStepSound()
			previous_state = current_state
			current_state = state.walk
		end

		lua_table.ParticlesFunctions:ActivateParticlesEmission()

		mov_speed_x = mov_speed_max_real * mov_input.used_input_x	--Joystick input directly translates to speed, no acceleration
		mov_speed_z = mov_speed_max_real * mov_input.used_input_z

		_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--Set velocity
		lua_table.PhysicsFunctions:SetLinearVelocity(mov_speed_x * dt, mov_speed_y, mov_speed_z * dt)

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to velocity direction
		lua_table.TransformFunctions:LookAt(pos_x + mov_speed_x, pos_y, pos_z + mov_speed_z)

	elseif current_state == state.run or current_state == state.walk
	then
		--Animation to IDLE
		lua_table.AnimationFunctions:PlayAnimation("idle", lua_table.idle_animation_speed)
		lua_table.AudioFunctions:StopStepSound()
		lua_table.ParticlesFunctions:DeactivateParticlesEmission()
		previous_state = current_state
		current_state = state.idle
	end
end

local function CheckCombo()	--Check combo performed	(ATTENTION: This should handle the animation, setting timers, bla bla)
	local string_match = false

	if current_energy > lua_table.combo_1_cost and CompareTables(combo_stack, combo_1)
	then
		current_action_block_time = lua_table.combo_1_duration
		current_action_duration = lua_table.combo_1_duration

		current_energy = current_energy - lua_table.combo_1_cost

		lua_table.AnimationFunctions:PlayAnimation("combo_1", lua_table.combo_1_animation_speed)	--Slide
		--Play Sound

		previous_state = current_state
		current_state = state.combo_1

		string_match = true
	elseif current_energy > lua_table.combo_2_cost and CompareTables(combo_stack, combo_2)
	then
		current_action_block_time = lua_table.combo_2_duration
		current_action_duration = lua_table.combo_2_duration

		current_energy = current_energy - lua_table.combo_2_cost
		
		lua_table.AnimationFunctions:PlayAnimation("combo_2", lua_table.combo_2_animation_speed)	--Spin
		--Play Sound
				
		previous_state = current_state
		current_state = state.combo_2

		string_match = true
	elseif current_energy > lua_table.combo_3_cost and CompareTables(combo_stack, combo_3)
	then
		current_action_block_time = lua_table.combo_3_duration
		current_action_duration = lua_table.combo_3_duration

		current_energy = current_energy - lua_table.combo_3_cost
		
		lua_table.AnimationFunctions:PlayAnimation("combo_3", lua_table.combo_3_animation_speed)	--Jump
		--Play Sound

		previous_state = current_state
		current_state = state.combo_3

		string_match = true
	-- elseif CompareTables(combo_stack, combo_4)
	-- then
	-- 	current_action_block_time = lua_table.combo_4_duration
	-- 	current_action_duration = lua_table.combo_4_duration

	-- 	lua_table.AnimationFunctions:PlayAnimation("combo_4", lua_table.combo_4_animation_speed)	--Blows
	-- 	--Play Sound
		
	-- 	previous_state = current_state
	-- 	current_state = state.combo_4

	-- 	string_match = true
	end

	return string_match
end

local function TimedAttack(attack_cost)
	local combo_achieved = false

	if current_state <= state.run		--IF Idle or Moving
	then
		combo_num = 1					--Register combo start
		current_energy = current_energy - attack_cost

	elseif current_state == state.light_1 and time_since_action > lua_table.light_attack_1_combo_start and time_since_action < lua_table.light_attack_1_combo_end
	or current_state == state.light_2 and time_since_action > lua_table.light_attack_2_combo_start and time_since_action < lua_table.light_attack_2_combo_end
	or current_state == state.light_3 and time_since_action > lua_table.light_attack_3_combo_start and time_since_action < lua_table.light_attack_3_combo_end
	or current_state == state.heavy_1 and time_since_action > lua_table.heavy_attack_1_combo_start and time_since_action < lua_table.heavy_attack_1_combo_end
	or current_state == state.heavy_2 and time_since_action > lua_table.heavy_attack_2_combo_start and time_since_action < lua_table.heavy_attack_2_combo_end
	or current_state == state.heavy_3 and time_since_action > lua_table.heavy_attack_3_combo_start and time_since_action < lua_table.heavy_attack_3_combo_end
	then
		combo_num = combo_num + 1
		current_energy = current_energy - attack_cost / lua_table.combo_cost_divider

		if combo_num > 3 then			--IF 4+ goods attacks
			combo_achieved = CheckCombo()
			if combo_achieved then
				combo_num = 0
			end
		end
	else
		combo_num = 1	--Not good timing since last attack
		current_energy = current_energy - attack_cost
	end

	return combo_achieved
end

local function RegularAttack(attack_type)

	if current_state == state.heavy_3 then	--Heavy_3 animation starts and ends on the right, therefore in this particular case we stay on the right
		rightside = not rightside
	end

	if rightside	--IF rightside
	then
		if combo_num > 2	--IF more than 2 succesful attacks
		then
			current_action_block_time = lua_table[attack_type .. "_attack_3_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_attack_3_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_3", lua_table[attack_type .. "_attack_3_animation_speed"])
			lua_table.AudioFunctions:PlayAttackSound()

			previous_state = current_state
			current_state = state[attack_type .. "_3"]
		else
			current_action_block_time = lua_table[attack_type .. "_attack_1_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_attack_1_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_1", lua_table[attack_type .. "_attack_1_animation_speed"])
			lua_table.AudioFunctions:PlayAttackSound()

			previous_state = current_state
			current_state = state[attack_type .. "_1"]
		end
	else			--IF leftside
		current_action_block_time = lua_table[attack_type .. "_attack_2_block_time"]	--Set duration of input block (no new actions)
		current_action_duration = lua_table[attack_type .. "_attack_2_duration"]		--Set duration of the current action (to return to idle/move)

		lua_table.AnimationFunctions:PlayAnimation(attack_type .. "_2", lua_table[attack_type .. "_attack_2_animation_speed"])
		lua_table.AudioFunctions:PlayAttackSound()

		previous_state = current_state
		current_state = state[attack_type .. "_2"]
	end

	rightside = not rightside
end

local function ActionInputs()	--Process Action Inputs
	local input_given = false
	local combo_achieved = false
	
	if current_energy >= lua_table.light_attack_cost and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_light, key_state.key_down)		--Light Input
	then
		action_started_at = game_time		--Set timer start mark
		PushBack(combo_stack, 'L')			--Add new input to stack

		combo_achieved = TimedAttack(lua_table.light_attack_cost)

		if not combo_achieved	--If no combo was achieved with the input, do the attack normally
		then
			RegularAttack("light")
		end

		SaveDirection()

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to direction
		lua_table.TransformFunctions:LookAt(pos_x + rec_direction_x, pos_y, pos_z + rec_direction_z)

		input_given = true

	elseif current_energy >= lua_table.heavy_attack_cost and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_heavy, key_state.key_down)	--Heavy Input
	then
		action_started_at = game_time		--Set timer start mark
		PushBack(combo_stack, 'H')			--Add new input to stack

		combo_achieved = TimedAttack(lua_table.heavy_attack_cost)

		if not combo_achieved	--If no combo was achieved with the input, do the attack normally
		then
			RegularAttack("heavy")
		end

		SaveDirection()

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to direction
		lua_table.TransformFunctions:LookAt(pos_x + rec_direction_x, pos_y, pos_z + rec_direction_z)

		input_given = true

	elseif current_energy >= lua_table.evade_cost and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_evade, key_state.key_down)	--Evade Input
	then
		action_started_at = game_time							--Set timer start mark
		current_action_block_time = lua_table.evade_duration
		current_action_duration = lua_table.evade_duration

		SaveDirection()

		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()	--Rotate to direction
		lua_table.TransformFunctions:LookAt(pos_x + rec_direction_x, pos_y, pos_z + rec_direction_z)

		--Do Evade
		current_energy = current_energy - lua_table.evade_cost
		lua_table.AnimationFunctions:PlayAnimation("evade", lua_table.evade_animation_speed)
		previous_state = current_state
		current_state = state.evade

		input_given = true
		
	elseif game_time - ability_started_at >= lua_table.ability_cooldown
	and current_energy > lua_table.ability_cost
	and lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_ability, key_state.key_down)	--IF cooldown over and Ability Input
	then
		action_started_at = game_time								--Set timer start mark
		ability_started_at = action_started_at

		current_action_block_time = lua_table.ability_duration
		current_action_duration = lua_table.ability_duration

		--Do Ability
		--1. Collect colliders of all enemies inside a radius
		local geralt_pos_x, geralt_pos_y, geralt_pos_z = lua_table.TransformFunctions:GetPosition()
		-- enemy_list = lua_table.PhysicsFunctions:OverlapSphere(geralt_pos_x, geralt_pos_y, geralt_pos_z, lua_table.ability_range, "enemy", false)

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
				--lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.ability_push_velocity * direction_x / magnitude * dt, 0.0, lua_table.ability_push_velocity * direction_z / magnitude * dt)
				--TODO: Stun enemy
				--TODO: Set Enemy Linear Velocity
			end
		end
		--Finish

		current_energy = current_energy - lua_table.ability_cost
		lua_table.AnimationFunctions:PlayAnimation("ability", lua_table.ability_animation_speed)
		previous_state = current_state
		current_state = state.ability
		input_given = true

	elseif current_ultimate >= max_ultimate
	and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_1, key_state.key_repeat)
	and lua_table.InputFunctions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_2, key_state.key_repeat)	--Ultimate Input
	then
		action_started_at = game_time							--Set timer start mark
		ultimate_started_at = action_started_at

		current_action_block_time = lua_table.ultimate_duration
		current_action_duration = lua_table.ultimate_duration

		--Do Ultimate
		lua_table.AnimationFunctions:PlayAnimation("ultimate", lua_table.ultimate_animation_speed)
		previous_state = current_state
		current_state = state.ultimate
		input_given = true	

	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_use_item, key_state.key_down)	--Object Input
	then
		action_started_at = game_time							--Set timer start mark

		--Do Use_Object
		previous_state = current_state
		current_state = state.item
		input_given = true

	elseif lua_table.InputFunctions:IsGamepadButton(lua_table.player_ID, lua_table.key_interact, key_state.key_down)	--Revive Input
	then
		action_started_at = game_time							--Set timer start mark

		--Do Revive
		previous_state = current_state
		current_state = state.revive
		input_given = true
	end

	if input_given	--TODO: This is trashy, it works for the current particle demonstration but it isn't the functionality we really want at the moment
	then
		lua_table.ParticlesFunctions:ActivateParticlesEmission()
	end

	return input_given
end

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

local function UltimateState(active)
	local ultimate_stat_mod = 1
	if not active then ultimate_stat_mod = -1 end

	health_reg_mod = health_reg_mod + lua_table.ultimate_health_reg_increase * ultimate_stat_mod
	energy_reg_mod = energy_reg_mod + lua_table.ultimate_energy_reg_increase * ultimate_stat_mod
	base_damage_mod = base_damage_mod + lua_table.ultimate_damage_mod_increase * ultimate_stat_mod

	must_update_stats = true

	ultimate_active = active
end

local function CalculateStats()
	--Health
	local max_health_increment = lua_table.max_health_orig * max_health_mod / max_health_real
	max_health_real = max_health_real * max_health_increment
	current_health = current_health * max_health_increment

	health_reg_real = max_health_real * health_reg_mod

	--Damage
	base_damage_real = lua_table.base_damage_orig * base_damage_mod
	critical_chance_real = lua_table.critical_chance_orig + critical_chance_add
	critical_damage_real = lua_table.critical_damage_orig + critical_damage_add

	--Speed
	mov_speed_max_real = lua_table.mov_speed_max_orig * mov_speed_max_mod
	mov_speed_stat = mov_speed_max_real * 0.1

	--Energy
	max_energy_real = lua_table.max_energy_orig * max_energy_mod
	energy_reg_real = lua_table.energy_reg_orig * energy_reg_mod

	--Ultimate
	ultimate_reg_real = lua_table.ultimate_reg_orig * ultimate_reg_mod

	--If current values overflow new maximums, limit them
	if current_health > max_health_real then current_health = max_health_real end
	if current_energy > max_energy_real then current_energy = max_energy_real end
end

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
	lua_table.SystemFunctions:LOG("This Log was called from LUA testing a table on AWAKE")
	
	--lua_table.ability_angle = math.rad(lua_table.ability_angle)

	max_health_real = lua_table.max_health_orig	--Necessary for the first CalculateStats()
	CalculateStats()	--Calculate stats based on orig values + modifier

	--Set initial values
	current_health = max_health_real
	current_energy = max_energy_real
	current_ultimate = 0.0

	CalculateAbilityTrapezoid()
end

function lua_table:Start()
    lua_table.SystemFunctions:LOG("This Log was called from LUA testing a table on START")
end

function lua_table:Update()

	dt = lua_table.SystemFunctions:DT()
	game_time = PerfGameTime()

	if must_update_stats then CalculateStats() end

	if current_state >= state.idle	--IF alive
	then
		if current_health <= 0
		then
			--Animation to DEATH
			--lua_table.PhysicsFunctions:SetVelocity(0.0, 0.0, 0.0)
			--death_started_at = game_time
			previous_state = current_state
			current_state = state.down

			if ultimate_active then UltimateState(false) end	--If ultimate on, go off
		else
			--DEBUG
			--KeyboardInputs()

			--Joystick Inputs
			JoystickInputs(lua_table.key_move, mov_input)
			JoystickInputs(lua_table.key_aim, aim_input)

			--Health Regeneration
			if health_reg_real > 0	--IF health regen online
			then
				if current_health < max_health_real then current_health = current_health + health_reg_real * dt end	--IF can increase, increase health
				if current_health > max_health_real then current_health = max_health_real end						--IF above max, set to max
			end

			--Energy Regeneration
			if current_energy < max_energy_real then current_energy = current_energy + energy_reg_real * dt end	--IF can increase, increase energy
			if current_energy > max_energy_real then current_energy = max_energy_real end						--IF above max, set to max

			if not ultimate_active	--IF ultimate offline
			then
				--Ultimate Regeneration
				if current_ultimate < max_ultimate then current_ultimate = current_ultimate + ultimate_reg_real * dt end	--IF can increase, increase ultimate
				if current_ultimate > max_ultimate then current_ultimate = max_ultimate end									--IF above max, set to max

			elseif game_time - ultimate_effect_started_at >= lua_table.ultimate_effect_duration	--IF ultimate online and time up!
			then
				UltimateState(false)	--Ultimate turn off (stats back to normal)
			end

			--IF action currently going on, check action timer
			if current_state > state.run
			then
				time_since_action = game_time - action_started_at
			end

			--IF state == idle/move or action_input_block_time has ended (Input-allowed environment)
			if current_state <= state.run or time_since_action > current_action_block_time
			then
				ActionInputs()
			end

			--IF there's no action being performed
			if current_state <= state.run
			then
				MovementInputs()	--Movement orders
				--SecondaryInputs()	--Minor actions with no timer or special animations

			else	--ELSE (action being performed)
				time_since_action = game_time - action_started_at

				if time_since_action > current_action_duration	--IF action duration up
				then
					if current_state == state.ultimate				--IF drinking ultimate potion finished
					then
						UltimateState(true)	--Ultimate turn on (boost stats)

						current_ultimate = 0.0
						ultimate_effect_started_at = game_time
					end

					GoDefaultState()	--Return to move or idle

				elseif current_state == state.evade				--ELSEIF evading
				then
					_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.evade_velocity * rec_direction_x * dt, mov_speed_y, lua_table.evade_velocity * rec_direction_z * dt)	--IMPROVE: Speed set on every frame bad?
				
				elseif current_state == state.light_2 or current_state == state.light_3	--IF Light Attacking
				then
					if not (current_state == state.light_3 and time_since_action > lua_table.light_attack_3_combo_end)	--IF inside return to idle of light_3	--IMPROVE: Maybe just cut the return to idle part?
					then
						_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--TODO: Check if truly needed or remove
						lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.light_attack_movement_speed * rec_direction_x * dt, mov_speed_y, lua_table.light_attack_movement_speed * rec_direction_z * dt)	--IMPROVE: Speed set on every frame bad?
					end
				elseif current_state == state.heavy_1 or current_state == state.heavy_2 or current_state == state.heavy_3	--IF Heavy Attacking
				then
					if not (current_state == state.heavy_3 and time_since_action > lua_table.heavy_attack_3_combo_end)	--IF inside return to idle of heavy_3	--IMPROVE: Maybe just cut the return to idle part?
					then
						_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--TODO: Check if truly needed or remove
						lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.heavy_attack_movement_speed * rec_direction_x * dt, mov_speed_y, lua_table.heavy_attack_movement_speed * rec_direction_z * dt)	--IMPROVE: Speed set on every frame bad?
					end

				elseif current_state == state.combo_1
				then
					_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.combo_1_movement_speed * rec_direction_x * dt, mov_speed_y, lua_table.combo_1_movement_speed * rec_direction_z * dt)	--IMPROVE: Speed set on every frame bad?
					
				elseif current_state == state.combo_2
				then
					_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.combo_2_movement_speed * rec_direction_x * dt, mov_speed_y, lua_table.combo_2_movement_speed * rec_direction_z * dt)	--IMPROVE: Speed set on every frame bad?
					
				elseif current_state == state.combo_3
				then
					_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.combo_3_movement_speed * rec_direction_x * dt, mov_speed_y, lua_table.combo_3_movement_speed * rec_direction_z * dt)	--IMPROVE: Speed set on every frame bad?
					
				-- elseif current_state == state.combo_4
				-- then
					--TODO: Add velocity for combo_1 attacks (I need the GetRotation method)
					--_x, mov_speed_y, _z = lua_table.PhysicsFunctions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.PhysicsFunctions:SetLinearVelocity(lua_table.combo_4_movement_speed * rec_direction_x * dt, mov_speed_y, lua_table.combo_4_movement_speed * rec_direction_z * dt)	--IMPROVE: Speed set on every frame bad?
					
				end
			end
		end
	elseif current_state == state.down	--IF currently down
	then
		if lua_table.being_revived		--IF flag marks that other player is reviving
		then
			if not stopped_death		--IF stop mark hasn't been done yet
			then
				death_stopped_at = game_time			--Mark revival start (for death timer)
				stopped_death = true					--Flag death timer stop
				revive_started_at = death_stopped_at	--Mark revival start (for revival timer)

			elseif game_time - revive_started_at > lua_table.revive_time		--IF revival complete
			then
				current_health = max_health_real / 2	--Get half health
				GoDefaultState()						--Return to move or idle
			end
		else								--IF other player isn't reviving
			if stopped_death				--IF death timer was stopped
			then
				death_started_at = death_started_at + game_time - death_stopped_at	--Resume timer
				stopped_death = false					--Flag timer resuming

			elseif game_time - death_started_at > lua_table.down_time	--IF death timer finished
			then
				previous_state = current_state
				current_state = state.dead			--Kill character
				--lua_table.Functions:Deactivate()	--Disable character
			end
		end
	end

	--DEBUG LOGS
	--lua_table.SystemFunctions:LOG("Delta Time: " .. dt)
	lua_table.SystemFunctions:LOG("State: " .. current_state)
	lua_table.SystemFunctions:LOG("Time passed: " .. time_since_action)
	SaveDirection()
	lua_table.SystemFunctions:LOG("Angle Y: " .. rot_y)
	--lua_table.SystemFunctions:LOG("Ultimate: " .. current_ultimate)
	--lua_table.SystemFunctions:LOG("Combo num: " .. combo_num)
	--lua_table.SystemFunctions:LOG("Combo string: " .. combo_stack[1] .. ", " .. combo_stack[2] .. ", " .. combo_stack[3] .. ", " .. combo_stack[4])
	
	--Stats LOGS
	--lua_table.SystemFunctions:LOG("Health: " .. current_health)
	--lua_table.SystemFunctions:LOG("Energy: " .. current_energy)

	--lua_table.SystemFunctions:LOG("Health Reg: " .. health_reg_real)
	--lua_table.SystemFunctions:LOG("Energy Reg: " .. energy_reg_real)
	--lua_table.SystemFunctions:LOG("Damage: " .. base_damage_real)

	--lua_table.SystemFunctions:LOG("Health Reg Mod: " .. health_reg_mod)
	--lua_table.SystemFunctions:LOG("Energy Reg Mod: " .. energy_reg_mod)
	--lua_table.SystemFunctions:LOG("Damage Mod: " .. base_damage_mod)

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