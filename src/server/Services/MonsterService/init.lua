local Knit = require(game:GetService("ReplicatedStorage").Knit)
local CollectionService = game:GetService("CollectionService")
local Component = require(Knit.Util.Component)
local TableUtil = require(Knit.Util.TableUtil)

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
        ["Hearing"] = {"MonsterBase", "MonsterMovement", "MonsterCombat", "MonsterBasicAttack", "HearingClass"};
    }

    local class = monsterHierarchy[monster:GetAttribute("Hierarchy")]
    if type(class) == "table" then
        for _,v in pairs(class) do
            CollectionService:AddTag(monster, v)
        end
    else
        CollectionService:AddTag(monster, class)
    end
    CollectionService:AddTag(monster, "Monster")

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

function MonsterService.GetHitbox(hitboxType)
    local hitboxes = {
        ["ArmHitbox"] = {
            [1] = {
                ["Parts"] = {"RightHand", "LeftHand"};
                ["Vector"] = {Vector3.new(0, 0, 0)};
                ["GroupName"] = "Normal"
            };
            [2] = {
                ["Parts"] = {"RightLowerArm", "LeftLowerArm"};
                ["Vector"] = {Vector3.new(0, 0, 0)};
                ["GroupName"] = "Light"
            }
        };
    }

    if hitboxes[hitboxType] then
        return hitboxes[hitboxType]
    else
        return hitboxes["ArmHitbox"]
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

function MonsterService.GetClass(class, hierarchy)
    print(class, hierarchy)
    local template = {
        ["Base"] = {
            -- Body Data
            Radius = 2;
            Height = 5;
            CanJump = true;
            -- Stats
            HP = 100;
            Damage = 100;
            BaseSpeed = 16;
            WanderSpeed = 1;
            ChaseSpeed = 1;
            AggroSpeed = 1;
            IdleTime = 1;
            AggroRange = 50;
            AttackRange = 5;
            -- Data
            UnarmedWeapon = "Arm";
            UnarmedHitbox = "ArmHitbox"
        };
        ["Hearing"] = {
            -- Body Data
            Radius = 2;
            Height = 5;
            CanJump = true;
            -- Stats
            HP = 100;
            Damage = 100;
            BaseSpeed = 16;
            WanderSpeed = 1;
            ChaseSpeed = 1;
            AggroSpeed = 1;
            IdleTime = 1;
            AggroRange = 20;
            AttackRange = 5;
            HearingMultiplier = 1;
            -- Data
            UnarmedWeapon = "Arm";
            UnarmedHitbox = "ArmHitbox"
        }
    }
    local classes = {
        -- Base Class
        ["Base"] = {
            HP = 100;
            Damage = 100;
            BaseSpeed = 16;
            IdleTime = 1;
            AggroRange = 50;
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
            HearingMultiplier = 2;
        };
    }

    if classes[class] then
        return TableUtil.Sync(classes[class], template[hierarchy])
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