function GetTableCardsTuto()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()


    --test for potions image to test double images movement
    local potions = false

    --TEST CONDITIONS
    
    local step25 = false--ultimate2
    
    local step35 = false--special2
    
    local step55 = false--combo2
    
    local step65 = false--potis2
    

   
    lua_table.continue_meter1_full = false
    lua_table.continue_meter2_full = false

    --GENERAL
    local CARD_PLAYER1_BUTTON = 0
    local CARD_PLAYER2_BUTTON = 0

    --METERS
    local P1_METER_EVADE = 0
    local P2_METER_EVADE = 0
    local P1_METER_SPECIAL = 0
    local P2_METER_SPECIAL = 0
    local P1_METER_ULTI = 0
    local P2_METER_ULTI = 0
    local P1_METER_COMBOS = 0
    local P2_METER_COMBOS = 0
    local P1_METER_POTIONS = 0
    local P2_METER_POTIONS = 0
    local P1_METER_BONFIRE = 0
    local P2_METER_BONFIRE = 0
    local P1_METER_ENEMY = 0
    local P2_METER_ENEMY = 0

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
    local TUTOMANAGER = 0

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
        lua_table["UI"]:MakeElementInvisible("Image", LEFT_ARROW)
        lua_table["UI"]:MakeElementInvisible("Image", RIGHT_ARROW)

        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER_EVADE)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER_EVADE)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER_SPECIAL)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER_SPECIAL)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER_ULTI)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER_ULTI)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER_COMBOS)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER_COMBOS)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER_POTIONS)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER_POTIONS)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER_ENEMY)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER_ENEMY)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER_BONFIRE)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER_BONFIRE)



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
        LEFT_ARROW = lua_table["GameObject"]:FindGameObject("LEFT")
        RIGHT_ARROW = lua_table["GameObject"]:FindGameObject("RIGHT")

        P1_METER_EVADE = lua_table["GameObject"]:FindGameObject("P1METEREVADE")
        P2_METER_EVADE = lua_table["GameObject"]:FindGameObject("P2METEREVADE")
        P1_METER_SPECIAL = lua_table["GameObject"]:FindGameObject("P1METERSPECIAL")
        P2_METER_SPECIAL = lua_table["GameObject"]:FindGameObject("P2METERSPECIAL")
        P1_METER_ULTI = lua_table["GameObject"]:FindGameObject("P1METERULTI")
        P2_METER_ULTI = lua_table["GameObject"]:FindGameObject("P2METERULTI")
        P1_METER_COMBOS = lua_table["GameObject"]:FindGameObject("P1METERCOMBO")
        P2_METER_COMBOS = lua_table["GameObject"]:FindGameObject("P2METERCOMBO")
        P1_METER_POTIONS = lua_table["GameObject"]:FindGameObject("P1METERPOTIS")
        P2_METER_POTIONS = lua_table["GameObject"]:FindGameObject("P2METERPOTIS")
        P1_METER_ENEMY = lua_table["GameObject"]:FindGameObject("P1METERENEMY")
        P2_METER_ENEMY = lua_table["GameObject"]:FindGameObject("P2METERENEMY")
        P1_METER_BONFIRE = lua_table["GameObject"]:FindGameObject("P1METERBONFIRE")
        P2_METER_BONFIRE = lua_table["GameObject"]:FindGameObject("P2METERBONFIRE")

        TUTOMANAGER = lua_table["GameObject"]:FindGameObject("TutorialManager")
        lua_table.tuto = lua_table["GameObject"]:GetScript(TUTOMANAGER)
        
    end
    
    function lua_table:Start()

        HideCard()

    end
    
    function lua_table:Update()

        if lua_table.continue_meter1_full == true
        then
            lua_table["System"]:LOG("METER TRUE")
        end
        if lua_table.continue_meter2_full == true
        then
            lua_table["System"]:LOG("METER2 TRUE")
        end

        if lua_table.continue_meter1_full == false
        then
            lua_table["System"]:LOG("METER FALSE")
        end
        if lua_table.continue_meter2_full == false
        then
            lua_table["System"]:LOG("METER2 FALSE")
        end


        --TESTING LOGIC
        if lua_table.tuto.currentStep == 6 and lua_table.tuto.PauseStep6 == true--evade 6
        then
            
            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false--mientras este congelado el time
            then
                lua_table["UI"]:MakeElementVisible("Image", EVADE)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_EVADE)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_EVADE)
            
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") 
            then
                lua_table.continue_meter1_full = true
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") 
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()

            end
                    
        end
        
        if lua_table.tuto.currentStep == 12 and lua_table.tuto.PauseStep12 == true--ultimate 12
        then

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", ULTIMATE)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
                then
                    step25 = true
                end

                if step25 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
                then
                    step25 = false
                end

                if step25 == true
                then
                    lua_table["UI"]:MakeElementInvisible("Image", ULTIMATE)
                    lua_table["UI"]:MakeElementVisible("Image", ULTIMATE2)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)
                end
          
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step25 == true --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step25 == true--and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()

            end
            
       
        end

        if lua_table.tuto.currentStep == 11 and lua_table.tuto.PauseStep11 == true--special 11
        then

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", SPECIAL)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
                then
                    step35 = true
                end

                if step35 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
                then
                    step35 = false
                end

                if step35 == true
                then
                    lua_table["UI"]:MakeElementInvisible("Image", SPECIAL)
                    lua_table["UI"]:MakeElementVisible("Image", SPECIAL2)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)
                end
            
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step25 == true--and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step35 == true--and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()

            end
           
           
        end
        

        if lua_table.tuto.currentStep == 9 and lua_table.tuto.PauseStep9 == true--enemies 9
        then      

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", ENEMY)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()

            end
    
           
        end
        
        if lua_table.tuto.currentStep == 10 and lua_table.tuto.PauseStep10 == true --combos 10
        then

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBOS)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
                then
                    step55 = true
                end

                if step55 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
                then
                    step55 = false
                end

                if step55 == true
                then
                    lua_table["UI"]:MakeElementInvisible("Image", COMBOS)
                    lua_table["UI"]:MakeElementVisible("Image", COMBOS2)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)
                end
            
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step55 == true --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step55 == true --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()

            end
          

        end
        --tetsing  potions double image

        if lua_table["Inputs"]:KeyDown("G")
        then
            potions = true
        end

        if potions == true--potis interaction  evcent FALTA QUE LO HAGA FAURE 
        then
            
            
            --if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            --then

            if step65 == true
            then
                lua_table["System"]:LOG("SECOND POTION IMAGE")
            end
            if step65 == false
            then
                lua_table["System"]:LOG("FIRST POTION IMAGE")
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
            then
                
                step65 = true
            end

            if step65 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                
                step65 = false
            end

                if step65 == false
                then
                    lua_table["UI"]:MakeElementInvisible("Image", POTIS2)
                    lua_table["UI"]:MakeElementVisible("Image", POTIS)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)
                end

                if step65 == true
                then
                    lua_table["UI"]:MakeElementInvisible("Image", POTIS)
                    lua_table["UI"]:MakeElementVisible("Image", POTIS2)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                    lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                    lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)
                end

          
            --end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step65 == true --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step65 == true --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()

            end
            
        end

        if lua_table.tuto.currentStep == 13 and lua_table.tuto.PauseStep13 == true--bonfire
        then

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", BONFIRE)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
                lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER_ENEMY)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER_ENEMY)
           
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()

            end
          
        end
        

    
   

        

    end
    
    return lua_table
    end