function GetTableCoin_Behaviour()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.GameObjectFunctions = Scripting.GameObject()

local myUID = 0

function lua_table:Awake()

    myUID = lua_table.GameObjectFunctions:GetMyUID()

end

function lua_table:OnCollisionEnter()

    lua_table.PhysicsFunctions:SetKinematic(true,myUID)
    
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end