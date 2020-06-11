function GetTableScriptCredits()
    local lua_table = {}
    lua_table.System = Scripting.System()
    lua_table.GO = Scripting.GameObject()
    lua_table.UI = Scripting.Interface()
    lua_table.Audio = Scripting.Audio()
    
    lua_table.delay = 1.0
    lua_table.fade_in = 0.1
    lua_table.fade_out = 0.05
    lua_table.wait = 2.0
    
    local animations = 0
    local art = 0
    local audio = 0
    local character_art = 0
    local cinematics = 0
    local engine = 0
    local environment = 0
    local ext_software_art = 0
    local ext_software_engine = 0
    local game_design = 0
    local gameplay = 0
    local marketing = 0
    local music = 0
    local producer = 0
    local programming = 0
    local qa = 0
    local special_thanks = 0
    local ui = 0
    local vfx = 0
    
    local flag0 = false
    local flag1 = false
    local flag2 = false
    local flag3 = false
    local flag4 = false
    local flag5 = false
    local flag6 = false
    local flag7 = false
    local flag8 = false
    local flag9 = false
    local flag10 = false
    local flag11 = false
    local flag12 = false
    local flag13 = false
    local flag14 = false
    local flag15 = false
    local flag16 = false
    local flag17 = false
    local flag18 = false
    
    local hordas = 0
    local hordas_script = 0
    
    local alpha = 0
    local alpha_flag = false
    local delay_flag = true
    local wait_flag = false
    
    local time = 0
    
    function lua_table:Awake()
        animations = lua_table.GO:FindGameObject("Animations")
        art = lua_table.GO:FindGameObject("Art")
        audio = lua_table.GO:FindGameObject("Audio")
        character_art = lua_table.GO:FindGameObject("CharacterArt")
        cinematics = lua_table.GO:FindGameObject("Cinematics")
        engine = lua_table.GO:FindGameObject("Engine")
        environment = lua_table.GO:FindGameObject("Environment")
        ext_software_art = lua_table.GO:FindGameObject("ExternalSoftwareArt")
        ext_software_engine = lua_table.GO:FindGameObject("ExternalSoftwareEngine")
        game_design = lua_table.GO:FindGameObject("GameDesign")
        gameplay = lua_table.GO:FindGameObject("Gameplay")
        marketing = lua_table.GO:FindGameObject("Marketing")
        music = lua_table.GO:FindGameObject("Music")
        producer = lua_table.GO:FindGameObject("Producer")
        programming = lua_table.GO:FindGameObject("Programming")
        qa = lua_table.GO:FindGameObject("QA")
        special_thanks = lua_table.GO:FindGameObject("SpecialThanks")
        ui = lua_table.GO:FindGameObject("UI")
        vfx = lua_table.GO:FindGameObject("VFX")
    
        hordas = lua_table.GO:FindGameObject("Hordas")
        if hordas > 0
        then
            hordas_script = lua_table.GO:GetScript(hordas)
        end
    end
    
    function lua_table:Start()
    end
    
    function lua_table:Update()
        time = time + lua_table.System:DT()
    
        if delay_flag == true
        then
            if time >= lua_table.delay
            then
                delay_flag = false
            end
        elseif wait_flag == true
        then
            if time >= lua_table.wait
            then
                wait_flag = false
            end
        else
            if flag0 == false
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, producer)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, producer)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag0 = true
                    end
                end
            elseif flag1 == false and flag0 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, programming)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, programming)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag1 = true
                    end
                end
            elseif flag2 == false and flag1 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, art)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, art)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag2 = true
                    end
                end
            elseif flag3 == false and flag2 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, game_design)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, game_design)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag3 = true
                    end
                end
            elseif flag4 == false and flag3 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, qa)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, qa)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag4 = true
                    end
                end
            elseif flag5 == false and flag4 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, gameplay)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, gameplay)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag5 = true
                    end
                end
            elseif flag6 == false and flag5 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, audio)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, audio)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag6 = true
                    end
                end
            elseif flag7 == false and flag6 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, vfx)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, vfx)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag7 = true
                    end
                end
            elseif flag8 == false and flag7 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, ui)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, ui)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag8 = true
                    end
                end
            elseif flag9 == false and flag8 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, character_art)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, character_art)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag9 = true
                    end
                end
            elseif flag10 == false and flag9 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, animations)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, animations)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag10 = true
                    end
                end
            elseif flag11 == false and flag10 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, cinematics)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, cinematics)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag11 = true
                    end
                end
            elseif flag12 == false and flag11 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, environment)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, environment)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag12 = true
                    end
                end
            elseif flag13 == false and flag12 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, engine)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, engine)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag13 = true
                    end
                end
            elseif flag14 == false and flag13 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, marketing)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, marketing)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag14 = true
                    end
                end
            elseif flag15 == false and flag14 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, ext_software_engine)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, ext_software_engine)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag15 = true
                    end
                end
            elseif flag16 == false and flag15 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, ext_software_art)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, ext_software_art)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag16 = true
                    end
                end
            elseif flag17 == false and flag16 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, music)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, music)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag17 = true
                    end
                end
            elseif flag18 == false and flag17 == true
            then
                --fade in
                if alpha_flag == false
                then
                    alpha = alpha + lua_table.fade_in
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, special_thanks)
    
                    if alpha >= 1.0
                    then
                        alpha_flag = true
                        wait_flag = true
                        time = 0
                    end
                else
                    --fade out
                    alpha = alpha - lua_table.fade_out
                    lua_table.UI:ChangeUIComponentAlpha("Image", alpha, special_thanks)
    
                    if alpha <= 0.0
                    then
                        alpha = 0.0
                        alpha_flag = false
                        delay_flag = true
                        time = 0
                        flag18 = true
                    end
                end
            end
        end
    end
        
    return lua_table
    end