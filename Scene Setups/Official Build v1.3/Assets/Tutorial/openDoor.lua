function GetTableopenDoor()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.Audio = Scripting.Audio()

local manager
local managerTable
local geraltUID
local jaskierUID
local MyUUID
local doorGO
local doorCollider
local hasOpened = false

function lua_table:OnTriggerEnter()
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    if managerTable.currentStep == 0 and hasOpened == false
    then    
        if colliderGO == geraltUID or colliderGO == jaskierUID
        then
            lua_table.ObjectFunctions:SetActiveGameObject(false, doorCollider)
            lua_table.AnimationFunctions:PlayAnimation("open", 30, doorGO)
            
            lua_table.Audio:PlayAudioEventGO("Play_Locked_And_No_Key_In_Sight", MyUUID)

            hasOpened = true
        end
    end
end

function lua_table:Awake()
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    manager = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
    managerTable = lua_table.ObjectFunctions:GetScript(manager)
    geraltUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    jaskierUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")
    doorGO = lua_table.ObjectFunctions:FindGameObject("Door_4")
    doorCollider = lua_table.ObjectFunctions:FindGameObject("colliderDoor4")
end

function lua_table:Start()
    hasOpened = false
end

function lua_table:Update()
end

return lua_table
end