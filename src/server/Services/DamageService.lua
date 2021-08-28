--[[
    This Service's purpose is to deal and calculate the final damage of attacks/other damaging things.
]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local DamageService = Knit.CreateService {
    Name = "DamageService";
    Client = {};
}


function DamageService.DealDamage(humanoid, damage, impactParams, impact, modifier)
    -- Setting the Defender's Defense
    local defense = 0
    local defenseAttribute = humanoid.Parent:GetAttribute("Defense")
    if defenseAttribute then defense = defenseAttribute
    end
    -- Calculating finalDamage
    local finalDamage
    if modifier then
        finalDamage = ((damage * impactParams[impact]) * modifier) - defense
    else
        finalDamage = (damage * impactParams[impact]) - defense
    end

    humanoid:TakeDamage(finalDamage)
end

function DamageService:KnitStart()
    
end


function DamageService:KnitInit()
    
end


return DamageService