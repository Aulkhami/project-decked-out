local Knit = require(game:GetService("ReplicatedStorage").Knit)

Knit.AddServices(script.Services)
print("Adding Services")
Knit.MonsterClasses = script.Services.MonsterService:GetDescendants()
print("Adding Monster Classes")

Knit:Start():Catch(warn):Await()