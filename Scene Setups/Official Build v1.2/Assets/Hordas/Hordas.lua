function GetTableHordas()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()

lua_table.begin = false

lua_table.round0 = 0
lua_table.round1 = 0
lua_table.round2 = 0
lua_table.round3 = 0
lua_table.round4 = 0
lua_table.round5 = 0
lua_table.round6 = 0
lua_table.round7 = 0
lua_table.round8 = 0
lua_table.round9 = 0

lua_table.spawn_rate = 0
lua_table.time = 0

local round0_script = 0
local round1_script = 0
local round2_script = 0
local round3_script = 0
local round4_script = 0
local round5_script = 0
local round6_script = 0
local round7_script = 0
local round8_script = 0
local round9_script = 0
local next_round = 0
local last_round = 0

function lua_table:Awake()
    if lua_table.round9 > 0 --round 9
    then
        round9_script = lua_table.GO:GetScript(lua_table.round9)
    else
        last_round = 9
    end

    if lua_table.round8 > 0 --round 8
    then
        round8_script = lua_table.GO:GetScript(lua_table.round8)
    else
        last_round = 8
    end

    if lua_table.round7 > 0 --round 7
    then
        round7_script = lua_table.GO:GetScript(lua_table.round7)
    else
        last_round = 7
    end
    
    if lua_table.round6 > 0 --round 6
    then
        round6_script = lua_table.GO:GetScript(lua_table.round6)
    else
        last_round = 6
    end

    if lua_table.round5 > 0 --round 5
    then
        round5_script = lua_table.GO:GetScript(lua_table.round5)
    else
        last_round = 5
    end

    if lua_table.round4 > 0 --round 4
    then
        round4_script = lua_table.GO:GetScript(lua_table.round4)
    else
        last_round = 4
    end

    if lua_table.round3 > 0 --round 3
    then
        round3_script = lua_table.GO:GetScript(lua_table.round3)
    else
        last_round = 3
    end

    if lua_table.round2 > 0 --round 2
    then
        round2_script = lua_table.GO:GetScript(lua_table.round2)
    else
        last_round = 2
    end

    if lua_table.round1 > 0 --round 1
    then
        round1_script = lua_table.GO:GetScript(lua_table.round1)
    else
        last_round = 1
    end

    if lua_table.round0 > 0 --round 0
    then
        round0_script = lua_table.GO:GetScript(lua_table.round0)
    else
        last_round = 0
    end

    next_round = 0
end

function lua_table:Start()
end

function lua_table:Update()
    lua_table.time = lua_table.time + lua_table.System:DT()
    
    if next_round >= last_round
    then
        lua_table.begin = false
    end
    
    if lua_table.begin == true
    then
        if lua_table.time >= lua_table.spawn_rate
        then
            if next_round == 0 and lua_table.round0 > 0 --round 0
            then
                if round0_script.is_finished == false
                then
                    round0_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 1 and lua_table.round1 > 0 --round 1
            then
                if round1_script.is_finished == false
                then
                    round1_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 2 and lua_table.round2 > 0 --round 2
            then
                if round2_script.is_finished == false
                then
                    round2_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 3 and lua_table.round3 > 0 --round 3
            then
                if round3_script.is_finished == false
                then
                    round3_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 4 and lua_table.round4 > 0 --round 4
            then
                if round4_script.is_finished == false
                then
                    round4_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 5 and lua_table.round5 > 0 --round 5
            then
                if round5_script.is_finished == false
                then
                    round5_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 6 and lua_table.round6 > 0 --round 6
            then
                if round6_script.is_finished == false
                then
                    round6_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 7 and lua_table.round7 > 0 --round 7
            then
                if round7_script.is_finished == false
                then
                    round7_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 8 and lua_table.round8 > 0 --round 8
            then
                if round8_script.is_finished == false
                then
                    round8_script:Spawn()
                else
                    next_round = next_round + 1
                end
            elseif next_round == 9 and lua_table.round9 > 0 --round 9
            then
                if round8_script.is_finished == false
                then
                    round8_script:Spawn()
                else
                    next_round = next_round + 1
                end
            end
            lua_table.time = 0
        end
    end
end

return lua_table
end