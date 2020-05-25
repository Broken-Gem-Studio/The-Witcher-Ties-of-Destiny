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
    
    local win_flag = false
    local lose_flag = false
    local fade_flag = false
    local fade_alpha = 0
    
    local function Victory()
        lua_table.System:PauseGame()
        
        --victory sound**
    
        lua_table.GO:SetActiveGameObject(true, win)
        if win_flag == false
        then
            --start animation**
            if lua_table.Input:KeyRepeat("F3") --finished**
            then
                win_flag = true
            end
        end

        if win_flag == true
        then
            lua_table.GO:SetActiveGameObject(true, fade)
            if fade_flag == false
            then
                fade_alpha = fade_alpha + 0.01
                lua_table.UI:ChangeUIComponentAlpha("Image", fade_alpha, fade)
        
                if fade_alpha >= 1.0
                then
                    fade_flag = true
                end
            end
        end
    
        if fade_flag == true
        then
            --if current_level == 1
            --then
                lua_table.GO:SetActiveGameObject(true, mainmenu)
                lua_table.GO:SetActiveGameObject(true, nextlevel)
            --elseif current_level == 2
            --then
            --    lua_table.GO:SetActiveGameObject(true, only_mainmenu)
            --end
        end
    end
    
    local function Defeat()
        lua_table.System:PauseGame()
    
        --defeat sound**
    
        lua_table.GO:SetActiveGameObject(true, lose)
        if lose_flag == false
        then
            --start animation**
            if lua_table.Input:KeyRepeat("F4") --finished**
            then
                lose_flag = true
            end
        end

        if lose_flag == true
        then
            lua_table.GO:SetActiveGameObject(true, fade)
            if fade_flag == false
            then
                fade_alpha = fade_alpha + 0.01
                lua_table.UI:ChangeUIComponentAlpha("Image", fade_alpha, fade)
        
                if fade_alpha >= 1.0
                then
                    fade_flag = true
                end
            end
        end
    
        if fade_flag == true
        then
            --reset variables
            is_lose = false
            lose_flag = false
            fade_flag = false
            fade_alpha = 0
        
            --set ui inactive
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
    end
    
    function lua_table:GoToMainMenu()
        --reset variables
        is_win = false
        win_flag = false
        fade_flag = false
        fade_alpha = 0
    
        --set ui inactive
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
        --reset variables
        is_win = false
        win_flag = false
        fade_flag = false
        fade_alpha = 0
    
        --set ui inactive
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
        win = lua_table.GO:FindGameObject("Victory")
        lose = lua_table.GO:FindGameObject("Defeat")
        fade = lua_table.GO:FindGameObject("Fade")
        mainmenu = lua_table.GO:FindGameObject("MainMenu")
        nextlevel = lua_table.GO:FindGameObject("NextLevel")
        only_mainmenu = lua_table.GO:FindGameObject("OnlyMainMenu")
        
        Geralt = lua_table.GO:FindGameObject("Geralt")
        --geralt_script = lua_table.GO:GetScript(Geralt)
        
        Jaskier = lua_table.GO:FindGameObject("Jaskier")
        --jaskier_script = lua_table.GO:GetScript(Jaskier)
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
    
        ----win condition
        --if current_level == 1 and is_win == false --and win condition**
        --then
        --    is_win = true
        --elseif current_level == 2 and is_win == false --and kikimora is dead**
        --then
        --    is_win = true
        --end
    
        ----lose condition
        --if geralt_script.current_state <= -3 and jaskier_script.current_state <= -3 and is_lose == false
        --then
        --    is_lose = true
        --end
    
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