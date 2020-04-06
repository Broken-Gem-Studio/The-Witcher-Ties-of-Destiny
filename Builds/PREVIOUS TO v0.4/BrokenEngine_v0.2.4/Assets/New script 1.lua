local Functions = Debug.Scripting()

function	GetTableGeraltScript()
local lua_table = {}
lua_table.Functions = Debug.Scripting()

--Main Code
function lua_table:Awake()
    lua_table.Functions:LOG("This Log was called from LUA testing a table on AWAKE")
end

function lua_table:Start()
    lua_table.Functions:LOG("This Log was called from LUA testing a table on START")
end

function lua_table:Update()

	dt = lua_table.Functions:dt()
    lua_table.Functions:SetCurrentAnimationSpeed(100)
	
end

return lua_table
end