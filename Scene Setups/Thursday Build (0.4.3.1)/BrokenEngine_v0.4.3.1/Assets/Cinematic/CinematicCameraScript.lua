function GetTableCinematicCameraScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.Audio = Scripting.Audio()
lua_table.Scene = Scripting.Scenes()

-- Camera target GO names
lua_table.cube = "Cube"
lua_table.value_ = 0
lua_table.scene_uid = 0

-- Camera position
local offset = {}
local position_z = {}

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
local next_scene = true

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
    lua_table.Transform:SetPosition(-970, 120, -4450, lua_table.GameObjectFunctions:GetMyUID())

    Cube_ID = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube)
    started_time = lua_table.System:GameTime()
end

function lua_table:Update()
    time = lua_table.System:GameTime() - started_time
    
    if camera_panning -- Camera pans downwards
    then
        local value_ = time / 3
        
        local position = lua_table.Transform:GetPosition(lua_table.GameObjectFunctions:GetMyUID())
        position[2] = Lerp(120, 24, value_)

        lua_table.Transform:SetPosition(position[1], position[2], position[3], lua_table.GameObjectFunctions:GetMyUID())
        if value_ >= 1
        then
            local pos = lua_table.Transform:GetPosition(lua_table.GameObjectFunctions:GetMyUID()) 
            local cube_pos = lua_table.Transform:GetPosition(Cube_ID)

            offset[1] = pos[1] - cube_pos[1]
            offset[2] = pos[2] - cube_pos[2]
            offset[3] = pos[3] - cube_pos[3]

            camera_panning = false
        end
    end
    
    if not camera_panning -- Follow Cube
    then 
        local new_pos = {}
        local cube_pos = lua_table.Transform:GetPosition(Cube_ID)

        new_pos[1] = cube_pos[1] + offset[1]
        new_pos[2] = cube_pos[2] + offset[2]
        new_pos[3] = cube_pos[3] + offset[3]
      
        lua_table.Transform:SetPosition(new_pos[1], new_pos[2], new_pos[3], lua_table.GameObjectFunctions:GetMyUID())
    end

    if time > 1.76 and not music_played -- Accurate time when sound starts playing
    then

        lua_table.Audio:PlayAudioEvent("Play_lvl1_Intro_conversation_Cutscene")
        music_played = true
    end

    if time > 31 and not start_motion
    then
        start_motion_time = time
        position_z = lua_table.Transform:GetPosition(lua_table.GameObjectFunctions:GetMyUID())
        start_motion = true 
    end

    if start_motion -- Zoom
    then
        local motion_time = time - start_motion_time
        local value_ = motion_time / 5
        
        local z = Lerp(position_z[3], -4000, value_)

        lua_table.Transform:SetPosition(position_z[1], position_z[2], z, lua_table.GameObjectFunctions:GetMyUID())
    end

	 if time > 38 and next_scene == true
    then
        lua_table.Scene:LoadScene(lua_table.scene_uid)
		next_scene = false
    end
   
end

return lua_table
end