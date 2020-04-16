function    GetTableTESTHP()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()

--VARIABLES

lua_table.hplocal = 0
local HPID = 0--ID BARRA HP INGAME
lua_table.hplocal2 = 0
local HPID2 = 0

local P1ID = 0--ID GERALT
lua_table.hpP1 = {}

local P2ID = 0--ID GERALT
lua_table.hpP2 = {}

--FUNCTIONS

function UpdateHealthBar(id, percentage)

    local result = 0

    if id == HPID
    then
        lua_table["System"]:LOG ("HP BEFORE PAINTING BAR: " .. percentage)
        lua_table["UI"]:SetUIBarPercentage(percentage, id)

        result =  percentage
    elseif id == HPID2
    then
        lua_table["System"]:LOG ("HP2 BEFORE PAINTING BAR: " .. percentage)
        lua_table["UI"]:SetUIBarPercentage(percentage, id)

        result =  percentage

    end

    return result

end


--MAIN CODE

function lua_table:Awake()
    lua_table["System"]:LOG ("This Log was called from HPBAR Script on AWAKE")

    HPID = lua_table["GameObject"]:FindGameObject("HP")
    HPID2 = lua_table["GameObject"]:FindGameObject("HP2")
    P1ID = lua_table["GameObject"]:FindGameObject("Geralt")
    lua_table.hpP1 = lua_table["GameObject"]:GetScript(P1ID)
    P2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
    lua_table.hpP2 = lua_table["GameObject"]:GetScript(P2ID)


end

function lua_table:Start()
    lua_table["System"]:LOG ("This Log was called from HPBAR Script on START")
    
    lua_table.hplocal = lua_table.hpP1.current_health--MAYBE THIS SHOULD GO TO UPDATE IF IT DOENT CHANGE WHEN LOWERINMG HP FROM SCRIPT
    lua_table["System"]:LOG ("INITIAL HP BEFORE ADAPTING TO HUNDRED : " .. lua_table.hplocal)
    lua_table.hplocal = lua_table.hplocal / 2--FIRST ATTEMPT TO ADJUST GERALT HP TO 100 FOR THE BAR NOT ENLARGING

    lua_table.hplocal2 = lua_table.hpP2.current_health--MAYBE THIS SHOULD GO TO UPDATE IF IT DOENT CHANGE WHEN LOWERINMG HP FROM SCRIPT
    lua_table["System"]:LOG ("INITIAL HP2 BEFORE ADAPTING TO HUNDRED : " .. lua_table.hplocal2)
    lua_table.hplocal2 = lua_table.hplocal2 / 2--FIRST ATTEMPT TO ADJUST GERALT HP TO 100 FOR THE BAR NOT ENLARGING
end

function lua_table:Update()
    dt = lua_table["System"]:DT ()
    --lua_table.hplocal = lua_table.hpP1.current_health
    lua_table["System"]:LOG (" HP IN UPDATE BEFORE FUNCTION : " .. lua_table.hplocal)
    lua_table["System"]:LOG (" HP2 IN UPDATE BEFORE FUNCTION : " .. lua_table.hplocal2)
    
        
        
        if lua_table.hplocal > 0
        then
            lua_table.hplocal = UpdateHealthBar(HPID, lua_table.hplocal)--igual poner hplocal en arg da `Problema y hay que usar lua_table.hpP1.curent_health
        end
      
        if lua_table.hplocal2 > 0
        then
            lua_table.hplocal2 = UpdateHealthBar(HPID2, lua_table.hplocal2)--igual poner hplocal en arg da `Problema y hay que usar lua_table.hpP1.curent_health
        end
         

      

end

    return lua_table
end