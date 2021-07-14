local Knit = require(game:GetService("ReplicatedStorage").Knit)
local PathfindingService = game:GetService("PathfindingService")

local BasicClass = {}
BasicClass.__index = BasicClass


function BasicClass.new(monster)
    local self = setmetatable({
    -- Properties
        attributes = monster:GetAttributes();
        currentEvent = "Wander";
        eventList = {"Aggro", "Wander"};
        monsterModel = monster;
        root = monster.HumanoidRootPart;
        humanoid = monster.Humanoid;
    }, BasicClass)
    -- Events
    self._maid = Knit.Util.Maid

    return self
end

function BasicClass:EventChange(newEvent)
    local currentPriority = table.find(self.eventList, self.currentEvent)
    local newPriority = table.find(self.eventList, newEvent)

    if newPriority < currentPriority then
        self.currentEvent = newEvent
    end
end

function BasicClass:Pathfind(target)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(self.root.position, target)
end

function BasicClass:Hello()
    print("Hello!")
end

function BasicClass:Destroy()

end

return BasicClass