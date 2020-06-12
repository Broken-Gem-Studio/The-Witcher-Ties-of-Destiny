function GetTableWL_Menu()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.UI = Scripting.Interface()
lua_table.Input = Scripting.Inputs()
lua_table.Scene = Scripting.Scenes()
lua_table.Audio = Scripting.Audio()

lua_table.scene_main_menu = 0
lua_table.scene_tutorial = 0
lua_table.scene_forest = 0
lua_table.scene_forest_cinematic = 0
lua_table.scene_credits = 0

local scene_to_load = {}
local has_to_load = false
local currentButton = 1

local loading = {}
local background = 0
local credits = 0
local mainmenu = 0
local nextlevel = 0
local retry = 0
local select = {
    0,
    0,
    0
}

-- function lua_table:GoToMainMenu()
--     --set ui inactive
--     lua_table.UI:MakeElementInvisible("Image", background)
--     lua_table.UI:MakeElementInvisible("Image", mainmenu)
--     lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
--     lua_table.UI:MakeElementInvisible("Image", nextlevel)
--     lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
--     lua_table.UI:MakeElementInvisible("Image", retry)
--     lua_table.UI:SetUIElementInteractable("Button", retry, false)
--     lua_table.UI:MakeElementInvisible("Image", only_mainmenu)
--     lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, false)
--     lua_table.UI:MakeElementInvisible("Image", only_retry)
--     lua_table.UI:SetUIElementInteractable("Button", only_retry, false)

--     --load main menu
--     last_checkpoint = 0
--     load_mainmenu = true
-- end

-- function lua_table:GoToNextLevel()
--     --set ui inactive
--     lua_table.UI:MakeElementInvisible("Image", background)
--     lua_table.UI:MakeElementInvisible("Image", mainmenu)
--     lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
--     lua_table.UI:MakeElementInvisible("Image", nextlevel)
--     lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
--     lua_table.UI:MakeElementInvisible("Image", retry)
--     lua_table.UI:SetUIElementInteractable("Button", retry, false)
--     lua_table.UI:MakeElementInvisible("Image", only_mainmenu)
--     lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, false)
--     lua_table.UI:MakeElementInvisible("Image", only_retry)
--     lua_table.UI:SetUIElementInteractable("Button", only_retry, false)

--     --load next level (level 2)
--     last_checkpoint = 0
--     load_level2 = true
-- end

-- function lua_table:GoToRetry()
--     --set ui inactive
--     lua_table.UI:MakeElementInvisible("Image", background)
--     lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
--     lua_table.UI:MakeElementInvisible("Image", nextlevel)
--     lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
--     lua_table.UI:MakeElementInvisible("Image", retry)
--     lua_table.UI:SetUIElementInteractable("Button", retry, false)
--     lua_table.UI:MakeElementInvisible("Image", only_mainmenu)
--     lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, false)
--     lua_table.UI:MakeElementInvisible("Image", only_retry)
--     lua_table.UI:SetUIElementInteractable("Button", only_retry, false)

--     --reload level
--     last_checkpoint = 0
--     if current_scene_score == 1 and load_level1 == false
--     then
--         load_level1 = true
--     elseif current_scene_score == 2 and load_level2 == false
--     then
--         load_level2 = true
--     end
-- end

function lua_table:ShowMenu()
    lua_table.UI:MakeElementVisible("Image", background)
    lua_table.UI:MakeElementVisible("Image", mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", mainmenu, true)
    lua_table.UI:MakeElementVisible("Image", retry)
    lua_table.UI:SetUIElementInteractable("Button", retry, true)

    if current_scene_score == 1
    then
        lua_table.UI:MakeElementVisible("Image", nextlevel)
        lua_table.UI:SetUIElementInteractable("Button", nextlevel, true)
        
    elseif current_scene_score == 2
    then
        --lua_table.UI:MakeElementVisible("Image", credits)
        --lua_table.UI:SetUIElementInteractable("Button", credits, true)
    end

    for i = 1, #select do
        lua_table.UI:MakeElementInvisible("Image", select[i])
    end

    lua_table.UI:MakeElementVisible("Image", select[currentButton])
end

function lua_table:Awake()
    --Failsave
    if current_scene_score == nil then current_scene_score = 1 end

    mainmenu = lua_table.GO:FindGameObject("MainMenu")
    nextlevel = lua_table.GO:FindGameObject("NextLevel")
    retry = lua_table.GO:FindGameObject("Retry")
    background = lua_table.GO:FindGameObject("WL_Background")
    loading_GO = lua_table.GO:FindGameObject("LoadingScreenCanvas")
    --credits = lua_table.GO:FindGameObject("Credits")

    loading = { lua_table.GO:FindGameObject("LoadingScreen_BG"), lua_table.GO:FindGameObject("TheWitcher_Wolf"), lua_table.GO:FindGameObject("FakeLoadingImage") }
    --set elements inactive
    lua_table.UI:MakeElementInvisible("Image", background)

    lua_table.UI:MakeElementInvisible("Image", mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
    lua_table.UI:MakeElementInvisible("Image", nextlevel)
    lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
    lua_table.UI:MakeElementInvisible("Image", retry)
    lua_table.UI:SetUIElementInteractable("Button", retry, false)
    --lua_table.UI:MakeElementInvisible("Image", credits)
    --lua_table.UI:SetUIElementInteractable("Button", credits, false)

    scene_to_load[1] = lua_table.scene_main_menu

    if current_scene_score == 1 then
        scene_to_load[2] = lua_table.scene_tutorial
        scene_to_load[3] = lua_table.scene_forest_cinematic
    elseif current_scene_score == 2 then
        scene_to_load[2] = lua_table.scene_forest
        scene_to_load[3] = lua_table.scene_credits
    end

    for i = 1, #select do
        select[i] = lua_table.GO:FindGameObject("Select_" .. i)
    end

    for i = 1, #loading do
        lua_table.UI:MakeElementInvisible("Image", loading[i])
    end

    lua_table.GO:SetActiveGameObject(false, lua_table.GO:GetMyUID())
end

function lua_table:Start()
end

function lua_table:Update()
    if lua_table.Input:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN")-- or lua_table.Input:IsGamepadButton(2, "BUTTON_DPAD_RIGHT", "DOWN")
    then 
        lua_table.Audio:PlayAudioEvent("Play_Mouse_over")
        lua_table.UI:MakeElementInvisible("Image", select[currentButton])
        currentButton = currentButton + 1
        if currentButton > 3 then currentButton = 1 end
        lua_table.UI:MakeElementVisible("Image", select[currentButton])
    elseif lua_table.Input:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN")-- or lua_table.Input:IsGamepadButton(2, "BUTTON_DPAD_LEFT", "DOWN")
    then 
        lua_table.Audio:PlayAudioEvent("Play_Mouse_over")
        lua_table.UI:MakeElementInvisible("Image", select[currentButton])
        currentButton = currentButton - 1
        if currentButton < 1 then currentButton = 3 end
        lua_table.UI:MakeElementVisible("Image", select[currentButton])
    elseif lua_table.Input:IsGamepadButton(1, "BUTTON_A", "DOWN")-- or lua_table.Input:IsGamepadButton(2, "BUTTON_A", "DOWN")
    then
        last_checkpoint = 0

        lua_table.UI:MakeElementInvisible("Image", background)
        lua_table.UI:MakeElementInvisible("Image", mainmenu)
        lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
        lua_table.UI:MakeElementInvisible("Image", retry)
        lua_table.UI:SetUIElementInteractable("Button", retry, false)

        if current_scene_score == 1
        then
            lua_table.UI:MakeElementInvisible("Image", nextlevel)
            lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
            
        elseif current_scene_score == 2
        then
            --lua_table.UI:MakeElementInvisible("Image", credits)
            --lua_table.UI:SetUIElementInteractable("Button", credits, false)
        end

        lua_table.UI:MakeElementInvisible("Image", select[currentButton])
        for i = 1, #loading do
            lua_table.UI:MakeElementVisible("Image", loading[i])
        end
        has_to_load = true

    elseif has_to_load then
        if scene_to_load[currentButton] ~= nil then
            lua_table.Scene:LoadScene(scene_to_load[currentButton])
        elseif scene_to_load[1] ~= nil then
            lua_table.Scene:LoadScene(scene_to_load[1])
        end
    end
end

return lua_table
end