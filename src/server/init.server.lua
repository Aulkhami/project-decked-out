local Knit = require(game:GetService("ReplicatedStorage").Knit)

Knit.AddServices(script.Services)
print("Adding Services")

Knit:Start():Catch(warn):Await()

print(workspace.TestDummy.HumanoidRootPart.CFrame.LookVector)