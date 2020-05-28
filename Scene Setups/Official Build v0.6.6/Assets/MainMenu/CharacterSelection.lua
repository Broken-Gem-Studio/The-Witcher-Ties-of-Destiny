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

    --animation
    local GERALT = 0
    local JASKIER = 0
    local YENN = 0
    local CIRI = 0

    local animgeralt = false
    local animjaskier = false
    local animgeralt2 = false
    local animjaskier2 = false


    local function Hide()

        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_GERALT)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_GERALT)
        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_JASKIER)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_JASKIER)
        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_YENN)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_YENN)
        lua_table["UI"]:MakeElementInvisible("Image", P1_ON_CIRI)
        lua_table["UI"]:MakeElementInvisible("Image", P2_ON_CIRI)

    end

    local function SelectionLogic1()--P1
        
        local current_selection = player1_focus

        lua_table["System"]:LOG("SELECTION: " .. current_selection)
     
        if current_selection < 3
        then
            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")
            then
                --lua_table["Audio"]:PlayAudioEvent()
                current_selection = player1_focus + 1
            end
        end

        if current_selection > 0
        then
            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                --lua_table["Audio"]:PlayAudioEvent()
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
            if lua_table["Inputs"]:KeyDown("D")
            then
                --lua_table["Audio"]:PlayAudioEvent()
                current_selection2 = player2_focus + 1
            end
        end

        if current_selection2 > 0
        then
            if lua_table["Inputs"]:KeyDown("A")
            then
                --lua_table["Audio"]:PlayAudioEvent()
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
                --lua_table["Audio"]:PlayAudioEvent()
                player1_locked = true--to avoid bug when p1 and p2 are in the same character and none has selected it

                if player2_locked == true
                then
                    player1_locked = false
                end
                
            else
                --lua_table["Audio"]:PlayAudioEvent()
                player1_locked = true
            end
        end

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_B", "DOWN")
        then
            --lua_table["Audio"]:PlayAudioEvent()
            if player1_focus == 0
            then
                lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
            elseif player1_focus == 1
            then
                lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
            end
            
            animgeralt = false
            animjaskier = false
            player1_locked = false
        end

        -----------

        if lua_table["Inputs"]:KeyDown("F") and player2_focus < 2
        then
            if player2_focus == player1_focus
            then
                --lua_table["Audio"]:PlayAudioEvent()
                player2_locked = true

                if player1_locked == true
                then
                    player2_locked = false
                end
                
            else
                --lua_table["Audio"]:PlayAudioEvent()
                player2_locked = true
            end
        end

        if lua_table["Inputs"]:KeyDown("G")
        then
            --lua_table["Audio"]:PlayAudioEvent()
            if player2_focus == 0
            then
                lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
            elseif player2_focus == 1
            then
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

    end
    
    function lua_table:Start()
    
        
        next = false

        Hide()
        player1_focus = selection.geralt
        player2_focus = selection.geralt
        player1_locked = false
        player2_locked = false

        --alpha test
        --[[
        lua_table["UI"]:ChangeUIComponentColor("Image", 125, 25, 25, 0, P1_ON_GERALT)
        lua_table["UI"]:ChangeUIComponentColor("Image", 125, 25, 25, 0, P1_ON_JASKIER)
        lua_table["UI"]:ChangeUIComponentColor("Image", 125, 25, 25, 0, P1_ON_YENN)
        lua_table["UI"]:ChangeUIComponentColor("Image", 125, 25, 25, 0, P1_ON_CIRI)
        lua_table["UI"]:ChangeUIComponentColor("Image", 132, 68, 180, 0, P2_ON_GERALT)
        lua_table["UI"]:ChangeUIComponentColor("Image", 132, 68, 180, 0, P2_ON_JASKIER)
        lua_table["UI"]:ChangeUIComponentColor("Image", 132, 68, 180, 0, P2_ON_YENN)
        lua_table["UI"]:ChangeUIComponentColor("Image", 132, 68, 180, 0, P2_ON_CIRI)
        --]]

        lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
        lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
        lua_table["Animation"]:PlayAnimation("Idle", 30, CIRI)

    end
    
    function lua_table:Update()



        if lua_table.main_menu.loadLevel1 == false and lua_table.main_menu.loadLevel2 == false --esconder si aun no han clickado level 1 o 2
        then
            not_selected = true
        end
      
        if lua_table.main_menu.loadLevel1 == true
        then
            lua_table["System"]:LOG("LEVEL1 SELECTED")
            not_selected = false
            lua_table["Transform"]:SetPosition(437.000, -20.750, -34.250, CAMERA)
            lua_table["Transform"]:SetObjectRotation(180,77.989, 180, CAMERA)
        end

        if lua_table.main_menu.loadLevel2 == true
        then
            lua_table["System"]:LOG("LEVEL2 SELECTED")
            not_selected = false
            lua_table["Transform"]:SetPosition(437.000, -20.750, -34.250, CAMERA)
            lua_table["Transform"]:SetObjectRotation(180,77.989, 180, CAMERA)
        end
        --

        if next == false and lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_Y", "DOWN")--tirar para atras
        then
            --PONER COORDENADAS CAMARA DANI
            lua_table["Transform"]:SetPosition(104.716, -44.599, -78.720, CAMERA)
            lua_table["Transform"]:SetObjectRotation(-180, 4.896, 180, CAMERA)
            --player1_focus = 4
            --player2_focus = 4
            player1_locked = false
            player2_locked = false
            Hide()
        end

        
        if next == true
        then
            lua_table["System"]:LOG("NEXT SCENE")--cambiar de escena

            if lua_table.main_menu.loadLevel1 == true
            then
                lua_table["System"]:LOG("LOADING SCENE1")
                lua_table["Scenes"]:LoadScene(lua_table.scene1)
            end

            if lua_table.main_menu.loadLevel2 == true
            then
                lua_table["System"]:LOG("LOADING SCENE2")
                lua_table["Scenes"]:LoadScene(lua_table.scene2)
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
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_GERALT)
        end

        if player2_focus == 0 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_GERALT)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_GERALT)
        end

        if player1_focus == 1 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_JASKIER)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_JASKIER)
        end

        if player2_focus == 1 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_JASKIER)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_JASKIER)
        end

        if player1_focus == 2 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_YENN)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_YENN)
        end

        if player2_focus == 2 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_YENN)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_YENN)
        end

        if player1_focus == 3 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_CIRI)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_CIRI)
        end

        if player2_focus == 3 and not_selected == false
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_CIRI)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_CIRI)
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
        end

        --ANIMATIONS
        
        if player1_locked == true
        then


            if player1_focus == 0 and animgeralt == false
            then
                lua_table["System"]:LOG("GERARDINHO")
                lua_table["Animation"]:PlayAnimation("Selected", 30, GERALT)
                animgeralt = true
            end

            if player1_focus == 1 and animjaskier == false
            then

                lua_table["System"]:LOG("JASKIERINHO")
                lua_table["Animation"]:PlayAnimation("Selected", 30, JASKIER)
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
                animgeralt2 = true
            end

            if player2_focus == 1 and animjaskier2 == false
            then
                lua_table["System"]:LOG("JASKIERINHO2")
                lua_table["Animation"]:PlayAnimation("Selected", 30, JASKIER)
                animjaskier2 = true
            end

            
        elseif player2_locked == false
        then
            lua_table["System"]:LOG("IDLE")
            --lua_table["Animation"]:PlayAnimation("Idle", 30, GERALT)
            --lua_table["Animation"]:PlayAnimation("Idle", 30, JASKIER)
        end
        




        lua_table["System"]:LOG("P1 FOCUS: " .. player1_focus)
        lua_table["System"]:LOG("P2 FOCUS: " .. player2_focus)

    --end--

    end
    
    return lua_table
    end