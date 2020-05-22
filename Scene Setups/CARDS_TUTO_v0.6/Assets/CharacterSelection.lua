function GetTableCharacterSelection()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()

    local selection = {
        geralt = 0,
        jaskier = 1,
        yenn = 2,
        ciri = 3
    }

    player1_focus = 0--HECHAS GLOBAL PARA PODERLAS COGER DESDE SCRIPT CARLES
    player2_focus = 0

    local player1_locked = false
    local player2_locked = false

    lua_table.next = false

    --SIMBOLS
    local P1_ON_GERALT = 0
    local P2_ON_GERALT = 0
    local P1_ON_JASKIER = 0
    local P2_ON_JASKIER = 0
    local P1_ON_YENN = 0
    local P2_ON_YENN = 0
    local P1_ON_CIRI = 0
    local P2_ON_CIRI = 0

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
                current_selection = player1_focus + 1
            end
        end

        if current_selection > 0
        then
            if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")
            then
                current_selection = player1_focus - 1
            end
        end
        
      return current_selection

    end

    local function SelectionLogic2()--P2
        
        local current_selection = player2_focus

        lua_table["System"]:LOG("SELECTION2: " .. current_selection)
     
        if current_selection < 3
        then
            if lua_table["Inputs"]:KeyDown("D")
            then
                current_selection = player2_focus + 1
            end
        end

        if current_selection > 0
        then
            if lua_table["Inputs"]:KeyDown("A")
            then
                current_selection = player2_focus - 1
            end
        end
        
      return current_selection

    end

    local function CheckIfLocked()

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_A", "DOWN") 
        then
            if player1_focus == player2_focus
            then
                player1_locked = true--to avoid bug when p1 and p2 are in the same character and none has selected it

                if player2_locked == true
                then
                    player1_locked = false
                end
                
            else
                player1_locked = true
            end
        end

        if lua_table["Inputs"]:IsGamepadButton(1, "BUTTON_B", "DOWN")
        then
            player1_locked = false
        end

        -----------

        if lua_table["Inputs"]:KeyDown("F") 
        then
            if player2_focus == player1_focus
            then
                player2_locked = true

                if player1_locked == true
                then
                    player2_locked = false
                end
                
            else
                player2_locked = true
            end
        end

        if lua_table["Inputs"]:KeyDown("G")
        then
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

    end
    
    function lua_table:Start()
    
        Hide()
        player1_focus = selection.geralt
        player2_focus = selection.geralt
        player1_locked = false
        player2_locked = false

    end
    
    function lua_table:Update()

        if next == true
        then
            lua_table["System"]:LOG("NEXT SCENE")--cambiar de escena, o que la pillen next desde otro script y si es true que empiece esa escena
        end

        if player1_locked == true and player2_locked == true
        then
            next = true
        end

        CheckIfLocked()

        if player1_locked == false
        then
            player1_focus = SelectionLogic1()
        end

        if player2_locked == false
        then
            player2_focus = SelectionLogic2()
        end
       

        if player1_focus == 0
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_GERALT)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_GERALT)
        end

        if player2_focus == 0
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_GERALT)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_GERALT)
        end

        if player1_focus == 1
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_JASKIER)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_JASKIER)
        end

        if player2_focus == 1
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_JASKIER)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_JASKIER)
        end

        if player1_focus == 2
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_YENN)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_YENN)
        end

        if player2_focus == 2
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_YENN)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_YENN)
        end

        if player1_focus == 3
        then 
            lua_table["UI"]:MakeElementVisible("Image", P1_ON_CIRI)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P1_ON_CIRI)
        end

        if player2_focus == 3
        then 
            lua_table["UI"]:MakeElementVisible("Image", P2_ON_CIRI)
        else 
            lua_table["UI"]:MakeElementInvisible("Image", P2_ON_CIRI)
        end

        

        lua_table["System"]:LOG("P1 FOCUS: " .. player1_focus)
        lua_table["System"]:LOG("P2 FOCUS: " .. player2_focus)

    end
    
    return lua_table
    end