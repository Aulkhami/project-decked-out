local Knit = require(game:GetService("ReplicatedStorage").Knit)
--local Component = require(Knit.Util.Component)
--local Janitor = require(Knit.Util.Janitor)

local ParentClass = require(script.Parent)
local HearingClass = {}
HearingClass.__index = HearingClass
setmetatable(HearingClass, ParentClass)
-- Component
HearingClass.Tag = "Monster:HearingClass"


function HearingClass.new(instance)
    local self = setmetatable(ParentClass.new(instance), HearingClass)

    return self
end

function HearingClass:Destroy()
    self._janitor:Destroy()
end


return HearingClass