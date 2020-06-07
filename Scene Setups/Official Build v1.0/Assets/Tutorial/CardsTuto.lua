function GetTableCardsTuto()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()

    local showedCard2 = false
    local showedCard6 = false
    local showedCard9 = false
    local showedCard10 = false
    local showedCard11 = false
    local showedCard12 = false
    local showedCard13 = false
    local showedRevive = false
    --test for potions image to test double images movement
    local potions = false

    --TEST CONDITIONS
    
    local step25 = false--ultimate2
    
    local step35 = false--special2
    
    local step55 = false--combo2
    
    local step65 = false--potis2
    

   
    lua_table.continue_meter1_full = false
    lua_table.continue_meter2_full = false
    local continue_meter1 = 0
    local continue_meter2 = 0


    --METERS
    local P1_METER = 0
    local P2_METER = 0
 

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
    local ATTACKS = 0
    local REVIVE = 0
    --
    lua_table.tuto = {}--para pillar desde script Faure i pillar steps
    local TUTOMANAGER = 0

    local function Meter()

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

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "REPEAT") and lua_table.continue_meter1_full == false
        then
            continue_meter1 = continue_meter1 + 1
        else 
            continue_meter1 = continue_meter1 - 0.6
        end

        if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "REPEAT") and lua_table.continue_meter2_full == false
        then
            continue_meter2 = continue_meter2 + 1
        else 
            continue_meter2 = continue_meter2 - 0.6
        end

        if lua_table.continue_meter1_full == false
        then
            lua_table["UI"]:SetUICircularBarPercentage(continue_meter1, P1_METER)
        else
            lua_table["UI"]:SetUICircularBarPercentage(100, P1_METER)
        end

        if lua_table.continue_meter2_full == false
        then
            lua_table["UI"]:SetUICircularBarPercentage(continue_meter2, P2_METER)
        else
            lua_table["UI"]:SetUICircularBarPercentage(100, P2_METER)
        end

    end

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
        lua_table["UI"]:MakeElementInvisible("Image", ATTACKS)
        lua_table["UI"]:MakeElementInvisible("Image", REVIVE)

        lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER)
        lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER)

    end
    
    function lua_table:Awake()
        EVADE = lua_table["GameObject"]:FindGameObject("C_EVADE")
        SPECIAL = lua_table["GameObject"]:FindGameObject("C_SPECIALCARD")
        SPECIAL2 = lua_table["GameObject"]:FindGameObject("C_SPECIALCARD2")
        ULTIMATE = lua_table["GameObject"]:FindGameObject("C_ULTI")
        ULTIMATE2 = lua_table["GameObject"]:FindGameObject("C_ULTI2")
        COMBOS = lua_table["GameObject"]:FindGameObject("C_COMBO")
        COMBOS2 = lua_table["GameObject"]:FindGameObject("C_COMBO2")
        POTIS = lua_table["GameObject"]:FindGameObject("C_POTIS")
        POTIS2 = lua_table["GameObject"]:FindGameObject("C_POTIS2")
        ENEMY = lua_table["GameObject"]:FindGameObject("C_ENEMY")
        BONFIRE = lua_table["GameObject"]:FindGameObject("C_BONFIRE")
        ATTACKS = lua_table["GameObject"]:FindGameObject("C_ATTACKS")
        REVIVE = lua_table["GameObject"]:FindGameObject("C_REVIVE")

        P1_METER = lua_table["GameObject"]:FindGameObject("C_P1METER")
        P2_METER = lua_table["GameObject"]:FindGameObject("C_P2METER")
        
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
        if lua_table.tuto.currentStep == 2 and showedCard2 == false--attacks
        then
            Meter()
            
            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", ATTACKS)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)            
            end

            if  continue_meter1 >= 100
            then
                lua_table.continue_meter1_full = true
            end

            if  continue_meter2 >= 100
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                showedCard2 = true
                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
            end
        end

        if lua_table.tuto.currentStep == 6 and lua_table.tuto.PauseStep6 == true and showedCard6 == false--evade 6
        then
            Meter()
            
            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false--mientras este congelado el time
            then
                lua_table["UI"]:MakeElementVisible("Image", EVADE)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)
                
            end
            lua_table["System"]:LOG("HOLA continue Meter 1"..continue_meter1)
            lua_table["System"]:LOG("HOLA continue Meter 2"..continue_meter2)

            if  continue_meter1 >= 100
            then
                lua_table.continue_meter1_full = true
            end

            if  continue_meter2 >= 100
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then

                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
                showedCard6 = true

            end
                    
        end
        
        if lua_table.tuto.currentStep == 12 and lua_table.tuto.PauseStep12 == true and showedCard12 == false--ultimate 12
        then

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", ULTIMATE)
                lua_table["System"]:LOG("STEP 12 visible ultimate1")

                --lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                --lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")
                then
                    step25 = true
                end
                --[[
                if step25 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
                then
                    step25 = false
                end
                --]]


          
            end
            if step25 == true
            then
                Meter()
                lua_table["UI"]:MakeElementInvisible("Image", ULTIMATE)
                lua_table["UI"]:MakeElementVisible("Image", ULTIMATE2)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)
            end

            if continue_meter1 >= 100 and step25 == true --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if continue_meter2 >= 100 and step25 == true--and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
                showedCard12 = true
            end
            
       
        end

        if lua_table.tuto.currentStep == 11 and lua_table.tuto.PauseStep11 == true and showedCard11 == false--special 11
        then

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", SPECIAL)
                --lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                --lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")
                then
                    step35 = true
                end
                --[[
                if step35 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
                then
                    step35 = false
                end
                --]]


            
            end
            if step35 == true
            then
                Meter()
                lua_table["UI"]:MakeElementInvisible("Image", SPECIAL)
                lua_table["UI"]:MakeElementVisible("Image", SPECIAL2)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)
            end
            if continue_meter1 >= 100 and step35 == true--and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if continue_meter2 >= 100 and step35 == true--and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
                showedCard11 = true
            end
           
           
        end
        

        if lua_table.tuto.currentStep == 9 and lua_table.tuto.PauseStep9 == true and showedCard9 == false--enemies 9
        then      

            Meter()

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", ENEMY)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)
            end

            if continue_meter1 >= 100 --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if continue_meter2 >= 100 --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
                showedCard9 = true
            end
    
           
        end
        
        if lua_table.tuto.currentStep == 10 and lua_table.tuto.PauseStep10 == true and showedCard10 == false--combos 10
        then

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", COMBOS)
                lua_table["System"]:LOG("STEP 10 visible combo1")
                --lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                --lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and step55 == false
                then
                    step55 = true
                    continue_meter1 = 0
                    continue_meter2 = 0
                end
                --[[

                if step55 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
                then
                    step55 = false
                end
                --]]
            
            end

            
            if step55 == true
            then

                Meter()
                lua_table["UI"]:MakeElementInvisible("Image", COMBOS)
                lua_table["UI"]:MakeElementVisible("Image", COMBOS2)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)      
            end

            if continue_meter1 >= 100 and step55 == true --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
                lua_table["System"]:LOG("STEP 10 continue meter1 full = true")
            end

            if continue_meter2 >= 100 and step55 == true --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
                lua_table["System"]:LOG("STEP 10 continue meter2 full = true")
            end

            lua_table["System"]:LOG("HOLA continue Meter 1"..continue_meter1)
            lua_table["System"]:LOG("HOLA continue Meter 2"..continue_meter2)

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
                lua_table["System"]:LOG("HOLA showedcard10")
                showedCard10 = true
            end
        end

        --tetsing  potions double image

      --  if  lua_table.tuto.potionsCards == true and potions == false
       --- then
      --      potions = true
        --end

        if lua_table.tuto.potionsCards == true--potis interaction  evcent FALTA QUE LO HAGA FAURA 
        then
                
            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
                then
                    step65 = true
                end

                if step65 == true and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
                then                 
                    step65 = false
                end     
            end

            if step65 == false
            then
                continue_meter1 = 0
                continue_meter2 = 0
                lua_table["UI"]:MakeElementInvisible("Image", POTIS2)
                lua_table["UI"]:MakeElementVisible("Image", POTIS)
                lua_table["UI"]:MakeElementInvisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementInvisible("CircularBar", P2_METER)
            end

            if step65 == true
            then
                Meter()
                lua_table["UI"]:MakeElementInvisible("Image", POTIS)
                lua_table["UI"]:MakeElementVisible("Image", POTIS2)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)
            end

            if continue_meter1 >= 100 and step65 == true --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if continue_meter2 >= 100 and step65 == true --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and lua_table.continue_meter2_full == true
            then
                HideCard()
                lua_table.tuto.potionsCards = false
                continue_meter1 = 0
                continue_meter2 = 0
            end
            
        end

        if lua_table.tuto.reviveCard == true and showedRevive == false
        then
            Meter()
            
            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", REVIVE)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)            
            end

            if  continue_meter1 >= 100
            then
                lua_table.continue_meter1_full = true
            end

            if  continue_meter2 >= 100
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                showedRevive = true
                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
            end
        end

        if lua_table.tuto.currentStep == 13 and lua_table.tuto.SaveGame13 == true and showedCard13== false--bonfire
        then
            Meter()

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", BONFIRE)
                lua_table["UI"]:MakeElementVisible("CircularBar", P1_METER)
                lua_table["UI"]:MakeElementVisible("CircularBar", P2_METER)
           
            end

            if continue_meter1 >= 100 --and lua_table.continue_meter1_full == false
            then
                lua_table.continue_meter1_full = true
            end

            if continue_meter2 >= 100 --and lua_table.continue_meter2_full == false
            then
                lua_table.continue_meter2_full = true
            end

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()
                continue_meter1 = 0
                continue_meter2 = 0
                showedCard13 = true
            end
          
        end

    end
    
    return lua_table
    end