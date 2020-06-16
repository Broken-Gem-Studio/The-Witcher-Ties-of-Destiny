function GetTableFakePlayers()
local lua_table = {}
lua_table.System = Scripting.System()

lua_table.collider_damage = 0
lua_table.collider_effect = 0
lua_table.current_state = 0

function lua_table:Awake()
end

function lua_table:Start()
end

function lua_table:Update()
    lua_table.collider_damage = 0
    lua_table.collider_effect = 0
    lua_table.current_state = 0
end

return lua_table
end