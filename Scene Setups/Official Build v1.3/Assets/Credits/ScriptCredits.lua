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
    
    local HUD_IMAGES = {}
    lua_table.HUD_LIBRARY = {
        Producer = 1,
        Programming = 2,
        Engine = 3,
        Audio = 4,
        Art = 5,
        CharacterArt = 6,
        Animations = 7,
        UI = 8,
        Cinematics = 9,
        GameDesign = 10,
        Gameplay = 11,
        Environment = 12,
        VFX = 13,
        QA = 14,
        Marketing = 15,
        ExternalSoftwareArt = 16,
        ExternalSoftwareEngine = 17,
        Music = 18,
        SpecialThanks = 19
    }

    lua_table.states = { 
        FADE_IN = 1,
        NORMAL = 2,
        FADE_OUT = 3
    }

    local current_HUD = lua_table.HUD_LIBRARY.Producer
    local to_HUD = 0
    local current_state = lua_table.states.FADE_IN
    
    local alpha = 0
    local time = 0
    local index = 0
    lua_table.finished = false

    local my_UID = 0
    
    function lua_table:Awake()
        HUD_IMAGES[lua_table.HUD_LIBRARY.Animations] = lua_table.GO:FindGameObject("Animations")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Art] = lua_table.GO:FindGameObject("Art")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Audio] = lua_table.GO:FindGameObject("Audio")
        HUD_IMAGES[lua_table.HUD_LIBRARY.CharacterArt] = lua_table.GO:FindGameObject("CharacterArt")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Cinematics] = lua_table.GO:FindGameObject("Cinematics")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Engine] = lua_table.GO:FindGameObject("Engine")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Environment] = lua_table.GO:FindGameObject("Environment")
        HUD_IMAGES[lua_table.HUD_LIBRARY.ExternalSoftwareArt] = lua_table.GO:FindGameObject("ExternalSoftwareArt")
        HUD_IMAGES[lua_table.HUD_LIBRARY.ExternalSoftwareEngine] = lua_table.GO:FindGameObject("ExternalSoftwareEngine")
        HUD_IMAGES[lua_table.HUD_LIBRARY.GameDesign] = lua_table.GO:FindGameObject("GameDesign")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Gameplay] = lua_table.GO:FindGameObject("Gameplay")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Marketing] = lua_table.GO:FindGameObject("Marketing")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Music] = lua_table.GO:FindGameObject("Music")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Producer] = lua_table.GO:FindGameObject("Producer")
        HUD_IMAGES[lua_table.HUD_LIBRARY.Programming] = lua_table.GO:FindGameObject("Programming")
        HUD_IMAGES[lua_table.HUD_LIBRARY.QA] = lua_table.GO:FindGameObject("QA")
        HUD_IMAGES[lua_table.HUD_LIBRARY.SpecialThanks] = lua_table.GO:FindGameObject("SpecialThanks")
        HUD_IMAGES[lua_table.HUD_LIBRARY.UI] = lua_table.GO:FindGameObject("UI")
        HUD_IMAGES[lua_table.HUD_LIBRARY.VFX] = lua_table.GO:FindGameObject("VFX")

        my_UID = lua_table.GO:GetMyUID()
    end
    
    function lua_table:Start()
        lua_table.Audio:PlayAudioEvent("Play_Level_2_Music")

        lua_table.Audio:SetAudioSwitch("Lvl_2_Music_Switch","Combat",my_UID)
        lua_table.Audio:SetVolume(0.3,my_UID)
    end

    function lua_table:showImage()
        if current_state == lua_table.states.FADE_IN then
            index = index + 1
            current_HUD = index
            show_flag = true
        end
    end
    
    function lua_table:Update()
    
        if show_flag == true and lua_table.finished == false
        then
            if current_state == lua_table.states.FADE_IN then
                lua_table.System:LOG("FADE IN")
                alpha = alpha + lua_table.fade_in
                lua_table.UI:ChangeUIComponentAlpha("Image", alpha, HUD_IMAGES[current_HUD])
    
                if alpha >= 1.0
                then
                    current_state = lua_table.states.NORMAL
                end
            elseif current_state == lua_table.states.NORMAL then
                lua_table.System:LOG("NORMAL")
                time = time + lua_table.System:DT()
                if time >= lua_table.wait
                then
                    current_state = lua_table.states.FADE_OUT
                    time = 0
                end
            elseif current_state == lua_table.states.FADE_OUT then
                lua_table.System:LOG("FADE OUT")
                alpha = alpha - lua_table.fade_out
                lua_table.UI:ChangeUIComponentAlpha("Image", alpha, HUD_IMAGES[current_HUD])
    
                if alpha <= 0.0
                then
                    if current_HUD > 19 then
                        lua_table.finished = true
                    else
                        current_state = lua_table.states.FADE_IN
                        --show_flag = false
                        index = index + 1
                        current_HUD = index
                    end
                end
            end
        end
    end
        
    return lua_table
    end