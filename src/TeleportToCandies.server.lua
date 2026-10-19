-- TeleportToCandies.server.lua

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local candyTag = "Candy"
local maxCandies = 50
local unstuckDistance = 10

local function getNearestCandy(player)
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local nearestCandy = nil
    local shortestDistance = math.huge
    
    for _, candy in ipairs(CollectionService:GetTagged(candyTag)) do
        local distance = (candy.Position - rootPart.Position).Magnitude
        if distance < shortestDistance then
            nearestCandy = candy
            shortestDistance = distance
        end
    end
    
    return nearestCandy
end

local function teleportToCandy(player)
    local nearestCandy = getNearestCandy(player)
    if nearestCandy then
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = nearestCandy.CFrame
            end
        end
    end
end

local function unstuck(player)
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, unstuckDistance, 0)
        end
    end
end

local function highlightCandies()
    for _, candy in ipairs(CollectionService:GetTagged(candyTag)) do
        local highlight = Instance.new("Highlight")
        highlight.Parent = candy
        highlight.FillColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    end
end

local function resetCandies()
    for _, candy in ipairs(CollectionService:GetTagged(candyTag)) do
        candy:Destroy()
    end
end

local function onPlayerAdded(player)
    local candiesCollected = 0
    
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            candiesCollected = 0
        end)
    end)
    
    local function onTouched(part)
        if CollectionService:HasTag(part, candyTag) then
            candiesCollected = candiesCollected + 1
            part:Destroy()
            
            if candiesCollected >= maxCandies then
                resetCandies()
                candiesCollected = 0
            end
        end
    end
    
    player.CharacterAdded:Connect(function(character)
        character.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") then
                descendant.Touched:Connect(onTouched)
            end
        end)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- User Interface
local function createUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportToCandiesUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0.5, -100, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui
    
    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(0, 180, 0, 30)
    teleportButton.Position = UDim2.new(0.5, -90, 0, 10)
    teleportButton.Text = "Teleport to Candy"
    teleportButton.Parent = frame
    
    teleportButton.MouseButton1Click:Connect(function()
        teleportToCandy(player)
    end)
    
    local unstuckButton = Instance.new("TextButton")
    unstuckButton.Size = UDim2.new(0, 180, 0, 30)
    unstuckButton.Position = UDim2.new(0.5, -90, 0, 50)
    unstuckButton.Text = "Unstuck"
    unstuckButton.Parent = frame
    
    unstuckButton.MouseButton1Click:Connect(function()
        unstuck(player)
    end)
    
    local highlightButton = Instance.new("TextButton")
    highlightButton.Size = UDim2.new(0, 180, 0, 30)
    highlightButton.Position = UDim2.new(0.5, -90, 0, 90)
    highlightButton.Text = "Highlight Candies"
    highlightButton.Parent = frame
    
    highlightButton.MouseButton1Click:Connect(function()
        highlightCandies()
    end)
end

Players.PlayerAdded:Connect(createUI)