local Knit = require(game:GetService("ReplicatedStorage").Knit)
local TweenService = game:GetService("TweenService")
local Janitor = require(Knit.Util.Janitor)
local Component = require(Knit.Util.Component)

local MonsterBasicAttack = {}
MonsterBasicAttack.__index = MonsterBasicAttack

MonsterBasicAttack.Tag = "MonsterBasicAttack"
MonsterBasicAttack.RequiredComponents = {"MonsterBase", "MonsterCombat"}


function MonsterBasicAttack.new(monster)
    local self = setmetatable({}, MonsterBasicAttack)
    self._b = Component.FromTag("MonsterBase"):GetFromInstance(monster)
    self._c = Component.FromTag("MonsterCombat"):GetFromInstance(monster)
    self._janitor = Janitor.new()

    self.attackAnimation = nil

    return self
end


function MonsterBasicAttack:Attack()
    self._b.humanoid:ChangeState(Enum.HumanoidStateType.None)
    -- Face the Monster towards the Target
    local rootPos = self._b.root.Position
    local targetPos = self._b.target.Position

    local lookAtVector3 = Vector3.new(targetPos.X, rootPos.Y, targetPos.Z)
    local rotation = CFrame.lookAt(rootPos, lookAtVector3)

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local goal = {}
    goal.CFrame = rotation
    self._b.root.Position = self._b.root.Position
    local tween = TweenService:Create(self._b.root, tweenInfo, goal)
    tween:Play()

    -- Attacking the Target
    -- Animation
    local attackAnimation = self._b.loadedAnimations[self.attackAnimation]
    attackAnimation:Play()
    self._janitor:Add(attackAnimation:GetMarkerReachedSignal("Landing"):Connect(function(condition)
        if condition == "Start" then
            print("Hitbox activated")
            self._c.hitboxes[self._c.currentHitbox]:HitStart()
        elseif condition == "End" then
            print("Hitbox deactivated")
            self._c.hitboxes[self._c.currentHitbox]:HitStop()
        end
    end), nil, "AttackAnimationEvent")

    attackAnimation.Stopped:Wait()
    self._janitor:Remove("AttackAnimationEvent")
end

function MonsterBasicAttack:Init()
end


function MonsterBasicAttack:Deinit()
end


function MonsterBasicAttack:Destroy()
    self._janitor:Destroy()
end


return MonsterBasicAttack