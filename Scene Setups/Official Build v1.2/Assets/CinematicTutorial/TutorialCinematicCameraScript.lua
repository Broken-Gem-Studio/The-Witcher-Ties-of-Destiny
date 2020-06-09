function GetTableTutorialCinematicCameraScript()
    local lua_table = {}
    lua_table.System = Scripting.System()
    lua_table.Transform = Scripting.Transform()
    lua_table.GameObjectFunctions = Scripting.GameObject()
    lua_table.Audio = Scripting.Audio()
    lua_table.Scene = Scripting.Scenes()
    lua_table.Input = Scripting.Inputs()
    lua_table.UI = Scripting.Interface()

    lua_table.MyUID = 0

    -- Camera target GO names
    lua_table.cube = {}
    lua_table.cube[1] = 0
    lua_table.cube[2] = 0
    lua_table.cube[3] = 0

    -- Scene enemies
    local lumber1 = 0
    local lumber2 = 0
    local lumber3 = 0
    local archer1 = 0
    local archer2 = 0
    local recruit1 = 0
    local recruit2 = 0
    local minion1 = 0
    local minion2 = 0

    local disable_fight = true

    -- Camera target IDs
    local cube_ID = {}
    --local BarID = 0
    local FadeScreen = 1
    local fade_speed = 0

    -- Time management
    local time = 0
    local started_time = 0
    local start_motion_time = 0
    lua_table.skip_threshold = 0

    --Values declaration
    local values = {}
    values.x = 0
    values.y = 0
    values.z = 0

    local dt = 0

    -- Scene variables
    lua_table.scene_uid = 0
    local next_scene = true

    -- Skip
    local skip_button_is_being_pressed = false
    local changeScene_nextFrame = false

    local function Lerp(start, end_, value)
        if value > 1.0
        then
            value = 1.0
        end
        return (1 - value) * start + value * end_
    end

    local function GoTo(id, speed)
        speed = (1000 / speed)
        values.x = time / speed
        values.y = time / speed
        values.z = time / speed
                        
        local pos = lua_table.Transform:GetPosition(lua_table.MyUID)
        local target_pos = lua_table.Transform:GetPosition(cube_ID[id])

        local x = Lerp(pos[1], target_pos[1], values.x)
        local y = Lerp(pos[2], target_pos[2], values.y)
        local z = Lerp(pos[3], target_pos[3], values.z)
        lua_table.Transform:SetPosition(x, y, z, lua_table.MyUID)
    end

    function lua_table:Awake()
        lua_table.System:LOG ("This Log was called from CinematicCameraScript on AWAKE")
    end

    local function SkipButton()
        --[[
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
            lua_table.Audio:StopAudioEvent("Play_Music_Cinematic_lvl1_The_Ocean_Takes_It_All")
            changeScene_nextFrame = true
        end

        --lua_table.UI:SetUICircularBarPercentage(lua_table.skip_threshold, BarID)
    end

    function lua_table:Start()
        lua_table.MyUID = lua_table.GameObjectFunctions:GetMyUID()
        -- Camera initial position (Players unseen)
        lua_table.Transform:SetPosition(-23, 13, 257, lua_table.MyUID)

        cube_ID[1] = lua_table.GameObjectFunctions:FindGameObject("Cube_1")
        cube_ID[2] = lua_table.GameObjectFunctions:FindGameObject("Cube_2")
        cube_ID[3] = lua_table.GameObjectFunctions:FindGameObject("Cube_3")

        lumber1 = lua_table.GameObjectFunctions:FindGameObject("Lumber1")
        lumber2 = lua_table.GameObjectFunctions:FindGameObject("Lumber2")
        lumber3 = lua_table.GameObjectFunctions:FindGameObject("Lumber3")

        archer1 = lua_table.GameObjectFunctions:FindGameObject("Archer1")
        archer2 = lua_table.GameObjectFunctions:FindGameObject("Archer2")

        -- This are the moving enemies
        recruit1 = lua_table.GameObjectFunctions:FindGameObject("Recruit1")
        recruit2 = lua_table.GameObjectFunctions:FindGameObject("Recruit_Gank")

        minion1 = lua_table.GameObjectFunctions:FindGameObject("Minion1")
        minion2 = lua_table.GameObjectFunctions:FindGameObject("Minion_Gank")

        --BarID = lua_table.GameObjectFunctions:FindGameObject("SkipBar")
        FadeScreen = lua_table.GameObjectFunctions:FindGameObject("TutorialFadeScreen")

        -- Disable "gaking" enemies

        lua_table.GameObjectFunctions:SetActiveGameObject(false, recruit2)
        lua_table.GameObjectFunctions:SetActiveGameObject(false, minion2)

        --Play music

        lua_table.Audio:PlayAudioEvent("Play_Music_Cinematic_lvl1_The_Ocean_Takes_It_All")

        started_time = lua_table.System:GameTime()
    end

    function lua_table:Update()
        time = lua_table.System:GameTime() - started_time

        dt = lua_table.System:DT()

        --Skip scene

        if changeScene_nextFrame == true then
            lua_table.Scene:LoadScene(lua_table.scene_uid)
            next_scene = false
        end

        SkipButton()

        -- Camera movements, rotations, fade to blacks and fade from blacks

        if fade_speed >= 1 then fade_speed = 1 end
        if fade_speed <= 0 then fade_speed = 0 end

        if time > 0 and time < 5
        then
            local value = time / 4
            local alpha = Lerp(1, 0, value)
            alpha = (alpha + 0.45 * dt)
            lua_table.UI:ChangeUIComponentColor("Image", 0, 0, 0, alpha, FadeScreen)
        end

        if time > 0 and time < 12 
        then
            GoTo(1, 50 * dt)
        end

        if time > 10 and time < 12
        then
            fade_speed = (fade_speed + 1  * dt)
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end

        if time > 12.5 and time < 13
        then
            lua_table.Transform:SetPosition(-67, 7, 101, lua_table.MyUID)
            lua_table.Transform:SetObjectRotation(179, 18, 179, lua_table.MyUID)

            lua_table.GameObjectFunctions:SetActiveGameObject(false, lumber1)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, lumber2)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, lumber3)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, archer1)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, archer2)

            lua_table.GameObjectFunctions:SetActiveGameObject(true, recruit2)
            lua_table.GameObjectFunctions:SetActiveGameObject(true, minion2)
        end

        if time > 13 and time < 15
        then
            fade_speed = (fade_speed - 1  * dt)
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end
        
        if time > 13 and time < 32
        then
            GoTo(2, 3.33 * dt)
        end

        if time > 19 and disable_fight == true 
        then
            lua_table.GameObjectFunctions:SetActiveGameObject(false, recruit1)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, recruit2)
            
            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion1)
            lua_table.GameObjectFunctions:SetActiveGameObject(false, minion2)
           

        end

        if time > 30 and time < 32
        then
            fade_speed = (fade_speed + 1  * dt)
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end

        if time > 32.5 and time < 33
        then
            lua_table.Transform:SetPosition(-255, 16, 169, lua_table.MyUID)
            lua_table.Transform:SetObjectRotation(-179, 60, 179, lua_table.MyUID)
        end

        if time > 33 and time < 35
        then
            fade_speed = (fade_speed - 1  * dt)
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end

        if time > 33
        then
            GoTo(3, 4 * dt)
        end

        if time > 48 and time < 50
        then
            fade_speed = (fade_speed + 1  * dt)
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end
        
        if time > 55 and next_scene == true
        then
            lua_table.Scene:LoadScene(lua_table.scene_uid)
            next_scene = false
        end   
    end

    return lua_table
end