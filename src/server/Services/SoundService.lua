--[[
    SoundService's purpose is to fire the Heard event whenever there is a sound played, and stores the "Loudness" of a sound. (which is a very unrealistic number)
]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Signal = require(Knit.Util.Signal)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)
local RemoteProperty = require(Knit.Util.Remote.RemoteProperty)


local SoundService = Knit.CreateService {
    Name = "SoundService";
    Client = {
        SoundPlayed = RemoteSignal.new()
    };
    SoundLoudness = {
        ["Running"] = 75;
        ["Jumping"] = 100;
        ["Landing"] = 125;
    };
    Heard = Signal.new();
}
-- Variables
SoundService.Client.SoundLoudness = RemoteProperty.new(SoundService.SoundLoudness);
SoundService.Client.SoundLoudness:Replicate()


function SoundService:SoundPlayed(sound, source)
    local soundName = sound.Name

    if self.SoundLoudness[soundName] then
        self.Heard:Fire(self.SoundLoudness[soundName], source)
    end
end

function SoundService:KnitStart()

end

function SoundService:KnitInit()
    -- Event Connections
    self.Client.SoundPlayed:Connect(function(_, loudness, source)
        self.Heard:Fire(loudness, source)
    end)
end


return SoundService