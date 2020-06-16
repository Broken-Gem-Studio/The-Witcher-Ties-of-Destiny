function GetTableLumber_Alive()
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
local stand_timer = 0

local attack = 0
local swing_speed = 0

local start_attack = false
local attack_timer = 0

function lua_table:Awake()
end

function lua_table:Start()
    MyUID = lua_table.GameObject:GetMyUID()
end

function lua_table:Update()
    if start_attack == false then 

        attack = math.random(1, 2)
        swing_speed = math.random(30, 50)
        attack_timer = lua_table.System:GameTime() * 1000 

        if attack == 1 then 
            lua_table.Animations:PlayAnimation("Attack1", swing_speed, MyUID)
        elseif attack == 2 then 
            lua_table.Animations:PlayAnimation("Attack2", swing_speed, MyUID)
        end

        start_attack = true
    end

    if attack == 1 and attack_timer + 1000 <= lua_table.System:GameTime() * 1000 then 
        start_attack = false
    elseif attack == 2 and attack_timer + 1000 <= lua_table.System:GameTime() * 1000 then 
        start_attack = false
    end
    
end

return lua_table
end