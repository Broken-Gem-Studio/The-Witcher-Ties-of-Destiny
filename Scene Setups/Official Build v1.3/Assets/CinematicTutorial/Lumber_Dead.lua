function GetTableLumber_Dead()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Animations = Scripting.Animations()

lua_table.play_dead = true
local MyUID = 0

function lua_table:Awake()
end

function lua_table:Start()
    MyUID = lua_table.GameObject:GetMyUID()
end

function lua_table:Update()

    if lua_table.play_dead == true then
        lua_table.Animations:PlayAnimation("DEATH", 30.0, MyUID)
        lua_table.play_dead = false
    end
    
end

return lua_table
end