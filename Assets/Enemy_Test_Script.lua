function GetTableEnemy_Test_Script()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.GameObjectFunctions = Scripting.GameObject()

local my_GO_UID
lua_table.collider_damage = 50
lua_table.collider_effect = 2

function lua_table:OnTriggerEnter()
    local collider_GO = lua_table.PhysicsFunctions:OnTriggerEnter(my_GO_UID)

    lua_table.SystemFunctions:LOG(" ------------ I GOT HIT ------------ ")
end

function lua_table:Awake()
    my_GO_UID = lua_table.GameObjectFunctions:GetMyUID()
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end