function GetTabledoorEndTutorial()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.Audio = Scripting.Audio()

lua_table.door_unlocked = false

local my_UID = 0

local recruiterGO = 0
local archerGO = 0
local tutorialGO = 0
local tutorialScript = 0
local doorGO = 0
local doorCollider = 0
local doorOpened = false
local firstEnemy = false 
local spawnerGO = 0

function lua_table:Awake()
    tutorialGO = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
    tutorialScript = lua_table.ObjectFunctions:GetScript(tutorialGO)
    doorGO = lua_table.ObjectFunctions:FindGameObject("Door_3")
    doorCollider = lua_table.ObjectFunctions:FindGameObject("colliderDoor3")
    spawnerGO = lua_table.ObjectFunctions:FindGameObject("CityLevelSpawners2_audio")    
    my_UID = lua_table.ObjectFunctions:GetMyUID()
end

function lua_table:Start()
    lua_table.ObjectFunctions:SetActiveGameObject(false, spawnerGO)
end

function lua_table:Update()
    
    recruiterGO = lua_table.ObjectFunctions:FindGameObject("Recruit_Bandit")
    archerGO = lua_table.ObjectFunctions:FindGameObject("Archer")

    if tutorialScript.currentStep == 0 and doorOpened == false
    then

        if recruiterGO == 0 and archerGO == 0 and firstEnemy == true
        then
            lua_table.AnimationFunctions:PlayAnimation("open", 30, doorGO)
            lua_table.Audio:PlayAudioEventGO("Play_Door_new_sound", my_UID)
            
            --Door unlocked, this bool serves for other scripts
            lua_table.door_unlocked = true

            lua_table.ObjectFunctions:SetActiveGameObject(false, doorCollider)
            lua_table.ObjectFunctions:SetActiveGameObject(true, spawnerGO)
            doorOpened = true
        end

        if firstEnemy == false
        then
            if recruiterGO ~= 0 or archerGO ~= 0
            then 
                firstEnemy = true
            end
        end
    end
end

return lua_table
end