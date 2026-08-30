--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                           SKID HUB ⚡                                 ║
    ║               Steal an Egg - Premium Automation Suite                 ║
    ║                   Powered by Fluent Interface Suite                   ║
    ╚═══════════════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

-- =========================================================================
-- 1. ANTI-CHEAT BYPASS
-- =========================================================================
local function bypassAntiCheat()
    local debugGetUpvalues = debug.getupvalues or getupvalues
    local setMeta = setrawmetatable or debug.setmetatable or setmetatable

    local functionsToCheck = filtergc("function", {
        Constants = {"gmatch", "GetFullName"},
    })

    if type(functionsToCheck) ~= "table" then
        functionsToCheck = {}
    end

    local blockedCount = 0
    for _, func in ipairs(functionsToCheck) do
        local upvalues = debugGetUpvalues(func)
        if upvalues then
            for _, upvalue in pairs(upvalues) do
                if typeof(upvalue) == "table" then
                    setMeta(upvalue, {
                        __newindex = function(t, k, v)
                            warn("[Bypass] Blocked detection", k, v)
                        end,
                    })
                    blockedCount = blockedCount + 1
                end
            end
        end
    end

    return blockedCount > 0
end

local antiCheatBypassed = pcall(bypassAntiCheat)
if antiCheatBypassed then
    print("[SkidHub] Anti-Cheat Bypassed successfully!")
else
    warn("[SkidHub] Warning: Anti-cheat bypass fallback active...")
end

-- =========================================================================
-- 2. GAME SERVICES & MODULES
-- =========================================================================
local _, loadError = pcall(function()
    local SaveData = require(ReplicatedStorage.Shared.Save)

    local EggState = require(ReplicatedStorage.Client.EggState)
    local EggStateAPI = {
        GetAreaEggSnapshot = EggState.ReadFieldEggs,
        RequestAreaEggSnapshot = EggState.SyncFieldEggs,
        AreaEggCarryStateChanged = EggState.CarryChanged,
        RequestCarryAreaEgg = EggState.CarryFieldEgg,
        RequestDropHeldAreaEgg = function()
            return EggState.DropFieldEgg("PlayerRequest")
        end,
    }

    local PlotState = require(ReplicatedStorage.Client.PlotState)
    local PlotStateAPI = {
        GetSlotOwner = PlotState.LookupOwner,
        GetRespawnPointCFrame = PlotState.FindRespawnCFrame,
        GetPlotData = PlotState.ResolvePlot,
    }

    local SlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
    local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)

    local Areas = Workspace:WaitForChild("__OBJECTS"):WaitForChild("Areas")
    local GuardAreas = Areas:WaitForChild("GuardAreas")

    local Zones = {
        "Forest",
        "Lake",
        "Desert",
        "Jungle",
        "Snow",
        "Volcano",
        "Abyss Ocean",
        "Prehistoric",
        "Cosmic",
        "Cherry Blossom",
    }

    local RarityMap = {
        Common = 1,
        Uncommon = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Mythic = 6,
        Cosmic = 7,
        Secret = 8,
        Eternal = 9,
        Divine = 10,
    }

    local RarityKeys = {
        "Common",
        "Uncommon",
        "Rare",
        "Epic",
        "Legendary",
        "Mythic",
        "Cosmic",
        "Secret",
        "Eternal",
        "Divine",
    }

    local StealPriorityOptions = {"Furthest", "Biggest Size", "Rarest", "Nearest"}

    -- =========================================================================
    -- 3. STATE & DATA
    -- =========================================================================
    local LastInputTime = tick()
    local FpsBoostState = nil
    local FpsBoostConnection = nil
    local FullbrightState = nil
    local IsCarrying = false
    local CarriedCount = 0
    local CarryConnection
    local CarryCallback

    local EspFolder = Instance.new("Folder")
    EspFolder.Name = "SkidEsp"
    EspFolder.Parent = Workspace

    local EspEntries = {}
    local EspActiveKeys = {}

    local Config = {
        GrabDelay = 0.05,
        ReturnPace = 0.05,
        CorridorMidpoint = Vector3.new(527, 71, -352),
    }

    -- =========================================================================
    -- 4. FLUENT UI INITIALIZATION
    -- =========================================================================
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    local Window = Fluent:CreateWindow({
        Title = "Skid Hub ⚡",
        SubTitle = "Steal an Egg",
        TabWidth = 150,
        Size = UDim2.fromOffset(620, 480),
        Acrylic = true,
        Theme = "Darker",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Options = Fluent.Options

    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "egg" }),
        Event = Window:AddTab({ Title = "Event 🌸", Icon = "flower" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Movement = Window:AddTab({ Title = "Movement", Icon = "zap" }),
        Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
    }

    -- =========================================================================
    -- 5. FLOATING TOGGLE BUTTON (MOBILE & PC)
    -- =========================================================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkidHubFloatingToggle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui:FindFirstChildOfClass("Folder") or CoreGui or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end

    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "ToggleBtn"
    FloatBtn.BackgroundColor3 = Color3.fromRGB(22, 20, 36)
    FloatBtn.Position = UDim2.new(0, 16, 0.45, 0)
    FloatBtn.Size = UDim2.new(0, 96, 0, 34)
    FloatBtn.Font = Enum.Font.GothamBlack
    FloatBtn.Text = "⚡ SKID HUB"
    FloatBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
    FloatBtn.TextSize = 11
    FloatBtn.AutoButtonColor = false
    FloatBtn.Parent = ScreenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(0, 17)
    floatCorner.Parent = FloatBtn

    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(138, 92, 246)
    floatStroke.Thickness = 1.4
    floatStroke.Parent = FloatBtn

    do
        local dragging = false
        local dragInput, dragStart, startPos

        FloatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = FloatBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        FloatBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    FloatBtn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    -- =========================================================================
    -- 6. CORE HUB METHODS
    -- =========================================================================
    local Hub = {}

    function Hub.isUnloaded()
        return Fluent.Unloaded
    end

    function Hub.isOn(key)
        if Hub.isUnloaded() then
            return false
        end
        local opt = Options[key]
        return opt ~= nil and opt.Value == true
    end

    function Hub.optionValue(key, defaultValue)
        local opt = Options[key]
        if opt == nil then
            return defaultValue
        end
        return opt.Value
    end

    function Hub.multiSelected(key)
        local value = Hub.optionValue(key, {})
        if typeof(value) ~= "table" then
            if typeof(value) == "string" and value ~= "" then
                return { [value] = true }
            end
            return {}
        end

        local selected = {}
        for k, v in pairs(value) do
            if v == true then
                selected[k] = true
            elseif typeof(k) == "number" and typeof(v) == "string" then
                selected[v] = true
            end
        end
        return selected
    end

    function Hub.multiHasAny(key)
        return next(Hub.multiSelected(key)) ~= nil
    end

    function Hub.selectionAllows(key, value)
        if not Hub.multiHasAny(key) then
            return true
        end
        if value == nil then
            return false
        end
        return Hub.multiSelected(key)[tostring(value)] == true
    end

    function Hub.getRoot()
        local character = LocalPlayer.Character
        if character then
            return character:FindFirstChild("HumanoidRootPart")
        end
        return nil
    end

    function Hub.getHumanoid()
        local character = LocalPlayer.Character
        if character then
            return character:FindFirstChildOfClass("Humanoid")
        end
        return nil
    end

    function Hub.getBasePosition()
        local spawnPoint = PlotStateAPI.GetRespawnPointCFrame()
        if spawnPoint then
            return spawnPoint.Position
        end

        local plotData = PlotStateAPI.GetPlotData()
        if plotData and plotData.CenterPoint then
            return plotData.CenterPoint.Position
        end

        if plotData and plotData.PetArea then
            return plotData.PetArea.Position
        end

        return nil
    end

    function Hub.getLaneZ()
        local gameplayZ = Areas:FindFirstChild("GameplayZ")
        if gameplayZ and gameplayZ:IsA("BasePart") then
            return gameplayZ.Position.Z
        end

        local separationLine = Areas:FindFirstChild("SeparationLine")
        if separationLine and separationLine:IsA("BasePart") then
            return separationLine.Position.Z
        end

        return -365.5
    end

    function Hub.getLaneY()
        local gameplayZ = Areas:FindFirstChild("GameplayZ")
        if gameplayZ and gameplayZ:IsA("BasePart") then
            return gameplayZ.Position.Y + 3
        end

        local root = Hub.getRoot()
        if root then
            return root.Position.Y
        end

        return 70
    end

    function Hub.groundedY(x, z, fallbackY)
        local laneY = Hub.getLaneY()
        local root = Hub.getRoot()
        local humanoid = Hub.getHumanoid()
        local hipHeight = (humanoid and humanoid.HipHeight > 0) and humanoid.HipHeight or 2
        local halfSize = (root and root.Size.Y * 0.5) or 1
        local offset = hipHeight + halfSize

        local targetY = laneY + 1.5

        local filter = RaycastParams.new()
        filter.FilterType = Enum.RaycastFilterType.Exclude
        local filterList = {}
        if LocalPlayer.Character then
            table.insert(filterList, LocalPlayer.Character)
        end
        filter.FilterDescendantsInstances = filterList

        local foundY = nil
        for i = 1, 20 do
            local result = Workspace:Raycast(Vector3.new(x, laneY + 40, z), Vector3.new(0, -160, 0), filter)
            if result then
                local y = result.Position.Y
                local name = result.Instance.Name
                if name == "Ground" or string.find(string.lower(name), "ground") then
                    foundY = y
                    break
                end
                if not (y <= targetY) then
                    table.insert(filterList, result.Instance)
                else
                    foundY = y
                    break
                end
            end
        end

        if foundY then
            return math.clamp(foundY + offset, laneY - 2, laneY + 5)
        end

        if typeof(fallbackY) == "number" then
            return math.clamp(fallbackY, laneY - 2, laneY + 5)
        end
        return laneY + 3
    end

    function Hub.getZoneModel(zoneName)
        return GuardAreas:FindFirstChild(zoneName)
    end

    function Hub.getZoneLaneCenter(zoneName)
        local model = Hub.getZoneModel(zoneName)
        if not model then
            return nil
        end

        local bounds = model:FindFirstChild("Bounds")
        if bounds and bounds:IsA("BasePart") then
            return Vector3.new(bounds.Position.X, Hub.getLaneY(), Hub.getLaneZ())
        end

        local success, bbox = pcall(function()
            return model:GetBoundingBox()
        end)

        if success then
            return Vector3.new(bbox.Position.X, Hub.getLaneY(), Hub.getLaneZ())
        end

        return nil
    end

    function Hub.tweenTo(x, y, z)
        local root = Hub.getRoot()
        if not root then
            return false
        end

        local humanoid = Hub.getHumanoid()
        if humanoid then
            humanoid.Sit = false
            humanoid.PlatformStand = true
        end

        local targetY = y or Hub.groundedY(x, z, root.Position.Y)
        local targetCFrame = CFrame.new(x, targetY, z)

        local distance = (root.Position - targetCFrame.Position).Magnitude
        if distance < 1.5 then
            root.CFrame = targetCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            if humanoid then
                humanoid.PlatformStand = false
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
            return true
        end

        local speed = tonumber(Hub.optionValue("StealSpeed", 600)) or 600
        speed = math.clamp(speed, 50, 3000)
        local duration = math.max(0.015, distance / speed)

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = targetCFrame,
        })
        tween:Play()
        tween.Completed:Wait()

        root.CFrame = targetCFrame
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        if humanoid then
            humanoid.PlatformStand = false
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end

        return true
    end

    function Hub.isCarrying()
        return IsCarrying
    end

    -- =========================================================================
    -- 7. STEAL & HUMANOID BYPASS
    -- =========================================================================
    function Hub.swapStealHumanoid()
        local character = LocalPlayer.Character
        if not character then
            return false
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return false
        end

        if humanoid:GetAttribute("SkidHum") == true then
            return true
        end

        for _, descendant in ipairs(character:GetDescendants()) do
            if string.find(descendant.Name, "PushBack") and descendant:IsA("LocalScript") then
                pcall(function()
                    descendant.Disabled = true
                    descendant:Destroy()
                end)
            end
        end

        humanoid.Archivable = true
        local newHumanoid = humanoid:Clone()
        if not newHumanoid then
            return false
        end

        newHumanoid:SetAttribute("SkidHum", true)
        newHumanoid.Sit = false
        newHumanoid.PlatformStand = false
        newHumanoid.AutoRotate = true

        humanoid:Destroy()
        newHumanoid.Parent = character

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero
        end

        pcall(function()
            newHumanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)

        return character:FindFirstChildOfClass("Humanoid") ~= nil
    end

    function Hub.getSave()
        local success, data = pcall(function()
            return SaveData.Get()
        end)
        if success then
            return data
        end
        return nil
    end

    function Hub.resolveRarity(category)
        if typeof(category) ~= "string" then
            return nil
        end

        local success, assetData = pcall(function()
            return require(ReplicatedStorage.Data.Assets).Directory[category]
        end)
        if success and assetData and assetData.Rarity then
            local r = assetData.Rarity._id or assetData.Rarity.DisplayName or assetData.Rarity.Name or tostring(assetData.Rarity)
            if typeof(r) == "string" and #r > 0 then
                return r
            end
        end

        if category:find("Divine") then return "Divine" end
        if category:find("Eternal") then return "Eternal" end
        if category:find("Secret") then return "Secret" end
        if category:find("Cosmic") then return "Cosmic" end
        if category:find("Mythic") then return "Mythic" end
        if category:find("Legendary") then return "Legendary" end
        if category:find("Epic") then return "Epic" end
        if category:find("Rare") then return "Rare" end
        if category:find("Uncommon") then return "Uncommon" end
        if category:find("Common") then return "Common" end

        return nil
    end

    function Hub.getAreaEggs()
        local snapshot = EggStateAPI.GetAreaEggSnapshot()
        if typeof(snapshot) ~= "table" or typeof(snapshot.Records) ~= "table" then
            pcall(function()
                EggStateAPI.RequestAreaEggSnapshot()
            end)
            snapshot = EggStateAPI.GetAreaEggSnapshot()
        end

        if typeof(snapshot) ~= "table" or typeof(snapshot.Records) ~= "table" then
            return {}
        end

        local eggs = {}
        for _, record in pairs(snapshot.Records) do
            if typeof(record) == "table" and typeof(record.Uid) == "string" then
                table.insert(eggs, record)
            end
        end

        return eggs
    end

    function Hub.recordMutations(itemData)
        local mutations = {}
        if typeof(itemData) ~= "table" then
            return mutations
        end

        if typeof(itemData.Mutations) == "table" then
            for _, mutation in pairs(itemData.Mutations) do
                if typeof(mutation) == "string" then
                    table.insert(mutations, mutation)
                end
            end
        end

        if typeof(itemData.BaseMutation) == "string" then
            table.insert(mutations, itemData.BaseMutation)
        end

        return mutations
    end

    function Hub.matchesMutationFilter(filterKey, itemData)
        if not Hub.multiHasAny(filterKey) then
            return true
        end

        local selected = Hub.multiSelected(filterKey)
        for _, mutation in ipairs(Hub.recordMutations(itemData)) do
            if selected[mutation] then
                return true
            end
        end

        return false
    end

    function Hub.matchesEggFilters(eggData, zoneFilter, rarityFilter, mutationFilter)
        if zoneFilter and eggData.AreaId then
            if not Hub.selectionAllows(zoneFilter, eggData.AreaId) then
                return false
            end
        end

        local rarity = Hub.resolveRarity(eggData.AssetCategory)
        if rarity and not Hub.selectionAllows(rarityFilter, rarity) then
            return false
        end

        return Hub.matchesMutationFilter(mutationFilter, eggData)
    end

    function Hub.isBigEgg(eggData)
        if not Hub.isOn("StealBigEggs") then
            return false
        end

        local scale = tonumber(eggData and eggData.AssetScale) or 1
        local minScale = tonumber(Hub.optionValue("StealBigEggScale", 1.5)) or 1.5
        return scale >= minScale
    end

    function Hub.eggScore(eggData)
        local rarity = Hub.resolveRarity(eggData.AssetCategory) or "Common"
        return RarityMap[rarity] or 0
    end

    function Hub.isStealCandidate(eggData, isAll)
        if typeof(eggData) ~= "table" or typeof(eggData.Uid) ~= "string" then
            return false
        end

        if eggData.State ~= "Slot" and eggData.State ~= "Dropped" then
            return false
        end

        if isAll then
            return true
        end

        if Hub.isBigEgg(eggData) and Hub.selectionAllows("StealZones", eggData.AreaId) then
            return true
        end

        if not Hub.isOn("AutoStealSelected") then
            return false
        end

        return Hub.matchesEggFilters(eggData, "StealZones", "StealRarities", "StealMutations")
    end

    function Hub.isBarrierActive()
        local sealed = false
        pcall(function()
            local resetWall = require(ReplicatedStorage.Client.AreaEggResetWall)
            if resetWall and type(resetWall.IsSealed) == "function" then
                sealed = (resetWall.IsSealed() == true)
            end
        end)
        if sealed then return true end

        pcall(function()
            local areas = Workspace:FindFirstChild("__OBJECTS") and Workspace.__OBJECTS:FindFirstChild("Areas")
            if areas then
                local col = areas:FindFirstChild("WallStartCollision")
                if col and col.CanCollide == true then
                    sealed = true
                end
            end
        end)

        return sealed
    end

    function Hub.pickStealTarget()
        if not Hub.stealingEnabled() then
            return nil
        end

        local eggs = Hub.getAreaEggs()
        if #eggs == 0 then
            return nil
        end

        local isAll = Hub.isOn("AutoStealAll") and not Hub.isOn("AutoStealSelected")
        local root = Hub.getRoot()
        local priority = Hub.optionValue("StealPriority", "Rarest")

        local bestEgg = nil
        local bestScore = -math.huge

        for _, egg in ipairs(eggs) do
            if Hub.isStealCandidate(egg, isAll) then
                local pos = egg.BottomCFrame and egg.BottomCFrame.Position or (egg.BoundsCFrame and egg.BoundsCFrame.Position)
                if pos then
                    local distance = root and (root.Position - pos).Magnitude or 1000
                    local score = 0

                    if priority == "Nearest" then
                        score = -distance
                    elseif priority == "Furthest" then
                        score = distance
                    elseif priority == "Biggest Size" then
                        local scale = tonumber(egg.AssetScale) or 1
                        score = scale * 10000 - math.min(distance * 0.05, 500)
                    else -- "Rarest"
                        local rarityScore = (Hub.eggScore(egg) or 0) * 100000
                        local scale = tonumber(egg.AssetScale) or 1
                        score = rarityScore + math.floor(scale * 1000) - math.min(distance * 0.05, 500)
                    end

                    if score > bestScore then
                        bestScore = score
                        bestEgg = egg
                    end
                end
            end
        end

        return bestEgg
    end

    function Hub.tryCarryEgg(eggRecord)
        if not eggRecord or typeof(eggRecord.Uid) ~= "string" then
            return false
        end

        local uid = eggRecord.Uid
        local slotKey = nil
        if eggRecord.AreaId and eggRecord.NestId then
            pcall(function()
                slotKey = SlotIdentity.SlotKey(eggRecord.AreaId, eggRecord.NestId)
            end)
        end

        pcall(function()
            if slotKey then
                EggStateAPI.RequestCarryAreaEgg(uid, slotKey)
            else
                EggStateAPI.RequestCarryAreaEgg(uid)
            end
        end)

        pcall(function()
            local slotsFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
            if slotsFolder then
                local slot = slotsFolder:FindFirstChild(uid)
                if slot then
                    for _, desc in ipairs(slot:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            desc.HoldDuration = 0
                            if fireproximityprompt then
                                fireproximityprompt(desc)
                            end
                        end
                    end
                end
            end
        end)

        return Hub.isCarrying()
    end

    function Hub.stealEgg(eggRecord)
        if not eggRecord or typeof(eggRecord.Uid) ~= "string" then
            return false
        end

        local rootCheck = Hub.getRoot()
        local curX = rootCheck and rootCheck.Position.X or 0
        if curX < 535 and Hub.isBarrierActive() then
            return false
        end

        Hub.swapStealHumanoid()

        local eggPos = eggRecord.BottomCFrame and eggRecord.BottomCFrame.Position or (eggRecord.BoundsCFrame and eggRecord.BoundsCFrame.Position)
        if not eggPos then
            return false
        end

        local root = Hub.getRoot()
        if not root then
            return false
        end

        root.Anchored = false

        local startX = root.Position.X
        local startZ = root.Position.Z
        local startY = Hub.groundedY(startX, startZ, root.Position.Y)

        local midpoint = Config.CorridorMidpoint
        local eggTargetY = eggPos.Y + 2.5
        local midY = math.max(startY, eggTargetY) + 5

        if startX < 535 and Hub.isBarrierActive() then
            return false
        end

        if startX < 535 then
            Hub.tweenTo(midpoint.X, midY, midpoint.Z)
        end
        if not Hub.stealingEnabled() then return false end

        Hub.tweenTo(eggPos.X, eggTargetY, eggPos.Z)

        root = Hub.getRoot()
        if root then
            root.CFrame = CFrame.new(eggPos.X, eggTargetY, eggPos.Z)
            root.AssemblyLinearVelocity = Vector3.zero
        end

        if not Hub.stealingEnabled() then return false end

        local slotKey = nil
        if eggRecord.AreaId and eggRecord.NestId then
            pcall(function()
                slotKey = SlotIdentity.SlotKey(eggRecord.AreaId, eggRecord.NestId)
            end)
        end

        local startTime = tick()
        local maxWait = 0.5
        while tick() - startTime < maxWait do
            if not Hub.stealingEnabled() then break end

            root = Hub.getRoot()
            if root then
                root.CFrame = CFrame.new(eggPos.X, eggTargetY, eggPos.Z)
                root.AssemblyLinearVelocity = Vector3.zero
            end

            pcall(function()
                if slotKey then
                    EggStateAPI.RequestCarryAreaEgg(eggRecord.Uid, slotKey)
                else
                    EggStateAPI.RequestCarryAreaEgg(eggRecord.Uid)
                end
            end)

            pcall(function()
                local slotsFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
                if slotsFolder then
                    local slot = slotsFolder:FindFirstChild(eggRecord.Uid)
                    if slot then
                        for _, desc in ipairs(slot:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                desc.HoldDuration = 0
                                if fireproximityprompt then
                                    fireproximityprompt(desc)
                                end
                            end
                        end
                    end
                end
            end)

            if Hub.isCarrying() then
                break
            end
            task.wait(0.02)
        end

        if Hub.isOn("AutoReturn") then
            local basePos = Hub.getBasePosition() or Vector3.new(startX, startY, startZ)
            local baseTargetY = basePos.Y + 2.5
            local returnMidY = math.max(eggTargetY, baseTargetY) + 5

            Hub.tweenTo(midpoint.X, returnMidY, midpoint.Z)
            Hub.tweenTo(basePos.X, baseTargetY, basePos.Z)

            local arriveTime = tick()
            while Hub.isCarrying() and tick() - arriveTime < 1.5 do
                local curRoot = Hub.getRoot()
                if curRoot and curRoot.Parent then
                    curRoot.CFrame = CFrame.new(basePos.X, baseTargetY, basePos.Z)
                    curRoot.AssemblyLinearVelocity = Vector3.zero
                end
                task.wait(0.05)
            end
        end

        task.wait(Config.ReturnPace or 0.05)
        return Hub.isCarrying()
    end

    -- =========================================================================
    -- 7.5. THE HUNGRY MONSTER EVENT METHODS (LIMITED EVENT 🐊)
    -- =========================================================================
    function Hub.isInfestedEgg(eggRecord)
        if typeof(eggRecord) ~= "table" then return false end

        -- 1. Check mutations table & base mutation
        local mutations = Hub.recordMutations(eggRecord)
        for _, m in ipairs(mutations) do
            local mLower = string.lower(tostring(m))
            if mLower:find("parasite") or mLower:find("infested") or mLower:find("purple") or mLower:find("hungry") or mLower:find("monster") then
                return true
            end
        end

        -- 2. Check AssetCategory
        if typeof(eggRecord.AssetCategory) == "string" then
            local catLower = string.lower(eggRecord.AssetCategory)
            if catLower:find("parasite") or catLower:find("infested") or catLower:find("monster") then
                return true
            end
        end

        -- 3. Check attributes / flags on egg record
        if eggRecord.Infested == true or eggRecord.Parasite == true or eggRecord.IsInfested == true or eggRecord.HasParasite == true then
            return true
        end

        -- 4. Check 3D Slot in Workspace
        if typeof(eggRecord.Uid) == "string" then
            local slotsFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
            if slotsFolder then
                local slot = slotsFolder:FindFirstChild(eggRecord.Uid)
                if slot then
                    if slot:GetAttribute("Infested") == true or slot:GetAttribute("Parasite") == true then
                        return true
                    end
                    for _, desc in ipairs(slot:GetDescendants()) do
                        local dLower = string.lower(desc.Name)
                        if dLower:find("parasite") or dLower:find("infested") or dLower:find("purple") then
                            return true
                        end
                        if desc:IsA("ParticleEmitter") or desc:IsA("PointLight") then
                            return true
                        end
                    end
                end
            end
        end

        return false
    end

    function Hub.findHungryMonster()
        -- 1. Search by Name
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") and (desc.Name == "The Hungry Monster" or desc.Name:find("Hungry Monster") or desc.Name:find("HungryMonster")) then
                return desc
            end
        end

        -- 2. Search by BillboardGui text
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BillboardGui") then
                for _, child in ipairs(desc:GetDescendants()) do
                    if child:IsA("TextLabel") and string.find(child.Text, "Hungry Monster") then
                        return desc.Adornee or desc.Parent
                    end
                end
            end
        end

        -- 3. Search in __OBJECTS
        local objects = Workspace:FindFirstChild("__OBJECTS")
        if objects then
            for _, child in ipairs(objects:GetDescendants()) do
                if child:IsA("Model") and (child.Name:find("Monster") or child.Name:find("Hungry")) then
                    return child
                end
            end
        end

        return nil
    end

    function Hub.feedHungryMonster()
        local monster = Hub.findHungryMonster()
        if not monster then
            Fluent:Notify({ Title = "Skid Hub", Content = "Hungry Monster not found in workspace", Duration = 3 })
            return false
        end

        local monsterPos = monster:GetPivot().Position
        local root = Hub.getRoot()
        if not root then return false end

        Hub.tweenTo(monsterPos.X, monsterPos.Y + 2, monsterPos.Z)

        for _, desc in ipairs(monster:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
                if fireproximityprompt then
                    fireproximityprompt(desc)
                else
                    desc:InputHoldBegin()
                    task.wait()
                    desc:InputHoldEnd()
                end
            end
        end

        return true
    end

    function Hub.findMonsterChests()
        local chests = {}
        for _, desc in ipairs(Workspace:GetChildren()) do
            if desc:IsA("Model") and (desc.Name:find("Monster Chest") or desc.Name:find("MonsterChest") or desc.Name:find("RewardChest")) then
                table.insert(chests, desc)
            end
        end
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") and (desc.Name:find("Monster Chest") or desc.Name:find("MonsterChest")) then
                table.insert(chests, desc)
            end
        end
        return chests
    end

    function Hub.collectMonsterChests()
        local chests = Hub.findMonsterChests()
        for _, chest in ipairs(chests) do
            local pos = chest:GetPivot().Position
            Hub.tweenTo(pos.X, pos.Y + 2, pos.Z)
            for _, desc in ipairs(chest:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    desc.HoldDuration = 0
                    if fireproximityprompt then fireproximityprompt(desc) end
                elseif desc:IsA("TouchTransmitter") or desc:IsA("BasePart") then
                    local root = Hub.getRoot()
                    if root then
                        pcall(function() firetouchinterest(root, desc:IsA("BasePart") and desc or desc.Parent, 0) end)
                        pcall(function() firetouchinterest(root, desc:IsA("BasePart") and desc or desc.Parent, 1) end)
                    end
                end
            end
        end
    end

    function Hub.pickInfestedStealTarget()
        local eggs = Hub.getAreaEggs()
        if #eggs == 0 then return nil end

        local root = Hub.getRoot()
        local bestEgg, bestScore = nil, -math.huge

        -- 1. Exact Infested/Parasite Egg match
        for _, egg in ipairs(eggs) do
            if Hub.isInfestedEgg(egg) and (egg.State == "Slot" or egg.State == "Dropped") then
                local pos = egg.BottomCFrame and egg.BottomCFrame.Position or (egg.BoundsCFrame and egg.BoundsCFrame.Position)
                if pos then
                    local dist = root and (root.Position - pos).Magnitude or 1000
                    local score = 100000 - dist
                    if score > bestScore then
                        bestScore = score
                        bestEgg = egg
                    end
                end
            end
        end

        if bestEgg then return bestEgg end

        -- 2. Target higher biomes where Infested eggs spawn (Snow -> Cherry Blossom)
        local candidateBiomes = {
            ["Snow"] = true,
            ["Volcano"] = true,
            ["Abyss Ocean"] = true,
            ["Prehistoric"] = true,
            ["Cosmic"] = true,
            ["Cherry Blossom"] = true,
        }

        for _, egg in ipairs(eggs) do
            if candidateBiomes[egg.AreaId] and (egg.State == "Slot" or egg.State == "Dropped") then
                local pos = egg.BottomCFrame and egg.BottomCFrame.Position or (egg.BoundsCFrame and egg.BoundsCFrame.Position)
                if pos then
                    local dist = root and (root.Position - pos).Magnitude or 1000
                    local score = 50000 - dist
                    if score > bestScore then
                        bestScore = score
                        bestEgg = egg
                    end
                end
            end
        end

        return bestEgg
    end

    function Hub.stealEggForMonster(eggRecord)
        if not eggRecord or typeof(eggRecord.Uid) ~= "string" then return false end
        if Hub.isBarrierActive() then return false end

        Hub.swapStealHumanoid()

        local eggPos = eggRecord.BottomCFrame and eggRecord.BottomCFrame.Position or (eggRecord.BoundsCFrame and eggRecord.BoundsCFrame.Position)
        if not eggPos then return false end

        local root = Hub.getRoot()
        if not root then return false end

        local midpoint = Config.CorridorMidpoint
        local eggTargetY = eggPos.Y + 2.5
        local midY = math.max(root.Position.Y, eggTargetY) + 5

        if root.Position.X < 535 then
            Hub.tweenTo(midpoint.X, midY, midpoint.Z)
        end

        Hub.tweenTo(eggPos.X, eggTargetY, eggPos.Z)

        root = Hub.getRoot()
        if root then
            root.CFrame = CFrame.new(eggPos.X, eggTargetY, eggPos.Z)
            root.AssemblyLinearVelocity = Vector3.zero
        end

        local slotKey = nil
        if eggRecord.AreaId and eggRecord.NestId then
            pcall(function()
                slotKey = SlotIdentity.SlotKey(eggRecord.AreaId, eggRecord.NestId)
            end)
        end

        local startTime = tick()
        while tick() - startTime < 0.5 do
            root = Hub.getRoot()
            if root then
                root.CFrame = CFrame.new(eggPos.X, eggTargetY, eggPos.Z)
                root.AssemblyLinearVelocity = Vector3.zero
            end

            pcall(function()
                if slotKey then
                    EggStateAPI.RequestCarryAreaEgg(eggRecord.Uid, slotKey)
                else
                    EggStateAPI.RequestCarryAreaEgg(eggRecord.Uid)
                end
            end)

            pcall(function()
                local slotsFolder = Workspace:FindFirstChild("AreaEggSlotsClient")
                if slotsFolder then
                    local slot = slotsFolder:FindFirstChild(eggRecord.Uid)
                    if slot then
                        for _, desc in ipairs(slot:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                desc.HoldDuration = 0
                                if fireproximityprompt then fireproximityprompt(desc) end
                            end
                        end
                    end
                end
            end)

            if Hub.isCarrying() then break end
            task.wait(0.02)
        end

        -- Fly directly to The Hungry Monster to feed!
        if Hub.isCarrying() then
            local monster = Hub.findHungryMonster()
            if monster then
                local monsterPos = monster:GetPivot().Position
                local deliverMidY = math.max(eggTargetY, monsterPos.Y + 2.5) + 5

                Hub.tweenTo(midpoint.X, deliverMidY, midpoint.Z)
                Hub.tweenTo(monsterPos.X, monsterPos.Y + 2, monsterPos.Z)

                local feedTime = tick()
                while Hub.isCarrying() and tick() - feedTime < 2.5 do
                    for _, desc in ipairs(monster:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            desc.HoldDuration = 0
                            if fireproximityprompt then fireproximityprompt(desc) end
                        end
                    end
                    task.wait(0.08)
                end

                if Hub.isOn("AutoCollectMonsterChest") then
                    task.wait(0.2)
                    pcall(Hub.collectMonsterChests)
                end
            end
        end

        return Hub.isCarrying()
    end

    function Hub.runAutoFeedMonster()
        if not Hub.isOn("AutoFeedMonster") then return end

        if Hub.isCarrying() then
            local monster = Hub.findHungryMonster()
            if monster then
                local pos = monster:GetPivot().Position
                Hub.tweenTo(pos.X, pos.Y + 2, pos.Z)

                local feedTime = tick()
                while Hub.isCarrying() and tick() - feedTime < 3.0 do
                    for _, desc in ipairs(monster:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            desc.HoldDuration = 0
                            if fireproximityprompt then fireproximityprompt(desc) end
                        end
                    end
                    task.wait(0.08)
                end

                if Hub.isOn("AutoCollectMonsterChest") then
                    task.wait(0.2)
                    pcall(Hub.collectMonsterChests)
                end
            end
            return
        end

        local target = Hub.pickInfestedStealTarget()
        if target then
            Hub.stealEggForMonster(target)
        end
    end

    -- =========================================================================
    -- EVENT & SAKURA METHODS (CHERRY BLOSSOM & GREAT BLOOM)
    -- =========================================================================
    function Hub.getBatTool()
        local character = LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                return tool
            end
        end

        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    return item
                end
            end
        end
        return nil
    end

    function Hub.equipBatTool()
        local character = LocalPlayer.Character
        local humanoid = Hub.getHumanoid()
        if not character or not humanoid then return end

        local tool = character:FindFirstChildOfClass("Tool")
        if tool then return tool end

        local bat = Hub.getBatTool()
        if bat and bat.Parent ~= character then
            humanoid:EquipTool(bat)
            return bat
        end
        return nil
    end

    function Hub.findSakuraTrees()
        local trees = {}
        local cbZone = GuardAreas:FindFirstChild("Cherry Blossom") or Areas:FindFirstChild("Cherry Blossom")
        if cbZone then
            for _, desc in ipairs(cbZone:GetDescendants()) do
                if desc:IsA("Model") and (desc.Name:find("Tree") or desc.Name:find("Sakura") or desc.Name:find("Bloom")) then
                    table.insert(trees, desc)
                end
            end
        end

        for _, desc in ipairs(Workspace:GetChildren()) do
            if desc:IsA("Model") and (desc.Name:find("SakuraTree") or desc.Name:find("EventTree") or desc.Name:find("BloomTree")) then
                table.insert(trees, desc)
            end
        end
        return trees
    end

    function Hub.smashTree(treeModel)
        if not treeModel then return end
        local root = Hub.getRoot()
        if not root then return end

        local treePos = treeModel:GetPivot().Position
        Hub.tweenTo(treePos.X, treePos.Y + 2, treePos.Z)

        if Hub.isOn("AutoEquipBat") then
            Hub.equipBatTool()
        end

        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                tool:Activate()
            end)
        end

        for _, desc in ipairs(treeModel:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
                if fireproximityprompt then
                    fireproximityprompt(desc)
                end
            elseif desc:IsA("ClickDetector") then
                if fireclickdetector then
                    fireclickdetector(desc)
                end
            end
        end
    end

    function Hub.smashNearestSakuraTree()
        local trees = Hub.findSakuraTrees()
        if #trees == 0 then
            local cbCenter = Hub.getZoneLaneCenter("Cherry Blossom")
            if cbCenter then
                Hub.tweenTo(cbCenter.X, cbCenter.Y + 2, cbCenter.Z)
            end
            return false
        end

        local root = Hub.getRoot()
        local bestTree, bestDist = nil, math.huge
        for _, tree in ipairs(trees) do
            local pos = tree:GetPivot().Position
            local dist = root and (root.Position - pos).Magnitude or math.huge
            if dist < bestDist then
                bestDist = dist
                bestTree = tree
            end
        end

        if bestTree then
            Hub.smashTree(bestTree)
            return true
        end
        return false
    end

    function Hub.findSakuraIncubator()
        local machines = Workspace:FindFirstChild("__OBJECTS") and Workspace.__OBJECTS:FindFirstChild("Machines")
        if machines then
            for _, m in ipairs(machines:GetChildren()) do
                if m.Name:find("Sakura") or m.Name:find("Bloom") or m.Name:find("Incubator") then
                    return m
                end
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find("SakuraIncubator") or obj.Name == "Sakura Incubator" or obj.Name:find("Incubator") then
                return obj
            end
        end
        return nil
    end

    function Hub.teleportToSakuraIncubator()
        local incubator = Hub.findSakuraIncubator()
        if incubator then
            local pos = incubator:GetPivot().Position
            local root = Hub.getRoot()
            if root then
                root.CFrame = CFrame.new(pos.X, pos.Y + 2, pos.Z)
                root.AssemblyLinearVelocity = Vector3.zero
                Fluent:Notify({ Title = "Skid Hub", Content = "Teleported to Sakura Incubator!", Duration = 3 })
                return
            end
        end
        Hub.teleportToZone("Cherry Blossom")
    end

    function Hub.mutateAtSakuraIncubator()
        local incubator = Hub.findSakuraIncubator()
        if not incubator then
            return false
        end

        local root = Hub.getRoot()
        if not root then return false end

        local pos = incubator:GetPivot().Position
        Hub.tweenTo(pos.X, pos.Y + 2, pos.Z)

        for _, desc in ipairs(incubator:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
                if fireproximityprompt then
                    fireproximityprompt(desc)
                end
            end
        end
        return true
    end

    function Hub.sacrificeCrane()
        local incubator = Hub.findSakuraIncubator()
        if incubator then
            local pos = incubator:GetPivot().Position
            Hub.tweenTo(pos.X, pos.Y + 2, pos.Z)
            for _, desc in ipairs(incubator:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    desc.HoldDuration = 0
                    if fireproximityprompt then fireproximityprompt(desc) end
                end
            end
            Fluent:Notify({ Title = "Skid Hub", Content = "Interacted with Sakura Incubator to offer Crane", Duration = 3 })
        else
            Fluent:Notify({ Title = "Skid Hub", Content = "Sakura Incubator not found in workspace", Duration = 3 })
        end
    end

    function Hub.stealingEnabled()
        return Hub.isOn("AutoStealSelected") or Hub.isOn("AutoStealAll")
    end

    function Hub.eggInventoryCount()
        local save = Hub.getSave()
        if not save or typeof(save.EggInventory) ~= "table" then
            return 0
        end

        local count = 0
        for _ in pairs(save.EggInventory) do
            count = count + 1
        end
        return count
    end

    function Hub.eggInventoryFull()
        local maxInventory = tonumber(require(ReplicatedStorage.Shared.Types.Eggs).MAX_INVENTORY) or math.huge
        return Hub.eggInventoryCount() >= maxInventory
    end

    function Hub.stealBlockedByInventory()
        return Hub.eggInventoryFull()
    end

    function Hub.runAutoSteal()
        if Hub.isCarrying() or Hub.stealBlockedByInventory() or not Hub.stealingEnabled() then
            return
        end

        local target = Hub.pickStealTarget()
        if not target then
            return
        end

        return Hub.stealEgg(target)
    end

    function Hub.runAutoReturn()
        if not Hub.isCarrying() then
            return
        end

        local basePos = Hub.getBasePosition()
        if not basePos then
            return
        end

        Hub.tweenTo(basePos.X, nil, basePos.Z)

        local root = Hub.getRoot()
        if root then
            local groundY = Hub.groundedY(basePos.X, basePos.Y, basePos.Z)
            root.CFrame = CFrame.new(basePos.X, groundY, basePos.Z)
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- =========================================================================
    -- 8. ESP SYSTEM
    -- =========================================================================
    function Hub.formatNumber(number)
        local value = tonumber(number) or 0
        local suffixes = {"", "K", "M", "B", "T", "Qa"}
        if value < 1000 then
            return tostring(math.floor(value))
        end

        local index = math.floor(math.log10(value) / 3)
        index = math.clamp(index, 1, #suffixes - 1)
        local divisor = 10 ^ (index * 3)
        return string.format("%.1f%s", value / divisor, suffixes[index + 1])
    end

    function Hub.espColorFor(rarity)
        local score = RarityMap[rarity] or 0
        if score >= 9 then
            return Color3.fromRGB(255, 120, 255)
        elseif score >= 7 then
            return Color3.fromRGB(255, 90, 90)
        elseif score >= 5 then
            return Color3.fromRGB(255, 190, 80)
        elseif score >= 3 then
            return Color3.fromRGB(110, 195, 255)
        else
            return Color3.fromRGB(190, 200, 215)
        end
    end

    function Hub.ensureEspEntry(key, color)
        local entry = EspEntries[key]
        if entry then
            return entry
        end

        local anchor = Instance.new("Part")
        anchor.Name = "EspAnchor_" .. tostring(key)
        anchor.Anchored = true
        anchor.CanCollide = false
        anchor.CanQuery = false
        anchor.CanTouch = false
        anchor.Transparency = 1
        anchor.Size = Vector3.new(0.2, 0.2, 0.2)
        anchor.Parent = EspFolder

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "EspLabel"
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.Size = UDim2.fromOffset(220, 36)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.MaxDistance = tonumber(Hub.optionValue("EspDistance", 2000)) or 2000
        billboard.Adornee = anchor
        billboard.Parent = anchor

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextStrokeTransparency = 0.3
        label.TextColor3 = color
        label.RichText = false
        label.Parent = billboard

        entry = {
            anchor = anchor,
            billboard = billboard,
            label = label,
            highlight = nil,
        }

        EspEntries[key] = entry
        return entry
    end

    function Hub.drawEspAt(key, position, text, color, adornee)
        local entry = Hub.ensureEspEntry(key, color)
        entry.anchor.CFrame = CFrame.new(position)
        entry.label.Text = text
        entry.label.TextColor3 = color
        entry.billboard.MaxDistance = tonumber(Hub.optionValue("EspDistance", 2000)) or 2000

        if adornee and adornee.Parent then
            if not entry.highlight then
                local highlight = Instance.new("Highlight")
                highlight.FillTransparency = 0.6
                highlight.OutlineTransparency = 0.2
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = EspFolder
                entry.highlight = highlight
            end

            entry.highlight.Adornee = adornee
            entry.highlight.FillColor = color
            entry.highlight.OutlineColor = color
        else
            if entry.highlight then
                entry.highlight:Destroy()
                entry.highlight = nil
            end
        end

        EspActiveKeys[key] = true
    end

    function Hub.releaseEsp(key)
        local entry = EspEntries[key]
        if not entry then
            return
        end

        if entry.highlight then
            entry.highlight:Destroy()
        end
        if entry.billboard then
            entry.billboard:Destroy()
        end
        if entry.anchor then
            entry.anchor:Destroy()
        end

        EspEntries[key] = nil
    end

    function Hub.espDistanceLimit()
        return tonumber(Hub.optionValue("EspDistance", 2000)) or 2000
    end

    function Hub.withinEspRange(position)
        local root = Hub.getRoot()
        if not root then
            return false
        end
        return (root.Position - position).Magnitude <= Hub.espDistanceLimit()
    end

    function Hub.collectEggEsp()
        if not Hub.isOn("EspWorldEggs") and not Hub.isOn("EspCarriedEggs") then
            return
        end

        for _, egg in ipairs(Hub.getAreaEggs()) do
            local cframe = egg.BottomCFrame or egg.BoundsCFrame
            if cframe then
                local isCarried = egg.State == "Carried"
                local isSlot = egg.State == "Slot"

                if (isSlot and Hub.isOn("EspWorldEggs")) or (isCarried and Hub.isOn("EspCarriedEggs")) then
                    local position = cframe.Position
                    if Hub.withinEspRange(position) then
                        local rarity = Hub.resolveRarity(egg.AssetCategory)
                        local assetData = nil
                        pcall(function()
                            assetData = require(ReplicatedStorage.Data.Assets).Directory[egg.AssetCategory]
                        end)
                        local displayName = assetData and assetData.DisplayName or tostring(egg.AssetCategory)
                        local scale = tonumber(egg.AssetScale) or 1
                        local isBig = scale >= 1.5

                        local text = isBig and string.format("[%.1fx] %s [%s]", scale, displayName, tostring(rarity or "?")) or string.format("%s [%s]", displayName, tostring(rarity or "?"))
                        if egg.AreaId then
                            text = text .. string.format("\n%s", tostring(egg.AreaId))
                        end
                        if isCarried then
                            text = text .. string.format(" (Carried)")
                        end

                        Hub.drawEspAt("egg_" .. egg.Uid, position, text, Hub.espColorFor(rarity), nil)
                    end
                end
            end
        end
    end

    function Hub.collectGuardEsp()
        if not Hub.isOn("EspGuards") then
            return
        end

        pcall(function()
            for _, area in ipairs(GuardAreas:GetChildren()) do
                local guard = area:FindFirstChild("Guard")
                if guard then
                    local success, pivot = pcall(function()
                        return guard:GetPivot()
                    end)

                    if success and Hub.withinEspRange(pivot.Position) then
                        local state = guard:GetAttribute("GuardState") or "Idle"
                        local text = string.format("Guard %s\n%s", area.Name, tostring(state))
                        Hub.drawEspAt("guard_" .. area.Name, pivot.Position, text, Color3.fromRGB(255, 140, 90), guard)
                    end
                end
            end
        end)
    end

    function Hub.collectPetEsp()
        if not Hub.isOn("EspPets") then
            return
        end

        pcall(function()
            local rendered = Workspace:FindFirstChild("ClientRenderedAssets")
            if not rendered then
                return
            end

            local save = Hub.getSave()
            local assetRoster = nil
            pcall(function()
                assetRoster = require(ReplicatedStorage.Client.AssetRoster).ReadSnapshot()
            end)
            local uidMap = {}

            if typeof(assetRoster) == "table" then
                for _, group in pairs(assetRoster) do
                    if typeof(group) == "table" and typeof(group.Records) == "table" then
                        for uid, data in pairs(group.Records) do
                            uidMap[uid] = data
                        end
                    end
                end
            end

            for _, pet in ipairs(rendered:GetChildren()) do
                local uid = pet:GetAttribute("UID")
                if typeof(uid) == "string" then
                    local data = uidMap[uid]
                    if typeof(data) == "table" then
                        local itemData = data.ItemData
                        local category = itemData and itemData.Category or "?"
                        local rarity = Hub.resolveRarity(category) or "?"
                        local displayName = itemData and itemData.DisplayName or "Pet"

                        local success, pivot = pcall(function()
                            return pet:GetPivot()
                        end)

                        if success and Hub.withinEspRange(pivot.Position) then
                            local text = string.format("%s [%s]", displayName, tostring(rarity))
                            local earnings = tonumber(data.MoneyPerSecond)
                            if earnings then
                                text = string.format("%s\n%s/s", text, Hub.formatNumber(earnings))
                            end

                            Hub.drawEspAt("pet_" .. pet.Name, pivot.Position, text, Hub.espColorFor(rarity), pet)
                        end
                    end
                end
            end
        end)
    end

    function Hub.collectPlayerEsp()
        if not Hub.isOn("EspPlayers") then
            return
        end

        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    if character then
                        local root = character:FindFirstChild("HumanoidRootPart")
                        if root and Hub.withinEspRange(root.Position) then
                            local rootPos = Hub.getRoot()
                            local distance = rootPos and (rootPos.Position - root.Position).Magnitude or 0
                            local text = string.format("%s\n%d studs", player.DisplayName, math.floor(distance))
                            Hub.drawEspAt("player_" .. player.Name, root.Position, text, Color3.fromRGB(120, 190, 255), character)
                        end
                    end
                end
            end
        end)
    end

    function Hub.collectMachineEsp()
        if not Hub.isOn("EspMachines") then
            return
        end

        pcall(function()
            local objects = Workspace:FindFirstChild("__OBJECTS")
            if not objects then return end

            local machines = objects:FindFirstChild("Machines")
            if not machines then return end

            for _, machine in ipairs(machines:GetChildren()) do
                local success, pivot = pcall(function()
                    return machine:GetPivot()
                end)

                if success and Hub.withinEspRange(pivot.Position) then
                    Hub.drawEspAt("machine_" .. machine.Name, pivot.Position, machine.Name, Color3.fromRGB(230, 200, 120), machine)
                end
            end
        end)
    end

    function Hub.collectPlotEsp()
        if not Hub.isOn("EspPlots") then
            return
        end

        pcall(function()
            local plots = Workspace:FindFirstChild("Plots")
            if not plots then return end

            for _, plot in ipairs(plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local center = plot:FindFirstChild("CenterPoint")
                    if center and Hub.withinEspRange(center.Position) then
                        local owner = nil
                        pcall(function()
                            owner = PlotStateAPI.GetSlotOwner(tonumber(plot.Name))
                        end)

                        local text = "Empty"
                        if owner then
                            local player = Players:GetPlayerByUserId(owner)
                            if player then
                                text = player.DisplayName
                                if player == LocalPlayer then
                                    text = text .. " (You)"
                                end
                            else
                                text = "User " .. tostring(owner)
                            end
                        end

                        Hub.drawEspAt("plot_" .. plot.Name, sign.Position, string.format("Plot %s\n%s", plot.Name, text), Color3.fromRGB(200, 170, 255), nil)
                    end
                end
            end
        end)
    end

    function Hub.clearAllEsp()
        for key in pairs(EspEntries) do
            Hub.releaseEsp(key)
        end
    end

    function Hub.collectEventEsp()
        if not Hub.isOn("EspSakuraTrees") and not Hub.isOn("EspSakuraIncubator") and not Hub.isOn("EspSakuraCrystals") then
            return
        end

        pcall(function()
            if Hub.isOn("EspSakuraTrees") then
                for _, tree in ipairs(Hub.findSakuraTrees()) do
                    local pos = tree:GetPivot().Position
                    if Hub.withinEspRange(pos) then
                        Hub.drawEspAt("sakura_tree_" .. tree:GetDebugId(), pos, "🌸 Sakura Tree\n[Break for Crystals]", Color3.fromRGB(255, 160, 200), tree)
                    end
                end
            end

            if Hub.isOn("EspSakuraIncubator") then
                local inc = Hub.findSakuraIncubator()
                if inc then
                    local pos = inc:GetPivot().Position
                    if Hub.withinEspRange(pos) then
                        Hub.drawEspAt("sakura_incubator", pos, "🌸 Sakura Incubator\n[Bloom Mutation]", Color3.fromRGB(255, 105, 180), inc)
                    end
                end
            end

            if Hub.isOn("EspSakuraCrystals") then
                for _, item in ipairs(Workspace:GetChildren()) do
                    if item.Name:find("Crystal") or item.Name:find("Sakura") or item.Name:find("Bloom") then
                        local pos = item:GetPivot().Position
                        if Hub.withinEspRange(pos) then
                            Hub.drawEspAt("sakura_crystal_" .. item:GetDebugId(), pos, "💎 Sakura Crystal", Color3.fromRGB(255, 130, 220), item)
                        end
                    end
                end
            end
        end)
    end

    function Hub.collectMonsterEsp()
        if not Hub.isOn("EspHungryMonster") and not Hub.isOn("EspInfestedEggs") and not Hub.isOn("EspMonsterChests") then
            return
        end

        pcall(function()
            -- Hungry Monster ESP
            if Hub.isOn("EspHungryMonster") then
                local monster = Hub.findHungryMonster()
                if monster then
                    local pos = monster:GetPivot().Position
                    if Hub.withinEspRange(pos) then
                        local progress = "0%"
                        for _, desc in ipairs(monster:GetDescendants()) do
                            if desc:IsA("TextLabel") and string.find(desc.Text, "%%") then
                                progress = desc.Text
                                break
                            end
                        end
                        Hub.drawEspAt("hungry_monster", pos, string.format("🐊 The Hungry Monster\n[%s - Feed 5 Eggs]", progress), Color3.fromRGB(80, 255, 120), monster)
                    end
                end
            end

            -- Infested Eggs ESP
            if Hub.isOn("EspInfestedEggs") then
                for _, egg in ipairs(Hub.getAreaEggs()) do
                    if Hub.isInfestedEgg(egg) and (egg.State == "Slot" or egg.State == "Dropped" or egg.State == "Carried") then
                        local cframe = egg.BottomCFrame or egg.BoundsCFrame
                        if cframe and Hub.withinEspRange(cframe.Position) then
                            local rarity = Hub.resolveRarity(egg.AssetCategory)
                            local text = string.format("🟣 [INFESTED / PARASITE]\n%s [%s]", tostring(egg.AssetCategory), tostring(rarity or "?"))
                            Hub.drawEspAt("infested_egg_" .. egg.Uid, cframe.Position, text, Color3.fromRGB(180, 70, 255), nil)
                        end
                    end
                end
            end

            -- Monster Chests ESP
            if Hub.isOn("EspMonsterChests") then
                for _, chest in ipairs(Hub.findMonsterChests()) do
                    local pos = chest:GetPivot().Position
                    if Hub.withinEspRange(pos) then
                        Hub.drawEspAt("monster_chest_" .. chest:GetDebugId(), pos, "🎁 Monster Chest\n[Open for Rewards]", Color3.fromRGB(255, 215, 0), chest)
                    end
                end
            end
        end)
    end

    function Hub.runEsp()
        table.clear(EspActiveKeys)
        pcall(Hub.collectEggEsp)
        pcall(Hub.collectGuardEsp)
        pcall(Hub.collectPetEsp)
        pcall(Hub.collectPlayerEsp)
        pcall(Hub.collectMachineEsp)
        pcall(Hub.collectPlotEsp)
        pcall(Hub.collectEventEsp)
        pcall(Hub.collectMonsterEsp)

        for key in pairs(EspEntries) do
            if not EspActiveKeys[key] then
                Hub.releaseEsp(key)
            end
        end
    end

    -- =========================================================================
    -- 9. FLY, TELEPORT & MOVEMENT
    -- =========================================================================
    function Hub.updateFly(delta)
        local root = Hub.getRoot()
        local humanoid = Hub.getHumanoid()
        if not root or not humanoid then
            return
        end

        humanoid.PlatformStand = true
        local moveVector = Vector3.zero
        local camera = Workspace.CurrentCamera
        if camera then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + camera.CFrame.RightVector
            end
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end

        root.Velocity = Vector3.zero
        if moveVector.Magnitude > 0 then
            local speed = Hub.optionValue("FlySpeed", 60) or 60
            root.CFrame = root.CFrame + moveVector.Unit * speed * delta
        end
    end

    function Hub.teleportToZone(zoneName)
        local center = Hub.getZoneLaneCenter(zoneName)
        if not center then
            Fluent:Notify({ Title = "Skid Hub", Content = "Zone not found: " .. tostring(zoneName), Duration = 3 })
            return
        end

        local root = Hub.getRoot()
        if not root then
            return
        end

        local groundY = Hub.groundedY(center.X, center.Z, center.Y)
        root.CFrame = CFrame.new(center.X, groundY, center.Z)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        Fluent:Notify({ Title = "Skid Hub", Content = "Teleported to " .. zoneName, Duration = 3 })
    end

    function Hub.teleportToPlayer(playerName)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name == playerName or player.DisplayName == playerName then
                local character = player.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local root = Hub.getRoot()
                        if root then
                            root.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                            root.AssemblyLinearVelocity = Vector3.zero
                            Fluent:Notify({ Title = "Skid Hub", Content = "Teleported to " .. player.DisplayName, Duration = 3 })
                        end
                    end
                end
                return
            end
        end
        Fluent:Notify({ Title = "Skid Hub", Content = "Player not found", Duration = 3 })
    end

    function Hub.teleportToBase()
        local basePos = Hub.getBasePosition()
        if not basePos then
            Fluent:Notify({ Title = "Skid Hub", Content = "Base not found", Duration = 3 })
            return
        end

        local root = Hub.getRoot()
        if not root then
            return
        end

        local groundY = Hub.groundedY(basePos.X, basePos.Y, basePos.Z)
        root.CFrame = CFrame.new(basePos.X, groundY, basePos.Z)
        root.AssemblyLinearVelocity = Vector3.zero
        Fluent:Notify({ Title = "Skid Hub", Content = "Teleported to Base", Duration = 3 })
    end

    -- =========================================================================
    -- 10. UTILITIES & STATS
    -- =========================================================================
    function Hub.antiAfkTap()
        local camera = Workspace.CurrentCamera
        if not camera then
            return
        end
        VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
        LastInputTime = tick()
    end

    function Hub.setEffectEnabled(effect, enabled)
        pcall(function()
            effect.Enabled = enabled
        end)
    end

    function Hub.enableFpsBoost()
        if FpsBoostState then
            return
        end

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        local qualityLevel = nil
        pcall(function()
            qualityLevel = settings().Rendering.QualityLevel
        end)

        FpsBoostState = {
            QualityLevel = qualityLevel,
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd = Lighting.FogEnd,
            Terrain = terrain,
            WaterWaveSize = terrain and terrain.WaterWaveSize or nil,
            WaterReflectance = terrain and terrain.WaterReflectance or nil,
            Effects = {},
        }

        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000

        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterReflectance = 0
        end

        local effectTypes = {
            ParticleEmitter = true,
            Fire = true,
            Sparkles = true,
            Trail = true,
            Smoke = true,
        }

        for _, desc in ipairs(Workspace:GetDescendants()) do
            if effectTypes[desc.ClassName] then
                table.insert(FpsBoostState.Effects, desc)
                Hub.setEffectEnabled(desc, false)
            end
        end

        FpsBoostConnection = Workspace.DescendantAdded:Connect(function(desc)
            if effectTypes[desc.ClassName] and Hub.isOn("FpsBoost") then
                Hub.setEffectEnabled(desc, false)
            end
        end)

        Fluent:Notify({ Title = "Skid Hub", Content = "FPS Boost enabled", Duration = 3 })
    end

    function Hub.disableFpsBoost()
        if FpsBoostConnection then
            FpsBoostConnection:Disconnect()
            FpsBoostConnection = nil
        end

        if not FpsBoostState then
            return
        end

        if FpsBoostState.QualityLevel then
            pcall(function()
                settings().Rendering.QualityLevel = FpsBoostState.QualityLevel
            end)
        end

        Lighting.GlobalShadows = FpsBoostState.GlobalShadows
        Lighting.FogEnd = FpsBoostState.FogEnd

        if FpsBoostState.Terrain and FpsBoostState.Terrain.Parent then
            if FpsBoostState.WaterWaveSize ~= nil then
                FpsBoostState.Terrain.WaterWaveSize = FpsBoostState.WaterWaveSize
            end
            if FpsBoostState.WaterReflectance ~= nil then
                FpsBoostState.Terrain.WaterReflectance = FpsBoostState.WaterReflectance
            end
        end

        for _, effect in ipairs(FpsBoostState.Effects) do
            Hub.setEffectEnabled(effect, true)
        end

        FpsBoostState = nil
        Fluent:Notify({ Title = "Skid Hub", Content = "FPS Boost disabled", Duration = 3 })
    end

    function Hub.applyFpsBoost(enabled)
        if enabled then
            Hub.enableFpsBoost()
        else
            Hub.disableFpsBoost()
        end
    end

    function Hub.applyFpsCap(value)
        local capFunc = setfpscap or syn and syn.set_fps_cap
        if typeof(capFunc) == "function" then
            local clamped = math.clamp(tonumber(value) or 60, 15, 360)
            pcall(capFunc, clamped)
        end
    end

    function Hub.enableFullbright()
        if FullbrightState then
            return
        end

        FullbrightState = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
        }

        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000000
        Lighting.GlobalShadows = false
    end

    function Hub.disableFullbright()
        if not FullbrightState then
            return
        end

        Lighting.Ambient = FullbrightState.Ambient
        Lighting.OutdoorAmbient = FullbrightState.OutdoorAmbient
        Lighting.Brightness = FullbrightState.Brightness
        Lighting.ClockTime = FullbrightState.ClockTime
        Lighting.FogEnd = FullbrightState.FogEnd
        Lighting.GlobalShadows = FullbrightState.GlobalShadows

        FullbrightState = nil
    end

    function Hub.applyGravity(value)
        Workspace.Gravity = value
    end

    function Hub.applyFov(value)
        local camera = Workspace.CurrentCamera
        if camera then
            camera.FieldOfView = value
        end
    end

    function Hub.rejoinServer()
        Fluent:Notify({ Title = "Skid Hub", Content = "Rejoining server...", Duration = 3 })
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end

    function Hub.getCharacterInfo()
        local humanoid = Hub.getHumanoid()
        local root = Hub.getRoot()
        local info = {}

        info.Health = humanoid and string.format("%.0f/%.0f", humanoid.Health, humanoid.MaxHealth) or "N/A"
        info.WalkSpeed = humanoid and string.format("%.0f", humanoid.WalkSpeed) or "N/A"
        info.JumpPower = humanoid and string.format("%.0f", humanoid.JumpPower) or "N/A"
        info.Position = root and string.format("%.0f, %.0f, %.0f", root.Position.X, root.Position.Y, root.Position.Z) or "N/A"

        local save = Hub.getSave()
        info.EggCount = "N/A"
        if save and typeof(save.EggInventory) == "table" then
            local count = 0
            for _ in pairs(save.EggInventory) do
                count = count + 1
            end
            info.EggCount = tostring(count)
        end

        info.StolenCount = tostring(CarriedCount)
        return info
    end

    -- =========================================================================
    -- 11. BUILD FLUENT UI TABS
    -- =========================================================================

    -- === TAB 1: MAIN (Auto Steal) ===
    Tabs.Main:AddSection("Target Egg Filters")

    Tabs.Main:AddDropdown("StealZones", {
        Title = "Select Target Areas",
        Values = Zones,
        Multi = true,
        Default = {},
    })

    Tabs.Main:AddDropdown("StealRarities", {
        Title = "Select Target Rarities",
        Values = RarityKeys,
        Multi = true,
        Default = {},
    })

    Tabs.Main:AddDropdown("StealMutations", {
        Title = "Select Target Mutations",
        Values = {"Silver", "Golden", "Rainbow", "Dark Matter", "Void", "Bloom", "Spirit Bloom"},
        Multi = true,
        Default = {},
    })

    Tabs.Main:AddDropdown("StealPriority", {
        Title = "Target Priority",
        Values = StealPriorityOptions,
        Multi = false,
        Default = "Rarest",
    })

    Tabs.Main:AddToggle("StealBigEggs", { Title = "Filter Big Eggs Only", Default = false })

    Tabs.Main:AddSlider("StealBigEggScale", {
        Title = "Big Egg Minimum Size",
        Description = "Egg size multiplier",
        Default = 1.5,
        Min = 1,
        Max = 50,
        Rounding = 2,
    })

    Tabs.Main:AddSection("Automation & Settings")

    Tabs.Main:AddToggle("InstantSteal", { Title = "⚡ Instant Egg Steal (0s Grab / Không cần giữ E)", Default = true })
    Tabs.Main:AddToggle("AutoStealSelected", { Title = "Auto Steal Selected (Using Filters)", Default = false })
    Tabs.Main:AddToggle("AutoStealAll", { Title = "Auto Steal All (Ignore Filters)", Default = false })

    Tabs.Main:AddSlider("StealSpeed", {
        Title = "Steal Fly Speed",
        Description = "Speed in studs/s",
        Default = 600,
        Min = 50,
        Max = 3000,
        Rounding = 0,
    })

    Tabs.Main:AddToggle("AutoDropEgg", { Title = "Auto Drop Held Egg", Default = false })
    Tabs.Main:AddToggle("AutoReturn", { Title = "Auto Return to Base", Default = true })

    Tabs.Main:AddSection("Quick Manual Actions")

    Tabs.Main:AddButton({
        Title = "⚡ Steal Targeted Egg Now",
        Description = "Steals one egg matching criteria immediately",
        Callback = function()
            local target = Hub.pickStealTarget()
            if target then
                local cat = target.AssetCategory or "Egg"
                task.spawn(function() Hub.stealEgg(target) end)
                Fluent:Notify({ Title = "Skid Hub", Content = "Stealing egg: " .. tostring(cat), Duration = 3 })
            else
                Fluent:Notify({ Title = "Skid Hub", Content = "No valid egg candidate found", Duration = 3 })
            end
        end
    })

    Tabs.Main:AddButton({
        Title = "❌ Drop Current Held Egg",
        Description = "Drops any egg currently in your hands",
        Callback = function()
            pcall(function() EggStateAPI.RequestDropHeldAreaEgg() end)
            Fluent:Notify({ Title = "Skid Hub", Content = "Dropped held egg", Duration = 3 })
        end
    })

    Tabs.Main:AddButton({
        Title = "🏠 Return to Base Now",
        Description = "Instantly moves your character back to your plot",
        Callback = function()
            task.spawn(Hub.runAutoReturn)
        end
    })

    -- === TAB 2: EVENT 🐊 & 🌸 (Hungry Monster & Sakura Event) ===
    Tabs.Event:AddSection("🐊 The Hungry Monster Event (Limited Time)")

    Tabs.Event:AddParagraph({
        Title = "🐊 The Hungry Monster Guide",
        Content = "• Vị trí: Ở gần khu vực Spawn / Máy Fuse.\n• Cách chơi: Cướp các quả trứng Ký Sinh (Infested Eggs với ký sinh tím trên đầu xuất hiện từ khu vực Snow trở đi).\n• Đem trứng về cho quái vật ăn (+20%/quả). Khi đủ 5 quả (100%), quái vật sẽ nhả Rương Monster Chest!\n• Phần thưởng: Cơ hội mở ra Monstrous Egg, Flyswatter, Speed Boost, v.v."
    })

    Tabs.Event:AddToggle("AutoFeedMonster", { Title = "Auto Steal & Feed The Hungry Monster", Default = false })
    Tabs.Event:AddToggle("AutoCollectMonsterChest", { Title = "Auto Collect & Open Monster Chests", Default = true })

    Tabs.Event:AddButton({
        Title = "📍 Teleport to The Hungry Monster",
        Callback = function()
            local monster = Hub.findHungryMonster()
            if monster then
                local pos = monster:GetPivot().Position
                local root = Hub.getRoot()
                if root then
                    root.CFrame = CFrame.new(pos.X, pos.Y + 2, pos.Z)
                    root.AssemblyLinearVelocity = Vector3.zero
                    Fluent:Notify({ Title = "Skid Hub", Content = "Teleported to The Hungry Monster!", Duration = 3 })
                end
            else
                Fluent:Notify({ Title = "Skid Hub", Content = "Hungry Monster NPC not found in workspace", Duration = 3 })
            end
        end
    })

    Tabs.Event:AddButton({
        Title = "🍗 Feed Current Held Egg to Monster Now",
        Callback = function()
            task.spawn(Hub.feedHungryMonster)
        end
    })

    Tabs.Event:AddButton({
        Title = "🎁 Collect All Monster Chests In Lobby",
        Callback = function()
            task.spawn(Hub.collectMonsterChests)
        end
    })

    Tabs.Event:AddToggle("EspHungryMonster", { Title = "The Hungry Monster ESP (Shows Hunger %)", Default = false })
    Tabs.Event:AddToggle("EspInfestedEggs", { Title = "Infested / Parasite Egg ESP (Purple)", Default = false })
    Tabs.Event:AddToggle("EspMonsterChests", { Title = "Monster Chest ESP (Gold)", Default = false })

    Tabs.Event:AddSection("🌸 Great Bloom Event & Sakura Biome")

    Tabs.Event:AddParagraph({
        Title = "Cherry Blossom (Sakura) Event Guide",
        Content = "• Great Bloom Event (Every 30m): Break Sakura Trees with Baseball Bat for Sakura Crystals.\n• Sakura Incubator: Offer a Crane pet once to unlock permanently, then use Crystals to apply Bloom (1.5x) or Spirit Bloom (3x) mutations.\n• Biome Requirement: High speed or Auto Steal bypass to evade Sakura Guardian."
    })

    Tabs.Event:AddToggle("AutoBloomEvent", { Title = "Auto Farm Sakura Trees (Great Bloom)", Default = false })
    Tabs.Event:AddToggle("AutoEquipBat", { Title = "Auto Equip Weapon / Baseball Bat", Default = true })
    Tabs.Event:AddToggle("AutoSakuraMutate", { Title = "Auto Mutate at Sakura Incubator", Default = false })
    Tabs.Event:AddToggle("AutoSacrificeCrane", { Title = "Auto Sacrifice Crane to Unlock Incubator", Default = false })

    Tabs.Event:AddButton({
        Title = "📍 Teleport to Cherry Blossom Biome",
        Callback = function()
            Hub.teleportToZone("Cherry Blossom")
        end
    })

    Tabs.Event:AddButton({
        Title = "🌸 Teleport to Sakura Incubator",
        Callback = function()
            Hub.teleportToSakuraIncubator()
        end
    })

    Tabs.Event:AddButton({
        Title = "🏏 Smash Nearest Sakura Tree Now",
        Callback = function()
            task.spawn(function()
                local ok = Hub.smashNearestSakuraTree()
                if ok then
                    Fluent:Notify({ Title = "Skid Hub", Content = "Smashing Sakura Tree!", Duration = 3 })
                else
                    Fluent:Notify({ Title = "Skid Hub", Content = "No Sakura Tree in range", Duration = 3 })
                end
            end)
        end
    })

    Tabs.Event:AddButton({
        Title = "🕊️ Offer Crane Pet to Incubator",
        Callback = function()
            task.spawn(Hub.sacrificeCrane)
        end
    })

    Tabs.Event:AddToggle("EspSakuraTrees", { Title = "Sakura Tree ESP", Default = false })
    Tabs.Event:AddToggle("EspSakuraIncubator", { Title = "Sakura Incubator ESP", Default = false })
    Tabs.Event:AddToggle("EspSakuraCrystals", { Title = "Sakura Crystal ESP", Default = false })

    -- === TAB 3: VISUALS (ESP & Lighting) ===
    Tabs.Visuals:AddSection("ESP Trackers")

    Tabs.Visuals:AddToggle("EspWorldEggs", { Title = "World Egg ESP", Default = false })
    Tabs.Visuals:AddToggle("EspCarriedEggs", { Title = "Carried & Dropped Egg ESP", Default = false })
    Tabs.Visuals:AddToggle("EspGuards", { Title = "Guard ESP", Default = false })
    Tabs.Visuals:AddToggle("EspPets", { Title = "Pet ESP", Default = false })
    Tabs.Visuals:AddToggle("EspPlayers", { Title = "Player ESP", Default = false })
    Tabs.Visuals:AddToggle("EspMachines", { Title = "Machine ESP", Default = false })
    Tabs.Visuals:AddToggle("EspPlots", { Title = "Plot ESP", Default = false })

    Tabs.Visuals:AddSlider("EspDistance", {
        Title = "Render Distance Limit",
        Description = "Maximum ESP distance in studs",
        Default = 2000,
        Min = 100,
        Max = 6000,
        Rounding = 0,
    })

    Tabs.Visuals:AddSection("Lighting & Field of View")

    local FullbrightToggle = Tabs.Visuals:AddToggle("Fullbright", { Title = "Fullbright (No Darkness)", Default = false })
    FullbrightToggle:OnChanged(function(val)
        if val then Hub.enableFullbright() else Hub.disableFullbright() end
    end)

    local FovSlider = Tabs.Visuals:AddSlider("FieldOfView", {
        Title = "Field of View (FOV)",
        Default = 70,
        Min = 50,
        Max = 120,
        Rounding = 0,
        Callback = function(val)
            Hub.applyFov(val)
        end
    })

    Tabs.Visuals:AddButton({
        Title = "Reset Field of View",
        Callback = function()
            FovSlider:SetValue(70)
        end
    })

    -- === TAB 4: MOVEMENT ===
    Tabs.Movement:AddSection("Character Speed & Jump")

    Tabs.Movement:AddToggle("InstantPrompt", { Title = "⚡ Instant Proximity Prompts (0s Hold)", Default = true })

    local WalkSpeedToggle = Tabs.Movement:AddToggle("WalkSpeedEnabled", { Title = "Walk Speed Override", Default = false })
    WalkSpeedToggle:OnChanged(function(val)
        if val then
            pcall(Hub.swapStealHumanoid)
            local hum = Hub.getHumanoid()
            if hum then hum.WalkSpeed = Options.WalkSpeed.Value end
        else
            local hum = Hub.getHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end)

    local WalkSpeedSlider = Tabs.Movement:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Default = 64,
        Min = 16,
        Max = 1500,
        Rounding = 0,
        Callback = function(val)
            if Hub.isOn("WalkSpeedEnabled") then
                local hum = Hub.getHumanoid()
                if hum then hum.WalkSpeed = val end
            end
        end
    })

    local JumpPowerToggle = Tabs.Movement:AddToggle("JumpPowerEnabled", { Title = "Jump Power Override", Default = false })
    JumpPowerToggle:OnChanged(function(val)
        if not val then
            local hum = Hub.getHumanoid()
            if hum then hum.JumpPower = 50 end
        end
    end)

    Tabs.Movement:AddSlider("JumpPower", {
        Title = "Jump Power",
        Default = 50,
        Min = 10,
        Max = 500,
        Rounding = 0,
        Callback = function(val)
            if Hub.isOn("JumpPowerEnabled") then
                local hum = Hub.getHumanoid()
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = val
                end
            end
        end
    })

    Tabs.Movement:AddToggle("InfJump", { Title = "Infinite Jump", Default = false })
    Tabs.Movement:AddToggle("NoClip", { Title = "NoClip (Walk Through Objects)", Default = false })

    Tabs.Movement:AddSection("Flight & Physics")

    local FlyToggle = Tabs.Movement:AddToggle("Fly", { Title = "Fly Mode (W/A/S/D/Space/Ctrl)", Default = false })
    FlyToggle:OnChanged(function(val)
        local hum = Hub.getHumanoid()
        if hum and not val then hum.PlatformStand = false end
    end)

    Tabs.Movement:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Default = 150,
        Min = 10,
        Max = 1500,
        Rounding = 0,
    })

    Tabs.Movement:AddSlider("CustomGravity", {
        Title = "World Gravity",
        Default = 196.2,
        Min = 0,
        Max = 400,
        Rounding = 1,
        Callback = function(val)
            Hub.applyGravity(val)
        end
    })

    -- === TAB 4: TELEPORT ===
    Tabs.Teleport:AddSection("Zone Teleportation")

    Tabs.Teleport:AddDropdown("SelectedZoneTp", {
        Title = "Select Zone Destination",
        Values = Zones,
        Multi = false,
        Default = "Forest",
    })

    Tabs.Teleport:AddButton({
        Title = "📍 Teleport to Selected Zone",
        Callback = function()
            local zone = Options.SelectedZoneTp.Value
            if zone then Hub.teleportToZone(zone) end
        end
    })

    Tabs.Teleport:AddButton({
        Title = "🏠 Teleport to My Base",
        Callback = function()
            Hub.teleportToBase()
        end
    })

    Tabs.Teleport:AddSection("Player Teleportation")

    local function getPlayerList()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
            end
        end
        if #list == 0 then table.insert(list, "No other players") end
        return list
    end

    local PlayerDropdown = Tabs.Teleport:AddDropdown("SelectedPlayerTp", {
        Title = "Select Target Player",
        Values = getPlayerList(),
        Multi = false,
        Default = getPlayerList()[1],
    })

    Tabs.Teleport:AddButton({
        Title = "🚀 Teleport to Player",
        Callback = function()
            local val = Options.SelectedPlayerTp.Value
            if val and val ~= "No other players" then
                local username = val:match("%(@(.+)%)") or val
                Hub.teleportToPlayer(username)
            else
                Fluent:Notify({ Title = "Skid Hub", Content = "No player selected", Duration = 3 })
            end
        end
    })

    Tabs.Teleport:AddButton({
        Title = "🔄 Refresh Player List",
        Callback = function()
            PlayerDropdown:SetValues(getPlayerList())
            PlayerDropdown:SetValue(getPlayerList()[1])
            Fluent:Notify({ Title = "Skid Hub", Content = "Player list refreshed", Duration = 3 })
        end
    })

    -- === TAB 5: MISC ===
    Tabs.Misc:AddSection("Performance & AFK")

    Tabs.Misc:AddToggle("AntiAfk", { Title = "Anti-AFK (Prevent 20min Kick)", Default = true })

    local FpsBoostToggle = Tabs.Misc:AddToggle("FpsBoost", { Title = "FPS Boost (Disable Laggy Particles)", Default = false })
    FpsBoostToggle:OnChanged(function(val)
        Hub.applyFpsBoost(val)
    end)

    Tabs.Misc:AddSlider("FpsCap", {
        Title = "FPS Limit",
        Default = 60,
        Min = 30,
        Max = 240,
        Rounding = 0,
        Callback = function(val)
            Hub.applyFpsCap(val)
        end
    })

    Tabs.Misc:AddButton({
        Title = "🔁 Rejoin Current Server",
        Callback = function()
            Hub.rejoinServer()
        end
    })

    Tabs.Misc:AddSection("Live Player Statistics")

    local StatsParagraph = Tabs.Misc:AddParagraph({
        Title = "Player Status",
        Content = "Health: Loading...\nWalkSpeed: Loading...\nEgg Inventory: Loading...\nEggs Stolen: 0\nPosition: Loading..."
    })

    local function refreshStats()
        local info = Hub.getCharacterInfo()
        StatsParagraph:SetDesc(string.format(
            "Health: %s\nWalkSpeed: %s\nEgg Inventory: %s\nEggs Stolen: %s\nPosition: %s",
            info.Health,
            info.WalkSpeed,
            info.EggCount,
            info.StolenCount,
            info.Position
        ))
    end

    Tabs.Misc:AddButton({
        Title = "🔄 Update Statistics",
        Callback = function()
            refreshStats()
            Fluent:Notify({ Title = "Skid Hub", Content = "Statistics refreshed", Duration = 3 })
        end
    })

    -- Build Save & Interface Manager
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("SkidHub")
    SaveManager:SetFolder("SkidHub/StealAnEgg")

    InterfaceManager:BuildInterfaceSection(Tabs.Misc)
    SaveManager:BuildConfigSection(Tabs.Misc)

    Window:SelectTab(1)

    -- =========================================================================
    -- 12. RUNTIME EVENT LOOPS & HOOKS
    -- =========================================================================
    if not EspFolder or not EspFolder.Parent then
        EspFolder = Instance.new("Folder")
        EspFolder.Name = "SkidEsp"
        EspFolder.Parent = Workspace
    end

    CarryConnection = EggStateAPI.AreaEggCarryStateChanged:Connect(function(data)
        if typeof(data) == "table" and (data.IsCarrying == true or data.Carrying == true) then
            local wasCarrying = IsCarrying
            if not wasCarrying then
                CarriedCount = CarriedCount + 1
            end
            IsCarrying = true
        else
            IsCarrying = false
        end
    end)

    CarryCallback = EggStateAPI.AreaEggCarryStateChanged:Connect(function(data)
        if typeof(data) == "table" and (data.IsCarrying == true or data.Carrying == true) then
            if Hub.isOn("AutoDropEgg") then
                pcall(function()
                    EggStateAPI.RequestDropHeldAreaEgg()
                end)
            elseif Hub.isOn("AutoReturn") then
                pcall(Hub.runAutoReturn)
            end
        end
    end)

    UserInputService.InputBegan:Connect(function()
        LastInputTime = tick()
    end)

    -- Anti-AFK Loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(1)
            if Hub.isOn("AntiAfk") then
                local idle = tick() - LastInputTime
                if idle >= 120 then
                    pcall(Hub.antiAfkTap)
                end
            end
        end
    end)

    -- Continuous Anti-PushBack & Clean Humanoid Loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(0.35)
            if not Fluent.Unloaded and (Hub.stealingEnabled() or Hub.isOn("WalkSpeedEnabled") or Hub.isOn("Fly")) then
                pcall(Hub.swapStealHumanoid)
            end
        end
    end)

    -- Anti-Velocity Rubberband Loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(0.1)
            if not Fluent.Unloaded and (Hub.stealingEnabled() or Hub.isOn("WalkSpeedEnabled")) then
                local root = Hub.getRoot()
                local humanoid = Hub.getHumanoid()
                if root and humanoid and humanoid:GetAttribute("SkidHum") == true then
                    local laneY = Hub.getLaneY()
                    if root.Position.Y > laneY + 12 and not Hub.isOn("Fly") then
                        local velocity = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)
                    end
                end
            end
        end
    end)

    -- Instant ProximityPrompt Hook (0s Hold)
    local ProximityPromptService = game:GetService("ProximityPromptService")
    pcall(function()
        ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
            if Hub.isOn("InstantPrompt") or Hub.isOn("InstantSteal") then
                pcall(function()
                    prompt.HoldDuration = 0
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        prompt:InputHoldBegin()
                        task.wait()
                        prompt:InputHoldEnd()
                    end
                end)
            end
        end)
    end)

    pcall(function()
        Workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") and (Hub.isOn("InstantPrompt") or Hub.isOn("InstantSteal")) then
                desc.HoldDuration = 0
            end
        end)
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
            end
        end
    end)

    -- The Hungry Monster Auto Feed Loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(0.25)
            if not Fluent.Unloaded and Hub.isOn("AutoFeedMonster") then
                pcall(Hub.runAutoFeedMonster)
            end
        end
    end)

    -- Auto Steal loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(0.25)
            if not Hub.isCarrying() and not Fluent.Unloaded and Hub.stealingEnabled() then
                pcall(Hub.runAutoSteal)
            end
        end
    end)

    -- Great Bloom Event loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(0.25)
            if not Fluent.Unloaded and Hub.isOn("AutoBloomEvent") and not Hub.isCarrying() then
                pcall(Hub.smashNearestSakuraTree)
            end
        end
    end)

    -- Sakura Mutate loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(1.5)
            if not Fluent.Unloaded and Hub.isOn("AutoSakuraMutate") and not Hub.isCarrying() then
                pcall(Hub.mutateAtSakuraIncubator)
            end
        end
    end)

    -- ESP loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(0.5)
            if not Fluent.Unloaded then
                pcall(Hub.runEsp)
            end
        end
    end)

    -- Stats refresh loop
    task.spawn(function()
        while not Fluent.Unloaded do
            task.wait(2)
            if not Fluent.Unloaded then
                pcall(refreshStats)
            end
        end
    end)

    -- Infinite Jump
    UserInputService.JumpRequest:Connect(function()
        if Fluent.Unloaded then return end
        if Hub.isOn("InfJump") then
            local hum = Hub.getHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    -- RenderStepped Loop (WalkSpeed, JumpPower, Fly, NoClip)
    RunService.RenderStepped:Connect(function(delta)
        if Fluent.Unloaded then return end

        if Hub.isOn("WalkSpeedEnabled") then
            local hum = Hub.getHumanoid()
            if hum then
                hum.WalkSpeed = Options.WalkSpeed.Value
            end
        end

        if Hub.isOn("JumpPowerEnabled") then
            local hum = Hub.getHumanoid()
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = Options.JumpPower.Value
            end
        end

        if Hub.isOn("Fly") then
            Hub.updateFly(delta)
        end

        if Hub.isOn("NoClip") then
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        if Fluent.Unloaded then return end
        task.wait(0.35)
        if Hub.stealingEnabled() or Hub.isOn("WalkSpeedEnabled") or Hub.isOn("Fly") then
            pcall(Hub.swapStealHumanoid)
        end
    end)

    SaveManager:LoadAutoloadConfig()

    Fluent:Notify({
        Title = "Skid Hub ⚡",
        Content = "Loaded successfully! Press LeftControl to toggle.",
        Duration = 5
    })
    print("[SkidHub] Loaded successfully with Fluent UI!")
end)

if not loadError then
    print("[SkidHub] Script initialized successfully")
else
    warn("[SkidHub] Failed to load: " .. tostring(loadError))
end
