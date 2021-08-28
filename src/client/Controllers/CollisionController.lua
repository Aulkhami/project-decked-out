local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local CollisionController = Knit.CreateController {
    Name = "CollisionController";
    Player = Players.LocalPlayer
}


function CollisionController:SetCollisionGroup(collisionGroup)
    for _, v in pairs(self.Player.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            PhysicsService:SetPartCollisionGroup(v, collisionGroup)
        end
    end
end

function CollisionController:KnitStart()
    if not self.Player.Character then
        self.Player.CharacterAdded:Wait()
    end

    self:SetCollisionGroup("Character")
end


function CollisionController:KnitInit()
    
end


return CollisionController