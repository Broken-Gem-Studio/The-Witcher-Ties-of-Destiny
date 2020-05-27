function    GetTableBOSSHP()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()


--------
lua_table.boss_hp = 0
--local boss_hp_local = 0

local BossBar = 0
local BossCapsule = 0
local BossBackground = 0
--local BossText= 0
local BossID = 0
lua_table.boss = {}

--MAIN CODE
function lua_table:Awake()
   
    BossBar = lua_table["GameObject"]:FindGameObject("BOSSHP")
    BossBackground = lua_table["GameObject"]:FindGameObject("BOSSBACKGROUND")
    BossCapsule = lua_table["GameObject"]:FindGameObject("BOSSCAPSULE")
    --BossText = lua_table["GameObject"]:FindGameObject("BOSSTEXT")
    BossID = lua_table["GameObject"]:FindGameObject("Kikimora")
    lua_table.boss = lua_table["GameObject"]:GetScript(BossID)


end

function lua_table:Start()
   
    --lua_table.boss_hp = lua_table.boss.health
    lua_table["System"]:LOG ("INITIAL BOSS HP: " .. lua_table.boss.current_health_percentage)
   

end

function lua_table:Update()
    lua_table["System"]:LOG ("INITIAL BOSS HP: " .. lua_table.boss.current_health_percentage)
    --make appear/dissapear bar whren kikimora appears/dies
    --bool desde script de Pol
    if lua_table.boss.awakened == true
    then
        lua_table["UI"]:MakeElementVisible("Image", BossBar)--MIRAR SI ESTA BIEN BAR
        lua_table["UI"]:MakeElementVisible("Image", BossBackground)
        lua_table["UI"]:MakeElementVisible("Image", BossCapsule)
        --lua_table["UI"]:MakeElementVisible("Text", BossText)
    end

    if lua_table.boss.awakened == false
    then
        lua_table["UI"]:MakeElementInvisible("Image", BossBar)
        lua_table["UI"]:MakeElementInvisible("Image", BossBackground)
        lua_table["UI"]:MakeElementInvisible("Image", BossCapsule)
        --lua_table["UI"]:MakeElementInvisible("Text", BossText)
    end
    


    if lua_table.boss.current_health_percentage > 0
    then
        lua_table["UI"]:SetUIBarPercentage(lua_table.boss.current_health_percentage, BossBar)
        --lua_table["UI"]:SetTextNumber(lua_table.boss.current_health, BossText)--cuidado que sea lua_table
    end

    if lua_table.boss.current_health_percentage <= 0--condicion para cuando le pegan una leche a boss que sobrepasa su vida actual y lo mata, que no se bugee la barra
    then
        lua_table["UI"]:SetUIBarPercentage(0, BossBar)
        --lua_table["UI"]:SetTextNumber(0, BossText)
    end
      

end

    return lua_table
end