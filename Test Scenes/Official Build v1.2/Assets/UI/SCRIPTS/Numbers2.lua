function GetTableNumbers2()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()


local HPID = 0--id del gameobject
lua_table.hpValue2 = {}
--local ENGID = 0
--lua_table.engValue2 = {}
local HPNUMBER2 = 0--id num player2
--local ENGNUMBER2 = 0--ID num player2

function lua_table:Awake()

    HPID = lua_table["GameObject"]:FindGameObject("HP2")
    lua_table.hpValue2 = lua_table["GameObject"]:GetScript(HPID)
    HPNUMBER2 = lua_table["GameObject"]:FindGameObject("HPNUMBER2")
    
    --ENGID = lua_table["GameObject"]:FindGameObject("ENG2")
    --lua_table.engValue2 = lua_table["GameObject"]:GetScript(ENGID)
    --ENGNUMBER2 = lua_table["GameObject"]:FindGameObject("ENGNUMBER2")
    
end

function lua_table:Start()

    lua_table["UI"]:SetTextNumber(lua_table.hpValue2.hplocal2, HPNUMBER2)--variables hplocal energy local de los scripts para el p2
    --lua_table["UI"]:SetTextNumber(lua_table.engValue2.energylocal2, ENGNUMBER2)
end

function lua_table:Update()

    lua_table["System"]:LOG ("VALUE HP2 FROM TEXT SCRIPT: " .. lua_table.hpValue2.hplocal2)
    --lua_table["System"]:LOG ("VALUE ENG2 FROM TEXT SCRIPT: " .. lua_table.engValue2.energylocal2)
    
    
    --lua_table["UI"]:SetTextNumber(lua_table.engValue2.energylocal2, ENGNUMBER2)
    
    
    
    lua_table["UI"]:SetTextNumber(lua_table.hpValue2.hplocal2, HPNUMBER2)
    
end

    return lua_table
end