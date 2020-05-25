function GetTableCheckpoint()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()

local winlose = 0
local winlose_script = 0

lua_table.checkpoint

local function OnTriggerEnter()
    if lua_table.GO:GetLayerByID(1)
    then
        last_checkpoint = lua_table.checkpoint
        winlose_script:Checkpoint()
    end
end

function lua_table:Awake()
    winlose = lua_table.GO:FindGameObject("WinLose")
    winlose_script = lua_table.GO:GetScript(winlose)
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end