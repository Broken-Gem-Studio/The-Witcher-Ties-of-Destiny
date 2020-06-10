function GetTableCoinSpawner()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Scene = Scripting.Scenes()
lua_table.TransformFunc =  Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()

--LEGACY
-- local randTime = 0
-- local Spawner1Pos = 0
-- local currentTimeToSpawn = 0
-- local SpawnerList = {}
-- local Phases = { Potions = 1, Kills = 2 , Helps = 3 }
-- local CurrentPhase = 0
-- local phasetochange = false

--TESTING
--Good Scores
geralt_score = {
    5873,--damage_dealt  --Exception, this numbers value_per_instance ratio is 1, since this will collect the real value already
	43, --minion_kills
	14,  --special_kills
    32, --incapacitations
    23,  --objects destroyed         
	6,  --chests opened
	8,  --potions_shared
	12   --ally_revived
}

--Bad Scores
jaskier_score = {
	2571, --damage_dealt  --Exception, this numbers value_per_instance ratio is 1, since this will collect the real value already
	17,  --minion_kills
	6,   --special_kills
    8,   --incapacitations
    3,  --objects destroyed
	0,   --chests opened
	3,  --potions_shared
	0    --ally_revived
}

--SCOREBOARD DATA
local scoreboard_data = {
	{ coin_ratio = 0.003, score_value = 1, title_start = "", title_end = " damage dealed", title_phase = "That's gotta hurt!" },                 --damage_dealt
	{ coin_ratio = 0.3, score_value = 100, title_start = "", title_end = " minions killed", title_phase = "And stay down!" },                   --minion_kills
	{ coin_ratio = 1.0, score_value = 300, title_start = "", title_end = " special enemies killed", title_phase = "The bigger they are..." },   --special_kills
    { coin_ratio = 0.5, score_value = 50, title_start = "", title_end = " enemies incapacitated", title_phase = "Crowd controller!" },            --incapacitations
    { coin_ratio = 0.5, score_value = 20, title_start = "", title_end = " objects destroyed", title_phase = "Collateral damage!" },               --objects_destroyed
    { coin_ratio = 2.0, score_value = 500, title_start = "", title_end = " secret chests found", title_phase = "Jackpot!" },                      --chests opened
	{ coin_ratio = 1.0, score_value = 200, title_start = "Potions shared ", title_end = " times with ally", title_phase = "Sharing is caring!" }, --items_shared
	{ coin_ratio = 1.0, score_value = 300, title_start = "Revived ally ", title_end = " times", title_phase = "No one left behind!" }             --ally_revived
}

--VARS
lua_table.coin_prefab = 0

local game_time = 0
local timestamp = 0

local cycle_stages = {
	ready = { stage = 1, duration = 1000 },
	showing_title = { stage = 2, duration = 1000 },
    spawning_coins = { stage = 3, duration = 0, duration_min = 150, duration_max = 250 },	--duration = time_between coin spawns
	showing_score = { stage = 4, duration = 1000 }
}
local current_stage = cycle_stages.ready.stage
local current_phase = 1
local max_phases = 9

lua_table.coins_finished = 0

local jaskier_spawn_positions = {}
local geralt_spawn_positions = {}

local stage_title = ""
local geralt_results = { coins = 0, result_title = "", score_title = "" }
local jaskier_results = { coins = 0, result_title = "", score_title = "" }

--FUNCTIONS
local function InstantiateCoin(spawn_position, prefab_UID)
    return lua_table.Scene:Instantiate(prefab_UID, spawn_position[1] + lua_table.System:RandomNumberInRange(-0.015, 0.015), spawn_position[2], spawn_position[3] + lua_table.System:RandomNumberInRange(-0.015, 0.015), -90, 0.0, lua_table.System:RandomNumberInRange(0, 360))
end

local function CalculateCoinsToThrow(character_score, current_phase)
    return character_score[current_phase] * scoreboard_data[current_phase].coin_ratio
end

local function BuildScoreStrings(character_results, character_score, current_phase)
    character_results.score_title = scoreboard_data[current_phase].title_start .. character_score[current_phase] .. scoreboard_data[current_phase].title_end
    character_results.result_title = "" .. scoreboard_data[current_phase].score_value * character_score[current_phase]
end

local function CalculatePhaseData(current_phase)
    stage_title =  scoreboard_data[current_phase].title_phase
    BuildScoreStrings(geralt_results, geralt_score, current_phase)
    BuildScoreStrings(jaskier_results, jaskier_score, current_phase)

    geralt_results.coins = math.floor(CalculateCoinsToThrow(geralt_score, current_phase))
    jaskier_results.coins = math.floor(CalculateCoinsToThrow(jaskier_score, current_phase))

    if geralt_results.coins == 0 then lua_table.coins_finished = lua_table.coins_finished + 1 end
    if jaskier_results.coins == 0 then lua_table.coins_finished = lua_table.coins_finished + 1 end
end

local function ShowPhaseTitle()
    lua_table.System:LOG("TITLE: " .. stage_title)
    --TODO-UI: Show current title
end

local function ShowCharacterScores()
    lua_table.System:LOG("Geralt: " .. geralt_results.result_title .. " SCORE: " .. geralt_results.score_title)
    lua_table.System:LOG("Jaskier: " .. jaskier_results.result_title .. " SCORE: " .. jaskier_results.score_title)
    --TODO-UI: Show character score titles
end

local function HideCharacterScores()
    --TODO-UI: Hide character scores titles
end

local function HidePhaseTitle() 
    --TODO-UI: Hide current title
end

local function SpawnCoins(current_phase)
    local ret = false
    local coin_UID = 0

    if geralt_results.coins > 0
    then
        coin_UID = InstantiateCoin(geralt_spawn_positions[current_phase], lua_table.coin_prefab)
        geralt_results.coins = geralt_results.coins - 1
        if geralt_results.coins == 0
        then
            lua_table.GameObjectFunctions:GetScript(coin_UID).final_coin = true
        end
    end

    if jaskier_results.coins > 0
    then
        coin_UID = InstantiateCoin(jaskier_spawn_positions[current_phase], lua_table.coin_prefab)
        jaskier_results.coins = jaskier_results.coins - 1
        if jaskier_results.coins == 0
        then
            lua_table.GameObjectFunctions:GetScript(coin_UID).final_coin = true
        end
    end

    if geralt_results.coins > 0 or jaskier_results.coins > 0 then ret = true end

    return ret
end

function lua_table:Awake()
    geralt_spawn_positions = {
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_damage_dealt")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_minion_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_special_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_incapacitations")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_objects_destroyed")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_chests_found")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_potions_shared")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_ally_revived"))
    }

    jaskier_spawn_positions = {
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_damage_dealt")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_minion_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_special_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_incapacitations")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_objects_destroyed")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_chests_found")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_potions_shared")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_ally_revived"))
    }
end

function lua_table:Start()

end

function lua_table:Update()
    game_time = lua_table.System:GameTime() * 1000

    if current_phase < max_phases then

        if current_stage == cycle_stages.ready.stage and game_time - timestamp > cycle_stages.ready.duration
        then
            CalculatePhaseData(current_phase)	--Both Characters, calculate data such as score of each and coins to throw
            ShowPhaseTitle(current_phase)
            timestamp = game_time
            current_stage = cycle_stages.showing_title.stage

        elseif current_stage == cycle_stages.showing_title.stage and game_time - timestamp > cycle_stages.showing_title.duration
        then
            current_stage = cycle_stages.spawning_coins.stage
            cycle_stages.spawning_coins.duration = lua_table.System:RandomNumberInRange(cycle_stages.spawning_coins.duration_min, cycle_stages.spawning_coins.duration_max)
        elseif current_stage == cycle_stages.spawning_coins.stage and game_time - timestamp > cycle_stages.spawning_coins.duration
        then
            if SpawnCoins(current_phase)	-- Function returns true if any of the two has the counter > 0 after spawning coin
            then
                cycle_stages.spawning_coins.duration = lua_table.System:RandomNumberInRange(cycle_stages.spawning_coins.duration_min, cycle_stages.spawning_coins.duration_max)
                timestamp = game_time
            elseif lua_table.coins_finished == 2 or game_time - timestamp > 3000	--3000 = time failsave
            then
                ShowCharacterScores()
                lua_table.coins_finished = 0
                timestamp = game_time
                current_stage = cycle_stages.showing_score.stage
            end
            
        elseif current_stage == cycle_stages.showing_score.stage and game_time - timestamp > cycle_stages.showing_score.duration
        then
            HideCharacterScores()
            HidePhaseTitle()
            timestamp = game_time
            current_phase = current_phase + 1
            current_stage = cycle_stages.ready.stage
        end
    else
        lua_table.System:LOG("I AM FINISHED")
    end

    ----------------------------------------------SpawnCoins
    -- HOW IT WORKS
        -- SpawnCoins() spawns 1 coin for each character if its counter > 0, then does counter - 1
        -- If after a spawning a coin the counter of that character == 0, mark the spawned coin's bool "coin_script.last_coin" as TRUE, which is FALSE by default
        -- OnCollisionEnter of the coin will check if lua_table.last_coin == TRUE, and if it is it will do <scoreboard_script.coins_finished = scoreboard_script.coins_finished + 1>
        
        -- This process requires script interaction, so that the scoreboard marks the coin as "last_coin" and this coin saves that scoreboard script to later add 1 to "coins_finished"
        -- This can be achieved using the GetScript() engine function
    --------------------------------------------

    -- LEGACY CODE
    -- if lua_table.ThrowCoins
    -- then
    --     currentTimeToSpawn = currentTimeToSpawn + dt
    --     if(currentTimeToSpawn>= randTime)
    --     then
    --         for i,j in pairs(SpawnerList) do
    --         InstantiateCoin(j,lua_table.coin_prefab)
    --         randTime =  lua_table.System:RandomNumberInRange(lua_table.MinTimeBetweenCoins,lua_table.MaxTimeBetweenCoins)   
    --         currentTimeToSpawn = 0

    --         end
    --     end
    -- end

end

return lua_table
end