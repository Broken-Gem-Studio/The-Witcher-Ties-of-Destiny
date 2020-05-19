function GetTableWinLose()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.UI = Scripting.Interface()
lua_table.Input = Scripting.Inputs()

local background = 0
local fade = 0
local win = 0
local lose = 0
local mainmenu = 0
local nextlevel = 0
local only_mainmenu = 0

local checkpoint = 0

local Geralt = 0
local geralt_x = 0
local geralt_y = 0
local geralt_z = 0

local Jaskier = 0
local jaskier_x = 0
local jaskier_y = 0
local jaskier_z = 0

local is_win = false
local is_lose = false
local is_level1 = true

local bg_flag = false
local win_flag = false
local lose_flag = false
local fade_flag = false
local mm_flag = false

local function Victory()
    lua_table.System:PauseGame()
        
    if bg_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, background)

        --bg_alpha += 2
        if bg_alpha == 256
        then
            bg_flag = true
        end
    end

    if bg_flag == true and win_flag == false
    then
        --victory sound
        lua_table.GO:SetActiveGameObject(true, win)

        --win_alpha += 4
        if win_alpha == 256
        then
            win_flag = true
        end
    end

    if win_flag == true and fade_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, fade)

        --fade_alpha += 2
        if fade_alpha == 256
        then
            fade_flag = true
        end
    end

    if fade_flag == true
    then
        if is_level1 == true
        then
            if mm_flag == false
            then
                lua_table.GO:SetActiveGameObject(true, mainmenu)
                lua_table.GO:SetActiveGameObject(true, nextlevel)

                --nl_alpha += 4
                --mm_alpha += 4
                if nl_alpha == 256 and mm_alpha == 256
                then
                    mm_flag = true
                end
            end
        elseif is_level1 == false
        then
            if mm_flag == false
            then
                lua_table.GO:SetActiveGameObject(true, only_mainmenu)

                --omm_alpha += 4
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
    --black and white
    
    if bg_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, background)

        --alpha += 2
        if bg_alpha == 256
        then
            bg_flag = true
        end
    end

    if bg_flag == true and lose_flag == false
    then
        --defeat sound
        lua_table.GO:SetActiveGameObject(true, lose)

        --alpha += 4
        if lose_alpha == 256
        then
            lose_flag = true
        end
    end

    if lose_flag == true and fade_flag == false
    then
        lua_table.GO:SetActiveGameObject(true, fade)

        --alpha += 2
        if fade_alpha == 256
        then
            fade_flag = true
        end
    end
 
    is_lose = false
    bg_flag = false
    lose_flag = false
    fade_flag = false
    
    ResetLevel()
end

local function ResetLevel()
    --reset activated entities (including Geralt and Jaskier)

    if checkpoint == 0
    then
        geralt_x = 0
        geralt_y = 0
        geralt_z = 0
        lua_table.Transform:SetPosition(geralt_x, geralt_y, geralt_z, Geralt)

        jaskier_x = 0
        jaskier_y = 0
        jaskier_z = 0
        lua_table.Transform:SetPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
    elseif checkpoint == 1
    then
        geralt_x = 0
        geralt_y = 0
        geralt_z = 0
        lua_table.Transform:SetPosition(geralt_x, geralt_y, geralt_z, Geralt)

        jaskier_x = 0
        jaskier_y = 0
        jaskier_z = 0
        lua_table.Transform:SetPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
    end

    --reset alphas
    
    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, lose)
    lua_table.GO:SetActiveGameObject(false, fade)

   --reset normal color
   lua_table.System:ResumeGame()
end

function lua_table:GoToMainMenu()
    is_win = false
    bg_flag = false
    win_flag = false
    fade_flag = false
    mm_flag = false

    --reset alphas

    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, win)
    lua_table.GO:SetActiveGameObject(false, fade)
    lua_table.GO:SetActiveGameObject(false, mainmenu)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)

    lua_table.System:ResumeGame()
    --load main menu
end

function lua_table:GoToNextLevel()
    is_win = false
    bg_flag = false
    win_flag = false
    fade_flag = false
    mm_flag = false

    --reset alphas

    lua_table.GO:SetActiveGameObject(false, background)
    lua_table.GO:SetActiveGameObject(false, win)
    lua_table.GO:SetActiveGameObject(false, fade)
    lua_table.GO:SetActiveGameObject(false, mainmenu)
    lua_table.GO:SetActiveGameObject(false, nextlevel)
    lua_table.GO:SetActiveGameObject(false, only_mainmenu)

    lua_table.System:ResumeGame()
    --load next level
end

function lua_table:Awake()
    background = lua_table.GO:FindGameObject("Background")
    win = lua_table.GO:FindGameObject("Victory")
    lose = lua_table.GO:FindGameObject("Defeat")
    fade = lua_table.GO:FindGameObject("Fade")
    mainmenu = lua_table.GO:FindGameObject("MainMenu")
    nextlevel = lua_table.GO:FindGameObject("NextLevel")
    only_mainmenu = lua_table.GO:FindGameObject("OnlyMainMenu")

    Geralt = lua_table.GO:FindGameObject("Geralt")
    Jaskier = lua_table.GO:FindGameObject("Jaskier")
end

function lua_table:Start()
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

    --check if win
    --check if lose

    if is_win == true
    then
        Victory()
    elseif is_lose == true
    then
        Defeat()
    end

    --if level 1
    --then
        --is_level1 = true
    --else
    --then
        --is_level1 = false
    --end
end

return lua_table
end