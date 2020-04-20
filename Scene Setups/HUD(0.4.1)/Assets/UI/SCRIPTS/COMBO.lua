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
    local COMBO_MEDIUM_ID = 0
    local COMBO_MEDIUM2_ID = 0
    local COMBO_MEDIUM3_ID = 0
    local COMBO_MEDIUM4_ID = 0

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

    ------------------

    local COMBO_LIGHT_ID_J = 0
    local COMBO_HEAVY_ID_J = 0
    local COMBO_LIGHT2_ID_J = 0
    local COMBO_HEAVY2_ID_J = 0
    local COMBO_LIGHT3_ID_J = 0
    local COMBO_HEAVY3_ID_J = 0
    local COMBO_LIGHT4_ID_J = 0
    local COMBO_HEAVY4_ID_J = 0
    local COMBO_MEDIUM_ID_J = 0
    local COMBO_MEDIUM2_ID_J = 0
    local COMBO_MEDIUM3_ID_J = 0
    local COMBO_MEDIUM4_ID_J = 0

    local SWORD_UP_ID_J = 0
    local SWORD_DOWN_ID_J = 0
    local SWORD_FIRE_ID_J = 0
    local sword_on_J = false
    local sword_off_J = false
    local combo_J = false

    local first_J = false--spaces
    local second_J = false
    local third_J = false
    local fourth_J = false

    local p2ID = 0
    lua_table.p2 = {}



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
        COMBO_MEDIUM_ID = lua_table["GameObject"]:FindGameObject("COMBO1.5")--exact name of gameobject
        COMBO_MEDIUM2_ID = lua_table["GameObject"]:FindGameObject("COMBO3.5")--exact name of gameobject
        COMBO_MEDIUM3_ID = lua_table["GameObject"]:FindGameObject("COMBO5.5")--exact name of gameobject
        COMBO_MEDIUM4_ID = lua_table["GameObject"]:FindGameObject("COMBO7.5")--exact name of gameobject

        SWORD_UP_ID = lua_table["GameObject"]:FindGameObject("SWORDUP")
        SWORD_DOWN_ID = lua_table["GameObject"]:FindGameObject("SWORDOWN")
        SWORD_FIRE_ID = lua_table["GameObject"]:FindGameObject("SWORDCOMBO")

        p1ID = lua_table["GameObject"]:FindGameObject("Geralt")
        lua_table.p1 = lua_table["GameObject"]:GetScript(p1ID)
        --------------

        COMBO_LIGHT_ID_J = lua_table["GameObject"]:FindGameObject("COMBO1J")--exact name of gameobject
        COMBO_HEAVY_ID_J = lua_table["GameObject"]:FindGameObject("COMBO2J")--exact name of gameobject
        COMBO_LIGHT2_ID_J = lua_table["GameObject"]:FindGameObject("COMBO3J")--exact name of gameobject
        COMBO_HEAVY2_ID_J = lua_table["GameObject"]:FindGameObject("COMBO4J")--exact name of gameobject
        COMBO_LIGHT3_ID_J = lua_table["GameObject"]:FindGameObject("COMBO5J")--exact name of gameobject
        COMBO_HEAVY3_ID_J = lua_table["GameObject"]:FindGameObject("COMBO6J")--exact name of gameobject
        COMBO_LIGHT4_ID_J = lua_table["GameObject"]:FindGameObject("COMBO7J")--exact name of gameobject
        COMBO_HEAVY4_ID_J = lua_table["GameObject"]:FindGameObject("COMBO8J")--exact name of gameobject
        COMBO_MEDIUM_ID_J = lua_table["GameObject"]:FindGameObject("COMBO1.5J")--exact name of gameobject
        COMBO_MEDIUM2_ID_J = lua_table["GameObject"]:FindGameObject("COMBO3.5J")--exact name of gameobject
        COMBO_MEDIUM3_ID_J = lua_table["GameObject"]:FindGameObject("COMBO5.5J")--exact name of gameobject
        COMBO_MEDIUM4_ID_J = lua_table["GameObject"]:FindGameObject("COMBO7.5J")--exact name of gameobject

        SWORD_UP_ID_J = lua_table["GameObject"]:FindGameObject("GUITARUP")
        SWORD_DOWN_ID_J = lua_table["GameObject"]:FindGameObject("GUITARDOWN")
        SWORD_FIRE_ID_J = lua_table["GameObject"]:FindGameObject("GUITARCOMBO")

        p2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
        lua_table.p2 = lua_table["GameObject"]:GetScript(p2ID)

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
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM2_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM3_ID)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM4_ID)

        sword_off = true--la espada empieza envainada
        combo = false
        lua_table["UI"]:MakeElementInvisible("Image", SWORD_UP_ID)--SWORD ENFUNDADA AL COMIENZO
        lua_table["UI"]:MakeElementInvisible("Image", SWORD_FIRE_ID)--SWORD ENFUNDADA AL COMIENZO

        --------------------------

        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT2_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY2_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT3_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY3_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT4_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY4_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM2_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM3_ID_J)
        lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM4_ID_J)

        --sword_off_J = true--la espada empieza envainada
        combo_J = false
        --lua_table["UI"]:MakeElementInvisible("Image", SWORD_UP_ID_J)--SWORD ENFUNDADA AL COMIENZO
        lua_table["UI"]:MakeElementInvisible("Image", SWORD_FIRE_ID_J)--SWORD ENFUNDADA AL COMIENZO
        lua_table["UI"]:MakeElementInvisible("Image", SWORD_DOWN_ID_J)--JASKIER HA DE TENER SIEMPRE EL LAUD ACTIVO


    end
    
    function lua_table:Update()
        timer = lua_table["System"]:GameTime()
        --lua_table["System"]:LOG("COMBO: " .. lua_table.p1.combo_num )
        --lua_table["System"]:LOG("STATE: " .. lua_table.p1.current_state )
        lua_table["System"]:LOG("COMBO2: " .. lua_table.p2.note_num )
        lua_table["System"]:LOG("STATE2: " .. lua_table.p2.current_state )

        --GERALT
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
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM2_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM3_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM4_ID)

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

        if lua_table.p1.combo_num >= 4 and combo == false--para borrar al cuarto input si no hace combo
        then

            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT2_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY2_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT3_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY3_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_LIGHT4_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_HEAVY4_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM2_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM3_ID)
            lua_table["UI"]:MakeElementInvisible("Image", COMBO_MEDIUM4_ID)

            first = false
            second = false
            third = false
            fourth = false
            lua_table.p1.combo_num = 0--ojo con esto

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
        if lua_table.p1.current_state == 8 and first == false and lua_table.p1.combo_num == 1--PRIMER LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT_ID)
            first = true
            
            
        end 

        if lua_table.p1.current_state == 14 and first == false and lua_table.p1.combo_num == 1 --PRIMER HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY_ID)
            first = true
            
        end 

        if lua_table.p1.current_state == 11 and first == false and lua_table.p1.combo_num == 1---PRIMER MEDIUM
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_MEDIUM_ID)
            first = true
            
        end 
-----------------------------
        if lua_table.p1.current_state == 9 and second == false and first == true and lua_table.p1.combo_num == 2 --SECGUNDO LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT2_ID)
            second = true
            
        end 


        if lua_table.p1.current_state == 15  and second == false and first == true and lua_table.p1.combo_num == 2 --SECGUNDO HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY2_ID)
            second  = true
            
        end 

        if lua_table.p1.current_state == 12  and second == false and first == true and lua_table.p1.combo_num == 2 --SECGUNDO MEDIUM
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_MEDIUM2_ID)
            second  = true
            
        end
--------------------------------
        if lua_table.p1.current_state == 10 and third == false and lua_table.p1.combo_num == 3--tercer LIGHT
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT3_ID)
            third = true
            
        end 

        if lua_table.p1.current_state == 16  and third == false and lua_table.p1.combo_num == 3 --tercer HEAVY
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY3_ID)
            third  = true
            
        end 

        if lua_table.p1.current_state == 13  and third == false and lua_table.p1.combo_num == 3--tercer MEDIUM
        then
            lua_table["UI"]:MakeElementVisible("Image", COMBO_MEDIUM3_ID)
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

        --JASKIER

        --COMPORTAMIENTO SWORD/GUITAR

        if lua_table.p2.ability_performed == true and combo_J == true--if ability is activated and combo is true(note_stack)
        then

            lua_table["UI"]:MakeElementInvisible("Image", SWORD_DOWN_ID_J)
            lua_table["UI"]:MakeElementInvisible("Image", SWORD_UP_ID_J)
            lua_table["UI"]:MakeElementVisible("Image", SWORD_FIRE_ID_J)
            combo_J = false

            first_J = false
            second_J = false
            third_J = false
            fourth_J = false

        end
        -------------------------------------

        lua_table["System"]:LOG("STACK 1: " .. lua_table.p2.note_stack[1])

        if first_J == false and lua_table.p2.note_stack[1] == 'N'
        then
            if lua_table.p2.current_state == 8 or lua_table.p2.current_state == 9 or lua_table.p2.current_state == 10
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT_ID_J)
                first_J = true
            elseif lua_table.p2.current_state == 11 or lua_table.p2.current_state == 12 or lua_table.p2.current_state == 13
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBO_MEDIUM_ID_J)
                first_J = true
            elseif lua_table.p2.current_state == 14 or lua_table.p2.current_state == 15 or lua_table.p2.current_state == 16
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY_ID_J)
                first_J = true
            end
        end
        
        lua_table["System"]:LOG("STACK 2: " .. lua_table.p2.note_stack[2])

        if second_J == false and lua_table.p2.note_stack[2] == 'N' and lua_table.p2.note_stack[1] ~= 'N'--AHORA SIEMPRE ENTRA , PENSAR SOLUCION PARA QUE NO ENTRE HASTA QUE FIRST ESTE OCUPADA Y HAGA OTRO NUEVO INPUT
        then
            if lua_table.p2.current_state == 8 or lua_table.p2.current_state == 9 or lua_table.p2.current_state == 10
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBO_LIGHT2_ID_J)
                second_J = true
            elseif lua_table.p2.current_state == 11 or lua_table.p2.current_state == 12 or lua_table.p2.current_state == 13
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBO_MEDIUM2_ID_J)
                second_J = true
            elseif lua_table.p2.current_state == 14 or lua_table.p2.current_state == 15 or lua_table.p2.current_state == 16
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBO_HEAVY2_ID_J)
                second_J = true
            end
        end
        

    
    end
    
    return lua_table
    end