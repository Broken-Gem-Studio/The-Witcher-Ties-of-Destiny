function GetTableCoin_Behaviour()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.AudioFunctions = Scripting.Audio()

local my_UID = 0
local first_collision = false
local scoreboard_script = {}
lua_table.final_coin = false

function lua_table:Awake()
    my_UID = lua_table.GameObjectFunctions:GetMyUID()
    scoreboard_script = lua_table.GameObjectFunctions:GetScript(lua_table.GameObjectFunctions:FindGameObject("CoinSpawner"))
end

function lua_table:OnCollisionEnter()
    lua_table.PhysicsFunctions:SetKinematic(true, my_UID)

    if not first_collision then
        lua_table.AudioFunctions:PlayAudioEventGO("Play_Coin_Collision", my_UID)
        first_collision = true
    end

    if lua_table.final_coin
    then
        if scoreboard_script ~= nil and scoreboard_script.coins_finished ~= nil then
            scoreboard_script.coins_finished = scoreboard_script.coins_finished + 1
        end
        lua_table.final_coin = false
    end
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end