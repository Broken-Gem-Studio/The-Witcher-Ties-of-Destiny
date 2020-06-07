function GetTableLore_VL_Trigger()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GO = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()

lua_table.lore_manager = 0
lua_table.my_UID = 0
lua_table.entered = false

lua_table.TriggersVoiceline = true
lua_table.City_Guard_Line = false
lua_table.Chest_Line = false
lua_table.Forest_Lead_way = false
lua_table.Forest_Kiki_Nest = false
lua_table.City_Door_locked = false
lua_table.CityBeforeHorde = false
lua_table.Forest_Enemies_Close = false

local geralt_UID = 0
local jaskier_UID = 0


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

    geralt_UID = lua_table.GO:FindGameObject("Geralt")
    jaskier_UID = lua_table.GO:FindGameObject("Jaskier")
end

function lua_table:Start()
end

function lua_table:Update()
end

function lua_table:OnTriggerEnter()
    local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.my_UID)
    
    lua_table.System:LOG("Detected Trigger")

    local layer = lua_table.GO:GetLayerByID(collider)
    
    if lua_table.entered == false then

        if layer == layers.player  --Checks if its player collider layer
        then
            if lua_table.lore_manager_script ~= nil and lua_table.TriggersVoiceline == true then

                --Here we must evaluate the booleans and decide which function we call from the manager
                if lua_table.City_Guard_Line == true then
                    lua_table.System:LOG("Triggered Voiceline: City Guard")
                    lua_table.lore_manager_script:PlayGuardLine()
                end

                if lua_table.Forest_Lead_way == true then
                    lua_table.System:LOG("Triggered Voiceline: Lead the way")
                    lua_table.lore_manager_script:PlayD8LeadTheWay()
                end

                if lua_table.Forest_Enemies_Close == true then
                    lua_table.System:LOG("Triggered Voiceline: Bandits_Close")
                    lua_table.lore_manager_script:PlayD3BanditsArrived()
                end

                if lua_table.Forest_Kiki_Nest == true then
                    lua_table.System:LOG("Triggered Voiceline: Kikimora nest")
                    lua_table.lore_manager_script:PlayD9KikiNest()
                end

                if lua_table.Chest_Line == true then
                    if collider == geralt_UID then
                        lua_table.lore_manager_script:PlayGeraltChest()
                        lua_table.System:LOG("Triggered Voiceline: Geralt found chest")
                    elseif collider == jaskier_UID then
                        lua_table.lore_manager_script:PlayJaskierChest()
                        lua_table.System:LOG("Triggered Voiceline: Jaskier found chest")
                    end
                end

                if lua_table.City_Door_locked == true then
                    lua_table.System:LOG("Triggered Voiceline: Door_Locked")
                    lua_table.lore_manager_script:PlayDoorLocked()
                end

                if lua_table.CityBeforeHorde == true then
                    lua_table.System:LOG("Triggered Voiceline: Hordes start")
                    lua_table.lore_manager_script:HordesStart()
                end



            end
        end


        lua_table.entered = true
    end
end

return lua_table
end