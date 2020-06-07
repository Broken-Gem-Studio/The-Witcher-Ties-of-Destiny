function GetTableRound()
local lua_table = {}
lua_table.System = Scripting.System()

lua_table.enemy1 = 0
lua_table.enemy2 = 0
lua_table.enemy3 = 0
lua_table.enemy4 = 0
lua_table.enemy5 = 0
lua_table.enemy6 = 0

lua_table.num_e1 = 0
lua_table.num_e2 = 0
lua_table.num_e3 = 0
lua_table.num_e4 = 0
lua_table.num_e5 = 0
lua_table.num_e6 = 0

lua_table.final_enemy = 0
lua_table.is_final = false

lua_table.spawn_pos1 = 0
lua_table.spawn_pos2 = 0
lua_table.spawn_pos3 = 0

function lua_table:Spawn()
end

function lua_table:Awake()
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end