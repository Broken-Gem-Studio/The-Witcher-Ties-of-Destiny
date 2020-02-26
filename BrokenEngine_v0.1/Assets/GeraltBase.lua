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
lua_table.key_ultimate_1 = "Left_Trigger"
lua_table.key_ultimate_2 = "Right_Trigger"

lua_table.key_interact = "Left_Bumper"
lua_table.key_object = "Right_Bumper"

lua_table.key_light = "X"
lua_table.key_heavy = "X"
lua_table.key_evade = "X"
lua_table.key_ability = "X"

lua_table.key_move = "Left_Joystick"
lua_table.key_aim = "Right_Joystick"
lua_table.key_sensibility = 1.0

lua_table.key_notdef1 = "Arrow_Up"
lua_table.key_notdef2 = "Arrow_Left"
lua_table.key_notdef3 = "Arrow_Right"
lua_table.key_notdef4 = "Arrow_Down"

lua_table.key_notdef5 = "Select"
lua_table.key_notdef6 = "Start"

--Movement
local mov_speed_x = 0.0
local mov_speed_y = 500.0
lua_table.mov_speed_max = 500.0
local mov_acc_x = 0.0
local mov_acc_y = 0.0
lua_table.mov_acc_max = 500.0

local rot_speed = 0.0
lua_table.rot_speed_max = 100.0
lua_table.rot_acc_max = 500.0

--Aiming
local aim_x = 0
local aim_y = 0

--Attacks
lua_table.light_attack_damage = 0
lua_table.light_attack_cost = 0
lua_table.light_attack_duration = 0

lua_table.heavy_attack_damage = 0
lua_table.heavy_attack_cost = 0
lua_table.heavy_attack_duration = 0

--Evade
lua_table.evade_cost = 0
lua_table.evade_duration = 0
lua_table.evade_acceleration = 0

--Ability
lua_table.ability_cost = 0
lua_table.ability_duration = 0

--Combos
lua_table.combo_timeframe_start = 10	-- Timeframe start to perform next combo attack (since attack start or duration end?)
lua_table.combo_timeframe_length = 10	-- Timeframe length
local combo_stack = 0					-- Starting at 0, increases by 1 for each attack well timed, starting at 4, each new attack will be checked for a succesful combo. Bad timing or performing a combo resets to 0
local combo_arr = { 0, 0, 0, 0 }				-- Last 4 attacks performed (0=none, 1=light, 2=heavy). Use push_back tactic.
local rightside = true				-- Last attack side, switches on a succesfully timed attack
	
--Methods
function lua_table:Awake ()
end

function lua_table:Start ()
end

function lua_table:Update ()
	dt = lua_table.Functions:dt ()

	mov_input_x, mov_input_y = lua_table.Functions:GetJoystick (lua_table.key_move);
	aim_input_x, aim_input_y = lua_table.Functions:GetJoystick (lua_table.key_aim);

	if current_state ~= state.dead
	then
		if current_state =< state.move
		then
			if mov_input_x ~= 0 | mov_input_y ~= 0
			then
				if current_state == state.idle
				then
					--Animation to MOVE
					current_state = state.move
				end
	
				desired_speed_x = lua_table.mov_speed_max * mov_input_x	--Joystick input decides desired speed
				desired_speed_y = lua_table.mov_speed_max * mov_input_y
	
				lua_table.mov_speed_x = desired_speed_x
				lua_table.mov_speed_y = desired_speed_y
			else if current_state == state.move
			then
				--Animation to IDLE
				current_state = state.idle
			end
		end

		if current_state =< state.move	-- state == idle | move
		then
			if lua_table.Functions:KeyDown (lua_table.key_light)		--Light Input
			then
				--Execute Animation
				--Start timer
				--Register attack to combo_arr
				--Add +1 on stack
				current_state = state.light

			else if lua_table.Functions:KeyDown (lua_table.key_heavy)	--Heavy Input
			then
				--Do Heavy Attack
				current_state = state.heavy

			else if lua_table.Functions:KeyDown (lua_table.key_evade)	--Evade Input
			then
				--Do Evade
				current_state = state.evade

			else if lua_table.Functions:KeyDown (lua_table.key_ability)	--Ability Input
			then
				--Do Ability
				current_state = state.ability

			else if lua_table.Functions:KeyDown (lua_table.key_object)	--Object Input
			then
				--Do Object
				current_state = state.object
		
			end
		end
	end

	-- mov = lua_table.Functions:GetJoystick (lua_table.key_move);
	-- lua_table.aim_x, lua_table.aim_y = lua_table.Functions:GetJoystick (lua_table.key_aim);

	-- if lua_table["Functions"]:KeyRepeat (lua_table["Up"]) then lua_table["Functions"]:Translate (0.0, 0.0, lua_table["Movement Speed"] * dt) lua_table["Functions"]:LOG ("Forward") end
	-- if lua_table["Functions"]:KeyRepeat (lua_table["Rotate Left"]) then lua_table["Functions"]:EulerRotate (0.0, lua_table["Rotation Speed"] * dt, 0.0) lua_table["Functions"]:LOG ("Turn Left") end
	-- if lua_table["Functions"]:KeyRepeat (lua_table["Down"]) then lua_table["Functions"]:Translate (0.0, 0.0, lua_table["Movement Speed"] * -dt) lua_table["Functions"]:LOG ("Backwards") end
	-- if lua_table["Functions"]:KeyRepeat (lua_table["Rotate Right"]) then lua_table["Functions"]:EulerRotate (0.0, lua_table["Rotation Speed"] * -dt, 0.0) lua_table["Functions"]:LOG ("Turn Right") end
end

return lua_table
end