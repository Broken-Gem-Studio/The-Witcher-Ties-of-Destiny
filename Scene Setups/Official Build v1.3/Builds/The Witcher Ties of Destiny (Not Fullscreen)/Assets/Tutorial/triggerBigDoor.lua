function GetTabletriggerBigDoor()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.Audio = Scripting.Audio()

local MyUUID = 0
local bigDoorGO = 0
local bigDoorScript = 0
local keyCard = 0
local geraltUID = 0
local jaskierUID = 0
local tutorialGO = 0
local tutorialScript = 0
local playOnce = false

lua_table.openDoor = false

function lua_table:OnTriggerEnter()
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    if colliderGO == geraltUID or colliderGO == jaskierUID
    then
        if bigDoorScript.keyFound == false and tutorialScript.currentStep == 0
        then  
            lua_table.InterfaceFunctions:MakeElementVisible("Image", keyCard)
        elseif bigDoorScript.keyFound == true 
        then
            lua_table.openDoor = true
        end
    end
end

function lua_table:Awake()
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    bigDoorGO = lua_table.ObjectFunctions:FindGameObject("Door_3")
    bigDoorScript = lua_table.ObjectFunctions:GetScript(bigDoorGO)
    keyCard = lua_table.ObjectFunctions:FindGameObject("L_KEY")
    geraltUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    jaskierUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")
    tutorialGO = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
    tutorialScript = lua_table.ObjectFunctions:GetScript(tutorialGO)
end

function lua_table:Start()
end

function lua_table:Update()
    if bigDoorScript.keyFound == true and playOnce == false
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", keyCard)
        lua_table.Audio:PlayAudioEventGO("Play_Must_Be_The_Key", MyUUID)
        playOnce = true
    end
end

return lua_table
end