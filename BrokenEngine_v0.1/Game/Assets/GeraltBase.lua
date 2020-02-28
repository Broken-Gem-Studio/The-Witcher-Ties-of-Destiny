local Functions = Debug.Scripting ()

function	GetTableGeraltBase ()
local lua_table = {}
lua_table.Functions = Debug.Scripting ()

--State Machine
local state = {
	dead = -1,
	idle = 0,
	move = 1,
	light = 2,
	heavy = 3,
	evade = 4,
	ability = 5,
	ultimate = 6,
	object = 7
}
local current_state = state.idle

--LOCAL: Variable Stats
local current_health = 100.0

--Stats Base (Character default stats)
lua_table.stat_max_health_base = 100
lua_table.stat_damage_base = 100
lua_table.stat_speed_base = 100

--Stats Improved (Stats after modification alterations)
local stat_max_health_alt = 0
local stat_damage_alt = 0
local stat_speed_alt = 0

--Mods: Stats (Multiplier of base Stats)
local stat_health_mod = 1
local stat_damage_mod = 1
local stat_speed_mod = 1

--Mods: Special Effects (Multiplier of stats for effect application)
local regen_bool = false
lua_table.regen_val = 0
local crit_bool = false
lua_table.crit_chance = 0
lua_table.crit_damage = 0

--Controls
local key_state = {
	key_idle = "IDLE",
	key_down = "DOWN",
	key_repeat = "REPEAT",
	key_up = "UP"
}

lua_table.key_ultimate_1 = "AXIS_TRIGGERLEFT"
lua_table.key_ultimate_2 = "AXIS_TRIGGERRIGHT"

lua_table.key_interact = "BUTTON_LEFTSHOULDER"
lua_table.key_object = "BUTTON_RIGHTSHOULDER"

lua_table.key_light = "BUTTON_X"
lua_table.key_heavy = "BUTTON_Y"
lua_table.key_evade = "BUTTON_A"
lua_table.key_ability = "BUTTON_B"

lua_table.key_move = "AXIS_LEFT"
lua_table.key_aim = "AXIS_RIGHT"
lua_table.key_joystick_sensibility = 1.0
local key_joystick_threshold = 0.01

lua_table.key_notdef1 = "BUTTON_DPAD_UP"
lua_table.key_notdef2 = "BUTTON_DPAD_LEFT"
lua_table.key_notdef3 = "BUTTON_DPAD_RIGHT"
lua_table.key_notdef4 = "BUTTON_DPAD_DOWN"

lua_table.key_notdef5 = "BUTTON_BACK"
lua_table.key_notdef6 = "BUTTON_START"

--Movement
local mov_speed_x = 0.0
local mov_speed_y = 0.0
lua_table.mov_speed_max = 50.0
local mov_acc_x = 0.0
local mov_acc_y = 0.0
lua_table.mov_acc_max = 0.0

local rot_speed = 0.0
lua_table.rot_speed_max = 0.0
lua_table.rot_acc_max = 0.0

--Aiming
local aim_x = 0.0
local aim_y = 0.0

--Light Attack
lua_table.light_attack_damage = 0
lua_table.light_attack_cost = 0

lua_table.light_attack_block_time = 400		--Input block duration	(block new attacks)
lua_table.light_attack_combo_start = 600	--Combo timeframe start
lua_table.light_attack_combo_end = 800		--Combo timeframe end
lua_table.light_attack_end_time = 1000		--Attack end (return to idle)

--Heavy Attack
lua_table.heavy_attack_damage = 0
lua_table.heavy_attack_cost = 0

lua_table.heavy_attack_block_time = 400		--Input block duration	(block new attacks)
lua_table.heavy_attack_combo_start = 600	--Combo timeframe start
lua_table.heavy_attack_combo_end = 800		--Combo timeframe end
lua_table.heavy_attack_end_time = 1000		--Attack end (return to idle)

--Evade
lua_table.evade_cost = 0
lua_table.evade_duration = 0
lua_table.evade_acceleration = 0

--Ability
lua_table.ability_cost = 0
lua_table.ability_duration = 0

--Actions
local started_at = 0	--TIMER
local current_action_block_time
local current_action_duration

--Combos
local combo_num = 0						-- Starting at 0, increases by 1 for each attack well timed, starting at 4, each new attack will be checked for a succesful combo. Bad timing or performing a combo resets to 0
local combo_stack = { 'N', 'N', 'N', 'N' }		-- Last 4 attacks performed (0=none, 1=light, 2=heavy). Use push_back tactic.
local rightside = true					-- Last attack side, switches on a succesfully timed attack

--Methods: Short
function PushBack (array, array_size, new_val)	--Pushes back all values and inserts a new one
	for i = 0, array_size - 2, 1
	do
		array[i] = array[i + 1]
	end

	array[array_size - 1] = new_val
end

function FinishAction ()
	if mov_input_x ~= 0.0 or mov_input_y ~= 0.0
	then
		--Animation to MOVE
		current_state = state.move
	else
		--Animation to IDLE
		current_state = state.idle
	end
end

--Methods: Massive
function KeyboardInputs ()	--Process Debug Keyboard Inputs
	mov_input_x = 0.0
	mov_input_y = 0.0
	
	aim_input_x = 0.0
	aim_input_y = 0.0
	
	if lua_table.Functions:KeyRepeat ("D")
	then
		mov_input_x = 2.0
	elseif lua_table.Functions:KeyRepeat ("A")
	then
		mov_input_x = -2.0
	end
	
	if lua_table.Functions:KeyRepeat ("S")
	then
		mov_input_y = 2.0
	elseif lua_table.Functions:KeyRepeat ("W")
	then
		mov_input_y = -2.0
	end
end

function MovementInputs ()	--Process Movement Inputs
	if mov_input_x ~= 0.0 or mov_input_y ~= 0.0
	then
		if current_state == state.idle
		then
			--Animation to MOVE
			current_state = state.move
		end

		desired_speed_x = lua_table.mov_speed_max * mov_input_x	--Joystick input decides desired speed
		desired_speed_y = lua_table.mov_speed_max * mov_input_y

		mov_speed_x = desired_speed_x
		mov_speed_y = desired_speed_y

		--lua_table.Functions:LOG ("SPEED X: " .. mov_speed_x)
		--lua_table.Functions:LOG ("SPEED Y: " .. mov_speed_y)
 
		lua_table.Functions:Translate (-mov_speed_x * dt, 0.0, 0.0)
		lua_table.Functions:Translate (0.0, 0.0, -mov_speed_y * dt)

	elseif current_state == state.move
	then
		--Animation to IDLE
		current_state = state.idle
	end
end

function ActionInputs ()	--Process Action Inputs

	combo_achieved = false

	if lua_table.Functions:IsGamepadButton (1, lua_table.key_light, key_state.key_down)		--Light Input
	then
		--started_at = lua_table.Functions:Time ()						--Set timer start mark
		
		if current_state <= state.move	--IF Idle or Moving
		then
			combo_num = 1				--Register combo start
		elseif current_state == state.light or current_state == state.heavy	--IF previous action was a light or heavy (potential combo)
		then
			if time_since_action > lua_table.light_attack_combo_end			--If too late for combo
			then
				combo_num = 1
			elseif time_since_action > lua_table.light_attack_combo_start	--If inside combo timeframe
			then
				combo_num = combo_num + 1
				if combo_num > 3
				then
					--combo_achieved = CheckCombo ()	--Check combo performed	(ATTENTION: This should handle the animation, combo_num resseting, setting timers, state, bla bla)
				end
			else															--If too early for combo
				combo_num = 1
			end
		end

		if combo_achieved ~= true	--If no combo was achieved with the input, do the attack normally
		then
			current_action_block_time = lua_table.light_attack_block_time	--Set duration of input block (no new actions)
			current_action_duration = lua_table.light_attack_end_time		--Set duration of the current action (to return to idle/move)

			PushBack(combo_stack, 4, 'L')

			--Animation to LIGHT
			current_state = state.light
		end

	elseif lua_table.Functions:IsGamepadButton (1, lua_table.key_heavy, key_state.key_down)	--Heavy Input
	then
		--started_at = lua_table.Functions:Time ()						--Set timer start mark
		
		if current_state <= state.move	--IF Idle or Moving
		then
			combo_num = 1				--Register combo start
		elseif current_state == state.heavy or current_state == state.heavy	--IF previous action was a light or heavy (potential combo)
		then
			if time_since_action > lua_table.heavy_attack_combo_end			--If too late for combo
			then
				combo_num = 1
			elseif time_since_action > lua_table.heavy_attack_combo_start	--If inside combo timeframe
			then
				combo_num = combo_num + 1
				if combo_num > 3
				then
					--combo_achieved = CheckCombo ()	--Check combo performed	(ATTENTION: This should handle the animation, combo_num resseting, setting timers, state, bla bla)
				end
			else															--If too early for combo
				combo_num = 1
			end
		end

		if combo_achieved ~= true	--If no combo was achieved with the input, do the attack normally
		then
			current_action_block_time = lua_table.heavy_attack_block_time	--Set duration of input block (no new actions)
			current_action_duration = lua_table.heavy_attack_end_time		--Set duration of the current action (to return to idle/move)

			PushBack(combo_stack, 4, 'L')

			--Animation to LIGHT
			current_state = state.heavy
		end

	elseif lua_table.Functions:IsGamepadButton (1, lua_table.key_evade, key_state.key_down)	--Evade Input
	then
		--Do Evade
		current_state = state.evade

	elseif lua_table.Functions:IsGamepadButton (1, lua_table.key_ability, key_state.key_down)	--Ability Input
	then
		--Do Ability
		current_state = state.ability

	elseif lua_table.Functions:IsTriggerState (1, lua_table.key_ultimate_1, key_state.key_down) and lua_table.Functions:IsTriggerState (1, lua_table.key_ultimate_2, key_state.key_down)	--Ultimate Input
	then
		--Do Ultimate
		current_state = state.ability

	elseif lua_table.Functions:IsGamepadButton (1, lua_table.key_object, key_state.key_down)	--Object Input
	then
		--Do Object
		current_state = state.object

	end
end

--Main Code
function lua_table:Awake ()
    lua_table.Functions:LOG ("This Log was called from LUA testing a table on AWAKE")
end

function lua_table:Start ()
    lua_table.Functions:LOG ("This Log was called from LUA testing a table on START")
end

function lua_table:Update ()

	dt = lua_table.Functions:dt ()
	if current_state ~= state.dead
	then
		--DEBUG
		--KeyboardInputs ()

		mov_input_x = lua_table.Functions:GetAxisValue(1, lua_table.key_move .. "X", key_joystick_threshold)
		mov_input_y = lua_table.Functions:GetAxisValue(1, lua_table.key_move .. "Y", key_joystick_threshold)

		aim_input_x = lua_table.Functions:GetAxisValue(1, lua_table.key_aim .. "X", key_joystick_threshold)
		aim_input_y = lua_table.Functions:GetAxisValue(1, lua_table.key_aim .. "Y", key_joystick_threshold)

		if current_state > state.move	--This is so <time_since_action> is only calculated only when an action is being performed
		then
			--time_since_action = lua_table.Functions:Time () - started_at
		end

		if current_state <= state.move --or time_since_action > current_action_block_time	--IF state == idle/move or action_input_block_time has ended (Input-allowed environment)
		then
			--ActionInputs ()
		end

		if current_state <= state.move	--IF there's no action inputs given, go for movement inputs
		then
			MovementInputs ()

		else	--ELSE (action being done)
			if time_since_action > current_action_duration	--IF action duration up, finish action and return to move/idle
			then
				FinishAction ()
			end
		end
	end
end

return lua_table
end

-- DÍDAC REFERENCE CODE
-- local Functions = Debug.Scripting ()

-- function	GetTablelua_tabletest ()
-- local lua_table = {}
-- lua_table["position_x"] = 0
-- lua_table["Functions"] = Debug.Scripting ()

-- function lua_table:Awake ()
-- 	lua_table["position_x"] = 30
-- 	lua_table["Functions"]:LOG ("This Log was called from LUA testing a table on AWAKE")
-- end

-- function lua_table:Start ()
-- 	lua_table["Functions"]:LOG ("This Log was called from LUA testing a table on START")
-- end

-- function lua_table:Update ()
	-- dt = lua_table["Functions"]:dt ()

	-- if lua_table["Functions"]:KeyRepeat ("W") then lua_table["Functions"]:Translate (0.0, 0.0, 50.0 * dt) end
	-- if lua_table["Functions"]:KeyRepeat ("A") then lua_table["Functions"]:Translate (50.0 * dt, 0.0 , 0.0) end
	-- if lua_table["Functions"]:KeyRepeat ("S") then lua_table["Functions"]:Translate (0.0, 0.0, -50.0 * dt) end
	-- if lua_table["Functions"]:KeyRepeat ("D") then lua_table["Functions"]:Translate(-50.0 * dt,0.0 , 0.0) end
	-- if lua_table["Functions"]:KeyRepeat ("Q") then lua_table["Functions"]:LOG ("Q is pressed") end
	-- if lua_table["Functions"]:IsGamepadButton(1,"BUTTON_DPAD_LEFT","DOWN") then lua_table["Functions"]:LOG ("Button BACK DOWN") end
	-- if lua_table["Functions"]:IsGamepadButton(2,"BUTTON_A","DOWN") then lua_table["Functions"]:LOG ("PLAYER 2 button A DOWN") end
	
	-- --Testing axis
	-- if lua_table["Functions"]:IsJoystickAxis(1,"AXIS_RIGHTX","POSITIVE_DOWN") then lua_table["Functions"]:LOG ("Joystick Left X POSITIVE Down") end
	-- if lua_table["Functions"]:IsJoystickAxis(1,"AXIS_RIGHTX","NEGATIVE_DOWN") then lua_table["Functions"]:LOG ("Joystick Left X NEGATIVE Down") end
	-- if lua_table["Functions"]:IsJoystickAxis(1,"AXIS_RIGHTY","POSITIVE_DOWN") then lua_table["Functions"]:LOG ("Joystick Left Y POSITIVE Down") end
	-- if lua_table["Functions"]:IsJoystickAxis(1,"AXIS_RIGHTY","NEGATIVE_DOWN") then lua_table["Functions"]:LOG ("Joystick Left Y NEGATIVE Down") end
	
	-- --lua_table["Functions"]:LOG ("Joystick Left X: " .. lua_table["Functions"]:GetAxisValue(1,"AXIS_RIGHTX"))
	-- --lua_table["Functions"]:LOG ("Joystick Left Y: " .. lua_table["Functions"]:GetAxisValue(1,"AXIS_RIGHTY"))
	
	-- if lua_table["Functions"]:IsTriggerState(1,"AXIS_TRIGGERLEFT","DOWN") then lua_table["Functions"]:StopControllerShake(1) end
	-- if lua_table["Functions"]:IsTriggerState(1,"AXIS_TRIGGERRIGHT","DOWN") then lua_table["Functions"]:ShakeController(1,0.3,2000) end
	
	-- lua_table["Functions"]:LOG ("Joystick Left X: " .. lua_table["Functions"]:GetAxisValue(1,"AXIS_LEFTX", 0.3))
	
-- end

-- return lua_table
-- end