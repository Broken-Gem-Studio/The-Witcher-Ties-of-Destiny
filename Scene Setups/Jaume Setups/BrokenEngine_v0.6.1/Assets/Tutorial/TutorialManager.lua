function GetTableTutorialManager()

local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.SceneFunctions = Scripting.Scenes()

------------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------------

-- Lua table variables
lua_table.enemiesToKill_Step9 = 3
lua_table.enemiesToKill_Step10 = 5
lua_table.threshold = 10
lua_table.lumberjack_UUID = 0

local Step = {
    MOVEMENT = 1,
    DODGE = 2,
    BASIC_ATTACKS = 3,
    BREAKABLE_OBJECTS = 4,
    POTIONS = 5,
    REANIMATE = 6,
    COMBAT = 7,
    SPELLS = 8,
    ULTIMATE = 9,
    KILL_EVERYONE = 10,
    RETURN_TO_SQUARE = 11,
    SURVIVE = 12
}

lua_table.currentStep = Step.POTIONS
lua_table.nextScene = 0

local KeyState = {
    IDLE = "IDLE",
	DOWN = "DOWN",
	REPEAT = "REPEAT",
	UP = "UP"
}

local MyUUID = 0
local GeraltNumber = 1
local JaskierNumber = 2
local textUID = 0
local squarePosition = {0, 0, 0}
local jaskierUlted = false
local geraltUlted = false

local table_barril_1
local table_barril_2
local table_barril_3
local table_barril_4

local barril_1
local barril_2
local barril_3
local barril_4

-- Variebales for STEP 1
local blocked_1_geralt = true
local blocked_1_jaskier = true

-- Variebales for STEP 2
local blocked_2_geralt = true
local blocked_2_jaskier = true

-- Variebales for STEP 3 & 4
local is_geralt_combos = true
local is_jaskier_combos = true
local geralt_combos
local jaskier_combos
local showCombos = false

-- Variables for STEP 5
local geraltDrinkPotion = false
local jaskierDrinkPotion = false
local geraltSwitchPotion = false
local jaskierSwitchPotion = false

-- Variables for STEP 6
local geraltRevive = false
local jaskierRevive = false
local jaskierDown = true
local geraltDown = false
local jaskierHasRevived = false

-- Variables for STEP 7 & 8
local spawnEnemy = false
local geraltSpell = false
local jaskierSpell = false
local hasDied = false
local dead = false
local enemyTable

-- Variables for STEP 9
local spawnEnemies = false

-- Timers
local lastTime_step7 = 0
local step7_message_time = 10

local lastTime_step8 = 0
local step8_message_time = 2

local lastTime_step10 = 0
local step10_message_time = 10

local lastTime_step11 = 0
local step11_message_time = 10

local lastTime_step12 = 0
local step12_message_time = 3

------------------------------------------------------------------------------
-- TOOL FUNCTIONS
------------------------------------------------------------------------------

local function NormalizeVector(vector)
	module = math.sqrt(vector[1] ^ 2 + vector[3] ^ 2)

    local newVector = {0, 0, 0}
    newVector[1] = vector[1] / module
    newVector[2] = vector[2] / module
    newVector[3] = vector[3] / module
    return newVector
end

local function CalculateDistances(position)
    lua_table.GeraltPosition = lua_table.TransformFunctions:GetPosition(lua_table.Geralt_UUID)
    lua_table.JaskierPosition = lua_table.TransformFunctions:GetPosition(lua_table.Jaskier_UUID)

    lua_table.GeraltDistance = math.sqrt((position[1] - lua_table.GeraltPosition[1]) ^ 2 + (position[3] - lua_table.GeraltPosition[3]) ^ 2)
    lua_table.JaskierDistance = math.sqrt((position[1] - lua_table.JaskierPosition[1]) ^ 2 + (position[3] - lua_table.JaskierPosition[3]) ^ 2)
end

------------------------------------------------------------------------------
-- STEPS
------------------------------------------------------------------------------

local function Step1()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Use the left joystick to move the player", textUID)

    if lua_table.InputFunctions:GetAxisValue(GeraltNumber, "AXIS_LEFT" .. "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(GeraltNumber, "AXIS_LEFT" .. "Y", 0.01) > 0
    then
        blocked_1_geralt = false
    end

    if lua_table.InputFunctions:GetAxisValue(JaskierNumber, "AXIS_LEFT" .. "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(JaskierNumber, "AXIS_LEFT" .. "Y", 0.01) > 0
    then
        blocked_1_jaskier = false
    end

    if blocked_1_geralt == false and blocked_1_jaskier == false
    then
        lua_table.SystemFunctions:LOG("TEXT invisible")
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.currentStep = Step.DODGE
    end
end

local function Step2()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Press A to move great distances and dodge attacks. Consumes 1 energy bar (yellow)", textUID)

    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_A", KeyState.DOWN) == true
    then
        blocked_2_geralt = false
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_A", KeyState.DOWN) == true
    then
        blocked_2_jaskier = false
    end

    if blocked_2_geralt == false and blocked_2_jaskier == false
    then
        lua_table.SystemFunctions:LOG("TEXT invisible")
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.currentStep = Step.BASIC_ATTACKS
    end
end

local function Step3()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)

    if showCombos == false
    then
        lua_table.InterfaceFunctions:MakeElementVisible("Image", geralt_combos)
        lua_table.InterfaceFunctions:MakeElementVisible("Image", jaskier_combos)
        showCombos = true
    end

    lua_table.InterfaceFunctions:SetText("Destroy these boxes! Press X (light attack), Y (medium attack) or X + Y (heavy attack)", textUID)

    -- Check Breakable Props
    if table_barril_1.health == 0 and table_barril_2.health == 0 and table_barril_3.health == 0 and table_barril_4.health == 0
    then
        lua_table.SystemFunctions:LOG("TEXT invisible")
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", geralt_combos)
        lua_table.InterfaceFunctions:MakeElementInvisible("Image", jaskier_combos)
        lua_table.currentStep = Step.POTIONS
    end
end

local function Step4()

end

local function Step5()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Press RB to use a potion. Use left and right pad buttons to switch between health potion (red) and energy potion (yellow)", textUID)
    
    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_RIGHTSHOULDER", KeyState.DOWN)   -- BUTTON_RIGHTSHOULDER == R1 ps4 controller
    then
        geraltDrinkPotion = true
        lua_table.SystemFunctions:LOG("BUTTON_RIGHTSHOULDER geralt")
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_RIGHTSHOULDER", KeyState.DOWN)   -- BUTTON_RIGHTSHOULDER == R1 ps4 controller
    then
        jaskierDrinkPotion = true
        lua_table.SystemFunctions:LOG("BUTTON_RIGHTSHOULDER jaskier")
    end

    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_DPAD_LEFT", KeyState.DOWN) 
    or lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_DPAD_RIGHT", KeyState.DOWN)
    then
        geraltSwitchPotion = true
        lua_table.SystemFunctions:LOG("Switch potions geralt")
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_DPAD_LEFT", KeyState.DOWN) 
    or lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_DPAD_RIGHT", KeyState.DOWN)
    then
        jaskierSwitchPotion = true
        lua_table.SystemFunctions:LOG("Switch potions jaskier")
    end

    if geraltDrinkPotion == true and jaskierDrinkPotion == true and geraltSwitchPotion == true and jaskierSwitchPotion == true
    then
        lua_table.SystemFunctions:LOG("TEXT invisible")
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.currentStep = Step.REANIMATE
    end
end

local function Step6()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Hold LB to reanimate your partner if they drop to 0 health", textUID)

    geraltTable = lua_table.ObjectFunctions:GetScript(lua_table.Geralt_UUID)
    jaskierTable = lua_table.ObjectFunctions:GetScript(lua_table.Jaskier_UUID)
 
    if jaskierTable.current_state ~= -3 and geraltDown == false and jaskierDown == false and jaskierHasRevived == false
    then
        jaskierRevive = true
        geraltDown = true
        jaskierHasRevived = true
    end

    if geraltTable.current_state ~= -3 and geraltDown == false and jaskierRevive == true 
    then
        geraltRevive = true
    end

    if jaskierDown == true
    then
        jaskierTable.current_health = 0
        jaskierTable.down_time = 10000000000000000
        jaskierDown = false
    end

    if geraltDown == true
    then
        geraltTable.current_health = 0
        geraltTable.down_time = 10000000000000000
        geraltDown = false
    end

    if jaskierRevive == true and geraltRevive == true
    then
        jaskierTable.down_time = 10000
        geraltTable.down_time = 10000
        
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.currentStep = Step.COMBAT
    end
end

local function Step7()    
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Kill the lumberjack!", textUID)

    if spawnEnemy == false
    then
        lastTime_step7 = lua_table.SystemFunctions:GameTime()
        lua_table.SystemFunctions:LOG("lumberjack 7 UID: "..lua_table.Lumberjack_7)
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_7)
        spawnEnemy = true
    end

    if lua_table.SystemFunctions:GameTime() > lastTime_step7 + step7_message_time
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.currentStep = Step.SPELLS
    end
end

local function Step8()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Press X to use the spells to defeat the enemy!", textUID)

    if hasDied == false
    then
        enemyTable = lua_table.ObjectFunctions:GetScript(lua_table.Lumberjack_7)
        enemyTable.deathTimer = 1000
    end

    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_X", "DOWN")
    then
        geraltSpell = true
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_X", "DOWN")
    then
        jaskierSpell = true
    end 

    if geraltSpell == true and jaskierSpell == true
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
    end

    if enemyTable.Dead == true and jaskierSpell == true and geraltSpell == true
    then
        lua_table.currentStep = Step.ULTIMATE

    elseif enemyTable.Dead == true
    then
        --enemyTable.Dead = false
        --enemyTable.CurrentHealth = enemyTable.MaxHealth
        --enemyTable.CurrentState = 1
        --lua_table.TransformFunctions:SetPosition(-25, 1, 36, lua_table.Lumberjack_7)

        hasDied = true
        tmpEnemy = lua_table.SceneFunctions:Instantiate(lua_table.lumberjack_UUID, -25, 1, 36, 0, 0, 0)
        enemyTable = lua_table.ObjectFunctions:GetScript(tmpEnemy)
        enemyTable.deathTimer = 1000
        enemyTable.Dead = false

        --enemyTable.CurrentHealth = enemyTable.MaxHealth
    end
end

local function Step9()    
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Press both trigger to use your ultimate!", textUID)

    if spawnEnemies == false
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_1)
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_2)
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_3)
        spawnEnemies = true
    end

    geralt_table = lua_table.ObjectFunctions:GetScript(lua_table.Geralt_UUID)     
    jaskier_table = lua_table.ObjectFunctions:GetScript(lua_table.Jaskier_UUID)      

    if geralt_table.current_state == 5
    then
        geraltUlted = true
        lua_table.SystemFunctions:LOG("Geralt ULT")
        --lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.GeraltUltiMessage)
    end
    
    if jaskier_table.current_state == 5
    then
        jaskierUlted = true
        lua_table.SystemFunctions:LOG("Jaskier ULT")
        --lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.JaskierUltiMessage)
    end


    if jaskierUlted == true and geraltUlted == true and lua_table.enemiesToKill_Step9 == 0
    then
        lua_table.currentStep = Step.KILL_EVERYONE
        lastTime_step10 = lua_table.SystemFunctions:GameTime()
        lua_table.InterfaceFunctions:SetText("Kill all enemies!", textUID)
        
        -- We activate the enemies
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_10_1)
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_10_2)
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_10_3)
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_10_4)
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_10_5)
    end
end

local function Step10()    
    if lua_table.enemiesToKill_Step10 == 0
    then
        lua_table.currentStep = Step.RETURN_TO_SQUARE
        lastTime_step11 = lua_table.SystemFunctions:GameTime()
        --lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.ReturnMessage)
        --lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.KillEveryoneMessage)
    end
            
    if lua_table.SystemFunctions:GameTime() > lastTime_step10 + step10_message_time
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
    end
end

local function Step11()    
    CalculateDistances(squarePosition)
    if lua_table.GeraltDistance < lua_table.threshold and lua_table.JaskierDistance < lua_table.threshold
    then
        lua_table.currentStep = Step.SURVIVE
        lastTime_step12 = lua_table.SystemFunctions:GameTime()
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
    end

    if lua_table.SystemFunctions:GameTime() > lastTime_step11 + step11_message_time
    then
        lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
        lua_table.InterfaceFunctions:SetText("Return to square", textUID)
    end
end

local function Step12()    
    if lua_table.SystemFunctions:GameTime() > lastTime_step12 + step12_message_time
    then
        lua_table.InterfaceFunctions:SetText("Tutorial Completed! GG WP", textUID)
        lua_table.SceneFunctions:LoadScene(lua_table.nextScene)
    end
end


local function ShowCombos()
    -- Geralt Combos Image
    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_START", KeyState.DOWN)
    then
        if is_geralt_combos == true
        then 
            lua_table.InterfaceFunctions:MakeElementInvisible("Image", geralt_combos)
            is_geralt_combos = false
        elseif is_geralt_combos == false
        then
            lua_table.InterfaceFunctions:MakeElementVisible("Image", geralt_combos)
            is_geralt_combos = true
        end
    end

    -- Jaskier Combos Image
    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_START", KeyState.DOWN)
    then
        if is_jaskier_combos == true
        then 
            lua_table.InterfaceFunctions:MakeElementInvisible("Image", jaskier_combos)
            is_jaskier_combos = false
        elseif is_jaskier_combos == false
        then
            lua_table.InterfaceFunctions:MakeElementVisible("Image", jaskier_combos)
            is_jaskier_combos = true
        end
    end
end
------------------------------------------------------------------------------
-- CORE
------------------------------------------------------------------------------

function lua_table:Awake()
    -- Get all the UUIDs
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    textUID = lua_table.ObjectFunctions:FindGameObject("Text")
    lua_table.Geralt_UUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    lua_table.Jaskier_UUID = lua_table.ObjectFunctions:FindGameObject("Jaskier")     
    lua_table.GeraltUltiMessage = lua_table.ObjectFunctions:FindGameObject("GeraltUltiMessage")   
    lua_table.JaskierUltiMessage = lua_table.ObjectFunctions:FindGameObject("JaskierUltiMessage")  
    lua_table.KillEveryoneMessage = lua_table.ObjectFunctions:FindGameObject("KillEveryoneMessage")
    lua_table.ReturnMessage = lua_table.ObjectFunctions:FindGameObject("ReturnMessage")
    lua_table.SurviveMessage = lua_table.ObjectFunctions:FindGameObject("SurviveMessage")

    lua_table.Lumberjack_7 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 7")

    lua_table.Lumberjack_9_1 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 9.1")
    lua_table.Lumberjack_9_2 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 9.2")
    lua_table.Lumberjack_9_3 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 9.3")
    
    lua_table.Lumberjack_10_1 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 10.1")
    lua_table.Lumberjack_10_2 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 10.2")
    lua_table.Lumberjack_10_3 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 10.3")
    lua_table.Lumberjack_10_4 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 10.4")
    lua_table.Lumberjack_10_5 = lua_table.ObjectFunctions:FindGameObject("Lumberjack 10.5")

    local parentBarril_1 = lua_table.ObjectFunctions:FindGameObject("Barril 1")
    local parentBarril_2 = lua_table.ObjectFunctions:FindGameObject("Barril 2")
    local parentBarril_3 = lua_table.ObjectFunctions:FindGameObject("Barril 3")
    local parentBarril_4 = lua_table.ObjectFunctions:FindGameObject("Barril 4")

    barril_1 = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Prop", parentBarril_1)
    barril_2 = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Prop", parentBarril_2)
    barril_3 = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Prop", parentBarril_3)
    barril_4 = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Prop", parentBarril_4)

    table_barril_1 = lua_table.ObjectFunctions:GetScript(barril_1)
    table_barril_2 = lua_table.ObjectFunctions:GetScript(barril_2)
    table_barril_3 = lua_table.ObjectFunctions:GetScript(barril_3)
    table_barril_4 = lua_table.ObjectFunctions:GetScript(barril_4)

    geralt_combos = lua_table.ObjectFunctions:FindGameObject("Geralt Combos")
    jaskier_combos = lua_table.ObjectFunctions:FindGameObject("Jaskier Combos")


end

function lua_table:Start()
end

function lua_table:Update()
    
    --lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_1)
    --lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_2)
    --lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_3)

    if lua_table.currentStep ~= Step.MOVEMENT and lua_table.currentStep ~= Step.DODGE
    then
        ShowCombos()
    end

    if lua_table.currentStep == Step.MOVEMENT
    then
        Step1()

    elseif lua_table.currentStep == Step.DODGE
    then
        Step2()
        
    elseif lua_table.currentStep == Step.BASIC_ATTACKS
    then
        Step3()

    elseif lua_table.currentStep == Step.BREAKABLE_OBJECTS 
    then 
        Step4()

    elseif lua_table.currentStep == Step.POTIONS
    then
        Step5()

    elseif lua_table.currentStep == Step.REANIMATE
    then
        Step6()

    elseif lua_table.currentStep == Step.COMBAT
    then
        Step7()
        
    elseif lua_table.currentStep == Step.SPELLS
    then
        Step8()

    elseif lua_table.currentStep == Step.ULTIMATE 
    then 
        Step9()
        
    elseif lua_table.currentStep == Step.KILL_EVERYONE
    then
        Step10()

    elseif lua_table.currentStep == Step.RETURN_TO_SQUARE
    then        
        Step11()

    elseif lua_table.currentStep == Step.SURVIVE
    then
        Step12()
    end
end

return lua_table
end