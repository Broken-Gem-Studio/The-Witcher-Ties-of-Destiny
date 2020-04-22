function GetTableSignScript()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.InterfaceFunctions = Scripting.Interface()

local startButton = 0
local fallingTime = 7.4
local lastTimeFallen = 0
local notPlayedIdle = true

function lua_table:Awake()
	startButton = lua_table.ObjectFunctions:FindGameObject("StartButton")
	lua_table.AnimationFunctions:PlayAnimation("Fall", 30)
	lastTimeFallen = lua_table.SystemFunctions:GameTime()
end

function lua_table:Start()
end

function lua_table:Update()
	if lua_table.SystemFunctions:GameTime() > lastTimeFallen + fallingTime and notPlayedIdle
	then
		lua_table.AnimationFunctions:PlayAnimation("Idle", 30)
		notPlayedIdle = false
	lua_table.InterfaceFunctions:MakeElementVisible("Button", startButton)
	end
end

return lua_table
end