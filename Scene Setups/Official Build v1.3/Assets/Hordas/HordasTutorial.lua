function GetTableHordasTutorial()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Physics = Scripting.Physics()
lua_table.UI = Scripting.Interface()

local camera_GO
local camera_script = {}
local camera_UID = 0

local next_round = 0
local last_round = 0
local counter = 0
local uid = 0

local hordas = 0
local hordas_script = 0

local round0 = 0
local round1 = 0
local round2 = 0
local round3 = 0
local round4 = 0
local round0_script = 0
local round1_script = 0
local round2_script = 0
local round3_script = 0
local round4_script = 0

local first = true
local begin = false
local flag0 = false
local flag1 = false
local flag2 = false
local flag3 = false
local flag4 = false

local counting = false
local count = 0
local time = 0

function lua_table:OnTriggerEnter()
    local collider = lua_table.Physics:OnTriggerEnter(uid)

    if lua_table.GO:GetLayerByID(collider) == 1 and first == true
    then
        --set camera angle and lock**
        if camera_script ~= nil
        then
            camera_script.hoardfight = true
        end
        
        lua_table.GO:SetActiveGameObject(true, next_round)
        lua_table.GO:SetActiveGameObject(true, counter)
        counting = true
        count = hordas_script.delay_rounds
        lua_table.UI:SetTextNumber(count, counter)
        time = 0
        first = false
    end
end

function lua_table:Awake()
    uid = lua_table.GO:GetMyUID()
    next_round = lua_table.GO:FindGameObject("NextRoundIn")
    last_round = lua_table.GO:FindGameObject("LastRoundIn")
    counter = lua_table.GO:FindGameObject("Counter")

    camera_UID = lua_table.GO:FindGameObject("Camera")
    if camera_UID > 0
    then
        camera_script = lua_table.GO:GetScript(camera_UID)
    end

    hordas = lua_table.GO:FindGameObject("HordasTutorial")
    if hordas > 0
    then
        hordas_script = lua_table.GO:GetScript(hordas)
    end

    round0 = lua_table.GO:FindGameObject("Round0")
    if round0 > 0
    then
        round0_script = lua_table.GO:GetScript(round0)
    end
    round1 = lua_table.GO:FindGameObject("Round1")
    if round1 > 0
    then
        round1_script = lua_table.GO:GetScript(round1)
    end
    round2 = lua_table.GO:FindGameObject("Round2")
    if round2 > 0
    then
        round2_script = lua_table.GO:GetScript(round2)
    end
    round3 = lua_table.GO:FindGameObject("Round3")
    if round3 > 0
    then
        round3_script = lua_table.GO:GetScript(round3)
    end
    round4 = lua_table.GO:FindGameObject("Round4")
    if round4 > 0
    then
        round4_script = lua_table.GO:GetScript(round4)
    end

    lua_table.GO:SetActiveGameObject(false, next_round)
    lua_table.GO:SetActiveGameObject(false, last_round)
    lua_table.GO:SetActiveGameObject(false, counter)
end

function lua_table:Start()
end

function lua_table:Update()
    time = time + lua_table.System:DT()

    if counting == true
    then
        if time >= 1
        then
            count = count - 1
            lua_table.UI:SetTextNumber(count, counter)
            time = 0
        end
    end

    if first == false
    then
        if count <= 0
        then
            lua_table.GO:SetActiveGameObject(false, next_round)
            lua_table.GO:SetActiveGameObject(false, last_round)
            lua_table.GO:SetActiveGameObject(false, counter)

            if begin == false
            then
                hordas_script.begin = true
                begin = true
            else
                if round0_script.is_finished == true and flag0 == false
                then
                    lua_table.GO:SetActiveGameObject(true, next_round)
                    lua_table.GO:SetActiveGameObject(true, counter)    
                    counting = true
                    count = hordas_script.delay_rounds
                    lua_table.UI:SetTextNumber(count, counter)
                    time = 0
                    flag0 = true
                end

                if round1_script.is_finished == true and flag1 == false
                then
                    lua_table.GO:SetActiveGameObject(true, next_round)
                    lua_table.GO:SetActiveGameObject(true, counter)    
                    counting = true
                    count = hordas_script.delay_rounds
                    lua_table.UI:SetTextNumber(count, counter)
                    time = 0
                    flag1 = true
                end

                if round2_script.is_finished == true and flag2 == false
                then
                    lua_table.GO:SetActiveGameObject(true, next_round)
                    lua_table.GO:SetActiveGameObject(true, counter)    
                    counting = true
                    count = hordas_script.delay_rounds
                    lua_table.UI:SetTextNumber(count, counter)
                    time = 0
                    flag2 = true
                end

                if round3_script.is_finished == true and flag3 == false
                then
                    lua_table.GO:SetActiveGameObject(true, last_round)
                    lua_table.GO:SetActiveGameObject(true, counter)    
                    counting = true
                    count = hordas_script.delay_rounds
                    lua_table.UI:SetTextNumber(count, counter)
                    time = 0
                    flag3 = true
                end
            end  
        end
    end
end

return lua_table
end