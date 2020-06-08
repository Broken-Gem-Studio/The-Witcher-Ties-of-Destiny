function GetTableHitColliderRightLeg1KikimoraScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()

lua_table.my_UID = 0
lua_table.kikimora_id = 0
lua_table.kikimora_GO = "Kikimora"
lua_table.kikimora_script = {}

lua_table.collider_parent_script = {}

-- Collider Layers
local layers = 
{
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
    enemy_attack = 4,
    prop = 5,
    particles_prop = 6,
}

-- Main Code
function lua_table:Awake ()
    lua_table.SystemFunctions:LOG ("This Log was called from Pivot Script on AWAKE")
    
    lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()
	
    lua_table.kikimora_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.kikimora_GO)

    lua_table.kikimora_script = lua_table.GameObjectFunctions:GetScript(lua_table.kikimora_id)
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("Pivot Script START")

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()

end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.my_UID)

    local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
    local collider_parent_GO = 0

	if layer == layers.player_attack  --Checks if its player attack collider layer
	then
        collider_parent_GO = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		lua_table.collider_parent_script = lua_table.GameObjectFunctions:GetScript(collider_parent_GO)

        -- Damage to main script
        lua_table.kikimora_script.damage_received = lua_table.collider_parent_script.collider_damage
        
        -- Hit to main script
        lua_table.kikimora_script.hits_received = lua_table.kikimora_script.hits_received + 1

        -- Particle activation to main script
        lua_table.kikimora_script.Right_leg_1_hit = true
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
    local collider = lua_table.PhysicsFunctions:OnCollisionEnter(lua_table.my_UID)
	-- lua_table.SystemFunctions:LOG("T:" .. collider)
end
	return lua_table
end

