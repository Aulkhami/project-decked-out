local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)
local Component = require(Knit.Util.Component)
local RaycastHitbox = require(Knit.Modules.RaycastHitbox)
local Switch = require(Knit.Modules.Switch)
local MonsterService = Knit.GetService("MonsterService")
local DamageService = Knit.GetService("DamageService")

local MonsterCombat = {}
MonsterCombat.__index = MonsterCombat

MonsterCombat.Tag = "MonsterCombat"
MonsterCombat.RequiredComponents = {"MonsterBase"}


function MonsterCombat.new(monster)
    local self = setmetatable({}, MonsterCombat)
    self._b = Component.FromTag("MonsterBase"):GetFromInstance(monster)
    self._janitor = Janitor.new()
    self.hitboxes = {}
    self.currentHitbox = nil

    -- Loading Unarmed Hitbox (you know, when you're unarmed, you use your arms to fight, instead of your arms.)
    local hitboxPointsParameters = MonsterService.GetHitbox(self._b.attributes.UnarmedHitbox)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {self._b.monsterCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    self.hitboxes["UnarmedHitbox"] = RaycastHitbox.new(self._b.monsterCharacter)
    self.hitboxes["UnarmedHitbox"].RaycastParams = raycastParams
    for _, v in pairs(hitboxPointsParameters) do
        for _, part in pairs(v["Parts"]) do
            self.hitboxes["UnarmedHitbox"]:SetPoints(self._b.bodyparts[part], v["Vector"], v["GroupName"])
        end
    end

    return self
end


function MonsterCombat.GetImpactParams(hitboxType, weapon)
    local impactParams = {
        ["UnarmedHitbox"] = {
            ["Arm"] = {
                ["Normal"] = 1;
                ["Light"] = 0.75
            };
        };
    }

    return impactParams[hitboxType][weapon]
end

function MonsterCombat:Init()
    local hitboxConnection = Switch()
    :case("UnarmedHitbox", function()
        return function(_, humanoid, _, groupName)
            DamageService.DealDamage(humanoid, self._b.attributes.Damage, self.GetImpactParams("UnarmedHitbox", self._b.attributes.UnarmedWeapon), groupName)
        end
    end)
    :default(function()
        return function(humanoid)
            humanoid:TakeDamage(self._b.attributes.Damage)
        end
    end)

    for i, v in pairs(self.hitboxes) do
        v.OnHit:Connect(hitboxConnection(i))
    end
end

function MonsterCombat:Destroy()
    self._janitor:Destroy()
end


return MonsterCombat