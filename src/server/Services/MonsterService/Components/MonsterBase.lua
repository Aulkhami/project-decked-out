-- Services
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
-- Knit Modules
local Signal = require(Knit.Util.Signal)
local Switch = require(Knit.Modules.Switch)
-- Knit Services
local MonsterService = Knit.GetService("MonsterService")
local AnimationService = Knit.GetService("AnimationService")

local MonsterBase = {}
MonsterBase.__index = MonsterBase
-- Component
MonsterBase.Tag = "MonsterBase"


function MonsterBase.new(monster) -- Constructor
    local self = setmetatable({
    -- Properties
        attributes = monster:GetAttributes();
        currentEvent = "Nothing";
        eventList = {"Aggro", "Wander", "Nothing"};
        monsterCharacter = monster;
        root = monster.HumanoidRootPart;
        humanoid = monster.Humanoid;
        loadedAnimations = {};
        weapons = {};
        hitBoxes = {};
    -- Variables
        raiders = workspace.Dungeon.Raiders;
        target = nil;
        targetDistance = nil;
        targetCharacter = nil;
        aggroDebounce = true;
        path = nil;
        pathObject = nil;
        currentWaypointIndex = 0;
    }, MonsterBase)

    -- Setting Class Attributes
    if self.attributes.Class then
        local class = MonsterService.GetClass(self.attributes.Class, self.attributes.Hierarchy)
        for i,v in pairs(class) do
            monster:SetAttribute(i,v)
        end
        self.attributes = monster:GetAttributes()
        self.humanoid.WalkSpeed = self.attributes.BaseSpeed
    end

    -- Loading Bodyparts
    local children = self.monsterCharacter:GetChildren()
    self.bodyparts = {}
    for _, v in pairs(children) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            self.bodyparts[v.Name] = v
        end
    end
    print(self.bodyparts)

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
    self.OnHeard = Signal.new(self._janitor)

    return self
end

function MonsterBase:EventChange(newEvent, chaseType, chaseValue) -- A function to prioritize certain Events over the other, and changing the current Event to the higher priority Event.
    local currentPriority = table.find(self.eventList, self.currentEvent)
    local newPriority = table.find(self.eventList, newEvent)

    local eventConditional = Switch()
    :case("Chase", function()
        local currentChasePriority = table.find(self.chaseList, self.currentChase)
        local newChasePriority = table.find(self.chaseList, chaseType)

        if newPriority <= currentPriority and chaseValue > 0 then
            if newChasePriority == currentChasePriority and chaseValue > self.chaseValue then
                self.currentEvent = newEvent
                print("Changed Event to", self.currentEvent)
                return true
            elseif newChasePriority < currentChasePriority then
                self.currentEvent = newEvent
                self.currentChase = chaseType
                print("Changed Event to", self.currentEvent)
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

        print("Changed Event to", self.currentEvent)
        self.IdleEvent:Fire()
    end)
    :default(function()
        if newPriority < currentPriority then
            self.currentEvent = newEvent
            print("Changed Event to", self.currentEvent)
            return true
        else
            return false
        end
    end)

    return eventConditional(newEvent)
end

-- Pathfinding and Movement

function MonsterBase:Pathfind(target) -- Pathfinding
    local agentParameters = {
        AgentRadius = self.attributes.Radius;
        AgentHeight = self.attributes.Height;
        AgentCanJump = self.attributes.CanJump;
    }
    local path = PathfindingService:CreatePath(agentParameters)
    path:ComputeAsync(self.root.position, target)

    if path.Status == Enum.PathStatus.Success then
        return path:GetWaypoints(), path
    else
        path:Destroy()
        path = nil
        return false
    end
end

function MonsterBase:MoveTo(reached) -- Move to current waypoint in the path
    self.currentWaypointIndex += 1
    if reached and self.currentWaypointIndex <= #self.path then
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

function MonsterBase:PathBlocked(blockedWaypointIndex) -- Runs when the Path from the Pathfinding gets blocked
    if blockedWaypointIndex >= self.currentWaypointIndex then
        self:AbortMovement()
    end
end

function MonsterBase:StartMovement(target) -- Start Pathfinded Movement to specified Target
    -- Pathfinding
    local path, pathObject = self:Pathfind(target)
    -- Starting Movement
    if path then
        self.path, self.pathObject = path, pathObject
        self._janitor:Add(self.pathObject, nil, "Path")
        -- Events
        self._janitor:Add(self.humanoid.MoveToFinished:Connect(function(reached) self:MoveTo(reached)
        end), nil, "MoveCleanup")
        self._janitor:Add(self.pathObject.Blocked:Connect(function(blockedWaypointIndex) self:PathBlocked(blockedWaypointIndex)
        end), nil, "BlockCleanup")
        -- MoveTo 1st Waypoint
        self:MoveTo(true)

        return true
    else
        return false
    end
end

function MonsterBase:AbortMovement() -- Aborts Current Pathfinded Movement
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

-- Senses

function MonsterBase:CheckSight(target, origin, params)
    local raycastParams
    if params then
        raycastParams = params
    else
        raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {self.monsterCharacter}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    end

    local rayOrigin = origin.Position
    local rayDirection = (target.Position - rayOrigin)

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return result
end

function MonsterBase:Heard(loudness, source)
    local distance = math.abs((self.root.Position - source.Position).Magnitude)
    local hearingMultiplier = self.attributes.HearingMultiplier

    local finalLoudness = (loudness * hearingMultiplier) - distance
    self.OnHeard:Fire(finalLoudness, source)
end

-- Monster Logic Loop

function MonsterBase:TargetPriority()
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

-- Component Functions

function MonsterBase:SetNetworkOwner()
    for _, desc in pairs(self.monsterCharacter:GetDescendants()) do
        if desc:IsA("BasePart")then
            desc:SetNetworkOwner(nil)
        end
    end
end

function MonsterBase:Init()
    -- Setting the Network Owner
    self:SetNetworkOwner()
    -- Connecting Events
    self.humanoid.Died:Connect(function() self:OnDeath()
    end)
    -- Adding Collision Groups
    for _, v in pairs(self.monsterCharacter:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            PhysicsService:SetPartCollisionGroup(v, "Character")
        end
    end
    -- Idling
    RunService.Heartbeat:Wait()
    self.humanoid.Jump = true
end

function MonsterBase:OnDeath()
    wait(5)
    self.monsterCharacter:Destroy()
end

function MonsterBase:Destroy()
    self._janitor:Destroy()
end

return MonsterBase