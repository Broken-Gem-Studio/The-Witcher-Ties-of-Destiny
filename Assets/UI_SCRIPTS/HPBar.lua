function    GetTableHPBar()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()

--VARIABLES

lua_table.hplocal = 0
local HPID = 0--ID BARRA HP INGAME

local P1ID = 0--ID GERALT
lua_table.hpP1 = {}

--FUNCTIONS

function UpdateHealthBar(id, dmg)

    local result = 0

    if id == HPID
    then
        
        lua_table.hplocal = lua_table.hplocal - dmg--mismo que con hp
        lua_table["System"]:LOG ("HP AFTER DMG: " .. lua_table.hplocal)
        lua_table["UI"]:SetUIBarPercentage(id, lua_table.hplocal)

        result =  lua_table.hplocal
    end

    return result

end


--MAIN CODE

function lua_table:Awake()
    lua_table["System"]:LOG ("This Log was called from HPBAR Script on AWAKE")

    HPID = lua_table["GameObject"]:FindGameObject("HP")
    P1ID = lua_table["GameObject"]:FindGameObject("Geralt")
    lua_table.hpP1 = lua_table["GameObject"]:GetScript(P1ID)


end

function lua_table:Start()
    lua_table["System"]:LOG ("This Log was called from HPBAR Script on START")
    
    lua_table.hplocal = lua_table.hpP1.current_health
    lua_table["System"]:LOG ("INITIAL HP BEFORE ADAPTING TO HUNDRED : " .. lua_table.hplocal)
    lua_table.hplocal = lua_table.hplocal / 5--FIRST ATTEMPT TO ADJUST GERALT HP TO 100 FOR THE BAR NOT ENLARGING
end

function lua_table:Update()
    dt = lua_table["System"]:DT ()
    
    
    
        if lua_table["Inputs"]:KeyDown ("A") --we simulate receiving a hit
        then 
            if lua_table.hplocal > 0
            then
                lua_table.hplocal = UpdateHealthBar(HPID, 10)--10% HEALTH
            end
      

        end    

      

end

    return lua_table
end