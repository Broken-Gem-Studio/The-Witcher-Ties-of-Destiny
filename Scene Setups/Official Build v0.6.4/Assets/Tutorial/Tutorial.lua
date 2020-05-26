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
lua_table.textUID = 0

-- Variables STEP 1
local geraltHasMoved = false
local jaskierHasMoved = false
lua_table.StartStep2 = false

-- Variables STEP 2
local geraltAttackY = false
local geraltAttackB = false
local jaskierAttackY = false
local jaskierAttackB = false

-- Variables STEP 4
local enemy1, enemy2, enemy3, enemy4
local enemyTable1, enemyTable2, enemyTable3, enemyTable4 
local enemy4Dead = {
    enemyDead1 = 0,
    enemyDead2 = 0,
    enemyDead3 = 0,
    enemyDead4 = 0    
}

lua_table.MoveEnemies = false

-- Variables STEP 5
local chest5
local chestProp5
local tableChestProp5

-- Variables STEP 6
local geraltRoll = false
local jaskierRoll = false
local ghoul1, ghoul2, ghoul3, ghoul4
local tableGhoul1, tableGhoul2, tableGhoul4, tableGhoul4
local ghoulsDead = {
    ghoul_1_dead = 0,
    ghoul_2_dead = 0,
    ghoul_3_dead = 0,
    ghoul_4_dead = 0 
}

local move = false
local geraltStart6 = false
local jaskierStart6 = false
lua_table.PauseStep6 = false

-- Variables STEP 7
lua_table.MoveEnemies7 = false
local enemy7_1, enemy7_2, enemy7_3, enemy7_4, enemy7_5, enemy7_6
local tableEnemy7_1, tableEnemy7_2, tableEnemy7_3, tableEnemy7_4, tableEnemy7_5, tableEnemy7_6

local enemy7dead = {
    enemy7_1_dead = 0,
    enemy7_2_dead = 0,
    enemy7_3_dead = 0,
    enemy7_4_dead = 0, 
    enemy7_5_dead = 0, 
    enemy7_6_dead = 0 
}


-- Variables STEP 9
local lumberjack
local tableLumberjack
local lumberjackDead = false
local moveStep9 = false
local activateEnemiesStep10 = false
local geraltStart9 = false
local jaskierStart9 = false
lua_table.PauseStep9 = false

-- Variables STEP 10
local enemy10_1, enemy10_2, enemy10_3, enemy10_4, enemy10_5, enemy10_6, enemy10_7, enemy10_8, enemy10_9
local tableEnemy10_1, tableEnemy10_2, tableEnemy10_3, tableEnemy10_4, tableEnemy10_5, tableEnemy10_6, tableEnemy10_7, tableEnemy10_8, tableEnemy10_9
local enemy10dead = {
    enemy10_1_dead = 0,
    enemy10_2_dead = 0,
    enemy10_3_dead = 0,
    enemy10_4_dead = 0,
    enemy10_5_dead = 0,
    enemy10_6_dead = 0,
    enemy10_7_dead = 0,
    enemy10_8_dead = 0,
    enemy10_9_dead = 0    
}

local moveStep10 = false
lua_table.PauseStep10 = false
local geraltStart10 = false
local jaskierStart10 = false

-- Variables STEP 11
local enemy11_1, enemy11_2, enemy11_3, enemy11_4, enemy11_5, enemy11_6, enemy11_7, enemy11_8, enemy11_9
local tableEnemy11_1, tableEnemy11_2, tableEnemy11_3, tableEnemy11_4, tableEnemy11_5, tableEnemy11_6, tableEnemy11_7, tableEnemy11_8, tableEnemy11_9
local enemy11dead = {
    enemy11_1_dead = 0,
    enemy11_2_dead = 0,
    enemy11_3_dead = 0,
    enemy11_4_dead = 0,
    enemy11_5_dead = 0,
    enemy11_6_dead = 0,
    enemy11_7_dead = 0,
    enemy11_8_dead = 0,
    enemy11_9_dead = 0   
}

local moveStep11 = false
local geraltStart11 = false
local jaskierStart11 = false
lua_table.PauseStep11 = false

-- Variables STEP 12
local enemy12_1, enemy12_2, enemy12_3, enemy12_4, enemy12_5, enemy12_6, enemy12_7, enemy12_8, enemy12_9, enemy12_10, enemy12_11, enemy12_12, enemy12_13, enemy12_14, enemy12_15, enemy12_16 
local tableEnemy12_1, tableEnemy12_2, tableEnemy12_3, tableEnemy12_4, tableEnemy12_5, tableEnemy12_6, tableEnemy12_7, tableEnemy11_8
local tableEnemy12_9, tableEnemy12_10, tableEnemy12_11, tableEnemy12_12, tableEnemy12_13, tableEnemy12_14, tableEnemy12_15, tableEnemy12_16
local enemy12_1_dead = false
local enemy12_2_dead = false
local enemy12_3_dead = false
local enemy12_4_dead = false
local enemy12_5_dead = false
local enemy12_6_dead = false
local enemy12_7_dead = false
local enemy12_8_dead = false
local enemy12_9_dead = false
local enemy12_10_dead = false
local enemy12_11_dead = false
local enemy12_12_dead = false
local enemy12_13_dead = false
local enemy12_14_dead = false
local enemy12_15_dead = false
local enemy12_16_dead = false
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

-- ARCHERS
local archer_1, archer_2, archer_3, archer_4, archer_5, archer_6, archer_7, archer_8, archer_9
local tableArcher_1, tableArcher_2, tableArcher_3, tableArcher_4, tableArcher_5, tableArcher_6, tableArcher_7, tableArcher_8, tableArcher_9
------------------------------------------------------------------------------
-- STEPS
------------------------------------------------------------------------------

local function Step1()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("Use the left joystick to move the player", lua_table.textUID)

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
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.textUID)
        lua_table.currentStep = Step.STEP_2
    end
end

local function Step2()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("Press Y to make a light attack. Press B to make a medium attack", lua_table.textUID)

    if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_Y", KeyState.DOWN) == true
    then
        geraltAttackY = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_B", KeyState.DOWN) == true
    then
        geraltAttackB = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_Y", KeyState.DOWN) == true
    then
        jaskierAttackY = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_B", KeyState.DOWN) == true
    then
        jaskierAttackB = true
    end

    if geraltAttackY == true and geraltAttackB == true and jaskierAttackY == true and jaskierAttackB == true
    then
        lua_table.InterfaceFunctions:MakeElementInvisible("Text", lua_table.textUID)
        lua_table.currentStep = Step.STEP_3
    end
end

local function Step3()
    lua_table.currentStep = Step.STEP_4
end

local function Step4()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("Kill all the enemies", lua_table.textUID)

    if enemy4Dead.enemyDead1 == 0 
    then
        if enemyTable1.currentState == 5
        then
            enemy4Dead.enemyDead1 = 1
        end
    end

    if enemy4Dead.enemyDead2 == 0 
    then
        if enemyTable2.currentState == 5
        then
            enemy4Dead.enemyDead2 = 1
        end
    end

    if enemy4Dead.enemyDead3 == 0 
    then
        if enemyTable3.currentState == 5
        then
            enemy4Dead.enemyDead3 = 1
        end
    end

    if enemy4Dead.enemyDead4 == 0 
    then
        if enemyTable4.currentState == 5
        then
            enemy4Dead.enemyDead4 = 1
        end
    end

    if enemy4Dead.enemyDead1 == 1 and enemy4Dead.enemyDead2 == 1 and enemy4Dead.enemyDead3 == 1 and enemy4Dead.enemyDead4 == 1 
    then
        lua_table.currentStep = Step.STEP_6
    end
end

local function Step5()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("Break the chest", lua_table.textUID)

    if tableChestProp5.health == 0
    then
        lua_table.currentStep = Step.STEP_7
    end
end

local function Step6()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)

    if lua_table.PauseStep6 == true and move == false
        then
            lua_table.InterfaceFunctions:SetText("Press A to move great distances and dodge attacks. Consumes 1 energy bar (yellow)", lua_table.textUID)   
            lua_table.SystemFunctions:PauseGame()     
        end
    --[[
        if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_START", KeyState.DOWN) == true and geraltStart6 == false
        then
            geraltStart6 = true
            lua_table.SystemFunctions:LOG("Geralt STRAT")
        end
    
        if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_START", KeyState.DOWN) == true and jaskierStart6 == false
        then
            jaskierStart6 = true
            lua_table.SystemFunctions:LOG("Jaskier STRAT")
        end
        --]]
    
        if TABLE_CARTAS.continue_meter1_full == true and TABLE_CARTAS.continue_meter2_full == true
        then
            lua_table.SystemFunctions:ResumeGame()
            move = true
        end
    
        if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_A", KeyState.DOWN) == true
        then
            geraltRoll = true
        end
    
        if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_A", KeyState.DOWN) == true
        then
            jaskierRoll = true
        end
    
        if ghoulsDead.ghoul_1_dead == 0 
        then
            if tableGhoul1.currentState == 5
            then
                ghoulsDead.ghoul_1_dead = 1
            end
        end
    
        if ghoulsDead.ghoul_2_dead == 0 
        then
            if tableGhoul2.currentState == 5
            then
                ghoulsDead.ghoul_2_dead = 1
            end
        end
    
        if ghoulsDead.ghoul_3_dead == 0 
        then
            if tableGhoul3.currentState == 5
            then
                ghoulsDead.ghoul_3_dead = 1
            end
        end
    
        if ghoulsDead.ghoul_4_dead == 0 
        then
            if tableGhoul4.currentState == 5
            then
                ghoulsDead.ghoul_4_dead = 1
            end
        end
    
        if geraltRoll == true and jaskierRoll == true and ghoulsDead.ghoul_1_dead == 1 and ghoulsDead.ghoul_2_dead == 1 and ghoulsDead.ghoul_3_dead == 1 and ghoulsDead.ghoul_4_dead == 1
        then
            lua_table.currentStep = Step.STEP_5
        end
end


local function Step7()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("Kill the enemies - STEP 7", lua_table.textUID)

    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy7_1)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy7_2)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy7_3)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy7_4)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy7_5)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy7_6)

    if enemy7dead.enemy7_1_dead == 0 
    then
        if tableEnemy7_1.currentState == 5
        then
            enemy7dead.enemy7_1_dead = 1
        end
    end
    if enemy7dead.enemy7_2_dead == 0 
    then
        if tableEnemy7_2.currentState == 5
        then
            enemy7dead.enemy7_2_dead = 1
        end
    end
    if enemy7dead.enemy7_3_dead == 0 
    then
        if tableEnemy7_3.currentState == 5
        then
            enemy7dead.enemy7_3_dead = 1
        end
    end
    if enemy7dead.enemy7_4_dead == 0 
    then
        if tableEnemy7_4.currentState == 5
        then
            enemy7dead.enemy7_4_dead = 1
        end
    end
    if enemy7dead.enemy7_5_dead == 0 
    then
        if tableEnemy7_5.currentState == 5
        then
            enemy7dead.enemy7_5_dead = 1
        end
    end
    if enemy7dead.enemy7_6_dead == 0 
    then
        if tableEnemy7_6.currentState == 5
        then
            enemy7dead.enemy7_6_dead = 1
        end
    end

    if enemy7dead.enemy7_1_dead == 1 and enemy7dead.enemy7_2_dead == 1 and enemy7dead.enemy7_3_dead == 1 and 
    enemy7dead.enemy7_4_dead == 1 and enemy7dead.enemy7_5_dead == 1 and enemy7dead.enemy7_6_dead == 1
    then
        lua_table.currentStep = Step.STEP_8
    end

end

local function Step8()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("STEP 8", lua_table.textUID)

    lua_table.currentStep = Step.STEP_9
end

local function Step9()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("STEP 9", lua_table.textUID)

    if lua_table.PauseStep9 == true and moveStep9 == false
    then
        lua_table.SystemFunctions:PauseGame()     
        lua_table.SystemFunctions:LOG("PASUE GAME STEP 9")   
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_START", KeyState.DOWN) == true and geraltStart9 == false
    then
        lua_table.PauseStep9 = false
        geraltStart9 = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_START", KeyState.DOWN) == true and jaskierStart9 == false
    then
        lua_table.PauseStep9 = false
        jaskierStart9 = true
    end

    if geraltStart9 == true and jaskierStart9 == true
    then
        lua_table.SystemFunctions:ResumeGame()
        moveStep9 = true
    end

    if lumberjackDead == false 
    then
        if tableLumberjack.CurrentState == 4
        then
            lua_table.SystemFunctions:LOG("LUMBERJACK DEAD")
            lumberjackDead = true
        end
    end

    if lumberjackDead == true
    then
        activateEnemiesStep10 = true
        lua_table.currentStep = Step.STEP_10
    end
end


local function Step10()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("STEP 10", lua_table.textUID)

    if lua_table.PauseStep10 == true and moveStep10 == false
    then
        lua_table.SystemFunctions:PauseGame()     
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_START", KeyState.DOWN) == true and geraltStart10 == false
    then
        lua_table.PauseStep10 = false
        geraltStart10 = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_START", KeyState.DOWN) == true and jaskierStart10 == false
    then
        lua_table.PauseStep10 = false
        jaskierStart10 = true
    end

    if geraltStart10 == true and jaskierStart10 == true
    then
        lua_table.SystemFunctions:ResumeGame()
        moveStep10 = true
    end

    if enemy10dead.enemy10_1_dead == 0 
    then
        if tableEnemy10_1.currentState == 5
        then
            enemy10dead.enemy10_1_dead = 1
        end
    end

    if enemy10dead.enemy10_2_dead == 0 
    then
        if tableEnemy10_2.currentState == 5
        then
            enemy10dead.enemy10_2_dead = 1
        end
    end

    if enemy10dead.enemy10_3_dead == 0 
    then
        if tableEnemy10_3.currentState == 5
        then
            enemy10dead.enemy10_3_dead = 1
        end
    end

    if enemy10dead.enemy10_4_dead == 0 
    then
        if tableEnemy10_4.currentState == 5
        then
            enemy10dead.enemy10_4_dead = 1
        end
    end

    if enemy10dead.enemy10_5_dead == 0 
    then
        if tableEnemy10_5.currentState == 5
        then
            enemy10dead.enemy10_5_dead = 1
        end
    end

    if enemy10dead.enemy10_6_dead == 0 
    then
        if tableEnemy10_6.currentState == 5
        then
            enemy10dead.enemy10_6_dead = 1
        end
    end

    if enemy10dead.enemy10_7_dead == 0 
    then
        if tableEnemy10_7.currentState == 5
        then
            enemy10dead.enemy10_7_dead = 1
        end
    end

    if enemy10dead.enemy10_8_dead == 0 
    then
        if tableEnemy10_8.currentState == 5
        then
            enemy10dead.enemy10_8_dead = 1
        end
    end

    if enemy10dead.enemy10_9_dead == 0 
    then
        if tableEnemy10_9.CurrentState == 4
        then
            enemy10dead.enemy10_9_dead = 1
        end
    end

    if enemy10dead.enemy10_1_dead == 1 and enemy10dead.enemy10_2_dead == 1 and enemy10dead.enemy10_3_dead == 1 and enemy10dead.enemy10_4_dead == 1 and enemy10dead.enemy10_5_dead == 1 and 
    enemy10dead.enemy10_6_dead == 1 and enemy10dead.enemy10_7_dead == 1 and enemy10dead.enemy10_8_dead == 1 and enemy10dead.enemy10_9_dead == 1
    then
        lua_table.currentStep = Step.STEP_11
    end
end


local function Step11()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("STEP 11", lua_table.textUID)

    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_1)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_2)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_3)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_4)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_5)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_6)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_7)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_8)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy11_9)

    if lua_table.PauseStep11 == true and moveStep11 == false
    then
        lua_table.SystemFunctions:PauseGame()     
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_START", KeyState.DOWN) == true and geraltStart11 == false
    then
        lua_table.PauseStep11 = false
        geraltStart11 = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_START", KeyState.DOWN) == true and jaskierStart11 == false
    then
        lua_table.PauseStep11 = false
        jaskierStart11 = true
    end

    if geraltStart11 == true and jaskierStart11 == true
    then
        lua_table.SystemFunctions:ResumeGame()
        moveStep11 = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_X", "DOWN")
    then
        geraltSpell = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_X", "DOWN")
    then
        jaskierSpell = true
    end 

    if enemy11dead.enemy11_1_dead == 0 
    then
        if tableEnemy11_1.currentState == 4
        then
            enemy11dead.enemy11_1_dead = 1
        end
    end

    if enemy11dead.enemy11_2_dead == 0 
    then
        if tableEnemy11_2.currentState == 4
        then
            enemy11dead.enemy11_2_dead = 1
        end
    end

    if enemy11dead.enemy11_3_dead == 0 
    then
        if tableEnemy11_3.currentState == 5
        then
            enemy11dead.enemy11_3_dead = 1
        end
    end

    if enemy11dead.enemy11_4_dead == 0 
    then
        if tableEnemy11_4.currentState == 5
        then
            enemy11dead.enemy11_4_dead = 1
        end
    end

    if enemy11dead.enemy11_5_dead == 0 
    then
        if tableEnemy11_5.currentState == 5
        then
            enemy11dead.enemy11_5_dead = 1
        end
    end

    if enemy11dead.enemy11_6_dead == 0 
    then
        if tableEnemy11_6.currentState == 5
        then
            enemy11dead.enemy11_6_dead = 1
        end
    end

    if enemy11dead.enemy11_7_dead == 0 
    then
        if tableEnemy11_7.currentState == 5
        then
            enemy11dead.enemy11_7_dead = 1
        end
    end

    if enemy11dead.enemy11_8_dead == 0 
    then
        if tableEnemy11_8.currentState == 5
        then
            enemy11dead.enemy11_8_dead = 1
        end
    end

    if enemy11dead.enemy11_9_dead == 0 
    then
        if tableEnemy11_9.CurrentState == 5
        then
            enemy11dead.enemy11_9_dead = 1
        end
    end

    if enemy11dead.enemy11_1_dead == 1 and enemy11dead.enemy11_2_dead == 1 and enemy11dead.enemy11_3_dead == 1 and enemy11dead.enemy11_4_dead == 1 and enemy11dead.enemy11_5_dead == 1 and 
    enemy11dead.enemy11_6_dead == 1 and enemy11dead.enemy11_7_dead == 1 and enemy11dead.enemy11_8_dead == 1 and enemy11dead.enemy11_9_dead == 1 and jaskierSpell == true and geraltSpell == true
    then
        lua_table.currentStep = Step.STEP_11
    end
end


local function Step12()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("STEP 12", lua_table.textUID)

    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_1)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_2)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_3)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_4)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_5)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_6)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_7)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_8)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_9)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_10)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_11)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_12)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_13)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_14)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_15)
    lua_table.ObjectFunctions:SetActiveGameObject(true, enemy12_16)

    if lua_table.PauseStep12 == true and moveStep12 == false
    then
        lua_table.SystemFunctions:PauseGame()     
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.GeraltNumber, "BUTTON_START", KeyState.DOWN) == true and geraltStart12 == false
    then
        lua_table.PauseStep12 = false
        geraltStart12 = true
    end

    if lua_table.InputFunctions:IsGamepadButton(lua_table.JaskierNumber, "BUTTON_START", KeyState.DOWN) == true and jaskierStart12 == false
    then
        lua_table.PauseStep12 = false
        jaskierStart12 = true
    end

    if geraltStart12 == true and jaskierStart12 == true
    then
        lua_table.SystemFunctions:ResumeGame()
        moveStep12 = true
    end

    if enemy12_1_dead == false 
    then
        if tableEnemy12_1.currentState == 5
        then
            enemy12_1_dead = true
        end
    end

    if enemy12_2_dead == false 
    then
        if tableEnemy12_2.currentState == 5
        then
            enemy12_2_dead = true
        end
    end

    if enemy12_3_dead == false 
    then
        if tableEnemy12_3.currentState == 5
        then
            enemy12_3_dead = true
        end
    end

    if enemy12_4_dead == false 
    then
        if tableEnemy12_4.currentState == 5
        then
            enemy12_4_dead = true
        end
    end

    if enemy12_5_dead == false 
    then
        if tableEnemy12_5.currentState == 5
        then
            enemy12_5_dead = true
        end
    end

    if enemy12_6_dead == false 
    then
        if tableEnemy12_6.currentState == 5
        then
            enemy12_6_dead = true
        end
    end

    if enemy12_7_dead == false 
    then
        if tableEnemy12_7.currentState == 5
        then
            enemy12_7_dead = true
        end
    end

    if enemy12_8_dead == false 
    then
        if tableEnemy12_8.currentState == 5
        then
            enemy12_8_dead = true
        end
    end

    if enemy12_9_dead == false 
    then
        if tableEnemy12_9.currentState == 7
        then
            enemy12_9_dead = true
        end
    end

    if enemy12_10_dead == false 
    then
        if tableEnemy12_10.currentState == 7
        then
            enemy12_10_dead = true
        end
    end

    if enemy12_11_dead == false 
    then
        if tableEnemy12_11.currentState == 7
        then
            enemy12_11_dead = true
        end
    end

    if enemy12_12_dead == false 
    then
        if tableEnemy12_12.currentState == 7
        then
            enemy12_12_dead = true
        end
    end

    if enemy12_13_dead == false 
    then
        if tableEnemy12_13.currentState == 7
        then
            enemy12_13_dead = true
        end
    end

    if enemy12_14_dead == false 
    then
        if tableEnemy12_14.currentState == 7
        then
            enemy12_14_dead = true
        end
    end

    if enemy12_15_dead == false 
    then
        if tableEnemy12_15.currentState == 7
        then
            enemy12_15_dead = true
        end
    end

    if enemy12_16_dead == false 
    then
        if tableEnemy12_16.currentState == 7
        then
            enemy12_16_dead = true
        end
    end

    if tableGeralt.current_state == 5
    then
        geraltUlt = true
    end
    
    if tableJaskier.current_state == 5
    then
        jaskierUlt = true
    end

    if enemy12_1_dead == true and enemy12_2_dead == true and enemy12_3_dead == true and enemy12_4_dead == true and 
    enemy12_5_dead == true and enemy12_6_dead == true and enemy12_7_dead == true and enemy12_8_dead == true and
    enemy12_9_dead == true and enemy12_10_dead == true and enemy12_11_dead == true and enemy12_12_dead == true and
    enemy12_13_dead == true and enemy12_14_dead == true and enemy12_15_dead == true and enemy12_16_dead == true and
    geraltUlt == true and jaskierUlt == true 
    then
        lua_table.currentStep = Step.STEP_13
    end
end


local function Step13()
    lua_table.InterfaceFunctions:MakeElementVisible("Text", lua_table.textUID)
    lua_table.InterfaceFunctions:SetText("STEP 13", lua_table.textUID)

    
    if lua_table.SaveGame13 == true and hasSaved == false
    then
        hasSaved = true

        -- SAVE GAME FUNCTION
    end
    
    if hasSaved == true
    then
        lua_table.currentStep = Step.NONE
    end
    
    lua_table.currentStep = Step.NONE
    
end


local function EnemiesManager()
    
    if move == false
    then
        tableGhoul1.currentState = 0
        tableGhoul2.currentState = 0
        tableGhoul3.currentState = 0
        tableGhoul4.currentState = 0
    end

    if lua_table.MoveEnemies == false and lua_table.currentStep < 4
    then
        enemyTable1.currentState = 0
        enemyTable2.currentState = 0
        enemyTable3.currentState = 0
        enemyTable4.currentState = 0
    end

    if moveStep9 == false and lua_table.currentStep < 9
    then
        tableLumberjack.CurrentState = 1
    end

    if activateEnemiesStep10 == false and lua_table.currentStep < 10
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_1)
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_2)
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_3)
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_4)
    end

    if moveStep10 == false and lua_table.currentStep == 10
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_5)
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_6)
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_7)
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_8)
        lua_table.ObjectFunctions:SetActiveGameObject(true, enemy10_9)
    end

end

function lua_table:Awake()
    CARTAS = lua_table.ObjectFunctions:FindGameObject("CARTAS")
    TABLE_CARTAS = lua_table.ObjectFunctions:GetScript(CARTAS)

    lua_table.MyUUID = lua_table.ObjectFunctions:GetMyUID()
    lua_table.textUID = lua_table.ObjectFunctions:FindGameObject("Text")
    
    lua_table.Geralt_UUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
    lua_table.Jaskier_UUID = lua_table.ObjectFunctions:FindGameObject("Jaskier") 

    tableGeralt = lua_table.ObjectFunctions:GetScript(lua_table.Geralt_UUID)
    tableJaskier = lua_table.ObjectFunctions:GetScript(lua_table.Jaskier_UUID)

    enemy1 = lua_table.ObjectFunctions:FindGameObject("enemy1")
    enemy2 = lua_table.ObjectFunctions:FindGameObject("enemy2")
    enemy3 = lua_table.ObjectFunctions:FindGameObject("enemy3")
    enemy4 = lua_table.ObjectFunctions:FindGameObject("enemy4")

    enemyTable1 = lua_table.ObjectFunctions:GetScript(enemy1)
    enemyTable2 = lua_table.ObjectFunctions:GetScript(enemy2)
    enemyTable3 = lua_table.ObjectFunctions:GetScript(enemy3)
    enemyTable4 = lua_table.ObjectFunctions:GetScript(enemy4)

    ghoul1 =  lua_table.ObjectFunctions:FindGameObject("enemy6_1")
    ghoul2 =  lua_table.ObjectFunctions:FindGameObject("enemy6_2")
    ghoul3 =  lua_table.ObjectFunctions:FindGameObject("enemy6_3")
    ghoul4 =  lua_table.ObjectFunctions:FindGameObject("enemy6_4")

    tableGhoul1 = lua_table.ObjectFunctions:GetScript(ghoul1)
    tableGhoul2 = lua_table.ObjectFunctions:GetScript(ghoul2)
    tableGhoul3 = lua_table.ObjectFunctions:GetScript(ghoul3)
    tableGhoul4 = lua_table.ObjectFunctions:GetScript(ghoul4)

    chest5 = lua_table.ObjectFunctions:FindGameObject("Box_Prop")
    chestProp5 = lua_table.ObjectFunctions:FindGameObject("PropStep5")
    tableChestProp5 = lua_table.ObjectFunctions:GetScript(chestProp5)
    
    enemy7_1 = lua_table.ObjectFunctions:FindGameObject("enemy7_1")
    enemy7_2 = lua_table.ObjectFunctions:FindGameObject("enemy7_2")
    enemy7_3 = lua_table.ObjectFunctions:FindGameObject("enemy7_3")
    enemy7_4 = lua_table.ObjectFunctions:FindGameObject("enemy7_4")
    enemy7_5 = lua_table.ObjectFunctions:FindGameObject("enemy7_5")
    enemy7_6 = lua_table.ObjectFunctions:FindGameObject("enemy7_6")

    tableEnemy7_1 = lua_table.ObjectFunctions:GetScript(enemy7_1)
    tableEnemy7_2 = lua_table.ObjectFunctions:GetScript(enemy7_2)
    tableEnemy7_3 = lua_table.ObjectFunctions:GetScript(enemy7_3)
    tableEnemy7_4 = lua_table.ObjectFunctions:GetScript(enemy7_4)
    tableEnemy7_5 = lua_table.ObjectFunctions:GetScript(enemy7_5)
    tableEnemy7_6 = lua_table.ObjectFunctions:GetScript(enemy7_6)

    lumberjack = lua_table.ObjectFunctions:FindGameObject("Lumberjack")

    tableLumberjack = lua_table.ObjectFunctions:GetScript(lumberjack)

    enemy10_1 = lua_table.ObjectFunctions:FindGameObject("enemy10_1")
    enemy10_2 = lua_table.ObjectFunctions:FindGameObject("enemy10_2")
    enemy10_3 = lua_table.ObjectFunctions:FindGameObject("enemy10_3")
    enemy10_4 = lua_table.ObjectFunctions:FindGameObject("enemy10_4")
    enemy10_5 = lua_table.ObjectFunctions:FindGameObject("enemy10_5")
    enemy10_6 = lua_table.ObjectFunctions:FindGameObject("enemy10_6")
    enemy10_7 = lua_table.ObjectFunctions:FindGameObject("enemy10_7")
    enemy10_8 = lua_table.ObjectFunctions:FindGameObject("enemy10_8")
    enemy10_9 = lua_table.ObjectFunctions:FindGameObject("enemy10_9")

    tableEnemy10_1 = lua_table.ObjectFunctions:GetScript(enemy10_1)
    tableEnemy10_2 = lua_table.ObjectFunctions:GetScript(enemy10_2)
    tableEnemy10_3 = lua_table.ObjectFunctions:GetScript(enemy10_3)
    tableEnemy10_4 = lua_table.ObjectFunctions:GetScript(enemy10_4)
    tableEnemy10_5 = lua_table.ObjectFunctions:GetScript(enemy10_5)
    tableEnemy10_6 = lua_table.ObjectFunctions:GetScript(enemy10_6)
    tableEnemy10_7 = lua_table.ObjectFunctions:GetScript(enemy10_7)
    tableEnemy10_8 = lua_table.ObjectFunctions:GetScript(enemy10_8)
    tableEnemy10_9 = lua_table.ObjectFunctions:GetScript(enemy10_9)

    archer_1 = lua_table.ObjectFunctions:FindGameObject("Archer_1")
    archer_2 = lua_table.ObjectFunctions:FindGameObject("Archer_2")
    archer_3 = lua_table.ObjectFunctions:FindGameObject("Archer_3")
    archer_4 = lua_table.ObjectFunctions:FindGameObject("Archer_4")
    archer_5 = lua_table.ObjectFunctions:FindGameObject("Archer_5")
    archer_6 = lua_table.ObjectFunctions:FindGameObject("Archer_6")
    archer_7 = lua_table.ObjectFunctions:FindGameObject("Archer_7")
    archer_8 = lua_table.ObjectFunctions:FindGameObject("Archer_8")
    archer_9 = lua_table.ObjectFunctions:FindGameObject("Archer_9")

    tableArcher_1 = lua_table.ObjectFunctions:GetScript(archer_1)
    tableArcher_2 = lua_table.ObjectFunctions:GetScript(archer_2)
    tableArcher_3 = lua_table.ObjectFunctions:GetScript(archer_3)
    tableArcher_4 = lua_table.ObjectFunctions:GetScript(archer_4)
    tableArcher_5 = lua_table.ObjectFunctions:GetScript(archer_5)
    tableArcher_6 = lua_table.ObjectFunctions:GetScript(archer_6)
    tableArcher_7 = lua_table.ObjectFunctions:GetScript(archer_7)
    tableArcher_8 = lua_table.ObjectFunctions:GetScript(archer_8)
    tableArcher_9 = lua_table.ObjectFunctions:GetScript(archer_9)

    enemy11_1 = lua_table.ObjectFunctions:FindGameObject("enemy11_1")
    enemy11_2 = lua_table.ObjectFunctions:FindGameObject("enemy11_2")
    enemy11_3 = lua_table.ObjectFunctions:FindGameObject("enemy11_3")
    enemy11_4 = lua_table.ObjectFunctions:FindGameObject("enemy11_4")
    enemy11_5 = lua_table.ObjectFunctions:FindGameObject("enemy11_5")
    enemy11_6 = lua_table.ObjectFunctions:FindGameObject("enemy11_6")
    enemy11_7 = lua_table.ObjectFunctions:FindGameObject("enemy11_7")
    enemy11_8 = lua_table.ObjectFunctions:FindGameObject("enemy11_8")
    enemy11_9 = lua_table.ObjectFunctions:FindGameObject("enemy11_9")

    tableEnemy11_1 = lua_table.ObjectFunctions:GetScript(enemy11_1)
    tableEnemy11_2 = lua_table.ObjectFunctions:GetScript(enemy11_2)
    tableEnemy11_3 = lua_table.ObjectFunctions:GetScript(enemy11_3)
    tableEnemy11_4 = lua_table.ObjectFunctions:GetScript(enemy11_4)
    tableEnemy11_5 = lua_table.ObjectFunctions:GetScript(enemy11_5)
    tableEnemy11_6 = lua_table.ObjectFunctions:GetScript(enemy11_6)
    tableEnemy11_7 = lua_table.ObjectFunctions:GetScript(enemy11_7)
    tableEnemy11_8 = lua_table.ObjectFunctions:GetScript(enemy11_8)
    tableEnemy11_9 = lua_table.ObjectFunctions:GetScript(enemy11_9)

    enemy12_1 = lua_table.ObjectFunctions:FindGameObject("enemy12_1")
    enemy12_2 = lua_table.ObjectFunctions:FindGameObject("enemy12_2")
    enemy12_3 = lua_table.ObjectFunctions:FindGameObject("enemy12_3")
    enemy12_4 = lua_table.ObjectFunctions:FindGameObject("enemy12_4")
    enemy12_5 = lua_table.ObjectFunctions:FindGameObject("enemy12_5")
    enemy12_6 = lua_table.ObjectFunctions:FindGameObject("enemy12_6")
    enemy12_7 = lua_table.ObjectFunctions:FindGameObject("enemy12_7")
    enemy12_8 = lua_table.ObjectFunctions:FindGameObject("enemy12_8")
    enemy12_9 = lua_table.ObjectFunctions:FindGameObject("enemy12_9")
    enemy12_10 = lua_table.ObjectFunctions:FindGameObject("enemy12_10")
    enemy12_11 = lua_table.ObjectFunctions:FindGameObject("enemy12_11")
    enemy12_12 = lua_table.ObjectFunctions:FindGameObject("enemy12_12")
    enemy12_13 = lua_table.ObjectFunctions:FindGameObject("enemy12_13")
    enemy12_14 = lua_table.ObjectFunctions:FindGameObject("enemy12_14")
    enemy12_15 = lua_table.ObjectFunctions:FindGameObject("enemy12_15")
    enemy12_16 = lua_table.ObjectFunctions:FindGameObject("enemy12_16")

    tableEnemy12_1 = lua_table.ObjectFunctions:GetScript(enemy12_1)
    tableEnemy12_2 = lua_table.ObjectFunctions:GetScript(enemy12_2)
    tableEnemy12_3 = lua_table.ObjectFunctions:GetScript(enemy12_3)
    tableEnemy12_4 = lua_table.ObjectFunctions:GetScript(enemy12_4)
    tableEnemy12_5 = lua_table.ObjectFunctions:GetScript(enemy12_5)
    tableEnemy12_6 = lua_table.ObjectFunctions:GetScript(enemy12_6)
    tableEnemy12_7 = lua_table.ObjectFunctions:GetScript(enemy12_7)
    tableEnemy12_8 = lua_table.ObjectFunctions:GetScript(enemy12_8)
    tableEnemy12_9 = lua_table.ObjectFunctions:GetScript(enemy12_9)
    tableEnemy12_10 = lua_table.ObjectFunctions:GetScript(enemy12_10)
    tableEnemy12_11 = lua_table.ObjectFunctions:GetScript(enemy12_11)
    tableEnemy12_12 = lua_table.ObjectFunctions:GetScript(enemy12_12)
    tableEnemy12_13 = lua_table.ObjectFunctions:GetScript(enemy12_13)
    tableEnemy12_14 = lua_table.ObjectFunctions:GetScript(enemy12_14)
    tableEnemy12_15 = lua_table.ObjectFunctions:GetScript(enemy12_15)
    tableEnemy12_16 = lua_table.ObjectFunctions:GetScript(enemy12_16)

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