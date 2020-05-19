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

    --GENERAL
    local CARD_ID = 0
    local CARD_PLAYER1_BUTTON = 0
    local CARD_PLAYER2_BUTTON = 0
    local CARD_PLAYER1_ID = 0
    local CARD_PLAYER2_ID = 0
   
    --EVADE
    local EVADE_TITLE_ID = 0

    local EVADE_TEXT1_ID = 0
    local EVADE_TEXT2_ID = 0
    local EVADE_TEXT3_ID = 0
    local EVADE_TEXT4_ID = 0
    local EVADE_TEXT5_ID = 0

    local EVADE_IMAGE1_ID = 0
    local EVADE_BUTTON_ID = 0

    --ULTI
    local ULTI_TITLE_ID = 0

    local ULTI_TEXT1_ID = 0
    local ULTI_TEXT2_ID = 0
    local ULTI_TEXT3_ID = 0
    local ULTI_TEXT4_ID = 0
    local ULTI_TEXT5_ID = 0

    local ULTI_IMAGE1_ID = 0
    local ULTI_BUTTON_ID = 0

    --ENEMIES
    --COMBOS 
    --ABILITIES
    --POTIS

    local function HideCard()

        
        lua_table["UI"]:MakeElementInvisible("Image", CARD_ID)
        lua_table["UI"]:MakeElementInvisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementInvisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementInvisible("Text", CARD_PLAYER1_ID)
        lua_table["UI"]:MakeElementInvisible("Text", CARD_PLAYER2_ID)


        lua_table["UI"]:MakeElementInvisible("Text", EVADE_TITLE_ID)
        lua_table["UI"]:MakeElementInvisible("Image", EVADE_IMAGE1_ID)
        lua_table["UI"]:MakeElementInvisible("Image", EVADE_BUTTON_ID)
        lua_table["UI"]:MakeElementInvisible("Text", EVADE_TEXT1_ID)
        lua_table["UI"]:MakeElementInvisible("Text", EVADE_TEXT2_ID)
        lua_table["UI"]:MakeElementInvisible("Text", EVADE_TEXT3_ID)
        lua_table["UI"]:MakeElementInvisible("Text", EVADE_TEXT4_ID)
        lua_table["UI"]:MakeElementInvisible("Text", EVADE_TEXT5_ID)

        lua_table["UI"]:MakeElementInvisible("Text", ULTI_TITLE_ID)
        lua_table["UI"]:MakeElementInvisible("Image", ULTI_IMAGE1_ID)
        lua_table["UI"]:MakeElementInvisible("Image", ULTI_BUTTON_ID)
        lua_table["UI"]:MakeElementInvisible("Text", ULTI_TEXT1_ID)
        lua_table["UI"]:MakeElementInvisible("Text", ULTI_TEXT2_ID)

    end
    
    function lua_table:Awake()
        
        --GENERAL
        CARD_ID = lua_table["GameObject"]:FindGameObject("CARDBACKGROUND")
        CARD_PLAYER1_ID = lua_table["GameObject"]:FindGameObject("CARDPLAYER1")
        CARD_PLAYER2_ID = lua_table["GameObject"]:FindGameObject("CARDPLAYER2")
        CARD_PLAYER1_BUTTON = lua_table["GameObject"]:FindGameObject("CARDP1BUTTON")
        CARD_PLAYER2_BUTTON = lua_table["GameObject"]:FindGameObject("CARDP2BUTTON")

        --EVADE SECTION
        EVADE_TITLE_ID = lua_table["GameObject"]:FindGameObject("EVADETITLE")

        EVADE_TEXT1_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT1")
        EVADE_TEXT2_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT2")
        EVADE_TEXT3_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT3")
        EVADE_TEXT4_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT4")
        EVADE_TEXT5_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT5")

        EVADE_IMAGE1_ID = lua_table["GameObject"]:FindGameObject("EVADEIMAGE1")
        EVADE_BUTTON_ID = lua_table["GameObject"]:FindGameObject("EVADEBUTTON")

        --ULTI SECTION
        ULTI_TITLE_ID = lua_table["GameObject"]:FindGameObject("ULTIMATETITLE")

        ULTI_TEXT1_ID = lua_table["GameObject"]:FindGameObject("ULTIMATETEXT1")
        ULTI_TEXT2_ID = lua_table["GameObject"]:FindGameObject("ULTIMATETEXT2")
        --ULTI_TEXT3_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT3")
        --ULTI_TEXT4_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT4")
        --ULTI_TEXT5_ID = lua_table["GameObject"]:FindGameObject("EVADETEXT5")

        ULTI_IMAGE1_ID = lua_table["GameObject"]:FindGameObject("ULTIMATEIMAGE1")
        --ULTI_BUTTON_ID = lua_table["GameObject"]:FindGameObject("EVADEBUTTON")


    
    end
    
    function lua_table:Start()
    
        HideCard()

    end
    
    function lua_table:Update()


        --TESTING LOGIC
        if lua_table["Inputs"]:KeyDown("A")
        then
            step2 = false
            step1 = true
        end

        if lua_table["Inputs"]:KeyDown("D")
        then
            step1 = false
            step2 =  true
        end


       --EVADE
       if step1 == true
       then

        HideCard()

        --GENERAL
        lua_table["UI"]:SetText("P1 MANTAIN        TO CONTINUE", CARD_PLAYER1_ID)
        lua_table["UI"]:SetText("P2 MANTAIN        TO CONTINUE", CARD_PLAYER2_ID)

        lua_table["UI"]:MakeElementVisible("Text", CARD_PLAYER1_ID)
        lua_table["UI"]:MakeElementVisible("Text", CARD_PLAYER2_ID)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_ID)
        --

        lua_table["UI"]:SetText("EVADE TUTORIAL", EVADE_TITLE_ID)
        
        lua_table["UI"]:SetText("THE EVADE IS ONE OF YOUR MAIN ACTIONS, IT WILL ALLOW YOU",EVADE_TEXT1_ID)
        lua_table["UI"]:SetText("TO MOVE QUICKLY AND REPOSITION YOURSELF TO AVOID ENEMY ATTACKS.",EVADE_TEXT2_ID)
        lua_table["UI"]:SetText("TO USE IT, JUST PRESS        ONCE IF YOU HAVE ENOUGHT STAMINA.",EVADE_TEXT3_ID)
        lua_table["UI"]:SetText("THE CHARACTER WILL PERFORM THE EVADE, BUT KEEP IN MIND THAT",EVADE_TEXT4_ID)
        lua_table["UI"]:SetText("IT WILL WASTE 1/3 OF YOUR STAMINA BAR, SO BE CAREFUL!",EVADE_TEXT5_ID)


        lua_table["UI"]:MakeElementVisible("Text", EVADE_TITLE_ID)
        lua_table["UI"]:MakeElementVisible("Image", EVADE_IMAGE1_ID)
        lua_table["UI"]:MakeElementVisible("Image", EVADE_BUTTON_ID)
        lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT1_ID)
        lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT2_ID)
        lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT3_ID)
        lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT4_ID)
        lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT5_ID)

       end

       --ULTIMATE
       if step2 == true
       then

        HideCard()

        --GENERAL
        lua_table["UI"]:SetText("P1 MANTAIN        TO CONTINUE", CARD_PLAYER1_ID)
        lua_table["UI"]:SetText("P2 MANTAIN        TO CONTINUE", CARD_PLAYER2_ID)

        lua_table["UI"]:MakeElementVisible("Text", CARD_PLAYER1_ID)
        lua_table["UI"]:MakeElementVisible("Text", CARD_PLAYER2_ID)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER1_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_PLAYER2_BUTTON)
        lua_table["UI"]:MakeElementVisible("Image", CARD_ID)
        --

        lua_table["UI"]:SetText("ULTIMATE TUTORIAL", ULTI_TITLE_ID)
        
        lua_table["UI"]:SetText("THE EVADE IS ONE OF YOUR MAIN ACTIONS, IT WILL ALLOW YOU",ULTI_TEXT1_ID)
        lua_table["UI"]:SetText("TO MOVE QUICKLY AND REPOSITION YOURSELF TO AVOID ENEMY ATTACKS.",ULTI_TEXT2_ID)
        
       
        lua_table["UI"]:MakeElementVisible("Text", ULTI_TITLE_ID)
        lua_table["UI"]:MakeElementVisible("Image", ULTI_IMAGE1_ID)
        lua_table["UI"]:MakeElementVisible("Image", ULTI_BUTTON_ID)
        lua_table["UI"]:MakeElementVisible("Text", ULTI_TEXT1_ID)
        lua_table["UI"]:MakeElementVisible("Text", ULTI_TEXT2_ID)
        --lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT3_ID)
        --lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT4_ID)
        --lua_table["UI"]:MakeElementVisible("Text", EVADE_TEXT5_ID)

       end
    
    
    end
    
    return lua_table
    end