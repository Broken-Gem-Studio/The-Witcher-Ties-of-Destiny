function GetTableUltimate2()
local lua_table = {}
lua_table["GameObject"] = Scripting.GameObject()
lua_table["Inputs"] = Scripting.Inputs()
lua_table["System"] = Scripting.System()
lua_table["UI"] = Scripting.Interface()
lua_table["Transform"] = Scripting.Transform()

local ULTID = 0
lua_table.ultimatelocal2 = 0

local P2ID = 0--ID GERALT
lua_table.ultiP2 = {}

function UpdateUltimate(id, percentage)

    local result = 0

    if id == ULTID
    then
        lua_table.ultimatelocal2 = (lua_table.ultimatelocal2 + percentage) / 2--sumamos la barra de la ulti PUEDE HABER PROBLEMAS DE QUE SALGA EL DOBLE, SI ES ASI DIVIDIR ENTRE 2
        lua_table["System"]:LOG ("ULTI2 AFTER ACTION: " .. lua_table.ultimatelocal2)
        lua_table["UI"]:SetUICircularBarPercentage(id, lua_table.ultimatelocal2)
         

            result =  lua_table.ultimatelocal2
    end

    return result
end

function lua_table:Awake()
    lua_table["System"]:LOG ("This Log was called from ULTI2 Script on AWAKE")

    ULTID = lua_table["GameObject"]:FindGameObject("ULTI2")
    P2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
    lua_table.ultiP2 = lua_table["GameObject"]:GetScript(P2ID)

end

function lua_table:Start()
    lua_table["System"]:LOG ("This Log was called from ULTI2 Script on START")
    lua_table.ultimatelocal2 = lua_table.ultiP2.current_ultimate
    lua_table["System"]:LOG ("ULTIMATE2 FROM SCRIPT: " .. lua_table.ultiP2.current_ultimate)--CHECKING VALUE ULTI FROM CARLES SCRIPT
    lua_table.ultimatelocal2 = UpdateUltimate(ULTID, lua_table.ultimatelocal2)--iniciamos la ulti a 0
end

function lua_table:Update()
    lua_table.ultimatelocal2 = lua_table.ultiP2.current_ultimate
    lua_table["System"]:LOG ("ULTIMATE2 UPDATE: " .. lua_table.ultimatelocal2)

    if lua_table.ultimatelocal2 < 100--MIENTRAS NO LLEGEU AL TOPE, ACTUALIZAMOS BARRA ULTI
    then
        lua_table.ultimatelocal2 = UpdateUltimate(ULTID, lua_table.ultimatelocal2)
    end

end

return lua_table
end