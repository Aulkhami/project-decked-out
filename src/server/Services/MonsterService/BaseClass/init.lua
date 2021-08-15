local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Signal = require(Knit.Util.Signal)
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Switch = require(Knit.Modules.Switch)
local MonsterService = Knit.GetService("MonsterService")
local AnimationService = Knit.GetService("AnimationService")

local BaseClass = {}
BaseClass.__index = BaseClass
-- Component
BaseClass.Tag = "Monster:BaseClass"


function BaseClass.new(monster) -- Constructor
    local self = setmetatable({
    -- Properties
        attributes = monster:GetAttributes();
        currentEvent = "Nothing";
        eventList = {"Aggro", "Wander", "Nothing"};
        monsterCharacter = monster;
        root = monster.HumanoidRootPart;
        humanoid = monster.Humanoid;
        loadedAnimations = {};
    -- Variables
        raiders = workspace.Dungeon.Raiders;
        target = nil;
        targetDistance = nil;
        targetCharacter = nil;
        aggroDebounce = true;
        path = nil;
        pathObject = nil;
        currentWaypointIndex = 0;
    }, BaseClass)

    -- Setting Class Attributes
    if self.attributes.Class then
        local class = MonsterService.GetClass(self.attributes.Class)
        for i,v in pairs(class) do
            monster:SetAttribute(i,v)
        end
        self.attributes = monster:GetAttributes()
        self.humanoid.WalkSpeed = self.attributes.BaseSpeed
    end

    -- Loading Animations
    AnimationService.LoadBaseAnimations(self.monsterCharacter)
    if self.attributes.animationClass then
        self.loadedAnimations = AnimationService:LoadAnimations(self.humanoid, MonsterService.FindAnimationsForClass(self.attributes.animationClass))
    else
        self.loadedAnimations = AnimationService:LoadAnimations(self.humanoid, MonsterService.FindAnimationsForClass(self.attributes.Class))
    end

    -- Janitor
    self._janitor = require(Knit.Util.Janitor).new()
    -- Events
    self.IdleEvent = Signal.new(self._janitor)
    -- Event Connections
    self._janitor:Add(self.IdleEvent:Connect(function() self:Idle()
    end)) -- Makes the Monster wander when Idle
    self.humanoid.Died:Connect(function() self:OnDeath()
    end) -- Connects Humanoid's death with the OnDeath function

    return self
end

function BaseClass:EventChange(newEvent, chaseType, chaseValue) -- A function to prioritize certain Events over the other, and changing the current Event to the higher priority Event.
    local currentPriority = table.find(self.eventList, self.currentEvent)
    local newPriority = table.find(self.eventList, newEvent)

    local eventConditional = Switch()
    :case("Chase", function()
        print("Thinking of changing event to Chase")
        local currentChasePriority = table.find(self.chaseList, self.currentChase)
        local newChasePriority = table.find(self.chaseList, chaseType)

        if newPriority <= currentPriority and chaseValue > 0 then
            if newChasePriority == currentChasePriority and chaseValue > self.chaseValue then
                print("Same type of Chase")
                print("New ChaseValue is higher than Old ChaseValue")
                self:AbortMovement()
                self.currentEvent = newEvent
                return true
            elseif newChasePriority < currentChasePriority then
                self:AbortMovement()
                self.currentEvent = newEvent
                self.currentChase = chaseType
                return true
            else
                return false
            end
        else
            return false
        end
    end)
    :case("Nothing", function()
        self.currentEvent = newEvent
        if self.currentChase then self.currentChase = "Nothing"
        end
        self.IdleEvent:Fire()
    end)
    :default(function()
        if newPriority < currentPriority then
            self:AbortMovement()
            self.currentEvent = newEvent
            return true
        else
            return false
        end
    end)

    return eventConditional(newEvent)
end

-- Pathfinding and Movement

function BaseClass:Pathfind(target) -- Pathfinding
    local path
    if self.attributes.Radius and self.attributes.Height then
        local agentParameters = {
            AgentRadius = self.attributes.Radius;
            AgentHeight = self.attributes.Height;
            AgentCanJump = true;
        }
        if self.attributes.CanJump then agentParameters.AgentCanJump = self.attributes.CanJump
        end
        path = PathfindingService:CreatePath(agentParameters)
    else
        path = PathfindingService:CreatePath()
    end
    path:ComputeAsync(self.root.position, target)

    if path.Status == Enum.PathStatus.Success then
        return path:GetWaypoints(), path
    else
        return false
    end
end

function BaseClass:MoveTo(reached) -- Move to current waypoint in the path
    self.currentWaypointIndex += 1
    if reached and self.currentWaypointIndex < #self.path then
        -- Moving to Waypoint
        local waypoint = self.path[self.currentWaypointIndex]
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            self.humanoid.Jump = true
        end
        self.humanoid:MoveTo(waypoint.Position)
    else
        self:AbortMovement()
    end
end

function BaseClass:PathBlocked(blockedWaypointIndex) -- Runs when the Path from the Pathfinding gets blocked
    if blockedWaypointIndex >= self.currentWaypointIndex then
        self:AbortMovement()
    end
end

function BaseClass:StartMovement(target) -- Start Pathfinded Movement to specified Target
    -- Pathfinding
    self.path, self.pathObject = self:Pathfind(target)
    -- Starting Movement
    if self.path then
        self._janitor:Add(self.pathObject, nil, "Path")
        -- Events
        self._janitor:Add(self.humanoid.MoveToFinished:Connect(function(reached) self:MoveTo(reached)
        end), nil, "MoveCleanup")
        self._janitor:Add(self.pathObject.Blocked:Connect(function(blockedWaypointIndex) self:PathBlocked(blockedWaypointIndex)
        end), nil, "BlockCleanup")
        -- MoveTo 1st Waypoint
        self:MoveTo(true)
    else
        self:EventChange("Nothing")
    end
end

function BaseClass:AbortMovement() -- Aborts Current Pathfinded Movement
    if self.currentEvent ~= "Nothing" then
        -- Cleanups
        self._janitor:Remove("Path")
        self._janitor:Remove("MoveCleanup")
        self._janitor:Remove("BlockCleanup")
        -- Resetting Path-related Variables
        self.path = nil
        self.pathObject = nil
        self.currentWaypointIndex = 0

        self:EventChange("Nothing")
    end
end

function BaseClass:ChangeSpeed(speedMod) -- Changes the Monster's Humanoid Walkspeed if the Monster has Speed Modifiers
    local speedModAttr = self.attributes[speedMod]
    if speedModAttr then
        self.humanoid.WalkSpeed = (self.attributes.BaseSpeed * speedModAttr)
        print(self.humanoid.WalkSpeed)
    end
end

-- Monster Actions

function BaseClass:Attack()
    self.humanoid:MoveTo(self.root.Position)
    -- Face the Monster towards the Target
    local rotation = CFrame.lookAt(self.root.Position, self.target.Position)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local goal = {}
    goal.CFrame = rotation
    self.root.Position = self.root.Position
    local tween = TweenService:Create(self.root, tweenInfo, goal)
    tween:Play()

    -- Attacking the Target
    local debounce = true
    local face = self.root.CFrame.LookVector
    local depth = 0
    if self.attributes.Depth then depth = self.attributes.Depth
    end

    -- HitBox
    local hitBoxSpawn = self.root.CFrame + ((face * (self.attributes.AttackRange / 2)) + (face * (depth / 2)))
    local hitBox

    -- Animation
    local attackAnimation = self.loadedAnimations["HeavyAttack"]
    attackAnimation:Play()
    self._janitor:Add(attackAnimation:GetMarkerReachedSignal("Contact"):Connect(function(condition)
        if condition == "Start" then
            hitBox = MonsterService.GetHitBox(self.attributes.HitBox):Clone()
            hitBox.Parent = workspace
            hitBox.CFrame = hitBoxSpawn

            hitBox.Touched:Connect(function(hit)
                if debounce and hit.Parent == self.targetCharacter then
                    debounce = false
                    self.targetCharacter.Humanoid:TakeDamage(self.attributes.Damage)
                end
            end)
        elseif condition == "End" then
            hitBox:Destroy()
        end
    end), nil, "AttackAnimationEvent")

    attackAnimation.Stopped:Wait()
    self._janitor:Remove("AttackAnimationEvent")
end

function BaseClass:Wander()
    if self:EventChange("Wander") then
        self:ChangeSpeed("WanderSpeed")
        -- Randomizing Coordinate
        local xRand = math.random(-50,50)
        local zRand = math.random(-50,50)
        local target = self.root.Position + Vector3.new(xRand,0,zRand)

        self:StartMovement(target)
    end
end

function BaseClass:Aggro() -- Aggroes the Monster's Target. Aggro is the highest priority Event, which is why it uses a while loop instead of an event loop.
    if self:EventChange("Aggro") then
        self.aggroDebounce = false
        local oldTarget = self.targetCharacter
        self:ChangeSpeed("AggroSpeed")
        while self.targetDistance <= self.attributes.AggroRange do
            RunService.Heartbeat:Wait()
            if not self.target or oldTarget.Name ~= self.targetCharacter.Name then break
            end
            self.humanoid:MoveTo(self.target.Position)
            if self.targetDistance <= self.attributes.AttackRange then
                self:Attack()
            end
        end
        self:EventChange("Nothing")
        self.aggroDebounce = true
    end
end

-- Monster Logic Loop

function BaseClass:TargetPriority()
    local raiders = self.raiders:GetChildren()
    local currentDistance = math.huge
    local newTarget
    local targetCharacter
    if #raiders > 0 then
        for _,v in pairs(raiders) do
            local targetRoot = v.HumanoidRootPart
            local newDistance = (self.root.Position - targetRoot.Position).magnitude
            if newDistance < currentDistance then
                currentDistance = newDistance
                newTarget = targetRoot
                targetCharacter = v
            end
        end
    end

    return newTarget, currentDistance, targetCharacter
end

function BaseClass:Idle()
    if self.attributes.IdleTime then wait(self.attributes.IdleTime)
    else wait(1)
    end
    self:Wander()
end

-- Component Functions
function BaseClass:HeartbeatUpdate()
    self.target, self.targetDistance, self.targetCharacter = self:TargetPriority()
    if self.targetDistance <= self.attributes.AggroRange and self.currentEvent ~= "Aggro" and self.aggroDebounce then
        if not self.currentEvent == "Nothing" then
            self:AbortMovement()
        end
        self:Aggro()
    end
end

function BaseClass:SetNetworkOwner()
    for _, desc in pairs(self.monsterCharacter:GetDescendants()) do
        if desc:IsA("BasePart")then
            desc:SetNetworkOwner(nil)
        end
    end
end

function BaseClass:BaseInit()
    self:SetNetworkOwner()
    self.humanoid.Jump = true
    self:Idle()
end

function BaseClass:Init()
    self:BaseInit()
end

function BaseClass:OnDeath()
    wait(5)
    self.monsterCharacter:Destroy()
end

function BaseClass:Destroy()
    self._janitor:Destroy()
end

return BaseClass