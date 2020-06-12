function GetTableWL_Menu()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.UI = Scripting.Interface()
lua_table.Input = Scripting.Inputs()
lua_table.Scene = Scripting.Scenes()
lua_table.Audio = Scripting.Audio()

local Buttons = {}
local currentButton = 0
local select_ui = false

local mainmenu = 0
local nextlevel = 0
local retry = 0
local only_mainmenu = 0
local only_retry = 0

function lua_table:GoToMainMenu()
    select_ui = false

    --set ui inactive
    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
    lua_table.GO:SetActiveGameObject(false, retry)
    lua_table.UI:SetUIElementInteractable("Button", retry, false)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, only_retry)
    lua_table.UI:SetUIElementInteractable("Button", only_retry, false)

    --load main menu
    last_checkpoint = 0
    load_mainmenu = true
end

function lua_table:GoToNextLevel()
    select_ui = false

    --set ui inactive
    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
    lua_table.GO:SetActiveGameObject(false, retry)
    lua_table.UI:SetUIElementInteractable("Button", retry, false)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, only_retry)
    lua_table.UI:SetUIElementInteractable("Button", only_retry, false)

    --load next level (level 2)
    last_checkpoint = 0
    load_level2 = true
end

function lua_table:GoToRetry()
    select_ui = false

    --set ui inactive
    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
    lua_table.GO:SetActiveGameObject(false, retry)
    lua_table.UI:SetUIElementInteractable("Button", retry, false)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, only_retry)
    lua_table.UI:SetUIElementInteractable("Button", only_retry, false)

    --reload level
    last_checkpoint = 0
    if current_scene_score == 1 and load_level1 == false
    then
        load_level1 = true
    elseif current_scene_score == 2 and load_level2 == false
    then
        load_level2 = true
    end
end

local function ShowMenu()
    lua_table.GO:SetActiveGameObject(true, background)
    if current_scene_score == 1
    then
        lua_table.GO:SetActiveGameObject(true, mainmenu)
        lua_table.UI:SetUIElementInteractable("Button", mainmenu, true)
        lua_table.GO:SetActiveGameObject(true, nextlevel)
        lua_table.UI:SetUIElementInteractable("Button", nextlevel, true)
        lua_table.GO:SetActiveGameObject(true, retry)
        lua_table.UI:SetUIElementInteractable("Button", retry, true)
    elseif current_scene_score == 2
    then
        lua_table.GO:SetActiveGameObject(true, only_mainmenu)
        lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, true)
        lua_table.GO:SetActiveGameObject(true, only_retry)
        lua_table.UI:SetUIElementInteractable("Button", only_retry, true)
    end
end

function lua_table:Awake()
    mainmenu = lua_table.GO:FindGameObject("MainMenu")
    nextlevel = lua_table.GO:FindGameObject("NextLevel")
    retry = lua_table.GO:FindGameObject("Retry")
    only_mainmenu = lua_table.GO:FindGameObject("OnlyMainMenu")
    only_retry = lua_table.GO:FindGameObject("OnlyRetry")
    background = lua_table.GO:FindGameObject("WL_Background")

    --set elements inactive
    lua_table.GO:SetActiveGameObject(false, mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.UI:SetUIElementInteractable("Button", nextlevel, false)
    lua_table.GO:SetActiveGameObject(false, retry)
    lua_table.UI:SetUIElementInteractable("Button", retry, false)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)
    lua_table.UI:SetUIElementInteractable("Button", only_mainmenu, false)
    lua_table.GO:SetActiveGameObject(false, only_retry)
    lua_table.UI:SetUIElementInteractable("Button", only_retry, false)
end

function lua_table:Start()
end

function lua_table:Update()
    -- controllers
    if select_ui == true 
    then
        if current_scene_score == 1
        then
            Buttons = {
                MAINMENU = 1,
                NEXTLEVEL = 2,
                RETRY = 3
            }
            currentButton = Buttons.MAINMENU
        elseif current_scene_score == 2
        then
            Buttons = {
                MAINMENU = 1,
                RETRY = 2
            }
            currentButton = Buttons.MAINMENU
        end

        if lua_table.Input:IsGamepadButton(1, "BUTTON_A", "DOWN") or lua_table.Input:IsGamepadButton(2, "BUTTON_A", "DOWN")
        then
            if currentButton == Buttons.MAINMENU
            then
                lua_table:GoToMainMenu()			
            elseif currentButton == Buttons.NEXTLEVEL
            then
                lua_table:GoToNextLevel()			
            elseif currentButton == Buttons.RETRY
            then
                lua_table:GoToRetry()
            end
        end
        if lua_table.Input:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN") or lua_table.Input:IsGamepadButton(2, "BUTTON_DPAD_RIGHT", "DOWN")
        then 
            lua_table.Audio:PlayAudioEvent("Play_Mouse_over")
            currentButton = currentButton + 1
            if currentButton >= Buttons.RETRY
            then
                currentButton = Buttons.RETRY
            end
        end
        if lua_table.Input:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN") or lua_table.Input:IsGamepadButton(2, "BUTTON_DPAD_LEFT", "DOWN")
        then 
            lua_table.Audio:PlayAudioEvent("Play_Mouse_over")
            currentButton = currentButton - 1
            if currentButton <= Buttons.MAINMENU
            then
                currentButton = Buttons.MAINMENU
            end
        end
    end
end

return lua_table
end