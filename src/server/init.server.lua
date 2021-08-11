local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Knit.Modules = ReplicatedStorage.Common.Modules
print("Loading Modules")
Knit.AddServices(script.Services)
print("Adding Services")

Knit:Start():Catch(warn):Await()