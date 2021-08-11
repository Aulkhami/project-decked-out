--[[
    SoundController's purpose is when a sound is played, Fire the Heard event in SoundService for the Monsters.
]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Players = game:GetService("Players")
local SoundService = Knit.GetService("SoundService")
print(Knit.Modules)

local SoundController = Knit.CreateController {
    Name = "SoundController";
    Player = Players.LocalPlayer;
    LoadedSounds = {};
}


function SoundController:LoadSounds()
    local character = self.Player.Character
    local sounds = character:WaitForChild("HumanoidRootPart"):GetChildren()
    for _, v in ipairs(sounds) do
        if v.ClassName == "Sound" then
            table.insert(self.LoadedSounds, v)
        end
    end
end

function SoundController:ConnectEvent()
    local SoundLoudness = SoundService.SoundLoudness:Get()

    for _, v in pairs(self.LoadedSounds) do
        if SoundLoudness[v.Name] then
            v:GetPropertyChangedSignal("Playing"):Connect(function()
                if v.Playing then
                    while v.Playing do
                        SoundService.SoundPlayed:Fire(SoundLoudness[v.Name], self.Player.Character.HumanoidRootPart)
                        wait(1)
                    end
                end
            end)
        end
    end
end

function SoundController:KnitStart()
    if not self.Player.Character then
        self.Player.CharacterAdded:Wait()
    end

    SoundController:LoadSounds()
    SoundController:ConnectEvent()
end


function SoundController:KnitInit()
    
end


return SoundController