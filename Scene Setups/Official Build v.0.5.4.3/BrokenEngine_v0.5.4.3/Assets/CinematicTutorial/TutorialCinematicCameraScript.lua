function GetTableTutorialCinematicCameraScript()
    local lua_table = {}
    lua_table.System = Scripting.System()
    lua_table.Transform = Scripting.Transform()
    lua_table.GameObjectFunctions = Scripting.GameObject()
    lua_table.Audio = Scripting.Audio()
    lua_table.Scene = Scripting.Scenes()

    -- Camera target GO names
    lua_table.cube = {}
    lua_table.cube[1] = "Cube_1"
    lua_table.cube[2] = "Cube_2"
    lua_table.cube[3] = "Cube_3"
    lua_table.cube[4] = "Cube_4"
    lua_table.cube[5] = "Cube_5"
    lua_table.cube[6] = "Cube_6"
    lua_table.cube[7] = "Cube_7"
    lua_table.cube[8] = "Cube_8"
    lua_table.cube[9] = "Cube_9"

    -- Camera target IDs
    local cube_ID = {}

    -- Time management
    local time = 0
    local started_time = 0
    local start_motion_time = 0

    --Values declaration
    local values_sum = 0
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
                        
        local pos = lua_table.Transform:GetPosition(lua_table.GameObjectFunctions:GetMyUID())
        local target_pos = lua_table.Transform:GetPosition(cube_ID[id])

        local x = Lerp(pos[1], target_pos[1], values.x)
        local y = Lerp(pos[2], target_pos[2], values.y)
        local z = Lerp(pos[3], target_pos[3], values.z)
                        
        lua_table.Transform:SetPosition(x, y, z, lua_table.GameObjectFunctions:GetMyUID())

        values_sum = values.x + values.y + values.z
    end

    function lua_table:Awake()
        lua_table.System:LOG ("This Log was called from CinematicCameraScript on AWAKE")
    end

    function lua_table:Start()
        -- Camera initial position (Players unseen)
        lua_table.Transform:SetPosition(0, 25, -18, lua_table.GameObjectFunctions:GetMyUID())

        cube_ID[1] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[1])
        cube_ID[2] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[2])
        cube_ID[3] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[3])
        cube_ID[4] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[4])
        cube_ID[5] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[5])
        cube_ID[6] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[6])
        cube_ID[7] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[7])
        cube_ID[8] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[8])
        cube_ID[9] = lua_table.GameObjectFunctions:FindGameObject(lua_table.cube[9])
    end

    function lua_table:Update()
        time = lua_table.System:GameTime() - started_time

        if time > 0 and time < 5 -- First
        then
            GoTo(1, 1.5)
        end
        if time > 5 and time < 10 -- Second
        then
            GoTo(2, 0.75)
        end
        if time > 10 and time < 15 -- Third
        then
            GoTo(3, 0.75)
        end
        if time > 15 and time < 20 -- Fourth
        then
            GoTo(4, 0.75)
        end
        if time > 20 and time < 25 -- Fifth
        then
            GoTo(5, 0.75)
        end
        if time > 25 and time < 30 -- Seventh
        then
            GoTo(6, 0.75)
        end
        if time > 30 and time < 35 -- Eighth
        then
            GoTo(7, 0.75)
        end
        if time > 35 and time < 40 -- Nineth
        then
            GoTo(8, 0.75)
        end
        if time > 40 and time < 45 -- Tenth
        then
            GoTo(9, 0.5)
        end

        if time > 55 and next_scene == true
        then
            --lua_table.Scene:LoadScene(lua_table.scene_uid)
            next_scene = false
        end   
    end

    return lua_table
end