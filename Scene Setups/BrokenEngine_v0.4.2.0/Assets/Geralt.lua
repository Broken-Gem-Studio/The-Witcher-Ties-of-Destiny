function GetTableGeralt()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Inputs = Scripting.Inputs()
lua_table.Object = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics = Scripting.Physics()

function lua_table:Awake()
	lua_table.MyUUID = lua_table.Object:GetMyUID()
end

function lua_table:Start()
end

function lua_table:Update()
	local dt = lua_table.System:DT() 
	if lua_table.Inputs:KeyRepeat("D")
	then
		lua_table.Transform:Translate(-50 * dt, 0, 0, lua_table.MyUUID)
	elseif lua_table.Inputs:KeyRepeat("A")
	then
		lua_table.Transform:Translate(50 * dt, 0, 0, lua_table.MyUUID)
	end
	
	if lua_table.Inputs:KeyRepeat("S")
	then
		lua_table.Transform:Translate(0, 0, -50 * dt, lua_table.MyUUID)
	elseif lua_table.Inputs:KeyRepeat("W")
	then
		lua_table.Transform:Translate(0, 0, 50 * dt, lua_table.MyUUID)
	end
end

return lua_table
end