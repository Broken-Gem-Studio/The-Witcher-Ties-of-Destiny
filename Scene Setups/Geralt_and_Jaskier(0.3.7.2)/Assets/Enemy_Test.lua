function GetTableEnemy_Test()
local lua_table = {}
lua_table.System = Scripting.System()

lua_table.collider_damage = 40.0
lua_table.collider_effect = 0

function lua_table:Awake()
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end