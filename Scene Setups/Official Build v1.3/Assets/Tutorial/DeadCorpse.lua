function GetTableDeadCorpse()

local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Animations = Scripting.Animations()
lua_table.GameObject = Scripting.GameObject()

lua_table.MyUID = 0
local playedAnim = false
function lua_table:Awake()
    lua_table.MyUID = lua_table.GameObject:GetMyUID()
end

function lua_table:Start()
    if playedAnim == false
    then
        lua_table.Animations:PlayAnimation("Death", 30.0, lua_table.MyUID)
        playedAnim = true
    end
end
return lua_table
end