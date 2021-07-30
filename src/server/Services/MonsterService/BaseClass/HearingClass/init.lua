local Knit = require(game:GetService("ReplicatedStorage").Knit)

local ParentClass = require(script.Parent)
local HearingClass = {}
HearingClass.__index = HearingClass
setmetatable(HearingClass, ParentClass)


function HearingClass.new(monster)
    local self = setmetatable(ParentClass.new(monster), HearingClass)

    return self
end


function HearingClass:Destroy()
    
end


return HearingClass