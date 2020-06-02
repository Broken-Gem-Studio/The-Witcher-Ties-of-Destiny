function GetTableNumbers()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()


local HPID = 0--id del gameobject
lua_table.hpValue = {}
--local ENGID = 0
--lua_table.engValue = {}
local HPNUMBER = 0--id num player 1
--local ENGNUMBER = 0--ID num player 1

function lua_table:Awake()

    HPID = lua_table["GameObject"]:FindGameObject("HP")
    lua_table.hpValue = lua_table["GameObject"]:GetScript(HPID)
    HPNUMBER = lua_table["GameObject"]:FindGameObject("HPNUMBER")
    
    --ENGID = lua_table["GameObject"]:FindGameObject("ENG")
    --lua_table.engValue = lua_table["GameObject"]:GetScript(ENGID)
    --ENGNUMBER = lua_table["GameObject"]:FindGameObject("ENGNUMBER")
    
end

function lua_table:Start()

    lua_table["UI"]:SetTextNumber(lua_table.hpValue.hplocal, HPNUMBER)
    --lua_table["UI"]:SetTextNumber(lua_table.engValue.energylocal, ENGNUMBER)
end

function lua_table:Update()

    lua_table["System"]:LOG ("VALUE HP FROM TEXT SCRIPT: " .. lua_table.hpValue.hplocal)
    --lua_table["System"]:LOG ("VALUE ENG FROM TEXT SCRIPT: " .. lua_table.engValue.energylocal)
    
    
    --lua_table["UI"]:SetTextNumber(lua_table.engValue.energylocal, ENGNUMBER)
    
    
    
    lua_table["UI"]:SetTextNumber(lua_table.hpValue.hplocal, HPNUMBER)
    
end

    return lua_table
end