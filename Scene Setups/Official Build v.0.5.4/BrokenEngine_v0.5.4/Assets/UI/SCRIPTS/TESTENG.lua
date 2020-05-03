function    GetTableTESTENG()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()

--VARIABLES


lua_table.energylocal = 0--he cambiado energy por 0, ya que no hacia nada, si peta devolverlo
local ENGID = 0--ID BARRA ENERGIA INGAMe
lua_table.energylocal2 = 0--he cambiado energy por 0, ya que no hacia nada, si peta devolverlo
local ENGID2 = 0--ID BARRA ENERGIA INGAME


local P1ID = 0--ID GERALT
lua_table.engP1 = {}
local P2ID = 0--ID GERALT
lua_table.engP2 = {}


--FUNCTIONS

function UpdateEnergyBar(id, percentage)

    local result = 0

    if id == ENGID
    then
        lua_table["System"]:LOG ("ENG BEFORE PAINTING BAR: " .. percentage)
        lua_table["UI"]:SetUIBarPercentage(percentage, id)

        result = percentage
        
    elseif id == ENGID2
    then
        lua_table["System"]:LOG ("ENG2 BEFORE PAINTING BAR: " .. percentage)
        lua_table["UI"]:SetUIBarPercentage(percentage, id)

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

    ENGID2 = lua_table["GameObject"]:FindGameObject("ENG2")
    P2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
    lua_table.engP2 = lua_table["GameObject"]:GetScript(P2ID)

end

function lua_table:Start()
    lua_table["System"]:LOG ("This Log was called from ENG Script on START")
    
    lua_table.energylocal = lua_table.engP1.current_energy
    lua_table["System"]:LOG ("INITIAL ENG IN START : " .. lua_table.energylocal)

    lua_table.energylocal2 = lua_table.engP2.current_energy
    lua_table["System"]:LOG ("INITIAL ENG2 IN START : " .. lua_table.energylocal2)
    

end

function lua_table:Update()
    dt = lua_table["System"]:DT ()
    lua_table.energylocal = lua_table.engP1.current_energy
    lua_table["System"]:LOG ("ENG IN UPDATE BEFORE FUNCTION : " .. lua_table.energylocal)
    lua_table.energylocal2 = lua_table.engP2.current_energy
    lua_table["System"]:LOG ("ENG2 IN UPDATE BEFORE FUNCTION : " .. lua_table.energylocal2)
   
   
    
        if lua_table.energylocal > 0
        then
            lua_table.energylocal = UpdateEnergyBar(ENGID, lua_table.energylocal)
        end
      
        if lua_table.energylocal2 > 0
        then
            lua_table.energylocal2 = UpdateEnergyBar(ENGID2, lua_table.energylocal2)
        end

        --audio fx

        if lua_table["Inputs"]:IsGamepadButton(1,"BUTTON_A","DOWN") and lua_table.energylocal < lua_table.engP1.evade_cost or
        lua_table["Inputs"]:IsGamepadButton(2,"BUTTON_A","DOWN") and lua_table.energylocal2 < lua_table.engP2.evade_cost
        then
            lua_table["Audio"]:PlayAudioEvent("Play_No_energy")
         end


end

    return lua_table
end