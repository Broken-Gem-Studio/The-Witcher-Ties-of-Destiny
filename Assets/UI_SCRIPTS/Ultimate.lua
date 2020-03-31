function GetTableUltimate()
local lua_table = {}
lua_table["GameObject"] = Scripting.GameObject()
lua_table["Inputs"] = Scripting.Inputs()
lua_table["System"] = Scripting.System()
lua_table["UI"] = Scripting.Interface()
lua_table["Transform"] = Scripting.Transform()

local ULTID = 0
lua_table.ultimatelocal = 0

local P1ID = 0--ID GERALT
lua_table.ultiP1 = {}

function UpdateUltimate(id, percentage)

    local result = 0

    if id == ULTID
    then
        lua_table.ultimatelocal = lua_table.ultimatelocal + percentage--sumamos la barra de la ulti PUEDE HABER PROBLEMAS DE QUE SALGA EL DOBLE, SI ES ASI DIVIDIR ENTRE 2
        lua_table["System"]:LOG ("ULTI AFTER ACTION: " .. lua_table.ultimatelocal)
        lua_table["UI"]:SetUICircularBarPercentage(id, lua_table.ultimatelocal)
         

            result =  lua_table.ultimatelocal
    end

    return result
end

function lua_table:Awake()
    lua_table["System"]:LOG ("This Log was called from ULTI Script on AWAKE")

    ULTID = lua_table["GameObject"]:FindGameObject("ULTI")
    P1ID = lua_table["GameObject"]:FindGameObject("Geralt")
    lua_table.ultiP1 = lua_table["GameObject"]:GetScript(P1ID)

end

function lua_table:Start()
    lua_table["System"]:LOG ("This Log was called from ULTI Script on START")
    lua_table.ultimatelocal = lua_table.ultiP1.current_ultimate
    lua_table["System"]:LOG ("ULTIMATE FROM SCRIPT: " .. lua_table.ultiP1.current_ultimate)--CHECKING VALUE ULTI FROM CARLES SCRIPT
    lua_table.ultimatelocal = UpdateUltimate(ULTID, lua_table.ultimatelocal)--iniciamos la ulti a 0
end

function lua_table:Update()

    if lua_table.ultimatelocal < 100--MIENTRAS NO LLEGEU AL TOPE, ACTUALIZAMOS BARRA ULTI
    then
        --lua_table.ultimate = UpdateUltimate(ULTID, 10)
        lua_table.ultimatelocal = UpdateUltimate(ULTID, lua_table.ultimatelocal)
    end

end

return lua_table
end