local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)
local Component = require(Knit.Util.Component)
local Signal = require(Knit.Util.Signal)
local SoundService = Knit.GetService("SoundService")

local HearingClass = {}
HearingClass.__index = HearingClass

HearingClass.Tag = "HearingClass"
HearingClass.RequiredComponents = {"MonsterBase", "MonsterMovement", "MonsterCombat", "MonsterBasicAttack"}


function HearingClass.new(monster)
    local self = setmetatable({}, HearingClass)
    self._b = Component.FromTag("MonsterBase"):GetFromInstance(monster)
    self._m = Component.FromTag("MonsterMovement"):GetFromInstance(monster)
    self._c = Component.FromTag("MonsterCombat"):GetFromInstance(monster)
    self._a = Component.FromTag("MonsterBasicAttack"):GetFromInstance(monster)
    self._janitor = Janitor.new()

    self._b.eventList = {"Aggro", "Chase", "Wander", "Nothing"}
    self._b.chaseList = {"Heard", "Nothing"}
    self._b.currentChase = "Nothing"
    self._b.heardTarget = nil
    self._b.chaseValue = 0

    self._a.attackAnimation = "HeavyAttack"
    self._c.currentHitbox = "UnarmedHitbox"

    self.Attack = Signal.new(self._janitor)
    self.AttackFinished = Signal.new(self._janitor)

    return self
end


function HearingClass:OnHeard(finalLoudness, source)
    if self._b:EventChange("Chase", "Heard", finalLoudness) then
        self._b.chaseValue = finalLoudness

        self.heardTarget = source
        self._m:Chase(self.heardTarget)
    end
end

function HearingClass:HeartbeatUpdate()
    self._b.target, self._b.targetDistance, self._b.targetCharacter = self._b:TargetPriority()
    if self._b.targetDistance <= self._b.attributes.AggroRange and self._b.currentEvent ~= "Aggro" then
        local sight = self._b:CheckSight(self._b.target, self._b.root)
        if sight and sight.Instance.Parent == self._b.targetCharacter then
            self._m:Aggro(self.Attack, self.AttackFinished)
        end
    end
end

function HearingClass:Idle()
    wait(self._b.attributes.IdleTime)
    self._m:Wander()
end

function HearingClass:Init()
    -- Connecting Events
    self._janitor:Add(self._b.IdleEvent:Connect(function() self:Idle()
    end))
    self._janitor:Add(SoundService.Heard:Connect(function(loudness, source) self._b:Heard(loudness, source)
    end))
    self._janitor:Add(self._b.OnHeard:Connect(function(finalLoudness, source) self:OnHeard(finalLoudness, source)
    end))
    self.Attack:Connect(function()
        self._a:Attack()
        self.AttackFinished:Fire()
    end)
    -- Idling
    self:Idle()
end

function HearingClass:Destroy()
    self._janitor:Destroy()
end


return HearingClass