function GetTablePotion_Script()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Physics = Scripting.Physics()

lua_table.item_id = 0
lua_table.my_UID = 0
lua_table.player_owner = 0
local passed_time = 0

function lua_table:Awake()
	lua_table.myUID = lua_table.GameObject:GetMyUID()
end

function lua_table:Start()
	passed_time = lua_table.System:GameTime()
end


function lua_table:Update()
local current_time = lua_table.System:GameTime()
	if current_time - passed_time > 3
	then
		--lua_table.Physics:FreezePositionX(true,lua_table.myUID)
		--lua_table.Physics:FreezePositionX(true,lua_table.myUID)
	end
	if current_time - passed_time > 120
	then
		lua_table.GameObject:DestroyGameObject(lua_table.myUID)
	end
  
end

return lua_table
end