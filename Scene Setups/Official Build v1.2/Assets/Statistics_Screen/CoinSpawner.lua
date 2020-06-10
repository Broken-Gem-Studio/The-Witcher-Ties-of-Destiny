function GetTableCoinSpawner()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.TransformFunctions =  Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.UIFunctions = Scripting.Interface()
lua_table.AnimationFunctions = Scripting.Animations()

--LEGACY
-- local randTime = 0
-- local Spawner1Pos = 0
-- local currentTimeToSpawn = 0
-- local SpawnerList = {}
-- local Phases = { Potions = 1, Kills = 2 , Helps = 3 }
-- local CurrentPhase = 0
-- local phasetochange = false

--Good Scores
geralt_score = {
    5873,--damage_dealt  --Exception, this numbers value_per_instance ratio is 1, since this will collect the real value already
	43, --minion_kills
	11,  --special_kills
    32, --incapacitations
    23,  --objects destroyed         
	0,  --chests opened
	8,  --potions_shared
	12   --ally_revived
}

--Bad Scores
jaskier_score = {
	2571, --damage_dealt  --Exception, this numbers value_per_instance ratio is 1, since this will collect the real value already
	17,  --minion_kills
	11,   --special_kills
    8,   --incapacitations
    3,  --objects destroyed
	6,   --chests opened
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

local geralt_GO_data = {
    GO_UID = 0,
    anim_started_at = -300,
    clapping = false,
    win_string = "Geralt is on fire!",
    final_win_string = "Geralt Wins!",
    win_UI = 0,
    final_win_UI = 0
}
local jaskier_GO_data = {
    GO_UID = 0,
    anim_started_at = -150,
    clapping = false,
    win_string = "Jaskier rocks!",
    final_win_string = "Jaskier Wins!",
    win_UI = 0,
    final_win_UI = 0
}
local animation_duration = 1700

local geralt_spawn_positions = {}
local jaskier_spawn_positions = {}

local phase_UI_titles = {}
local geralt_UI_titles = {}
local jaskier_UI_titles = {}
local match_result_UI_titles = {}

local game_time = 0
local timestamp = 0

local cycle_stages = {
	ready = { stage = 1, duration = 500 },
	showing_title = { stage = 2, duration = 500 },
    spawning_coins = { stage = 3, duration = 0, duration_min = 50, duration_max = 150 },	--duration = time_between coin spawns
    showing_score = { stage = 4, duration = 1500 },
    showing_winner = { stage = 5, duration = 1500 },
    final_winner = { stage = 0, duration = 4000 }
}
local current_stage = cycle_stages.ready.stage
local current_phase = 1
local total_phases = 8
local character_winner = nil

lua_table.coins_finished = 0

local phase_title = ""
local geralt_results = { coins = 0, result_score = 0, result_title = "", }
local jaskier_results = { coins = 0, result_score = 0, result_title = "", }

--FUNCTIONS
local function InstantiateCoin(spawn_position, prefab_UID)
    return lua_table.SceneFunctions:Instantiate(prefab_UID, spawn_position[1] + lua_table.SystemFunctions:RandomNumberInRange(-0.015, 0.015), spawn_position[2], spawn_position[3] + lua_table.SystemFunctions:RandomNumberInRange(-0.015, 0.015), -90, 0.0, lua_table.SystemFunctions:RandomNumberInRange(0, 360))
end

local function CalculateCoinsToThrow(character_score, current_phase)
    return character_score[current_phase] * scoreboard_data[current_phase].coin_ratio
end

local function CalculateCharacterResults(character_results, character_score, current_phase)
    character_results.result_title = scoreboard_data[current_phase].title_start .. character_score[current_phase] .. scoreboard_data[current_phase].title_end
    character_results.result_score = scoreboard_data[current_phase].score_value * character_score[current_phase]
end

local function CalculatePhaseData(current_phase)
    phase_title =  scoreboard_data[current_phase].title_phase
    CalculateCharacterResults(geralt_results, geralt_score, current_phase)
    CalculateCharacterResults(jaskier_results, jaskier_score, current_phase)

    geralt_results.coins = math.floor(CalculateCoinsToThrow(geralt_score, current_phase))
    jaskier_results.coins = math.floor(CalculateCoinsToThrow(jaskier_score, current_phase))

    if geralt_results.coins == 0 then lua_table.coins_finished = lua_table.coins_finished + 1 end
    if jaskier_results.coins == 0 then lua_table.coins_finished = lua_table.coins_finished + 1 end
end

local function WinnerClap(character_data)
    lua_table.AnimationFunctions:PlayAnimation("clap", 30.0, character_data.GO_UID)
    character_data.anim_started_at = game_time
    character_data.clapping = true
end

local function DecideWinner(character_data)
    local geralt_final_score = 0
    local jaskier_final_score = 0
    
    for i = 1, total_phases, 1 do
        geralt_final_score = scoreboard_data[i].score_value * geralt_score[i]
        jaskier_final_score = scoreboard_data[i].score_value * jaskier_score[i]

        geralt_score[i] = 0
        jaskier_score[i] = 0
    end

    if character_data = nil then
        WinnerClap(character_data)
        lua_table.UIFunctions:MakeElementVisible("Image", character_data.final_win_UI)
        lua_table.SystemFunctions:LOG(character_data.final_win_string)
    else
        WinnerClap(geralt_GO_data)
        WinnerClap(jaskier_GO_data)
        --lua_table.UIFunctions:MakeElementVisible("Image", character_data.final_win_UI)    --TODO: Show it's a final tie UI
        lua_table.SystemFunctions:LOG("Amazing! It's a tie!")
    end
        
    end
end

local function ShowPhaseTitle(current_phase)
    lua_table.UIFunctions:MakeElementVisible("Image", phase_UI_titles[current_phase])
    lua_table.SystemFunctions:LOG("" .. phase_UI_titles[current_phase])
end

local function HidePhaseTitle(current_phase) 
    lua_table.UIFunctions:MakeElementInvisible("Image", phase_UI_titles[current_phase])
end

local function ShowCharacterScores(current_phase)
    lua_table.UIFunctions:MakeElementVisible("Image", geralt_UI_titles[current_phase])
    lua_table.UIFunctions:MakeElementVisible("Image", jaskier_UI_titles[current_phase])

    lua_table.SystemFunctions:LOG("Geralt: " .. geralt_results.result_title .. " SCORE: " .. geralt_results.result_score)
    lua_table.SystemFunctions:LOG("Jaskier: " .. jaskier_results.result_title .. " SCORE: " .. jaskier_results.result_score)
end

local function HideCharacterScores(current_phase)
    lua_table.UIFunctions:MakeElementInvisible("Image", geralt_UI_titles[current_phase])
    lua_table.UIFunctions:MakeElementInvisible("Image", jaskier_UI_titles[current_phase])
end

local function ShowPhaseWinner(character_data)
    if character_data == nil then
        --TODO: Show it's a tie UI
        lua_table.SystemFunctions:LOG("It's a tie!")
    else
        lua_table.AnimationFunctions:SetBlendTime(0.5, character_data.GO_UID)
        lua_table.AnimationFunctions:PlayAnimation("quick_clap", 30.0, character_data.GO_UID)
        character_data.anim_started_at = game_time
        character_data.clapping = true

        lua_table.UIFunctions:MakeElementVisible("Image", character_data.win_UI)
        lua_table.SystemFunctions:LOG(character_data.win_string)
    end
end

local function HidePhaseWinner(character_data)
    if character_data ~= nil then
        lua_table.UIFunctions:MakeElementInvisible("Image", character_data.win_UI)
    end
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

local function CharacterIdleAnim(character_data)
    if not character_data.clapping then
        if game_time - character_data.anim_started_at > animation_duration then
            lua_table.AnimationFunctions:PlayAnimation("idle_forward", 2.0, character_data.GO_UID)
            character_data.anim_started_at = game_time
        end
    elseif game_time - character_data.anim_started_at > 1000 and lua_table.AnimationFunctions:CurrentAnimationEnded(character_data.GO_UID) == 1 then
        lua_table.AnimationFunctions:SetBlendTime(0.4, character_data.GO_UID)
        character_data.clapping = false
    end
end

function lua_table:Awake()
    geralt_GO_data.GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt_Score")
    jaskier_GO_data.GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Score")

    for i = 1, total_phases, 1 do
        geralt_spawn_positions[i] = lua_table.TransformFunctions:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_" .. i))
        jaskier_spawn_positions[i] = lua_table.TransformFunctions:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_" .. i))
        phase_UI_titles[i] = lua_table.GameObjectFunctions:FindGameObject("Phase_Title_" .. i)
        geralt_UI_titles[i] = lua_table.GameObjectFunctions:FindGameObject("Geralt_Title_" .. i)
        jaskier_UI_titles[i] = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Title_" .. i)
    end

    -- match_result_UI_titles = {
    --     lua_table.GameObjectFunctions:FindGameObject("Title_Tie"),
    --     lua_table.GameObjectFunctions:FindGameObject("Final_Title_Tie")
    -- }

    geralt_GO_data.win_UI = lua_table.GameObjectFunctions:FindGameObject("Geralt_Title_Round")
    jaskier_GO_data.win_UI = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Title_Round")

    geralt_GO_data.final_win_UI = lua_table.GameObjectFunctions:FindGameObject("Geralt_Title_Wins")
    jaskier_GO_data.final_win_UI = lua_table.GameObjectFunctions:FindGameObject("Jaskier_Title_Wins")
end

function lua_table:Start()
    lua_table.UIFunctions:MakeElementInvisible("Image", geralt_GO_data.win_UI)
    lua_table.UIFunctions:MakeElementInvisible("Image", geralt_GO_data.final_win_UI)
    lua_table.UIFunctions:MakeElementInvisible("Image", jaskier_GO_data.win_UI)
    lua_table.UIFunctions:MakeElementInvisible("Image", jaskier_GO_data.final_win_UI)

    for i = 1, total_phases, 1 do
        lua_table.UIFunctions:MakeElementInvisible("Image", phase_UI_titles[i])
        lua_table.UIFunctions:MakeElementInvisible("Image", geralt_UI_titles[i])
        lua_table.UIFunctions:MakeElementInvisible("Image", jaskier_UI_titles[i])
    end

    -- for i = 1, 3, 1 do
    --     lua_table.UIFunctions:MakeElementInvisible("Image", match_result_UI_titles[i])
    -- end
end

function lua_table:Update()
    game_time = lua_table.SystemFunctions:GameTime() * 1000

    CharacterIdleAnim(geralt_GO_data)
    CharacterIdleAnim(jaskier_GO_data)

    if current_phase <= total_phases then
        if current_stage == cycle_stages.ready.stage and game_time - timestamp > cycle_stages.ready.duration
        then
            CalculatePhaseData(current_phase)	--Both Characters, calculate data such as score of each and coins to throw
            ShowPhaseTitle(current_phase)
            timestamp = game_time
            current_stage = cycle_stages.showing_title.stage

        elseif current_stage == cycle_stages.showing_title.stage and game_time - timestamp > cycle_stages.showing_title.duration
        then
            timestamp = game_time
            current_stage = cycle_stages.spawning_coins.stage
            cycle_stages.spawning_coins.duration = lua_table.SystemFunctions:RandomNumberInRange(cycle_stages.spawning_coins.duration_min, cycle_stages.spawning_coins.duration_max)
        elseif current_stage == cycle_stages.spawning_coins.stage and game_time - timestamp > cycle_stages.spawning_coins.duration
        then
            if SpawnCoins(current_phase)	-- Function returns true if any of the two has the counter > 0 after spawning coin
            then
                cycle_stages.spawning_coins.duration = lua_table.SystemFunctions:RandomNumberInRange(cycle_stages.spawning_coins.duration_min, cycle_stages.spawning_coins.duration_max)
                timestamp = game_time
            elseif lua_table.coins_finished == 2 or game_time - timestamp > 3000	--3000 = time failsave
            then
                ShowCharacterScores(current_phase)
                lua_table.coins_finished = 0
                timestamp = game_time
                current_stage = cycle_stages.showing_winner.stage
            end

        elseif current_stage == cycle_stages.showing_winner.stage and game_time - timestamp > cycle_stages.showing_winner.duration
        then
            if geralt_results.result_score > jaskier_results.result_score then character_winner = geralt_GO_data
            elseif geralt_results.result_score < jaskier_results.result_score then character_winner = jaskier_GO_data
            else character_winner = nil end

            ShowPhaseWinner(character_winner)

            timestamp = game_time
            current_stage = cycle_stages.showing_score.stage

        elseif current_stage == cycle_stages.showing_score.stage and game_time - timestamp > cycle_stages.showing_score.duration
        then
            HideCharacterScores(current_phase)
            HidePhaseTitle(current_phase)
            HidePhaseWinner(character_winner)
            timestamp = game_time
            current_phase = current_phase + 1
            current_stage = cycle_stages.ready.stage
            lua_table.SystemFunctions:LOG(" --- ROUND FINISHED --- ")
        end
    elseif game_time - timestamp > cycle_stages.final_winner.duration and current_phase == (total_phases + 1)
    then
        DecideWinner(character_winner)
        current_phase = current_phase + 1
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
    --         randTime =  lua_table.SystemFunctions:RandomNumberInRange(lua_table.MinTimeBetweenCoins,lua_table.MaxTimeBetweenCoins)   
    --         currentTimeToSpawn = 0

    --         end
    --     end
    -- end

end

return lua_table
end