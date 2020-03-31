function    GetTableENGBar()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()

--VARIABLES


lua_table.energylocal = 0--he cambiado energy por 0, ya que no hacia nada, si peta devolverlo
local ENGID = 0--ID BARRA ENERGIA INGAME


local P1ID = 0--ID GERALT
lua_table.engP1 = {}


--FUNCTIONS

function UpdateEnergyBar(id, percentage)

    local result = 0

    if id == ENGID
    then
        lua_table["System"]:LOG ("ENG BEFORE PAINTING BAR: " .. percentage)
        lua_table["UI"]:SetUIBarPercentage(id, percentage)

        result = percentage
        
    end

    return result

end


--MAIN CODE

function lua_table:Awake()
    lua_table["System"]:LOG ("This Log was called from ENG Script on AWAKE")

    ENGID = lua_table["GameObject"]:FindGameObject("ENG")
    P1ID = lua_table["GameObject"]:FindGameObject("Geralt")
    lua_table.engP1 = lua_table["GameObject"]:GetScript(P1ID)

end

function lua_table:Start()
    lua_table["System"]:LOG ("This Log was called from ENG Script on START")
    
    lua_table.energylocal = lua_table.engP1.current_energy
    lua_table["System"]:LOG ("INITIAL ENG IN START : " .. lua_table.energylocal)
    

end

function lua_table:Update()
    dt = lua_table["System"]:DT ()
    lua_table.energylocal = lua_table.engP1.current_energy
    lua_table["System"]:LOG ("ENG IN UPDATE BEFORE FUNCTION : " .. lua_table.energylocal)
   
    
        if lua_table.energylocal > 0
        then
            lua_table.energylocal = UpdateEnergyBar(ENGID, lua_table.energylocal)
        end
      


end

    return lua_table
end