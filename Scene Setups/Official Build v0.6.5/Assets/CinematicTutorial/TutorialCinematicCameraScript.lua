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

    local move_recruits = true

    -- Camera target IDs
    local cube_ID = {}
    local BarID = 0
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

    -- Scene variables
    lua_table.scene_uid = 0
    local next_scene = true

    local function Lerp(start, end_, value)
        if value > 1.0
        then
            value = 1.0
        end
        return (1 - value) * start + value * end_
    end

    local function GoTo(id, speed)
        speed = 1000 / speed
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
        archer2 = lua_table.GameObjectFunctions:FindGameObject("Archer1")

        recruit1 = lua_table.GameObjectFunctions:FindGameObject("Recruit1")
        recruit2 = lua_table.GameObjectFunctions:FindGameObject("Recruit1")

        minion1 = lua_table.GameObjectFunctions:FindGameObject("Minion1")
        minion2 = lua_table.GameObjectFunctions:FindGameObject("Minion1")


        BarID = lua_table.GameObjectFunctions:FindGameObject("SkipBar")
        FadeScreen = lua_table.GameObjectFunctions:FindGameObject("TutorialFadeScreen")

        started_time = lua_table.System:GameTime()
    end

    function lua_table:Update()
        time = lua_table.System:GameTime() - started_time

        if lua_table.skip_threshold <= 0.00 then
            lua_table.skip_threshold = 0.00
        end

        -------------------- Skip scene
        if lua_table.Input:IsGamepadButton(1, "BUTTON_A", "REPEAT") and next_scene == true then
            lua_table.skip_threshold = lua_table.skip_threshold + 0.4
        else 
            lua_table.skip_threshold = lua_table.skip_threshold - 0.6
        end

        if lua_table.skip_threshold >= 100 and next_scene == true then
            lua_table.Scene:LoadScene(lua_table.scene_uid)
            next_scene = false
        end

        lua_table.UI:SetUICircularBarPercentage(lua_table.skip_threshold, BarID)

        --------------------------------------------------------------------------------------------------------------------------------------------------
        if fade_speed >= 1 then fade_speed = 1 end
        if fade_speed <= 0 then fade_speed = 0 end

        if time > 0 and time < 12 
        then
            GoTo(1, 0.5)
        end

        if time > 0 and time < 4
            then
                local value = time / 4
                local alpha = Lerp(1, 0, value)
                lua_table.UI:ChangeUIComponentColor("Image", 0, 0, 0, alpha, FadeScreen)
        end

        if time > 4 and move_recruits == true
        then
            lua_table.GameObjectFunctions:SetActiveGameObject(true, recruit1)
            lua_table.GameObjectFunctions:SetActiveGameObject(true, recruit2)
            move_recruits = false
        end

        if time > 10 and time < 12
        then
            fade_speed = fade_speed + 0.015
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end

        if time > 12.5 and time < 13.5
        then
            lua_table.Transform:SetPosition(-67, 7, 101, lua_table.MyUID)
            lua_table.Transform:SetObjectRotation(179, 18, 179, lua_table.MyUID)
        end

        if time > 14 and time < 15
        then
            fade_speed = fade_speed - 0.015
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end
        
        if time > 14 and time < 32
        then
            GoTo(2, 0.03)
        end

        if time > 30 and time < 31
        then
            fade_speed = fade_speed + 0.015
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end

        if time > 31.5 and time < 32.5
        then
            lua_table.Transform:SetPosition(-255, 16, 169, lua_table.MyUID)
            lua_table.Transform:SetObjectRotation(-179, 60, 179, lua_table.MyUID)
        end

        if time > 34
        then
            GoTo(3, 0.04)
        end

        if time > 34 and time < 35
        then
            fade_speed = fade_speed - 0.015
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end

        if time > 44 and time < 45
        then
            fade_speed = fade_speed + 0.015
            lua_table.UI:ChangeUIComponentAlpha("Image", fade_speed, FadeScreen)
        end
        
        if time > 50 and next_scene == true
        then
            lua_table.Scene:LoadScene(lua_table.scene_uid)
            next_scene = false
        end   
    end

    return lua_table
end