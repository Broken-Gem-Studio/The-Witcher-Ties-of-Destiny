function GetTableHitColliderHeadKikimoraScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.MaterialsFunctions = Scripting.Materials ()

local my_UID = 0
kikimora_id = 0
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

local particles = 
{
    head_blood_hit = { part_name = "Head_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    left_leg_1_blood_hit = { part_name = "Left_Leg_1_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    left_leg_2_blood_hit = { part_name = "Left_Leg_2_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    left_leg_3_blood_hit = { part_name = "Left_Leg_3_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    left_leg_4_blood_hit = { part_name = "Left_Leg_4_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },

    right_leg_1_blood_hit = { part_name = "Right_Leg_1_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    right_leg_2_blood_hit = { part_name = "Right_Leg_2_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    right_leg_3_blood_hit = { part_name = "Right_Leg_3_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
    right_leg_4_blood_hit = { part_name = "Right_Leg_4_Blood_Hit", part_UID = 0, part_childs = {}, part_active = false, part_pos = {} },
}
-- Main Code
function lua_table:Awake ()
    lua_table.SystemFunctions:LOG ("This Log was called from Pivot Script on AWAKE")
    
    lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()
	
    lua_table.kikimora_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.kikimora_GO)

    lua_table.kikimora_script = lua_table.GameObjectFunctions:GetScript(lua_table.kikimora_id)

    particles.head_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.head_blood_hit.part_name)
	particles.head_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.head_blood_hit.part_UID)

    particles.left_leg_1_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.left_leg_1_blood_hit.part_name)
    particles.left_leg_1_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.left_leg_1_blood_hit.part_UID)
    particles.left_leg_2_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.left_leg_2_blood_hit.part_name)
    particles.left_leg_2_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.left_leg_2_blood_hit.part_UID)
  
    particles.right_leg_1_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.right_leg_1_blood_hit.part_name)
    particles.right_leg_1_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.right_leg_1_blood_hit.part_UID)
    particles.right_leg_2_blood_hit.part_UID = lua_table.GameObjectFunctions:FindGameObject(particles.right_leg_2_blood_hit.part_name)
    particles.right_leg_2_blood_hit.part_childs = lua_table.GameObjectFunctions:GetGOChilds(particles.right_leg_2_blood_hit.part_UID)
   
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

        -- Damage 
        lua_table.kikimora_script.damage_received = lua_table.collider_parent_script.collider_damage
        lua_table.kikimora_script.current_health = lua_table.kikimora_script.current_health - (lua_table.kikimora_script.damage_received * 2)

        -- Particle activation to main script
        for i = 1, #particles.head_blood_hit.part_childs do
	        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.head_blood_hit.part_childs[i], particles.head_blood_hit.part_UID)
        end
        
        lua_table.MaterialsFunctions:SetMaterialByName(lua_table.kikimora_script.hit_material_GO, lua_table.kikimora_script.my_mesh_UID)
        lua_table.kikimora_script.swapped_material = true

        lua_table.kikimora_script.AudioFunctions:PlayAudioEventGO("Play_Kikimora_damaged", kikimora_id)
    end
end

function lua_table:RequestedTrigger(character_UID)

    lua_table.collider_parent_script = lua_table.GameObjectFunctions:GetScript(character_UID)

    -- Damage 
    lua_table.kikimora_script.damage_received = lua_table.collider_parent_script.collider_damage
    lua_table.kikimora_script.current_health = lua_table.kikimora_script.current_health - (lua_table.kikimora_script.damage_received * 2)

    -- Particle activation to main script
    for i = 1, #particles.head_blood_hit.part_childs do
        lua_table.ParticlesFunctions:PlayParticleEmitter(particles.head_blood_hit.part_childs[i], particles.head_blood_hit.part_UID)
    end
    
    lua_table.MaterialsFunctions:SetMaterialByName(lua_table.kikimora_script.hit_material_GO, lua_table.kikimora_script.my_mesh_UID)
    lua_table.kikimora_script.swapped_material = true

    lua_table.kikimora_script.AudioFunctions:PlayAudioEventGO("Play_Kikimora_damaged", kikimora_id)
end

	return lua_table
end

