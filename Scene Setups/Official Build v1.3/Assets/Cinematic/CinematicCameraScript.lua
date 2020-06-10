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
local changeScene_nextFrame = false

local minion = 0
local minion1 = 0
local minion2 = 0
local minion3 = 0
local minion4 = 0
local minion5 = 0

-- Camera position
local offset = {}
local position_z = {}

-- Jaskier UID
local Cube_ID = 0
--local BarID = 0 -- Ciruclar bar for skip

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


local conversation_finished = false
local start_motion = false

-- Dummy bools
local music_played = false
local cube_moved = false
local next_scene = true

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
    --[[
    -- Skip Scene code
    if lua_table.skip_threshold <= 0.00 then
       lua_table.skip_threshold = 0.00
   end

   if lua_table.Input:IsGamepadButton(1, "BUTTON_A", "REPEAT") and next_scene == true then
       lua_table.skip_threshold = lua_table.skip_threshold + 0.4
       if skip_button_is_being_pressed == false then
        lua_table.Audio:PlayAudioEvent("Play_Pressed_Skip_Button")
        skip_button_is_being_pressed = true
   end
   else 
       lua_table.skip_threshold = lua_table.skip_threshold - 0.6
       skip_button_is_being_pressed = false
   end
   --]]

   if lua_table.Input:IsGamepadButton(1, "BUTTON_A", "DOWN") and next_scene == true then

       lua_table.Audio:PlayAudioEvent("Play_Skipped_Cinematic")
       lua_table.Audio:StopAudioEvent("Play_lvl2_Intro_conversation_Cutscene")
       lua_table.Audio:StopAudioEvent("Play_Lvl2_Ambience_Wind_Loop")
       lua_table.Audio:StopAudioEvent("Play_Lvl2_Ambience_Crickets_Loop")
       lua_table.Audio:StopAudioEvent("Play_Music_Cinematic_lvl2_Elven_Forest")

       changeScene_nextFrame = true
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

    minion = lua_table.GameObjectFunctions:FindGameObject("Minion_Ghoul")
    minion1 = lua_table.GameObjectFunctions:FindGameObject("Minion_Ghoul1")
    minion2 = lua_table.GameObjectFunctions:FindGameObject("Minion_Ghoul2")
    minion3 = lua_table.GameObjectFunctions:FindGameObject("Minion_Ghoul3")
    minion4 = lua_table.GameObjectFunctions:FindGameObject("Minion_Ghoul4")
    minion5 = lua_table.GameObjectFunctions:FindGameObject("Minion_Ghoul5")

    lua_table.Audio:PlayAudioEvent("Play_lvl2_Intro_conversation_Cutscene")
    lua_table.Audio:PlayAudioEvent("Play_Lvl2_Ambience_Wind_Loop")
    lua_table.Audio:PlayAudioEvent("Play_Lvl2_Ambience_Crickets_Loop")
    lua_table.Audio:PlayAudioEvent("Play_Music_Cinematic_lvl2_Elven_Forest")

    started_time = lua_table.System:GameTime()
end


function lua_table:Update()
    time = lua_table.System:GameTime() - started_time
    CurrentCameraPos = lua_table.Transform:GetPosition(lua_table.GameObjectFunctions:GetMyUID())

    if changeScene_nextFrame == true then
        lua_table.Scene:LoadScene(lua_table.NextScene)
        next_scene = false
    end

    SkipButton()

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
            lua_table.Transform:SetPosition(889.392, 23.327, -365.724, lua_table.GameObjectFunctions:GetMyUID())
            lua_table.Transform:SetObjectRotation(159.255, 0, 180.000, lua_table.GameObjectFunctions:GetMyUID())

            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion1)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion2)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion3)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion4)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion5)
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

        if value >= 1 
        then
            FadeOut3 = false
            lua_table.Scene:LoadScene(lua_table.NextScene)
        end
    end

   
end

return lua_table
end