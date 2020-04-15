function GetTableRand()
local lua_table = {}
lua_table.System = Scripting.System()

function lua_table:Awake()
	num1 = lua_table.System:RandomNumber()
	num2 = lua_table.System:RandomNumberInRange(1, 25)
	lua_table.System:LOG("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA " .. num1)
	lua_table.System:LOG("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB " .. num2)
end

function lua_table:Start()
	list = lua_table.System:RandomNumberList(10, 1, 25)
	for i = 1, #list
	do
		lua_table.System:LOG("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC " .. list[i])
	end
end

function lua_table:Update()
end

return lua_table
end