function GetTableLogoIntro_Behaviour()
local lua_table = {}

lua_table.SystemFunctions = Scripting.System()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.Scenes = Scripting.Scenes()

local dt = 0
local LogoIntroFinished = false
local PoweredbyFinished = false
local CounterStartAnimation = 0
local StartedLogoIntroAnimation = false 
local CounterTimeBetweenLogos = 0
local LogoPoweredbyFinished = false
local CounterAppearingLoadingPage = 0
local CounterInitialBlackBackgroundVanish = 0

lua_table.MainMenuScene = 0

lua_table.BlackBackgroundUID = 0
lua_table.BlackBacgroundandLoadingAlpha = 0
lua_table.LoadingTextureUID = 0
lua_table.LoadingPageAppearingTime = 2
lua_table.IntialBlackBackgroundVanish = 2

lua_table.TimeBetweenLogos = 1
lua_table.LogoIntroUID = 0
lua_table.VanishTime = 1
lua_table.VanishSpeed = 1
lua_table.LogoIntroAlpha = 1
lua_table.LogoCounter = 0
lua_table.StartAnimationLogoIntro = 1

lua_table.WolfUID = 0
lua_table.WolfAlpha = 0

lua_table.PoweredByUID = 0
lua_table.PoweredbyAlpha = 0
lua_table.CounterPoweredAppearing = 0
lua_table.CounterPoweredIdle = 0
lua_table.CounterPoweredGone = 0
lua_table.PoweredTimeAppear = 1
lua_table.PoweredTimeIdle = 2
lua_table.PoweredTimeGone = 1
--## Functions ##--

local function ChangeAlpha(uID,alpha)
    
    if(uID ~= 0 )
    then      
        lua_table.InterfaceFunctions:ChangeUIComponentAlpha("Image",alpha,uID)
    else
        lua_table.SystemFunctions:LOG("Error uID is 0")
    end

end

--## Code ## --

function lua_table:Awake()

    lua_table.LogoIntroUID = lua_table.ObjectFunctions:FindGameObject("LogoIntro")
    lua_table.PoweredByUID = lua_table.ObjectFunctions:FindGameObject("PoweredBy")
    lua_table.LoadingTextureUID = lua_table.ObjectFunctions:FindGameObject("Loading")
    lua_table.BlackBackgroundUID = lua_table.ObjectFunctions:FindGameObject("BlackBackground")
    lua_table.WolfUID = lua_table.ObjectFunctions:FindGameObject("Wolf")

end

function lua_table:Start()

    ChangeAlpha(lua_table.PoweredByUID,lua_table.PoweredbyAlpha)
    ChangeAlpha(lua_table.LoadingTextureUID,lua_table.BlackBacgroundandLoadingAlpha)
    lua_table.BlackBacgroundandLoadingAlpha = 1
    ChangeAlpha(lua_table.BlackBackgroundUID,lua_table.BlackBacgroundandLoadingAlpha)


end

function lua_table:Update()

    dt = lua_table.SystemFunctions:DT()
    -- Wait x Seconds to start Animation

    if CounterInitialBlackBackgroundVanish <= lua_table.IntialBlackBackgroundVanish
    then
        CounterInitialBlackBackgroundVanish = CounterInitialBlackBackgroundVanish + dt
        local TempAlpha = CounterInitialBlackBackgroundVanish/lua_table.IntialBlackBackgroundVanish
        lua_table.BlackBacgroundandLoadingAlpha = 1 - TempAlpha
        ChangeAlpha(lua_table.BlackBackgroundUID,lua_table.BlackBacgroundandLoadingAlpha)
    end


    if CounterStartAnimation >= lua_table.StartAnimationLogoIntro and StartedLogoIntroAnimation == false
    then
        lua_table.InterfaceFunctions:PlayUIAnimation(lua_table.LogoIntroUID)   
        lua_table.SystemFunctions:LOG("Starting Logo Intro")
        StartedLogoIntroAnimation = true
    else
        CounterStartAnimation = CounterStartAnimation + dt
    end

    -- Logo Behaviour --
    if lua_table.InterfaceFunctions:UIAnimationFinished(lua_table.LogoIntroUID) == true and LogoIntroFinished == false and StartedLogoIntroAnimation == true
    then 
        lua_table.LogoCounter = lua_table.LogoCounter + dt
        if lua_table.LogoCounter > lua_table.VanishTime
        then 
            if lua_table.LogoIntroAlpha > 0
            then
                --lua_table.LogoIntroAlpha = lua_table.InterfaceFunctions:GetUIComponentAlpha("Image",lua_table.LogoIntroUID)
                lua_table.LogoIntroAlpha = lua_table.LogoIntroAlpha - lua_table.VanishSpeed*dt
                
                ChangeAlpha(lua_table.LogoIntroUID,lua_table.LogoIntroAlpha)
            else
                LogoIntroFinished = true
            end
        end 
    end

    -- Poweredby Behaviour--
    if LogoIntroFinished 
    then
        CounterTimeBetweenLogos = CounterTimeBetweenLogos+dt
    end

    if LogoIntroFinished == true and CounterTimeBetweenLogos >= lua_table.TimeBetweenLogos and PoweredbyFinished==false
    then
        lua_table.CounterPoweredAppearing = lua_table.CounterPoweredAppearing + dt
        
        if lua_table.CounterPoweredAppearing <= lua_table.PoweredTimeAppear
        then
            lua_table.PoweredbyAlpha = lua_table.CounterPoweredAppearing/lua_table.PoweredTimeAppear
            ChangeAlpha(lua_table.PoweredByUID,lua_table.PoweredbyAlpha)
        else
            lua_table.CounterPoweredIdle = lua_table.CounterPoweredIdle + dt
            
            if lua_table.CounterPoweredIdle >= lua_table.PoweredTimeIdle
            then
                lua_table.CounterPoweredGone = lua_table.CounterPoweredGone+dt
                local TempAlpha = lua_table.CounterPoweredGone/lua_table.PoweredTimeGone
                lua_table.PoweredbyAlpha = 1 - TempAlpha
                ChangeAlpha(lua_table.PoweredByUID,lua_table.PoweredbyAlpha)
                
                if lua_table.PoweredbyAlpha <= 0
                then
                    PoweredbyFinished = true
                end
            end
        end   
    end

    if PoweredbyFinished == true
    then
        CounterAppearingLoadingPage = CounterAppearingLoadingPage + dt
        lua_table.BlackBacgroundandLoadingAlpha = CounterAppearingLoadingPage/lua_table.LoadingPageAppearingTime
        lua_table.WolfAlpha = lua_table.BlackBacgroundandLoadingAlpha*0.25;
        ChangeAlpha(lua_table.BlackBackgroundUID,lua_table.BlackBacgroundandLoadingAlpha)
        ChangeAlpha(lua_table.LoadingTextureUID,lua_table.BlackBacgroundandLoadingAlpha)
        ChangeAlpha(lua_table.WolfUID,lua_table.WolfAlpha)
        if lua_table.BlackBacgroundandLoadingAlpha >= 1
        then
            lua_table.SystemFunctions:LOG("LOADING MainMenu")
            lua_table.Scenes:LoadScene(lua_table.MainMenuScene)
        end
    end

end

return lua_table
end

