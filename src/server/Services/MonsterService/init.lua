local Knit = require(game:GetService("ReplicatedStorage").Knit)
local classes = require(Knit.MonsterClasses)

local MonsterService = Knit.CreateService {
    Name = "MonsterService";
    Client = {};
    LoadedMonsters = {};
}

function MonsterService:LoadMonsters(monsterFolder)
    self.LoadedMonsters[monsterFolder] = {}

    -- Loading the Scripts to the Monsters
    local monsterClasses = {
        ["Base"] = classes.BaseClass
    }

    for i,v in pairs(monsterFolder) do
        local class = v:GetAttribute()
        local monster = monsterClasses[class].new(v)

        self.LoadedMonsters[monsterFolder][i] = monster
    end
end


function MonsterService:KnitStart()
    
end


function MonsterService:KnitInit()
    
end


return MonsterService