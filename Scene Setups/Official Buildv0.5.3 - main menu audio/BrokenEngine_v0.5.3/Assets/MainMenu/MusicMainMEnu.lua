function GetTableMusicMainMEnu()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Audio = Scripting.Audio()

function lua_table:Awake()
lua_table.Audio:StopAudioEvent("Default")
lua_table.Audio:StopAudioEvent("Rest")
lua_table.Audio:StopAudioEvent("Combat")
lua_table.Audio:PlayAudioEvent("Play_Main_menu")
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end