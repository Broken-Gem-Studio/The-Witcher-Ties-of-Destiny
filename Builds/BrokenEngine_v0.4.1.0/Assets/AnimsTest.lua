function GetTableAnimsTest()
local lua_table = {}
lua_table.System = Scripting.System()

function lua_table:Awake()
end

function lua_table:Start()
	lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",3.0)
end

function lua_table:Update()
end

return lua_table
end