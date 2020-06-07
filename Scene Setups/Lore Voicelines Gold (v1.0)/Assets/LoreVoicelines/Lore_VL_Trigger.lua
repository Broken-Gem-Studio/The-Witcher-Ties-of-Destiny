function GetTableLore_VL_Trigger()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()

lua_table.lore_manager = 0
lua_table.my_UID = 0
lua_table.entered = false

lua_table.lore_manager_script = {}
-- Collider Layers
local layers = 
{
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4
}	


function lua_table:Awake()
    lua_table.my_UID = lua_table.GO:GetMyUID()

    lua_table.lore_manager = lua_table.GO:FindGameObject("Voicelines_Lore_Manager")

    if lua_table.lore_manager ~= 0 then
        lua_table.lore_manager_script = lua_table.GO:GetScript(lua_table.lore_manager)
    end
end

function lua_table:Start()
end

function lua_table:Update()
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.my_UID)

    local layer = lua_table.GO:GetLayerByID(collider)
    
    if lua_table.entered == false then

        if layer == layers.player  --Checks if its player collider layer
        then
            if lua_table.lore_manager_script ~= nil then


                --Here we must evaluate the booleans and decide which function we call from the manager
                lua_table.System:LOG("Triggered Voiceline")
                lua_table.lore_manager_script:PlayLevel_1_Start()
            end
        end


        lua_table.entered = true
    end
end

return lua_table
end