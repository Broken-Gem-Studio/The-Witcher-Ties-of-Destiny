function GetTableLore_VL_Manager()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Audio = Scripting.Audio()

local my_UID = 0

function lua_table:Awake()
    my_UID = lua_table.GO:GetMyUID()
end

function lua_table:Start()
end

function lua_table:Update()
end

function lua_table:PlayLevel_1_Start()
lua_table.Audio:PlayAudioEventGO("Play_Enemy_Conversation", my_UID)
end

return lua_table
end