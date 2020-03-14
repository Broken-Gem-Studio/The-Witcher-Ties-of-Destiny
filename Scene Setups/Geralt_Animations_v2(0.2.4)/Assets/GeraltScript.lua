local Functions = Debug.Scripting()

function	GetTableGeraltScript()
local lua_table = {}
lua_table.Functions = Debug.Scripting()

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

--Health
local current_health
local max_health_real
local max_health_mod = 1.0
lua_table.max_health_orig = 100

--Damage
local base_damage_real
local base_damage_mod = 1.0
lua_table.base_damage_orig = 100

local critical_chance_real
local critical_chance_mod = 1.0
lua_table.critical_chance_orig = 5

local critical_damage_real
local critical_damage_mod = 1.0
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
local mov_input_x = 0.0	--Movement Input
local mov_input_z = 0.0

local aim_input_x = 0.0	--Aim Input
local aim_input_z = 0.0

local key_joystick_threshold = 0.1
lua_table.input_walk_threshold = 0.8

--Movement
local mov_speed_x = 0.0
local mov_speed_z = 0.0

local rot_y = 0.0

local mov_speed_max_real
local mov_speed_max_mod = 1.0
lua_table.mov_speed_max_orig = 3000	--Was 60.0 before dt

lua_table.idle_animation_speed = 30.0
lua_table.walk_animation_speed = 30.0
lua_table.run_animation_speed = 20.0

--Energy
local current_energy
local max_energy_real
local max_energy_mod = 1.0
lua_table.max_energy_orig = 100

local energy_reg_real
local energy_reg_mod = 1.0
lua_table.energy_reg_orig = 10	--Ideally, 10 per second or something similar

--Attacks
local rightside = true								-- Last attack side, marks the animation of next attack

--Light Attack
lua_table.light_attack_damage = 0
lua_table.light_attack_cost = 10

lua_table.light_attack_movement_speed = 10.0

lua_table.light_attack_1_block_time = 500			--Input block duration	(block new attacks)
lua_table.light_attack_1_combo_start = 500			--Combo timeframe start
lua_table.light_attack_1_combo_end = 2000			--Combo timeframe end
lua_table.light_attack_1_duration = 2000			--Attack end (return to idle)
lua_table.light_attack_1_animation_speed = 30.0

lua_table.light_attack_2_block_time = 500			--Input block duration	(block new attacks)
lua_table.light_attack_2_combo_start = 500			--Combo timeframe start
lua_table.light_attack_2_combo_end = 2000			--Combo timeframe end
lua_table.light_attack_2_duration = 2000			--Attack end (return to idle)
lua_table.light_attack_2_animation_speed = 30.0

lua_table.light_attack_3_block_time = 500			--Input block duration	(block new attacks)
lua_table.light_attack_3_combo_start = 500			--Combo timeframe start
lua_table.light_attack_3_combo_end = 2000			--Combo timeframe end
lua_table.light_attack_3_duration = 2000			--Attack end (return to idle)
lua_table.light_attack_3_animation_speed = 30.0

--Heavy Attack
lua_table.heavy_attack_damage = 0
lua_table.heavy_attack_cost = 20

lua_table.heavy_attack_movement_speed = 10.0

lua_table.heavy_attack_1_block_time = 500			--Input block duration	(block new attacks)
lua_table.heavy_attack_1_combo_start = 500			--Combo timeframe start
lua_table.heavy_attack_1_combo_end = 2000			--Combo timeframe end
lua_table.heavy_attack_1_duration = 2000			--Attack end (return to idle)
lua_table.heavy_attack_1_animation_speed = 30.0

lua_table.heavy_attack_2_block_time = 500			--Input block duration	(block new attacks)
lua_table.heavy_attack_2_combo_start = 500			--Combo timeframe start
lua_table.heavy_attack_2_combo_end = 2000			--Combo timeframe end
lua_table.heavy_attack_2_duration = 2000			--Attack end (return to idle)
lua_table.heavy_attack_2_animation_speed = 30.0

lua_table.heavy_attack_3_block_time = 500			--Input block duration	(block new attacks)
lua_table.heavy_attack_3_combo_start = 500			--Combo timeframe start
lua_table.heavy_attack_3_combo_end = 2000			--Combo timeframe end
lua_table.heavy_attack_3_duration = 2000			--Attack end (return to idle)
lua_table.heavy_attack_3_animation_speed = 30.0

--Evade		
lua_table.evade_velocity = 10000.0	--Was 200 before dt
lua_table.evade_cost = 20
lua_table.evade_duration = 800

lua_table.evade_animation_speed = 40.0

--Ability
lua_table.ability_push_velocity = 0.0
lua_table.ability_cooldown = 5000.0
lua_table.ability_duration = 2000.0

local ability_started_at = 0.0

lua_table.ability_animation_speed = 30.0

--Ultimate
local current_ultimate = 0.0
local max_ultimate = 100.0

local ultimate_reg_real
local ultimate_reg_mod = 1.0
lua_table.ultimate_reg_orig = 10	--Ideally, 2 or something similar

local ultimate_started_at = 0.0
lua_table.ultimate_duration = 2000
lua_table.ultimate_animation_speed = 35.0

local ultimate_effect_started_at = 0.0
lua_table.ultimate_effect_duration = 10000

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
lua_table.combo_1_duration = 1500
lua_table.combo_1_animation_speed = 35.0
lua_table.combo_1_movement_speed = 10.0

local combo_2 = { 'L', 'L', 'L', 'H' }	--High Spin
lua_table.combo_2_duration = 1400
lua_table.combo_2_animation_speed = 40.0
lua_table.combo_2_movement_speed = 10.0

local combo_3 = { 'L', 'H', 'H', 'L' }	--Jump Attack
lua_table.combo_3_duration = 1800
lua_table.combo_3_animation_speed = 40.0
lua_table.combo_3_movement_speed = 10.0

local combo_4 = { 'H', 'H', 'L', 'H' }	--Concussive Blows
lua_table.combo_4_duration = 2000
lua_table.combo_4_animation_speed = 50.0
lua_table.combo_4_movement_speed = 10.0

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
	return lua_table.Functions:GameTime() * 1000
end

--Methods: Specific
local function GoDefaultState()
	previous_state = current_state

	if mov_input_x ~= 0.0 or mov_input_z ~= 0.0
	then
		if lua_table.input_walk_threshold < math.sqrt(mov_input_x ^ 2 + mov_input_z ^ 2)
		then
			lua_table.Functions:PlayAnimation("run", lua_table.run_animation_speed)
			lua_table.Functions:PlayStepSound()
			current_state = state.run
		else
			lua_table.Functions:PlayAnimation("walk", lua_table.walk_animation_speed)
			lua_table.Functions:PlayStepSound()
			current_state = state.walk
		end
	else
		lua_table.Functions:PlayAnimation("idle", lua_table.idle_animation_speed)
		lua_table.Functions:StopStepSound()
		current_state = state.idle
		lua_table.Functions:DeactivateParticlesEmission()	--IMPROVE: Make particle emission more complex than de/activating
	end

	rightside = true
end

--Methods: Inputs
local function KeyboardInputs()	--Process Debug Keyboard Inputs
	mov_input_x, mov_input_z, aim_input_x, aim_input_z = 0.0		--CARLES TODO
	
	if lua_table.Functions:KeyRepeat("D")
	then
		mov_input_x = 2.0
	elseif lua_table.Functions:KeyRepeat("A")
	then
		mov_input_x = -2.0
	end
	
	if lua_table.Functions:KeyRepeat("S")
	then
		mov_input_z = -2.0
	elseif lua_table.Functions:KeyRepeat("W")
	then
		mov_input_z = 2.0
	end
end

local function MovementInputs()	--Process Movement Inputs
	if mov_input_x ~= 0.0 or mov_input_z ~= 0.0														--IF Movement Input
	then
		if current_state == state.idle																--IF Idle
		then
			previous_state = current_state

			if lua_table.input_walk_threshold < math.sqrt(mov_input_x ^ 2 + mov_input_z ^ 2)		--IF great input
			then
				lua_table.Functions:PlayAnimation("run", lua_table.run_animation_speed)
				lua_table.Functions:PlayStepSound()
				current_state = state.run
			else																					--IF small input
				lua_table.Functions:PlayAnimation("walk", lua_table.walk_animation_speed)
				lua_table.Functions:PlayStepSound()
				current_state = state.walk
			end
		elseif current_state == state.walk and lua_table.input_walk_threshold < math.sqrt(mov_input_x ^ 2 + mov_input_z ^ 2)	--IF walking and big input
		then
			lua_table.Functions:PlayAnimation("run", lua_table.run_animation_speed)
			lua_table.Functions:PlayStepSound()
			previous_state = current_state
			current_state = state.run
		elseif current_state == state.run and lua_table.input_walk_threshold > math.sqrt(mov_input_x ^ 2 + mov_input_z ^ 2)	--IF running and small input
		then
			lua_table.Functions:PlayAnimation("walk", lua_table.walk_animation_speed)
			lua_table.Functions:PlayStepSound()
			previous_state = current_state
			current_state = state.walk
		end

		lua_table.Functions:ActivateParticlesEmission()

		mov_speed_x = mov_speed_max_real * mov_input_x	--Joystick input directly translates to speed, no acceleration
		mov_speed_z = mov_speed_max_real * mov_input_z

		_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--Set velocity
		lua_table.Functions:SetLinearVelocity(mov_speed_x * dt, mov_speed_y, mov_speed_z * dt)

		dir_x, _y, dir_z = lua_table.Functions:GetPosition()	--Rotate to velocity direction

		dir_x = dir_x + mov_speed_x
		dir_z = dir_z + mov_speed_z

		lua_table.Functions:LookAt(dir_x, _y, dir_z)

	elseif current_state == state.run or current_state == state.walk
	then
		--Animation to IDLE
		lua_table.Functions:PlayAnimation("idle", lua_table.idle_animation_speed)
		lua_table.Functions:StopStepSound()
		lua_table.Functions:DeactivateParticlesEmission()
		previous_state = current_state
		current_state = state.idle
	end
end

local function CheckCombo()	--Check combo performed	(ATTENTION: This should handle the animation, setting timers, bla bla)
	local string_match = false

	if CompareTables(combo_stack, combo_1)
	then
		current_action_block_time = lua_table.combo_1_duration
		current_action_duration = lua_table.combo_1_duration

		lua_table.Functions:PlayAnimation("combo_1", lua_table.combo_1_animation_speed)	--Slide
		--Play Sound
		
		previous_state = current_state
		current_state = state.combo_1

		string_match = true
	elseif CompareTables(combo_stack, combo_2)
	then
		current_action_block_time = lua_table.combo_2_duration
		current_action_duration = lua_table.combo_2_duration

		lua_table.Functions:PlayAnimation("combo_2", lua_table.combo_2_animation_speed)	--Spin
		--Play Sound
				
		previous_state = current_state
		current_state = state.combo_2

		string_match = true
	elseif CompareTables(combo_stack, combo_3)
	then
		current_action_block_time = lua_table.combo_3_duration
		current_action_duration = lua_table.combo_3_duration

		lua_table.Functions:PlayAnimation("combo_3", lua_table.combo_3_animation_speed)	--Jump
		--Play Sound

		previous_state = current_state
		current_state = state.combo_3

		string_match = true
	elseif CompareTables(combo_stack, combo_4)
	then
		current_action_block_time = lua_table.combo_4_duration
		current_action_duration = lua_table.combo_4_duration

		lua_table.Functions:PlayAnimation("combo_4", lua_table.combo_4_animation_speed)	--Blows
		--Play Sound
		
		previous_state = current_state
		current_state = state.combo_4

		string_match = true
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
	if rightside	--IF rightside
	then
		if combo_num > 2	--IF more than 2 succesful attacks
		then
			current_action_block_time = lua_table[attack_type .. "_attack_3_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_attack_3_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.Functions:PlayAnimation(attack_type .. "_3", lua_table[attack_type .. "_attack_3_animation_speed"])
			lua_table.Functions:PlayAttackSound()

			previous_state = current_state
			current_state = state[attack_type .. "_3"]
		else
			current_action_block_time = lua_table[attack_type .. "_attack_1_block_time"]	--Set duration of input block (no new actions)
			current_action_duration = lua_table[attack_type .. "_attack_1_duration"]		--Set duration of the current action (to return to idle/move)

			lua_table.Functions:PlayAnimation(attack_type .. "_1", lua_table[attack_type .. "_attack_1_animation_speed"])
			lua_table.Functions:PlayAttackSound()

			previous_state = current_state
			current_state = state[attack_type .. "_1"]
		end
	else			--IF leftside
		current_action_block_time = lua_table[attack_type .. "_attack_2_block_time"]	--Set duration of input block (no new actions)
		current_action_duration = lua_table[attack_type .. "_attack_2_duration"]		--Set duration of the current action (to return to idle/move)

		lua_table.Functions:PlayAnimation(attack_type .. "_2", lua_table[attack_type .. "_attack_2_animation_speed"])
		lua_table.Functions:PlayAttackSound()

		previous_state = current_state
		current_state = state[attack_type .. "_2"]
	end

	rightside = not rightside
end

local function ActionInputs()	--Process Action Inputs
	local input_given = false
	local combo_achieved = false
	
	if current_energy >= lua_table.light_attack_cost and lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_light, key_state.key_down)		--Light Input
	then
		action_started_at = game_time		--Set timer start mark
		PushBack(combo_stack, 'L')			--Add new input to stack

		combo_achieved = TimedAttack(lua_table.light_attack_cost)

		if not combo_achieved	--If no combo was achieved with the input, do the attack normally
		then
			RegularAttack("light")
		end

		--rot_y = lua_table.Functions:GetRotationY()	--Used to move the character FORWARD when performing attacks	--TODO: Uncomment when ready
		input_given = true

	elseif current_energy >= lua_table.heavy_attack_cost and lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_heavy, key_state.key_down)	--Heavy Input
	then
		action_started_at = game_time		--Set timer start mark
		PushBack(combo_stack, 'H')			--Add new input to stack

		combo_achieved = TimedAttack(lua_table.heavy_attack_cost)

		if not combo_achieved	--If no combo was achieved with the input, do the attack normally
		then
			RegularAttack("heavy")
		end

		--rot_y = lua_table.Functions:GetRotationY()	--Used to move the character FORWARD when performing attacks	--TODO: Uncomment when ready
		input_given = true

	elseif current_energy >= lua_table.evade_cost and lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_evade, key_state.key_down)	--Evade Input
	then
		action_started_at = game_time							--Set timer start mark
		current_action_block_time = lua_table.evade_duration
		current_action_duration = lua_table.evade_duration

		--rot_y = lua_table.Functions:GetRotationY()	--TODO: Uncomment when ready
			
		--Do Evade
		current_energy = current_energy - lua_table.evade_cost
		lua_table.Functions:PlayAnimation("evade", lua_table.evade_animation_speed)
		previous_state = current_state
		current_state = state.evade
		input_given = true
		
	elseif game_time - ability_started_at >= lua_table.ability_cooldown and lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_ability, key_state.key_down)	--IF cooldown over and Ability Input
	then
		action_started_at = game_time								--Set timer start mark
		ability_started_at = action_started_at

		current_action_block_time = lua_table.ability_duration
		current_action_duration = lua_table.ability_duration

		--Do Ability
		--1. Collect colliders of all enemies inside a radius
		--2. Discard all colliders that are outside the triangle/arc of effect
		--3. Apply LinearVelocity (lua_table.ability_push_velocity) to enemies which direction depends on their position in reference to Geralt

		lua_table.Functions:PlayAnimation("ability", lua_table.ability_animation_speed)
		previous_state = current_state
		current_state = state.ability
		input_given = true

	elseif current_ultimate >= max_ultimate
	and lua_table.Functions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_1, key_state.key_repeat)
	and lua_table.Functions:IsTriggerState(lua_table.player_ID, lua_table.key_ultimate_2, key_state.key_repeat)	--Ultimate Input
	then
		action_started_at = game_time							--Set timer start mark
		ultimate_started_at = action_started_at

		current_action_block_time = lua_table.ultimate_duration
		current_action_duration = lua_table.ultimate_duration

		--Do Ultimate
		--lua_table.Functions:PlayAnimation("ultimate", lua_table.ultimate_animation_speed)
		previous_state = current_state
		current_state = state.ultimate
		input_given = true	

	elseif lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_use_item, key_state.key_down)	--Object Input
	then
		action_started_at = game_time							--Set timer start mark

		--Do Use_Object
		previous_state = current_state
		current_state = state.item
		input_given = true

	elseif lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_interact, key_state.key_down)	--Revive Input
	then
		action_started_at = game_time							--Set timer start mark

		--Do Revive
		previous_state = current_state
		current_state = state.revive
		input_given = true
	end

	if input_given	--TODO: This is trashy, it works for the current particle demonstration but it isn't the functionality we really want at the moment
	then
		lua_table.Functions:ActivateParticlesEmission()
	end

	return input_given
end

local function SecondaryInputs()	--Process Secondary Inputs
	if lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_pickup_item, key_state.key_down)			--Pickup Item
	then
		--IF consumable (increase counter)
		--ELSEIF gear (replace current gear)
	
	elseif lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_prev_consumable, key_state.key_down)	--Previous Consumable
	then
		--GO TO PREV CONSUMABLE
	
	elseif lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_next_consumable, key_state.key_down)	--Next Consumable
	then
		--GO TO NEXT CONSUMABLE

	elseif lua_table.Functions:IsGamepadButton(lua_table.player_ID, lua_table.key_drop_consumable, key_state.key_down)	--Drop Consumable
	then
		--DROP CURRENT CONSUMABLE
	end
end

--Main Code
function lua_table:Awake()
	lua_table.Functions:LOG("This Log was called from LUA testing a table on AWAKE")

	--Health
	max_health_real = lua_table.max_health_orig * max_health_mod
	current_health = max_health_real

	--Damage
	base_damage_real = lua_table.base_damage_orig * base_damage_mod
	critical_chance_real = lua_table.critical_chance_orig * critical_chance_mod
	critical_damage_real = lua_table.critical_damage_orig * critical_damage_mod

	--Speed
	mov_speed_max_real = lua_table.mov_speed_max_orig * mov_speed_max_mod

	--Energy
	max_energy_real = lua_table.max_energy_orig * max_energy_mod
	energy_reg_real = lua_table.energy_reg_orig * energy_reg_mod
	current_energy = max_energy_real

	--Ultimate
	ultimate_reg_real = lua_table.ultimate_reg_orig * ultimate_reg_mod
	current_ultimate = 0.0
end

function lua_table:Start()
    lua_table.Functions:LOG("This Log was called from LUA testing a table on START")
end

function lua_table:Update()

	dt = lua_table.Functions:dt()
	game_time = PerfGameTime()

	if current_state >= state.idle	--IF alive
	then
		if current_health <= 0
		then
			--Animation to DEATH
			--lua_table.Functions:SetVelocity(0.0, 0.0, 0.0)
			--death_started_at = game_time
			previous_state = current_state
			current_state = state.down
		else
			--DEBUG
			--KeyboardInputs()

			--Joystick Inputs
			mov_input_x = lua_table.Functions:GetAxisValue(lua_table.player_ID, lua_table.key_move .. "X", key_joystick_threshold)
			mov_input_z = lua_table.Functions:GetAxisValue(lua_table.player_ID, lua_table.key_move .. "Y", key_joystick_threshold)

			aim_input_x = lua_table.Functions:GetAxisValue(lua_table.player_ID, lua_table.key_aim .. "X", key_joystick_threshold)
			aim_input_z = lua_table.Functions:GetAxisValue(lua_table.player_ID, lua_table.key_aim .. "Y", key_joystick_threshold)

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
				ultimate_active = false
				--TODO: Ultimate return stats to normal
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
					if current_state == state.ultimate			--IF drinking ultimate potion finished
					then
						ultimate_active = true
						current_ultimate = 0.0
						ultimate_effect_started_at = game_time
						--TODO: Ultimate Boost stats
					end

					GoDefaultState()	--Return to move or idle

				elseif current_state == state.evade				--ELSEIF evading
				then
					--_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.Functions:SetLinearVelocity(lua_table.evade_velocity * math.cos(rot_y) * dt, mov_speed_y, lua_table.evade_velocity * math.sin(rot_y) * dt)	--IMPROVE: Speed set on every frame bad?
				
				elseif current_state == state.light_1 or current_state == state.light_2 or current_state == state.light_3	--IF Light Attacking
				then
					--TODO: Add velocity for light attacks (I need the GetRotation method)
					--_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.Functions:SetLinearVelocity(lua_table.light_attack_movement_speed * math.cos(rot_y) * dt, mov_speed_y, lua_table.light_attack_movement_speed * math.sin(rot_y) * dt)	--IMPROVE: Speed set on every frame bad?
				
				elseif current_state == state.heavy_1 or current_state == state.heavy_2 or current_state == state.heavy_3	--IF Heavy Attacking
				then
					--TODO: Add velocity for heavy attacks (I need the GetRotation method)
					--_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.Functions:SetLinearVelocity(lua_table.heavy_attack_movement_speed * math.cos(rot_y) * dt, mov_speed_y, lua_table.heavy_attack_movement_speed * math.sin(rot_y) * dt)	--IMPROVE: Speed set on every frame bad?
				
				elseif current_state == state.combo_1
				then
					--TODO: Add velocity for combo_1 attacks (I need the GetRotation method)
					--_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.Functions:SetLinearVelocity(lua_table.combo_1_movement_speed * math.cos(rot_y) * dt, mov_speed_y, lua_table.combo_1_movement_speed * math.sin(rot_y) * dt)	--IMPROVE: Speed set on every frame bad?
					
				elseif current_state == state.combo_2
				then
					--TODO: Add velocity for combo_1 attacks (I need the GetRotation method)
					--_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.Functions:SetLinearVelocity(lua_table.combo_2_movement_speed * math.cos(rot_y) * dt, mov_speed_y, lua_table.combo_2_movement_speed * math.sin(rot_y) * dt)	--IMPROVE: Speed set on every frame bad?
					
				elseif current_state == state.combo_3
				then
				--TODO: Add velocity for combo_1 attacks (I need the GetRotation method)
					--_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.Functions:SetLinearVelocity(lua_table.combo_3_movement_speed * math.cos(rot_y) * dt, mov_speed_y, lua_table.combo_3_movement_speed * math.sin(rot_y) * dt)	--IMPROVE: Speed set on every frame bad?
					
				elseif current_state == state.combo_4
				then
					--TODO: Add velocity for combo_1 attacks (I need the GetRotation method)
					--_x, mov_speed_y, _z = lua_table.Functions:GetLinearVelocity()	--TODO: Check if truly needed or remove
					--lua_table.Functions:SetLinearVelocity(lua_table.combo_4_movement_speed * math.cos(rot_y) * dt, mov_speed_y, lua_table.combo_4_movement_speed * math.sin(rot_y) * dt)	--IMPROVE: Speed set on every frame bad?
					
				end
			end
		end
	elseif current_state == state.down	--IF currently down
	then
		if lua_table.being_revived		--IF flag marks that other player is reviving
		then
			if not stopped_death		--IF stop mark hasn't been done yet
			then
				death_stopped_at = game_time				--Mark revival start (for death timer)
				stopped_death = true						--Flag death timer stop
				revive_started_at = death_stopped_at		--Mark revival start (for revival timer)

			elseif game_time - revive_started_at > lua_table.revive_time		--IF revival complete
			then
				current_health = max_health_real / 2	--Get half health
				GoDefaultState()						--Return to move or idle
			end
		else								--IF other player isn't reviving
			if stopped_death				--IF death timer was stopped
			then
				death_started_at = death_started_at + game_time - death_stopped_at	--Resume timer
				stopped_death = false																		--Flag timer resuming

			elseif game_time - death_started_at > lua_table.down_time	--IF death timer finished
			then
				previous_state = current_state
				current_state = state.dead			--Kill character
				--lua_table.Functions:Deactivate()	--Disable character
			end
		end
	end

	--DEBUG LOGS
	lua_table.Functions:LOG("Current state: " .. current_state)
	--lua_table.Functions:LOG("Ultimate: " .. current_ultimate)
	lua_table.Functions:LOG("Combo num: " .. combo_num)
	lua_table.Functions:LOG("Combo string: " .. combo_stack[1] .. ", " .. combo_stack[2] .. ", " .. combo_stack[3] .. ", " .. combo_stack[4])
	lua_table.Functions:LOG("Energy: " .. current_energy)
end

return lua_table
end