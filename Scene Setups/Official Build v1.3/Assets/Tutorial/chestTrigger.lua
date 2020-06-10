function GetTablechestTrigger()
local lua_table = {}

lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics = Scripting.Physics()

local uid = 0
local tutorialGO = 0
local tutorialScript = 0

function lua_table:OnTriggerEnter()
    local collider = lua_table.Physics:OnTriggerEnter(uid)

    if lua_table.GO:GetLayerByID(collider) == 1
    then
        tutorialScript.chestCard = true
    end
end

function lua_table:Awake()
    uid = lua_table.GO:GetMyUID()
    tutorialGO = lua_table.GO:FindGameObject("TutorialManager")
    tutorialScript = lua_table.GO:GetScript(tutorialGO)
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end