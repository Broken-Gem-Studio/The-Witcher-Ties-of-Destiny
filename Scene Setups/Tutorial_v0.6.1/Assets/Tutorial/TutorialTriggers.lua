function GetTableTutorialTriggers()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()

local manager
local managerTable
local geraltUID
local jaskierUID
local triggerStep4
local triggerStep6

function lua_table:OnTriggerEnter()
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    if MyUUID == triggerStep4
    then
        lua_table.SystemFunctions:LOG("hola collision step4")
        if colliderGO == geraltUID or colliderGO == jaskierUID
        then
            managerTable.MoveEnemies = true
            lua_table.SystemFunctions:LOG("hola move enemies = true")
        end
    end
    lua_table.SystemFunctions:LOG("hola trigger enter box")
    lua_table.SystemFunctions:LOG("hola colliderGO: "..colliderGO)
    lua_table.SystemFunctions:LOG("hola MyUUID: "..MyUUID)
    lua_table.SystemFunctions:LOG("hola geraltUID: "..geraltUID)
    lua_table.SystemFunctions:LOG("hola jaskierUID: "..jaskierUID)
    lua_table.SystemFunctions:LOG("hola triggerStep4: "..triggerStep4)
    lua_table.SystemFunctions:LOG("hola triggerStep6: "..triggerStep6)

    if MyUUID == triggerStep6
    then
        lua_table.SystemFunctions:LOG("hola collision step6")
        if colliderGO == geraltUID or colliderGO == jaskierUID
        then    
            lua_table.SystemFunctions:LOG("hola he entrat a la colisio")
            managerTable.PauseStep6 = true
        end
    end
end

function lua_table:Awake()
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    manager = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
    managerTable = lua_table.ObjectFunctions:GetScript(manager)
    geraltUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    jaskierUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")

    triggerStep4 = lua_table.ObjectFunctions:FindGameObject("triggerStep4")
    triggerStep6 = lua_table.ObjectFunctions:FindGameObject("triggerStep6")

    lua_table.SystemFunctions:LOG("triggerStep6: "..triggerStep6)


end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end