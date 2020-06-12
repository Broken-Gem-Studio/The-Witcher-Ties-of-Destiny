function GetTableTutorialCinematicCameraScript()
    local lua_table = {}
    lua_table.System = Scripting.System()
    lua_table.Transform = Scripting.Transform()
    lua_table.GameObject = Scripting.GameObject()
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

    local warrior1 = 0
    local warrior2 = 0
    local warrior3 = 0

    local recruit_bridge1 = 0
    local lumber_bridge = 0

    local disable_fight = true

    -- Camera target IDs
    local cube_ID = {}
    --local BarID = 0
    local FadeScreen = 1
    local fade_speed = 0

    -- Time management
    local time = 0
    local skip_time = 0
    local started_time = 0

    --Values declaration
    local values = {}
    values.x = 0
    values.y = 0
    values.z = 0

    local dt = 0

    -- Scene variables
    lua_table.scene_uid = 0
    local next_scene = false

    -- Loading UIDs
    local AButton = 0
    local loading_screen = 0

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

    function lua_table:Start()
        lua_table.MyUID = lua_table.GameObject:GetMyUID()
        -- Camera initial position (Players unseen)
        lua_table.Transform:SetPosition(-23, 13, 257, lua_table.MyUID)

        cube_ID[1] = lua_table.GameObject:FindGameObject("Cube_1")
        cube_ID[2] = lua_table.GameObject:FindGameObject("Cube_2")
        cube_ID[3] = lua_table.GameObject:FindGameObject("Cube_3")

        lumber1 = lua_table.GameObject:FindGameObject("Lumber1")
        lumber2 = lua_table.GameObject:FindGameObject("Lumber2")
        lumber3 = lua_table.GameObject:FindGameObject("Lumber3")

        archer1 = lua_table.GameObject:FindGameObject("Archer1")
        archer2 = lua_table.GameObject:FindGameObject("Archer2")

        -- This are the moving enemies
        recruit1 = lua_table.GameObject:FindGameObject("Recruit1")
        recruit2 = lua_table.GameObject:FindGameObject("Recruit_Gank")
        -- Bridge recruits
        recruit_bridge1 = lua_table.GameObject:FindGameObject("Recruit_Bridge1")
        lumber_bridge = lua_table.GameObject:FindGameObject("Lumber_Bridge")

        warrior1 = lua_table.GameObject:FindGameObject("Warrior_City1")
        warrior2 = lua_table.GameObject:FindGameObject("Warrior_City2")
        warrior3 = lua_table.GameObject:FindGameObject("Warrior_City3")

        FadeScreen = lua_table.GameObject:FindGameObject("TutorialFadeScreen")
        loading_screen = lua_table.GameObject:FindGameObject("LoadingScreenCanvas")
        AButton = lua_table.GameObject:FindGameObject("TutorialCanvas")

        -- Disable "gaking" enemies
        lua_table.GameObject:SetActiveGameObject(false, recruit2)

        lua_table.GameObject:SetActiveGameObject(false, recruit_bridge1)
        lua_table.GameObject:SetActiveGameObject(false, lumber_bridge)

        --Play music
        lua_table.Audio:PlayAudioEvent("Play_Music_Cinematic_lvl1_The_Ocean_Takes_It_All")

        started_time = lua_table.System:GameTime()
    end

    function lua_table:Update()
        time = lua_table.System:GameTime() - started_time

        dt = lua_table.System:DT()

        if lua_table.Input:IsGamepadButton(1, "BUTTON_A", "DOWN") then
            lua_table.Audio:PlayAudioEvent("Play_Skipped_Cinematic")
            lua_table.Audio:StopAudioEvent("Play_Music_Cinematic_lvl1_The_Ocean_Takes_It_All")

            lua_table.GameObject:SetActiveGameObject(false, AButton)
            lua_table.GameObject:SetActiveGameObject(true, loading_screen)
            
            skip_time =  lua_table.System:GameTime() * 1000

            next_scene = true
        end

        if skip_time + 1000 <= lua_table.System:GameTime() * 1000 and next_scene == true then 
            lua_table.Scene:LoadScene(lua_table.scene_uid)
            next_scene = false
        end

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

            lua_table.GameObject:SetActiveGameObject(false, lumber1)
            lua_table.GameObject:SetActiveGameObject(false, lumber2)
            lua_table.GameObject:SetActiveGameObject(false, lumber3)
            lua_table.GameObject:SetActiveGameObject(false, archer1)
            lua_table.GameObject:SetActiveGameObject(false, archer2)

            lua_table.GameObject:SetActiveGameObject(true, recruit2)

            lua_table.GameObject:SetActiveGameObject(true, recruit_bridge1)
            lua_table.GameObject:SetActiveGameObject(true, lumber_bridge)
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

        if time > 20 and disable_fight == true 
        then
            lua_table.GameObject:SetActiveGameObject(false, recruit1)
            lua_table.GameObject:SetActiveGameObject(false, recruit2)

            lua_table.GameObject:SetActiveGameObject(false, warrior1)
            lua_table.GameObject:SetActiveGameObject(false, warrior2)
            lua_table.GameObject:SetActiveGameObject(false, warrior3)
            
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
        
        if time > 55 and next_scene == false
        then
            lua_table.Audio:StopAudioEvent("Play_Music_Cinematic_lvl1_The_Ocean_Takes_It_All")
            lua_table.GameObject:SetActiveGameObject(false, AButton)
            lua_table.GameObject:SetActiveGameObject(true, loading_screen)

            skip_time =  lua_table.System:GameTime() * 1000
            next_scene = true
        end   
    end

    return lua_table
end