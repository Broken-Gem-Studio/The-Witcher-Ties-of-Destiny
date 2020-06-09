function GetTableSpawnerScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.Audio = Scripting.Audio()
lua_table.Scene = Scripting.Scenes()
lua_table.Physics = Scripting.Physics()
lua_table.SpawnRadius = 5
lua_table.SpawnRate = 3

lua_table.NumberofEnemies = 10

lua_table.Enemy_Prefab = 0

lua_table.time = 0

lua_table.ActiveDistance = 60

lua_table.humanoid_spawner = false
lua_table.shouted_at_players = false
lua_table.had_conversation = false
lua_table.is_cinematic = false
lua_table.enemies_chat = false

lua_table.enemies = 0

local MyUID = 0
local position = {}

local leader_chosen = false
lua_table.camera_name = "Camera"
local camera_UID = 0
local camera_pos = {}
lua_table.DistanceToCamera = 0
local counter = 0
local spawnedEnemies = {}
local spawnedEnemiesChild = {}
lua_table.auxCounter = 0 
local tutoGO = 0

function lua_table:CheckEnemies()
    lua_table.auxCounter = counter

    for i = 1, #spawnedEnemies do
        lua_table.System:LOG("OSCAR spawnedEnemies: "..spawnedEnemies[i])
        local alive = lua_table.GameObjectFunctions:GetLayerByID(spawnedEnemies[i])
        --lua_table.System:LOG("OSCAR alive variable: "..alive)
        if alive == -1 
        then
            --lua_table.System:LOG("OSCAR ALIVE false")
            lua_table.auxCounter = lua_table.auxCounter - 1
        end
    end   
end


local function Spawn()

    local pos_randX = math.random(-lua_table.SpawnRadius,lua_table.SpawnRadius)
    local pos_randZ = math.random(-lua_table.SpawnRadius,lua_table.SpawnRadius)

    local enemy =  lua_table.Scene:Instantiate(lua_table.Enemy_Prefab, position[1]+pos_randX, position[2], position[3] + pos_randZ, 0, 0, 0)
    counter = counter + 1
    spawnedEnemies[counter] = enemy

    if lua_table.humanoid_spawner == true and leader_chosen == false then
        lua_table.enemies = enemy
        leader_chosen = true
        if lua_table.enemies ~= 0 
        then
            lua_table.leader_script = lua_table.GameObjectFunctions:GetScript(lua_table.enemies)
        else
            leader_chosen = false
        end
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

        if lua_table.NumberofEnemies > 0 then

            if lua_table.ActiveDistance >= lua_table.DistanceToCamera and lua_table.enemies_chat == true then
                if lua_table.had_conversation == false and lua_table.humanoid_spawner == true   then
                    lua_table.Audio:PlayAudioEventGO("Play_Enemy_Conversation_01", MyUID)
                    lua_table.had_conversation = true
                    lua_table.System:LOG ("Playing Conversation")
                end
            end

            Spawn()

            lua_table.NumberofEnemies = lua_table.NumberofEnemies - 1
        end

        lua_table.time = 0
    end

    --Manage the enemies shouting at players when they discover them
    if leader_chosen == true and lua_table.leader_script.currentState ~= nil then
        if lua_table.humanoid_spawner == true  and lua_table.shouted_at_players == false and lua_table.leader_script.currentState == 2 then
            lua_table.Audio:PlayAudioEventGO("Play_Enemy_Humanoid_Discover_Players",MyUID)
            lua_table.shouted_at_players = true
        end
    end
end

return lua_table
end