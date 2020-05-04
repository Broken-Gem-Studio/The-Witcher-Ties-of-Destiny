function GetTableSpawnerScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.Scene = Scripting.Scenes()

lua_table.SpawnRate = 3

lua_table.InfiniteEnemies = true
lua_table.NumberofEnemies = 10

lua_table.Prefab_Archer = 0
lua_table.Prefab_Lumberjack = 0
lua_table.Prefab_walker_Ghoul = 0
lua_table.Prefab_Zomboid = 0
lua_table.Prefab_minion = 0

lua_table.time = 0

lua_table.ActiveDistance = 60

local enemies = {
    RANDOM = -1,
    ARCHER = 0,
    LUMBERJACK = 1,
    WALKER_GHOUL = 2,
    ZOMBOID = 3,
    MINION = 4
}

lua_table.enemy_to_spawn = enemies.RANDOM

local MyUID = 0
local position = {}

lua_table.camera_name = "Camera"
local camera_UID = 0
local camera_pos = {}
lua_table.DistanceToCamera = 0

local function GetEnemyPrefab(type)

    if type == enemies.ARCHER then 
        return lua_table.Prefab_Archer
    elseif type == enemies.LUMBERJACK then
        return lua_table.Prefab_Lumberjack
    elseif type == enemies.WALKER_GHOUL then
        return lua_table.Prefab_walker_Ghoul
    elseif type == enemies.ZOMBOID then
        return lua_table.Prefab_Zomboid
    elseif type == enemies.MINION then
        return lua_table.Prefab_minion
    end
end

local function Spawn(enemy_type)

    if enemy_type == enemies.RANDOM then
        local random = math.random(0,4)
        local pos_randX = math.random(-10,10)
        local pos_randZ = math.random(-10,10)
        local enemy = GetEnemyPrefab(random)
        lua_table.Scene:Instantiate(enemy, position[1]+pos_randX, position[2], position[3] + pos_randZ, 0, 0, 0)
    else
        local enemy = GetEnemyPrefab(enemy_type)
        local pos_randX = math.random(-10,10)
        local pos_randZ = math.random(-10,10)
        lua_table.Scene:Instantiate(enemy, position[1]+pos_randX, position[2], position[3] + pos_randZ, 0, 0, 0)
    end

end

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from SpawnerScript on AWAKE")
end

function lua_table:Start()
    MyUID = lua_table.GameObjectFunctions:GetMyUID()
    camera_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.camera_name)
end

function lua_table:Update()

    lua_table.time = lua_table.time + lua_table.System:DT()

    ------ Distance to camera ----------------------------
    position = lua_table.Transform:GetPosition(MyUID)
    camera_pos = lua_table.Transform:GetPosition(camera_UID)

    PX = camera_pos[1] - position[1]
    PZ = camera_pos[3] - position[3]

    lua_table.DistanceToCamera = math.sqrt(PX^2 + PZ^2)
    
    -----------------------------------------------------------

    if lua_table.time >= lua_table.SpawnRate and lua_table.ActiveDistance >= lua_table.DistanceToCamera then

        if lua_table.NumberofEnemies > 0  or lua_table.InfiniteEnemies then

            Spawn(lua_table.enemy_to_spawn)

            if not lua_table.InfiniteEnemies then lua_table.NumberofEnemies = lua_table.NumberofEnemies - 1
            end
        end

        lua_table.time = 0
    end

end

return lua_table
end