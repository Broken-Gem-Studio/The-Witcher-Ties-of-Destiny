function GetTableDummyScript()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.PhysicsFunctions =  Scripting.Physics()
lua_table.Audio = Scripting.Audio()

local MyUID
local randomNumber

function lua_table:OnTriggerEnter()	
    local collider = lua_table.PhysicsFunctions:OnTriggerEnter(MyUID)
    local layer = lua_table.ObjectFunctions:GetLayerByID(collider)
    
    if layer == 2
    then
        randomNumber = lua_table.SystemFunctions:RandomNumberInRange(0, 2)

        if randomNumber <= 1
        then
            lua_table.AnimationFunctions:PlayAnimation("rotation", 30, MyUID)
        else
            lua_table.AnimationFunctions:PlayAnimation("hit", 30, MyUID)
        end

        lua_table.Audio:PlayAudioEventGO("Play_Prop_hit_wood",MyUID)
    end
end

function lua_table:Awake()
    MyUID = lua_table.ObjectFunctions:GetMyUID()
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end