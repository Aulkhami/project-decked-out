local Knit = require(game:GetService("ReplicatedStorage").Knit)
local RunService = game:GetService("RunService")
local Janitor = require(Knit.Util.Janitor)
local Component = require(Knit.Util.Component)

local MonsterMovement = {}
MonsterMovement.__index = MonsterMovement

MonsterMovement.Tag = "MonsterMovement"
MonsterMovement.RequiredComponents = {"MonsterBase"}


function MonsterMovement.new(monster)
    local self = setmetatable({}, MonsterMovement)
    self._b = Component.FromTag("MonsterBase"):GetFromInstance(monster)
    self.aggroDebounce = false
    self._janitor = Janitor.new()

    return self
end


function MonsterMovement:ChangeSpeed(speedMod) -- Changes the Monster's Humanoid Walkspeed if the Monster has Speed Modifiers
    local speedModAttr = self._b.attributes[speedMod]
    if speedModAttr then
        self._b.humanoid.WalkSpeed = (self._b.attributes.BaseSpeed * speedModAttr)
    end
end

function MonsterMovement:Wander()
    if self._b:EventChange("Wander") then
        self:ChangeSpeed("WanderSpeed")
        -- Randomizing Coordinate
        local xRand = math.random(-50,50)
        local zRand = math.random(-50,50)
        local target = self._b.root.Position + Vector3.new(xRand,0,zRand)

        local pathfinded = self._b:StartMovement(target)
        if not pathfinded then
            self._b.currentEvent = "Nothing"
            self:Wander()
        end
    end
end

function MonsterMovement:Chase(target)
    local goal = target.Position
    self:ChangeSpeed("ChaseSpeed")
    local pathfinded = self._b:StartMovement(goal)

    if not pathfinded then
        self._b:EventChange("Nothing")
    end
end

function MonsterMovement:Aggro(attackSignal, attackFinishedSignal) -- Aggroes the Monster's Target. Aggro is the highest priority Event, which is why it uses a while loop instead of an event loop.
    if not self.aggroDebounce then
        self.aggroDebounce = true
        if self._b.currentEvent ~= "Nothing" then
            self._b:AbortMovement()
        end
        if self._b:EventChange("Aggro") then

            local oldTarget = self._b.targetCharacter
            self:ChangeSpeed("AggroSpeed")
            while self._b.targetDistance <= self._b.attributes.AggroRange do
                RunService.Heartbeat:Wait()
                if not self._b.target or oldTarget.Name ~= self._b.targetCharacter.Name then break
                end
                self._b.humanoid:MoveTo(self._b.target.Position)
                if self._b.targetDistance <= self._b.attributes.AttackRange then -- Fires the Signal passed
                    print("Attacking")
                    attackSignal:Fire()
                    attackFinishedSignal:Wait()
                    print("Finshed Attacking")
                end
            end

            self._b:EventChange("Nothing")
            self.aggroDebounce = false
            return true
        else
            self.aggroDebounce = false
            return false
        end
    else
        return false
    end
end

function MonsterMovement:Init()
end


function MonsterMovement:Deinit()
end


function MonsterMovement:Destroy()
    self._janitor:Destroy()
end


return MonsterMovement