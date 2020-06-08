function GetTableRound()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.Scene = Scripting.Scenes()

lua_table.enemy1 = 0
lua_table.enemy2 = 0
lua_table.enemy3 = 0
lua_table.enemy4 = 0
lua_table.enemy5 = 0
lua_table.enemy6 = 0

lua_table.num_e1 = 0
lua_table.num_e2 = 0
lua_table.num_e3 = 0
lua_table.num_e4 = 0
lua_table.num_e5 = 0
lua_table.num_e6 = 0

lua_table.final_enemy = 0
lua_table.is_final = false

lua_table.spawn_pos1 = 0
lua_table.spawn_pos2 = 0
lua_table.spawn_pos3 = 0

lua_table.is_finished = false

local e1_counter = 0
local e2_counter = 0
local e3_counter = 0
local e4_counter = 0
local e5_counter = 0
local e6_counter = 0

local enemy_spawn = 0
local position_spawn = 0
local pos = 0

function lua_table:Spawn()
    --finished
    if e1_counter == 0 and e2_counter == 0 and e3_counter == 0 and e4_counter == 0 and e5_counter == 0 and e6_counter == 0
    then 
        is_finished = true
    end

    if is_finished == false
    then
        --get spawn position
        position_spawn = lua_table.System:RandomNumberInRange(1,3)
        if position_spawn == 1
        then
            pos = lua_table.Transform:GetPosition(lua_table.spawn_pos1)
        elseif position_spawn == 2
        then
            pos = lua_table.Transform:GetPosition(lua_table.spawn_pos2)
        elseif position_spawn == 3
        then
            pos = lua_table.Transform:GetPosition(lua_table.spawn_pos3)
        end

        --spawn enemy
        if is_final == true --final enemy
        then
            lua_table.Scene:Instantiate(lua_table.final_enemy, pos[1], pos[2], pos[3], 0, 0, 0)
            is_finished = true
        else
            enemy_spawn = lua_table.System:RandomNumberInRange(1,6)
            if enemy_spawn == 1 and e1_counter > 0 --enemy 1
            then
                lua_table.Scene:Instantiate(lua_table.enemy1, pos[1], pos[2], pos[3], 0, 0, 0)
                e1_counter = e1_counter - 1
            elseif enemy_spawn == 2 and e2_counter > 0 --enemy 2
            then
                lua_table.Scene:Instantiate(lua_table.enemy2, pos[1], pos[2], pos[3], 0, 0, 0)
                e2_counter = e2_counter - 1
            elseif enemy_spawn == 3 and e3_counter > 0 --enemy 3
            then
                lua_table.Scene:Instantiate(lua_table.enemy3, pos[1], pos[2], pos[3], 0, 0, 0)
                e3_counter = e3_counter - 1
            elseif enemy_spawn == 4 and e4_counter > 0 --enemy 4
            then
                lua_table.Scene:Instantiate(lua_table.enemy4, pos[1], pos[2], pos[3], 0, 0, 0)
                e4_counter = e4_counter - 1
            elseif enemy_spawn == 5 and e5_counter > 0 --enemy 5
            then
                lua_table.Scene:Instantiate(lua_table.enemy5, pos[1], pos[2], pos[3], 0, 0, 0)
                e5_counter = e5_counter - 1
            elseif enemy_spawn == 6 and e6_counter > 0 --enemy 6
            then
                lua_table.Scene:Instantiate(lua_table.enemy6, pos[1], pos[2], pos[3], 0, 0, 0)
                e6_counter = e6_counter - 1
            end
        end
    end
end

function lua_table:Awake()
    e1_counter = lua_table.num_e1
    e2_counter = lua_table.num_e2
    e3_counter = lua_table.num_e3
    e4_counter = lua_table.num_e4
    e5_counter = lua_table.num_e5
    e6_counter = lua_table.num_e6
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end