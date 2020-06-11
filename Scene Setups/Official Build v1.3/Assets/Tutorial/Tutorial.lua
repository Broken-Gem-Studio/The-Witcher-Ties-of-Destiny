function GetTableTutorial()

local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.PhysicsFunctions = Scripting.Physics()

------------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------------
-- Pause
local buttonManagerGO = 0
local buttonManagerScript = 0
lua_table.tutorialPause = false

local geralt_mesh_GO_UID = 0
local geralt_pivot_GO_UID = 0
local jaskier_mesh_GO_UID = 0
local jaskier_pivot_GO_UID = 0

local checkPlayersHealth = false
local geraltDead = false
local jaskierDead = false

local CARTAS = 0
local TABLE_CARTAS = 0

local KeyState = {
    IDLE = "IDLE",
    DOWN = "DOWN",
    REPEAT = "REPEAT",
    UP = "UP"
}

local Step = {
    NONE = 0,
    STEP_1 = 1,
    STEP_2 = 2,
    STEP_3 = 3,
    STEP_4 = 4,
    STEP_5 = 5,
    STEP_6 = 6,
    STEP_7 = 7,
    STEP_8 = 8,
    STEP_9 = 9,
    STEP_10 = 10,
    STEP_11 = 11,
    STEP_12 = 12,
    STEP_13 = 13
}

lua_table.currentStep = Step.STEP_1

lua_table.MyUUID = 0
lua_table.GeraltNumber = 1
lua_table.JaskierNumber = 2
local tableGeralt, tableJaskier

------------------------------------------------------------------------------
-- SPAWNERS
------------------------------------------------------------------------------
local spawnerStep4, spawnerStep6_1, spawnerStep6_2, spawnerStep7, spawnerStep9, spawnerStep10_1, spawnerStep10_2, spawnerStep10_3, spawnerArcher1, spawnerArcher2, spawnerArcher3
local spawnerStep11_1, spawnerStep11_2, spawnerStep12_1, spawnerStep12_2, spawnerStep12_3

local scriptSpawnerStep4, scriptSpawnerStep6_1, scriptSpawnerStep6_2, scriptSpawnerStep7, scriptSpawnerStep9, scriptSpawnerStep10_1, scriptSpawnerStep10_2, scriptSpawnerStep10_3
local scriptSpawnerArcher1, scriptSpawnerArcher2, scriptSpawnerArcher3, scriptSpawnerStep11_1, scriptSpawnerStep11_2, scriptSpawnerStep12_1, scriptSpawnerStep12_2, scriptSpawnerStep12_3 

local checkStep4 = false
local checkStep6_1 = false
local checkStep6_2 = false
local checkStep7 = false
local checkStep9 = false
local checkStep10_1 = false
local checkStep10_2 = false
local checkStep10_3 = false
local checkStep11_1 = false
local checkStep11_2 = false
local checkStep12_1 = false
local checkStep12_2 = false
local checkStep12_3 = false

-- Variables STEP 1
local geraltHasMoved = false
local jaskierHasMoved = false
lua_table.StartStep2 = false

-- Variables STEP 2
local showedAttacks = false
local geraltAttackY = false
local geraltAttackB = false
local geraltAttackHeavy = false
local jaskierAttackY = false
local jaskierAttackB = false
local jaskierAttackHeavy = false

lua_table.MoveEnemies = false

-- Variables STEP 6
local geraltRoll = false
local jaskierRoll = false
local geraltStart6 = false
local jaskierStart6 = false
lua_table.PauseStep6 = false

-- Variables STEP 7
lua_table.MoveEnemies7 = false

-- Variables STEP 9
local moveStep9 = false
local activateEnemiesStep10 = false
local geraltStart9 = false
local jaskierStart9 = false
lua_table.PauseStep9 = false

-- Variables STEP 10
lua_table.moveStep10 = false
lua_table.PauseStep10 = false
local geraltStart10 = false
local jaskierStart10 = false

-- Variables STEP 11
local moveStep11 = false
local geraltStart11 = false
local jaskierStart11 = false
lua_table.PauseStep11 = false

-- Variables STEP 12
local moveStep12 = false
local jaskierUlt = false
local geraltUlt = false
local geraltStart12 = false
local jaskierStart12 = false
local geraltSpell = false
local jaskierSpell = false
lua_table.PauseStep12 = false

-- Variables STEP 13
lua_table.SaveGame13 = false
local hasSaved = false

-- Vasriables STEP
local step8

-- Variables DOORS
local doorsGO = {
    door1,
    door2,
    door5
}

local doorsColliders = {
    door1,
    door2,
    door5
}

-- Variables POTIONS
lua_table.potionsCards = false
local showedPotions = false
local potionDropped = false

-- Variables REVIVE
lua_table.reviveCard = false
local showedRevive = false

-- Variables CHEST
lua_table.chestCard = false
local showedChest = false
local lastTime = 0
local chestTime = 4
local startTimer = false

-- Variables CARDS
local littleCards = {
    chest,
    dummy,
    enemy,
    move,
    lumberjack,
    ultimate,
    abilities,
    bonfire
}


local function RevivePlayers()
    if tableGeralt.current_state == -4
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, geralt_mesh_GO_UID)
        lua_table.ObjectFunctions:SetActiveGameObject(true, geralt_pivot_GO_UID)
        lua_table.PhysicsFunctions:SetActiveController(true, lua_table.Geralt_UUID)
        tableGeralt:Start()

        if lua_table.Jaskier_UUID  ~= nil and lua_table.Jaskier_UUID ~= 0
        then
            local jaskier_pos = lua_table.TransformFunctions:GetPosition(lua_table.Jaskier_UUID)
            lua_table.PhysicsFunctions:SetCharacterPosition(jaskier_pos[1], jaskier_pos[2] + 5.0, jaskier_pos[3], lua_table.Geralt_UUID)
        end
    elseif tableGeralt.current_state == -3
    then
        tableGeralt.being_revived = true
    end

    if tableJaskier.current_state == -4
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, jaskier_mesh_GO_UID)
        lua_table.ObjectFunctions:SetActiveGameObject(true, jaskier_pivot_GO_UID)
        lua_table.PhysicsFunctions:SetActiveController(true, lua_table.Jaskier_UUID)
        tableJaskier:Start()

        if lua_table.Geralt_UUID  ~= nil and lua_table.Geralt_UUID ~= 0
        then
            local geralt_pos = lua_table.TransformFunctions:GetPosition(lua_table.Geralt_UUID)
            lua_table.PhysicsFunctions:SetCharacterPosition(geralt_pos[1], geralt_pos[2] + 5.0, geralt_pos[3], lua_table.Jaskier_UUID)
        end
    elseif tableJaskier.current_state == -3
    then
        tableJaskier.being_revived = true
    end
end

------------------------------------------------------------------------------
-- STEPS
------------------------------------------------------------------------------

local function Step1()
    lua_table.InterfaceFunctions:MakeElementVisible("Image", littleCards.move)

    if lua_table.InputFunctions:GetAxisValue(lua_table.GeraltNumber, "AXIS_LEFT" .. "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(lua_table.GeraltNumber, "AXIS_LEFT" .. "Y", 0.01) > 0
    then
        geraltHasMoved = true
    end

    if lua_table.InputFunctions:GetAxisValue(lua_table.JaskierNumber, "AXIS_LEFT" .. "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(lua_table.JaskierNumber, "AXIS_LEFT" .. "Y", 0.01) > 0
    then
        jaskierHasMoved = true
    end
    
    if geraltHasMoved == true and jaskierHasMoved == true and lua_table.StartStep2 == true
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.move)
        lua_table.currentStep = Step.STEP_2
    end
end

local function Step2()
    if showedAttacks == false
    then
        lua_table.SystemFunctions:PauseGame()  
        lua_table.tutorialPause = true
        buttonManagerScript.gamePaused = true   
    end

    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        showedAttacks = true
        lua_table.SystemFunctions:ResumeGame()
        buttonManagerScript.gamePaused = false
        lua_table.tutorialPause = false
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
        lua_table.InterfaceFunctions:MakeElementVisible("Image", littleCards.dummy)
    end

    if tableGeralt.current_state == 8 or tableGeralt.current_state == 9 or tableGeralt.current_state == 10 
    then
        geraltAttackY = true
    end

    if tableJaskier.current_state == 8 or tableJaskier.current_state == 9 or tableJaskier.current_state == 10 
    then
        geraltAttackB = true
    end

    if tableGeralt.current_state == 11 or tableGeralt.current_state == 12 or tableGeralt.current_state == 13 
    then
        jaskierAttackY = true
    end

    if tableJaskier.current_state == 11 or tableJaskier.current_state == 12 or tableJaskier.current_state == 13 
    then
        jaskierAttackB = true
    end

    if tableGeralt.current_state == 14 or tableGeralt.current_state == 15 or tableGeralt.current_state == 16 
    then
        geraltAttackHeavy = true
    end

    if tableJaskier.current_state == 14 or tableJaskier.current_state == 15 or tableJaskier.current_state == 16 
    then
        jaskierAttackHeavy = true
    end

    if geraltAttackY == true and geraltAttackB == true and jaskierAttackY == true and jaskierAttackB == true and geraltAttackHeavy == true and jaskierAttackHeavy == true
    then
        lua_table.AnimationFunctions:PlayAnimation("open", 30, doorsGO.door1)
        lua_table.ObjectFunctions:SetActiveGameObject(false, doorsColliders.door1)

        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.dummy)

        lua_table.currentStep = Step.STEP_3
    end
end

local function Step3()
    lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep4)
    lua_table.currentStep = Step.STEP_4
end

local function Step4()
    scriptSpawnerStep4.CheckEnemies()
    if scriptSpawnerStep4.auxCounter == 4
    then
        checkStep4 = true
    end
    
    if scriptSpawnerStep4.auxCounter == 0 and checkStep4 == true
    then
        lua_table.AnimationFunctions:PlayAnimation("open", 30, doorsGO.door2)
        lua_table.ObjectFunctions:SetActiveGameObject(false, doorsColliders.door2)
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.enemy)

        lua_table.currentStep = Step.STEP_6
    end
end

local function Step5()

    lua_table.currentStep = Step.STEP_7

end

local function Step6()

    if checkPlayersHealth == false
    then
        RevivePlayers()
        checkPlayersHealth = true
    end

    if lua_table.PauseStep6 == true
    then
        lua_table.SystemFunctions:PauseGame()     
        lua_table.tutorialPause = true
        buttonManagerScript.gamePaused = true
    end

    
    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        lua_table.SystemFunctions:ResumeGame()
        buttonManagerScript.gamePaused = false
        lua_table.tutorialPause = false
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep6_1)
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep6_2)
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
        lua_table.PauseStep6 = false
    end

    if tableGeralt.current_state == 3 or tableGeralt.current_state == -4
    then
        geraltRoll = true
    end

    if tableJaskier.current_state == 3 or tableJaskier.current_state == -4
    then
        jaskierRoll = true
    end
    
    scriptSpawnerStep6_1.CheckEnemies()
    scriptSpawnerStep6_2.CheckEnemies()

    if scriptSpawnerStep6_1.auxCounter == 2
    then
        checkStep6_1 = true
    end

    if scriptSpawnerStep6_2.auxCounter == 2
    then
        checkStep6_2 = true
    end

    if geraltRoll == true and jaskierRoll == true and scriptSpawnerStep6_1.auxCounter == 0 and checkStep6_1 == true and scriptSpawnerStep6_2.auxCounter == 0 and checkStep6_2 == true
    then
        checkPlayersHealth = false
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep7)
        lua_table.currentStep = Step.STEP_7
    end
end


local function Step7()
    scriptSpawnerStep7.CheckEnemies()

    if checkPlayersHealth == false
    then
        RevivePlayers()
        checkPlayersHealth = true
    end

    if scriptSpawnerStep7.auxCounter == 8
    then
        checkStep7 = true
    end

    if scriptSpawnerStep7.auxCounter == 0 and checkStep7 == true
    then
        checkPlayersHealth = false
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.enemy)
        lua_table.ObjectFunctions:SetActiveGameObject(true, step8)
        lua_table.currentStep = Step.STEP_8
    end

end

local function Step8()
    lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep9)
    lua_table.currentStep = Step.STEP_9
end

local function Step9()
    if checkPlayersHealth == false
    then
        RevivePlayers()
        checkPlayersHealth = true
    end

    if lua_table.PauseStep9 == true and moveStep9 == false
    then
        lua_table.SystemFunctions:PauseGame()     
        lua_table.tutorialPause = true
        buttonManagerScript.gamePaused = true
    end

    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        lua_table.SystemFunctions:ResumeGame()
        lua_table.tutorialPause = false
        buttonManagerScript.gamePaused = false
        moveStep9 = true
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
        lua_table.PauseStep9 = false
        lua_table.InterfaceFunctions:MakeElementVisible("Image", littleCards.lumberjack)
    end

    scriptSpawnerStep9.CheckEnemies()

    if scriptSpawnerStep9.auxCounter == 1
    then
        checkStep9 = true
    end

    if scriptSpawnerStep9.auxCounter == 0 and checkStep9 == true
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep10_1)
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep10_2)
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep10_3)

        checkPlayersHealth = false
        activateEnemiesStep10 = true
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.lumberjack)
        lua_table.currentStep = Step.STEP_10
    end
end


local function Step10()
    if checkPlayersHealth == false
    then
        RevivePlayers()
        checkPlayersHealth = true
    end

    if lua_table.PauseStep10 == true and lua_table.moveStep10 == false
    then
        lua_table.SystemFunctions:PauseGame() 
        lua_table.tutorialPause = true
        buttonManagerScript.gamePaused = true    
    end

    
    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        lua_table.SystemFunctions:ResumeGame()
        buttonManagerScript.gamePaused = false
        lua_table.tutorialPause = false
        lua_table.moveStep10 = true
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
        lua_table.PauseStep10 = false
    end

    scriptSpawnerStep10_1.CheckEnemies()
    scriptSpawnerStep10_2.CheckEnemies()
    scriptSpawnerStep10_3.CheckEnemies()

    if scriptSpawnerStep10_1.auxCounter == 4 then checkStep10_1 = true end
    if scriptSpawnerStep10_2.auxCounter == 6 then checkStep10_2 = true end
    if scriptSpawnerStep10_3.auxCounter == 1 then checkStep10_3 = true end

    if scriptSpawnerStep10_1.auxCounter == 0 and checkStep10_1 == true and scriptSpawnerStep10_2.auxCounter == 0 
    and checkStep10_2 == true and scriptSpawnerStep10_3.auxCounter == 0 and checkStep10_3 == true
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerArcher1)
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerArcher2)
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerArcher3)
        checkPlayersHealth = false
        lua_table.currentStep = Step.STEP_11
    end
end


local function Step11()
    if checkPlayersHealth == false
    then
        RevivePlayers()
        checkPlayersHealth = true
    end

    if lua_table.PauseStep11 == true and moveStep11 == false
    then
        lua_table.SystemFunctions:PauseGame()
        buttonManagerScript.gamePaused = true
        lua_table.tutorialPause = true
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep11_1)     
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep11_2)     
    end   

    if  TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        lua_table.SystemFunctions:ResumeGame()
        buttonManagerScript.gamePaused = false
        lua_table.tutorialPause = false
        moveStep11 = true
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
        lua_table.PauseStep11 = false
        lua_table.InterfaceFunctions:MakeElementVisible("Image", littleCards.abilities)
        tableGeralt.ability_cooldown = 5000.0
        tableJaskier.ability_cooldown = 1000.0
    end
    
    if tableGeralt.current_state == 4 or tableGeralt.current_state == -4
    then
        geraltSpell = true
    end

    if tableJaskier.current_state == 4 or  tableJaskier.current_state == -4
    then
        jaskierSpell = true
    end 

    scriptSpawnerStep11_1.CheckEnemies()
    scriptSpawnerStep11_2.CheckEnemies()

    if scriptSpawnerStep11_1.auxCounter == 8 then checkStep11_1 = true end
    if scriptSpawnerStep11_2.auxCounter == 1 then checkStep11_2 = true end

    if scriptSpawnerStep11_1.auxCounter == 0 and checkStep11_1 == true and scriptSpawnerStep11_2.auxCounter == 0 and checkStep11_2 == true and geraltSpell == true --and jaskierSpell == true 
    then
        lua_table.ObjectFunctions:SetActiveGameObject(false, doorsColliders.door5)
        lua_table.AnimationFunctions:PlayAnimation("open", 30, doorsGO.door5)

        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep12_1)
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep12_2)
        lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerStep12_3)

        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.abilities)

        checkPlayersHealth = false
        lua_table.currentStep = Step.STEP_12
    end
end


local function Step12()
    if checkPlayersHealth == false
    then
        RevivePlayers()
        checkPlayersHealth = true
    end

    if lua_table.PauseStep12 == true and moveStep12 == false
    then
        lua_table.SystemFunctions:PauseGame()    
        buttonManagerScript.gamePaused = true 
        lua_table.tutorialPause = true
    end

    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        lua_table.SystemFunctions:ResumeGame()
        lua_table.InterfaceFunctions:MakeElementVisible("Image", littleCards.ultimate)
        buttonManagerScript.gamePaused = false
        lua_table.tutorialPause = false
        moveStep12 = true
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
        lua_table.PauseStep12 = false
        tableGeralt.current_ultimate = tableGeralt.max_ultimate
        tableJaskier.current_ultimate = tableJaskier.max_ultimate
    end


    if tableGeralt.current_state == 5 or tableGeralt.current_state == -4
    then
        geraltUlt = true
    end
    
    if tableJaskier.current_state == 5 or tableJaskier.current_state == -4
    then
        jaskierUlt = true
    end

    scriptSpawnerStep12_1.CheckEnemies()
    scriptSpawnerStep12_2.CheckEnemies()    
    scriptSpawnerStep12_3.CheckEnemies()

    if scriptSpawnerStep12_1.auxCounter == 8 then checkStep12_1 = true end
    if scriptSpawnerStep12_2.auxCounter == 4 then checkStep12_2 = true end
    if scriptSpawnerStep12_3.auxCounter == 2 then checkStep12_3 = true end

    if scriptSpawnerStep12_1.auxCounter == 0 and checkStep12_1 == true and scriptSpawnerStep12_2.auxCounter == 0 and checkStep12_2 == true  and scriptSpawnerStep12_3.auxCounter == 0 and checkStep12_3 == true
    and geraltUlt == true and jaskierUlt == true 
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.ultimate)
        checkPlayersHealth = false
        lua_table.currentStep = Step.STEP_13
    end
end


local function Step13()
    lua_table.InterfaceFunctions:MakeElementVisible("Image", littleCards.bonfire)

    if checkPlayersHealth == false
    then
        RevivePlayers()
        checkPlayersHealth = true
    end

    if lua_table.SaveGame13 == true and hasSaved== false
    then
        lua_table.SystemFunctions:PauseGame()    
        buttonManagerScript.gamePaused = true
        lua_table.tutorialPause = true
    end

    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        lua_table.SystemFunctions:ResumeGame()
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.bonfire)
        buttonManagerScript.gamePaused = false
        lua_table.tutorialPause = false
        hasSaved = true
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
        lua_table.SaveGame13 = false
    end
    
    if hasSaved == true
    then
        checkPlayersHealth = false
        lua_table.currentStep = Step.NONE
    end
end

local function ReviveCard()   
    if showedRevive == false
    then
        lua_table.SystemFunctions:PauseGame() 
        lua_table.tutorialPause = true  
        buttonManagerScript.gamePaused = true
    end

    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        showedRevive = true
        lua_table.reviveCard = false
        lua_table.SystemFunctions:ResumeGame()
        lua_table.tutorialPause = false  
        buttonManagerScript.gamePaused = false
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
    end
end

local function ChestCard()   
    if startTimer == false
    then
        lastTime = lua_table.SystemFunctions:GameTime()
        lua_table.InterfaceFunctions:MakeElementVisible("Image", littleCards.chest)
        startTimer = true
    end

    if lua_table.SystemFunctions:GameTime() > lastTime + chestTime
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.chest)
        showedChest = true
        lua_table.chestCard = false
    end
end

local function PotionsCards()   
    if showedPotions == false
    then
        lua_table.SystemFunctions:PauseGame()    
        lua_table.tutorialPause = true  
        buttonManagerScript.gamePaused = true
    end

    if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
    then
        showedPotions = true
        lua_table.potionsCards = false
        lua_table.SystemFunctions:ResumeGame()
        lua_table.tutorialPause = false
        buttonManagerScript.gamePaused = false
        TABLE_CARTAS.continue_meter1_full = false
        TABLE_CARTAS.continue_meter2_full = false
    end
end

local function FindPotions()

    local redPotion = lua_table.ObjectFunctions:FindGameObject("Drop_Particle_Red")
    local yellowPotion = lua_table.ObjectFunctions:FindGameObject("Drop_Particle_Yellow")
    local purplePotion = lua_table.ObjectFunctions:FindGameObject("Drop_Particle_Purple")

    if redPotion ~= 0 or yellowPotion ~= 0 or purplePotion ~= 0
    then
        potionDropped = true
    end
end


function lua_table:Awake()

    spawnerStep4 = lua_table.ObjectFunctions:FindGameObject("spawnerStep4")
    spawnerStep6_1 = lua_table.ObjectFunctions:FindGameObject("spawnerStep6_1")
    spawnerStep6_2 = lua_table.ObjectFunctions:FindGameObject("spawnerStep6_2")
    spawnerStep7 = lua_table.ObjectFunctions:FindGameObject("spawnerStep7")
    spawnerStep9 = lua_table.ObjectFunctions:FindGameObject("spawnerStep9")
    spawnerStep10_1 = lua_table.ObjectFunctions:FindGameObject("spawnerStep10_1")
    spawnerStep10_2 = lua_table.ObjectFunctions:FindGameObject("spawnerStep10_2")
    spawnerStep10_3 = lua_table.ObjectFunctions:FindGameObject("spawnerStep10_3")
    spawnerStep11_1 = lua_table.ObjectFunctions:FindGameObject("spawnerStep11_1")
    spawnerStep11_2 = lua_table.ObjectFunctions:FindGameObject("spawnerStep11_2")
    spawnerArcher1 = lua_table.ObjectFunctions:FindGameObject("spawnerArcher1")
    spawnerArcher2 = lua_table.ObjectFunctions:FindGameObject("spawnerArcher2")
    spawnerArcher3 = lua_table.ObjectFunctions:FindGameObject("spawnerArcher3")
    spawnerStep12_1 = lua_table.ObjectFunctions:FindGameObject("spawnerStep12_1")
    spawnerStep12_2 = lua_table.ObjectFunctions:FindGameObject("spawnerStep12_2")
    spawnerStep12_3 = lua_table.ObjectFunctions:FindGameObject("spawnerStep12_3")

    scriptSpawnerStep4 = lua_table.ObjectFunctions:GetScript(spawnerStep4)
    scriptSpawnerStep6_1 = lua_table.ObjectFunctions:GetScript(spawnerStep6_1) 
    scriptSpawnerStep6_2 = lua_table.ObjectFunctions:GetScript(spawnerStep6_2)
    scriptSpawnerStep7 = lua_table.ObjectFunctions:GetScript(spawnerStep7)
    scriptSpawnerStep9 = lua_table.ObjectFunctions:GetScript(spawnerStep9)
    scriptSpawnerStep10_1 = lua_table.ObjectFunctions:GetScript(spawnerStep10_1)
    scriptSpawnerStep10_2 = lua_table.ObjectFunctions:GetScript(spawnerStep10_2)
    scriptSpawnerStep10_3 = lua_table.ObjectFunctions:GetScript(spawnerStep10_3)
    scriptSpawnerStep11_1 = lua_table.ObjectFunctions:GetScript(spawnerStep11_1)
    scriptSpawnerStep11_2 = lua_table.ObjectFunctions:GetScript(spawnerStep11_2)
    scriptSpawnerArcher1 = lua_table.ObjectFunctions:GetScript(spawnerArcher1)
    scriptSpawnerArcher2 = lua_table.ObjectFunctions:GetScript(spawnerArcher2)
    scriptSpawnerArcher3 = lua_table.ObjectFunctions:GetScript(spawnerArcher3)
    scriptSpawnerStep12_1 = lua_table.ObjectFunctions:GetScript(spawnerStep12_1)
    scriptSpawnerStep12_2 = lua_table.ObjectFunctions:GetScript(spawnerStep12_2)
    scriptSpawnerStep12_3 = lua_table.ObjectFunctions:GetScript(spawnerStep12_3)

    geralt_mesh_GO_UID = lua_table.ObjectFunctions:FindGameObject("Geralt_Mesh")
    geralt_pivot_GO_UID = lua_table.ObjectFunctions:FindGameObject("Geralt_Pivot")
    jaskier_mesh_GO_UID = lua_table.ObjectFunctions:FindGameObject("Jaskier_Mesh")
    jaskier_pivot_GO_UID = lua_table.ObjectFunctions:FindGameObject("Jaskier_Pivot")
    
    CARTAS = lua_table.ObjectFunctions:FindGameObject("CARTAS")
    TABLE_CARTAS = lua_table.ObjectFunctions:GetScript(CARTAS)

    step8 = lua_table.ObjectFunctions:FindGameObject("STEP 8")

    lua_table.MyUUID = lua_table.ObjectFunctions:GetMyUID()
    
    lua_table.Geralt_UUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    lua_table.Jaskier_UUID = lua_table.ObjectFunctions:FindGameObject("Jaskier") 

    tableGeralt = lua_table.ObjectFunctions:GetScript(lua_table.Geralt_UUID)
    tableJaskier = lua_table.ObjectFunctions:GetScript(lua_table.Jaskier_UUID)

    buttonManagerGO = lua_table.ObjectFunctions:FindGameObject("ButtonManager")
    if buttonManagerGO ~= 0 
    then
        buttonManagerScript = lua_table.ObjectFunctions:GetScript(buttonManagerGO)
    end

    doorsGO.door1 = lua_table.ObjectFunctions:FindGameObject("Door_1")
    doorsGO.door2 = lua_table.ObjectFunctions:FindGameObject("Door_2")
    doorsGO.door5 = lua_table.ObjectFunctions:FindGameObject("Door_5")
    doorsColliders.door1 = lua_table.ObjectFunctions:FindGameObject("colliderDoor1")
    doorsColliders.door2 = lua_table.ObjectFunctions:FindGameObject("colliderDoor2")
    doorsColliders.door5 = lua_table.ObjectFunctions:FindGameObject("colliderDoor5")

    littleCards.chest = lua_table.ObjectFunctions:FindGameObject("L_CHEST")
    littleCards.dummy = lua_table.ObjectFunctions:FindGameObject("L_DUMMY")
    littleCards.enemy = lua_table.ObjectFunctions:FindGameObject("L_ENEMY")
    littleCards.move = lua_table.ObjectFunctions:FindGameObject("L_MOVE")
    littleCards.lumberjack = lua_table.ObjectFunctions:FindGameObject("L_LUMBERJACK")
    littleCards.ultimate = lua_table.ObjectFunctions:FindGameObject("L_ULTIMATE")
    littleCards.abilities = lua_table.ObjectFunctions:FindGameObject("L_ABILITIES")
    littleCards.bonfire = lua_table.ObjectFunctions:FindGameObject("L_BONFIRE")
end

function lua_table:Start()
    lua_table.ObjectFunctions:SetActiveGameObject(false, step8)

    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep4)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep6_1)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep6_2)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep7)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep9)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep10_1)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep10_2)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep10_3)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep11_1)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep11_2)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerArcher1)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerArcher2)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerArcher3)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep12_1)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep12_2)
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerStep12_3)

    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.chest)
    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.dummy)
    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.enemy)
    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.move)
    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.lumberjack)
    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.ultimate)
    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.abilities)
    lua_table.InterfaceFunctions:MakeElementInvisible("Image", littleCards.bonfire)

    checkPlayersHealth = false
end

function lua_table:Update()
    if showedPotions == false
    then
        FindPotions()
        if potionDropped == true --or tableGeralt.current_health <= 100 or tableJaskier.current_health <= 100
        then
            lua_table.potionsCards = true
            PotionsCards()
        end
    end

    if showedRevive == false
    then
        if tableGeralt.current_state == -3 or tableJaskier.current_state == -3
        then
            lua_table.reviveCard = true
            ReviveCard()
        end
    end

    if showedChest == false and lua_table.chestCard == true
    then
        ChestCard()
    end

    if lua_table.currentStep == Step.STEP_1
    then
        Step1()

    elseif lua_table.currentStep == Step.STEP_2
    then
        Step2()
        
    elseif lua_table.currentStep == Step.STEP_3
    then
        Step3()

    elseif lua_table.currentStep == Step.STEP_4 
    then 
        Step4()

    elseif lua_table.currentStep == Step.STEP_5
    then
        Step5()

    elseif lua_table.currentStep == Step.STEP_6
    then
        Step6()

    elseif lua_table.currentStep == Step.STEP_7
    then
        Step7()

    elseif lua_table.currentStep == Step.STEP_8
    then
        Step8()
    
    elseif lua_table.currentStep == Step.STEP_9
    then
        Step9()
    
    elseif lua_table.currentStep == Step.STEP_10
    then
        Step10()
    
    elseif lua_table.currentStep == Step.STEP_11
    then
        Step11()
    
    elseif lua_table.currentStep == Step.STEP_12
    then
        Step12()
    
    elseif lua_table.currentStep == Step.STEP_13
    then
        Step13()
    else
        lua_table.currentStep = Step.NONE
    end
end

return lua_table
end