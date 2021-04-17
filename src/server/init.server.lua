local Knit = require(game:GetService("ReplicatedStorage").Knit)

Knit.AddServices(script.Services)

Knit:Start():Catch(warn):Await()