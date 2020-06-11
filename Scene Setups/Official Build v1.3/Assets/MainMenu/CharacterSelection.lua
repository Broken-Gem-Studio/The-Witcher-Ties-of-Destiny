function GetTableCharacterSelection()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()
    lua_table["Scenes"] = Scripting.Scenes()
    lua_table["Animation"] = Scripting.Animations()

    local selection = {
        geralt = 0,
        jaskier = 1,
        yenn = 2,
        ciri = 3,
        none = 4
    }

    player1_focus = 0--HECHAS GLOBAL PARA PODERLAS COGER DESDE SCRIPT CARLES
    player2_focus = 0

    local player1_locked = false
    local player2_locked = false

    lua_table.next = false
    lua_table.scene1 = 0
    lua_table.scene2 = 0
    lua_table.main_menu = {}
    local MAINMENU = 0
    local not_selected = false--to make invisible arrow until we enter character slection

    local alpha = 0
    local alpha2 = 1
    lua_table.fading = false
    lua_table.fading2 = false
    local SCREEN = 0
   

    --camera
    local CAMERA = 0
    local currentCamera = 0

    --SIMBOLS
    local P1_ON_GERALT = 0
    local P2_ON_GERALT = 0
    local P1_ON_JASKIER = 0
    local P2_ON_JASKIER = 0
    local P1_ON_YENN = 0
    local P2_ON_YENN = 0
    local P1_ON_CIRI = 0
    local P2_ON_CIRI = 0

    local PRESS_Y = 0
    local PRESS_A = 0
    local PRESS_B = 0
    local ARROWS = 0

    --POSTERS
    local GERALT_POSTER_P1 = 0
    local JASKIER_POSTER_P1 = 0
    local YENN_POSTER_P1 = 0
    local CIRI_POSTER_P1 = 0
    local GERALT_POSTER_P2 = 0
    local JASKIER_POSTER_P2 = 0
    local YENN_POSTER_P2 = 0
    local CIRI_POSTER_P2 = 0

    local PLAYER1_READY = 0
    local PLAYER1_NOT_AVAILABLE = 0
    local PLAYER2_READY = 0
    local PLAYER2_NOT_AVAILABLE = 0

    --animation
    local GERALT = 0
    local JASKIER = 0
    local YENN = 0
    local CIRI = 0

    local animgeralt = false
    local animjaskier = false
    local animgeralt2 = false
    local animjaskier2 = false
    local geraltfinished = false
    local jaskierfinished = false

    local geralttime = 0
    local jaskiertime = 0

    --
    local SELECTION = 0
    local load_timer = 0
    local loading_screen = 0


    local function Hide()

        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_GERALT)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_GERALT)
        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_JASKIER)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_JASKIER)
        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_YENN)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_YENN)
        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_CIRI)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_CIRI)

        lua_table["UI"]:MakeElementInvisible("Image", PRESS_Y)
        lua_table["UI"]:MakeElementInvisible("Image", PRESS_A)
        lua_table["UI"]:MakeElementInvisible("Image", PRESS_B)
        lua_table["UI"]:MakeElementInvisible("Image", ARROWS)

        lua_table["UI"]:MakeElementInvisible("Image", GERALT_POSTER_P1)
        lua_table["UI"]:MakeElementInvisible("Image", JASKIER_POSTER_P1)
        lua_table["UI"]:MakeElementInvisible("Image", YENN_POSTER_P1)
        lua_table["UI"]:MakeElementInvisible("Image", CIRI_POSTER_P1)
        lua_table["UI"]:MakeElementInvisible("Image", GERALT_POSTER_P2)
        lua_table["UI"]:MakeElementInvisible("Image", JASKIER_POSTER_P2)
        lua_table["UI"]:MakeElementInvisible("Image", YENN_POSTER_P2)
        lua_table["UI"]:MakeElementInvisible("Image", CIRI_POSTER_P2)
        lua_table["UI"]:MakeElementInvisible("Image", PLAYER1_READY)
        lua_table["UI"]:MakeElementInvisible("Image", PLAYER2_READY)
        lua_table["UI"]:MakeElementInvisible("Image", PLAYER1_NOT_AVAILABLE)
        lua_table["UI"]:MakeElementInvisible("Image", PLAYER2_NOT_AVAILABLE)

        

    end

    local function SelectionLogic1()--P1
        
        local current_selection = player1_focus

        lua_table["System"]:LOG("SELECTION: " .. current_selection)
     
        if current_selection < 3
        then
            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
            then
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Hover", SELECTION)
                current_selection = player1_focus + 1
            end
        end

        if current_selection > 0
        then
            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Hover", SELECTION)
                current_selection = player1_focus - 1
            end
        end
        
      return current_selection

    end

    local function SelectionLogic2()--P2
        
        local current_selection2 = player2_focus

        lua_table["System"]:LOG("SELECTION2: " .. current_selection2)
     
        if current_selection2 < 3
        then
            if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_DPAD_RIGHT", "DOWN") or lua_table["Inputs"]:KeyDown("D")
            then
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Hover", SELECTION)
                current_selection2 = player2_focus + 1
            end
        end

        if current_selection2 > 0
        then
            if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_DPAD_LEFT", "DOWN") or lua_table["Inputs"]:KeyDown("A")
            then
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Hover", SELECTION)
                current_selection2 = player2_focus - 1
            end
        end
        
      return current_selection2

    end

    local function CheckIfLocked()

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") and player1_focus < 2
        then
            if player1_focus == player2_focus
            then
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Selected", SELECTION)
                player1_locked = true--to avoid bug when p1 and p2 are in the same character and none has selected it

                if player2_locked == true
                then
                    player1_locked = false
                end
                
            else
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Selected", SELECTION)
                player1_locked = true
            end
        end

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_B", "DOWN")
        then
            lua_table["Audio"]:PlayAudioEventGO("Play_Character_Unselected", SELECTION)
            if player1_focus == 0
            then
                geraltfinished = false
                lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
            elseif player1_focus == 1
            then
                jaskierfinished = false
                lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
            end
            
            animgeralt = false
            animjaskier = false
            player1_locked = false
        end

        -----------

        if (lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_A", "DOWN") or lua_table["Inputs"]:KeyDown("F")) and player2_focus < 2
        then
            if player2_focus == player1_focus
            then
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Selected", SELECTION)
                player2_locked = true

                if player1_locked == true
                then
                    player2_locked = false
                end
                
            else
                lua_table["Audio"]:PlayAudioEventGO("Play_Character_Selected", SELECTION)
                player2_locked = true
            end
        end

        if lua_table["Inputs"]:IsGamepadButton(2, "BUTTON_B", "DOWN") or lua_table["Inputs"]:KeyDown("G")
        then
            lua_table["Audio"]:PlayAudioEventGO("Play_Character_Unselected", SELECTION)
            if player2_focus == 0
            then
                geraltfinished = false
                lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
            elseif player2_focus == 1
            then
                jaskierfinished = false
                lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
            end
            animgeralt2 = false
            animjaskier2 = false
            player2_locked = false
        end

    end

    
    
    function lua_table:Awake()
       
        P1_ON_GERALT = lua_table["GameObject"]:FindGameObject("P1GERALT")
        P2_ON_GERALT = lua_table["GameObject"]:FindGameObject("P2GERALT")
        P1_ON_JASKIER = lua_table["GameObject"]:FindGameObject("P1JASKIER")
        P2_ON_JASKIER = lua_table["GameObject"]:FindGameObject("P2JASKIER")
        P1_ON_YENN = lua_table["GameObject"]:FindGameObject("P1YENN")
        P2_ON_YENN = lua_table["GameObject"]:FindGameObject("P2YENN")
        P1_ON_CIRI = lua_table["GameObject"]:FindGameObject("P1CIRI")
        P2_ON_CIRI = lua_table["GameObject"]:FindGameObject("P2CIRI")

        MAINMENU = lua_table["GameObject"]:FindGameObject("ButtonManager")
        lua_table.main_menu = lua_table["GameObject"]:GetScript(MAINMENU)

        CAMERA = lua_table["GameObject"]:FindGameObject("Camera")
        SCREEN = lua_table["GameObject"]:FindGameObject("FADE")

        GERALT = lua_table["GameObject"]:FindGameObject("GERARDO")
        JASKIER = lua_table["GameObject"]:FindGameObject("JASKIERO")
        YENN = lua_table["GameObject"]:FindGameObject("YENN")
        CIRI = lua_table["GameObject"]:FindGameObject("CIRILA")

        SELECTION = lua_table["GameObject"]:FindGameObject("SELECTION")

        PRESS_Y = lua_table["GameObject"]:FindGameObject("PRESS_Y")
        PRESS_A = lua_table["GameObject"]:FindGameObject("PRESS_A")
        PRESS_B = lua_table["GameObject"]:FindGameObject("PRESS_B")
        ARROWS = lua_table["GameObject"]:FindGameObject("ARROWS")

        GERALT_POSTER_P1= lua_table["GameObject"]:FindGameObject("P1PAPER")
        JASKIER_POSTER_P1 = lua_table["GameObject"]:FindGameObject("P1PAPER2")
        YENN_POSTER_P1= lua_table["GameObject"]:FindGameObject("P1PAPER3")
        CIRI_POSTER_P1 = lua_table["GameObject"]:FindGameObject("P1PAPER4")
        GERALT_POSTER_P2 = lua_table["GameObject"]:FindGameObject("P2PAPER")
        JASKIER_POSTER_P2 = lua_table["GameObject"]:FindGameObject("P2PAPER2")
        YENN_POSTER_P2= lua_table["GameObject"]:FindGameObject("P2PAPER3")
        CIRI_POSTER_P2= lua_table["GameObject"]:FindGameObject("P2PAPER4")
        PLAYER1_READY= lua_table["GameObject"]:FindGameObject("PLAYER1READY")
        PLAYER1_NOT_AVAILABLE= lua_table["GameObject"]:FindGameObject("PLAYER1NOTAVAILABLE")
        PLAYER2_READY= lua_table["GameObject"]:FindGameObject("PLAYER2READY")
        PLAYER2_NOT_AVAILABLE= lua_table["GameObject"]:FindGameObject("PLAYER2NOTAVAILABLE")

        loading_screen = lua_table["GameObject"]:FindGameObject("LoadingScreenCanvas")
    end
    
    function lua_table:Start()
    
        
        next = false

        Hide()
        player1_focus = 0
        player2_focus = 0
        player1_locked = false
        player2_locked = false

        lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
        lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
        lua_table["Animation"]:PlayAnimation("Idle", 30, CIRI)
       
        --to avoid blinking at the start
        --lua_table["UI"]:MakeElementInvisible("Image", GERALT_POSTER_P2)
        --lua_table["UI"]:MakeElementInvisible("Image", JASKIER_POSTER_P2)

    end
    
    function lua_table:Update()

        if lua_table.main_menu.loadLevel1 == true or lua_table.main_menu.loadLevel2 == true
        then
            lua_table["GameObject"]:SetActiveGameObject(true, SELECTION)
            lua_table["System"]:LOG("Enter")
            --fade
            --[[if lua_table.fading == false
            then
                alpha = alpha + 0.05
                lua_table["UI"]:ChangeUIComponentAlpha("Image", alpha, SCREEN)
                
            end

            if alpha >= 1.0
            then
                lua_table["UI"]:MakeElementInvisible("Image", SCREEN)
                lua_table.fading = true
        
                
            end
            
            if lua_table.fading == true
            then
                lua_table["UI"]:MakeElementVisible("Image", SCREEN)
                alpha2 = alpha2 - 0.05
                lua_table["UI"]:ChangeUIComponentAlpha("Image", alpha2, SCREEN)
                lua_table.fading2 = true
            end--]]

                

        else
            lua_table["GameObject"]:SetActiveGameObject(false, SELECTION)
        end

        if lua_table.main_menu.loadLevel1 == false and lua_table.main_menu.loadLevel2 == false --esconder si aun no han clickado level 1 o 2
        then
            not_selected = true
        end
      
        if lua_table.main_menu.loadLevel1 == true 
        then
            lua_table["System"]:LOG("LEVEL1 SELECTED")  

            if lua_table.fading == false
            then
                alpha = alpha + 0.05
                lua_table["UI"]:ChangeUIComponentAlpha("Image", alpha, SCREEN)
                
            end

            if alpha >= 1.0
            then
                lua_table["UI"]:MakeElementInvisible("Image", SCREEN)
                lua_table.fading = true
        
                
            end
            
            if lua_table.fading == true
            then
                lua_table["UI"]:MakeElementVisible("Image", SCREEN)
                alpha2 = alpha2 - 0.05
                lua_table["UI"]:ChangeUIComponentAlpha("Image", alpha2, SCREEN)
                lua_table.fading2 = true
            end

            if lua_table.fading2 == true
            then
                not_selected = false
                lua_table["Transform"]:SetPosition(437.000, -20.750, -34.250, CAMERA)
                lua_table["Transform"]:SetObjectRotation(180,77.989, 180, CAMERA) 
                lua_table["UI"]:MakeElementVisible("Image", PRESS_Y)    
                lua_table["UI"]:MakeElementVisible("Image", PRESS_A) 
                lua_table["UI"]:MakeElementVisible("Image", PRESS_B) 
                lua_table["UI"]:MakeElementVisible("Image", ARROWS) 
            end    
           
        

        end

        if lua_table.main_menu.loadLevel2 == true 
        then
            lua_table["System"]:LOG("LEVEL2 SELECTED")

            if lua_table.fading == false
            then
                alpha = alpha + 0.05
                lua_table["UI"]:ChangeUIComponentAlpha("Image", alpha, SCREEN)
                
            end

            if alpha >= 1.0
            then
                lua_table["UI"]:MakeElementInvisible("Image", SCREEN)
                lua_table.fading = true
        
                
            end
            
            if lua_table.fading == true
            then
                lua_table["UI"]:MakeElementVisible("Image", SCREEN)
                alpha2 = alpha2 - 0.05
                lua_table["UI"]:ChangeUIComponentAlpha("Image", alpha2, SCREEN)
                lua_table.fading2 = true
            end

            if lua_table.fading2 == true
            then
                not_selected = false
                lua_table["Transform"]:SetPosition(437.000, -20.750, -34.250, CAMERA)
                lua_table["Transform"]:SetObjectRotation(180,77.989, 180, CAMERA)
                lua_table["UI"]:MakeElementVisible("Image", PRESS_Y) 
                lua_table["UI"]:MakeElementVisible("Image", PRESS_A) 
                lua_table["UI"]:MakeElementVisible("Image", PRESS_B) 
                lua_table["UI"]:MakeElementVisible("Image", ARROWS) 
            end
        end

        if lua_table.main_menu.loadLevel1 == false and lua_table.main_menu.loadLevel2 == false
        then
            lua_table["System"]:LOG("NONE SELECTED")
        end
        --

        if next == false and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_Y", "DOWN")--tirar para atras
        then        

             
            --player1_focus = 4
            --player2_focus = 4
            player1_locked = false
            player2_locked = false
            geraltfinished = false
            jaskierfinished = false
            animgeralt = false
            animjaskier = false
            animgeralt2 = false
            animjaskier2 = false
            Hide()
            alpha = 0
            alpha2 = 1
            lua_table.fading = false
            lua_table.fading2 = false
            
            
            
            
            --PONER COORDENADAS CAMARA DANI
            
                lua_table["Transform"]:SetPosition(97.333, -41.926, -76.645, CAMERA)
                lua_table["Transform"]:SetObjectRotation(-180, 3.167, 180, CAMERA)
            
            
            --lua_table.main_menu.loadLevel1 = false
            --lua_table.main_menu.loadLevel2 = false
        end

        
        if next == true
        then
            lua_table["System"]:LOG("NEXT SCENE")--cambiar de escena

            if lua_table.main_menu.loadLevel1 == true and geraltfinished == true and jaskierfinished == true
            then
                lua_table["System"]:LOG("LOADING SCENE1")
                
                load_timer = load_timer + lua_table["System"]:DT()

                if load_timer >= 1 
                then
                    lua_table["Scenes"]:LoadScene(lua_table.scene1)
                    lua_table.main_menu.loadLevel1 = false
                else 
                    lua_table["GameObject"]:SetActiveGameObject(true, loading_screen)
                end

            end

            if lua_table.main_menu.loadLevel2 == true and geraltfinished == true and jaskierfinished == true
            then
                lua_table["System"]:LOG("LOADING SCENE2")
            
                load_timer = load_timer + lua_table["System"]:DT()

                if load_timer >= 1 
                then
                    lua_table["Scenes"]:LoadScene(lua_table.scene2)
                    lua_table.main_menu.loadLevel2 = false
                else 
                    lua_table["GameObject"]:SetActiveGameObject(true, loading_screen)
                end
            end
        end  
        

        if player1_locked == true and player2_locked == true
        then
            next = true
        end

        if lua_table.main_menu.loadLevel1 == true or lua_table.main_menu.loadLevel2 == true
        then
            CheckIfLocked()
        end

        if player1_locked == false and (lua_table.main_menu.loadLevel1 == true or lua_table.main_menu.loadLevel2 == true)
        then
            player1_focus = SelectionLogic1()
        end

        if player2_locked == false and (lua_table.main_menu.loadLevel1 == true or lua_table.main_menu.loadLevel2 == true)
        then
            player2_focus = SelectionLogic2()
        end
       

        if player1_focus == 0 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_GERALT)
            lua_table["UI"]:MakeElementVisible("Image", GERALT_POSTER_P1)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_GERALT)
            lua_table["UI"]:MakeElementInvisible("Image", GERALT_POSTER_P1)
        end

        if player2_focus == 0 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_GERALT)
            lua_table["UI"]:MakeElementVisible("Image", GERALT_POSTER_P2)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_GERALT)
            lua_table["UI"]:MakeElementInvisible("Image", GERALT_POSTER_P2)
        end

        if player1_focus == 1 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_JASKIER)
            lua_table["UI"]:MakeElementVisible("Image", JASKIER_POSTER_P1)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_JASKIER)
            lua_table["UI"]:MakeElementInvisible("Image", JASKIER_POSTER_P1)
        end

        if player2_focus == 1 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_JASKIER)
            lua_table["UI"]:MakeElementVisible("Image", JASKIER_POSTER_P2)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_JASKIER)
            lua_table["UI"]:MakeElementInvisible("Image", JASKIER_POSTER_P2)
        end

        if player1_focus == 2 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_YENN)
            lua_table["UI"]:MakeElementVisible("Image", YENN_POSTER_P1)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_YENN)
            lua_table["UI"]:MakeElementInvisible("Image", YENN_POSTER_P1)
        end

        if player2_focus == 2 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_YENN)
            lua_table["UI"]:MakeElementVisible("Image", YENN_POSTER_P2)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_YENN)
            lua_table["UI"]:MakeElementInvisible("Image", YENN_POSTER_P2)
        end

        if player1_focus == 3 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_CIRI)
            lua_table["UI"]:MakeElementVisible("Image", CIRI_POSTER_P1)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_CIRI)
            lua_table["UI"]:MakeElementInvisible("Image", CIRI_POSTER_P1)
        end

        if player2_focus == 3 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_CIRI)
            lua_table["UI"]:MakeElementVisible("Image", CIRI_POSTER_P2)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_CIRI)
            lua_table["UI"]:MakeElementInvisible("Image", CIRI_POSTER_P2)
        end

        
        --ALPHA MANAGEMENT
        if player1_locked == true
        then
            if player1_focus == 0
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ON_GERALT)
            elseif player1_focus == 1
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ON_JASKIER)
            elseif player1_focus == 2
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ON_YENN)
            elseif player1_focus == 3
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P1_ON_CIRI)
            end

            lua_table["UI"]:MakeElementVisible("Image", PLAYER1_READY)
        end

        if player1_locked == false
        then
            if player1_focus == 0
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P1_ON_GERALT)
            elseif player1_focus == 1
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P1_ON_JASKIER)
            elseif player1_focus == 2
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P1_ON_YENN)
            elseif player1_focus == 3
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P1_ON_CIRI)
            end

            lua_table["UI"]:MakeElementInvisible("Image", PLAYER1_READY)
        end

        if player2_locked == true
        then
            if player2_focus == 0
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ON_GERALT)
            elseif player2_focus == 1
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ON_JASKIER)
            elseif player2_focus == 2
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ON_YENN)
            elseif player2_focus == 3
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 1.0, P2_ON_CIRI)
            end

            lua_table["UI"]:MakeElementVisible("Image", PLAYER2_READY)
        end

        if player2_locked == false
        then
            if player2_focus == 0
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P2_ON_GERALT)
            elseif player2_focus == 1
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P2_ON_JASKIER)
            elseif player2_focus == 2
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P2_ON_YENN)
            elseif player2_focus == 3
            then
                lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, P2_ON_CIRI)
            end

            lua_table["UI"]:MakeElementInvisible("Image", PLAYER2_READY)
        end


        if player1_focus == player2_focus
        then
            if player1_locked == true
            then
                lua_table["UI"]:MakeElementVisible("Image", PLAYER2_NOT_AVAILABLE)
            else
                lua_table["UI"]:MakeElementInvisible("Image", PLAYER2_NOT_AVAILABLE)
            end

            if player2_locked == true
            then
                lua_table["UI"]:MakeElementVisible("Image", PLAYER1_NOT_AVAILABLE)
            else
                lua_table["UI"]:MakeElementInvisible("Image", PLAYER1_NOT_AVAILABLE)
            end

        else
            lua_table["UI"]:MakeElementInvisible("Image", PLAYER1_NOT_AVAILABLE)
            lua_table["UI"]:MakeElementInvisible("Image", PLAYER2_NOT_AVAILABLE)
        end



        --ANIMATIONS
        
        if player1_locked == true
        then


            if player1_focus == 0 and animgeralt == false
            then
                lua_table["System"]:LOG("GERARDINHO")
                lua_table["Animation"]:PlayAnimation("Selected", 30, GERALT)
                lua_table["Audio"]:PlayAudioEventGO("Play_Select_Geralt", SELECTION)
                geralttime = lua_table["System"]:GameTime()
                animgeralt = true
            end

            if player1_focus == 1 and animjaskier == false
            then

                lua_table["System"]:LOG("JASKIERINHO")
                lua_table["Animation"]:PlayAnimation("Selected", 30, JASKIER)
                lua_table["Audio"]:PlayAudioEventGO("Play_Select_Jaskier", SELECTION)
                jaskiertime = lua_table["System"]:GameTime()
                animjaskier = true
            end
            

        elseif player1_locked == false
        then
            lua_table["System"]:LOG("IDLE")
            --lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
            --lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
        end
        
        if player2_locked == true
        then

            if player2_focus == 0 and animgeralt2 == false
            then
                lua_table["System"]:LOG("GERARDINHO2")
                lua_table["Animation"]:PlayAnimation("Selected", 30, GERALT)
                lua_table["Audio"]:PlayAudioEventGO("Play_Select_Geralt", SELECTION)
                geralttime = lua_table["System"]:GameTime()
                animgeralt2 = true
            end

            if player2_focus == 1 and animjaskier2 == false
            then
                lua_table["System"]:LOG("JASKIERINHO2")
                lua_table["Animation"]:PlayAnimation("Selected", 30, JASKIER)
                lua_table["Audio"]:PlayAudioEventGO("Play_Select_Jaskier", SELECTION)
                jaskiertime = lua_table["System"]:GameTime()
                animjaskier2 = true
            end

            
        elseif player2_locked == false
        then
            lua_table["System"]:LOG("IDLE")
            --lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
            --lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
        end
        

        --WAIT FOR THE ANIM TO END WORKAROUND

        if animgeralt == true or animgeralt2 == true
        then
           
           
                if lua_table["System"]:GameTime() >= geralttime + 2.76
                then
                    geraltfinished = true
                end
            
        end

        if animjaskier == true or animjaskier2 == true
        then
           
                if lua_table["System"]:GameTime() >= jaskiertime + 2.23
                then
                    jaskierfinished = true
                end
            
        end

    
        lua_table["System"]:LOG("ALPHA: " .. alpha)
        lua_table["System"]:LOG("P1 FOCUS: " .. player1_focus)
        lua_table["System"]:LOG("P2 FOCUS: " .. player2_focus)

    --end--

    end
    
    return lua_table
    end