function GetTablePotion_Script()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()

lua_table.item_id = 0
lua_table.my_UID = 0
lua_table.player_owner = 0

function lua_table:Awake()
	lua_table.myUID = lua_table.GameObject:GetMyUID()
end

function lua_table:Start()

end


function lua_table:Update()

  
end

return lua_table
end