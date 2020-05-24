function GetTableWinLose()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.UI = Scripting.Interface()
lua_table.Input = Scripting.Inputs()
lua_table.Scene = Scripting.Scenes()
lua_table.Physics = Scripting.Physics()

lua_table.level1_uid = 0
lua_table.level2_uid = 0
lua_table.mm_uid = 0

local background = 0
local fade = 0
local win = 0
local lose = 0
local mainmenu = 0
local nextlevel = 0
local only_mainmenu = 0

local Geralt = 0
local geralt_script = 0
local geralt_x = 0
local geralt_y = 0
local geralt_z = 0

local Jaskier = 0
local jaskier_script = 0
local jaskier_x = 0
local jaskier_y = 0
local jaskier_z = 0

local is_win = false
local is_lose = false

local bg_flag = false
local win_flag = false
local lose_flag = false
local fade_flag = false
local mm_flag = false

local bg_alpha = 0
local fade_alpha = 0
local win_alpha = 0
local lose_alpha = 0
local mm_alpha = 0
local nl_alpha = 0
local omm_alpha = 0

local function Victory()
    lua_table.System:PauseGame()
        
    if bg_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, background)

        bg_alpha = bg_alpha + 2
        lua_table.UI:ChangeUIComponentAlpha("Image", bg_alpha, background)

        if bg_alpha == 256
        then
            bg_flag = true
        end
    end

    if bg_flag == true and win_flag == false
    then
        --victory sound**
        lua_table.GO:SetActiveGameObject(true, win)

        win_alpha = win_alpha + 4
        lua_table.UI:ChangeUIComponentAlpha("Image", win_alpha, win)

        if win_alpha == 256
        then
            win_flag = true
        end
    end

    if win_flag == true and fade_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, fade)

        fade_alpha = fade_alpha + 2
        lua_table.UI:ChangeUIComponentAlpha("Image", fade_alpha, fade)

        if fade_alpha == 256
        then
            fade_flag = true
        end
    end

    if fade_flag == true
    then
        if current_level == 1
        then
            if mm_flag == false
            then
                lua_table.GO:SetActiveGameObject(true, mainmenu)
                lua_table.GO:SetActiveGameObject(true, nextlevel)

                nl_alpha = nl_alpha + 4
                mm_alpha = mm_alpha + 4
                lua_table.UI:ChangeUIComponentAlpha("Image", nl_alpha, mainmenu)
                lua_table.UI:ChangeUIComponentAlpha("Image", mm_alpha, nextlevel)

                if nl_alpha == 256 and mm_alpha == 256
                then
                    mm_flag = true
                end
            end
        elseif current_level == 2
        then
            if mm_flag == false
            then
                lua_table.GO:SetActiveGameObject(true, only_mainmenu)

                omm_alpha = omm_alpha + 4
                lua_table.UI:ChangeUIComponentAlpha("Image", omm_alpha, only_mainmenu)

                if omm_alpha == 256
                then
                    mm_flag = true
                end
            end
        end
    end
end

local function Defeat()
    lua_table.System:PauseGame()
    
    if bg_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, background)

        bg_alpha = bg_alpha + 2
        lua_table.UI:ChangeUIComponentAlpha("Image", bg_alpha, background)

        if bg_alpha == 256
        then
            bg_flag = true
        end
    end

    if bg_flag == true and lose_flag == false
    then
        --defeat sound**

        lua_table.GO:SetActiveGameObject(true, lose)

        lose_alpha = lose_alpha + 4
        lua_table.UI:ChangeUIComponentAlpha("Image", lose_alpha, lose)

        if lose_alpha == 256
        then
            lose_flag = true
        end
    end

    if lose_flag == true and fade_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, fade)

        fade_alpha = fade_alpha + 2
        lua_table.UI:ChangeUIComponentAlpha("Image", fade_alpha, fade)

        if fade_alpha == 256
        then
            fade_flag = true
        end
    end

    ResetLevel()
end

local function ResetLevel()
    --set bools to false
    is_lose = false
    bg_flag = false
    lose_flag = false
    fade_flag = false

    --reset alphas
    bg_alpha = 0
    fade_alpha = 0
    lose_alpha = 0

    --set ui inactive
    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, lose)
    lua_table.GO:SetActiveGameObject(false, fade)

    --unpause game
    lua_table.System:ResumeGame()

    --load current level
    if current_level == 1
    then
        lua_table.Scene:LoadScene(lua_table.level1_uid);
    elseif current_level == 2
    then
        lua_table.Scene:LoadScene(lua_table.level2_uid);
    end
end

function lua_table:GoToMainMenu()
    --set bools to false
    is_win = false
    bg_flag = false
    win_flag = false
    fade_flag = false
    mm_flag = false

    --reset alphas
    bg_alpha = 0
    fade_alpha = 0
    win_alpha = 0
    mm_alpha = 0
    nl_alpha = 0
    omm_alpha = 0

    --set ui inactive
    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, win)
    lua_table.GO:SetActiveGameObject(false, fade)
    lua_table.GO:SetActiveGameObject(false, mainmenu)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)

    --unpause game
    lua_table.System:ResumeGame()

    --load main menu
    lua_table.Scene:LoadScene(lua_table.mm_uid)
end

function lua_table:GoToNextLevel()
    --set bools to false
    is_win = false
    bg_flag = false
    win_flag = false
    fade_flag = false
    mm_flag = false

    --reset alphas
    bg_alpha = 0
    fade_alpha = 0
    win_alpha = 0
    mm_alpha = 0
    nl_alpha = 0

    --set ui inactive
    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, win)
    lua_table.GO:SetActiveGameObject(false, fade)
    lua_table.GO:SetActiveGameObject(false, mainmenu)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)

    --unpause game
    lua_table.System:ResumeGame()

    --load next level (level 2)
    current_level = 2
    lua_table.Scene:LoadScene(lua_table.level2_uid);
end

local function GetCheckpointPos()
    -- define checkpoint positions**
    if last_checkpoint == nil or last_checkpoint == 0
    then
        geralt_x = 0
        geralt_y = 0
        geralt_z = 0

        jaskier_x = 0
        jaskier_y = 0
        jaskier_z = 0
    elseif last_checkpoint == 1
    then
        geralt_x = 0
        geralt_y = 0
        geralt_z = 0

        jaskier_x = 0
        jaskier_y = 0
        jaskier_z = 0
    end
end

local function Checkpoint()
    --get characters' respawn pos
    GetCheckpointPos()

    --Geralt Dead
    if geralt_script.current_state <= -4
    then
        --revive Geralt
        lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Geralt_Mesh"))
        lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Geralt_Pivot"))
        geralt_script:Start()
        lua_table.Physics:SetActiveController(true, Geralt)

        --set Geralt's pos in last checkpoint
        lua_table.Physics:SetCharacterPosition(geralt_x, geralt_y, geralt_z, Geralt)
    end

    --Jaskier Dead
    if jaskier_script.current_state <= -4
    then
        --revive Jaskier
        lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Jaskier_Mesh"))
        lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Jaskier_Pivot"))
        jaskier_script:Start()
        lua_table.Physics:SetActiveController(true, Jaskier)

        --set Jaskier's pos in last checkpoint
        lua_table.Physics:SetCharacterPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
    end
end

-------------------------------------------------
function lua_table:Awake()
    background = lua_table.GO:FindGameObject("Background")
    win = lua_table.GO:FindGameObject("Victory")
    lose = lua_table.GO:FindGameObject("Defeat")
    fade = lua_table.GO:FindGameObject("Fade")
    mainmenu = lua_table.GO:FindGameObject("MainMenu")
    nextlevel = lua_table.GO:FindGameObject("NextLevel")
    only_mainmenu = lua_table.GO:FindGameObject("OnlyMainMenu")

    Geralt = lua_table.GO:FindGameObject("Geralt")
    geralt_script = lua_table.GO:GetScript(Geralt)

    Jaskier = lua_table.GO:FindGameObject("Jaskier")
    jaskier_script = lua_table.GO:GetScript(Jaskier)
end

function lua_table:Start()
    --respawn on last checkpoint
    GetCheckpointPos()
    lua_table.Physics:SetCharacterPosition(geralt_x, geralt_y, geralt_z, Geralt)
    lua_table.Physics:SetCharacterPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)  
end

function lua_table:Update()
    -- DEBUG --
    if lua_table.Input:KeyRepeat("F1")
	then
		is_win = true
	elseif lua_table.Input:KeyRepeat("F2")
	then
		is_lose = true
	end
    -----------

    --win condition
    if current_level == 1 and is_win == false
    then
        --check if win**
        is_win = true
    elseif current_level == 2 and is_win == false
    then
        --check if kikimora is dead**
        is_win = true
    end

    --lose condition
    if geralt_script.current_state <= -3 and jaskier_script.current_state <= -3 and is_lose == false
    then
        is_lose = true
    end

    --check win/lose bools
    if is_win == true
    then
        Victory()
    elseif is_lose == true
    then
        Defeat()
    end
end

return lua_table
end