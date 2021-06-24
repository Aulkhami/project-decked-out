local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonReplicated = ReplicatedStorage.Dungeon
local Dungeon = workspace.Dungeon

local MapService = Knit.CreateService {
    Name = "MapService";
    Client = {};
    LoadedMap = {};
}


function MapService:LoadMap(map)
    local mapDatabase = {
        -- Sands of Beginnings
        ["SoBL01"] = {
            map = DungeonReplicated.A01SoB.L01;
            mapDir = Dungeon.A01SoB.L01
        };
    }

    -- Getting NewMap from the Map Database and Cloning it into Workspace
    local newMap = mapDatabase[map].map:Clone()
    newMap.Parent = mapDatabase[map].mapDir
    -- Getting the NewMap's ID
    local mapID
    while true do
        mapID = math.random(1000,9999)
        if not table.find(self.LoadedMap,mapID) then
            break
        end
    end
    newMap.Name = mapID
    
    -- Adding newMap to LoadedMap
    self.LoadedMap[mapID] = newMap
    
    -- Loading the Monsters
end


function MapService:KnitStart()
    self:LoadMap("SoBL01")
end


function MapService:KnitInit()
    
end


return MapService