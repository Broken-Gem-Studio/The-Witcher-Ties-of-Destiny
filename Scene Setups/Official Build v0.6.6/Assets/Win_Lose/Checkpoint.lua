function GetTableCheckpoint()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()

local winlose = 0
local winlose_script = 0
local geraltUID
local jaskierUID
local MyUUID

lua_table.checkpoint = 0

function lua_table:OnTriggerEnter()
    
    local colliderGO = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)

    if last_checkpoint == nil or last_checkpoint < lua_table.checkpoint and colliderGO == geraltUID or colliderGO == jaskierUID
    then
        last_checkpoint = lua_table.checkpoint
        winlose_script:Checkpoint()
    end
end

function lua_table:Awake()
    winlose = lua_table.GO:FindGameObject("WinLose")

    if winlose > 0
    then
        winlose_script = lua_table.GO:GetScript(winlose)
    end
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    geraltUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    jaskierUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")

end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end