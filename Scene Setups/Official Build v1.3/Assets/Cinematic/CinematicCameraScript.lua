function GetTableCinematicCameraScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.Audio = Scripting.Audio()
lua_table.Scene = Scripting.Scenes()
lua_table.Input = Scripting.Inputs()
lua_table.UI = Scripting.Interface()

-- Camera target GO names
lua_table.cube = "Cube"
lua_table.value_ = 0
lua_table.skip_threshold = 0

lua_table.NextScene = 0

local Fade = 0

local village_enemies = 0
local kikimora_enemies = 0

-- Camera position
local offset = {}
local position_z = {}

-- Jaskier UID
local Cube_ID = 0
--local BarID = 0 -- Ciruclar bar for skip
local loading_screen = 0

-- Time management
local time = 0
local started_time = 0
local start_motion_time = 0
local forest_speech_time = 0

-- Camera Positions
local CurrentCameraPos = {}
local Pos_Minions = {523.236, 57.469, -202.149}
local Pos_Kiki = {889.392, 97.577, -365.724}
local Pos_Jaskier = {368.095, 37.109, -326.500}
local ZoomPos1 = {403.086, 38.228, -319.858}
local ZoomPos2 = {433.336, 31.978, -311.858}

-- Cinematic conditions 
local follow_jaskier = false

local A_time = 0
local fade_button = false

local camera_panning = true
local FadeOut1 = true
local FadeIn2 = false
local FadeIn2_Time = 0
local FadeOut2 = false
local FadeIn3 = false
local FadeIn3_Time = 0
local MoveToJaskier = false
local MoveToJaskier_Time = 10000
local ZoomToTown = false
local ZoomToTown_Time = 0
local FadeOut3 = false
local FadeOut3_Time = 0
local skip_button_is_being_pressed = false
local actual_scene_timer = 0

local conversation_finished = false
local start_motion = false

-- Dummy bools
local music_played = false
local cube_moved = false
local next_scene = false

local function Lerp(start, end_, value)

    if value > 1.0
    then
        value = 1.0
    end

    return (1 - value) * start + value * end_
end

local function GoTo(position, speed)

    speed = 1000 / speed
    value = time / speed

    local pos = lua_table.Transform:GetPosition(lua_table.GameObjectFunctions:GetMyUID())

    local x = Lerp(pos[1], position[1], value)
    local y = Lerp(pos[2], position[2], value)
    local z = Lerp(pos[3], position[3], value)

    lua_table.Transform:SetPosition(x, y, z, lua_table.GameObjectFunctions:GetMyUID())

end

local function SkipButton()

    if lua_table.Input:IsGamepadButton(1, "BUTTON_A", "DOWN") then
        lua_table.Audio:PlayAudioEvent("Play_Skipped_Cinematic")

        lua_table.Audio:StopAudioEvent("Play_lvl2_Intro_conversation_Cutscene")
        lua_table.Audio:StopAudioEvent("Play_Lvl2_Ambience_Wind_Loop")
        lua_table.Audio:StopAudioEvent("Play_Lvl2_Ambience_Crickets_Loop")
        lua_table.Audio:StopAudioEvent("Play_Music_Cinematic_lvl2_Elven_Forest")
        A_time = lua_table.System:GameTime()

        fade_button = true
    end

   --lua_table.UI:SetUICircularBarPercentage(lua_table.skip_threshold, BarID)

end

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from CinematicCameraScript on AWAKE")
end

function lua_table:Start()
    -- Camera initial position (Players unseen)
    lua_table.Transform:SetPosition(424.949, 57.469, -266.669, lua_table.GameObjectFunctions:GetMyUID())
    lua_table.Transform:SetObjectRotation(132.264, 38.413, -147.605, lua_table.GameObjectFunctions:GetMyUID())

    Cube_ID = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube)
    --BarID = lua_table.GameObjectFunctions:FindGameObject("SkipBarForest")
    Fade = lua_table.GameObjectFunctions:FindGameObject("Fade")

    loading_screen = lua_table.GameObjectFunctions:FindGameObject("LoadingScreenCanvas")

    village_enemies = lua_table.GameObjectFunctions:FindGameObject("EnemiesVillage")
    kikimora_enemies = lua_table.GameObjectFunctions:FindGameObject("EnemiesKikimora")

    lua_table.Audio:PlayAudioEvent("Play_lvl2_Intro_conversation_Cutscene")
    lua_table.Audio:PlayAudioEvent("Play_Lvl2_Ambience_Wind_Loop")
    lua_table.Audio:PlayAudioEvent("Play_Lvl2_Ambience_Crickets_Loop")
    lua_table.Audio:PlayAudioEvent("Play_Music_Cinematic_lvl2_Elven_Forest")

    started_time = lua_table.System:GameTime()
end



function lua_table:Update()
    time = lua_table.System:GameTime() - started_time
    CurrentCameraPos = lua_table.Transform:GetPosition(lua_table.GameObjectFunctions:GetMyUID())

    if actual_scene_timer + 1000 <= lua_table.System:GameTime() * 1000 and next_scene == true then
        lua_table.Scene:LoadScene(lua_table.NextScene)
        next_scene = false
    end

    if fade_button == true then
            local fade_time = time - A_time
            local value = fade_time / 3
            local alpha = Lerp(0, 1, value)
            lua_table.UI:ChangeUIComponentColor("Image",0,0,0, alpha, Fade)
    
            if value >= 1 and next_scene == false then

                lua_table.GameObjectFunctions:SetActiveGameObject(true, loading_screen)

                actual_scene_timer = lua_table.System:GameTime() * 1000
                next_scene = true


                fade_button = false
            end
    end

    SkipButton()
    if fade_button == false 
    then
        if camera_panning -- Camera pans sideways
        then
            GoTo(Pos_Minions, 1)
    
            local value = time / 2
            local alpha = Lerp(1, 0, value)
            lua_table.UI:ChangeUIComponentColor("Image",0,0,0, alpha, Fade)
    
            if time > 15
            then
                camera_panning = false
            end
        end
    
        if time >= 17 and FadeOut1 == true
        then
            local fade_time = time - 17
            local value = fade_time / 2
            local alpha = Lerp(0, 1, value)
            lua_table.UI:ChangeUIComponentColor("Image",0,0,0, alpha, Fade)
    
            if value >= 1 then
                FadeOut1 = false
                FadeIn2 = true
                FadeIn2_Time = time
                lua_table.GameObjectFunctions:SetActiveGameObject(false, village_enemies)
                lua_table.GameObjectFunctions:SetActiveGameObject(true, kikimora_enemies)
                lua_table.Transform:SetPosition(889.392, 23.327, -365.724, lua_table.GameObjectFunctions:GetMyUID())
                lua_table.Transform:SetObjectRotation(159.255, 0, 180.000, lua_table.GameObjectFunctions:GetMyUID())
            end
        end
    
        if FadeIn2 == true then
            local fade_time = time - FadeIn2_Time
            local value = fade_time / 2
            local alpha = Lerp(1, 0, value)
            lua_table.UI:ChangeUIComponentColor("Image",0,0,0, alpha, Fade)
    
            GoTo(Pos_Kiki, 0.1)
    
            if time > 36 then
    
                FadeIn2 = false
                FadeOut2 = true
            end
        end
    
        if FadeOut2 == true and time >= 36 + forest_speech_time
        then
            local fade_time = time - 36 + forest_speech_time
            local value = fade_time / 2
            local alpha = Lerp(0, 1, value)
            lua_table.UI:ChangeUIComponentColor("Image",0,0,0, alpha, Fade)
    
            if value >= 1
            then
                FadeOut2 = false
                FadeIn3 = true
                FadeIn3_Time = time
                lua_table.GameObjectFunctions:SetActiveGameObject(false, kikimora_enemies)
                lua_table.Transform:SetPosition(345.595, 37.109, -332.500, lua_table.GameObjectFunctions:GetMyUID())
                lua_table.Transform:SetObjectRotation(42.666, 74.933, -41.272, lua_table.GameObjectFunctions:GetMyUID())
            end
        end
    
        if FadeIn3 == true then
            local fade_time = time - FadeIn3_Time
            local value = fade_time / 2
            local alpha = Lerp(1, 0, value)
            lua_table.UI:ChangeUIComponentColor("Image",0,0,0, alpha, Fade)
            
            MoveToJaskier = true
    
            if time > 40 then
                MoveToJaskier_Time = time
                FadeIn3 = false
            end
        end
    
        if MoveToJaskier == true and time >= MoveToJaskier_Time  
        then
            GoTo(Pos_Jaskier, 0.025)
    
            if time >= MoveToJaskier_Time + 27
            then
                MoveToJaskier = false
                ZoomToTown_Time = time
                ZoomToTown = true
            end
        end
    
        if ZoomToTown == true and time >= ZoomToTown_Time + 4
        then
            GoTo(ZoomPos2, 0.1)
    
            if time >= ZoomToTown_Time + 4.5 and FadeOut3 == false
            then
                FadeOut3 = true
                FadeOut3_Time = time
            end
    
            if time >= ZoomToTown_Time + 7
            then
                ZoomToTown = false
            end
        end
    
    
        if FadeOut3 == true 
        then
            local fade_time = time - FadeOut3_Time
            local value = fade_time / 3
            local alpha = Lerp(0, 1, value)
            lua_table.UI:ChangeUIComponentColor("Image",0,0,0, alpha, Fade)
    
            if value >= 1 and next_scene == false
            then
                FadeOut3 = false
                lua_table.GameObjectFunctions:SetActiveGameObject(true, loading_screen)
                
                actual_scene_timer = lua_table.System:GameTime() * 1000
                next_scene = true

            end
        end
    end
   

   
end

return lua_table
end