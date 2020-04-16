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

    local SWORD_UP_ID = 0
    local SWORD_DOWN_ID = 0
    local SWORD_FIRE_ID = 0
    local sword_on = false
    local sword_off = false
    local combo = false
    
    local timer = 0

    local first = false--spaces
    local second = false
    local third = false
    local fourth = false

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
        SWORD_UP_ID = lua_table["GameObject"]:FindGameObject("SWORDUP")
        SWORD_DOWN_ID = lua_table["GameObject"]:FindGameObject("SWORDOWN")
        SWORD_FIRE_ID = lua_table["GameObject"]:FindGameObject("SWORDCOMBO")

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

        sword_off = true--la espada empieza envainada
        combo = false
        lua_table["UI"]:MakeElementInvisible("Image", SWORD_UP_ID)--SWORD ENFUNDADA AL COMIENZO
        lua_table["UI"]:MakeElementInvisible("Image", SWORD_FIRE_ID)--SWORD ENFUNDADA AL COMIENZO
    end
    
    function lua_table:Update()
        timer = lua_table["System"]:GameTime()
        lua_table["System"]:LOG("COMBO: " .. lua_table.p1.combo_num )
        lua_table["System"]:LOG("STATE: " .. lua_table.p1.current_state )

        if lua_table.p1.current_state < 8 and sword_on == true and combo == false
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

            lua_table["UI"]:MakeElementInvisible("Image", SWORD_UP_ID)
            lua_table["UI"]:MakeElementInvisible("Image", SWORD_FIRE_ID)
            lua_table["UI"]:MakeElementVisible("Image", SWORD_DOWN_ID)

            sword_off = true
            sword_on = false
            combo = false
            
        end


        --COMPORTAMIENTO SWORD/GUITAR
        if lua_table.p1.current_state >= 8 and lua_table.p1.current_state <= 16 and sword_off == true--cambiar por condicion de entrar en combate
        then
            lua_table["UI"]:MakeElementInvisible("Image", SWORD_DOWN_ID)
            lua_table["UI"]:MakeElementVisible("Image", SWORD_UP_ID)
            sword_off = false
            sword_on = true
        end

        if combo == true
        then

            lua_table["UI"]:MakeElementInvisible("Image", SWORD_DOWN_ID)
            lua_table["UI"]:MakeElementInvisible("Image", SWORD_UP_ID)
            lua_table["UI"]:MakeElementVisible("Image", SWORD_FIRE_ID)
            combo = false

        end

    -------------------------------------
        if lua_table.p1.current_state == 8 and first == false--PRIMER LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT_ID)
            first = true
            
            
        end 

        if lua_table.p1.current_state == 14 and first == false--PRIMER HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY_ID)
            first = true
            
        end 
-----------------------------
        if lua_table.p1.current_state == 9 and second == false --SECGUNDO LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT2_ID)
            second = true
            
        end 


        if lua_table.p1.current_state == 15  and second == false --SECGUNDO HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY2_ID)
            second  = true
            
        end 
--------------------------------
        if lua_table.p1.current_state == 10 and third == false--tercer LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT3_ID)
            third = true
            
        end 

        if lua_table.p1.current_state == 16  and third == false --tercer HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY3_ID)
            third  = true
            
        end 
---------------------------------
        if lua_table.p1.current_state == 17 and fourth == false--fourth LIGHT if first combo
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT4_ID)
            fourth = true
            combo = true
        end 

        if lua_table.p1.current_state == 18  and fourth == false --fourth HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY4_ID)
            fourth  = true
            combo = true
        end 

        if lua_table.p1.current_state == 19 and fourth == false--fourth LIGHT if third combo
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT4_ID)
            fourth = true
            combo = true
        end

    
    end
    
    return lua_table
    end