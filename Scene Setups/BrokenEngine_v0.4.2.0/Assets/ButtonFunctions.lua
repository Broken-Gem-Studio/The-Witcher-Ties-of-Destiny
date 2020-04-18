function GetTableButtonFunctions()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Scenes = Scripting.Scenes()

function lua_table:Play()
	lua_table.System:ResumeGame()
end

function lua_table:Stop()
	lua_table.System:PauseGame()
end

function lua_table:Quit()
	lua_table.Scenes:QuitGame()
end

return lua_table
end