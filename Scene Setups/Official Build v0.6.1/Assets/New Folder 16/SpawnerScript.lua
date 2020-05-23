function GetTableSpawnerScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.Scene = Scripting.Scenes()
lua_table.SpawnRadius = 5
lua_table.SpawnRate = 3

lua_table.NumberofEnemies = 10

lua_table.Enemy_Prefab = 0

lua_table.time = 0

lua_table.ActiveDistance = 60

local MyUID = 0
local position = {}

lua_table.camera_name = "Camera"
local camera_UID = 0
local camera_pos = {}
lua_table.DistanceToCamera = 0

local function Spawn()

    local pos_randX = math.random(-lua_table.SpawnRadius,lua_table.SpawnRadius)
    local pos_randZ = math.random(-lua_table.SpawnRadius,lua_table.SpawnRadius)
    lua_table.Scene:Instantiate(lua_table.Enemy_Prefab, position[1]+pos_randX, position[2], position[3] + pos_randZ, 0, 0, 0)

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

            Spawn()

            lua_table.NumberofEnemies = lua_table.NumberofEnemies - 1
        end

        lua_table.time = 0
    end

end

return lua_table
end