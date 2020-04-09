
function    GetTableNewScript2()
local lua_table = {}

lua_table["Functions"] = Scripting.Debug ()
lua_table["Syst"] = Scripting.Systems ()

--Main Code
function lua_table:Awake()
    lua_table["Functions"]:LOG("This Log was called from LUA testing a table on AWAKE")
end

function lua_table:Start()
    lua_table["Functions"]:LOG("This Log was called from LUA testing a table on START")
end

function lua_table:Update()
    lua_table["Functions"]:LOG("This Log was called from LUA testing a table on UPDATE")
    lua_table["Syst"]:SetTextAndNuminTextComp("Espanita: x", 1.5)
end

return lua_table
end