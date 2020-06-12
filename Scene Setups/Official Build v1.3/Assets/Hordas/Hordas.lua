function GetTableHordas()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()

lua_table.begin = false
lua_table.spawn_rate = 0
lua_table.delay_rounds = 0

local time = 0
local delay_time = 0
local delay = false

local round0 = 0
local round1 = 0
local round2 = 0
local round3 = 0
local round4 = 0
local round5 = 0
local round6 = 0
local round7 = 0
local round8 = 0
local round9 = 0

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
    last_round = 0
    next_round = 0

    round0 = lua_table.GO:FindGameObject("Round0")
    round1 = lua_table.GO:FindGameObject("Round1")
    round2 = lua_table.GO:FindGameObject("Round2")
    round3 = lua_table.GO:FindGameObject("Round3")
    round4 = lua_table.GO:FindGameObject("Round4")
    round5 = lua_table.GO:FindGameObject("Round5")
    round6 = lua_table.GO:FindGameObject("Round6")
    round7 = lua_table.GO:FindGameObject("Round7")
    round8 = lua_table.GO:FindGameObject("Round8")
    round9 = lua_table.GO:FindGameObject("Round9")

    if round9 > 0 --round 9
    then
        round9_script = lua_table.GO:GetScript(round9)
    else
        last_round = 9
    end

    if round8 > 0 --round 8
    then
        round8_script = lua_table.GO:GetScript(round8)
    else
        last_round = 8
    end

    if round7 > 0 --round 7
    then
        round7_script = lua_table.GO:GetScript(round7)
    else
        last_round = 7
    end
    
    if round6 > 0 --round 6
    then
        round6_script = lua_table.GO:GetScript(round6)
    else
        last_round = 6
    end

    if round5 > 0 --round 5
    then
        round5_script = lua_table.GO:GetScript(round5)
    else
        last_round = 5
    end

    if round4 > 0 --round 4
    then
        round4_script = lua_table.GO:GetScript(round4)
    else
        last_round = 4
    end

    if round3 > 0 --round 3
    then
        round3_script = lua_table.GO:GetScript(round3)
    else
        last_round = 3
    end

    if round2 > 0 --round 2
    then
        round2_script = lua_table.GO:GetScript(round2)
    else
        last_round = 2
    end

    if round1 > 0 --round 1
    then
        round1_script = lua_table.GO:GetScript(round1)
    else
        last_round = 1
    end

    if round0 > 0 --round 0
    then
        round0_script = lua_table.GO:GetScript(round0)
    else
        last_round = 0
    end
end

function lua_table:Start()
end

function lua_table:Update()
    time = time + lua_table.System:DT()
    delay_time = delay_time + lua_table.System:DT()
    
    lua_table.System:LOG(next_round .. "..." .. last_round)
    if next_round > last_round
    then
        lua_table.begin = false
        lua_table.System:LOG("last")
    end
    
    if lua_table.begin == true
    then
        lua_table.System:LOG("begin")
        if time >= lua_table.spawn_rate
        then
            if delay == true --delay
            then
                lua_table.System:LOG("true")
                if delay_time >= lua_table.delay_rounds
                then
                    delay_time = 0
                    delay = false
                end
            else
                lua_table.System:LOG("false")
                if next_round == 0 and round0 > 0 --round 0
                then
                    if round0_script.is_finished == false
                    then
                        round0_script:Spawn()
                        lua_table.System:LOG("SPAWN 1")
                    elseif round0_script.is_finished == true and round0_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 1 and round1 > 0 --round 1
                then
                    if round1_script.is_finished == false
                    then
                        lua_table.System:LOG("SPAWN 2")
                        round1_script:Spawn()
                    elseif round1_script.is_finished == true and round1_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 2 and round2 > 0 --round 2
                then
                    if round2_script.is_finished == false
                    then
                        lua_table.System:LOG("SPAWN 3")
                        round2_script:Spawn()
                    elseif round2_script.is_finished == true and round2_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 3 and round3 > 0 --round 3
                then
                        lua_table.System:LOG("SPAWN 4")
                    if round3_script.is_finished == false
                    then
                        round3_script:Spawn()
                    elseif round3_script.is_finished == true and round3_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 4 and round4 > 0 --round 4
                then
                    if round4_script.is_finished == false
                    then
                        lua_table.System:LOG("SPAWN 5")
                        round4_script:Spawn()
                    elseif round4_script.is_finished == true and round4_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 5 and round5 > 0 --round 5
                then
                    if round5_script.is_finished == false
                    then
                        lua_table.System:LOG("SPAWN 6")
                        round5_script:Spawn()
                   elseif round5_script.is_finished == true and round5_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 6 and round6 > 0 --round 6
                then
                    if round6_script.is_finished == false
                    then
                        lua_table.System:LOG("SPAWN 7")
                        round6_script:Spawn()
                    elseif round6_script.is_finished == true and round6_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 7 and round7 > 0 --round 7
                then
                    if round7_script.is_finished == false
                    then
                        lua_table.System:LOG("SPAWN 8")
                        round7_script:Spawn()
                    elseif round7_script.is_finished == true and round7_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 8 and round8 > 0 --round 8
                then
                    if round8_script.is_finished == false
                    then
                        round8_script:Spawn()
                        lua_table.System:LOG("SPAWN 9")
                    elseif round8_script.is_finished == true and round8_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                elseif next_round == 9 and round9 > 0 --round 9
                then
                    if round8_script.is_finished == false
                    then
                        round8_script:Spawn()
                    elseif round9_script.is_finished == true and round9_script.auxCounter == 0 then
                        next_round = next_round + 1
                        delay = true
                        delay_time = 0
                    end
                end
            end

            time = 0
        end
    end
end

return lua_table
end