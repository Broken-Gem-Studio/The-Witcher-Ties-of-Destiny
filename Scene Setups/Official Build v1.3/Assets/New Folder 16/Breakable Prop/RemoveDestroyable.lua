function GetTableRemoveDestroyable()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObject = Scripting.GameObject()
lua_table.Physics = Scripting.Physics()

local passed_time = 0
lua_table.scale = 0.025
local deactivated = 0

function lua_table:Awake()
	lua_table.myUID = lua_table.GameObject:GetMyUID()
	lua_table.parent = lua_table.GameObject:GetGameObjectParent(lua_table.myUID)
end

function lua_table:Start()
	passed_time = lua_table.System:GameTime()
end

function lua_table:Update()
	local current_time = lua_table.System:GameTime()
	if current_time - passed_time > 5
	then
		if deactivated == 0 then
			lua_table.Physics:SetActiveCollider(false,lua_table.myUID)
			deactivated = 1
		end
		lua_table.scale = lua_table.scale - 0.0001 * 2
		lua_table.Transform:SetScale(lua_table.scale,lua_table.scale,lua_table.scale,lua_table.myUID)
	end
	
	if lua_table.scale <= 0
	then
		lua_table.GameObject:DestroyGameObject(lua_table.parent)
	end

end

return lua_table
end