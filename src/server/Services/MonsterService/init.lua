local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonsterService = Knit.CreateService {
    Name = "MonsterService";
    Client = {};
    LoadedMonsters = {};
    LatestNumber = 0;
}

function MonsterService:LoadMonster(monster)
    -- Loading the Script to the Specified Monster
    local monsterHierarchy = {
        ["Base"] = require(script.BaseClass)
    }

    local class = monsterHierarchy[monster:GetAttribute("Hierarchy")]
    print(class)
    local newClass = class.new(monster)
    -- Monster ID
    local monsterID = self.LatestNumber + 1
    self.LoadedMonsters[monsterID] = newClass
    self.LatestNumber = monsterID
end

function MonsterService:LoadMonsters(monsterFolder)
    -- Loading the Scripts to the Monsters
    for _,v in pairs(monsterFolder) do
        self:LoadMonster(v)
    end
end

function MonsterService.GetHitBox(hitBox)
    local Model = ReplicatedStorage.Model
    local hitBoxes = {
        ["Default"] = Model.HitBox.Default;
    }

    return hitBoxes[hitBox]
end

function MonsterService.GetClass(class)
    local classes = {
        -- Base Class
        ["Base"] = {
            HP = 100;
            Damage = 100;
            BaseSpeed = 16;
            AggroRange = 50;
            IdleTime = 1;
            AttackRange = 2;
            HitBox = "Default";
        };
        -- Hearing Class
        ["Mummy"] = {
            HP = 100;
            Damage = 80;
            BaseSpeed = 16;
            WanderSpeed = 0.5;
            ChaseSpeed = 0.95;
            AggroSpeed = 1.5;
            IdleTime = 2;
            AggroRange = 5;
            MinHear = 30;
            AttackRange = 2;
        };
    }

    return classes[class]
end

function MonsterService:KnitStart()
    wait(11)
    self:LoadMonster(workspace.Dummy)
    print(self.LoadedMonsters[1], getmetatable(self.LoadedMonsters[1]))
    self.LoadedMonsters[1]:StartMovement(workspace.Target.Position)
end


function MonsterService:KnitInit()
    
end


return MonsterService