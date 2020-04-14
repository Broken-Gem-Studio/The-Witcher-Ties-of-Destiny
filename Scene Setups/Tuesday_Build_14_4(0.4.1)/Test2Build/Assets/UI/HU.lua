function GetTableHU()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    
    local COMBO_LIGHT_ID = 0
    local COMBO_HEAVY_ID = 0
    local COMBO_LIGHT2_ID = 0
    local COMBO_HEAVY2_ID = 0
    
    
    local timer = 0
    local timer1 = 0
    local timer2 = 0
    
    local first = false--FIRST SPACE ALREADY OCUPPIED OR NOT
    local second = false
    
    local p1ID = 0
    lua_table.p1 = {}

    function lua_table:Awake()
        lua_table["System"]:LOG ("WORKING")
    
        COMBO_LIGHT_ID = lua_table["GameObject"]:FindGameObject("COMBO1")--exact name of gameobject
        COMBO_HEAVY_ID = lua_table["GameObject"]:FindGameObject("COMBO2")--exact name of gameobject
        COMBO_LIGHT2_ID = lua_table["GameObject"]:FindGameObject("COMBO3")--exact name of gameobject
        COMBO_HEAVY2_ID = lua_table["GameObject"]:FindGameObject("COMBO4")--exact name of gameobject

        p1ID = lua_table["GameObject"]:FindGameObject("Geralt")
        lua_table.p1 = lua_table["GameObject"]:GetScript(p1ID)
    end
    
    function lua_table:Start()
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT2_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY2_ID)
    end
    
    function lua_table:Update()
        timer = lua_table["System"]:GameTime()
    
        --PRIMER HUECO
        if lua_table.p1.current_state == 8 and first == false --aqui recibimos bool de que geralt ha usado el primer light
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT_ID)
            timer1 = lua_table["System"]:GameTime()
            first = true--bool que utilizamos como puerta para el siguiente input del combo
            
        end
    
        if lua_table.p1.current_state == 11 and first == false --aqui recibimos bool de que geralt ha usado el primer heavy
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY_ID)
            timer1 = lua_table["System"]:GameTime()
            first = true--bool que utilizamos como puerta para el siguiente input del combo
            
        end
    
        if timer - timer1 >= 2--ventana para el siguiente combo
        then
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY_ID)
            first = false
        else
        end
    

        --SEGUNDO HUECO
        if lua_table.p1.current_state == 9 and second == false and first == true--aqui recibimos bool de que geralt ha usado el primer light
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT2_ID)
            timer2 = lua_table["System"]:GameTime()
            second = true--bool que utilizamos como puerta para el siguiente input del combo
        end
    
        if lua_table.p1.current_state == 12  and second == false and first == true --aqui recibimos bool de que geralt ha usado el primer heavy
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY2_ID)
            timer2 = lua_table["System"]:GameTime()
            second = true--bool que utilizamos como puerta para el siguiente input del combo
            
        end
    
        if timer - timer2 >= 2--aqui le quitamos el espacio que creemos que usa para hacer el segundo input
        then
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT2_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY2_ID)
            second = false
        end
    
    
    end
    
    return lua_table
    end