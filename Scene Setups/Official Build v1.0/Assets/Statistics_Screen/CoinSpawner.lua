function GetTableCoinSpawner()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Scene = Scripting.Scenes()
lua_table.TransformFunc =  Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()


lua_table.PlaceSpawner1uID = 0
lua_table.PlaceSpawner2uID = 0
lua_table.CoinToSpawn = 0
lua_table.currentTimeToSpawn = 0
lua_table.MaxTimeBetweenCoins = 0.2
lua_table.MinTimeBetweenCoins = 0.1
lua_table.ThrowCoins = false

local randTime = 0
local Spawner1Pos = 0
local currentTimeToSpawn = 0
local SpawnerList = {}

local uID = 0
local dt = 0

local function InstantiateCoin( Position , uID)

    local randPositionZ = lua_table.System:RandomNumberInRange(-0.02,0.02)
    local randPositionX = lua_table.System:RandomNumberInRange(-0.02,0.02)

    local randRotation = lua_table.System:RandomNumberInRange(0,360)
    lua_table.Scene:Instantiate(uID, Position[1]+randPositionX,Position[2],Position[3]+randPositionZ,-90,0.0,randRotation)

end

function lua_table:Awake()

    SpawnerList = {
        Spawner1Position = lua_table.TransformFunc:GetPosition(lua_table.PlaceSpawner1uID),
        Spawner2Position = lua_table.TransformFunc:GetPosition(lua_table.PlaceSpawner2uID)
    }

    Spawner1Pos = lua_table.TransformFunc:GetPosition(lua_table.PlaceSpawner1uID)

end

function lua_table:Start()

    randTime =  lua_table.System:RandomNumberInRange(lua_table.MinTimeBetweenCoins,lua_table.MaxTimeBetweenCoins)   
    --InstantiateCoin(Spawner1Pos,lua_table.CoinToSpawn)

end



function lua_table:Update()

    dt = lua_table.System:DT()
    --Spawner1Pos = lua_table.TransformFunc:GetPosition(lua_table.PlaceSpawner1uID)

    if lua_table.ThrowCoins
    then
        currentTimeToSpawn = currentTimeToSpawn + dt
        if(currentTimeToSpawn>= randTime)
        then
            for i,j in pairs(SpawnerList) do

            InstantiateCoin(j,lua_table.CoinToSpawn)
            randTime =  lua_table.System:RandomNumberInRange(lua_table.MinTimeBetweenCoins,lua_table.MaxTimeBetweenCoins)   
            currentTimeToSpawn = 0

            end
        end
    end

end


return lua_table
end