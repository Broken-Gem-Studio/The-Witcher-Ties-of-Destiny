function    GetTableENGBar()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()

--VARIABLES


lua_table.energylocal = energy
local ENGID = 0--ID BARRA ENERGIA INGAME


local P1ID = 0--ID GERALT
lua_table.engP1 = {}


--FUNCTIONS

function UpdateEnergyBar(id, wasted)

    local result = 0

    if id == ENGID
    then
        lua_table.energylocal = lua_table.energylocal - wasted--mismo que con hp
        lua_table["System"]:LOG ("ENG AFTER ACTION: " .. lua_table.energylocal)
        lua_table["UI"]:SetUIBarPercentage(id, lua_table.energylocal)

        result =  lua_table.energylocal
        
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
    lua_table["System"]:LOG ("INITIAL ENG BEFORE RECEIVING DAMAGE : " .. lua_table.energylocal)
    

end

function lua_table:Update()
    dt = lua_table["System"]:DT ()
    
   
    
        if lua_table["Inputs"]:KeyDown ("D") --we simulate receiving a hit
        then 
            if lua_table.energylocal > 0
            then
                lua_table.energylocal = UpdateEnergyBar(ENGID, 10)--10% energy
            end
      

        end    

      

end

    return lua_table
end