function GetTableDeathHUD()
local lua_table = {}
lua_table["GameObject"] = Scripting.GameObject()
lua_table["Inputs"] = Scripting.Inputs()
lua_table["System"] = Scripting.System()
lua_table["UI"] = Scripting.Interface()
lua_table["Transform"] = Scripting.Transform()
lua_table["Audio"] = Scripting.Audio()

local P1ID = 0--ID GERALT
lua_table.p1 = {}
local P2ID = 0--ID JASKIER
lua_table.p2 = {}

local death1ID = 0
local death2ID = 0

local revive1ID = 0
local revive2ID = 0

local revivaval1ID = 0
local revivaval2ID = 0


local timer = 0
local timer1ID = 0
local timerdeath1 = 0
local timer2ID = 0
local timerdeath2 = 0

local revived = false
local revived2 = false


function lua_table:Awake()

    P1ID = lua_table["GameObject"]:FindGameObject("Geralt")
    lua_table.p1 = lua_table["GameObject"]:GetScript(P1ID)
    death1ID = lua_table["GameObject"]:FindGameObject("GERDEATH")
    revive1ID = lua_table["GameObject"]:FindGameObject("GERREVIVE")
    revivaval1ID = lua_table["GameObject"]:FindGameObject("GERREVIVAVAL")
    timer1ID = lua_table["GameObject"]:FindGameObject("GERDEATHTIMER")
    

    
    P2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
    lua_table.p2 = lua_table["GameObject"]:GetScript(P2ID)
    death2ID = lua_table["GameObject"]:FindGameObject("JASKDEATH")
    revive2ID = lua_table["GameObject"]:FindGameObject("JASKREVIVE")
    revivaval2ID = lua_table["GameObject"]:FindGameObject("JASKREVIVAVAL")
    timer2ID = lua_table["GameObject"]:FindGameObject("JASKDEATHTIMER")
    

end

function lua_table:Start()

    lua_table["UI"]:MakeElementInvisible("Image", death1ID)
    lua_table["UI"]:MakeElementInvisible("Image", death2ID)
    lua_table["UI"]:MakeElementInvisible("Image", revive1ID)
    lua_table["UI"]:MakeElementInvisible("Image", revive2ID)
    lua_table["UI"]:MakeElementInvisible("Image", revivaval1ID)
    lua_table["UI"]:MakeElementInvisible("Image", revivaval2ID)

    lua_table["UI"]:MakeElementInvisible("Text", timer1ID)
    lua_table["UI"]:MakeElementInvisible("Text", timer2ID)
   

end

function lua_table:Update()

    timer = lua_table["System"]:GameTime()
    lua_table["System"]:LOG("TIMER: " .. timer)
    lua_table["System"]:LOG("REVIVE TIME: " .. lua_table.p1.revive_time)
    lua_table["System"]:LOG("REVIVE STARTED AT: " .. lua_table.p1.revive_started_at)
    lua_table["System"]:LOG("DOWN: " .. lua_table.p1.down_time)
    lua_table["System"]:LOG("DEATH STARTED AT: " .. lua_table.p1.death_started_at)
   

    --GERALT

    if lua_table.p1.current_state > -3 --if not down no death
    then
        lua_table["UI"]:MakeElementInvisible("Image", death1ID)
        lua_table["UI"]:MakeElementInvisible("Image", revive1ID)
        lua_table["UI"]:MakeElementInvisible("Image", revivaval1ID)
        lua_table["UI"]:MakeElementInvisible("Text", timer1ID)
        
        
    end
    
    if lua_table.p1.being_revived == true
    then
        lua_table["UI"]:MakeElementVisible("Image", revivaval1ID)

        if revived == false
        then
            lua_table["UI"]:PlayUIAnimation(revivaval1ID)
            revived = true
        end

        if lua_table["UI"]:UIAnimationFinished(revivaval1ID) == true
        then
            revived = false
        end
      
    
        --lua_table["UI"]:MakeElementInvisible("Image", revive1ID)
        lua_table["UI"]:MakeElementInvisible("Image", death1ID)
        lua_table["UI"]:SetText("REVIVING", timer1ID)
    end

    if lua_table.p1.current_state == -3 and lua_table.p1.being_revived == false--REVIVE STATE
    then
        timerdeath1 = (lua_table.p1.down_time/1000) - (timer -  lua_table.p1.death_started_at / 1000)
        timerdeath1 = math.floor(timerdeath1)
        lua_table["UI"]:SetTextNumber(timerdeath1, timer1ID)
        lua_table["UI"]:MakeElementVisible("Text", timer1ID)
        
        lua_table["UI"]:MakeElementVisible("Image", revive1ID)
        lua_table["UI"]:MakeElementInvisible("Image", death1ID)
        lua_table["UI"]:MakeElementInvisible("Image", revivaval1ID)
    end


    if lua_table.p1.current_state == -4 --DEATH STATE
    then
        lua_table["UI"]:MakeElementVisible("Image", death1ID)
        lua_table["UI"]:MakeElementInvisible("Image", revivaval1ID)
        lua_table["UI"]:MakeElementInvisible("Image", revive1ID)
        lua_table["UI"]:MakeElementInvisible("Text", timer1ID)
    end


    --JASKIER
    
    if lua_table.p2.current_state > -3 --if not down no death
    then
        lua_table["UI"]:MakeElementInvisible("Image", death2ID)
        lua_table["UI"]:MakeElementInvisible("Image", revive2ID)
        lua_table["UI"]:MakeElementInvisible("Image", revivaval2ID)
        lua_table["UI"]:MakeElementInvisible("Text", timer2ID)
        
    end
    
    if lua_table.p2.being_revived == true
    then
        lua_table["UI"]:MakeElementVisible("Image", revivaval2ID)

        if revived2 == false
        then
            lua_table["UI"]:PlayUIAnimation(revivaval2ID)
            revived2 = true
        end

        if lua_table["UI"]:UIAnimationFinished(revivaval2ID) == true
        then
            revived2 = false
        end
        --lua_table["UI"]:MakeElementInvisible("Image", revive2ID)
        lua_table["UI"]:MakeElementInvisible("Image", death2ID)
        lua_table["UI"]:SetText("REVIVING", timer2ID)
    end

    if lua_table.p2.current_state == -3 and lua_table.p2.being_revived == false--REVIVE STATE
    then
        timerdeath2 = (lua_table.p2.down_time/1000) - (timer -  lua_table.p2.death_started_at / 1000)
        timerdeath2 = math.floor(timerdeath2)
        lua_table["UI"]:SetTextNumber(timerdeath2, timer2ID)
        lua_table["UI"]:MakeElementVisible("Text", timer2ID)
        
        lua_table["UI"]:MakeElementVisible("Image", revive2ID)
        lua_table["UI"]:MakeElementInvisible("Image", death2ID)
        lua_table["UI"]:MakeElementInvisible("Image", revivaval2ID)
    end


    if lua_table.p2.current_state == -4 --DEATH STATE
    then
        lua_table["UI"]:MakeElementVisible("Image", death2ID)
        lua_table["UI"]:MakeElementInvisible("Image", revivaval2ID)
        lua_table["UI"]:MakeElementInvisible("Image", revive2ID)
        lua_table["UI"]:MakeElementInvisible("Text", timer2ID)
    end

   lua_table["System"]:LOG("TIME TEST: " .. timerdeath2)

end

return lua_table
end