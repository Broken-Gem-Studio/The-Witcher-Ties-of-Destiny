function GetTableExperience()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()


local experience = 1
local ID = 0
local percentage = 30

function LevelUp(id)

    experience = experience + 1
    lua_table["UI"]:SetTextNumber( id, experience)
    

end

function lua_table:Awake()

    ID = lua_table["GameObject"]:FindGameObject("test")

end

function lua_table:Start()
    
   

end

function lua_table:Update()

    if lua_table["Inputs"]:KeyDown ("A") --or time > 5--si pulsamos a o si pasan 5 seg
    then 

       LevelUp(ID)

    end

    if lua_table["Inputs"]:KeyDown ("D") --simple testeo de progress bar, borrar
    then

        lua_table["UI"]:SetUIBarPercentage(ID, percentage)

    end

end

    return lua_table
end