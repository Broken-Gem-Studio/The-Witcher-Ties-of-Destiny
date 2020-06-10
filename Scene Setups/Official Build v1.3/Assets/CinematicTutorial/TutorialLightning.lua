function GetTableTutorialLightning()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.LightingFunctions = Scripting.Lighting()
lua_table.Audio = Scripting.Audio()

-- My UID
lua_table.my_UID = 0
    
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
local time_to_next_lighting_max = 8
local time_to_next_lighting_min = 5
local time_to_next_lighting = 0

-- Light Controller
local able_to_light = false
        

function lua_table:Awake()

    -- Get my own UID
    lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()

    if lua_table.my_UID == 0
    then
        lua_table.SystemFunctions:LOG ("Light: can't find my UID ")
    end

    time_to_next_lighting = lua_table.SystemFunctions:RandomNumberInRange(time_to_next_lighting_min,time_to_next_lighting_max)

    
end

function lua_table:Start()

    --Play the Rain
    lua_table.Audio:PlayAudioEventGO("Rain_loop", lua_table.my_UID)

end

function lua_table:Update()
    local dt = lua_table.SystemFunctions:DT ()

    if current_time_to_next_lighting > time_to_next_lighting then
        able_to_light = true
    end


    if able_to_light == true then
        current_time_appearing = current_time_appearing + dt
        if current_time_appearing < time_to_lighting_appearing then
            current_intensity = (current_time_appearing/time_to_lighting_appearing)*max_intensity
            lua_table.LightingFunctions:SetLightIntensity(current_intensity,lua_table.my_UID)
        else     
            current_time_vanishing = current_time_vanishing + dt
            if(current_intensity > initial_intensity) then
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