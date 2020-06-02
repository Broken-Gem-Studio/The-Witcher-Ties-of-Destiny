function GetTableTriggerStep10()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.InterfaceFunctions = Scripting.Interface()

local manager
local managerTable
local geraltUID
local jaskierUID
local MyUUID
local justonce = false
local text 

function lua_table:OnTriggerEnter()
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    if justonce == false and colliderGO == geraltUID or colliderGO == jaskierUID and manager.currentStep == 10
    then    
        managerTable.PauseStep10 = true
        justonce = true
        lua_table.InterfaceFunctions:SetText("Kill the enemies! Try different combos!", text)
    end
end

function lua_table:Awake()
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    manager = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
    managerTable = lua_table.ObjectFunctions:GetScript(manager)
    geraltUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    jaskierUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")
    text = lua_table.ObjectFunctions:FindGameObject("Text")
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end