function GetTableCinematicCameraScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.Audio = Scripting.Audio()

-- Camera target GO names
lua_table.cube = "Cube"
lua_table.value_ = 0

-- Camera position
local offset_x = 0
local offset_y = 0
local offset_z = 0
local pos_z = 0

-- Jaskier UID
local Cube_ID = 0

-- Time management
local time = 0
local started_time = 0
local start_motion_time = 0

-- Cinematic conditions 
local follow_jaskier = false
local camera_panning = true
local conversation_finished = false
local start_motion = false

-- Dummy bools
local music_played = false
local cube_moved = false

function Lerp(start, end_, value)
    if value > 1.0
    then
        value = 1.0
    end
    return (1 - value) * start + value * end_
end

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from CinematicCameraScript on AWAKE")
end

function lua_table:Start()
    -- Camera initial position (Players unseen)
    lua_table.Transform:SetPosition(-960, 120, -4327)

    Cube_ID = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube)
    started_time = lua_table.System:GameTime()
end

function lua_table:Update()
    time = lua_table.System:GameTime() - started_time
    
    if camera_panning -- Camera pans downwards
    then
        local value_ = time / 3
        
        local x = lua_table.Transform:GetPositionX()
        local y = Lerp(120, 24, value_)
        local z = lua_table.Transform:GetPositionZ()

        lua_table.Transform:SetPosition(x, y, z)
        if value_ >= 1
        then
            offset_x = lua_table.Transform:GetPositionX() - lua_table.GameObjectFunctions:GetGameObjectPosX(Cube_ID)
            offset_y = lua_table.Transform:GetPositionY() - lua_table.GameObjectFunctions:GetGameObjectPosY(Cube_ID)
            offset_z = lua_table.Transform:GetPositionZ() - lua_table.GameObjectFunctions:GetGameObjectPosZ(Cube_ID)

            camera_panning = false
        end
    end
    
    if not camera_panning -- Follow Cube
    then 
        local new_pos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(Cube_ID) + offset_x
        local new_pos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(Cube_ID) + offset_y
        local new_pos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(Cube_ID) + offset_z
    
        lua_table.Transform:SetPosition(new_pos_x, new_pos_y, new_pos_z)
    end

    if time > 1.76 and not music_played -- Accurate time when sound starts playing
    then
        lua_table.System:LOG ("PlayMusic") --Play conversation audio
        lua_table.Audio:PlayAudioEvent("lvl1_Conversation_Cutscene")
        music_played = true
    end

    if time > 31 and not start_motion
    then
        start_motion_time = time
        pos_z = lua_table.Transform:GetPositionZ()
        start_motion = true 
    end

    if start_motion -- Zoom
    then
        local motion_time = time - start_motion_time
        local value_ = motion_time / 5
        
        local x = lua_table.Transform:GetPositionX()
        local y = lua_table.Transform:GetPositionY()
        local z = Lerp(pos_z, -4000, value_)

        lua_table.Transform:SetPosition(x, y, z)
    end
   
end

return lua_table
end