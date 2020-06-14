function GetTabletriggerBigDoor()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.PhysicsFunctions = Scripting.Physics()

local MyUUID = 0
local bigDoorGO = 0
local bigDoorScript = 0
local keyCard = 0
local geraltUID = 0
local jaskierUID = 0

lua_table.openDoor = false

function lua_table:OnTriggerEnter()
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    if colliderGO == geraltUID or colliderGO == jaskierUID
    then
        if bigDoorScript.keyFound == false
        then  
            lua_table.InterfaceFunctions:MakeElementVisible("Image", keyCard)
        else
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
end

function lua_table:Start()
end

function lua_table:Update()
    if bigDoorScript.keyFound == true 
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", keyCard)
    end
end

return lua_table
end