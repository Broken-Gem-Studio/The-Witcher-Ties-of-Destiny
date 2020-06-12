function GetTableBloodScreen()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()


local BLOODSCREEN = 0
local PAUSEPREFAB = 0
lua_table.pause = {}
local GERALTID = 0
lua_table.geralt = {}
local JASKIERID = 0
lua_table.jaskier = {}

local timer = 0
local bleed = false
local bleed2 = false
local player_num = 0




local function CheckAlpha(player)
    lua_table["System"]:LOG("ENTERING")

    if player == 1
    then
        if lua_table.geralt.current_health <= 50.0 and lua_table.geralt.current_health >= 40.0 
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.3, BLOODSCREEN)

        elseif lua_table.geralt.current_health < 40.0 and lua_table.geralt.current_health >= 30.0 
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.45, BLOODSCREEN)

        elseif lua_table.geralt.current_health < 30.0 and lua_table.geralt.current_health >= 20.0 
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, BLOODSCREEN)

        elseif lua_table.geralt.current_health < 20.0 and lua_table.geralt.current_health >= 0.0 
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.7, BLOODSCREEN)

        end
    elseif player == 2
    then
        if lua_table.jaskier.current_health <= 50.0 and lua_table.jaskier.current_health >= 40.0
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.3, BLOODSCREEN)

        elseif lua_table.jaskier.current_health < 40.0 and lua_table.jaskier.current_health >= 30.0 
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.45, BLOODSCREEN)

        elseif lua_table.jaskier.current_health < 30.0 and lua_table.jaskier.current_health >= 20.0 
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, BLOODSCREEN)

        elseif lua_table.jaskier.current_health < 20.0 and lua_table.jaskier.current_health >= 0.0 
        then
            lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.7, BLOODSCREEN)

        end

    end

    --[[if lua_table.geralt.current_health <= 50.0 and lua_table.geralt.current_health >= 40.0 or
    lua_table.jaskier.current_health <= 50.0 and lua_table.jaskier.current_health >= 40.0
    then
        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.3, BLOODSCREEN)

    elseif lua_table.geralt.current_health < 40.0 and lua_table.geralt.current_health >= 30.0 or
    lua_table.jaskier.current_health < 40.0 and lua_table.jaskier.current_health >= 30.0 
    then
        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.45, BLOODSCREEN)

    elseif lua_table.geralt.current_health < 30.0 and lua_table.geralt.current_health >= 20.0 or
    lua_table.jaskier.current_health < 30.0 and lua_table.jaskier.current_health >= 20.0 
    then
        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.6, BLOODSCREEN)

    elseif lua_table.geralt.current_health < 20.0 and lua_table.geralt.current_health >= 0.0 or
    lua_table.jaskier.current_health < 20.0 and lua_table.jaskier.current_health >= 0.0 
    then
        lua_table["UI"]:ChangeUIComponentAlpha("Image", 0.8, BLOODSCREEN)

    end--]]


end

local function BloodRegulation()


    if lua_table.geralt.current_health <= 50 
    then
        if lua_table.geralt.current_state > -3 
        then
            --lua_table["UI"]:MakeElementVisible("Image", BLOODSCREEN)
            bleed = true
            
        elseif lua_table.geralt.current_state <= -3 or lua_table.geralt.being_revived == true 
        then
            lua_table["UI"]:MakeElementInvisible("Image", BLOODSCREEN)
            bleed = false
        end
    

    elseif lua_table.geralt.current_health > 50 
    then
        lua_table["UI"]:MakeElementInvisible("Image", BLOODSCREEN)
        bleed = false
    end

--------------
    if lua_table.jaskier.current_health <= 50 
    then
        if lua_table.jaskier.current_state > -3 
        then
            --lua_table["UI"]:MakeElementVisible("Image", BLOODSCREEN)
            bleed2 = true
            
        elseif lua_table.jaskier.current_state <= -3 or lua_table.jaskier.being_revived == true 
        then
            lua_table["UI"]:MakeElementInvisible("Image", BLOODSCREEN)
            bleed2 = false
        end
    

    elseif lua_table.jaskier.current_health > 50 
    then
        lua_table["UI"]:MakeElementInvisible("Image", BLOODSCREEN)
        bleed2 = false
    end

    --check who is printing the blood
    if bleed == true --or bleed2 == true
    then

        CheckAlpha(1)
        lua_table["UI"]:MakeElementVisible("Image", BLOODSCREEN)
       

    end
    if bleed2 == true --or bleed2 == true
    then

        CheckAlpha(2)
        lua_table["UI"]:MakeElementVisible("Image", BLOODSCREEN)
       
    end
    if bleed == true and bleed2 == true--to solve visual bug that happens when the two players are low, the one printing will be the lowest hp one
    then

        if lua_table.geralt.current_health < lua_table.jaskier.current_health
        then
            player_num = 1

        else
            lua_table["System"]:LOG("PLAYER2 LOW")
            player_num = 2
        end

        CheckAlpha(player_num)
        lua_table["UI"]:MakeElementVisible("Image", BLOODSCREEN)
    end


end

function lua_table:Awake()

    BLOODSCREEN = lua_table["GameObject"]:FindGameObject("BLOODSCREEN")
    PAUSEPREFAB = lua_table["GameObject"]:FindGameObject("ButtonManager")
    GERALTID = lua_table["GameObject"]:FindGameObject("Geralt")
    JASKIERID = lua_table["GameObject"]:FindGameObject("Jaskier")

    lua_table.pause = lua_table["GameObject"]:GetScript(PAUSEPREFAB)
    lua_table.geralt = lua_table["GameObject"]:GetScript(GERALTID)
    lua_table.jaskier = lua_table["GameObject"]:GetScript(JASKIERID)

end

function lua_table:Start()

    lua_table["UI"]:MakeElementInvisible("Image", BLOODSCREEN)

end

function lua_table:Update()

    timer = lua_table["System"]:GameTime()

    if lua_table.pause.gamePaused == true--paused game
    then
        lua_table["UI"]:MakeElementInvisible("Image", BLOODSCREEN)
    else
        BloodRegulation()
    end
    
    


end

return lua_table
end