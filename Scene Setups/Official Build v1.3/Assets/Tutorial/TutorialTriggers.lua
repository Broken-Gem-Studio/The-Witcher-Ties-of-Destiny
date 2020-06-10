function GetTableTutorialTriggers()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.InterfaceFunctions = Scripting.Interface()

local manager
local managerTable
local geraltUID
local jaskierUID
local MyUUID
local text
local enemyCard

function lua_table:OnTriggerEnter()
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    lua_table.SystemFunctions:LOG("OSCAR TRIGGER STEP 4")
    if managerTable.currentStep == 4
    then
        if colliderGO == geraltUID or colliderGO == jaskierUID
        then
            managerTable.MoveEnemies = true
            lua_table.InterfaceFunctions:SetText("Kill all the enemies", text)
            lua_table.InterfaceFunctions:MakeElementVisible("Image", enemyCard)
        end
    end
end

function lua_table:Awake()
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    manager = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
    managerTable = lua_table.ObjectFunctions:GetScript(manager)
    geraltUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    jaskierUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")
    text = lua_table.ObjectFunctions:FindGameObject("Text")
    enemyCard = lua_table.ObjectFunctions:FindGameObject("L_ENEMY")
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end