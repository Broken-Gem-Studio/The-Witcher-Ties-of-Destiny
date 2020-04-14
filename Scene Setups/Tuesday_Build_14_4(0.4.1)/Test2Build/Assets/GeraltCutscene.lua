function GetTableGeraltCutscene()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.AnimationFunctions = Scripting.Animations()

-- Camera target GO names
lua_table.geralt_GO = "Geralt"
lua_table.speed = 30.0

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from GeraltCutscene on AWAKE")
end

function lua_table:Start()
    lua_table.AnimationFunctions:PlayAnimation("Cutscene", lua_table.speed)
end

function lua_table:Update()
end

return lua_table
end