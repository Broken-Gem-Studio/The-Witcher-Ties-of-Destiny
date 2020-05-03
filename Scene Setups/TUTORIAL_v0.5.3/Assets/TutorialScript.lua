function GetTableTutorialScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.UIFunctions = Scripting.Interface()
lua_table.PhysicsFunctions = Scripting.Physics()

local geralt
local jaskier
local block_1
local block_2
local block_3
local canvas_1
local canvas_2
local canvas_3
local geralt_combos
local jaskier_combos
local barril_1
local barril_2
local barril_3
local barril_4

local is_geralt_combos = true
local is_jaskier_combos = true

local table_barril_1
local table_barril_2
local table_barril_3
local table_barril_4

local blocked_1 = true
local blocked_2 = true
local blocked_3 = true

local blocked_1_geralt = true
local blocked_2_geralt = true
local blocked_3_geralt = true

local blocked_1_jaskier = true
local blocked_2_jaskier = true
local blocked_3_jaskier = true

function lua_table:OnTriggerEnter()
    if blocked_1 == false
    then
        lua_table.GameObjectFunctions:SetActiveGameObject(false, block_1)
    end

    if blocked_2 == false
    then
        lua_table.GameObjectFunctions:SetActiveGameObject(false, block_2)
    end

    if blocked_3 == false
    then
        lua_table.GameObjectFunctions:SetActiveGameObject(false, block_3)
    end
end

function lua_table:Awake()
    geralt = lua_table.GameObjectFunctions:FindGameObject("Geralt")
    jaskier = lua_table.GameObjectFunctions:FindGameObject("Jaskier")

    block_1 = lua_table.GameObjectFunctions:FindGameObject("Block 1")
    block_2 = lua_table.GameObjectFunctions:FindGameObject("Block 2")
    block_3 = lua_table.GameObjectFunctions:FindGameObject("Block 3")

    canvas_1 = lua_table.GameObjectFunctions:FindGameObject("Cartel 1")
    canvas_2 = lua_table.GameObjectFunctions:FindGameObject("Cartel 2")
    canvas_3 = lua_table.GameObjectFunctions:FindGameObject("Cartel 3")
    geralt_combos = lua_table.GameObjectFunctions:FindGameObject("Geralt Combos")
    jaskier_combos = lua_table.GameObjectFunctions:FindGameObject("Jaskier Combos")

    barril_1 = lua_table.GameObjectFunctions:FindGameObject("Barril 1")
    barril_2 = lua_table.GameObjectFunctions:FindGameObject("Barril 2")
    barril_3 = lua_table.GameObjectFunctions:FindGameObject("Barril 3")
    barril_4 = lua_table.GameObjectFunctions:FindGameObject("Barril 4")
    table_barril_1 = lua_table.GameObjectFunctions:GetScript(barril_1)
    table_barril_2 = lua_table.GameObjectFunctions:GetScript(barril_2)
    table_barril_3 = lua_table.GameObjectFunctions:GetScript(barril_3)
    table_barril_4 = lua_table.GameObjectFunctions:GetScript(barril_4)
end

function lua_table:Start()
end

function lua_table:Update()
    -- Block 1
    if blocked_1 == true
    then
        lua_table.GameObjectFunctions:SetActiveGameObject(true, canvas_1)

        if lua_table.InputFunctions:GetAxisValue(1, "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(1, "Y", 0.01) > 0
        then
            blocked_1_geralt = false
        end

        if lua_table.InputFunctions:GetAxisValue(2, "X", 0.01) > 0 or lua_table.InputFunctions:GetAxisValue(2, "Y", 0.01) > 0
        then
            blocked_1_jaskier = false
        end

        if blocked_1_geralt == false and blocked_1_jaskier == false
        then
            blocked_1 = false
        end
    end

    -- Block 2
    if blocked_2 == true and blocked_1 == false
    then
        lua_table.GameObjectFunctions:SetActiveGameObject(false, canvas_1)
        lua_table.GameObjectFunctions:SetActiveGameObject(true, canvas_2)

        if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_A", "DOWN") == true
        then
            blocked_2_geralt = false
        end

        if lua_table.InputFunctions:IsGamepadButton(2, "BUTTON_A", "DOWN") == true
        then
            blocked_2_jaskier = false
        end

        if blocked_2_geralt == false and blocked_2_jaskier == false
        then
            blocked_2 = false
        end
    end

    -- Block 3
    if blocked_3 == true and blocked_2 == false
    then
        lua_table.GameObjectFunctions:SetActiveGameObject(false, canvas_2)
        lua_table.GameObjectFunctions:SetActiveGameObject(true, canvas_3)

        -- Geralt Combos Image
        if lua_table.InputFunctions:IsGamepadButton(1, "SELECT", "DOWN") == true
        then
            if is_geralt_combos == true
            then 
                lua_table.UIFunctions:MakeElementInvisible(geralt_combos, "Image")
                is_geralt_combos = false
            elseif is_geralt_combos == false
            then
                lua_table.UIFunctions:MakeElementVisible(geralt_combos, "Image")
                is_geralt_combos = true
            end
        end

        -- Jaskier Combos Image
        if lua_table.InputFunctions:IsGamepadButton(2, "SELECT", "DOWN") == true
        then
            if is_jaskier_combos == true
            then 
                lua_table.UIFunctions:MakeElementInvisible(jaskier_combos, "Image")
                is_jaskier_combos = false
            elseif is_jaskier_combos == false
            then
                lua_table.UIFunctions:MakeElementVisible(jaskier_combos, "Image")
                is_jaskier_combos = true
            end
        end

        -- Check Breakable Props
        if table_barril_1.health == 0 and table_barril_2.health == 0 and table_barril_3.health == 0 and table_barril_4.health == 0
        then
            blocked_3 = false
        end
    end
end

return lua_table
end