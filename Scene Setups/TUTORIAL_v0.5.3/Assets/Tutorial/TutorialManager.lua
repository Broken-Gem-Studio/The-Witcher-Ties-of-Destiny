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
lua_table.threshold = 4
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

-- Timers
local lastTime_step7 = 0
local step7_message_time = 10

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

local function SpawnEnemies()
    lua_table.SceneFunctions:Instantiate(lua_table.lumberjack_UUID, 10, 1, 10, 45, 0, 45)
    lua_table.SceneFunctions:Instantiate(lua_table.lumberjack_UUID, -10, 1, -10, 45, 0, 45)
    lua_table.SceneFunctions:Instantiate(lua_table.lumberjack_UUID, 5, 1, -5, 45, 0, 45)
end

------------------------------------------------------------------------------
-- STEPS
------------------------------------------------------------------------------

local function Step1()
end

local function Step2()
end

local function Step3()
end

local function Step4()
end

local function Step5()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Press button to use a potion. Press button to switch between health potion (red) and energy potion (yellow)", textUID)

    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_RIGHTSHOULDER", KeyState.DOWN)   -- BUTTON_RIGHTSHOULDER == R1 ps4 controller
    then
        geraltDrinkPotion = true
        lua_table.System:LOG("BUTTON_RIGHTSHOULDER geralt")
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_RIGHTSHOULDER", KeyState.DOW)   -- BUTTON_RIGHTSHOULDER == R1 ps4 controller
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
    lua_table.InterfaceFunctions:SetText("Hold button to reanimate your partner if they drop to 0 health", textUID)

    geraltTable = lua_table.GameObject:GetScript(lua_table.Geralt_UUID)
    jaskierTable = lua_table.GameObject:GetScript(lua_table.Jaskier_UUID)
 
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
        lua_table.GameObject:SetActiveGameObject(true, lua_table.Lumberjack_7)
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
    lua_table.InterfaceFunctions:SetText("Use the spells to defeat the enemy!", textUID)

    local enemyTable = lua_table.GameObject:GetScript(lua_table.Lumberjack_7)
    
    if lua_table.Input:IsGamepadButton(GeraltNumber, "BUTTON_X", "DOWN")
    then
        geraltSpell = true
    end

    if lua_table.Input:IsGamepadButton(JaskierNumber, "BUTTON_X", "DOWN")
    then
        jaskierSpell = true
    end 

    if geraltSpell == true and jaskierSpell == true
    then
        lua_table.UI:MakeElementInvisible("Text", textUID)
    end

    if enemyTable.Dead == true and jaskierSpell == true and geraltSpell == true
    then
        lua_table.currentStep = Step.ULTIMATE
    
    elseif enemyTable.Dead == true
    then
        enemyTable.Dead = false
        enemyTable.CurrentHealth = enemyTable.MaxHealth
    end
end

local function Step9()    
    geralt_table = lua_table.ObjectFunctions:GetScript(lua_table.Geralt_UUID)     
    jaskier_table = lua_table.ObjectFunctions:GetScript(lua_table.Jaskier_UUID)      

    if geralt_table.current_ultimate >= geralt_table.max_ultimate
    and lua_table.InputFunctions:IsTriggerState(GeraltNumber, "AXIS_TRIGGERLEFT", KeyState.REPEAT) 
    and lua_table.InputFunctions:IsTriggerState(GeraltNumber, "AXIS_TRIGGERRIGHT", KeyState.REPEAT)
    then
        geraltUlted = true
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.GeraltUltiMessage)
    end

    if jaskier_table.current_ultimate >= jaskier_table.max_ultimate
    and lua_table.InputFunctions:IsTriggerState(JaskierNumber, "AXIS_TRIGGERLEFT", KeyState.REPEAT) 
    and lua_table.InputFunctions:IsTriggerState(JaskierNumber, "AXIS_TRIGGERRIGHT", KeyState.REPEAT)
    then
        jaskierUlted = true
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.JaskierUltiMessage)
    end

    if jaskierUlted == true and geraltUlted == true and lua_table.enemiesToKill_Step9 == 0
    then
        lua_table.currentStep = Step.KILL_EVERYONE
        lastTime_step10 = lua_table.SystemFunctions:GameTime()
        lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.KillEveryoneMessage)
        
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
        lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.ReturnMessage)
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.KillEveryoneMessage)
    end
            
    if lua_table.SystemFunctions:GameTime() > lastTime_step10 + step10_message_time
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.KillEveryoneMessage)
    end
end

local function Step11()    
    CalculateDistances(squarePosition)
    if lua_table.GeraltDistance < lua_table.threshold and lua_table.JaskierDistance < lua_table.threshold
    then
        lua_table.currentStep = Step.SURVIVE
        lastTime_step12 = lua_table.SystemFunctions:GameTime()
        lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.SurviveMessage)
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.ReturnMessage)
    end

    if lua_table.SystemFunctions:GameTime() > lastTime_step11 + step11_message_time
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.ReturnMessage)
    end
end

local function Step12()    
    if lua_table.SystemFunctions:GameTime() > lastTime_step12 + step12_message_time
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.SurviveMessage)
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
end

function lua_table:Start()
end

function lua_table:Update()
    
    --lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_1)
    --lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_2)
    --lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.Lumberjack_9_3)

    if lua_table.currentStep == Step.POTIONS
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