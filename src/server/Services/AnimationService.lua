local Knit = require(game:GetService("ReplicatedStorage").Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asset = ReplicatedStorage.Asset
local AnimationFolder = Asset.Animation

local AnimationService = Knit.CreateService {
    Name = "AnimationService";
    Client = {};
    animations = { -- Monster Animation ID database. Please only have 1 nested table inside of a table, my script can't handle more than 1 D:
        ["Default"] = {
            ["Attack"] = {
                ["HeavyAttack"] = "rbxassetid://7168908478";
            }
        }
    }
}


function AnimationService:LoadAnimation(humanoid, animation)
    local animator = humanoid.Animator
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    if type(animation) == "string" then animation = self.GetAnimation(animation)
    end
    local loadedAnimation = animator:LoadAnimation(animation)
    local loadedAnimationName = loadedAnimation.Name

    return loadedAnimationName, loadedAnimation
end

function AnimationService:LoadAnimations(humanoid, animationTable)
    local loadedAnimations = {}
    for _, v in pairs(animationTable) do
        local animation = v
        local loadedAnimationName, loadedAnimation = self:LoadAnimation(humanoid, animation)
        loadedAnimations[loadedAnimationName] = loadedAnimation
    end

    return loadedAnimations
end

function AnimationService:CreateAnimation(animationID, parent, name)
    local animation = Instance.new("Animation")
    animation.AnimationId = animationID
    animation.Parent = parent
    animation.Name = name
end

function AnimationService:CreateAnimations()
    for i,v in pairs(self.animations) do -- This script is such a mess
        if type(v) == "table" then
            local classFolder = Instance.new("Folder")
            classFolder.Parent = AnimationFolder
            classFolder.Name = i

            for o, b in pairs(v) do
                if type(b) == "table" then
                    local actionFolder = Instance.new("Folder")
                    actionFolder.Parent = classFolder
                    actionFolder.Name = o

                    for p, n in pairs(b) do
                        self:CreateAnimation(n, actionFolder, p)
                    end
                else
                   self:CreateAnimation(b, classFolder, o)
                end
            end
        else
           self:CreateAnimation(v, AnimationFolder, i)
        end
    end
end

function AnimationService.GetAnimation(animation) -- Dictionary Function for pointing String Values to Animation Instances
    local animationDictionary = {
        ["DefaultHeavyAttack"] = AnimationFolder.Default.Attack.HeavyAttack;
    }

    if animationDictionary[animation] then
        return animationDictionary[animation]
    else
        warn(animation, "is not a valid Animation")
    end
end

function AnimationService:KnitStart()

end


function AnimationService:KnitInit()
    self:CreateAnimations()
end


return AnimationService