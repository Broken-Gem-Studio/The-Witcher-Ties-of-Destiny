function GetTableWarriorTutorial()
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

lua_table.ground_stun = true
lua_table.ground_idle = false
lua_table.actual_stand_time = 0
local stand_timer = 0

local attack = 0
local swing_speed = 0

local start_attack = false
local attack_timer = 0

local dt = 0

function lua_table:Awake()
end

function lua_table:Start()
    MyUID =  lua_table.GameObject:GetMyUID()

    if lua_table.ground_stun == true and lua_table.ground_idle == true then 
        lua_table.ground_stun = false
    end

    if lua_table.ground_stun == true then
        lua_table.Animations:PlayAnimation("Ground_Stun", 30.0, MyUID)
    end

    if lua_table.ground_idle == true and lua_table.ground_stun == false then
        lua_table.Animations:PlayAnimation("Ground_Idle", 30.0, MyUID)
    end
end

function lua_table:Update()
end

return lua_table
end