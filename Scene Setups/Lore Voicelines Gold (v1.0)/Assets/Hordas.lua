function GetTableHordas()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()

lua_table.spawn_rate = 0

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

local function Spawn()
    if time == lua_table.spawn_rate
    then
        if next_round = 0
        then
            round0_script:Spawn()
        elseif next_round = 1
        then
            round1_script:Spawn()
        elseif next_round = 2
        then
            round2_script:Spawn()
        elseif next_round = 3
        then
            round3_script:Spawn()
        elseif next_round = 4
        then
            round4_script:Spawn()
        elseif next_round = 5
        then
            round5_script:Spawn()
        elseif next_round = 6
        then
            round6_script:Spawn()
        elseif next_round = 7
        then
            round7_script:Spawn()
        elseif next_round = 8
        then
            round8_script:Spawn()
        elseif next_round = 9
        then
            round9_script:Spawn()
        end

        next_round = next_round + 1
        time = 0
    end
end

function lua_table:Awake()
    if round0 > 0 --round 0
    then
        round0_script = lua_table.GO:GetScript(round0)
    end
    if round1 > 0 --round 1
    then
        round1_script = lua_table.GO:GetScript(round0)
    end
    if round2 > 0 --round 2
    then
        round2_script = lua_table.GO:GetScript(round0)
    end
    if round3 > 0 --round 3
    then
        round3_script = lua_table.GO:GetScript(round0)
    end
    if round4 > 0 --round 4
    then
        round4_script = lua_table.GO:GetScript(round0)
    end
    if round5 > 0 --round 5
    then
        round5_script = lua_table.GO:GetScript(round0)
    end
    if round6 > 0 --round 6
    then
        round6_script = lua_table.GO:GetScript(round0)
    end
    if round7 > 0 --round 7
    then
        round7_script = lua_table.GO:GetScript(round0)
    end
    if round8 > 0 --round 8
    then
        round8_script = lua_table.GO:GetScript(round0)
    end
    if round9 > 0 --round 9
    then
        round9_script = lua_table.GO:GetScript(round0)
    end
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end