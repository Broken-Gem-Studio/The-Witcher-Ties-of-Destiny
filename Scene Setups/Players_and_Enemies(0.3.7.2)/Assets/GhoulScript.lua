function GetTableGhoulScript()

local lua_table = {}

lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.AnimationSystem = Scripting.Animations()
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

lua_table.player_1 = "Geralt"
lua_table.player_2 = "Jaskier"

local AnimIDLE = "IDLE"

lua_table.Life = 80

lua_table.MaxSpeed = 150

lua_table.SwipeAttack = 10

lua_table.Stunned = false

lua_table.StuntTime = 5000 --time that the base stunt is this value should be changed by every character for every different stunt they use //milliseconds

lua_table.currentTarget = 0

lua_table.PatrolPoint = 0

lua_table.AggroDistance = 150

lua_table.minDistance = 30  

lua_table.MyUID = 0

lua_table.DistanceMagnitude = 0

local RUNcontroller = 0

local TimeController = 0

local TimePassed = 0

lua_table.Nvec3x = 0
lua_table.Nvec3y = 0
lua_table.Nvec3z = 0

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
local Speed = 10


lua_table.currentState = State.IDL

---------------------------------FUNCTIONS------------------------------
------------------------------------------------------------------------

local function PerfGameTime()
	return lua_table.SystemFunctions:GameTime() * 1000
end

function Patrol()
	--lua_table.SystemFunctions:LOG("Patrol()")
	
	--
end

local function Players() --function to know if there is a player in the area and where it is
	
    ret = true


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
	--lua_table.SystemFunctions:LOG("Aggro()?")													
	if lua_table.currentTarget == 0 and Players() == true --sin objetivo inicial y existen players
	then	
			if lua_table.GeraltDistance < lua_table.AggroDistance  
			then
				lua_table.currentTarget = lua_table.Geralt
				--lua_table.SystemFunctions:LOG("GERALT IN AGGRO")
				return true			
			elseif lua_table.JaskierDistance < lua_table.AggroDistance  
			then
				lua_table.currentTarget = lua_table.Jaskier
				--lua_table.SystemFunctions:LOG("JASKIER IN AGGRO")
			else
				lua_table.SystemFunctions:LOG("NO PLAYERS INSIDE AGGRO DISTANCE")
				return false
			end
	
	end
	if ret == true
	then
		--lua_table.SystemFunctions:LOG("Aggro() - YES")		
	end
	return ret
end


function HandleIdleState() --handle if necessary to change idle state to patrol.
	
    if lua_table.currentState == State.IDL
    then		
		if lua_table.Stunned == false
		then
			--lua_table.SystemFunctions:LOG("Players()?")
			if Players() == true
			then				
				--lua_table.SystemFunctions:LOG("Players()? - YES")	
				lua_table.currentState = State.PATROL 
				--lua_table.SystemFunctions:LOG("GhoulScript: New State: PATROL")	
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

	--lua_table.SystemFunctions:LOG ("Distance from Jaskier: " .. lua_table.JaskierDistance)
	--lua_table.SystemFunctions:LOG ("Distance from Geralt: " .. lua_table.GeraltDistance)

	if HandleAggro() == true
	then
		lua_table.currentState = State.SEEK
		lua_table.AnimationSystem:PlayAnimation("RUN",30)
		--lua_table.SystemFunctions:LOG("GhoulScript: New State: SEEK")
	end


   
end



function HandleSeekState()

end


function Seek()

	--lua_table.SystemFunctions:LOG("SEEKKKKKKKKKKKKKK")
	-- vec3 = x1-x�,y1-y�,z1-z�
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

	lua_table.DistanceMagnitude = math.sqrt( vec3xpow + vec3zpow) --y not used
	--lua_table.SystemFunctions:LOG ("Target Distance Magnitude: " ..lua_table.DistanceMagnitude)

	if lua_table.DistanceMagnitude > lua_table.minDistance 
	then
		--lua_table.SystemFunctions:LOG ("CALCULATE DIRECTION VECTORS") 
		lua_table.Nvec3x = vec3x / lua_table.DistanceMagnitude
		lua_table.Nvec3y = vec3y / lua_table.DistanceMagnitude -- Normalized values
		lua_table.Nvec3z = vec3z / lua_table.DistanceMagnitude	
	elseif lua_table.DistanceMagnitude < lua_table.minDistance
	then
		lua_table.currentState = State.ATTACK
		--lua_table.SystemFunctions:LOG ("New state: ATTACK") 		
	end
end

function HandleAttackState()

--------------------------CALCULATE DISTANCE MAGNITUDE-----------------

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

	lua_table.DistanceMagnitude = math.sqrt( vec3xpow + vec3zpow) 

	--lua_table.SystemFunctions:LOG("DISTANCE WHEN ATTACK IS:"..lua_table.DistanceMagnitude)


	if lua_table.DistanceMagnitude > lua_table.minDistance
	then
		lua_table.currentState = State.SEEK
	end
	local Timer = PerfGameTime()

	if TimeController == 0
	then
		TimePassed = Timer
		lua_table.AnimationSystem:PlayAnimation("ATTACK_2",30)
		--lua_table.SystemFunctions:LOG("----------------------------------------------------------------------------------------------") 
		TimeController = 1
	end

	TimeElapse = Timer - TimePassed

	if TimeElapse > 3000
	then
		TimeController = 0
	end

end


--------------------------------FUNCTIONS END -------------------------
------------------------------------------------------------------------

function lua_table:OnTriggerEnter()	
	local collider = lua_table.PhysicsSystem:OnTriggerEnter(lua_table.MyUID)
	--lua_table.SystemFunctions:LOG("T: ".. collider)
end

function lua_table:OnCollisionEnter()
	local collider = lua_table.PhysicsSystem:OnCollisionEnter(lua_table.MyUID)
	--lua_table.SystemFunctions:LOG("T: ".. collider)
end


--Main Code
function lua_table:Awake()
   lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on AWAKE")

   -------------------- GET PLAYERS id START--------------------
   lua_table.Geralt = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_1)
   lua_table.Jaskier = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_2) 

   if lua_table.Geralt == 0 then lua_table.SystemFunctions:LOG ("A random GhoulScript: Null Geralt id, check the name of game object the script is looking for or add Geralt to the scene if not there already")
   end
    
   if lua_table.Jaskier == 0 then lua_table.SystemFunctions:LOG ("A random GhoulScript: Null Jaskier id, check the name of game object the script is looking for or add Jaskier to the scene if not there already")
   end

   lua_table.currentState = State.IDL
   lua_table.AnimationSystem:PlayAnimation("IDLE",30)
   -------------------- GET PLAYERS id END --------------------

   --------------------GET MY UID---------------------------

   lua_table.MyUID = lua_table.GameObjectFunctions:GetMyUID()


end

function lua_table:Start()
    lua_table.SystemFunctions:LOG("A random GhoulScript: START") 
	
	--lua_table.AnimationSystem.StartAnimation(Lumberjack,30.0)
end

function lua_table:Update()
 
	
	if stunned == true --stunt bool change handled inn HandleIdleState() function
	then 
		lua_table.currentState = State.IDL
	end

    if lua_table.currentState == State.IDL --and lua_table.Jaskier ~= 0 and lua_table.Geralt ~= 0
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


	if lua_table.DistanceMagnitude > 20 and lua_table.currentTarget ~= 0 and lua_table.currentState ~= State.ATTACK
	then
		Speed = 30
		if RUNcontroller == 0
		then
			lua_table.AnimationSystem:PlayAnimation("RUN",30)
			RUNcontroller = 1
		end
	else 
		Speed = 0
		RUNcontroller = 0
	end
  
	if lua_table.currentState == State.SEEK
	then
		lua_table.PhysicsSystem:Move(lua_table.Nvec3x*Speed,lua_table.Nvec3z*Speed)
	end

	if lua_table.currentState == State.SEEK or lua_table.currentState == State.ATTACK
	then
		pos_x, pos_y, pos_z = lua_table.TransformFunctions:GetPosition()
		lua_table.TransformFunctions:LookAt(pos_x + lua_table.Nvec3x,pos_y,pos_z + lua_table.Nvec3z,true)
		 --lua_table.TransformFunctions:RotateObject(lua_table.GameObjectFunctions:GetGameObjectPosX(lua_table.currentTarget),lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.currentTarget),lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.currentTarget))
	end

end

return lua_table
end
