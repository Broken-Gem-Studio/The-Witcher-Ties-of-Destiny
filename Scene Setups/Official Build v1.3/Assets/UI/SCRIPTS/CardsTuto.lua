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
    local step25 = false--ultimate2
    local step3 = false
    local step35 = false--special2
    local step4 = false
    local step5 = false
    local step55 = false--combo2
    local step6 = false
    local step65 = false--potis2
    local step7 = false

    local continue_meter1 = 0
    local continue_meter2 = 0
    local continue_meter1_full = false
    local continue_meter2_full = false

    --GENERAL
    local CARD_PLAYER1_BUTTON = 0
    local CARD_PLAYER2_BUTTON = 0
    local P1_METER = 0
    local P2_METER = 0

    local LEFT_ARROW = 0
    local RIGHT_ARROW = 0

    local EVADE = 0
    local SPECIAL = 0
    local SPECIAL2 = 0
    local ULTIMATE = 0
    local ULTIMATE2 = 0
    local POTIS = 0
    local POTIS2 = 0
    local COMBOS = 0
    local COMBOS2 = 0
    local ENEMY = 0
    local BONFIRE = 0
   
    --
    lua_table.tuto = {}--para pillar desde script Faure i pillar steps

    local function HideCard()
        lua_table["UI"]:MakeElementInvisible("Image", EVADE)
        lua_table["UI"]:MakeElementInvisible("Image", SPECIAL)
        lua_table["UI"]:MakeElementInvisible("Image", SPECIAL2)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIMATE)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIMATE2)
        lua_table["UI"]:MakeElementInvisible("Image", POTIS)
        lua_table["UI"]:MakeElementInvisible("Image", POTIS2)
        lua_table["UI"]:MakeElementInvisible("Image", COMBOS)
        lua_table["UI"]:MakeElementInvisible("Image", COMBOS2)
        lua_table["UI"]:MakeElementInvisible("Image", ENEMY)
        lua_table["UI"]:MakeElementInvisible("Image", BONFIRE)

        lua_table["UI"]:MakeElementInvisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementInvisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementInvisible("CiruclarBar", P1_METER)
        lua_table["UI"]:MakeElementInvisible("CiruclarBar", P2_METER)
        lua_table["UI"]:MakeElementInvisible("Image", LEFT_ARROW)
        lua_table["UI"]:MakeElementInvisible("Image", RIGHT_ARROW)


    end
    
    function lua_table:Awake()
        EVADE = lua_table["GameObject"]:FindGameObject("EVADE")
        SPECIAL = lua_table["GameObject"]:FindGameObject("SPECIAL")
        SPECIAL2 = lua_table["GameObject"]:FindGameObject("SPECIAL2")
        ULTIMATE = lua_table["GameObject"]:FindGameObject("ULTI")
        ULTIMATE2 = lua_table["GameObject"]:FindGameObject("ULTI2")
        COMBOS = lua_table["GameObject"]:FindGameObject("COMBO")
        COMBOS2 = lua_table["GameObject"]:FindGameObject("COMBO2")
        POTIS = lua_table["GameObject"]:FindGameObject("POTIS")
        POTIS2 = lua_table["GameObject"]:FindGameObject("POTIS2")
        ENEMY = lua_table["GameObject"]:FindGameObject("ENEMY")
        BONFIRE = lua_table["GameObject"]:FindGameObject("BONFIRE")
        
        CARD_PLAYER1_BUTTON = lua_table["GameObject"]:FindGameObject("CARDP1BUTTON")
        CARD_PLAYER2_BUTTON = lua_table["GameObject"]:FindGameObject("CARDP2BUTTON")
        P1_METER = lua_table["GameObject"]:FindGameObject("P1METER")
        P2_METER = lua_table["GameObject"]:FindGameObject("P2METER")
        LEFT_ARROW = lua_table["GameObject"]:FindGameObject("LEFT")
        RIGHT_ARROW = lua_table["GameObject"]:FindGameObject("RIGHT")
    
    end
    
    function lua_table:Start()
    
        HideCard()

    end
    
    function lua_table:Update()


        --TESTING LOGIC
        if lua_table["Inputs"]:KeyDown("A")--evade 6
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step2 = false
            step25 = false
            step3 = false
            step35 = false
            step4 = false
            step5 = false
            step55 = false
            step6 = false
            step65 = false
            step7 = false

            step1 = true
        end

        if lua_table["Inputs"]:KeyDown("S")--ultimate 12
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step1 = false
            step25 = false
            step3 = false
            step35 = false
            step4 = false
            step5 = false
            step55 = false
            step6 = false
            step65 = false
            step7 = false

            step2 =  true
        end

        if lua_table["Inputs"]:KeyDown("D")--special 11
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step1 = false
            step2 = false
            step25 = false
            step35 = false
            step4 = false
            step5 = false
            step55 = false
            step6 = false
            step65 = false
            step7 = false

            step3 = true
        end

        if lua_table["Inputs"]:KeyDown("E")--enemies 9
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step1 = false
            step2 = false
            step25 = false
            step3 = false
            step35 = false
            step5 = false
            step55 = false
            step6 = false
            step65 = false
            step7 = false

            step4 = true
        end

        if lua_table["Inputs"]:KeyDown("F")--combos 10
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step1 = false
            step2 = false
            step25 = false
            step3 = false
            step35 = false
            step4 = false
            step55 = false
            step6 = false
            step65 = false
            step7 = false

            step5 = true
        end

        if lua_table["Inputs"]:KeyDown("G")--potis interaction  evcent
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step1 = false
            step2 = false
            step25 = false
            step3 = false
            step35 = false
            step4 = false
            step5 = false
            step55 = false
            step65 = false
            step7 = false

            step6 = true
        end

        if lua_table["Inputs"]:KeyDown("H")--bonfire
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step1 = false
            step2 = false
            step25 = false
            step3 = false
            step35 = false
            step4 = false
            step5 = false
            step55 = false
            step6 = false
            step65 = false

            step7 = true
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

        if continue_meter1_full == true and continue_meter2_full == true
        then
            step1 = false
            HideCard()
        end
    

       end

       --ULTIMATE
       if step2 == true
       then

        HideCard()

        lua_table["UI"]:MakeElementVisible("Image", ULTIMATE)
        lua_table["UI"]:MakeElementVisible("Image", RIGHT_ARROW)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step25 = true
            step2 = false
        end
       
       end

       if step25 == true
       then

            HideCard()

            lua_table["UI"]:MakeElementVisible("Image", ULTIMATE2)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)
            lua_table["UI"]:MakeElementVisible("Image", LEFT_ARROW)

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                step2 = true
                step25 = false
            end

            if continue_meter1_full == true and continue_meter2_full == true
            then
                step25 = false
                HideCard()
            end

       end

       --SPECIAL
       if step3 == true
       then

        HideCard()

        lua_table["UI"]:MakeElementVisible("Image", SPECIAL)
        lua_table["UI"]:MakeElementVisible("Image", RIGHT_ARROW)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step35 = true
            step3 = false
        end
       
       
       end

       if step35 == true
       then

            HideCard()
            
            lua_table["UI"]:MakeElementVisible("Image", SPECIAL2)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)
            lua_table["UI"]:MakeElementVisible("Image", LEFT_ARROW)

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                step3 = true
                step35 = false
            end

            if continue_meter1_full == true and continue_meter2_full == true
            then
                step35 = false
                HideCard()
            end

       end

       --ENEMY
       if step4 == true
       then

        HideCard()

        lua_table["UI"]:MakeElementVisible("Image", ENEMY)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)

        if continue_meter1_full == true and continue_meter2_full == true
        then
            step4 = false
            HideCard()
        end
       
       end

       --COMBOS
       if step5 == true
       then

        HideCard()

        lua_table["UI"]:MakeElementVisible("Image", COMBOS)
        lua_table["UI"]:MakeElementVisible("Image", RIGHT_ARROW)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step55 = true
            step5 = false
        end
       
       end

       if step55 == true
       then

            HideCard()
           
            lua_table["UI"]:MakeElementVisible("Image", COMBOS2)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)
            lua_table["UI"]:MakeElementVisible("Image", LEFT_ARROW)

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                step5 = true
                step55 = false
            end

            if continue_meter1_full == true and continue_meter2_full == true
            then
                step55 = false
                HideCard()
            end

       end

       --POTIS
       if step6 == true
       then

        HideCard()

        lua_table["UI"]:MakeElementVisible("Image", POTIS)
        lua_table["UI"]:MakeElementVisible("Image", RIGHT_ARROW)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        --lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        --lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
        then
            continue_meter1 = 0
            continue_meter2 = 0
            continue_meter1_full = false
            continue_meter2_full = false
            step65 = true
            step6 = false
        end
       
       end

       if step65 == true
       then

            HideCard()
            
            lua_table["UI"]:MakeElementVisible("Image", POTIS2)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
            lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
            lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)
            lua_table["UI"]:MakeElementVisible("Image", LEFT_ARROW)

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                step6 = true
                step65 = false
            end

            if continue_meter1_full == true and continue_meter2_full == true
            then
                step65 = false
                HideCard()
            end

       end

       --BONFIRE
       if step7 == true
       then

        HideCard()

        lua_table["UI"]:MakeElementVisible("Image", BONFIRE)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P1_METER)
        lua_table["UI"]:MakeElementVisible("CiruclarBar", P2_METER)

        if continue_meter1_full == true and continue_meter2_full == true
        then
            step7 = false
            HideCard()
        end
       
       end
    
    --METERS FUNCTIONALITY

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

        if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "REPEAT") and continue_meter2_full == false
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