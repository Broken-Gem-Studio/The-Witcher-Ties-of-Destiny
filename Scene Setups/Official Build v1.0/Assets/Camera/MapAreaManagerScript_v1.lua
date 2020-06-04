function GetTableMapAreaManagerScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()

-----------------------------------------------------------------------------------------
-- UIDs
-----------------------------------------------------------------------------------------
lua_table.reset_all_map_areas = false

-- Own UID
lua_table.my_UID = 0

-- Childs UID table
lua_table.map_areas = {}

lua_table.map_areas_scripts = {}

-- Camera UID
lua_table.camera_UID = 0

-- Camera target GO names
lua_table.camera_GO = "Camera"

local function ResetTriggers()
	for i = 1, #lua_table.map_areas do
		lua_table.map_areas_scripts[i].P1_triggered = false
		lua_table.map_areas_scripts[i].P2_triggered = false
	end
end

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")

	-- Get my own UID
	lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()

	-- Get all my childs UID
	lua_table.map_areas = lua_table.GameObjectFunctions:GetGOChilds(lua_table.my_UID)

	for i = 1, #lua_table.map_areas do
		lua_table.map_areas_scripts[i] = lua_table.GameObjectFunctions:GetScript(lua_table.map_areas[i])
	end

    -- Get camera UID
    lua_table.camera_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.camera_GO)

    if lua_table.camera_UID == 0
    then
        lua_table.SystemFunctions:LOG ("Map Area: Can't find Camera")
    else
        lua_table.camera_script = lua_table.GameObjectFunctions:GetScript(lua_table.camera_UID)
	end
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on START")

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()
    
	if lua_table.reset_all_map_areas == true
	then
		lua_table.reset_all_map_areas = false
		ResetTriggers()
	end
end

return lua_table

end