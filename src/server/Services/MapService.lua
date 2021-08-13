local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    local tester = workspace:WaitForChild("Rakha2828")
    tester.Parent = newMap.Raiders

    -- Loading the Monsters PLACEHOLDER
    MonsterService:LoadMonsters(newMap.Monsters:GetChildren())
end


function MapService:KnitStart()
    -- Getting other Services
    MonsterService = Knit.GetService("MonsterService")

    self:LoadMap("SoBL01")
end


function MapService:KnitInit()
    
end


return MapService