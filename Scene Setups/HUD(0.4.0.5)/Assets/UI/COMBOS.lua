function GetTableCOMBOS()
local lua_table = {}
lua_table["GameObject"] = Scripting.GameObject()
lua_table["Inputs"] = Scripting.Inputs()
lua_table["System"] = Scripting.System()
lua_table["UI"] = Scripting.Interface()
lua_table["Transform"] = Scripting.Transform()

local specialID = 0
local special2ID = 0
local special3ID = 0

local timer = 0
local timer1 = 0
local timer2 = 0

local first = false
local second = false

function lua_table:Awake()
    lua_table["System"]:LOG ("WORKING")
    specialID = lua_table["GameObject"]:FindGameObject("SPECIAL")--exact name of gameobject
    special2ID = lua_table["GameObject"]:FindGameObject("SPECIAL2")--exact name of gameobject
end

function lua_table:Start()
    lua_table["UI"]:MakeElementInvisible("Image", specialID)
    lua_table["UI"]:MakeElementInvisible("Image", special2ID)
end

function lua_table:Update()
    timer = lua_table["System"]:GameTime()

    if lua_table["Inputs"]:KeyDown("A") and first == false --aqui recibimos bool de que geralt ha usado el primer light
    then
        lua_table["UI"]:MakeElementVisible("Image", specialID)
        timer1 = lua_table["System"]:GameTime()
        first = true--bool que utilizamos como puerta para el siguiente input del combo
    end

    if lua_table["Inputs"]:KeyDown("S") and second == false and first == true --aqui recibimos bool de que geralt ha usado el segundo light
    then
        lua_table["UI"]:MakeElementVisible("Image", special2ID)
        timer2 = lua_table["System"]:GameTime()
        second = true
    end

    if timer - timer1 >= 3
    then
        lua_table["UI"]:MakeElementInvisible("Image", specialID)
        first = false
    end

    if timer - timer2 >= 3
    then
        lua_table["UI"]:MakeElementInvisible("Image", special2ID)
        second = false
    end

end

return lua_table
end