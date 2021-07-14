local Knit = require(game:GetService("ReplicatedStorage").Knit)

local MonsterService = Knit.CreateService {
    Name = "MonsterService";
    Client = {};
    LoadedMonsters = {};
}

function MonsterService:LoadMonsters(monsterFolder)
    self.LoadedMonsters[monsterFolder] = {}

    -- Loading the Scripts to the Monsters
    local monsterHeirarchy = {
        ["Base"] = script.BaseClass
    }

    for i,v in pairs(monsterFolder) do
        local class = v:GetAttribute()
        local monster = monsterHeirarchy[class].new(v)

        self.LoadedMonsters[monsterFolder][i] = monster
    end
end


function MonsterService:KnitStart()
    local class = require(script.BaseClass.HearingClass)
    local newClass = class.new(workspace.Mummy)
    print(newClass)
end


function MonsterService:KnitInit()
    
end


return MonsterService