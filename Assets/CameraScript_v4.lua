
function	GetTableCameraScript_v4 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.CameraFunctions = Scripting.Camera ()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Absolute Distance from Target
lua_table.camera_distance_layer_1 = 230 
lua_table.camera_distance_layer_2 = 330
lua_table.camera_distance_layer_3 = 550

-- Angle of the camera in degrees (0 Horizontal 90 Vertical)
lua_table.camera_angle = 70

-- Smoothing Speed from (0 to 1)
lua_table.movement_smooth_speed = 0.2
lua_table.zoom_smooth_speed = 0.2

-----------------------------------------------------------------------------------------
-- Camera Variables
-----------------------------------------------------------------------------------------

-- Camera GO UID
lua_table.myUID = 0

-- Camera target GO names
lua_table.geralt_GO = "Geralt"
lua_table.jaskier_GO = "Jaskier"
lua_table.yennefer_GO = "Yennefer"
lua_table.ciri_GO = "Ciri"

-- Camera distance
local current_camera_distance = lua_table.camera_distance_layer_1 -- Should initialize at awake(?)

-- Camera Desired distance (to be compared with current distnace)
local desired_distance = 0

-- Camera position
local camera_position_x = 0
local camera_position_y = 0 
local camera_position_z = 0

-- Camera Desired position (target + offset)
local desired_position_x = 0
local desired_position_y = 0
local desired_position_z = 0

-- Camera Target 
local target_position_x = 0
local target_position_y = 0
local target_position_z = 0

-- Camera Distance Offset 
local offset_a = 0
local offset_b = 0

-- Camera Position Offset 
local offset_x = 0
local offset_y = 0
local offset_z = 0

local camera_angle_for_offset = 0 -- 90-lua_table.camera_angle

-- Camera rotation (z hardcoded for now bc reasons)
local rotation_x = 0 -- 180 - (lua_table.camera_angle) 
local rotation_y = 0 -- If camera ever follows direction this is the one that would need to update
local rotation_z = -180

-- Player distance from camera target (probably won't be used)
local player_distance_from_camera_target = 0 --unused

-- Camera state
local state = -- not in use rn
{
	STATIC = 0, 
	DYNAMIC = 1,
	SWITCHING = 2
}
local current_state = state.DYNAMIC -- Should initialize at awake(?)

-- Zoom layers
local zoom = -- not in use rn
{
	LAYER_1 = 1, 
	LAYER_2 = 2, 
	LAYER_3 = 3
}
local current_zoom_layer = zoom.LAYER_1 -- Shoul initialize at awake(?)

-- FOV ratio for different layers (from 0 to 1) (should always be smaller than 1) (FOV_1 should always be bigger than FOV_2)
lua_table.Layer_1_FOV_ratio_1 = 0.8 
lua_table.Layer_1_FOV_ratio_2 = 0.8

lua_table.Layer_2_FOV_ratio_1 = 0.8 
lua_table.Layer_2_FOV_ratio_2 = 0.55

lua_table.Layer_3_FOV_ratio_1 = 0.85 
lua_table.Layer_3_FOV_ratio_2 = 0.55

-----------------------------------------------------------------------------------------
-- Gameplay Variables
-----------------------------------------------------------------------------------------
-- Gameplay Mode
local gameplay = 
{
	SOLO = 1, 
	DUO = 2, 
	TRIO = 3, 
	QUARTET = 4
}
local current_gameplay = 0 -- Should AUTOMATICALLY initialize at awake (hardcoded right now)

-----------------------------------------------------------------------------------------
-- Player Variables
-----------------------------------------------------------------------------------------

-- P1
local P1_id = 0
lua_table.P1_pos = {}

-- P2
local P2_id = 0
lua_table.P2_pos = {}

-- P3 I still have hope
-- P4 Yeet hopes

-- I use this for visual pleasure (so I can write lua_table.P1_pos[x] instead of lua_table.P1_pos[1])  )
local x = 1
local y = 2
local z = 3

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Get Position Offset from Distance and Angle Methods
function GetAfromDistAndAng(c_distance, c_angle) --given hypotenuse and angle returns contiguous side
	local c_angle_rad
	local c_angle_cos
	local y_dist 

	c_angle_rad = math.rad(c_angle)
	c_angle_cos = math.cos(c_angle_rad)
	y_dist = c_distance*c_angle_cos

	return y_dist
end

function GetBfromDistAndAng(c_distance, c_angle) --given hypotenuse and angle returns opposite side
	local c_angle_rad
	local c_angle_sin
	local x_dist 

	c_angle_rad = math.rad(c_angle)
	c_angle_sin = math.sin(c_angle_rad)
	x_dist = c_distance*c_angle_sin

	return x_dist
end

-- Centroid Methods
function Centroid2P(p1, p2)
	return (p1 + p2) / 2 
end

function Centroid3P(p1, p2, p3)
	return (p1 + p2 + p3) / 3 
end

function Centroid4P(p1, p2, p3, p4)
	return (p1 + p2 + p3 + p4) / 4
end

-- Camera Movement smoothing NEEDS A LIMIT WHERE IT STOPS SMOOTHING
function Asymptotic_Average(pos, target_pos, speed)
	if lua_table.SystemFunctions:CompareFloats(pos, target_pos) == 0
	then
		return pos + (target_pos - pos)*speed
	else
		return target_pos 
	end
end

-- Get gameplay mode method (1,2,3 or players)(Eventually) 
-- function GetCurrentGameplay()

-- Handle Camera Zoom Layers Method
function HandleZoomLayers()
	if current_state ~= state.SWITCHING
	then
		-- 2 Players Handeling
		if current_gameplay == gameplay.DUO 
		then
			-- Layer 1
			if current_zoom_layer == zoom.LAYER_1
			then
				-- When ONE player get out of lua_table.Layer_1_FOV_ratio_1
				if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1 or 
				lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1
				then
					-- Switch up to Layer 2
					current_zoom_layer = zoom.LAYER_2
					current_state = state.SWITCHING
					lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2")
				end

			-- Layer 2
			elseif current_zoom_layer == zoom.LAYER_2
			then
				-- When ALL players get in of lua_table.Layer_2_FOV_ratio_2 
				if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3 and
				lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3
				then
					-- Switch down to Layer 1
					current_zoom_layer = zoom.LAYER_1
					current_state = state.SWITCHING
					lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 1")
					
				-- When ONE player gets out of lua_table.Layer_2_FOV_ratio_1
				elseif lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1 or
				lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1
				 then
					-- Switch up to Layer 3
				 	current_zoom_layer = zoom.LAYER_3
				 	current_state = state.SWITCHING
					 lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 3")
				end

			-- Layer 3
			elseif current_zoom_layer == zoom.LAYER_3
			then
				-- When ALL players get in of lua_table.Layer_3_FOV_ratio_2
				if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3 and
				lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3
				then
					-- Switch down to Layer 2
					current_zoom_layer = zoom.LAYER_2
					current_state = state.SWITCHING
					lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2")

				-- When ONE player gets out of lua_table.Layer_3_FOV_ratio_1
				elseif lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 1 or
				lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 1
				then
					lua_table.SystemFunctions:LOG ("Camera: SHOULD BLOCK PLAYER")
				else
					--lua_table.SystemFunctions:LOG ("Camera: nothing")
				end
			end
		end
		-- 3 Players Handeling
		-- 4 Players Handeling
	end
end

-- Handles Camera Switching between Zoom Layers Method
function HandleSwitch()
	if current_state == state.SWITCHING
	then
		if current_zoom_layer == zoom.LAYER_1
		then
			
			desired_distance = lua_table.camera_distance_layer_1
			current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_smooth_speed) --Smoothens transition
			
			if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1 -- Smoothing eeventually ends (already checked from Asymptotic function)
			then
				current_state = state.DYNAMIC -- Enables Position Checking again
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 1 COMPLETE")
			end
			
		elseif current_zoom_layer == zoom.LAYER_2
		then
			desired_distance = lua_table.camera_distance_layer_2 -- No need to know if switching layers up or down since the layers change immediately even though the state is "SWITCHING"
			current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_smooth_speed)
			
			if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1
			then
				current_state = state.DYNAMIC
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2 COMPLETE")
			end

		elseif current_zoom_layer == zoom.LAYER_3
		then
			desired_distance = lua_table.camera_distance_layer_3
			current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_smooth_speed)
			
			if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1
			then
				current_state = state.DYNAMIC
				-- current_state = state.STATIC
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 3 COMPLETE")
			end
		end
	end
end

-- Handle Target Position Method
function HandleTarget()

	-- 1 Player Target Calculations
	if current_gameplay == gameplay.SOLO
	then
		-- Gets position from Player 1 gameobject Id
		lua_table.P1_pos = lua_table.TransformFunctions:GetPosition(P1_id)

		if lua_table.P1_pos[x] == nil or lua_table.P1_pos[y] == nil or lua_table.P1_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Camera: Player 1 position nil")
		end

		-- Target is P1 position
		target_position_x = lua_table.P1_pos[x]
		target_position_y = lua_table.P1_pos[y]		-- Kind of redundant but organized
		target_position_z = lua_table.P1_pos[z]
	
	-- 2 Players Target Calculations
	elseif current_gameplay == gameplay.DUO
	then
		-- Gets position from Player 1 gameobject Id
		lua_table.P1_pos = lua_table.TransformFunctions:GetPosition(P1_id)
		
		if lua_table.P1_pos[x] == nil or lua_table.P1_pos[y] == nil or lua_table.P1_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Camera: Player 1 position nil")
		end

		-- Gets position from Player 2 gameobject Id 
		lua_table.P2_pos = lua_table.TransformFunctions:GetPosition(P2_id)

		if lua_table.P2_pos[x] == nil or lua_table.P2_pos[y] == nil or lua_table.P2_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Camera: Player 2 position nil")
		end
	
		-- Target is Midpoint between P1 and P2 positions
		target_position_x = Centroid2P(lua_table.P1_pos[x], lua_table.P2_pos[x])
		target_position_y = Centroid2P(lua_table.P1_pos[y], lua_table.P2_pos[y])
		target_position_z = Centroid2P(lua_table.P1_pos[z], lua_table.P2_pos[z])
	end
	-- 3 Players Target Calculations
	-- 4 Players Target Calculations
end

-- Handle Camera Offset Method
function HandleOffset()

	-- Offset from Distance and Angle
	offset_a = GetAfromDistAndAng(current_camera_distance, camera_angle_for_offset)
	offset_b = GetBfromDistAndAng(current_camera_distance, camera_angle_for_offset)
	
	-- offset_x = -- since camera only has a direction for now, only Z is affected. Else the value (offset b) would be split between x and z depending on direction
	offset_y = offset_a  
	offset_z = offset_b -- in case we need the camera to follow the direction too this value would be split with x accordingly
end

-- Handle Camera Movement Method
function HandleMovement()

	-- Camera won't move if is static (3rd layer of zoom for now)
	if current_state ~= state.STATIC 
	then
		--Start 
		if is_start == true
		then
			-- Camera position is Target + Offset
			camera_position_x = target_position_x + offset_x
			camera_position_y = target_position_y + offset_y 	-- Kind of redundant but conceptually organized
			camera_position_z = target_position_z + offset_z
		
		-- Update 
		elseif is_update == true
		then
			-- Desired position is target + offset
			desired_position_x = target_position_x + offset_x
			desired_position_y = target_position_y + offset_y
			desired_position_z = target_position_z + offset_z

			-- Camera position is an averaged position between desired position and self position (the averaging depends on "smooth_speed")
			camera_position_x = Asymptotic_Average(camera_position_x, desired_position_x, lua_table.movement_smooth_speed)
			camera_position_y = Asymptotic_Average(camera_position_y, desired_position_y, lua_table.movement_smooth_speed)
			camera_position_z = Asymptotic_Average(camera_position_z, desired_position_z, lua_table.movement_smooth_speed)
		end

		-- Setting Camera Position
		lua_table.TransformFunctions:SetPosition(camera_position_x, camera_position_y, camera_position_z, lua_table.myUID)
	end
end
-- Handle Zoom layers method

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")

	-- Get my own UID
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()

	-- Gameplay mode (Comment/Uncomment for now until we have a way to manage it automatically)
	-- current_gameplay = gameplay.SOLO
	current_gameplay = gameplay.DUO --Hardcoded af

	if current_gameplay == 0
	then 
		lua_table.SystemFunctions:LOG ("Camera: Gameplay mode set to NULL")

	elseif current_gameplay == gameplay.SOLO
	then
		lua_table.SystemFunctions:LOG ("Camera: Gameplay mode set to SOLO")

		-- Player 1 id
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt_GO)	

		if P1_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Camera: Null Player 1 id, check name of game object inside script")
		else
			lua_table.SystemFunctions:LOG ("Camera: Player 1 id successfully recieved")

			-- Player 1 script (only if successfull id)
			-- lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

			-- if P1_script == NIL
			-- then
			-- 	lua_table.SystemFunctions:LOG ("Camera: Null Player 1 script")
			-- else
			-- 	lua_table.SystemFunctions:LOG ("Camera: Player 1 script successfully recieved")
			-- end
		end

	elseif current_gameplay == gameplay.DUO
	then
		lua_table.SystemFunctions:LOG ("Camera: Gameplay mode set to DUO")
		
		-- Player 1 id
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt_GO)--exact name of gameobject 

		if P1_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Camera: Null Player 1 id, check name of game object inside script")
		else
			lua_table.SystemFunctions:LOG ("Camera: Player 1 id successfully recieved")
			
			-- Player 1 script (only if successfull id)
			-- lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

			-- if lua_table.P1_script == NIL 
			-- then
			-- 	lua_table.SystemFunctions:LOG ("Camera: Null Player 1 script")
			-- else
			-- 	lua_table.SystemFunctions:LOG ("Camera: Player 1 script successfully recieved")
			-- end
		end

		-- Player 2 id
		P2_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO)

		if P2_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Camera: Null Player 2 id, check name of game object inside script")
			
		else
			lua_table.SystemFunctions:LOG ("Camera: Player 2 id successfully recieved")
			
			-- Player 2 script (only if successfull id)
			-- lua_table.P2_script = lua_table.GameObjectFunctions:GetScript(P2_id)

			-- if lua_table.P2_script == NIL 
			-- then
			-- 	lua_table.SystemFunctions:LOG ("Camera: Null Player 2 script")
			-- else
			-- 	lua_table.SystemFunctions:LOG ("Camera: Player 2 script successfully recieved")
			-- end
		end
	end
	 
	camera_angle_for_offset = 90 - lua_table.camera_angle
	rotation_x = 180 - lua_table.camera_angle --because soemthing is wrong with the motor view that is inverted

	-- Debug
	-- Health = lua_table.P1_script.max_health_orig
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on START")
	local is_start = true

	HandleTarget()
	HandleOffset()
	HandleMovement()

	-- LookAt
	-- lua_table["Functions"]:LookAt(target_position_x, 0, 0, false)
	lua_table.TransformFunctions:RotateObject(rotation_x, rotation_y, rotation_z, lua_table.myUID)	

	is_start = false
end

function lua_table:Update ()
	dt = lua_table.SystemFunctions:DT ()
	is_update = true
	
	HandleZoomLayers()
	HandleSwitch()
	HandleTarget()
	HandleOffset()
	HandleMovement()

	-- Debug

	lua_table.SystemFunctions:LOG ("Camera Layer: " .. current_zoom_layer)
	lua_table.SystemFunctions:LOG ("Camera State: " .. current_state)
	
	-- lua_table.SystemFunctions:LOG ("Camera: Max Health is " .. Health)
	-- lua_table.SystemFunctions:LOG ("Camera: Health x5 is " .. Health * 5)
	-- lua_table.SystemFunctions:LOG ("Camera: 1")

	is_update = false
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
