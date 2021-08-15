local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Component = require(Knit.Util.Component)
local MonsterService
local DungeonReplicated = ReplicatedStorage.Dungeon

local MapService = Knit.CreateService {
    Name = "MapService";
    Client = {};
    LoadedMap = nil;
}


function MapService:LoadMap(map)
    local mapDatabase = {
        -- Sands of Beginnings
        ["SoBL01"] = DungeonReplicated.A01SoB.L01;
    }

    -- Getting NewMap from the Map Database and Cloning it into Workspace
    local newMap = mapDatabase[map]:Clone()
    newMap.Parent = workspace
    newMap.Name = "Dungeon"
    self.LoadedMap = map

    -- Loading the Players PLACEHOLDER
    local tester1, tester2 = workspace:WaitForChild("Rakha2828"), workspace:WaitForChild("Erabungo")
    tester1.Parent = newMap.Raiders
    tester2.Parent = newMap.Raiders

    -- Loading the Monsters PLACEHOLDER
    MonsterService:LoadMonsters(newMap.Monsters:GetChildren())

    -- Loading the Treasure PLACEHOLDER
    CollectionService:AddTag(newMap.Map:FindFirstChild("Treasure", true), "Treasure")
end


function MapService:KnitStart()
    -- Getting other Services
    MonsterService = Knit.GetService("MonsterService")
    -- Loading Components
    Component.Auto(script)

    self:LoadMap("SoBL01")
end


function MapService:KnitInit()

end


return MapService