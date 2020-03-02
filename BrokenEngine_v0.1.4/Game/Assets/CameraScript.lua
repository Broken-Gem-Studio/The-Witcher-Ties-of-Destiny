local Functions = Debug.Scripting ()

function	GetTableCameraScript ()
local lua_table = {}
lua_table["Functions"] = Debug.Scripting ()

-- Camera position
lua_table["camera_position_x"] = 0
lua_table["camera_position_y"] = 0
lua_table["camera_position_z"] = 0

-- Camera offset (Distance from target)
lua_table["offset_x"] = 0
lua_table["offset_y"] = 0
lua_table["offset_z"] = 0

-- Camera rotation (hardcoded for now)
lua_table["rotation_x"] = 0

-- Camera rotation
lua_table["camera_rotation_x"] = 0
lua_table["camera_rotation_y"] = 0
lua_table["camera_rotation_z"] = 0

-- Camera FOV
-- lua_table["fov"] = 0

-- Camera Target 
lua_table["target_position_x"] = 0
lua_table["target_position_y"] = 0
lua_table["target_position_z"] = 0

-- Players Id & Position
lua_table.P1_id = 0
local P1_pos_x = 0
local P1_pos_y = 0
local P1_pos_z = 0

lua_table.P2_id = 0
local P2_pos_x = 0
local P2_pos_y = 0
local P2_pos_z = 0

-- lua_table["P3_id"] = 0
-- lua_table["P3_pos_x"] = 0
-- lua_table["P3_pos_y"] = 0
-- lua_table["P3_pos_z"] = 0

-- lua_table["P4_id"] = 0
-- lua_table["P4_pos_x"] = 0
-- lua_table["P4_pos_y"] = 0
-- lua_table["P4_pos_z"] = 0

-- Camera desired position (target + offset)
lua_table["desired_position_x"] = 0
lua_table["desired_position_y"] = 0
lua_table["desired_position_z"] = 0

-- Smoothing Speed
lua_table["smooth_speed"] = 0

-- Player distance from camera target
lua_table["player_distance_from_camera_target"] = 0 --unused for now

-- Gameplay Mode
local gameplay = 
{
	SOLO = 1, 
	DUO = 2, 
	TRIO = 3, 
	QUARTET = 4
}
local current_gameplay = 0 -- Should AUTOMATICALLY initialize at awake (hardcoded right now)

-- Camera state
local state = 
{
	STATIC = 1, 
	DYNAMIC = 2
}
local current_state = state.DYNAMIC -- Should initialize at awake(?)

-- Zoom layers
local zoom = 
{
	LAYER_1 = 1, 
	LAYER_2 = 2, 
	LAYER_3 = 3
}
local current_zoom = zoom.LAYER_1 -- Shoul initialize at awake(?)

-- Methods
function Centroid2P(p1, p2)
	return (p1 + p2) / 2 
end

function Asymptotic_Average(position, target_position, speed)
	return position + (target_position - position)*speed
end

-- function FindCameraXAngle(y,z)
-- 	local tan
-- 	tan = z/y
-- 	return --inverse tangent or arc tangent
-- end

-- WILL EVENTUALLY NEED A HOW TO ACCES NUMBER OF PLAYERS ACTUALLY PLAYING
-- function getTarget() 
-- 	if gameplay == solo
-- 	then
-- 		target_pos = P1_pos
-- 	end

-- 	if gameplay == duo
-- 		target_pos = Centroid2P(P1, P2)
-- 	then
-- 	end

-- 	if gameplay == trio
-- 	then
-- 		target_pos = Centroid3P(P1, P2, P3)
-- 	end

-- 	if gameplay == quartet
-- 	then
-- 		target_pos = Centroid4P(P1, P2, P3, P4)
-- 	end
-- end

-- Main Code
function lua_table:Awake ()
	lua_table["Functions"]:LOG ("This Log was called from Camera Script on AWAKE")
	 
	lua_table["offset_x"] = 0 -- Should always be 0
	lua_table["offset_y"] = 10
	lua_table["offset_z"] = -10

	lua_table["rotation_x"] = 45

	lua_table["smooth_speed"] = 0.2

	-- Gameplay mode (Comment/Uncomment for now until we have a way to manage it automatically)
	-- current_gameplay = gameplay.SOLO
	current_gameplay = gameplay.DUO

	if current_gameplay == 0
	then 
		lua_table["Functions"]:LOG ("Camera: Gameplay mode set to NULL")

	elseif current_gameplay == gameplay.SOLO
	then
		lua_table["Functions"]:LOG ("Camera: Gameplay mode set to SOLO")

		-- Player 1 id
		lua_table.P1_id= lua_table["Functions"]:FindGameObject("gerardo1")--exact name of gameobject 

		if P1_id == 0 
		then
			lua_table["Functions"]:LOG ("Camera: Null Player 1 id, check name of game object inside script")
		else
			lua_table["Functions"]:LOG ("Camera: Player 1 id successfully recieved")
		end

	elseif current_gameplay == gameplay.DUO
	then
		lua_table["Functions"]:LOG ("Camera: Gameplay mode set to DUO")
		
		-- Player 1 id
		lua_table.P1_id= lua_table["Functions"]:FindGameObject("gerardo1")--exact name of gameobject 

		if P1_id == 0 
		then
			lua_table["Functions"]:LOG ("Camera: Null Player 1 id, check name of game object inside script")
		else
			lua_table["Functions"]:LOG ("Camera: Player 1 id successfully recieved")
		end

		-- Player 2 id
		lua_table.P2_id= lua_table["Functions"]:FindGameObject("gerardo2")--exact name of gameobject 

		if P1_id == 0 
		then
			lua_table["Functions"]:LOG ("Camera: Null Player 1 id, check name of game object inside script")
		else
			lua_table["Functions"]:LOG ("Camera: Player 2 id successfully recieved")
		end
 	end
end

function lua_table:Start ()
	lua_table["Functions"]:LOG ("This Log was called from Camera Script on START")

	-- Single player
	if current_gameplay == gameplay.SOLO
	then
		-- Gets position from Player 1 gameobject Id
		P1_pos_x = lua_table["Functions"]:GetGameObjectPosX(lua_table.P1_id)
		P1_pos_y = lua_table["Functions"]:GetGameObjectPosY(lua_table.P1_id)
		P1_pos_z = lua_table["Functions"]:GetGameObjectPosZ(lua_table.P1_id)

		-- Target is P1 position
		lua_table["target_position_x"] = P1_pos_x
		lua_table["target_position_y"] = P1_pos_y		-- Kind of redundant but conceptually organized
		lua_table["target_position_z"] = P1_pos_z
		
		-- Camera position is Target + Offset
		lua_table["camera_position_x"] = lua_table["target_position_x"] + lua_table["offset_x"]
		lua_table["camera_position_y"] = lua_table["target_position_y"] + lua_table["offset_y"] 	-- Kind of redundant but conceptually organized
		lua_table["camera_position_z"] = lua_table["target_position_z"] + lua_table["offset_z"]

		-- Sets camera position
		lua_table["Functions"]:SetPosition(lua_table["camera_position_x"], lua_table["camera_position_y"], lua_table["camera_position_z"])

		-- LookAt
		-- lua_table["Functions"]:LookAt(lua_table["target_position_x"], 0, 0, false)
		lua_table["Functions"]:RotateObject(lua_table["rotation_x"], 0, 0)	
	
	elseif current_gameplay == gameplay.DUO
	then
		-- Gets position from Player 1 gameobject Id
		P1_pos_x = lua_table["Functions"]:GetGameObjectPosX(lua_table.P1_id)
		P1_pos_y = lua_table["Functions"]:GetGameObjectPosY(lua_table.P1_id)
		P1_pos_z = lua_table["Functions"]:GetGameObjectPosZ(lua_table.P1_id)

		-- Gets position from Player 2 gameobject Id 
		P2_pos_x = lua_table["Functions"]:GetGameObjectPosX(lua_table.P2_id)
		P2_pos_y = lua_table["Functions"]:GetGameObjectPosY(lua_table.P2_id)
		P2_pos_z = lua_table["Functions"]:GetGameObjectPosZ(lua_table.P2_id)

		-- Target is Midpoint between P1 and P2 positions
		lua_table["target_position_x"] = Centroid2P(P1_pos_x, P2_pos_x)
		lua_table["target_position_y"] = Centroid2P(P1_pos_y, P2_pos_y)
		lua_table["target_position_z"] = Centroid2P(P1_pos_z, P2_pos_z)

		-- Camera position is Target + Offset
		lua_table["camera_position_x"] = lua_table["target_position_x"] + lua_table["offset_x"]
		lua_table["camera_position_y"] = lua_table["target_position_y"] + lua_table["offset_y"]
		lua_table["camera_position_z"] = lua_table["target_position_z"] + lua_table["offset_z"]

		lua_table["Functions"]:SetPosition(lua_table["camera_position_x"], lua_table["camera_position_y"], lua_table["camera_position_z"])

		-- LookAt
		-- lua_table["Functions"]:LookAt(lua_table["target_position_x"], 0, 0, false)
		lua_table["Functions"]:RotateObject(lua_table["rotation_x"], 0, 0)		
	
	end
	
end

function lua_table:Update ()
	dt = lua_table["Functions"]:dt ()

	-- Single player
	if current_gameplay == gameplay.SOLO
	then
		-- Updating Player 1 Position from gameobject Id
		P1_pos_x = lua_table["Functions"]:GetGameObjectPosX(lua_table.P1_id)
		P1_pos_y = lua_table["Functions"]:GetGameObjectPosY(lua_table.P1_id)
		P1_pos_z = lua_table["Functions"]:GetGameObjectPosZ(lua_table.P1_id)

		-- Target is P1 position 
		lua_table["target_position_x"] = P1_pos_x
		lua_table["target_position_y"] = P1_pos_y
		lua_table["target_position_z"] = P1_pos_z

		-- Desired position is target + offset
		lua_table["desired_position_x"] = lua_table["target_position_x"] + lua_table["offset_x"]
		lua_table["desired_position_y"] = lua_table["target_position_y"] + lua_table["offset_y"]
		lua_table["desired_position_z"] = lua_table["target_position_z"] + lua_table["offset_z"]

		-- Camera position is an averaged position between desired position and self position (the averaging depends on "smooth_speed")
		lua_table["camera_position_x"] = Asymptotic_Average(lua_table["camera_position_x"], lua_table["desired_position_x"], lua_table["smooth_speed"])
		lua_table["camera_position_y"] = Asymptotic_Average(lua_table["camera_position_y"], lua_table["desired_position_y"], lua_table["smooth_speed"])
		lua_table["camera_position_z"] = Asymptotic_Average(lua_table["camera_position_z"], lua_table["desired_position_z"], lua_table["smooth_speed"])

		-- Setting Position
		lua_table["Functions"]:SetPosition(lua_table["camera_position_x"], lua_table["camera_position_y"], lua_table["camera_position_z"])

		-- LookAt
		-- lua_table["Functions"]:LookAt(lua_table["camera_position_x"] - lua_table["offset_x"], 0, 0, false)		

	elseif current_gameplay == gameplay.DUO
	then
		-- Gets position from Player 1 gameobject Id
		P1_pos_x = lua_table["Functions"]:GetGameObjectPosX(lua_table.P1_id)
		P1_pos_y = lua_table["Functions"]:GetGameObjectPosY(lua_table.P1_id)
		P1_pos_z = lua_table["Functions"]:GetGameObjectPosZ(lua_table.P1_id)

		-- Gets position from Player 2 gameobject Id 
		P2_pos_x = lua_table["Functions"]:GetGameObjectPosX(lua_table.P2_id)
		P2_pos_y = lua_table["Functions"]:GetGameObjectPosY(lua_table.P2_id)
		P2_pos_z = lua_table["Functions"]:GetGameObjectPosZ(lua_table.P2_id)

		-- Target is Midpoint between P1 and P2 positions
		lua_table["target_position_x"] = Centroid2P(P1_pos_x, P2_pos_x)
		lua_table["target_position_y"] = Centroid2P(P1_pos_y, P2_pos_y)
		lua_table["target_position_z"] = Centroid2P(P1_pos_z, P2_pos_z)

		-- Desired position is target + offset
		lua_table["desired_position_x"] = lua_table["target_position_x"] + lua_table["offset_x"]
		lua_table["desired_position_y"] = lua_table["target_position_y"] + lua_table["offset_y"]
		lua_table["desired_position_z"] = lua_table["target_position_z"] + lua_table["offset_z"]

		-- Camera position is an averaged position between desired position and self position (the averaging depends on "smooth_speed")
		lua_table["camera_position_x"] = Asymptotic_Average(lua_table["camera_position_x"], lua_table["desired_position_x"], lua_table["smooth_speed"])
		lua_table["camera_position_y"] = Asymptotic_Average(lua_table["camera_position_y"], lua_table["desired_position_y"], lua_table["smooth_speed"])
		lua_table["camera_position_z"] = Asymptotic_Average(lua_table["camera_position_z"], lua_table["desired_position_z"], lua_table["smooth_speed"])

		-- Setting Position
		lua_table["Functions"]:SetPosition(lua_table["camera_position_x"], lua_table["camera_position_y"], lua_table["camera_position_z"])

		-- LookAt
		-- lua_table["Functions"]:LookAt(lua_table["camera_position_x"] - lua_table["offset_x"], 0, 0, false)		

	end
end
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
