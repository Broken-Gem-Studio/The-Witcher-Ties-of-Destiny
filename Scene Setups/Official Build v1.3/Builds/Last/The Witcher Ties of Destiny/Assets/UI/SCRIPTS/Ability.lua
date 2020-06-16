function GetTableAbility()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()
    lua_table["Audio"] = Scripting.Audio()

local timer = 0
--local cd = 3--seconds
lua_table.cdP1 = {}--cd script carles gerardo1
lua_table.cdP2 = {}
local tiempopasado = 0
local tiempopasado2 = 0
local used = false
local used2 = false
local specialID = 0
local specialCDID = 0
local p1ID = 0
local special2ID = 0
local specialCD2ID = 0
local p2ID = 0

local counter = 0
local counter2 = 0


function PlayingSound()

    lua_table["Audio"]:PlayAudioEventGO("Play_HUD_Special_Up", specialID)
end

function AbilityCD(id)

    if id == specialID--P1
    then

        lua_table["UI"]:MakeElementInvisible("Image", specialID)
        lua_table["UI"]:MakeElementVisible("Image", specialCDID)--escondemos la imagen y enseñamos la de CD

    elseif id == specialCDID
    then
        lua_table["UI"]:MakeElementInvisible("Image", specialCDID)
        lua_table["UI"]:MakeElementVisible("Image", specialID)--escondemos la CD y volvemos a enseñar la origginal

    elseif id == special2ID--P2
    then

        lua_table["UI"]:MakeElementInvisible("Image", special2ID)
        lua_table["UI"]:MakeElementVisible("Image", specialCD2ID)--escondemos la CD y volvemos a enseñar la origginal

    elseif id == specialCD2ID
    then

        lua_table["UI"]:MakeElementInvisible("Image", specialCD2ID)
        lua_table["UI"]:MakeElementVisible("Image", special2ID)--escondemos la CD y volvemos a enseñar la origginal



    end


end

function AbilityUP(id)--INUTIL POR AHORA
    
        if id == specialID
        then
            lua_table["UI"]:MakeElementVisible("Image", specialID)
        end
    
end


function lua_table:Awake()

    specialID = lua_table["GameObject"]:FindGameObject("SPECIAL")--exact name of gameobject
    specialCDID = lua_table["GameObject"]:FindGameObject("SPECIALCD")--exact name of gameobject
    special2ID = lua_table["GameObject"]:FindGameObject("SPECIAL2")--exact name of gameobject
    specialCD2ID = lua_table["GameObject"]:FindGameObject("SPECIALCD2")--exact name of gameobject

    
    p1ID = lua_table["GameObject"]:FindGameObject("Geralt")
    lua_table.cdP1 = lua_table["GameObject"]:GetScript(p1ID)

    p2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
    lua_table.cdP2 = lua_table["GameObject"]:GetScript(p2ID)


end

function lua_table:Start()
    
    if specialCDID == 0
    then
    lua_table["System"]:LOG ("FAILED TO FIND")
    end
    
    lua_table["UI"]:MakeElementInvisible("Image", specialID)
    lua_table["UI"]:MakeElementInvisible("Image", special2ID)
    --lua_table["UI"]:MakeElementInvisible("Image", specialCDID)--imagen del cd de la abilidad en invisible al principio de la escena
    --lua_table["UI"]:MakeElementInvisible("Image", specialCD2ID)

end

function lua_table:Update()
    dt = lua_table["System"]:DT()
    timer = lua_table["System"]:GameTime()

    lua_table["System"]:LOG ("VALUE CD: " .. lua_table.cdP1.ability_cooldown)--CON ESTO DEMOSTRAMOS QUE ESTAMOS PILLANDO LA VARIABLE CD DE CARLES
    lua_table["System"]:LOG ("VALUE CD2: " .. lua_table.cdP2.ability_cooldown)--LO MISMO PERO PARA EL SEGUNDO PLAYER

    
    --if lua_table["Inputs"]:KeyDown ("A") and used == false
    if lua_table.cdP1.ability_performed == true and used == false--booleana que utilice carles
    then
        counter = 0
       AbilityCD(specialID)
       tiempopasado = lua_table["System"]:GameTime()       
       used = true 
    end

    if lua_table.cdP1.ability_performed == false and timer - tiempopasado >= (lua_table.cdP1.ability_cooldown / 1000) -- si pasan CD TIME DE SCRIPT CARLES
    then
        AbilityCD(specialCDID)
        used = false
        --lua_table.cdP1.used_ability = false
       
    end

    if used == false and timer - tiempopasado >= (lua_table.cdP1.ability_cooldown / 1000) and counter == 0
    then
        --lua_table["System"]:LOG("TRY")
        PlayingSound()
        counter = 1
    end

    --------------------

    if lua_table.cdP2.ability_performed == true and used2 == false--esta fallando por que estamos utilizando el mismo script que el de geralt, cuando jaskier tenga el suyo propio, en teoria de esta manera las dos abilidades no cogeran el input a la vez
    then 
        counter2 = 0
       AbilityCD(special2ID)
       tiempopasado2 = lua_table["System"]:GameTime()       
       used2 = true 
    end

    if lua_table.cdP2.ability_performed == false and timer - tiempopasado2 >= (lua_table.cdP2.ability_cooldown / 1000) -- si pasan CD TIME DE SCRIPT CARLES
    then

        AbilityCD(specialCD2ID)
        used2 = false
        --lua_table.cdP2.used_ability = false
       
    end

    if used2 == false and timer - tiempopasado2 >= (lua_table.cdP2.ability_cooldown / 1000) and counter2 == 0
    then
        --lua_table["System"]:LOG("TRY2")
        --PlayingSound()
        counter2 = 1
    end


end

return lua_table
end