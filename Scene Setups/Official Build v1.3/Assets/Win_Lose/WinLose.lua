function GetTableWinLose()
    local lua_table = {}
    lua_table.System = Scripting.System()
    lua_table.GO = Scripting.GameObject()
    lua_table.Transform = Scripting.Transform()
    lua_table.UI = Scripting.Interface()
    lua_table.Input = Scripting.Inputs()
    lua_table.Scene = Scripting.Scenes()
    lua_table.Physics = Scripting.Physics()
    lua_table.Audio = Scripting.Audio()

    lua_table.level1_uid = 0
    lua_table.level2_uid = 0
    lua_table.mm_uid = 0
    lua_table.score = 0

    lua_table.current_level = 0
    lua_table.played_music = false

    local pos = 0
    local winlose = 0
    local music_manager_UID = 0 --We need this UID in order to stop the music!

    local geralt_pos0 = 0
    local geralt_pos1 = 0
    local geralt_pos2 = 0

    local jaskier_pos0 = 0
    local jaskier_pos1 = 0
    local jaskier_pos2 = 0

    local fade = 0
    local win = 0
    local lose = 0
    local background = 0

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

    local Kikimora = 0
    local kikimora_script = 0

    local FinalEnemy = 0
    local finalenemy_script = 0

    local is_win = false
    local is_lose = false

    local win_flag = false
    local lose_flag = false
    local fade_flag = false
    local fade_alpha = 0

    local tp_geralt = false
    local tp_jaskier = false

    local load_level1 = false
    local load_level2 = false
    local load_mainmenu = false
    local load_score = false

    local play_win = false
    local play_lose = false

    local loading_UID = 0
    local load_timer = 0

    local tutorialGO = 0
    local cartasGO = 0

    local function Victory()
        lua_table.System:PauseGame()

        --victory sound
        if lua_table.played_music == false and lua_table.music_manager_script ~= nil then
            lua_table.music_manager_script:StopMusic()
            lua_table.Audio:PlayAudioEventGO("Play_Win_Menu_Music", winlose)
            lua_table.Audio:SetVolume(0.3, winlose)
            lua_table.played_music = true
        end

        --win animation
        lua_table.GO:SetActiveGameObject(true, win)
        if win_flag == false
        then
            if play_win == true
            then
                play_win = false
                lua_table.UI:PlayUIAnimation(win)
            end

            if lua_table.UI:UIAnimationFinished(win) == true
            then
                play_win = true
                win_flag = true
            end
        end

        --fade
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

        --reset variables
        if fade_flag == true
        then
            is_win = false
            win_flag = false
            fade_flag = false
            fade_alpha = 0

            --unpause game
            lua_table.System:ResumeGame()

            load_score = true
        end
    end

    local function Defeat()
        lua_table.System:PauseGame()

        --defeat sound
        if lua_table.played_music == false and lua_table.music_manager_script ~= nil then
            lua_table.music_manager_script:StopMusic()
            lua_table.Audio:PlayAudioEventGO("Play_Lost_Menu_Music", winlose)
            lua_table.Audio:SetVolume(0.3, winlose)
            lua_table.played_music = true
        end

        --lose animation
        lua_table.GO:SetActiveGameObject(true, lose)
        if lose_flag == false
        then
            if play_lose == true
            then
                play_lose = false
                lua_table.UI:PlayUIAnimation(lose)
            end

            if lua_table.UI:UIAnimationFinished(lose) == true
            then
                play_lose = true
                lose_flag = true
            end
        end

        --fade
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

        --reset level
        if fade_flag == true
        then
            --set score to 0
            if geralt_score ~= nil then
                for i = 1, #geralt_score do
                    geralt_score[i] = 0
                end
            end
            if jaskier_score ~= nil then
                for i = 1, #jaskier_score do
                    jaskier_score[i] = 0
                end
            end

            --reset variables
            lose_flag = false
            fade_flag = false
            fade_alpha = 0

            --set ui inactive
            lua_table.GO:SetActiveGameObject(false, lose)
            lua_table.GO:SetActiveGameObject(false, fade)

            --unpause game
            lua_table.System:ResumeGame()

            --load current level
            if lua_table.current_level == 1
            then
                load_level1 = true
            elseif lua_table.current_level == 2
            then
                load_level2 = true
            end
        end
    end

    local function GetCheckpointPos()
        if last_checkpoint == nil or last_checkpoint == 0
        then
            pos = lua_table.Transform:GetPosition(geralt_pos0)
            geralt_x = pos[1]
            geralt_y = pos[2]
            geralt_z = pos[3]

            pos = lua_table.Transform:GetPosition(jaskier_pos0)
            jaskier_x = pos[1]
            jaskier_y = pos[2]
            jaskier_z = pos[3]
        elseif last_checkpoint == 1
        then
            pos = lua_table.Transform:GetPosition(geralt_pos1)
            geralt_x = pos[1]
            geralt_y = pos[2]
            geralt_z = pos[3]

            pos = lua_table.Transform:GetPosition(jaskier_pos1)
            jaskier_x = pos[1]
            jaskier_y = pos[2]
            jaskier_z = pos[3]
        elseif last_checkpoint == 2
        then
            pos = lua_table.Transform:GetPosition(geralt_pos2)
            geralt_x = pos[1]
            geralt_y = pos[2]
            geralt_z = pos[3]

            pos = lua_table.Transform:GetPosition(jaskier_pos2)
            jaskier_x = pos[1]
            jaskier_y = pos[2]
            jaskier_z = pos[3]
        end
    end

    function lua_table:Checkpoint()
        --get characters' respawn pos
        GetCheckpointPos()

        --Geralt Dead
        if geralt_script.current_state <= -4
        then
            lua_table.Physics:SetActiveController(true, Geralt)
            lua_table.Physics:SetCharacterPosition(geralt_x, geralt_y, geralt_z, Geralt)
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Geralt_Mesh"))
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Geralt_Pivot"))
            geralt_script:Resurrect()
        else
            geralt_script.current_health = 200
            if tp_geralt == true
            then
                lua_table.Physics:SetCharacterPosition(geralt_x, geralt_y, geralt_z, Geralt)
                tp_geralt = false
            end
        end

        --Jaskier Dead
        if jaskier_script.current_state <= -4
        then
            lua_table.Physics:SetActiveController(true, Jaskier)
            lua_table.Physics:SetCharacterPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Jaskier_Mesh"))
            lua_table.GO:SetActiveGameObject(true, lua_table.GO:FindGameObject("Jaskier_Pivot"))
            jaskier_script:Resurrect()
        else
            jaskier_script.current_health = 200
            if tp_jaskier == true
            then
                lua_table.Physics:SetCharacterPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
                tp_jaskier = false
            end
        end
    end

    -------------------------------------------------
    function lua_table:Awake()
        winlose = lua_table.GO:GetMyUID()
        music_manager_UID = lua_table.GO:FindGameObject("Music_Manager")
        if music_manager_UID ~= 0 then
            lua_table.music_manager_script = lua_table.GO:GetScript(music_manager_UID)
        end
        tutorialGO = lua_table.GO:FindGameObject("TutorialManager")
        cartasGO = lua_table.GO:FindGameObject("CARTAS")

        --UI
        win = lua_table.GO:FindGameObject("Victory")
        lose = lua_table.GO:FindGameObject("Defeat")
        fade = lua_table.GO:FindGameObject("Fade")

        --Geralt
        Geralt = lua_table.GO:FindGameObject("Geralt")
        if Geralt > 0
        then
            geralt_script = lua_table.GO:GetScript(Geralt)
        end

        --Jaskier
        Jaskier = lua_table.GO:FindGameObject("Jaskier")
        if Jaskier > 0
        then
            jaskier_script = lua_table.GO:GetScript(Jaskier)
        end

        --Win Condition
        if lua_table.current_level == 1
        then
            FinalEnemy = lua_table.GO:FindGameObject("FinalEnemy")
            if FinalEnemy > 0
            then
                finalenemy_script = lua_table.GO:GetScript(FinalEnemy)
            end
        elseif lua_table.current_level == 2
        then
            Kikimora = lua_table.GO:FindGameObject("Kikimora")
            if Kikimora > 0
            then
                kikimora_script = lua_table.GO:GetScript(Kikimora)
            end
        end

        --Respawn Pos
        geralt_pos0 = lua_table.GO:FindGameObject("GeraltPos0")
        geralt_pos1 = lua_table.GO:FindGameObject("GeraltPos1")
        geralt_pos2 = lua_table.GO:FindGameObject("GeraltPos2")

        jaskier_pos0 = lua_table.GO:FindGameObject("JaskierPos0")
        jaskier_pos1 = lua_table.GO:FindGameObject("JaskierPos1")
        jaskier_pos2 = lua_table.GO:FindGameObject("JaskierPos2")

        --Set elements inactive
        lua_table.GO:SetActiveGameObject(false, lose)
        lua_table.GO:SetActiveGameObject(false, win)
        lua_table.GO:SetActiveGameObject(false, fade)
        lua_table.GO:SetActiveGameObject(false, background)
        
        loading_UID = lua_table.GO:FindGameObject("LoadingScreenCanvas")
    end

    function lua_table:Start()
        --respawn on last checkpoint
        GetCheckpointPos()
        lua_table.Physics:SetActiveController(true, Geralt)
        lua_table.Physics:SetActiveController(true, Jaskier)
        lua_table.Physics:SetCharacterPosition(geralt_x, geralt_y, geralt_z, Geralt)
        lua_table.Physics:SetCharacterPosition(jaskier_x, jaskier_y, jaskier_z, Jaskier)
    end

    function lua_table:Update()
        -- DEBUG --
        if lua_table.Input:KeyRepeat("F1") --win
        then
            is_win = true
        elseif lua_table.Input:KeyRepeat("F2") --lose
        then
            is_lose = true
        elseif lua_table.Input:KeyRepeat("F3") --level1
        then
            load_level1 = true
        elseif lua_table.Input:KeyRepeat("F4") --level2
        then
            load_level2 = true
        elseif lua_table.Input:KeyRepeat("F5") --checkpoint0
        then
            if tutorialGO ~= nil and tutorialGO ~= 0 then
                lua_table.GO:SetActiveGameObject(false, tutorialGO)
                lua_table.GO:SetActiveGameObject(false, cartasGO)
            end
            last_checkpoint = 0
            tp_geralt = true
            tp_jaskier = true
            lua_table.Checkpoint()
        elseif lua_table.Input:KeyRepeat("F6") --checkpoint1
        then
            if tutorialGO ~= nil and tutorialGO ~= 0 then
                lua_table.GO:SetActiveGameObject(false, tutorialGO)
                lua_table.GO:SetActiveGameObject(false, cartasGO)
            end
            last_checkpoint = 1
            tp_geralt = true
            tp_jaskier = true
            lua_table.Checkpoint()
        elseif lua_table.Input:KeyRepeat("F7") --checkpoint2
        then
            if tutorialGO ~= nil and tutorialGO ~= 0 then
                lua_table.GO:SetActiveGameObject(false, tutorialGO)
                lua_table.GO:SetActiveGameObject(false, cartasGO)
            end
            last_checkpoint = 2
            tp_geralt = true
            tp_jaskier = true
            lua_table.Checkpoint()
        end
        -----------

        --check win/lose bools
        if is_win == true
        then
            Victory()
        elseif is_lose == true
        then
            Defeat()
        end

        --win condition
        if lua_table.current_level == 1 and win_level1 ~= nil and win_level1 == true and is_win == false
        then
            is_win = true
            win_level1 = false
        elseif lua_table.current_level == 2 and Kikimora > 0 and kikimora_script.dead == true and is_win == false
        then
            is_win = true
        end

        --lose condition
        if Geralt > 0 and Jaskier > 0 and geralt_script.current_state <= -3 and jaskier_script.current_state <= -3 and is_lose == false
        then
            is_lose = true
        end

        --change scene
        if load_level1 == true
        then
            load_timer = load_timer + lua_table.System:DT()
            is_lose = false
            if load_timer >= 1 
            then
                load_level1 = false
                lua_table.Scene:LoadScene(lua_table.level1_uid)
            else 
                lua_table.GO:SetActiveGameObject(true, loading_UID)
            end 
        elseif load_level2 == true 
        then
            load_timer = load_timer + lua_table.System:DT()
            is_lose = false
            if load_timer >= 1 
            then
                load_level2 = false
                lua_table.Scene:LoadScene(lua_table.level2_uid)
            else 
                lua_table.GO:SetActiveGameObject(true, loading_UID)
            end
        elseif load_score == true
        then
            load_timer = load_timer + lua_table.System:DT()
            is_win = false
            if load_timer >= 1 
            then
                if lua_table.current_level == 1
                then
                    current_scene_score = 1
                elseif lua_table.current_level == 2
                then
                    current_scene_score = 2
                end
                last_checkpoint = 0
                lua_table.Scene:LoadScene(lua_table.score)
            else 
                lua_table.GO:SetActiveGameObject(true, loading_UID)
            end
        end
    end

    return lua_table
    end
