function GetTableDirectionalLightTutorialScript()
    local lua_table = {}
    lua_table.SystemFunctions = Scripting.System ()
    lua_table.TransformFunctions = Scripting.Transform ()
    lua_table.GameObjectFunctions = Scripting.GameObject ()
    lua_table.LightingFunctions = Scripting.Lighting()
    lua_table.Audio = Scripting.Audio()
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
    
    -- Intensity Controller
    local initial_intensity = 0.007
    local max_intensity = 0.5
    local current_intensity = 0
    
    -- Timers
    local game_time = 0
    local current_time_appearing = 0
    local current_time_vanishing = 0
    local current_time_to_next_lighting = 0
    
    local time_to_lighting_appearing = 0.2
    local time_to_lighting_vanishing = 0.8
    local time_to_next_lighting_max = 20
    local time_to_next_lighting_min = 15
    local time_to_next_lighting = 0
    
    -- Light Controller
    local able_to_light = false
    
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
    
        time_to_next_lighting = lua_table.SystemFunctions:RandomNumberInRange(time_to_next_lighting_min,time_to_next_lighting_max)
        -- Debug
        -- Health = lua_table.P1_script.max_health_orig
    end
    
    function lua_table:Start ()
        lua_table.SystemFunctions:LOG ("This Log was called from Light Script on START")
        
        -- Setting Light Position
        lua_table.TransformFunctions:SetPosition(lua_table.camera_script.target_position_x + lua_table.offset_x, lua_table.camera_script.target_position_y + lua_table.offset_y, lua_table.camera_script.target_position_z + lua_table.offset_z, lua_table.my_UID)
        
        -- Rotation of the Actual camera
        lua_table.TransformFunctions:SetObjectRotation(lua_table.rotation_x, lua_table.rotation_y, lua_table.rotation_z, lua_table.my_UID)
    
        --Play the Rain
        lua_table.Audio:PlayAudioEventGO("Rain_loop",lua_table.my_UID)
    end
    
    function lua_table:Update ()
        local dt = lua_table.SystemFunctions:DT ()
        
        -- Setting Light Position
        lua_table.TransformFunctions:SetPosition(lua_table.camera_script.target_position_x + lua_table.offset_x, lua_table.camera_script.target_position_y + lua_table.offset_y, lua_table.camera_script.target_position_z + lua_table.offset_z, lua_table.my_UID)
        
        -- Rotation of the Actual camera
        lua_table.TransformFunctions:SetObjectRotation(lua_table.rotation_x, lua_table.rotation_y, lua_table.rotation_z, lua_table.my_UID)
        if current_time_to_next_lighting > time_to_next_lighting
        then
            able_to_light = true
        end
    
        if able_to_light == true
        then
            current_time_appearing = current_time_appearing + dt
            if current_time_appearing < time_to_lighting_appearing
            then
                current_intensity = (current_time_appearing/time_to_lighting_appearing)*max_intensity
                lua_table.LightingFunctions:SetLightIntensity(current_intensity,lua_table.my_UID)
            else     
                current_time_vanishing = current_time_vanishing + dt
                if(current_intensity > initial_intensity)
                then
                    current_intensity = max_intensity - (current_time_vanishing/time_to_lighting_vanishing)
                    lua_table.LightingFunctions:SetLightIntensity(current_intensity,lua_table.my_UID)
                else
                    able_to_light = false 
                    current_time_appearing = 0
                    current_time_vanishing = 0
                    current_time_to_next_lighting = 0
                    current_intensity = initial_intensity
                    lua_table.LightingFunctions:SetLightIntensity(current_intensity,lua_table.my_UID)
                    time_to_next_lighting = lua_table.SystemFunctions:RandomNumberInRange(time_to_next_lighting_min,time_to_next_lighting_max)
                    lua_table.Audio:PlayAudioEventGO("Thunder",lua_table.my_UID)
                end
            end
        else
            current_time_to_next_lighting = current_time_to_next_lighting+dt
        end
    
    end
    return lua_table
end