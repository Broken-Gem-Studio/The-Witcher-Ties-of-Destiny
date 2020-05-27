function GetTableCheckpoint()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()

local winlose = 0
local winlose_script = 0

lua_table.checkpoint = 0

function lua_table:OnTriggerEnter()
    if last_checkpoint == nil or last_checkpoint <= lua_table.checkpoint
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
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end