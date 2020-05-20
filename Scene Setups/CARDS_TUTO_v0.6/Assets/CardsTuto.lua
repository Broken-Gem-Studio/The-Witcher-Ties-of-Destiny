function GetTableCardsTuto()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()

    --TEST CONDITIONS
    local step1 = false
    local step2 = false
    local continue_meter1 = 0
    local continue_meter2 = 0
    local continue_meter1_full = false
    local continue_meter2_full = false

    --GENERAL
    local CARD_PLAYER1_BUTTON = 0
    local CARD_PLAYER2_BUTTON = 0
    local P1_METER = 0
    local P2_METER = 0

    local EVADE = 0
    local SPECIAL = 0
    local ULTIMATE = 0
    local POTIS = 0
    local COMBOS = 0
    local ENEMY = 0
   
    

    local function HideCard()
        lua_table["UI"]:MakeElementInvisible("Image", EVADE)
        lua_table["UI"]:MakeElementInvisible("Image", SPECIAL)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIMATE)
        lua_table["UI"]:MakeElementInvisible("Image", POTIS)
        lua_table["UI"]:MakeElementInvisible("Image", COMBOS)
        lua_table["UI"]:MakeElementInvisible("Image", ENEMY)

        lua_table["UI"]:MakeElementInvisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementInvisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementInvisible("CiruclarBar", P1_METER)
        lua_table["UI"]:MakeElementInvisible("CiruclarBar", P2_METER)

    end
    
    function lua_table:Awake()
        EVADE = lua_table["GameObject"]:FindGameObject("EVADE")
        SPECIAL = lua_table["GameObject"]:FindGameObject("SPECIAL")
        ULTIMATE = lua_table["GameObject"]:FindGameObject("ULTI")
        COMBOS = lua_table["GameObject"]:FindGameObject("COMBO")
        POTIS = lua_table["GameObject"]:FindGameObject("POTIS")
        ENEMY = lua_table["GameObject"]:FindGameObject("ENEMY")
        
        CARD_PLAYER1_BUTTON = lua_table["GameObject"]:FindGameObject("CARDP1BUTTON")
        CARD_PLAYER2_BUTTON = lua_table["GameObject"]:FindGameObject("CARDP2BUTTON")
        P1_METER = lua_table["GameObject"]:FindGameObject("P1METER")
        P2_METER = lua_table["GameObject"]:FindGameObject("P2METER")

    
    end
    
    function lua_table:Start()
    
        HideCard()

    end
    
    function lua_table:Update()


        --TESTING LOGIC
        if lua_table["Inputs"]:KeyDown("A")
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step2 = false
            step1 = true
        end

        if lua_table["Inputs"]:KeyDown("D")
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step1 = false
            step2 =  true
        end


       --EVADE
       if step1 == true
       then

        HideCard()
        lua_table["UI"]:MakeElementVisible("Image", EVADE)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)
    

       end

       --ULTIMATE
       if step2 == true
       then

        HideCard()

        lua_table["UI"]:MakeElementVisible("Image", ULTIMATE)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)
       
       end
    
    --METERS

        lua_table["System"]:LOG("PERCENTAGE: " .. continue_meter1)
        lua_table["System"]:LOG("PERCENTAGE2: " .. continue_meter2)

        if continue_meter1 <= 0
        then
            continue_meter1 = 0
        end

        if continue_meter2 <= 0
        then
            continue_meter2 = 0
        end

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "REPEAT") and continue_meter1_full == false
        then
            continue_meter1 = continue_meter1 + 1
        else 
            continue_meter1 = continue_meter1 - 0.6
        end

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "REPEAT") and continue_meter2_full == false
        then
            continue_meter2 = continue_meter2 + 1
        else 
            continue_meter2 = continue_meter2 - 0.6
        end

        if continue_meter1 >= 100
        then
            continue_meter1_full = true
        end

        if continue_meter2 >= 100
        then
            continue_meter2_full = true
        end

        if continue_meter1_full == false
        then
            lua_table["UI"]:SetUICircularBarPercentage(continue_meter1, P1_METER)
        else
            lua_table["UI"]:SetUICircularBarPercentage(100, P1_METER)
        end

        if continue_meter2_full == false
        then
            lua_table["UI"]:SetUICircularBarPercentage(continue_meter2, P2_METER)
        else
            lua_table["UI"]:SetUICircularBarPercentage(100, P2_METER)
        end

    end
    
    return lua_table
    end