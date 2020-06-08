function GetTableCoin_Behaviour()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.GameObjectFunctions = Scripting.GameObject()

local myUID = 0
local scoreboard_script = {}
lua_table.final_coin = false

function lua_table:Awake()

    myUID = lua_table.GameObjectFunctions:GetMyUID()
    scoreboard_script = lua_table.GameObjectFunctions:GetScript(lua_table.GameObjectFunctions:FindGameObject("CoinSpawner"))

end

function lua_table:OnCollisionEnter()

    lua_table.PhysicsFunctions:SetKinematic(true,myUID)

    if lua_table.final_coin == true
    then
        scoreboard_script.coins_finished = scoreboard_script.coins_finished + 1
        lua_table.final_coin = false
    end
    
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end