function GetTableCOMBO()
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
    local COMBO_LIGHT3_ID = 0
    local COMBO_HEAVY3_ID = 0
    local COMBO_LIGHT4_ID = 0
    local COMBO_HEAVY4_ID = 0
    
    local timer = 0

    local first = false--spaces
    local second = false
    local third = false
    local fourth = false

    local first_light = false
    local first_heavy = false
    local second_light = false
    local second_heavy = false
    local third_light = false
    local third_heavy = false
    local fourth_light = false
    local fourth_heavy = false
    --local erase = true

    local p1ID = 0
    lua_table.p1 = {}

    function lua_table:Awake()
        lua_table["System"]:LOG ("WORKING")
    
        COMBO_LIGHT_ID = lua_table["GameObject"]:FindGameObject("COMBO1")--exact name of gameobject
        COMBO_HEAVY_ID = lua_table["GameObject"]:FindGameObject("COMBO2")--exact name of gameobject
        COMBO_LIGHT2_ID = lua_table["GameObject"]:FindGameObject("COMBO3")--exact name of gameobject
        COMBO_HEAVY2_ID = lua_table["GameObject"]:FindGameObject("COMBO4")--exact name of gameobject
        COMBO_LIGHT3_ID = lua_table["GameObject"]:FindGameObject("COMBO5")--exact name of gameobject
        COMBO_HEAVY3_ID = lua_table["GameObject"]:FindGameObject("COMBO6")--exact name of gameobject
        COMBO_LIGHT4_ID = lua_table["GameObject"]:FindGameObject("COMBO7")--exact name of gameobject
        COMBO_HEAVY4_ID = lua_table["GameObject"]:FindGameObject("COMBO8")--exact name of gameobject

        p1ID = lua_table["GameObject"]:FindGameObject("Geralt")
        lua_table.p1 = lua_table["GameObject"]:GetScript(p1ID)
    end
    
    function lua_table:Start()
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT2_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY2_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT3_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY3_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT4_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY4_ID)
    end
    
    function lua_table:Update()
        timer = lua_table["System"]:GameTime()
        lua_table["System"]:LOG("COMBO: " .. lua_table.p1.combo_num )
        lua_table["System"]:LOG("STATE: " .. lua_table.p1.current_state )
    
        if lua_table.p1.current_state == 8 and lua_table.p1.previous_state < 8 and first == false --PRIMER LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT_ID)
            first = true
            first_light = true
        end 

        if lua_table.p1.current_state == 11 and lua_table.p1.previous_state < 8 and first == false--PRIMER HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY_ID)
            first = true
            first_heavy = true
        end 
-----------------------------
        if lua_table.p1.current_state == 9 and second == false--SECGUNDO LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT2_ID)
            second = true
            second_light = true
        end 


        if lua_table.p1.current_state == 12  and second == false --SECGUNDO HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY2_ID)
            second  = true
            second_heavy = true
        end 
--------------------------------
        if lua_table.p1.current_state == 10 and third == false--tercer LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT3_ID)
            third = true
            third_light = true
        end 

        if lua_table.p1.current_state == 13  and third == false --tercer HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY3_ID)
            third  = true
            third_heavy = true
        end 
---------------------------------
        if lua_table.p1.current_state == 14 and fourth == false--fourth LIGHT if first combo
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT4_ID)
            fourth = true
        end 

        if lua_table.p1.current_state == 15  and fourth == false --fourth HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY4_ID)
            fourth  = true
        end 

        if lua_table.p1.current_state == 16 and fourth == false--fourth LIGHT if third combo
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT4_ID)
            fourth = true
        end

        --[==[
        if lua_table.p1.current_state == 10 --TERCER LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT3_ID)
        end 

        if lua_table.p1.current_state == 13 --TERCER HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY3_ID)
        end 

        --]==]

        

        --ESCONDERLAS
        if lua_table.p1.current_state < 8 
        then
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT2_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY2_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT3_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY3_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT4_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY4_ID)

            first = false
            second = false
            third = false
            fourth = false
            
        end

    
    end
    
    return lua_table
    end