function GetTableTutorial()

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

local KeyState = {
    IDLE = "IDLE",
	DOWN = "DOWN",
	REPEAT = "REPEAT",
	UP = "UP"
}

local Step = {
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
    STEP_12 = 12
}

lua_table.currentStep = Step.STEP_1

local MyUUID = 0
local GeraltNumber = 1
local JaskierNumber = 2
local textUID = 0

-- Variables STEP 1
local geraltHasMoved = false
local jaskierHasMoved = false

-- Variables STEP 2
local geraltAttackY = false
local geraltAttackB = false
local jaskierAttackY = false
local jaskierAttackB = false

-- Variables STEP 4
local enemy1, enemy2, enemy3, enemy4
local enemyTable1, enemyTable2, enemyTable3, enemyTable4 
local enemyDead1 = false 
local enemyDead2 = false
local enemyDead3 = false
local enemyDead4 = false
lua_table.MoveEnemies = false

-- Variables STEP 5
local chestStep5

-- Variables STEP 6
local geraltRoll = false
local jaskierRoll = false
local ghoul1, ghoul2, ghoul3, ghoul4
local move = false
lua_table.PauseStep6 = false

------------------------------------------------------------------------------
-- STEPS
------------------------------------------------------------------------------

local function Step1()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Use the left joystick to move the player", textUID)

    if lua_table.InputFunctions:GetAxisValue(GeraltNumber, "AXIS_LEFT" .. "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(GeraltNumber, "AXIS_LEFT" .. "Y", 0.01) > 0
    then
        geraltHasMoved = true
    end

    if lua_table.InputFunctions:GetAxisValue(JaskierNumber, "AXIS_LEFT" .. "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(JaskierNumber, "AXIS_LEFT" .. "Y", 0.01) > 0
    then
        jaskierHasMoved = true
    end

    if geraltHasMoved == true and jaskierHasMoved == true
    then
        lua_table.SystemFunctions:LOG("TEXT invisible")
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.currentStep = Step.STEP_2
    end
end

local function Step2()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Press Y to make a light attack. Press B to make a medium attack", textUID)

    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_Y", KeyState.DOWN) == true
    then
        geraltAttackY = true
    end

    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_B", KeyState.DOWN) == true
    then
        geraltAttackB = true
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_Y", KeyState.DOWN) == true
    then
        jaskierAttackY = true
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_B", KeyState.DOWN) == true
    then
        jaskierAttackB = true
    end

    if geraltAttackY == true and geraltAttackB == true and jaskierAttackY == true and jaskierAttackB == true
    then
        lua_table.SystemFunctions:LOG("TEXT invisible")
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", textUID)
        lua_table.currentStep = Step.STEP_3
    end
end

local function Step3()
    lua_table.currentStep = Step.STEP_4
end

local function Step4()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Kill all the enemies", textUID)
    --[[
    if lua_table.MoveEnemies == false
    then
        enemyTable1.currentState = 0
        enemyTable2.currentState = 0
        enemyTable3.currentState = 0
        enemyTable4.currentState = 0
    end
]]
    if enemyDead1 == false 
    then
        if enemyTable1.currentState == 5
        then
            enemyDead1 = true
        end
    end

    if enemyDead2 == false 
    then
        if enemyTable2.currentState == 5
        then
            enemyDead2 = true
        end
    end

    if enemyDead3 == false 
    then
        if enemyTable3.currentState == 5
        then
            enemyDead3 = true
        end
    end

    if enemyDead4 == false 
    then
        if enemyTable4.currentState == 5
        then
            enemyDead4 = true
        end
    end

    if enemyDead1 == true and enemyDead2 == true and enemyDead3 == true and enemyDead4 == true 
    then
        lua_table.currentStep = Step.STEP_6
    end
end

local function Step5()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Break the chest", textUID)

    if chestStep5 == nil
    then
        lua_table.currentStep = Step.STEP_7
    end
end

local function Step6()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", textUID)
    lua_table.InterfaceFunctions:SetText("Press A to move great distances and dodge attacks. Consumes 1 energy bar (yellow)", textUID)
    lua_table.SystemFunctions:LOG("hola STEP 6 ")

    if lua_table.PauseStep6 == true and move == false
    then
        lua_table.SystemFunctions:LOG("hola PAUSE STEP == TRUE")
        lua_table.SystemFunctions:PauseGame()        
    end
    --[[
    if move == false
    then
        lua_table.SystemFunctions:LOG("hola move == false")
        ghoulTable1.currentState = 0
        ghoulTable2.currentState = 0
        ghoulTable3.currentState = 0
        ghoulTable4.currentState = 0
    end
]]
    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_START", KeyState.DOWN) == true and move == false
    then
        lua_table.SystemFunctions:LOG("RESUME FUCKING GAME STEP 6")
        lua_table.PauseStep6 = false
        move = true
        lua_table.SystemFunctions:ResumeGame()
    end

    if lua_table.InputFunctions:IsGamepadButton(GeraltNumber, "BUTTON_A", KeyState.DOWN) == true
    then
        geraltRoll = true
    end

    if lua_table.InputFunctions:IsGamepadButton(JaskierNumber, "BUTTON_A", KeyState.DOWN) == true
    then
        jaskierRoll = true
    end

    if geraltRoll == true and jaskierRoll == true
    then
        lua_table.currentStep = Step.STEP_5
    end
end

local function EnemiesManager()
    if move == false
    then
        lua_table.SystemFunctions:LOG("hola move == false")
        ghoulTable1.currentState = 0
        ghoulTable2.currentState = 0
        ghoulTable3.currentState = 0
        ghoulTable4.currentState = 0
    end

    if lua_table.MoveEnemies == false
    then
        enemyTable1.currentState = 0
        enemyTable2.currentState = 0
        enemyTable3.currentState = 0
        enemyTable4.currentState = 0
    end
end

function lua_table:Awake()
    MyUUID = lua_table.ObjectFunctions:GetMyUID()
    textUID = lua_table.ObjectFunctions:FindGameObject("Text")
    
    lua_table.Geralt_UUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    lua_table.Jaskier_UUID = lua_table.ObjectFunctions:FindGameObject("Jaskier") 

    enemy1 = lua_table.ObjectFunctions:FindGameObject("enemy1")
    enemy2 = lua_table.ObjectFunctions:FindGameObject("enemy2")
    enemy3 = lua_table.ObjectFunctions:FindGameObject("enemy3")
    enemy4 = lua_table.ObjectFunctions:FindGameObject("enemy4")

    enemyTable1 = lua_table.ObjectFunctions:GetScript(enemy1)
    enemyTable2 = lua_table.ObjectFunctions:GetScript(enemy2)
    enemyTable3 = lua_table.ObjectFunctions:GetScript(enemy3)
    enemyTable4 = lua_table.ObjectFunctions:GetScript(enemy4)

    ghoul1 =  lua_table.ObjectFunctions:FindGameObject("ghoul1")
    ghoul2 =  lua_table.ObjectFunctions:FindGameObject("ghoul2")
    ghoul3 =  lua_table.ObjectFunctions:FindGameObject("ghoul3")
    ghoul4 =  lua_table.ObjectFunctions:FindGameObject("ghoul4")

    ghoulTable1 = lua_table.ObjectFunctions:GetScript(ghoul1)
    ghoulTable2 = lua_table.ObjectFunctions:GetScript(ghoul2)
    ghoulTable3 = lua_table.ObjectFunctions:GetScript(ghoul3)
    ghoulTable4 = lua_table.ObjectFunctions:GetScript(ghoul4)

end

function lua_table:Start()
end

function lua_table:Update()

    EnemiesManager()
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
    else
    end
end

return lua_table
end