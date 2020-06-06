function GetTableCheckpoint()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics = Scripting.Physics()

local uid = 0
local winlose = 0
local winlose_script = 0

lua_table.checkpoint = 0

function lua_table:OnTriggerEnter()
    local collider = lua_table.Physics:OnTriggerEnter(uid)

    if lua_table.GO:GetLayerByID(collider) == 1
    then
        if last_checkpoint == nil or last_checkpoint < lua_table.checkpoint
        then
            --audio**
            --particles on**
            last_checkpoint = lua_table.checkpoint
            winlose_script:Checkpoint()
        end
    end
end

function lua_table:Awake()
    uid = lua_table.GO:GetMyUID()
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