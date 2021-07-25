local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

    -- Loading the Monsters
end


function MapService:KnitStart()
    self:LoadMap("SoBL01")
    wait(10)
    workspace.Rakha2828.Parent = workspace.Dungeon.Raiders
    print("Wake up samurai")
end


function MapService:KnitInit()
    
end


return MapService