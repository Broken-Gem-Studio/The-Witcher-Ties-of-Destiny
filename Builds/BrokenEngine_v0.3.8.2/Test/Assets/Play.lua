function GetTablePlay()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Scenes = Scripting.Scenes()

lua_table.nextScene = 0

function lua_table:Awake()
end

function lua_table:Start()
end

function lua_table:Update()
end

function lua_table:LoadScene()
   lua_table.Scenes:LoadScene(lua_table.nextScene)
end

return lua_table
end