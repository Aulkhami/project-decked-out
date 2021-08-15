local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)

local Treasure = {}
Treasure.__index = Treasure

Treasure.Tag = "Treasure"


function Treasure.new(instance)
    local self = setmetatable({}, Treasure)
    self.instance = instance
    self._janitor = Janitor.new()

    return self
end


function Treasure:Init()
    self.instance.Touched:Connect(function()
        local sound = Instance.new("Sound")
        sound.Parent = self.instance
        sound.SoundId = "rbxassetid://6335911565"
        sound:Play()
    end)
end


function Treasure:Deinit()
end


function Treasure:Destroy()
    self._janitor:Destroy()
end


return Treasure