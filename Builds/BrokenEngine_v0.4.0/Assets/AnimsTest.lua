function GetTableAnimsTest()
local lua_table = {}

lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.AnimationSystem = Scripting.Animations()

function lua_table:Awake()
end

function lua_table:Start()
	lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",30.0)
	lua_table.SystemFunctions:LOG("LOOKING_ARROUND")
end

function lua_table:Update()
end

return lua_table
end