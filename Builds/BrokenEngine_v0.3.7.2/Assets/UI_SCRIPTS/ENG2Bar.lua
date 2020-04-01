function    GetTableENG2Bar()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()

--VARIABLES


lua_table.energylocal2 = 0--he cambiado energy por 0, ya que no hacia nada, si peta devolverlo
local ENGID = 0--ID BARRA ENERGIA INGAME


local P2ID = 0--ID jaskier
lua_table.engP2 = {}


--FUNCTIONS

function UpdateEnergyBar(id, percentage)

    local result = 0

    if id == ENGID
    then
        lua_table["System"]:LOG ("ENG2 BEFORE PAINTING BAR: " .. percentage)
        lua_table["UI"]:SetUIBarPercentage(id, percentage)

        result = percentage
        
    end

    return result

end


--MAIN CODE

function lua_table:Awake()
    lua_table["System"]:LOG ("This Log was called from ENG2 Script on AWAKE")

    ENGID = lua_table["GameObject"]:FindGameObject("ENG2")
    P2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
    lua_table.engP2 = lua_table["GameObject"]:GetScript(P2ID)

end

function lua_table:Start()
    lua_table["System"]:LOG ("This Log was called from ENG2 Script on START")
    
    lua_table.energylocal2 = lua_table.engP2.current_energy
    lua_table["System"]:LOG ("INITIAL ENG2 IN START : " .. lua_table.energylocal2)
    

end

function lua_table:Update()
    dt = lua_table["System"]:DT ()
    lua_table.energylocal2 = lua_table.engP2.current_energy
    lua_table["System"]:LOG ("ENG2 IN UPDATE BEFORE FUNCTION : " .. lua_table.energylocal2)
   
    
        if lua_table.energylocal2 > 0
        then
            lua_table.energylocal2 = UpdateEnergyBar(ENGID, lua_table.energylocal2)
        end
      


end

    return lua_table
end