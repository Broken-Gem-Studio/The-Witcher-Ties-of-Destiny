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
        local enemy = GetEnemyPrefab(random)
        lua_table.Scene:Instantiate(enemy, position[1], position[2], position[3], 0, 0, 0)
    else
        local enemy = GetEnemyPrefab(enemy_type)
        lua_table.Scene:Instantiate(enemy, position[1], position[2], position[3], 0, 0, 0)
    end

end

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from SpawnerScript on AWAKE")
end

function lua_table:Start()
    MyUID = lua_table.GameObjectFunctions:GetMyUID()
end

function lua_table:Update()
    
    lua_table.time = lua_table.time + lua_table.System:DT()

    if lua_table.time >= lua_table.SpawnRate then

        if lua_table.NumberofEnemies > 0  or lua_table.InfiniteEnemies then

            position = lua_table.Transform:GetPosition(MyUID)

            Spawn(lua_table.enemy_to_spawn)

            if not lua_table.InfiniteEnemies then lua_table.NumberofEnemies = lua_table.NumberofEnemies - 1
            end
        end

        lua_table.time = 0
    end

end

return lua_table
end