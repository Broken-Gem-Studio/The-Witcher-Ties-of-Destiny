function GetTableCameraScript_v11 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.CameraFunctions = Scripting.Camera ()
lua_table.InputFunctions = Scripting.Inputs ()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Absolute Distance from Target
lua_table.camera_distance_layer_1 = 25
lua_table.camera_distance_layer_2 = 35
lua_table.camera_distance_layer_3 = 45

lua_table.bossfight_distance = 45
lua_table.hoardfight_distance = 35
lua_table.creditsfight_distance = 35

-- Angle of the camera in degrees (0 Horizontal 90 Vertical)
-- lua_table.camera_angle = 70

-- Angle for every layer
lua_table.camera_angle_layer_1 = 50
lua_table.camera_angle_layer_2 = 60
lua_table.camera_angle_layer_3 = 70

lua_table.bossfight_angle = 45
lua_table.hoardfight_angle = 50
lua_table.creditsfight_angle = 50

-- Orientation
lua_table.camera_orientation = 0 -- basically = camera_rotation_y

-- not used lol
lua_table.bossfight_orientation = -7.5
lua_table.hoardfight_orientation = 0
lua_table.creditsfight_orientation = 0

-- Smoothing Speed from (from 0 to 1 -- slow to fast)
lua_table.movement_smooth_speed = 0.2

lua_table.zoom_distance_smooth_speed = 0.1
lua_table.zoom_angle_smooth_speed = 0.1
lua_table.orientation_smooth_speed = 0.1

-- Snapping threshold (the closer to 0 the longer the smoothing)
lua_table.asymptotic_average_snapping_threshold = 0.01

-----------------------------------------------------------------------------------------
-- Camera Variables
-----------------------------------------------------------------------------------------

-- Camera Pivot GO UID
local my_UID = 0

-- Camera UID
local camera_UID = 0

-- Camera target GO names
lua_table.camera_GO = "Actual_Camera"

lua_table.geralt_GO = "Geralt"
lua_table.jaskier_GO = "Jaskier"
lua_table.yennefer_GO = "Yennefer"
lua_table.ciri_GO = "Ciri"

lua_table.kikimora_GO = "Kikimora"
lua_table.Hoard_GO = "HoardPivot"

-- Camera distance/angle
local current_camera_distance = lua_table.camera_distance_layer_1 -- Should initialize at awake(?)
local current_camera_angle = lua_table.camera_angle_layer_1 -- Should initialize at awake(?)
local current_camera_angle_for_offset = 0 -- 90-lua_table.current_camera_angle
lua_table.current_camera_orientation = lua_table.camera_orientation

local camera_orientation_rad = 0
local camera_orientation_sin = 0
local camera_orientation_cos = 0

-- Camera Desired distance/angle (to be compared with current distnace/angle)
local desired_distance = 0
local desired_angle = 0
local desired_orientation = 0

-- Camera position
local camera_position_x = 0
local camera_position_y = 0 
local camera_position_z = 0

-- Camera Desired position (target + offset)
local camera_desired_position_x = 0
local camera_desired_position_y = 0
local camera_desired_position_z = 0

-- Target 
lua_table.target_position_x = 0
lua_table.target_position_y = 0
lua_table.target_position_z = 0

-- Camera Distance Offset 
local camera_offset_a = 0
local camera_offset_b = 0

-- Camera Position Offset 
local camera_offset_x = 0
local camera_offset_y = 0
local camera_offset_z = 0

-- Camera rotation (z hardcoded for now bc reasons)
local camera_rotation_x = 0 -- 180 - (current_camera_angle) 
local camera_rotation_y = 0 -- If camera ever follows direction this is the one that would need to update
local camera_rotation_z = -180

-- Player distance from camera target (probably won't be used)
local player_distance_from_camera_target = 0 --unused

-- Camera state
local state = -- not in use rn
{
	STATIC = 0, 
	DYNAMIC = 1,
	SWITCHING = 2,
}
lua_table.current_state = state.DYNAMIC -- Should initialize at awake(?)

-- Level stage 
lua_table.bossfight = false -- Will be true when Kikimora gets inside frustum
lua_table.hoardfight = false
lua_table.creditsfight = false

-- Zoom layers
local zoom = -- not in use rn
{
	LAYER_1 = 1, 
	LAYER_2 = 2, 
    LAYER_3 = 3,
	LAYER_BOSS = 4,
    LAYER_HOARD = 5,
    LAYER_CREDITS = 6,
}
lua_table.current_zoom_layer = zoom.LAYER_1 -- Shoul initialize at awake(?)

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
	NULL = 0,

	SOLO = 1, 
	DUO = 2, 
	TRIO = 3, 
	QUARTET = 4
}
lua_table.current_gameplay = 0 --AUTOMATICALLY initializes at awake (not hardcoded anymore)

-----------------------------------------------------------------------------------------
-- Player Variables
-----------------------------------------------------------------------------------------

-- P1
local P1_id = 0
lua_table.P1_pos = {}
lua_table.P1_script = {}
local P1_dead = false

-- P2
local P2_id = 0
lua_table.P2_pos = {}
lua_table.P2_script = {}
local P2_dead = false

local Kikimora_id = 0
lua_table.Kikimora_pos = {}
lua_table.kikimora_script = {}
local got_pos_once = false -- used so we only use GetPosition() once (since it won't move for now)

local Hoard_id = 0
lua_table.hoard_pos = {}
lua_table.hoard_script = {}

-- P3 I still have hope
-- P4 Yeet hopes

-- I use this for visual pleasure (so I can write lua_table.P1_pos[x] instead of lua_table.P1_pos[1])  )
local x = 1
local y = 2
local z = 3

-- Camera Shake variables
lua_table.camera_shake_duration = 0
lua_table.camera_shake_magnitude = 0
lua_table.camera_shake_activated = false

local shake_active = false
local elapsed_time = 0

local camera_shake_x = 0
local camera_shake_y = 0
local camera_shake_z = 0

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Get Position Offset from Distance and Angle Methods
local function GetAfromDistAndAng(c_distance, c_angle) --given hypotenuse and angle returns contiguous side
	local c_angle_rad
	local c_angle_cos
	local y_dist 

	c_angle_rad = math.rad(c_angle)
	c_angle_cos = math.cos(c_angle_rad)
	y_dist = c_distance*c_angle_cos

	return y_dist
end

local function GetBfromDistAndAng(c_distance, c_angle) --given hypotenuse and angle returns opposite side
	local c_angle_rad
	local c_angle_sin
	local x_dist 

	c_angle_rad = math.rad(c_angle)
	c_angle_sin = math.sin(c_angle_rad)
	x_dist = c_distance*c_angle_sin

	return x_dist
end

-- Centroid Methods
local function Centroid2P(p1, p2)
	return (p1 + p2) / 2 
end

local function Centroid3P(p1, p2, p3)
	return (p1 + p2 + p3) / 3 
end

local function Centroid4P(p1, p2, p3, p4)
	return (p1 + p2 + p3 + p4) / 4
end

-- Camera Movement smoothing NEEDS A LIMIT WHERE IT STOPS SMOOTHING
local function Asymptotic_Average(pos, target_pos, speed)
	local distance = target_pos - pos

	--if lua_table.SystemFunctions:CompareFloats(pos, target_pos) == 0
	if math.abs(distance) > lua_table.asymptotic_average_snapping_threshold
	then
		return pos + (distance) * speed * dt * 50
	else
		return target_pos 
	end
end

local function HandleShake()

	if lua_table.camera_shake_activated == true
	then
		elapsed_time = 0
		lua_table.camera_shake_activated = false

		shake_active = true
	end

	if shake_active == true
	then
		if lua_table.camera_shake_duration > elapsed_time
		then
			camera_shake_x = lua_table.SystemFunctions:RandomNumberInRange(-1,1) * lua_table.camera_shake_magnitude
			camera_shake_y = lua_table.SystemFunctions:RandomNumberInRange(-1,1) * lua_table.camera_shake_magnitude
			camera_shake_z = lua_table.SystemFunctions:RandomNumberInRange(-2,2) * lua_table.camera_shake_magnitude

			elapsed_time = elapsed_time + dt 
		else 
			shake_active = false
			--failsafe to everything

			camera_shake_x = 0
			camera_shake_y = 0
			camera_shake_z = 0

			lua_table.camera_shake_duration = 0
			lua_table.camera_shake_magnitude = 0

			elapsed_time = 1 
		end
	end
end

-- Checks If Boss is inside Frustum
-- local function Checklua_table.bossfight()
-- 	if Kikimora_id ~= 0
-- 	then 
-- 		if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x],lua_table.Kikimora_pos[y],lua_table.Kikimora_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1
-- 		then
-- 			lua_table.bossfight = true
-- 			lua_table.SystemFunctions:LOG ("Camera: lua_table.bossfight")
-- 		end
-- 	end
-- end

-- Handle Camera Zoom Layers Method
local function HandleZoomLayers()
	if lua_table.current_state ~= state.SWITCHING
	then
		-- 1 Player Handeling (only in lua_table.bossfight)
		if lua_table.current_gameplay == gameplay.SOLO
        then
            if lua_table.current_zoom_layer ~= zoom.LAYER_1
            then
                -- Switch up to Layer 1
				lua_table.current_zoom_layer = zoom.LAYER_1
				lua_table.current_state = state.SWITCHING
                lua_table.SystemFunctions:LOG ("Camera: Switching to Layer 1")
			end
			
			if lua_table.hoardfight == true
            then
                if lua_table.current_zoom_layer ~= zoom.LAYER_HOARD
                then 
                    -- Switch up to Layer Boss
					lua_table.current_zoom_layer = zoom.LAYER_HOARD
					lua_table.current_state = state.SWITCHING
                    lua_table.SystemFunctions:LOG ("Camera: Switching to Hoard Layer")
                end
			end

			if lua_table.bossfight == true
            then
                if lua_table.current_zoom_layer ~= zoom.LAYER_BOSS
                then 
                    -- Switch up to Layer Boss
					lua_table.current_zoom_layer = zoom.LAYER_BOSS
					lua_table.current_state = state.SWITCHING
                    lua_table.SystemFunctions:LOG ("Camera: Switching to Boss Layer")
                end
            end

			if lua_table.creditsfight == true
            then
                if lua_table.current_zoom_layer ~= zoom.LAYER_CREDITS
                then 
                    -- Switch up to Layer Boss
					lua_table.current_zoom_layer = zoom.LAYER_CREDITS
					lua_table.current_state = state.SWITCHING
                    lua_table.SystemFunctions:LOG ("Camera: Switching to Boss Layer")
                end
				-- -- Layer 1
				-- if lua_table.current_zoom_layer == zoom.LAYER_1
				-- then
				-- 	-- When ONE player get out of lua_table.Layer_1_FOV_ratio_1
				-- 	if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1 or 
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1
				-- 	then
				-- 		-- Switch up to Layer 2
				-- 		lua_table.current_zoom_layer = zoom.LAYER_2
				-- 		lua_table.current_state = state.SWITCHING
				-- 		lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2")
				-- 	end

				-- -- Layer 2
				-- elseif lua_table.current_zoom_layer == zoom.LAYER_2
				-- then
				-- 	-- When ALL players get in of lua_table.Layer_2_FOV_ratio_2 
				-- 	if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3 and
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3
				-- 	then
				-- 		-- Switch down to Layer 1
				-- 		lua_table.current_zoom_layer = zoom.LAYER_1
				-- 		lua_table.current_state = state.SWITCHING
				-- 		lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 1")
					
				-- 	-- When ONE player gets out of lua_table.Layer_2_FOV_ratio_1
				-- 	elseif lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1 or
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1
				-- 	then
				-- 		-- Switch up to Layer 3
				--  		lua_table.current_zoom_layer = zoom.LAYER_3
				--  		lua_table.current_state = state.SWITCHING
				-- 		 lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 3")
				-- 	end

				-- -- Layer 3
				-- elseif lua_table.current_zoom_layer == zoom.LAYER_3
				-- then
				-- 	-- When ALL players get in of lua_table.Layer_3_FOV_ratio_2
				-- 	if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3 and
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3
				-- 	then
				-- 		-- Switch down to Layer 2
				-- 		lua_table.current_zoom_layer = zoom.LAYER_2
				-- 		lua_table.current_state = state.SWITCHING
				-- 		lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2")

				-- 	-- When ONE player gets out of lua_table.Layer_3_FOV_ratio_1
				-- 	elseif lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 1 or
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 1
				-- 	then
				-- 		lua_table.SystemFunctions:LOG ("Camera: SHOULD BLOCK PLAYER")
				-- 	else
				-- 		--lua_table.SystemFunctions:LOG ("Camera: nothing")
				-- 	end
				-- end
			end
		end

		-- 2 Players Handeling
		if lua_table.current_gameplay == gameplay.DUO 
		then
			if lua_table.bossfight == false and lua_table.hoardfight == false
			then
				-- Layer 1
				if lua_table.current_zoom_layer == zoom.LAYER_1
				then
					-- When ONE player get out of lua_table.Layer_1_FOV_ratio_1
					if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1 or 
					lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1
					then
						-- Switch up to Layer 2
						lua_table.current_zoom_layer = zoom.LAYER_2
						lua_table.current_state = state.SWITCHING
						lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2")
					end

				-- Layer 2
				elseif lua_table.current_zoom_layer == zoom.LAYER_2
				then
					-- When ALL players get in of lua_table.Layer_2_FOV_ratio_2 
					if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3 and
					lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3
					then
						-- Switch down to Layer 1
						lua_table.current_zoom_layer = zoom.LAYER_1
						lua_table.current_state = state.SWITCHING
						lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 1")
					
					-- When ONE player gets out of lua_table.Layer_2_FOV_ratio_1
					elseif lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1 or
					lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1
					then
						-- Switch up to Layer 3
					 	lua_table.current_zoom_layer = zoom.LAYER_3
					 	lua_table.current_state = state.SWITCHING
						lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 3")
					end

				-- Layer 3
				elseif lua_table.current_zoom_layer == zoom.LAYER_3
				then
					-- When ALL players get in of lua_table.Layer_3_FOV_ratio_2
					if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3 and
					lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3
					then
						-- Switch down to Layer 2
						lua_table.current_zoom_layer = zoom.LAYER_2
						lua_table.current_state = state.SWITCHING
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
            elseif lua_table.bossfight == true
            then
                if lua_table.current_zoom_layer ~= zoom.LAYER_BOSS
                then 
                   -- Switch up to Layer Boss
					lua_table.current_zoom_layer = zoom.LAYER_BOSS
					lua_table.current_state = state.SWITCHING
                    lua_table.SystemFunctions:LOG ("Camera: Switching to Boss Layer")
				end

			elseif lua_table.hoardfight == true
            then 
				if lua_table.current_zoom_layer ~= zoom.LAYER_HOARD
				then 
				-- Switch up to Layer Boss
					lua_table.current_zoom_layer = zoom.LAYER_HOARD
					lua_table.current_state = state.SWITCHING
					lua_table.SystemFunctions:LOG ("Camera: Switching to Hoard Layer")
                end

			elseif lua_table.creditsfight == true
            then
                if lua_table.current_zoom_layer ~= zoom.LAYER_CREDITS
                then 
                    -- Switch up to Layer Boss
					lua_table.current_zoom_layer = zoom.LAYER_CREDITS
					lua_table.current_state = state.SWITCHING
                    lua_table.SystemFunctions:LOG ("Camera: Switching to Credits Layer")
                end
				-- -- Layer 1
				-- if lua_table.current_zoom_layer == zoom.LAYER_1
				-- then
				-- 	-- When ONE player get out of lua_table.Layer_1_FOV_ratio_1
				-- 	if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1 or 
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1 or
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_1_FOV_ratio_1, lua_table.Layer_1_FOV_ratio_2) == 1
				-- 	then
				-- 		-- Switch up to Layer 2
				-- 		lua_table.current_zoom_layer = zoom.LAYER_2
				-- 		lua_table.current_state = state.SWITCHING
				-- 		lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2")
				-- 	end

				-- -- Layer 2
				-- elseif lua_table.current_zoom_layer == zoom.LAYER_2
				-- then
				-- 	-- When ALL players get in of lua_table.Layer_2_FOV_ratio_2 
				-- 	if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3 and
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3 and
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 3
				-- 	then
				-- 		-- Switch down to Layer 1
				-- 		lua_table.current_zoom_layer = zoom.LAYER_1
				-- 		lua_table.current_state = state.SWITCHING
				-- 		lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 1")
					
				-- 	-- When ONE player gets out of lua_table.Layer_2_FOV_ratio_1
				-- 	elseif lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1 or
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1 or
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_2_FOV_ratio_1, lua_table.Layer_2_FOV_ratio_2) == 1
				-- 	then
				-- 		-- Switch up to Layer 3
				-- 	 	lua_table.current_zoom_layer = zoom.LAYER_3
				-- 	 	lua_table.current_state = state.SWITCHING
				-- 		lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 3")
				-- 	end

				-- -- Layer 3
				-- elseif lua_table.current_zoom_layer == zoom.LAYER_3
				-- then
				-- 	-- When ALL players get in of lua_table.Layer_3_FOV_ratio_2
				-- 	if lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3 and
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3 and
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 3
				-- 	then
				-- 		-- Switch down to Layer 2
				-- 		lua_table.current_zoom_layer = zoom.LAYER_2
				-- 		lua_table.current_state = state.SWITCHING
				-- 		lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2")

				-- 	-- When ONE player gets out of lua_table.Layer_3_FOV_ratio_1
				-- 	elseif lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P1_pos[x], lua_table.P1_pos[y], lua_table.P1_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 1 or
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.P2_pos[x], lua_table.P2_pos[y], lua_table.P2_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 1 or
				-- 	lua_table.CameraFunctions:GetPositionInFrustum(lua_table.Kikimora_pos[x], lua_table.Kikimora_pos[y], lua_table.Kikimora_pos[z], lua_table.Layer_3_FOV_ratio_1, lua_table.Layer_3_FOV_ratio_2) == 1
				-- 	then
				-- 		lua_table.SystemFunctions:LOG ("Camera: SHOULD BLOCK PLAYER")
				-- 	else
				-- 		--lua_table.SystemFunctions:LOG ("Camera: nothing")
				-- 	end
				-- end
			end
		end
		-- 3 Players Handeling
		-- 4 Players Handeling
	end
end

-- Handles Camera Switching between Zoom Layers Method
local function HandleSwitch()
	if lua_table.current_state == state.SWITCHING
	then
		if lua_table.current_zoom_layer == zoom.LAYER_1
		then
			desired_distance = lua_table.camera_distance_layer_1
            current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_distance_smooth_speed) --Smoothens distance transition
            
            desired_angle = lua_table.camera_angle_layer_1
            current_camera_angle = Asymptotic_Average(current_camera_angle, desired_angle, lua_table.zoom_angle_smooth_speed) --Smoothens angle transition
			
            if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1 
			and lua_table.SystemFunctions:CompareFloats(current_camera_angle, desired_angle) == 1 -- Smoothing eventually ends (already checked from Asymptotic function)
			-- local dis = current_camera_distance - desired_distance
			-- if math.abs(dis) > lua_table.asymptotic_average_snapping_threshold
			then
				lua_table.current_state = state.DYNAMIC -- Enables Position Checking again
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 1 COMPLETE")
            end
			
		elseif lua_table.current_zoom_layer == zoom.LAYER_2
		then
			desired_distance = lua_table.camera_distance_layer_2 -- No need to know if switching layers up or down since the layers change immediately even though the state is "SWITCHING"
            current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_distance_smooth_speed)
            
            desired_angle = lua_table.camera_angle_layer_2
            current_camera_angle = Asymptotic_Average(current_camera_angle, desired_angle, lua_table.zoom_angle_smooth_speed) --Smoothens angle transition
			
            if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1
			and lua_table.SystemFunctions:CompareFloats(current_camera_angle, desired_angle) == 1
			-- local dis = current_camera_distance - desired_distance
			-- if math.abs(dis) > lua_table.asymptotic_average_snapping_threshold
			then
				lua_table.current_state = state.DYNAMIC -- Enables Position Checking again
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 2 COMPLETE")
			end

		elseif lua_table.current_zoom_layer == zoom.LAYER_3
		then
			desired_distance = lua_table.camera_distance_layer_3
            current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_distance_smooth_speed)
            
            desired_angle = lua_table.camera_angle_layer_3
            current_camera_angle = Asymptotic_Average(current_camera_angle, desired_angle, lua_table.zoom_angle_smooth_speed) --Smoothens angle transition
			
            if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1
			and lua_table.SystemFunctions:CompareFloats(current_camera_angle, desired_angle) == 1
			-- local dis = current_camera_distance - desired_distance
			-- if math.abs(dis) > lua_table.asymptotic_average_snapping_threshold
			then
				lua_table.current_state = state.DYNAMIC -- Enables Position Checking again
				-- lua_table.current_state = state.STATIC
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer 3 COMPLETE")
            end
            
        elseif lua_table.current_zoom_layer == zoom.LAYER_BOSS
        then
            desired_distance = lua_table.bossfight_distance
            current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_distance_smooth_speed)
            
            desired_angle = lua_table.bossfight_angle
            current_camera_angle = Asymptotic_Average(current_camera_angle, desired_angle, lua_table.zoom_angle_smooth_speed) --Smoothens angle transition
			
            if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1
			and lua_table.SystemFunctions:CompareFloats(current_camera_angle, desired_angle) == 1
			-- local dis = current_camera_distance - desired_distance
			-- if math.abs(dis) > lua_table.asymptotic_average_snapping_threshold
			then
				lua_table.current_state = state.DYNAMIC -- Enables Position Checking again
				-- lua_table.current_state = state.STATIC
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer BOSS COMPLETE")
			end

		elseif lua_table.current_zoom_layer == zoom.LAYER_HOARD
        then
            desired_distance = lua_table.hoardfight_distance
            current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_distance_smooth_speed)
            
            desired_angle = lua_table.hoardfight_angle
            current_camera_angle = Asymptotic_Average(current_camera_angle, desired_angle, lua_table.zoom_angle_smooth_speed) --Smoothens angle transition
			
            if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1
			and lua_table.SystemFunctions:CompareFloats(current_camera_angle, desired_angle) == 1
			-- local dis = current_camera_distance - desired_distance
			-- if math.abs(dis) > lua_table.asymptotic_average_snapping_threshold
			then
				lua_table.current_state = state.DYNAMIC -- Enables Position Checking again
				-- lua_table.current_state = state.STATIC
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer HOARD COMPLETE")
            end

        elseif lua_table.current_zoom_layer == zoom.LAYER_CREDITS
        then
            desired_distance = lua_table.creditsfight_distance
            current_camera_distance = Asymptotic_Average(current_camera_distance, desired_distance, lua_table.zoom_distance_smooth_speed)
            
            desired_angle = lua_table.creditsfight_angle
            current_camera_angle = Asymptotic_Average(current_camera_angle, desired_angle, lua_table.zoom_angle_smooth_speed) --Smoothens angle transition
			
            if lua_table.SystemFunctions:CompareFloats(current_camera_distance, desired_distance) == 1
			and lua_table.SystemFunctions:CompareFloats(current_camera_angle, desired_angle) == 1
			-- local dis = current_camera_distance - desired_distance
			-- if math.abs(dis) > lua_table.asymptotic_average_snapping_threshold
			then
				lua_table.current_state = state.DYNAMIC -- Enables Position Checking again
				-- lua_table.current_state = state.STATIC
				lua_table.SystemFunctions:LOG ("Camera: Switching to Zoom Layer HOARD COMPLETE")
			end
			
			--lua_table.camera_orientation = lua_table.bossfight_orientation
        end
	end
end

-- Handle Target Position Method
local function HandleTarget()

	-- Kikimora Position
	if Kikimora_id ~= 0
	then
		if lua_table.kikimora_script.awakened == true
		then
			lua_table.bossfight = true
		end
		lua_table.Kikimora_pos = lua_table.TransformFunctions:GetPosition(Kikimora_id)

		if lua_table.Kikimora_pos[x] == nil or lua_table.Kikimora_pos[y] == nil or lua_table.Kikimora_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Camera: Kikimora position nil")
		end
	end

	if Hoard_id ~= 0
	then
		--lua_table.hoard_script = lua_table.GameObjectFunctions:GetScript(Hoard_id)

		lua_table.hoard_pos = lua_table.TransformFunctions:GetPosition(Hoard_id)

		if lua_table.hoard_pos[x] == nil or lua_table.hoard_pos[y] == nil or lua_table.hoard_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Camera: Hoard Pivot position nil")
		end
	end

    if lua_table.creditsfight ~= true
    then
        --Death checkers
        if lua_table.current_gameplay == gameplay.SOLO
        then
            if P2_id == 0 --Truly Solo gameplay
            then
            
                if lua_table.P1_script.current_state == -4 --DEAD
                then
                    lua_table.current_gameplay = gameplay.NULL
                end

            else -- Solo gameplay because was duo but one player died
                if P1_dead == true
                then
                    if lua_table.P1_script.resurrecting == nil -- this is futureproofing
					then
						if lua_table.P1_script.current_state ~= -4 --NOT DEAD (revived)
						then
							lua_table.current_gameplay = gameplay.DUO
						end
					else
						if lua_table.P1_script.current_state ~= -4 and lua_table.P1_script.resurrecting == false--NOT DEAD (revived)
						then
							lua_table.current_gameplay = gameplay.DUO
						end
					end
                elseif P2_dead == true
                then
                    if lua_table.P2_script.resurrecting == nil -- this is futureproofing
					then
						if lua_table.P2_script.current_state ~= -4--NOT DEAD (revived)
						then
							lua_table.current_gameplay = gameplay.DUO
						end
					else
						if lua_table.P2_script.current_state ~= -4 and lua_table.P2_script.resurrecting == false--NOT DEAD (revived)
						then
							lua_table.current_gameplay = gameplay.DUO
						end
					end
                end
            end
        end


        --Death checkers
        if lua_table.current_gameplay == gameplay.DUO
        then
            
            if lua_table.P1_script.current_state == -4 --DEAD
            then
                lua_table.current_gameplay = gameplay.SOLO
                P1_dead = true
            end

            if lua_table.P2_script.current_state == -4 --DEAD
            then
                lua_table.current_gameplay = gameplay.SOLO
                P2_dead = true
            end

            if lua_table.P1_script.current_state == -4 and lua_table.P2_script.current_state == -4
            then
                lua_table.current_gameplay = gameplay.NULL
            end
        end
    else
        lua_table.current_gameplay = gameplay.SOLO
    end


	-- 1 Player Target Calculations
	if lua_table.current_gameplay == gameplay.SOLO
	then
		if P2_id == 0 or P2_dead == true
		then
			-- Gets position from Player 1 gameobject Id
			lua_table.P1_pos = lua_table.TransformFunctions:GetPosition(P1_id)

			if lua_table.P1_pos[x] == nil or lua_table.P1_pos[y] == nil or lua_table.P1_pos[z] == nil
			then
				lua_table.SystemFunctions:LOG ("Camera: Player 1 position nil")
			end

			if lua_table.bossfight == false and lua_table.hoardfight == false and lua_table.creditsfight == false
			then
				-- Target is P1 position
				lua_table.target_position_x = lua_table.P1_pos[x]
				lua_table.target_position_y = lua_table.P1_pos[y]		-- Kind of redundant but organized
				lua_table.target_position_z = lua_table.P1_pos[z]

			elseif lua_table.bossfight == true
			then
				-- Target is Midpoint between P1 and BOSS positions
				lua_table.target_position_x = Centroid2P(lua_table.P1_pos[x], lua_table.Kikimora_pos[x])
				lua_table.target_position_y = Centroid2P(lua_table.P1_pos[y], lua_table.Kikimora_pos[y])
				lua_table.target_position_z = Centroid2P(lua_table.P1_pos[z], lua_table.Kikimora_pos[z])

			elseif lua_table.hoardfight == true
			then
				-- Target is Midpoint between P1 and BOSS positions
				lua_table.target_position_x = Centroid2P(lua_table.P1_pos[x], lua_table.hoard_pos[x])
				lua_table.target_position_y = Centroid2P(lua_table.P1_pos[y], lua_table.hoard_pos[y])
                lua_table.target_position_z = Centroid2P(lua_table.P1_pos[z], lua_table.hoard_pos[z])
                
            elseif lua_table.creditsfight == true
            then
                -- Target is Midpoint between P1 and BOSS positions
				lua_table.target_position_x = lua_table.hoard_pos[x]
				lua_table.target_position_y = lua_table.hoard_pos[y]
                lua_table.target_position_z = lua_table.hoard_pos[z]
			end	

		elseif P2_id ~= 0 and P1_dead == true
		then
			-- Gets position from Player 2 gameobject Id
			lua_table.P2_pos = lua_table.TransformFunctions:GetPosition(P2_id)

			if lua_table.P2_pos[x] == nil or lua_table.P2_pos[y] == nil or lua_table.P2_pos[z] == nil
			then
				lua_table.SystemFunctions:LOG ("Camera: Player 2 position nil")
			end

			if lua_table.bossfight == false
			then
				-- Target is P2 position
				lua_table.target_position_x = lua_table.P2_pos[x]
				lua_table.target_position_y = lua_table.P2_pos[y]		-- Kind of redundant but organized
				lua_table.target_position_z = lua_table.P2_pos[z]

			elseif lua_table.bossfight == true
			then
				-- Target is Midpoint between P1 and BOSS positions
				lua_table.target_position_x = Centroid2P(lua_table.P2_pos[x], lua_table.Kikimora_pos[x])
				lua_table.target_position_y = Centroid2P(lua_table.P2_pos[y], lua_table.Kikimora_pos[y])
				lua_table.target_position_z = Centroid2P(lua_table.P2_pos[z], lua_table.Kikimora_pos[z])

			elseif lua_table.hoardfight == true
			then
				-- Target is Midpoint between P1 and BOSS positions
				lua_table.target_position_x = Centroid2P(lua_table.P2_pos[x], lua_table.hoard_pos[x])
				lua_table.target_position_y = Centroid2P(lua_table.P2_pos[y], lua_table.hoard_pos[y])
                lua_table.target_position_z = Centroid2P(lua_table.P2_pos[z], lua_table.hoard_pos[z])
                
			elseif lua_table.creditsfight == true
            then
                -- Target is Midpoint between P1 and BOSS positions
				lua_table.target_position_x = lua_table.hoard_pos[x]
				lua_table.target_position_y = lua_table.hoard_pos[y]
                lua_table.target_position_z = lua_table.hoard_pos[z]
			end	
		end
	
	-- 2 Players Target Calculations
	elseif lua_table.current_gameplay == gameplay.DUO
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

		if lua_table.bossfight == false
		then
			-- Target is Midpoint between P1 and P2 positions
			lua_table.target_position_x = Centroid2P(lua_table.P1_pos[x], lua_table.P2_pos[x])
			lua_table.target_position_y = Centroid2P(lua_table.P1_pos[y], lua_table.P2_pos[y])
			lua_table.target_position_z = Centroid2P(lua_table.P1_pos[z], lua_table.P2_pos[z])

		elseif lua_table.bossfight == true
		then
			-- Target is Midpoint between P1, P2 and Boss positions
			lua_table.target_position_x = Centroid3P(lua_table.P1_pos[x], lua_table.P2_pos[x], lua_table.Kikimora_pos[x])
			lua_table.target_position_y = Centroid3P(lua_table.P1_pos[y], lua_table.P2_pos[y], lua_table.Kikimora_pos[y])
			lua_table.target_position_z = Centroid3P(lua_table.P1_pos[z], lua_table.P2_pos[z], lua_table.Kikimora_pos[z])

		elseif lua_table.hoardfight == true
		then
			-- Target is Midpoint between P1, P2 and Boss positions
			lua_table.target_position_x = Centroid3P(lua_table.P1_pos[x], lua_table.P2_pos[x], lua_table.hoard_pos[x])
			lua_table.target_position_y = Centroid3P(lua_table.P1_pos[y], lua_table.P2_pos[y], lua_table.hoard_pos[y])
            lua_table.target_position_z = Centroid3P(lua_table.P1_pos[z], lua_table.P2_pos[z], lua_table.hoard_pos[z])
            
		elseif lua_table.creditsfight == true
        then
            -- Target is Midpoint between P1 and BOSS positions
            lua_table.target_position_x = lua_table.hoard_pos[x]
            lua_table.target_position_y = lua_table.hoard_pos[y]
            lua_table.target_position_z = lua_table.hoard_pos[z]
        end		
	end
	-- 3 Players Target Calculations
	-- 4 Players Target Calculations
end

-- Handle Camera Offset Method
local function HandleOffset()

	current_camera_angle_for_offset = 90 - current_camera_angle

	-- Camera Offset from Distance and Angle
	camera_offset_a = GetAfromDistAndAng(current_camera_distance, current_camera_angle_for_offset)
	camera_offset_b = GetBfromDistAndAng(current_camera_distance, current_camera_angle_for_offset)

	-- Updating values every frame so it can be changed via Map Areas
	desired_orientation = lua_table.camera_orientation
	lua_table.current_camera_orientation = Asymptotic_Average(lua_table.current_camera_orientation, desired_orientation, lua_table.orientation_smooth_speed) --Smoothens angle transition
	
	-- Offset Calculations for Camera
    camera_orientation_rad = math.rad(lua_table.current_camera_orientation)
    camera_orientation_sin = math.sin(camera_orientation_rad)
    camera_orientation_cos = math.cos(camera_orientation_rad)
	
	camera_offset_x = camera_offset_b * camera_orientation_sin
	camera_offset_y = camera_offset_a  
	camera_offset_z = camera_offset_b * camera_orientation_cos
    
    -- to support changes in the angle we must update the camera_rotation_x aswell so it keeps the orientation to the target
	camera_rotation_x = 180 - current_camera_angle

    -- Rotation of the Actual camera (Here we add the rotation shake (only z) too)
	lua_table.TransformFunctions:SetObjectRotation(camera_rotation_x, camera_rotation_y, camera_rotation_z + camera_shake_z, camera_UID)
    
    -- Rotation of the Pivot (supports the orientation)
	lua_table.TransformFunctions:SetObjectRotation(0, lua_table.current_camera_orientation, 0, my_UID)
	
end

-- Handle Camera Movement Method
local function HandleMovement()

	-- Camera won't move if is static (3rd layer of zoom for now)
	if lua_table.current_state ~= state.STATIC 
	then
		--Start 
		if is_start == true
		then
			-- Camera position is Target + Offset
			camera_position_x = lua_table.target_position_x + camera_offset_x 
			camera_position_y = lua_table.target_position_y + camera_offset_y 	-- Kind of redundant but conceptually organized
			camera_position_z = lua_table.target_position_z + camera_offset_z
		
		-- Update 
		elseif is_update == true
		then
			-- Desired position is target + offset

			-- Camera Desired Position
			camera_desired_position_x = lua_table.target_position_x + camera_offset_x
			camera_desired_position_y = lua_table.target_position_y + camera_offset_y
			camera_desired_position_z = lua_table.target_position_z + camera_offset_z

			-- Camera position is an averaged position between desired position and self position (the averaging depends on "smooth_speed")
			camera_position_x = Asymptotic_Average(camera_position_x, camera_desired_position_x, lua_table.movement_smooth_speed)
			camera_position_y = Asymptotic_Average(camera_position_y, camera_desired_position_y, lua_table.movement_smooth_speed)
            camera_position_z = Asymptotic_Average(camera_position_z, camera_desired_position_z, lua_table.movement_smooth_speed)
            
		end

		-- Setting Camera Position
		lua_table.TransformFunctions:SetPosition(camera_position_x + camera_shake_x, camera_position_y + camera_shake_y, camera_position_z, my_UID)
	end
end

local function DebugInputs()
	if lua_table.InputFunctions:KeyRepeat("Left Ctrl") 
	then
		if lua_table.InputFunctions:KeyDown("n")
		then
			lua_table.camera_orientation = lua_table.camera_orientation - 5
        end

        if lua_table.InputFunctions:KeyDown("m")
		then 
			lua_table.camera_orientation = lua_table.camera_orientation + 5
		end
		
		if lua_table.InputFunctions:KeyDown("b")
		then 
			lua_table.camera_shake_activated = true
			lua_table.camera_shake_duration = 0.2
			lua_table.camera_shake_magnitude = 0.1
		end 
		
		if lua_table.InputFunctions:KeyDown("v")
		then 
			lua_table.camera_shake_activated = true
			lua_table.camera_shake_duration = 0.5
			lua_table.camera_shake_magnitude = 0.3
		end 
	end
end

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")

	-- Get my own UID
	my_UID = lua_table.GameObjectFunctions:GetMyUID()

	if my_UID == 0
    then
        lua_table.SystemFunctions:LOG ("Camera: can't find my UID ")
    end
	
    -- Get actual camera UID
    camera_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.camera_GO)

    if camera_UID == 0
    then
        lua_table.SystemFunctions:LOG ("Camera: You need an actual camera inside me, moron")
    end

	---------------------------------------------------------------------------
	-- Player UIDs
	---------------------------------------------------------------------------

	-- Player 1 id
	P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt_GO)	-- first checks if Geralt available

	if P1_id ~= 0
	then 
		lua_table.SystemFunctions:LOG ("Camera: Player 1 id successfully recieved (Geralt)")

		lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

		-- Player 2 id
		P2_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO)

		if P2_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Camera: Null Player 2 id, check name of game object inside script")

			lua_table.SystemFunctions:LOG ("Camera: Gameplay mode set to SOLO")
			lua_table.current_gameplay = gameplay.SOLO
		else
			lua_table.SystemFunctions:LOG ("Camera: Player 2 id successfully recieved (Jaskier)")

			lua_table.P2_script = lua_table.GameObjectFunctions:GetScript(P2_id)

			lua_table.SystemFunctions:LOG ("Camera: Gameplay mode set to DUO")

			lua_table.current_gameplay = gameplay.DUO
		end
	else
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) -- If not checks if Jaskier available

		if P1_id ~= 0
		then 
			lua_table.SystemFunctions:LOG ("Camera: Player 1 id successfully recieved (Jaskier)")

			lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

			lua_table.SystemFunctions:LOG ("Camera: Gameplay mode set to SOLO")

			lua_table.current_gameplay = gameplay.SOLO
		else
			lua_table.SystemFunctions:LOG ("Camera: Null Player 1 id, check name of game object")	

			lua_table.SystemFunctions:LOG ("Camera: Gameplay mode set to NULL")
			lua_table.current_gameplay = gameplay.NULL
		end
	end

	-- Kikimora id

	Kikimora_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.kikimora_GO)

	if Kikimora_id == 0 
	then
		lua_table.SystemFunctions:LOG ("Camera: Null Boss id, check name of game object inside script")
	else
		lua_table.SystemFunctions:LOG ("Camera: Boss id successfully recieved")

		lua_table.kikimora_script = lua_table.GameObjectFunctions:GetScript(Kikimora_id)
	end

	-- Hoard Pivot id

	Hoard_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.Hoard_GO)

	if Hoard_id == 0 
	then
		lua_table.SystemFunctions:LOG ("Camera: Null Hoard Pivot id, check name of game object inside script")
	else
		lua_table.SystemFunctions:LOG ("Camera: Hoard Pivot id successfully recieved")

		--lua_table.kikimora_script = lua_table.GameObjectFunctions:GetScript(Hoard_id)
	end

    --This two lines should be updated everytime angle changes
    current_camera_angle = lua_table.camera_angle_layer_1
	current_camera_angle_for_offset = 90 - lua_table.camera_angle_layer_1
    camera_rotation_x = 180 - lua_table.camera_angle_layer_1 --because soemthing is wrong with the motor view that is inverted
    
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
	-- lua_table["Functions"]:LookAt(lua_table.target_position_x, 0, 0, false)
    lua_table.TransformFunctions:SetObjectRotation(camera_rotation_x, camera_rotation_y, camera_rotation_z, camera_UID)
    lua_table.TransformFunctions:SetObjectRotation(0, lua_table.current_camera_orientation, 0, my_UID)

	is_start = false
end

function lua_table:Update ()
	dt = lua_table.SystemFunctions:DT ()
	is_update = true

	DebugInputs()

	HandleShake()

	HandleZoomLayers()

	HandleSwitch()

	HandleTarget()

	HandleOffset()

	HandleMovement()

	-- Debug

	-- lua_table.SystemFunctions:LOG ("Camera Layer: " .. lua_table.current_zoom_layer)
	-- lua_table.SystemFunctions:LOG ("Camera State: " .. lua_table.current_state)
	
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

-- Player 1 script (only if successfull id)
		-- lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

		-- if P1_script == NIL
		-- then
			-- 	lua_table.SystemFunctions:LOG ("Camera: Null Player 1 script")
		-- else
			-- 	lua_table.SystemFunctions:LOG ("Camera: Player 1 script successfully recieved")
		-- end