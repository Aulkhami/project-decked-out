local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Knit.Modules = ReplicatedStorage.Common.Modules
print("Loading Modules")
Knit.AddControllers(script.Controllers)
print("Adding Controllers")

Knit:Start():Catch(warn):Await()