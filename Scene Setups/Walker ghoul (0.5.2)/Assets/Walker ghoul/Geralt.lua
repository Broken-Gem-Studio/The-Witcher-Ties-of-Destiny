function GetTableGeralt()

local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.ObjectFunctions = Scripting.GameObject()

lua_table.speed = 20 

function lua_table:Awake()
	lua_table.MyUUID = lua_table.ObjectFunctions:GetMyUID()
end

function lua_table:Start()
end

function lua_table:Update()
	local dt = lua_table.SystemFunctions:DT()

	if lua_table.InputFunctions:KeyRepeat("W")
	then
		lua_table.TransformFunctions:Translate(0, 0, lua_table.speed * dt, lua_table.MyUUID)
	elseif lua_table.InputFunctions:KeyRepeat("S")
	then
		lua_table.TransformFunctions:Translate(0, 0, -lua_table.speed * dt, lua_table.MyUUID)
	end
	
	if lua_table.InputFunctions:KeyRepeat("A")
	then
		lua_table.TransformFunctions:Translate(lua_table.speed * dt, 0, 0, lua_table.MyUUID)
	elseif lua_table.InputFunctions:KeyRepeat("D")
	then
		lua_table.TransformFunctions:Translate(-lua_table.speed * dt, 0, 0, lua_table.MyUUID)
	end	
end

return lua_table
end