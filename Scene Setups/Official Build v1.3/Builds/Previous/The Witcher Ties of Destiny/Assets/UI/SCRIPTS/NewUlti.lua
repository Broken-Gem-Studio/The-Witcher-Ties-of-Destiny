function GetTableNewUlti()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()
    
    local ULTIDCERO = 0
    local ULTIDTWENTY = 0
    local ULTIDFORTY = 0
    local ULTIDSIXTY = 0
    local ULTIDEIGHTY = 0
    local ULTIDHUNDRED = 0
    local ULTIDUSING = 0

    local ULTID2CERO = 0
    local ULTID2TWENTY = 0
    local ULTID2FORTY = 0
    local ULTID2SIXTY = 0
    local ULTID2EIGHTY = 0
    local ULTID2HUNDRED = 0
    local ULTID2USING = 0
    
    local BUMPERS = 0
    local BUMPERS2 = 0


    lua_table.ultimatelocal = 0
    lua_table.ultimatelocal2 = 0
    local P1ID = 0--ID GERALT
    lua_table.ultiP1 = {}
    local P2ID = 0--ID GERALT
    lua_table.ultiP2 = {}

    --vibration
    local timer = 0
    local timepassed = 0
    local satisfier = false
    local used = false
    local timepassed2 = 0
    local satisfier2 = false
    local used2 = false
    
    
    function lua_table:Awake()
        lua_table["System"]:LOG ("This Log was called from NEWULTI Script on AWAKE")
    
        ULTIDCERO = lua_table["GameObject"]:FindGameObject("ULTICERO")
        ULTIDTWENTY = lua_table["GameObject"]:FindGameObject("ULTITWENTY")
        ULTIDFORTY = lua_table["GameObject"]:FindGameObject("ULTIFORTY")
        ULTIDSIXTY = lua_table["GameObject"]:FindGameObject("ULTISIXTY")
        ULTIDEIGHTY = lua_table["GameObject"]:FindGameObject("ULTIEIGHTY")
        ULTIDHUNDRED = lua_table["GameObject"]:FindGameObject("ULTIHUNDRED")
        ULTIDUSING = lua_table["GameObject"]:FindGameObject("ULTIUSING")
        

        ULTID2CERO = lua_table["GameObject"]:FindGameObject("ULTICERO2")
        ULTID2TWENTY = lua_table["GameObject"]:FindGameObject("ULTITWENTY2")
        ULTID2FORTY = lua_table["GameObject"]:FindGameObject("ULTIFORTY2")
        ULTID2SIXTY = lua_table["GameObject"]:FindGameObject("ULTISIXTY2")
        ULTID2EIGHTY = lua_table["GameObject"]:FindGameObject("ULTIEIGHTY2")
        ULTID2HUNDRED = lua_table["GameObject"]:FindGameObject("ULTIHUNDRED2")
        ULTID2USING = lua_table["GameObject"]:FindGameObject("ULTIUSING2")
        
        BUMPERS = lua_table["GameObject"]:FindGameObject("BUMPERS")
        BUMPERS2 = lua_table["GameObject"]:FindGameObject("BUMPERS2")

        P1ID = lua_table["GameObject"]:FindGameObject("Geralt")
        lua_table.ultiP1 = lua_table["GameObject"]:GetScript(P1ID)
        P2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
        lua_table.ultiP2 = lua_table["GameObject"]:GetScript(P2ID)
    
    end
    
    function lua_table:Start()
    
        lua_table["UI"]:MakeElementInvisible("Image", ULTID2TWENTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTID2FORTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTID2SIXTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTID2EIGHTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTID2HUNDRED)
        lua_table["UI"]:MakeElementInvisible("Image", ULTID2USING)

        lua_table["UI"]:MakeElementInvisible("Image", ULTIDTWENTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIDFORTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIDSIXTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIDEIGHTY)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIDHUNDRED)
        lua_table["UI"]:MakeElementInvisible("Image", ULTIDUSING)

        lua_table["UI"]:MakeElementInvisible("Image", BUMPERS)
        lua_table["UI"]:MakeElementInvisible("Image", BUMPERS2)
     
        lua_table.ultimatelocal2 = lua_table.ultiP2.current_ultimate
        lua_table.ultimatelocal = lua_table.ultiP1.current_ultimate
    end
    
    function lua_table:Update()
        timer = lua_table["System"]:GameTime()
        --lua_table["System"]:LOG("TIME: " .. timer)
        --lua_table["System"]:LOG("TIMEpassed: " .. timepassed)
        --lua_table["System"]:LOG("TIMEpassed2: " .. timepassed2)

        lua_table.ultimatelocal = lua_table.ultiP1.current_ultimate
        lua_table["System"]:LOG ("ULTIMATE UPDATE: " .. lua_table.ultimatelocal)

        lua_table.ultimatelocal2 = lua_table.ultiP2.current_ultimate
        lua_table["System"]:LOG ("ULTIMATE2 UPDATE: " .. lua_table.ultimatelocal2)

        --ULTI GERALT

        if lua_table.ultiP1.current_state == -3 or lua_table.ultiP1.current_state == -4 or lua_table.ultiP1.being_revived == true
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDTWENTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDFORTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDSIXTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDEIGHTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDHUNDRED)
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDUSING)
    
            lua_table["UI"]:MakeElementInvisible("Image", BUMPERS)
        end

        if lua_table.ultimatelocal < 20 and lua_table.ultiP1.ultimate_active == false and lua_table.ultiP1.current_state > -3 and lua_table.ultiP1.being_revived == false--WHEN ULTIMATE IS USED, WE PUT IMAGE AS 0%
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDUSING)
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDHUNDRED)
            lua_table["UI"]:MakeElementVisible("Image", ULTIDCERO)
            used = false
        end

        if lua_table.ultimatelocal >= 20 and lua_table.ultiP1.current_state  > -3 and lua_table.ultiP1.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDCERO)
            lua_table["UI"]:MakeElementVisible("Image", ULTIDTWENTY)
        end

        if lua_table.ultimatelocal >= 40 and lua_table.ultiP1.current_state  > -3 and lua_table.ultiP1.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDTWENTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTIDFORTY)
        end

        if lua_table.ultimatelocal >= 60 and lua_table.ultiP1.current_state > -3 and lua_table.ultiP1.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDFORTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTIDSIXTY)
        end

        if lua_table.ultimatelocal >= 80 and lua_table.ultiP1.current_state > -3 and lua_table.ultiP1.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDSIXTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTIDEIGHTY)
        end

        if lua_table.ultimatelocal == 100 and lua_table.ultiP1.current_state  > -3 and lua_table.ultiP1.being_revived == false--LAST IMAGE ULTI IS READY
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDEIGHTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTIDHUNDRED)
            lua_table["UI"]:MakeElementVisible("Image", BUMPERS)
        end

        if lua_table.ultiP1.current_state  <= -3 or lua_table.ultiP1.being_revived == true--LAST IMAGE ULTI IS READY
        then
            lua_table["UI"]:MakeElementInvisible("Image", BUMPERS)
        end

        --vibration

        if lua_table.ultimatelocal == 100 and satisfier == false and used == false --LAST IMAGE ULTI IS READY
        then
            timepassed = lua_table["System"]:GameTime()
            satisfier = true
            used = true
        end

        if satisfier == true and timer - timepassed >= 1 and used == true
        then
            --lua_table["Audio"]:PlayAudioEvent("Play_Ulti_Geralt")
            lua_table["Inputs"]:ShakeController(1, 1.0, 500)
            satisfier = false
        end

        --

        if lua_table.ultiP1.ultimate_active == true 
        then
            if lua_table.ultiP1.current_state  ~= -3 and lua_table.ultiP1.current_state  ~= -4 and lua_table.ultiP1.being_revived == false
            then
                lua_table["UI"]:MakeElementInvisible("Image", BUMPERS)
                lua_table["UI"]:MakeElementVisible("Image", ULTIDUSING)
            else
                lua_table["UI"]:MakeElementInvisible("Image", ULTIDUSING)
            end

        end

        if lua_table.ultiP1.ultimate_active == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTIDUSING)
        end

        --

    
        --ULTI JASKIER

        if lua_table.ultiP2.current_state == -3 or lua_table.ultiP2.current_state == -4  or lua_table.ultiP2.being_revived == true
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2TWENTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2FORTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2SIXTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2EIGHTY)
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2HUNDRED)
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2USING)
            lua_table["UI"]:MakeElementInvisible("Image", BUMPERS2)
        end

        if lua_table.ultimatelocal2 < 20 and lua_table.ultiP2.ultimate_active == false and lua_table.ultiP2.current_state > -3 and lua_table.ultiP2.being_revived == false--WHEN ULTIMATE IS USED, WE PUT IMAGE AS 0%
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2USING)
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2HUNDRED)
            lua_table["UI"]:MakeElementVisible("Image", ULTID2CERO)
            used2 = false
        end

        if lua_table.ultimatelocal2 >= 20 and lua_table.ultiP2.current_state > -3 and lua_table.ultiP2.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2CERO)
            lua_table["UI"]:MakeElementVisible("Image", ULTID2TWENTY)
        end

        if lua_table.ultimatelocal2 >= 40 and lua_table.ultiP2.current_state > -3 and lua_table.ultiP2.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2TWENTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTID2FORTY)
        end

        if lua_table.ultimatelocal2 >= 60 and lua_table.ultiP2.current_state > -3 and lua_table.ultiP2.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2FORTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTID2SIXTY)
        end

        if lua_table.ultimatelocal2 >= 80 and lua_table.ultiP2.current_state > -3 and lua_table.ultiP2.being_revived == false
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2SIXTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTID2EIGHTY)
        end

        if lua_table.ultimatelocal2 == 100 and lua_table.ultiP2.current_state > -3 and lua_table.ultiP2.being_revived == false--LAST IMAGE ULTI IS READY
        then
            lua_table["UI"]:MakeElementInvisible("Image", ULTID2EIGHTY)
            lua_table["UI"]:MakeElementVisible("Image", ULTID2HUNDRED)
            lua_table["UI"]:MakeElementVisible("Image", BUMPERS2)
        end

        if lua_table.ultiP2.current_state  <= -3 or lua_table.ultiP2.being_revived == true--LAST IMAGE ULTI IS READY
        then
            lua_table["UI"]:MakeElementInvisible("Image", BUMPERS2)
        end

         --vibration 2

         if lua_table.ultimatelocal2 == 100 and satisfier2 == false and used2 == false --LAST IMAGE ULTI IS READY
         then
             timepassed2 = lua_table["System"]:GameTime()
             satisfier2 = true
             used2 = true
         end
 
         if satisfier2 == true and timer - timepassed2 >= 1 and used2 == true
         then
             --lua_table["Audio"]:PlayAudioEvent("Play_Geralt_aard_2")--buscarle audio
             lua_table["Inputs"]:ShakeController(2, 1.0, 500)
             satisfier2 = false
         end
 
         --

         if lua_table.ultiP2.ultimate_active == true 
         then
             if lua_table.ultiP2.current_state  ~= -3 and lua_table.ultiP2.current_state  ~= -4 and lua_table.ultiP2.being_revived == false
             then
                lua_table["UI"]:MakeElementInvisible("Image", BUMPERS2)
                 lua_table["UI"]:MakeElementVisible("Image", ULTID2USING)
 
             else
                 lua_table["UI"]:MakeElementInvisible("Image", ULTID2USING)
             end
 
         end
 
         if lua_table.ultiP2.ultimate_active == false
         then
             lua_table["UI"]:MakeElementInvisible("Image", ULTID2USING)
         end

         --
       

    
    end
    
    return lua_table
    end