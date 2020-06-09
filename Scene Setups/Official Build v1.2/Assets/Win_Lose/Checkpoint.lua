function GetTableCheckpoint()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics = Scripting.Physics()
lua_table.Audio = Scripting.Audio()

local uid = 0
local winlose = 0
local winlose_script = 0

lua_table.checkpoint = 0

local bonfire_1 = 0
local bonfire_2 = 0
local bonfire1_particles = {}
local bonfire2_particles = {}

local spawner1 = 0
local spawner2 = 0
local spawner3 = 0
local spawner4 = 0

function lua_table:OnTriggerEnter()
    local collider = lua_table.Physics:OnTriggerEnter(uid)

    if lua_table.GO:GetLayerByID(collider) == 1
    then
        if last_checkpoint == nil or last_checkpoint < lua_table.checkpoint
        then
            --audio
            lua_table.Audio:PlayAudioEventGO("Play_Reach_firecamp", uid)
            lua_table.System:LOG("Audio checkpoint")

            --particles
            if lua_table.checkpoint == 1
            then
                lua_table.GO:SetActiveGameObject(true, bonfire1_particles[2])
                lua_table.GO:SetActiveGameObject(false, bonfire1_particles[1])

                --deactivate spawners on forest level
                if winlose_script.current_level == 2
                then
                    lua_table.GO:SetActiveGameObject(false, spawner1)
                    lua_table.GO:SetActiveGameObject(false, spawner2)
                end

            elseif lua_table.checkpoint == 2
            then
                lua_table.GO:SetActiveGameObject(true, bonfire2_particles[2])
                lua_table.GO:SetActiveGameObject(false, bonfire2_particles[1])

                --deactivate spawners on forest level
                if winlose_script.current_level == 2
                then
                    lua_table.GO:SetActiveGameObject(false, spawner1)
                    lua_table.GO:SetActiveGameObject(false, spawner2)
                    lua_table.GO:SetActiveGameObject(false, spawner3)
                    lua_table.GO:SetActiveGameObject(false, spawner4)
                end
            end

            --checkpoint
            last_checkpoint = lua_table.checkpoint
            winlose_script:Checkpoint()
        end
    end
end

function lua_table:Awake()
    uid = lua_table.GO:GetMyUID()
    winlose = lua_table.GO:FindGameObject("WinLose")
    bonfire_1 = lua_table.GO:FindGameObject("Bonefire1")
    bonfire_2 = lua_table.GO:FindGameObject("Bonefire2")
    bonfire1_particles[1] = lua_table.GO:FindChildGameObjectFromGO("FireParticles1", bonfire_1)
    bonfire1_particles[2] = lua_table.GO:FindChildGameObjectFromGO("FireParticles2", bonfire_1)
    bonfire2_particles[1] = lua_table.GO:FindChildGameObjectFromGO("FireParticles1", bonfire_2)
    bonfire2_particles[2] = lua_table.GO:FindChildGameObjectFromGO("FireParticles2", bonfire_2)

    spawner1 = lua_table.GO:FindGameObject("Spwanersv2_audio")
    spawner2 = lua_table.GO:FindGameObject("Spawners_2ndPart")
    spawner3 = lua_table.GO:FindGameObject("Spawners_PreKiki")
    spawner4 = lua_table.GO:FindGameObject("Spawners_AfterBridge")

    if winlose > 0
    then
        winlose_script = lua_table.GO:GetScript(winlose)
    end
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end