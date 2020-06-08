function GetTableDirectionalLightScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Position offset
lua_table.offset_x = 0
lua_table.offset_y = 20
lua_table.offset_z = -20

-- Rotations
lua_table.rotation_x = 30
lua_table.rotation_y = 0
lua_table.rotation_z = 0

-----------------------------------------------------------------------------------------
-- My UID
lua_table.my_UID = 0

-- Camera UID
lua_table.camera_UID = 0

-- Camera target GO names
lua_table.camera_GO = "Camera"

-- Camera script
lua_table.camera_script = {}

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Light Script on AWAKE")

	-- Get my own UID
	lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()

	if lua_table.my_UID == 0
    then
        lua_table.SystemFunctions:LOG ("Light: can't find my UID ")
    end
	
    -- Get camera UID
    lua_table.camera_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.camera_GO)

    if lua_table.camera_UID == 0
    then
        lua_table.SystemFunctions:LOG ("Light: Can't find Camera")
    else
        lua_table.camera_script = lua_table.GameObjectFunctions:GetScript(lua_table.camera_UID)
    end

	-- Debug
	-- Health = lua_table.P1_script.max_health_orig
end

function lua_table:Start ()
    lua_table.SystemFunctions:LOG ("This Log was called from Light Script on START")
    
    -- Setting Light Position
    lua_table.TransformFunctions:SetPosition(lua_table.camera_script.target_position_x + lua_table.offset_x, lua_table.camera_script.target_position_y + lua_table.offset_y, lua_table.camera_script.target_position_z + lua_table.offset_z, lua_table.my_UID)
    
    -- Rotation of the Actual camera
	lua_table.TransformFunctions:SetObjectRotation(lua_table.rotation_x, lua_table.rotation_y, lua_table.rotation_z, lua_table.my_UID)

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()
    
    -- Setting Light Position
    lua_table.TransformFunctions:SetPosition(lua_table.camera_script.target_position_x + lua_table.offset_x, lua_table.camera_script.target_position_y + lua_table.offset_y, lua_table.camera_script.target_position_z + lua_table.offset_z, lua_table.my_UID)
    
    -- Rotation of the Actual camera
	lua_table.TransformFunctions:SetObjectRotation(lua_table.rotation_x, lua_table.rotation_y, lua_table.rotation_z, lua_table.my_UID)

end
	return lua_table
end