function GetTableLore_VL_Manager()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.Audio = Scripting.Audio()

local my_UID = 0
local locked_door_UID = 0
local locked_door_Script = {}


function lua_table:Awake()
    my_UID = lua_table.GO:GetMyUID()
    locked_door_UID = lua_table.GO:FindGameObject("Door_3")

    if locked_door_UID ~= 0 then
        locked_door_Script = lua_table.GO:GetScript(locked_door_UID)
    end
end

function lua_table:Start()
end

function lua_table:Update()
end

function lua_table:PlayGuardLine()
    lua_table.Audio:PlayAudioEventGO("Play_Guard_Line", my_UID)
end

function lua_table:PlayD8LeadTheWay()
    lua_table.Audio:PlayAudioEventGO("Play_Dialogue_8", my_UID)
end

function lua_table:PlayD9KikiNest()
    lua_table.Audio:PlayAudioEventGO("Play_Dialogue_9", my_UID)
end

function lua_table:PlayD3BanditsArrived()
    lua_table.Audio:PlayAudioEventGO("Play_Dialogue_3", my_UID)
end

function lua_table:PlayWaveIncome()
    lua_table.Audio:PlayAudioEventGO("Play_Wave_Incoming", my_UID)
end

function lua_table:PlayGeraltChest()
    lua_table.Audio:PlayAudioEventGO("Play_Geralt_find_chest", my_UID)
end

function lua_table:PlayJaskierChest()
    lua_table.Audio:PlayAudioEventGO("Play_Jaskier_find_chest", my_UID)
end

function lua_table:PlayDoorLocked()
    if locked_door_Script ~= nil and locked_door_Script.door_unlocked == false then
        lua_table.Audio:PlayAudioEventGO("Play_Locked_And_No_Key_In_Sight", my_UID)
    end
end

function lua_table:HordesStart()
    lua_table.Audio:PlayAudioEventGO("Play_Wave_Incoming", my_UID)
end

return lua_table
end