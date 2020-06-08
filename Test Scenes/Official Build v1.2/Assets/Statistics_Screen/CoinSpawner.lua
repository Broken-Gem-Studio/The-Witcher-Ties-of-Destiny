function GetTableCoinSpawner()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Scene = Scripting.Scenes()
lua_table.TransformFunc =  Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()

lua_table.CoinToSpawn = 0

lua_table.EndGame = false -- Only To Test -- Delete later
lua_table.coins_finished = 0

local randTime = 0
local Spawner1Pos = 0
local currentTimeToSpawn = 0
local SpawnerList = {}
local Phases = { Potions = 1, Kills = 2 , Helps = 3 }
local CurrentPhase = 0
local phasetochange = false

local game_time = 0

local currentTimer = 0
local timetopassphase = 2

local jaskier_spawn_positions = {}
local geralt_spawn_positions = {}

geralt_score = {
	300,  --damage_dealt  --Exception, this numbers value_per_instance ratio is 1, since this will collect the real value already
	20,  --minion_kills
	4,  --special_kills
	10,  --incapacitations
	20,  --objects_destroyed
	5,  --potions_shared
	2   --ally_revived
}

jaskier_score = {
	500,  --damage_dealt  --Exception, this numbers value_per_instance ratio is 1, since this will collect the real value already
	10,  --minion_kills
	5,  --special_kills
	3,  --incapacitations
	60,  --objects_destroyed
	10,  --potions_shared
	0   --ally_revived
}

local cycle_stages = {
	ready = { stage = 1, duration = 1000 },
	showing_title = { stage = 2, duration = 1000 },
    spawning_coins = { stage = 3, duration = 0, duration_min = 150, duration_max = 250 },	--duration = time_between coin spawns
	showing_score = { stage = 4, duration = 1000 }
}

local current_stage = cycle_stages.ready.stage
local timestamp = 0

local GeraltResults = {score =0 , coins = 0 , string = "" }
local JaskierResults = {score = 0, coins = 0, string = ""}

local scoreboard_data = {
	{ coin_ratio = 0.01, score_value = 1, title_start = "", title_end = " damage dealed" },                    --damage_dealt
	{ coin_ratio = 0.5, score_value = 100, title_start = "", title_end = " minions killed" },                 --minion_kills
	{ coin_ratio = 0.5, score_value = 300, title_start = "", title_end = " special enemies killed" },         --special_kills
	{ coin_ratio = 1, score_value = 50, title_start = "", title_end = " enemies incapacitated" },           --incapacitations
	{ coin_ratio = 1, score_value = 20, title_start = "", title_end = " objects destroyed" },               --objects_destroyed
	{ coin_ratio = 1, score_value = 200, title_start = "Potions shared ", title_end = " times with ally" }, --items_shared
	{ coin_ratio = 1, score_value = 300, title_start = "Revived ally ", title_end = " times" }               --ally_revived
}

local uID = 0
local dt = 0

local function InstantiateCoin( Position , uID)

    local randPositionZ = lua_table.System:RandomNumberInRange(-0.02,0.02)
    local randPositionX = lua_table.System:RandomNumberInRange(-0.02,0.02)

    local randRotation = lua_table.System:RandomNumberInRange(0,360)
    return lua_table.Scene:Instantiate(uID, Position[1]+randPositionX,Position[2],Position[3]+randPositionZ,-90,0.0,randRotation)

end

local function CalculateCoinsToThrow ( CharacterScore , phase )
    
    return CharacterScore[phase] * scoreboard_data[phase].coin_ratio

end

local function DefineString ( phase)

    GeraltResults.string = scoreboard_data[phase].title_start .. (scoreboard_data[phase].score_value * geralt_score[phase]) .. scoreboard_data[phase].title_end
    JaskierResults.string = scoreboard_data[phase].title_start .. (scoreboard_data[phase].score_value * jaskier_score[phase]) .. scoreboard_data[phase].title_end

end

local function CalculatePhaseData ( phase )

    DefineString( phase )
    GeraltResults.coins = math.floor(CalculateCoinsToThrow(geralt_score,phase))
    JaskierResults.coins = math.floor(CalculateCoinsToThrow (jaskier_score, phase))

    if GeraltResults.coins == 0
    then
        lua_table.coins_finished= lua_table.coins_finished + 1
    end

    if JaskierResults.coins == 0
    then
        lua_table.coins_finished= lua_table.coins_finished + 1
    end

end

local function ShowPhaseTitle()

end

local function ShowCharacterScores()

end

local function HideCharacterScores()

end

local function HidePhaseTitle() 

end

local function SpawnCoins( phase )

    local ret = false
    local coinUID = 0
    local coin_script = {}
    if geralt_score.coin > 0
    then
        coinUID = InstantiateCoin(geralt_spawn_positions[phase] , lua_table.CoinToSpawn)
        geralt_score.coin = geralt_score.coin - 1
        if geralt_score.coin == 0
        then
            coin_script = lua_table.GameObjectFunctions:GetScript(coinUID)
            coin_script.final_coin = true
        end
    end

    if jaskier_score.coin > 0
    then
        coinUID = InstantiateCoin(jaskier_spawn_positions[phase] , lua_table.CoinToSpawn)
        jaskier_score.coin = jaskier_score.coin - 1
        if jaskier_score.coin == 0
        then
            coin_script = lua_table.GameObjectFunctions:GetScript(coinUID)
            coin_script.final_coin = true
        end
    end

    if geralt_score.coin > 0 or jaskier_score.coin > 0
    then
        ret = true
    end

    return ret

end

function lua_table:Awake()

    jaskier_spawn_positions = {
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_damage_dealt")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_minion_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_special_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_incapacitations")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_objects_destroyed")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_potions_shared")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("jaskier_coins_ally_revived"))
    }

    geralt_spawn_positions = {
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_damage_dealt")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_minion_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_special_kills")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_incapacitations")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_objects_destroyed")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_potions_shared")),
        lua_table.TransformFunc:GetPosition(lua_table.GameObjectFunctions:FindGameObject("geralt_coins_ally_revived"))
    }

    

end

function lua_table:Start()

end

function lua_table:Update()

    dt = lua_table.System:DT()
    game_time = game_time+dt
    --Spawner1Pos = lua_table.TransformFunc:GetPosition(lua_table.PlaceSpawner1uID)
    if lua_table.EndGame == true
    then
        if current_stage == cycle_stages.ready.stage and game_time - timestamp > cycle_stages.ready.duration
        then
            CalculatePhaseData()	--Both Characters, calculate data such as score of each and coins to throw
            ShowPhaseTitle()
            timestamp = game_time
            current_stage = cycle_stages.showing_title.stage
    
        elseif current_stage == cycle_stages.showing_title.stage and game_time - timestamp > cycle_stages.showing_title.duration
        then
            current_stage = cycle_stages.spawning_coins.stage
            cycle_stages.spawning_coins.duration = lua_table.System:RandomNumberInRange(cycle_stages.spawning_coins.duration_min,cycle_stages.spawning_coins.duration_max)
        elseif current_stage == cycle_stages.spawning_coins.stage and game_time - timestamp > cycle_stages.spawning_coins.duration
        then
            -- HOW IT WORKS
            -- SpawnCoins() spawns 1 coin for each character if its counter > 0, then does counter - 1
            -- If after a spawning a coin the counter of that character == 0, mark the spawned coin's bool "coin_script.last_coin" as TRUE, which is FALSE by default
            -- OnCollisionEnter of the coin will check if lua_table.last_coin == TRUE, and if it is it will do <scoreboard_script.coins_finished = scoreboard_script.coins_finished + 1>
            
            -- This process requires script interaction, so that the scoreboard marks the coin as "last_coin" and this coin saves that scoreboard script to later add 1 to "coins_finished"
            -- This can be achieved using the GetScript() engine function
    
            if SpawnCoins()	-- Function returns true if any of the two has the counter > 0 after spawning coin
            then			
                timestamp = game_time
            elseif lua_table.coins_finished == 2 or game_time - timestamp > 3000	--3000 = time failsave
            then
                ShowCharacterScores()
                lua_table.coins_finished = 0
                timestamp = game_time
                current_stage = cycle_stages.showing_score.stage
            end
            
        elseif current_stage == cycle_stages.showing_score and game_time - timestamp > cycle_stages.showing_score.duration
        then
            HideCharacterScores()
            HidePhaseTitle()
            timestamp = game_time
            current_stage = cycle_stages.ready.stage
        end
    end

    -- if lua_table.ThrowCoins
    -- then
    --     currentTimeToSpawn = currentTimeToSpawn + dt
    --     if(currentTimeToSpawn>= randTime)
    --     then
    --         for i,j in pairs(SpawnerList) do
    --         InstantiateCoin(j,lua_table.CoinToSpawn)
    --         randTime =  lua_table.System:RandomNumberInRange(lua_table.MinTimeBetweenCoins,lua_table.MaxTimeBetweenCoins)   
    --         currentTimeToSpawn = 0

    --         end
    --     end
    -- end

end


return lua_table
end