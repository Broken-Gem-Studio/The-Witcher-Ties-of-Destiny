function GetTableLumber_Alive()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Animations = Scripting.Animations()

local MyUID = 0
local random = 0
local play_anim = true

function lua_table:Awake()
end

function lua_table:Start()
    MyUID = lua_table.GameObject:GetMyUID()
end

function lua_table:Update()
    random = math.random(1, 2)

    if random == 1 and play_anim == true then
        lua_table.Animations:PlayAnimation("Idle", 30.0, MyUID)
        play_anim = false
    elseif random == 2 and play_anim == true then
        lua_table.Animations:PlayAnimation("Looking", 30.0, MyUID)
        play_anim = false
    end
    
end

return lua_table
end