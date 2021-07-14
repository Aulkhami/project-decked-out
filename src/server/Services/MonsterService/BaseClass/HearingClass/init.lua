local Knit = require(game:GetService("ReplicatedStorage").Knit)

local HearingClass = require(script.Parent)
HearingClass.__index = HearingClass


function HearingClass.new(monster)
    local self = setmetatable({
    -- Properties
        attributes = monster:GetAttributes();
        currentEvent = "Wander";
        eventList = {"Aggro", "Chase", "Wander"};
        monsterModel = monster;
        root = monster.HumanoidRootPart;
        humanoid = monster.Humanoid;
    }, HearingClass)
    -- Setting Attributes
    local classes = {
        ["Mummy"] = {
            HP = 100;
            Damage = 80;
            BaseSpeed = 16;
            WanderSpeed = 0.5;
            ChaseSpeed = 0.95;
            AggroSpeed = 1.5;
            MinHear = 30;
        }
    }

    for i,v in pairs(classes[self.attributes.MonsterClass]) do
        monster:SetAttribute(i,v)
    end
    self.attributes = monster:GetAttributes()

    return self
end


function HearingClass:Destroy()
    
end


return HearingClass