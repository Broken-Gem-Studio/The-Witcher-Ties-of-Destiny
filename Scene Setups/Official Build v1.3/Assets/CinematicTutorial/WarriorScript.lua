function GetTableWarriorScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObject = Scripting.GameObject()
lua_table.Audio = Scripting.Audio()
lua_table.Scene = Scripting.Scenes()
lua_table.Input = Scripting.Inputs()
lua_table.UI = Scripting.Interface()
lua_table.Animations = Scripting.Animations()

local MyUID = 0

lua_table.is_sitting = true

local swing_speed = 0

function lua_table:Awake()
end

function lua_table:Start()
    MyUID =  lua_table.GameObject:GetMyUID()

    if lua_table.is_sitting == true then
        lua_table.Animations:PlayAnimation("Ground_Stun", 30.0, MyUID)
    end
end

function lua_table:Update()
end

return lua_table
end