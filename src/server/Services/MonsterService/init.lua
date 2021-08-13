local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Component = require(Knit.Util.Component)
local Asset = ReplicatedStorage.Asset

local MonsterService = Knit.CreateService {
    Name = "MonsterService";
    Client = {};
    LoadedMonsters = {};
    LatestNumber = 0;
}


function MonsterService:LoadMonster(monster)
    -- Loading the Script to the Specified Monster
    local monsterHierarchy = {
        ["Base"] = "Monster:BaseClass";
        ["Hearing"] = --[[{"Monster:BaseClass",]] "Monster:HearingClass"--};
    }

    local class = monsterHierarchy[monster:GetAttribute("Hierarchy")]
    --[[if type(class) == "table" then
        for _,v in pairs(class) do
            CollectionService:AddTag(monster, v)
        end
    else
        CollectionService:AddTag(monster, class)
    end]]
    CollectionService:AddTag(monster, "Monster")
    CollectionService:AddTag(monster, class)

    -- Monster ID
    local monsterID = self.LatestNumber + 1
    self.LoadedMonsters[monsterID] = monster
    monster.Humanoid.Died:Connect(function() self:UnloadMonster(monsterID)
    end)
    self.LatestNumber = monsterID
end

function MonsterService:LoadMonsters(monsterFolder)
    -- Loading the Scripts to the Monsters
    for _,v in pairs(monsterFolder) do
        self:LoadMonster(v)
    end
end

function MonsterService:UnloadMonster(monsterID)
    self.LoadedMonsters[monsterID] = nil
end

function MonsterService.GetHitBox(hitBox)
    local hitBoxes = {
        ["Default"] = Asset.HitBox.Default;
    }

    if type(hitBox) == "table" then
        local hitBoxTable
        for _, v in pairs(hitBox) do
            table.insert(hitBoxTable, hitBoxes[v])
        end

        return hitBoxTable
    else
        return hitBoxes[hitBox]
    end
end

function MonsterService.FindAnimationsForClass(classAnimation)
    local animations = {
        ["Default"] = {"DefaultHeavyAttack"};
        ["Base"] = {"DefaultHeavyAttack"};
    }

    if classAnimation then
        if animations[classAnimation] then
            return animations[classAnimation]
        else
            warn("Can't Find Animations for", classAnimation)
            return animations["Default"]
        end
    else
        return animations["Default"]
    end
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
            AggroSpeed = 1.25;
            IdleTime = 2;
            AggroRange = 10;
            AttackRange = 2;
            HearingMultiplier = 2;
            HitBox = "Default";
        };
    }

    if classes[class] then
        return classes[class]
    else
        warn(class, "is not a valid Class")
    end
end

function MonsterService:KnitStart()
    Component.Auto(script) -- Loads all the classes
end


function MonsterService:KnitInit()
    
end


return MonsterService