function GetTableHordasTutorial()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Physics = Scripting.Physics()

lua_table.countdown = 0

local uid = 0
local time = 0

local first = true
local started = false
local flag0 = false
local flag1 = false
local flag2 = false
local flag3 = false
local flag4 = false

function lua_table:OnTriggerEnter()
    local collider = lua_table.Physics:OnTriggerEnter(uid)

    if lua_table.GO:GetLayerByID(collider) == 1 and first == true
    then
        first = false
        --set camera angle and lock
        --active ui
        --start countdown
        time = 0
    end
end

function lua_table:Awake()
    uid = lua_table.GO:GetMyUID()
end

function lua_table:Start()
end

function lua_table:Update()
    time = time + lua_table.System:DT()

    if first == false
    then
        if time >= lua_table.countdown and started == false
        then
            --script_hordas.begin = true
            started = false
        end

        --if round0_script.is_finished == true and flag0 == false
        --then
            --active ui countdown (= to delay_round)
            --flag0 = true
        --end
    end
end

return lua_table
end