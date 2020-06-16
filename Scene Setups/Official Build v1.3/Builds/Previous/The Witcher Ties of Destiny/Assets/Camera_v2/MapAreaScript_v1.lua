function GetTableMapAreaScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()


-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Absolute Distance from Target
lua_table.map_area_camera_distance_layer_1 = 25
lua_table.map_area_camera_distance_layer_2 = 35
lua_table.map_area_camera_distance_layer_3 = 45

-- Angle for every layer
lua_table.map_area_camera_angle_layer_1 = 50
lua_table.map_area_camera_angle_layer_2 = 60
lua_table.map_area_camera_angle_layer_3 = 70

-- Orientation
lua_table.map_area_camera_orientation = 0

-----------------------------------------------------------------------------------------
-- UIDs
-----------------------------------------------------------------------------------------

-- Camera Pivot GO UID
lua_table.my_UID = 0

-- Camera UID
lua_table.camera_UID = 0

-- Manager UID
lua_table.manager_UID = 0

-- Camera target GO names
lua_table.camera_GO = "Camera"

-- Manager GO
lua_table.manager_GO = "Map_Area_Manager"

lua_table.camera_script = {}

lua_table.manager_script = {}

lua_table.geralt_GO = "Geralt"
lua_table.jaskier_GO = "Jaskier"

lua_table.kikimora_GO = "Kikimora"

-- P1
local P1_id = 0
lua_table.P1_script = {}
lua_table.P1_triggered = false

-- P2
local P2_id = 0
lua_table.P2_script = {}
lua_table.P2_triggered = false

local game_time = 0
lua_table.half_trigger_time = 0
lua_table.full_trigger_time = 0

-- Collider Layers
local layers = 
{
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4
}	

local state = -- not in use rn
{
	STATIC = 0, 
	DYNAMIC = 1,
	SWITCHING = 2
}

local gameplay = 
{
	NULL = 0,

	SOLO = 1, 
	DUO = 2, 
	TRIO = 3, 
	QUARTET = 4
}

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")

	-- Get my own UID
	lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()
	
    -- Get camera UID
    lua_table.camera_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.camera_GO)

    if lua_table.camera_UID == 0
    then
        lua_table.SystemFunctions:LOG ("Map Area: Can't find Camera")
    else
        lua_table.camera_script = lua_table.GameObjectFunctions:GetScript(lua_table.camera_UID)
	end
	
	 -- Get manager UID
	 lua_table.manager_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.manager_GO)
	 
	if lua_table.manager_UID == 0
	then
		lua_table.SystemFunctions:LOG ("Map Area: Can't find manager")
	else
			lua_table.manager_script = lua_table.GameObjectFunctions:GetScript(lua_table.manager_UID)
 	end	
	---------------------------------------------------------------------------
	-- Player UIDs
	---------------------------------------------------------------------------

	-- Player 1 id
	P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt_GO)	-- first checks if Geralt available

	if P1_id ~= 0
	then 
		lua_table.SystemFunctions:LOG ("Map Area: Player 1 id successfully recieved (Geralt)")

		lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

		-- Player 2 id
		P2_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO)

		if P2_id == 0 
		then
            lua_table.SystemFunctions:LOG ("Map Area: No Player 2 (Jaskier)")
		else
			lua_table.P2_script = lua_table.GameObjectFunctions:GetScript(P2_id)
		end
	else
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) -- If not checks if Jaskier available

		if P1_id ~= 0
		then 
            lua_table.SystemFunctions:LOG ("Map Area: Player 1 id successfully recieved (Jaskier)")
            
			lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)
		else
			lua_table.SystemFunctions:LOG ("Map Area:: Null Players id")	
		end
	end
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on START")

end

function lua_table:Update ()
	dt = lua_table.SystemFunctions:DT ()
	game_time = lua_table.SystemFunctions:GameTime()
    
    if lua_table.camera_script.current_gameplay == gameplay.SOLO and lua_table.P1_triggered == true 
    or lua_table.camera_script.current_gameplay == gameplay.SOLO and lua_table.P2_triggered == true
    then
        lua_table.P1_triggered = false
        lua_table.P2_triggered = false

        lua_table.camera_script.camera_distance_layer_1 = lua_table.map_area_camera_distance_layer_1
        lua_table.camera_script.camera_distance_layer_2 = lua_table.map_area_camera_distance_layer_2
        lua_table.camera_script.camera_distance_layer_3 = lua_table.map_area_camera_distance_layer_3

        lua_table.camera_script.camera_angle_layer_1 = lua_table.map_area_camera_angle_layer_1
        lua_table.camera_script.camera_angle_layer_2 = lua_table.map_area_camera_angle_layer_2
        lua_table.camera_script.camera_angle_layer_3 = lua_table.map_area_camera_angle_layer_3

		lua_table.camera_script.camera_orientation = lua_table.map_area_camera_orientation
		
		-- So camera updates it's distance and angles
		lua_table.camera_script.current_state = state.SWITCHING

		-- Tells manager to reset all other area scripts
		lua_table.manager_script.reset_all_map_areas = true

    elseif lua_table.camera_script.current_gameplay == gameplay.DUO and lua_table.P1_triggered == true and lua_table.P2_triggered == true
    then
        lua_table.P1_triggered = false
        lua_table.P2_triggered = false

        lua_table.camera_script.camera_distance_layer_1 = lua_table.map_area_camera_distance_layer_1
        lua_table.camera_script.camera_distance_layer_2 = lua_table.map_area_camera_distance_layer_2
        lua_table.camera_script.camera_distance_layer_3 = lua_table.map_area_camera_distance_layer_3

        lua_table.camera_script.camera_angle_layer_1 = lua_table.map_area_camera_angle_layer_1
        lua_table.camera_script.camera_angle_layer_2 = lua_table.map_area_camera_angle_layer_2
        lua_table.camera_script.camera_angle_layer_3 = lua_table.map_area_camera_angle_layer_3

		lua_table.camera_script.camera_orientation = lua_table.map_area_camera_orientation
		
		-- So camera updates it's distance and angles
		lua_table.camera_script.current_state = state.SWITCHING

		-- Tells manager to reset all other area scripts
		lua_table.manager_script.reset_all_map_areas = true

		-- Area manager uses this timer 
		lua_table.full_trigger_time = game_time
    end
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.my_UID)

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)

	if layer == layers.player  --Checks if its player attack collider layer
	then
        if collider == P1_id
		then
			lua_table.SystemFunctions:LOG ("P1 entered Map Area: " .. lua_table.my_UID)
			lua_table.P1_triggered = true
			
			if lua_table.camera_script.current_gameplay == gameplay.DUO and lua_table.P2_triggered == false
			then
				-- Area manager uses this timer 
				lua_table.half_trigger_time = game_time
			end
		end

        if collider == P2_id
		then
			lua_table.SystemFunctions:LOG ("P2 entered Map Area: " .. lua_table.my_UID)
			lua_table.P2_triggered = true
			
			if lua_table.camera_script.current_gameplay == gameplay.DUO and lua_table.P1_triggered == false
			then
				-- Area manager uses this timer 
				lua_table.half_trigger_time = game_time
			end
        end
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
    local collider = lua_table.PhysicsFunctions:OnCollisionEnter(lua_table.my_UID)
	-- lua_table.SystemFunctions:LOG("T:" .. collider)
end
	return lua_table
end