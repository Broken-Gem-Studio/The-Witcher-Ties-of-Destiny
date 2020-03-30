function	GetTableGhoulScript()

local lua_table = {}
--lua_table.DebugFunctions = Scripting.Debug() ------------> lua_table.SystemFunctions = Scripting.System()
--lua_table.ElementFunctions = Scripting.Elements() ------------> lua_table.GameObjectFunctions = Scripting.GameObject()
--lua_table.SystemFunctions = Scripting.Systems()
--lua_table.InputFunctions = Scripting.Inputs()
lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

--Enemy main state
local State = {
    IDL = 1,
    PATROL = 2,
    SEEK = 3,
    ATTACK = 4
}

lua_table.Life = 80

lua_table.MaxSpeed = 150

lua_table.SwipeAttack = 10

lua_table.Stunned = false

lua_table.StuntTime = 5000 --time that the base stunt is this value should be changed by every character for every different stunt they use //milliseconds

lua_table.currentTarget = 0

lua_table.PatrolPoint = 0

lua_table.AggroDistance = 30

local GeraltPos_x = 0
local GeraltPos_y = 0
local GeraltPos_z = 0

local JaskierPos_x = 0
local JaskierPos_y = 0
local JaskierPos_z = 0

lua_table.JaskierDistance = 0
lua_table.GeraltDistance = 0

lua_table.Geralt = 0
lua_table.Jaskier = 0

-----------------------------------------------------------------------------------------
-- Enemy Variables
-----------------------------------------------------------------------------------------

--Movement
local Speed_x = 0.0
local Speed_z = 0.0
local Speed_y = 0.0 --up?

lua_table.currentState = State.IDL

---------------------------------FUNCTIONS------------------------------
------------------------------------------------------------------------

local function PerfGameTime()
	return lua_table.DebugFunctions:GameTime() * 1000
end

function Patrol()
	lua_table.SystemFunctions:LOG("Patrol()")
	
	--
end

local function Players() --function to know if there is a player in the area and where it is
	
    ret = true

	JaskierPos_x = 0
	JaskierPos_y = 0
	JaskierPos_z = 0

	GeraltPos_x = 0
	GeraltPos_y = 0
	GeraltPos_z = 0

    if lua_table.Geralt ~= 0 --Geralt comprovation
    then 
		GeraltPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(lua_table.Geralt)
		GeraltPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.Geralt)
		GeraltPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.Geralt)
		--lua_table.SystemFunctions:LOG("Geralt - YES")	
    else--if  lua_table.Geralt == 0
		lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on Players()? function because Geralt is not found")
		ret = false
    end

    if  lua_table.Jaskier ~= 0 --Jaskier comprovation
    then 
       JaskierPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(lua_table.Jaskier)
       JaskierPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.Jaskier)
       JaskierPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.Jaskier)   
       --lua_table.SystemFunctions:LOG("Jaskier - YES")	
    else  
        lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on HandleTheNearestPlayer function because Geralt is not found")
		ret = false
    end

    --calculate distances:
	--PITAGORAS SAYS SQRT(A^2-B^2)

	--JASKIER:
	GhoulX = lua_table.TransformFunctions:GetPositionX()
	GhoulZ = lua_table.TransformFunctions:GetPositionZ()
	Aj = JaskierPos_x - GhoulX
	Bj = JaskierPos_z - GhoulZ
	--lua_table.SystemFunctions:LOG ("Aj: " .. Aj)
	--lua_table.SystemFunctions:LOG ("Bj: " .. Bj)
    lua_table.JaskierDistance =  math.sqrt(Aj^2 + Bj^2)
	--lua_table.SystemFunctions:LOG ("JASKIER DISTANCE : " .. lua_table.JaskierDistance)

	--GERALT:
	GhoulX = lua_table.TransformFunctions:GetPositionX()
	GhoulZ = lua_table.TransformFunctions:GetPositionZ()
	Ag = GeraltPos_x - GhoulX
	Bg = GeraltPos_z - GhoulZ
	--lua_table.SystemFunctions:LOG ("Ag: " .. Ag)
	--lua_table.SystemFunctions:LOG ("Bg: " .. Bg)
    lua_table.GeraltDistance =  math.sqrt(Ag^2 + Bg^2)
	--lua_table.SystemFunctions:LOG ("JASKIER DISTANCE : " .. lua_table.JaskierDistance)

    return ret
end



function HandleAggro()
	ret = true 
	lua_table.SystemFunctions:LOG("Aggro()?")													
	if lua_table.currentTarget == 0 and Players() == true --sin objetivo inicial y existen players
	then	
			if lua_table.GeraltDistance < lua_table.AggroDistance  
			then
				lua_table.currentTarget = lua_table.Geralt
				lua_table.SystemFunctions:LOG("GERALT IN AGGRO")
				return true			
			elseif lua_table.JaskierDistance < lua_table.AggroDistance  
			then
				lua_table.currentTarget = lua_table.Jaskier
				lua_table.SystemFunctions:LOG("JASKIER IN AGGRO")
			else
				lua_table.SystemFunctions:LOG("NO PLAYERS INSIDE AGGRO DISTANCE")
				return false
			end
	
	end
	if ret == true
	then
		lua_table.SystemFunctions:LOG("Aggro() - YES")		
	end
	return ret
end


function HandleIdleState() --handle if necessary to change idle state to patrol.
	
    if lua_table.currentState == State.IDL
    then		
		if lua_table.Stunned == false
		then
			lua_table.SystemFunctions:LOG("Players()?")
			if Players() == true
			then				
				lua_table.SystemFunctions:LOG("Players()? - YES")	
				lua_table.currentState = State.PATROL 
				lua_table.SystemFunctions:LOG("GhoulScript: New State: PATROL")	
			end
		end
    end
end

function HandlePatrolState() -- THIS IS NOT A PATROL ITSELF, IS JUST A LITTLE AREA IN WICH THE GHOULS WILL WALK. (little is like 3 meters in a circle)

    --if lua_table.currentState ==State.PATROL
    --then
    Patrol()
    --end
    
    lua_table.JaskierPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(lua_table.Jaskier)
    lua_table.JaskierPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.Jaskier)
    lua_table.JaskierPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.Jaskier)
	


    lua_table.GeraltPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(lua_table.Geralt)
    lua_table.GeraltPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.Geralt)
    lua_table.GeraltPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.Geralt)

    lua_table.JaskierDistance =  math.sqrt(JaskierPos_x ^ 2 + JaskierPos_z ^ 2)
    lua_table.GeraltDistance = math.sqrt(GeraltPos_x ^ 2 + GeraltPos_z ^ 2)

	lua_table.SystemFunctions:LOG ("Distance from Jaskier: " .. lua_table.JaskierDistance)
	lua_table.SystemFunctions:LOG ("Distance from Geralt: " .. lua_table.GeraltDistance)

	if HandleAggro() == true
	then
		lua_table.currentState = State.SEEK
		lua_table.SystemFunctions:LOG("GhoulScript: New State: SEEK")
	end


   
end

function HandleAttackState()

 --attack!
 --play 1 time the attack anim=?????

end

function HandleSeekState()
	
     --elseif lua_table.Stunned == true -- when stunned is true idle state does not change. add a script to add stunned effect in enemy head when stunned
	 --		then
	 --			lua_table.SystemFunctions:LOG("Stunned - YES")	
	 --			local Time = 0 --TODO timer
				--timer for stunt here. dt??? when end Timer controller is false turn stunned to false
	 --			if Time == StuntTime 
		--		then
	 --				lua_table.Stunned = false
	 --			end
	 --		end
end


function Seek()

	
	-- vec3 = x1-xº,y1-yº,z1-zº
	posX,posY,posZ = lua_table.TransformFunctions:GetPosition()

	tarX = lua_table.GameObjectFunctions:GetGameObjectPosX(lua_table.currentTarget)
	tarY = lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.currentTarget)
	tarZ = lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.currentTarget)

	--Now we get the direction vector and then we normalize it and aply a velocity in every component

	vec3x = tarX - posX
	vec3y = tarY - posY  -- Direction
	vec3z = tarZ - posZ

	vec3xpow = vec3x * vec3x
	vec3ypow = vec3y * vec3y -- pre calculus
	vec3zpow = vec3z * vec3z

	magnitude = math.sqrt( vec3xpow + vec3zpow) --y not used
	lua_table.SystemFunctions:LOG ("Target Distance Magnitude: " .. magnitude)

	Nvec3x = vec3x / magnitude
	Nvec3y = vec3y / magnitude -- Normalized values
	Nvec3z = vec3z / magnitude


	lua_table.TransformFunctions:Translate(Nvec3x,Nvec3y,Nvec3z,false)
	--lua_table.PhysicsSystem:SetLinearVelocity(Nvecx * 15,Nvecy * 15,Nvecz * 15) --move
	
	--then
	--	lua_table.PhysicsSystem:SetLinearVelocity()
	--end
end
---------------------------------FUNCTIONS END -------------------------
------------------------------------------------------------------------


--Main Code
function lua_table:Awake()
   lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on AWAKE")

   -------------------- GET PLAYERS id START--------------------
   lua_table.Geralt = lua_table.GameObjectFunctions:FindGameObject("gerardo1")
   lua_table.Jaskier = lua_table.GameObjectFunctions:FindGameObject("jaskier1") 

   if lua_table.Geralt == 0 then lua_table.SystemFunctions:LOG ("A random GhoulScript: Null Geralt id, check the name of game object the script is looking for or add Geralt to the scene if not there already")
   end
    
   if lua_table.Jaskier == 0 then lua_table.SystemFunctions:LOG ("A random GhoulScript: Null Jaskier id, check the name of game object the script is looking for or add Jaskier to the scene if not there already")
   end

   lua_table.currentState = State.IDL
   -------------------- GET PLAYERS id END --------------------
end

function lua_table:Start()
    lua_table.SystemFunctions:LOG("A random GhoulScript: START")  
end

function lua_table:Update()
 --lua_table.SystemFunctions:LOG("A random GhoulScript: UPDATE")  
	--dt = lua_table.SystemFunctions:dt()
--  lua_table.Functions:SetCurrentAnimationSpeed(100)
	
	if stunned == true --stunt bool change handled inn HandleIdleState() function
	then 
		lua_table.currentState = State.IDL
	end

    if lua_table.currentState == State.IDL 
    then
        HandleIdleState()
    elseif lua_table.currentState == State.PATROL
    then
        HandlePatrolState()
    elseif lua_table.currentState == State.SEEK
    then
        HandleSeekState()
		Seek()
    elseif lua_table.currentState == State.ATTACK
    then    
        HandleAttackState()
    end

	
--    HandleAnimations()
--    HandleMovement()

end

return lua_table
end
