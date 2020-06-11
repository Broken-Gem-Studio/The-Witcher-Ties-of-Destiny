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
lua_table.is_dead = false
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

    if lua_table.is_sitting == true and lua_table.is_dead == true then 
        lua_table.is_sitting = false
    end

    if lua_table.is_sitting == true then
        lua_table.Animations:PlayAnimation("Ground_Stun", 30.0, MyUID)
    end

    if lua_table.is_dead == true and lua_table.is_sitting == false then
        lua_table.Animations:PlayAnimation("Death", 30.0, MyUID)
    end
end

function lua_table:Update()

    dt = lua_table.System:DT()

    stand_timer = stand_timer + dt

    if lua_table.is_dead == false and lua_table.actual_stand_time <= stand_timer then 
        if start_attack == false then 

            attack = math.random(1, 2)
            swing_speed = math.random(30, 50)
            attack_timer = lua_table.System:GameTime() * 1000 

            if attack == 1 then 
                lua_table.Animations:PlayAnimation("Attack_1", swing_speed, MyUID)
            elseif attack == 2 then 
                lua_table.Animations:PlayAnimation("Attack_2", swing_speed, MyUID)
            end

            start_attack = true
        end

        if attack == 1 and attack_timer + 1300 <= lua_table.System:GameTime() * 1000 then 
            start_attack = false
        elseif attack == 2 and attack_timer + 1900 <= lua_table.System:GameTime() * 1000 then 
            start_attack = false
        end
    end 
    

end

return lua_table
end