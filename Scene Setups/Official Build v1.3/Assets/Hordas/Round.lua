function GetTableRound()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.Scene = Scripting.Scenes()
lua_table.GO = Scripting.GameObject()

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

lua_table.is_finished = false

local spawn_pos1 = 0
local spawn_pos2 = 0
local spawn_pos3 = 0

local e1_counter = 0
local e2_counter = 0
local e3_counter = 0
local e4_counter = 0
local e5_counter = 0
local e6_counter = 0

local enemy_spawn = 0
local position_spawn = 0
local pos = 0
local correct = false

local spawned_enemies = {}
local enemy_counter = 0
lua_table.auxCounter = 0

local stop = false

function lua_table:Reset()
    lua_table.is_finished = false
    enemy_counter = 0
    lua_table.auxCounter = 0
    enemy_spawn = 0
    correct = false
    stop = false
    for i=0, #spawned_enemies do spawned_enemies[i]=nil end
end

function lua_table:Spawn()
    --finished
    if e1_counter + e2_counter + e3_counter + e4_counter + e5_counter + e6_counter == enemy_counter
    then 
        lua_table.is_finished = true
    end

    if lua_table.is_finished == false
    then
        --get spawn position
        position_spawn = math.random(1,3)
        if position_spawn == 1
        then
            pos = lua_table.Transform:GetPosition(spawn_pos1)
        elseif position_spawn == 2
        then
            pos = lua_table.Transform:GetPosition(spawn_pos2)
        elseif position_spawn == 3
        then
            pos = lua_table.Transform:GetPosition(spawn_pos3)
        end

        --spawn enemy
        if lua_table.is_final == true --final enemy
        then
            lua_table.Scene:Instantiate(lua_table.final_enemy, pos[1], pos[2], pos[3], 0, 0, 0)
            lua_table.is_finished = true
        else
            --random enemy
            while correct == false
            do
                enemy_spawn = math.random(1,6)
                if enemy_spawn == 1 and e1_counter > 0
                then
                    correct = true
                elseif enemy_spawn == 2 and e2_counter > 0
                then
                    correct = true
                elseif enemy_spawn == 3 and e3_counter > 0
                then
                    correct = true
                elseif enemy_spawn == 4 and e4_counter > 0
                then
                    correct = true
                elseif enemy_spawn == 5 and e5_counter > 0
                then
                    correct = true
                elseif enemy_spawn == 6 and e6_counter > 0
                then
                    correct = true
                end
            end
            correct = false
            --enemies
            if enemy_spawn == 1 and e1_counter > 0 --enemy 1
            then
                enemy_counter = enemy_counter + 1
                spawned_enemies[enemy_counter] = lua_table.Scene:Instantiate(lua_table.enemy1, pos[1], pos[2], pos[3], 0, 0, 0)
            elseif enemy_spawn == 2 and e2_counter > 0 --enemy 2
            then
                enemy_counter = enemy_counter + 1
                spawned_enemies[enemy_counter] = lua_table.Scene:Instantiate(lua_table.enemy2, pos[1], pos[2], pos[3], 0, 0, 0)
            elseif enemy_spawn == 3 and e3_counter > 0 --enemy 3
            then
                enemy_counter = enemy_counter + 1
                spawned_enemies[enemy_counter] = lua_table.Scene:Instantiate(lua_table.enemy3, pos[1], pos[2], pos[3], 0, 0, 0)
            elseif enemy_spawn == 4 and e4_counter > 0 --enemy 4
            then
                enemy_counter = enemy_counter + 1
                spawned_enemies[enemy_counter] = lua_table.Scene:Instantiate(lua_table.enemy4, pos[1], pos[2], pos[3], 0, 0, 0)
            elseif enemy_spawn == 5 and e5_counter > 0 --enemy 5
            then
                enemy_counter = enemy_counter + 1
                spawned_enemies[enemy_counter] = lua_table.Scene:Instantiate(lua_table.enemy5, pos[1], pos[2], pos[3], 0, 0, 0)
            elseif enemy_spawn == 6 and e6_counter > 0 --enemy 6
            then
                enemy_counter = enemy_counter + 1
                spawned_enemies[enemy_counter] = lua_table.Scene:Instantiate(lua_table.enemy6, pos[1], pos[2], pos[3], 0, 0, 0)
            end
        end
    end
end

function lua_table:Awake()
    lua_table.is_finished = false

    if lua_table.num_e1 ~= nil
    then
        e1_counter = lua_table.num_e1
    end
    if lua_table.num_e2 ~= nil
    then
        e2_counter = lua_table.num_e2
    end
    if lua_table.num_e3 ~= nil
    then
        e3_counter = lua_table.num_e3
    end
    if lua_table.num_e4 ~= nil
    then
        e4_counter = lua_table.num_e4
    end
    if lua_table.num_e5 ~= nil
    then
        e5_counter = lua_table.num_e5
    end
    if lua_table.num_e6 ~= nil
    then
        e6_counter = lua_table.num_e6
    end

    spawn_pos1 = lua_table.GO:FindGameObject("Pos1")
    spawn_pos2 = lua_table.GO:FindGameObject("Pos2")
    spawn_pos3 = lua_table.GO:FindGameObject("Pos3")
end

function lua_table:Start()
end

function lua_table:Update()
    if stop == false and lua_table.is_finished == true
    then
        lua_table.auxCounter = enemy_counter
        for i = 1, #spawned_enemies do
            local active = lua_table.GO:GetLayerByID(spawned_enemies[i])
            if  active == -1 
            then
                lua_table.auxCounter = lua_table.auxCounter - 1
            end
        end

        if lua_table.auxCounter == 0
        then
            stop = true
        end
    end
end

return lua_table
end