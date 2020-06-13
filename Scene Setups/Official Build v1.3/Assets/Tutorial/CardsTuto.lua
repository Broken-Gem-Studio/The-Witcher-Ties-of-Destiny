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
    local step25b = false
    
    local step35 = false--special2
    local step35b = false

    local step55 = false--combo2
    local step55b = false

    local step65 = false--potis2
    local step65b = false

   
    lua_table.continue_meter1_full = false
    lua_table.continue_meter2_full = false
    --local continue_meter1 = 0
    --local continue_meter2 = 0


    --METERS
    --local P1_METER = 0
    --local P2_METER = 0
 

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
    local PRESS_A = 0
    local P1_ARROW = 0
    local P2_ARROW = 0
    local alpha1 = false
    local alpha2 = false

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
        lua_table["UI"]:MakeElementInvisible("Image", ATTACKS)
        lua_table["UI"]:MakeElementInvisible("Image", REVIVE)

        lua_table["UI"]:MakeElementInvisible("Image", PRESS_A)
        lua_table["UI"]:MakeElementInvisible("Image", P1_ARROW)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ARROW)

        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P1_ARROW)
        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P2_ARROW)

        

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

        P1_ARROW = lua_table["GameObject"]:FindGameObject("P1_CONFIRM")
        P2_ARROW = lua_table["GameObject"]:FindGameObject("P2_CONFIRM")
        PRESS_A = lua_table["GameObject"]:FindGameObject("PRESS_A")

        
        TUTOMANAGER = lua_table["GameObject"]:FindGameObject("TutorialManager")
        lua_table.tuto = lua_table["GameObject"]:GetScript(TUTOMANAGER)
        
    end
    
    function lua_table:Start()

        HideCard()
        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P1_ARROW)
        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P2_ARROW)


    end
    
    function lua_table:Update()

        
        --TESTING LOGIC
        if lua_table.tuto.currentStep == 2 and showedCard2 == false--attacks
        then
            
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", ATTACKS)
                           
            end

            if  lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                lua_table.continue_meter1_full = true
            end

            if  lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
            then
                
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                lua_table.continue_meter2_full = true
            end


            if lua_table.continue_meter1_full == true and lua_table.continue_meter2_full == true
            then
                showedCard2 = true
                HideCard()
                
            end
        end

        if lua_table.tuto.currentStep == 6 and lua_table.tuto.PauseStep6 == true and showedCard6 == false--evade 6
        then
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)
            
            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false--mientras este congelado el time
            then
                lua_table["UI"]:MakeElementVisible("Image", EVADE)
                
                
            end
            

            if  lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                lua_table.continue_meter1_full = true
                
            end

            if  lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                lua_table.continue_meter2_full = true
            end


            

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then

                HideCard()
                
                showedCard6 = true

            end
                    
        end
        
        if lua_table.tuto.currentStep == 12 and lua_table.tuto.PauseStep12 == true and showedCard12 == false--ultimate 12
        then
            lua_table["UI"]:MakeElementVisible("Image", ULTIMATE)
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)

            if step25 == true and step25b == true
            then
               
                lua_table["UI"]:MakeElementInvisible("Image", ULTIMATE)
                lua_table["UI"]:MakeElementVisible("Image", ULTIMATE2)

                if alpha1 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P1_ARROW)
                end

                if alpha2 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P2_ARROW)
                end
                

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                    alpha1 = true
                    --lua_table["System"]:LOG("FIRST INPUT")
                    lua_table.continue_meter1_full = true
                    
                end
    
                if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                    alpha2 = true
                    --lua_table["System"]:LOG("SECOND INPUT")
                    lua_table.continue_meter2_full = true
                    
                end

            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                step25 = true
                
            end

            if lua_table["Inputs"]:KeyDown("F") or lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                step25b = true
                    
            end

           

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                alpha1 = false
                alpha2 = false
                HideCard()
                showedCard12 = true
            end
            
       
        end

        if lua_table.tuto.currentStep == 11 and lua_table.tuto.PauseStep11 == true and showedCard11 == false--special 11
        then

            lua_table["UI"]:MakeElementVisible("Image", SPECIAL)
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)
            
            if step35 == true and step35b == true
            then
                
                lua_table["UI"]:MakeElementInvisible("Image", SPECIAL)
                lua_table["UI"]:MakeElementVisible("Image", SPECIAL2)

                if alpha1 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P1_ARROW)
                end

                if alpha2 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P2_ARROW)
                end
            

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                    alpha1 = true
                    --lua_table["System"]:LOG("FIRST INPUT")
                    lua_table.continue_meter1_full = true
                    
                end
    
                if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                    alpha2 = true
                    --lua_table["System"]:LOG("SECOND INPUT")
                    lua_table.continue_meter2_full = true
                    
                end

            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                step35 = true
                
            end

            if lua_table["Inputs"]:KeyDown("F") or lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                step35b = true
                    
            end
            



            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                alpha1 = false
                alpha2 = false
                HideCard()
                
                showedCard11 = true
            end
           
           
        end
        

        if lua_table.tuto.currentStep == 9 and lua_table.tuto.PauseStep9 == true and showedCard9 == false--enemies 9
        then      

            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", ENEMY)
                
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") --and lua_table.continue_meter1_full == false
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                lua_table.continue_meter1_full = true
            
            end

            if  lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                lua_table.continue_meter2_full = true
            end


           

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()
              
                showedCard9 = true
            end
    
           
        end
        
        if lua_table.tuto.currentStep == 10 and lua_table.tuto.PauseStep10 == true and showedCard10 == false--combos 10
        then

            lua_table["UI"]:MakeElementVisible("Image", COMBOS)
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)
            
            if step55 == true and step55b == true
            then

                
                lua_table["UI"]:MakeElementInvisible("Image", COMBOS)
                lua_table["UI"]:MakeElementVisible("Image", COMBOS2)
                
                if alpha1 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P1_ARROW)
                end

                if alpha2 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P2_ARROW)
                end
                
                
                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                    alpha1 = true
                    --lua_table["System"]:LOG("FIRST INPUT")
                    lua_table.continue_meter1_full = true
                    
                end
    
                if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                    alpha2 = true
                    --lua_table["System"]:LOG("SECOND INPUT")
                    lua_table.continue_meter2_full = true
                    
                end
                
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                step55 = true
                
            end

            if lua_table["Inputs"]:KeyDown("F") or lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                step55b = true
                    
            end

            

          

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                alpha1 = false
                alpha2 = false
                HideCard()
                
                --lua_table["System"]:LOG("HOLA showedcard10")
                showedCard10 = true
            end

        end


        if lua_table.tuto.potionsCards == true--potis interaction  evcent FALTA QUE LO HAGA FAURA 
        then
       

            lua_table["UI"]:MakeElementVisible("Image", POTIS)
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)

            if step65 == true and step65b == true
            then
                
                lua_table["UI"]:MakeElementInvisible("Image", POTIS)
                lua_table["UI"]:MakeElementVisible("Image", POTIS2)
                
                if alpha1 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P1_ARROW)
                end

                if alpha2 == false
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.4, P2_ARROW)
                end

                if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                    alpha1 = true
                    --lua_table["System"]:LOG("FIRST INPUT")
                    lua_table.continue_meter1_full = true
                end
    
                if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
                then
                    lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                    alpha2 = true
                    --lua_table["System"]:LOG("SECOND INPUT")
                    lua_table.continue_meter2_full = true
                end
                

            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")  
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                step65 = true
                    
            end

            if lua_table["Inputs"]:KeyDown("F") or lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                step65b = true
                    
            end

            

            if lua_table.continue_meter1_full == true and lua_table.continue_meter2_full == true
            then
                
                alpha1 = false
                alpha2 = false
                HideCard()
                lua_table.tuto.potionsCards = false
                
            end
            
        end

        if lua_table.tuto.reviveCard == true and showedRevive == false
        then
            
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)
            
            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", REVIVE)
                       
            end

            if  lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                lua_table.continue_meter1_full = true
            end

            if  lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                lua_table.continue_meter2_full = true
            end


          

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                showedRevive = true
                HideCard()
                
            end
        end

        if lua_table.tuto.currentStep == 13 and lua_table.tuto.SaveGame13 == true and showedCard13== false--bonfire
        then
            lua_table["UI"]:MakeElementVisible("Image", PRESS_A)
            lua_table["UI"]:MakeElementVisible("Image", P1_ARROW)
            lua_table["UI"]:MakeElementVisible("Image", P2_ARROW)

            if lua_table.continue_meter1_full == false and lua_table.continue_meter2_full == false
            then
                lua_table["UI"]:MakeElementVisible("Image", BONFIRE)
                
           
            end

            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") 
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ARROW)
                lua_table.continue_meter1_full = true
            end

            if  lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ARROW)
                lua_table.continue_meter2_full = true
            end


            

            if lua_table.continue_meter1_full == true and  lua_table.continue_meter2_full == true
            then
                HideCard()
              
                showedCard13 = true
            end
          
        end

    end
    
    return lua_table
    end