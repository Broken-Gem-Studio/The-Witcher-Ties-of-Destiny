local Functions = Debug.Scripting ()

function	GetTableCameraScript ()
local lua_table = {}
lua_table["Functions"] = Debug.Scripting ()

-- Camera position
local camera_position_x = 0
local camera_position_y = 0
local camera_position_z = 0

-- Camera offset (Distance from target)
lua_table["offset_x"] = 0
lua_table["offset_y"] = 0
lua_table["offset_z"] = 0

-- Camera rotation
local camera_rotation_x = 0
local camera_rotation_y = 0
local camera_rotation_z = 0

-- Camera FOV
local fov = 0

-- Camera Target 
local target_position_x = 0
local target_position_y = 0
local target_position_z = 0

-- Players positions
luatable.P1_position -- Can I do this?
P1_position.x 
P1_position.y 
P1_position.z 

local P1_Position_x = 0
local P1_Position_y = 0
local P1_Position_z = 0

local P2_Position_x = 0
local P2_Position_y = 0
local P2_Position_z = 0

local P3_Position_x = 0
local P3_Position_y = 0
local P3_Position_z = 0

local P4_Position_x = 0
local P4_Position_y = 0
local P4_Position_z = 0

-- Camera desired position (target + offset)
lua_table["desired_position_x"] = 0
lua_table["desired_position_y"] = 0
lua_table["desired_position_z"] = 0

-- Smoothing Speed
lua_table["smooth_speed"] = 0

-- Player distance from camera target
lua_table["player_distance_from_camera_target"] = 0 --unused for now

-- Zoom layers
lua_table["zoom"] = {layer1, layer2, layer3}

-- Gameplay Mode
lua_table["gameplay"] = {solo, duo, trio, quartet}

-- Camera state
lua_table["state"] = {static, dynamic}

-- Methods
function Centroid2P (p1, p2) --pseudo
	local c

	c.x = (p1.x + p2.x) / 2 
	c.y = (p1.y + p2.y) / 2
	c.z = (p1.z + p2.z) / 2

	return c
end

function Asymptotic_Average (pos, tpos, speed) --pseudo
	return pos = pos + (tpos - pos)*speed
end

function getTarget()
	if gameplay == solo
	then
		target_pos = P1_pos
	end

	if gameplay == duo
		target_pos = Centroid2P(P1, P2)
	then
	end

	if gameplay == trio
	then
		target_pos = Centroid3P(P1, P2, P3)
	end

	if gameplay == quartet
	then
		target_pos = Centroid4P(P1, P2, P3, P4)
	end
end
-- Main Code
function lua_table:Awake ()
	lua_table["Functions"]:LOG ("This Log was called from Camera Script on AWAKE")
	 
	lua_table["offset_x"] = 0
	lua_table["offset_y"] = 25
	lua_table["offset_z"] = 50

	lua_table["smooth_speed"] = 0.1

	gameplay = solo --for now
end

function lua_table:Start ()
	lua_table["Functions"]:LOG ("This Log was called from Camera Script on START")

	--pseudostart
	getTarget()

	camera_pos = target_pos + offset
	--pseudoend
end

function lua_table:Update ()
	dt = lua_table["Functions"]:dt ()

	--pseudostart
	if gameplay == solo
	then
		target_pos = P1
	if gameplay == duo
	then
		target_pos = Centroid2P(P1,P2)
	end

	desired_pos = target_pos + offset

	camera_pos = Asymptotic_Average(desired_pos, target_pos, smooth_speed)

	lua_table["Functions"]:LookAt(target_pos)
	--pseudoend

	return lua_table
end

-- REFERENCE CODE
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
