
function    GetTableNewScript2()
local lua_table = {}

lua_table["Functions"] = Debug.Scripting ()

--Main Code
function lua_table:Awake()
    lua_table["Functions"]:LOG("This Log was called from LUA testing a table on AWAKE")
end

function lua_table:Start()
    lua_table["Functions"]:LOG("This Log was called from LUA testing a table on START")
end

function lua_table:Update()
    dt = lua_table["Functions"]:dt ()
    boleasa = lua_table["Functions"]:GetPosInFrustum (0, 0, 0)
    lua_table["Functions"]:LOG("POINT IN FRUSTUM: " .. boleasa)
end

return lua_table
end