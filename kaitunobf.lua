--// ================= BLOX FRUITS COMPATIBILITY SHIM =================
do
    local RS = game:GetService("ReplicatedStorage")
    if not RS:FindFirstChild("Library") then
        local fakeLibrary = Instance.new("Folder")
        fakeLibrary.Name = "Library"
        fakeLibrary.Parent = RS
    end
    if not RS:FindFirstChild("Package") then
        local fakePackage = Instance.new("Folder")
        fakePackage.Name = "Package"
        fakePackage.Parent = RS
    end
end

Config = {
    Team = "Pirates",
    FPS = 60,
    TweenSpeed = 270,
    Configuration = {
        HopWhenIdle = true,
        AutoHop = true,
        AutoHopDelay = 60 * 60,
        FpsBoost = false,
        blackscreen = false,
        TweenSpeed = 270
    },
    Fruit ={
        Sniper = true,
        Fruit = {"Kitsune-Kitsune"}
    },
    Items = {
        -- Melees 
        AutoFullyMelees = true,

        -- Swords 
        Saber = true,
        CursedDualKatana = false,

        -- Guns 
        SoulGuitar = true,

        -- Upgrades 

        RaceV2 = true

    },
    Settings = {
        StayInSea2UntilHaveDarkFragments = false
    }
}
function CheckKick(v)
    if v and v.Name == "ErrorPrompt" then
        task.wait(2)
        pcall(function()
            if v:FindFirstChild("TitleFrame") and v.TitleFrame:FindFirstChild("ErrorTitle") then
                if v.TitleFrame.ErrorTitle.Text == "Teleport Failed" then
                    if v:FindFirstChild("MessageArea") and v.MessageArea:FindFirstChild("ErrorFrame") and string.find(v.MessageArea.ErrorFrame.ErrorMessage.Text, "Unable to join game") then
                        return
                    end
                else
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                    v:Destroy()
                end
            end
        end)
    end
end

pcall(function()
    game:GetService('CoreGui').RobloxPromptGui.promptOverlay.ChildAdded:Connect(CheckKick)
end)
        
    local LogService = game:GetService('LogService')
    local GameName = "Blox Fruit" 

    pcall(function() 
        GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end) 

    local StartTime = os.time()

    local Traces = {} 


    function Build(Error) 
        print("Error\n\n", Error, "\n\n")
        local Result =  {
        content = "<@1330431331057799209>",
        embeds = {
            {
            title = GameName,
            description = game.PlaceId .. " | " .. game.JobId,
            color = 15642286,
            fields = {
                {
                name = "Error Details",
                value = Error
                },
                {   
                name = "Player Info",
                value = "Level: " ..  ScriptStorage.PlayerData.Level
                },
                {
                name = "Script Details",
                value = GetCurrentDateTime() .. " | ".. DispTime(os.time() - StartTime, true)
                .." after execution\nMain task: " .. (  ScriptStorage.Task.MainTask or "n/a" )  .. " ( " .. (  ScriptStorage.Task["MainTask-d"] and  DispTime(os.time() -  ScriptStorage.Task["MainTask-d"], true) or "n/a" ) .. " ) \nSub task: " .. (  ScriptStorage.Task.SubTask or "n/a" ) .. " ( " .. (  ScriptStorage.Task["SubTask-d"] and DispTime(os.time() -  ScriptStorage.Task["SubTask-d"], true) or "n/a") .. " )"
                },
                {
                name = "Traceback",
                value = (function() 
                    local Result = ""
                    
                    for Index , Content in  ScriptStorage.Tracebacks do 
                        
                        if # ScriptStorage.Tracebacks > 20 then 
                            break
                        end
                        
                        Result = Result .. (Content or "null") .. "\n" 
                    end 
                    
                    return Result ~= "" and Result or "... ( empty list ) "
                    
                    end)()
                }
            },
            author = {
                name = tostring(LocalPlayer)
            }
            }
        },
        attachments = {}
        }
        
        for Index, Value in Result.embeds[1].fields do 
            Value.value = "```" .. Value.value .. "```"
        end 
        return Result
    end 

    function Report(Message) 
        if true then 
            if Traces[Message] then return end 
            Traces[Message] = true 
            
            local Body  = game:GetService("HttpService"):JSONEncode(Build(Message)) 
            
            local AffectedIndexes = {0,0,0,0}
            
            request({
                Url = "https://discord.com/api/webhooks/1343574235213467718/uo1MdtlhfKOTQZ8CHIQTKDT4DxCpIMUw3XnDYafeXmUuBvqOgGYI8tmCVdc2XCBpN_yo", 
                Method = "POST", 
                Headers = {["Content-Type"] = "application/json"}, 
                Body = Body 
            })
        end 
    end

    function mmb() 
        local UIController = {
            _gui = nil,
            _elements = {},
            _visible = true
        }

        local function FormatNumber(n)
            local formatted = tostring(math.floor(tonumber(n) or 0))
            local k
            while true do
                formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
                if k == 0 then break end
            end
            return formatted
        end

        local function MakeDraggable(frame, dragHandle)
            -- UI is static and immovable by design
        end

        function UIController:Init()
            pcall(function()
                local parents = {}
                if gethui then pcall(function() table.insert(parents, gethui()) end) end
                pcall(function() if game:GetService("CoreGui") then table.insert(parents, game:GetService("CoreGui")) end end)
                pcall(function() if game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui") then table.insert(parents, game.Players.LocalPlayer.PlayerGui) end end)
                for _, p in ipairs(parents) do
                    for _, c in ipairs(p:GetChildren()) do
                        if c.Name == "skidhub_ui" or c.Name == "SkidHubKaitunUI" or c.Name == "3TN" then
                            pcall(function() c:Destroy() end)
                        end
                    end
                end
            end)
            
            local targetParent = (gethui and gethui()) or (game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui")) or game.Players.LocalPlayer:WaitForChild("PlayerGui")
            local gui = Instance.new("ScreenGui")
            gui.Name = "skidhub_ui"
            gui.Parent = targetParent
            gui.Enabled = true
            gui.ResetOnSpawn = false
            gui.DisplayOrder = 100
            self._gui = gui
            
            if Config and Config.Configuration and Config.Configuration.blackscreen then
                pcall(function()
                    game:GetService("Lighting").ExposureCompensation = -math.huge
                end)
            end
            
            local mainFrame = Instance.new("Frame")
            mainFrame.Name = "Frame"
            mainFrame.AnchorPoint = Vector2.new(0.5, 0)
            mainFrame.Position = UDim2.new(0.5, 0, 0, 16)
            mainFrame.Size = UDim2.new(0, 550, 0, 185)
            mainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
            mainFrame.BackgroundTransparency = 0.08
            mainFrame.BorderSizePixel = 0
            mainFrame.Active = false
            mainFrame.Parent = gui
            self._elements["MainFrame"] = mainFrame
            
            local mainCorner = Instance.new("UICorner", mainFrame)
            mainCorner.CornerRadius = UDim.new(0, 14)
            
            local mainStroke = Instance.new("UIStroke", mainFrame)
            mainStroke.Color = Color3.fromRGB(0, 200, 255)
            mainStroke.Thickness = 1.6
            mainStroke.Transparency = 0.25
            
            local mainGradient = Instance.new("UIGradient", mainFrame)
            mainGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 28, 48)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 16, 28)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 14, 24)),
            })
            mainGradient.Rotation = 135
            
            local headerFrame = Instance.new("Frame")
            headerFrame.Name = "Header"
            headerFrame.Size = UDim2.new(1, -20, 0, 34)
            headerFrame.Position = UDim2.new(0, 10, 0, 6)
            headerFrame.BackgroundTransparency = 1
            headerFrame.Parent = mainFrame
            
            local titleLabel = Instance.new("TextLabel", headerFrame)
            titleLabel.Position = UDim2.new(0, 4, 0, 0)
            titleLabel.Size = UDim2.new(0, 260, 0, 18)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = "⚡ SKID HUB KAITUN"
            titleLabel.TextSize = 15
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local subLabel = Instance.new("TextLabel", headerFrame)
            subLabel.Position = UDim2.new(0, 4, 0, 18)
            subLabel.Size = UDim2.new(0, 260, 0, 14)
            subLabel.BackgroundTransparency = 1
            subLabel.Text = "REFACTORED MODULAR ENGINE"
            subLabel.TextSize = 9
            subLabel.Font = Enum.Font.GothamMedium
            subLabel.TextColor3 = Color3.fromRGB(100, 160, 230)
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local badgeContainer = Instance.new("Frame", headerFrame)
            badgeContainer.Size = UDim2.new(0, 220, 0, 26)
            badgeContainer.Position = UDim2.new(1, -224, 0, 4)
            badgeContainer.BackgroundTransparency = 1
            
            local badgeLayout = Instance.new("UIListLayout", badgeContainer)
            badgeLayout.FillDirection = Enum.FillDirection.Horizontal
            badgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            badgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            badgeLayout.Padding = UDim.new(0, 6)
            
            local statusBadge = Instance.new("TextLabel", badgeContainer)
            statusBadge.Size = UDim2.new(0, 110, 0, 22)
            statusBadge.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
            statusBadge.BackgroundTransparency = 0.75
            statusBadge.Text = "🟢 FARMING ACTIVE"
            statusBadge.TextColor3 = Color3.fromRGB(0, 255, 170)
            statusBadge.Font = Enum.Font.GothamBold
            statusBadge.TextSize = 9
            Instance.new("UICorner", statusBadge).CornerRadius = UDim.new(0, 6)
            self._elements["StatusBadge"] = statusBadge
            
            local fpsBadge = Instance.new("TextLabel", badgeContainer)
            fpsBadge.Size = UDim2.new(0, 65, 0, 22)
            fpsBadge.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
            fpsBadge.BackgroundTransparency = 0.5
            fpsBadge.Text = "60 FPS"
            fpsBadge.TextColor3 = Color3.fromRGB(180, 210, 245)
            fpsBadge.Font = Enum.Font.GothamMedium
            fpsBadge.TextSize = 9
            Instance.new("UICorner", fpsBadge).CornerRadius = UDim.new(0, 6)
            self._elements["FPS"] = fpsBadge
            
            local statsGrid = Instance.new("Frame", mainFrame)
            statsGrid.Name = "StatsGrid"
            statsGrid.Size = UDim2.new(1, -20, 0, 28)
            statsGrid.Position = UDim2.new(0, 10, 0, 44)
            statsGrid.BackgroundColor3 = Color3.fromRGB(8, 12, 22)
            statsGrid.BackgroundTransparency = 0.4
            Instance.new("UICorner", statsGrid).CornerRadius = UDim.new(0, 8)
            
            local statsLayout = Instance.new("UIGridLayout", statsGrid)
            statsLayout.FillDirection = Enum.FillDirection.Horizontal
            statsLayout.CellSize = UDim2.new(0.25, -6, 1, -4)
            statsLayout.CellPadding = UDim2.new(0, 6, 0, 0)
            statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            
            local function CreateChip(name, color)
                local chip = Instance.new("Frame", statsGrid)
                chip.BackgroundTransparency = 1
                local txt = Instance.new("TextLabel", chip)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 11
                txt.TextColor3 = color
                txt.TextXAlignment = Enum.TextXAlignment.Center
                return txt
            end
            
            self._elements["ChipLevel"] = CreateChip("Level", Color3.fromRGB(0, 240, 255))
            self._elements["ChipBeli"] = CreateChip("Beli", Color3.fromRGB(100, 255, 140))
            self._elements["ChipFrags"] = CreateChip("Frags", Color3.fromRGB(210, 130, 255))
            self._elements["ChipWeapon"] = CreateChip("Weapon", Color3.fromRGB(255, 210, 100))
            
            local features = Instance.new("Frame", mainFrame)
            features.Name = "Features"
            features.Position = UDim2.new(0, 10, 0, 78)
            features.Size = UDim2.new(1, -20, 0, 80)
            features.BackgroundTransparency = 1
            
            local fLayout = Instance.new("UIListLayout", features)
            fLayout.SortOrder = Enum.SortOrder.LayoutOrder
            fLayout.Padding = UDim.new(0, 4)
            
            local function CreateTaskRow(name, color, order)
                local row = Instance.new("Frame", features)
                row.Size = UDim2.new(1, 0, 0, 23)
                row.BackgroundColor3 = Color3.fromRGB(15, 20, 34)
                row.BackgroundTransparency = 0.45
                row.LayoutOrder = order
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                
                local txt = Instance.new("TextLabel", row)
                txt.Size = UDim2.new(1, -12, 1, 0)
                txt.Position = UDim2.new(0, 8, 0, 0)
                txt.BackgroundTransparency = 1
                txt.Font = Enum.Font.GothamMedium
                txt.TextSize = 11
                txt.TextColor3 = color
                txt.TextXAlignment = Enum.TextXAlignment.Left
                return txt
            end
            
            self._elements["Task1"] = CreateTaskRow("Task1", Color3.fromRGB(0, 230, 255), 1)
            self._elements["Task2"] = CreateTaskRow("Task2", Color3.fromRGB(160, 220, 255), 2)
            self._elements["Task3"] = CreateTaskRow("Task3", Color3.fromRGB(0, 255, 170), 3)
            
            local footer = Instance.new("TextLabel", mainFrame)
            footer.Size = UDim2.new(1, -20, 0, 16)
            footer.Position = UDim2.new(0, 10, 1, -20)
            footer.BackgroundTransparency = 1
            footer.Font = Enum.Font.Gotham
            footer.TextSize = 9
            footer.TextColor3 = Color3.fromRGB(120, 150, 190)
            footer.Text = "⚡ Kaitun Engine Active • Sea 1"
            footer.TextXAlignment = Enum.TextXAlignment.Center
            self._elements["Footer"] = footer

            MakeDraggable(mainFrame, headerFrame)
            MakeDraggable(mainFrame, mainFrame)

            local lastFpsTick = os.clock()
            local frameCount = 0
            game:GetService("RunService").RenderStepped:Connect(function()
                frameCount = frameCount + 1
                local now = os.clock()
                if now - lastFpsTick >= 0.5 then
                    local fps = math.floor(frameCount / (now - lastFpsTick))
                    if self._elements["FPS"] then
                        self._elements["FPS"].Text = tostring(fps) .. " FPS"
                    end
                    frameCount = 0
                    lastFpsTick = now
                end
            end)

            task.spawn(function()
                while task.wait(0.2) do
                    pcall(function()
                        if self._gui and self._gui.Enabled then
                            self:Update()
                        end
                    end)
                end
            end)
        end

        function UIController:Update()
            if not self._gui then return end
            pcall(function()
                local lvl = (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or (game.Players.LocalPlayer:FindFirstChild("Data") and game.Players.LocalPlayer.Data:FindFirstChild("Level") and game.Players.LocalPlayer.Data.Level.Value) or 1
                local beli = (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Beli) or (game.Players.LocalPlayer:FindFirstChild("Data") and game.Players.LocalPlayer.Data:FindFirstChild("Beli") and game.Players.LocalPlayer.Data.Beli.Value) or 0
                local frags = (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Fragments) or (game.Players.LocalPlayer:FindFirstChild("Data") and game.Players.LocalPlayer.Data:FindFirstChild("Fragments") and game.Players.LocalPlayer.Data.Fragments.Value) or 0
                
                if self._elements["ChipLevel"] then
                    self._elements["ChipLevel"].Text = "⭐ Lv. " .. FormatNumber(lvl) .. "/2750"
                end
                if self._elements["ChipBeli"] then
                    self._elements["ChipBeli"].Text = "💰 $" .. FormatNumber(beli)
                end
                if self._elements["ChipFrags"] then
                    self._elements["ChipFrags"].Text = "💎 " .. FormatNumber(frags) .. " F"
                end
                if self._elements["ChipWeapon"] then
                    local char = game.Players.LocalPlayer.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then
                        local m = (tool:FindFirstChild("Level") and tool.Level.Value) or (ScriptStorage and ScriptStorage.Melees and ScriptStorage.Melees[tool.Name]) or 0
                        self._elements["ChipWeapon"].Text = "⚔️ " .. tool.Name .. " (" .. m .. ")"
                    elseif ScriptStorage and ScriptStorage.CurrentMeleeData and ScriptStorage.CurrentMeleeData.Name then
                        local m = (ScriptStorage.Melees and ScriptStorage.Melees[ScriptStorage.CurrentMeleeData.Name]) or 0
                        self._elements["ChipWeapon"].Text = "⚔️ " .. ScriptStorage.CurrentMeleeData.Name .. " (" .. m .. ")"
                    else
                        self._elements["ChipWeapon"].Text = "⚔️ Combat"
                    end
                end
                
                local mainTask = (ScriptStorage and ScriptStorage.Task and ScriptStorage.Task.MainTask)
                if not mainTask or mainTask == "n/a" or mainTask == "" then
                    if ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level then
                        if ScriptStorage.PlayerData.Level >= 2025 and (ScriptStorage.Backpack.Bones or {Count=0}).Count < 500 then
                            local bCount = (ScriptStorage.Backpack.Bones or {Count=0}).Count
                            mainTask = "Resource Farming | Bones (" .. bCount .. "/500)"
                        else
                            mainTask = "Level Farming | Progression"
                        end
                    else
                        mainTask = "Auto Farming | Progression"
                    end
                end

                local subTask = (ScriptStorage and ScriptStorage.Task and ScriptStorage.Task.SubTask)
                if not subTask or subTask == "n/a" or subTask == "" then
                    if GetCurrentClaimQuest then
                        local ok, q = pcall(GetCurrentClaimQuest)
                        if ok and q and q ~= "" then
                            subTask = "Quest: " .. tostring(q)
                        end
                    end
                    if not subTask or subTask == "n/a" or subTask == "" then
                        if ScriptStorage and ScriptStorage.Backpack and ScriptStorage.Backpack.Bones then
                            local bCount = (ScriptStorage.Backpack.Bones or {Count=0}).Count
                            subTask = "Haunted Castle • Bones: " .. bCount .. " / 500"
                        else
                            subTask = "Auto Quest Active"
                        end
                    end
                end

                local miniTask = (ScriptStorage and ScriptStorage.Task and (ScriptStorage.Task.MiniTask or ScriptStorage.Task.DebugLine or ScriptStorage.Task.MainTextLabel))
                if not miniTask or miniTask == "LevelFarm" or miniTask == "n/a" or miniTask == "" then
                    if MonResult and MonResult.Parent and MonResult:FindFirstChild("Humanoid") then
                        local hpPct = math.floor((MonResult.Humanoid.Health / math.max(1, MonResult.Humanoid.MaxHealth)) * 100)
                        miniTask = "Attacking " .. tostring(MonResult.Name) .. " [HP: " .. hpPct .. "%]"
                    elseif CurrentTask and CurrentTask ~= "LevelFarm" then
                        miniTask = tostring(CurrentTask)
                    else
                        miniTask = "Farming Mobs with Fast Attack"
                    end
                end

                if self._elements["Task1"] then
                    self._elements["Task1"].Text = "📌 Mode: " .. tostring(mainTask)
                end
                if self._elements["Task2"] then
                    self._elements["Task2"].Text = "🎯 Quest: " .. tostring(subTask)
                end
                if self._elements["Task3"] then
                    self._elements["Task3"].Text = "⚡ Action: " .. tostring(miniTask)
                end

                local currentSea = (SeaIndex) or (game.PlaceId == 2753915549 and 1 or game.PlaceId == 4442272183 and 2 or game.PlaceId == 7449423635 and 3 or 1)
                local elapsed = math.max(0, (StartTime and (os.time() - StartTime)) or 0)
                local totalElapsed = math.max(0, elapsed + math.max(0, OldSessionTime or 0))
                local timeStr = ""
                if DispTime then
                    timeStr = " • " .. DispTime(totalElapsed, true)
                end

                if self._elements["Footer"] then
                    self._elements["Footer"].Text = "⚡ Kaitun Engine Active • Sea " .. tostring(currentSea) .. timeStr
                end
            end)
        end

        UIController:Init()

        local Interface = {
            Instances = setmetatable({}, {
                __index = function(self, key)
                    local fake = {Text = "", TextTransparency = 0, Visible = true}
                    rawset(self, key, fake)
                    return fake
                end
            }),
            UIController = UIController
        }

        function SetText(Name, Text)
            pcall(function()
                if not UIController._gui then return end
                if Name == "Task1" or Name == "MainTask" then
                    local val = tostring(Text):gsub("^MainTask%s*:%s*", "")
                    if ScriptStorage and ScriptStorage.Task then
                        ScriptStorage.Task.MainTask = val
                    end
                    if UIController._elements["Task1"] then
                        UIController._elements["Task1"].Text = "📌 Mode: " .. val
                    end
                elseif Name == "Task2" or Name == "SubTask" then
                    local val = tostring(Text):gsub("^SubTask%s*:%s*", "")
                    if ScriptStorage and ScriptStorage.Task then
                        ScriptStorage.Task.SubTask = val
                    end
                    if UIController._elements["Task2"] then
                        UIController._elements["Task2"].Text = "🎯 Quest: " .. val
                    end
                elseif Name == "Task3" or Name == "DebugLine" or Name == "MainTextLabel" then
                    if ScriptStorage and ScriptStorage.Task then
                        ScriptStorage.Task.MiniTask = tostring(Text)
                    end
                    if UIController._elements["Task3"] then
                        UIController._elements["Task3"].Text = "⚡ Action: " .. tostring(Text)
                    end
                elseif Name == "Currencies" or Name == "Melees" then
                    UIController:Update()
                elseif Name == "LiveTime" then
                    if UIController._elements["Footer"] then
                        local currentSea = (SeaIndex) or (game.PlaceId == 2753915549 and 1 or game.PlaceId == 4442272183 and 2 or game.PlaceId == 7449423635 and 3 or 1)
                        local elapsed = math.max(0, (StartTime and (os.time() - StartTime)) or 0)
                        local totalElapsed = math.max(0, elapsed + math.max(0, OldSessionTime or 0))
                        local timeStr = DispTime(totalElapsed, true)
                        UIController._elements["Footer"].Text = "⚡ Kaitun Engine Active • Sea " .. tostring(currentSea) .. " • " .. timeStr
                    end
                end
                if Interface.Instances[Name] then
                    Interface.Instances[Name].Text = tostring(Text)
                end
            end)
        end

        function ToggleUI(State)
            if State == nil then
                UIController._visible = not UIController._visible
            else
                UIController._visible = State
            end
            if UIController._gui then
                UIController._gui.Enabled = UIController._visible
            end
        end

        Interface.SetText = SetText
        Interface.ToggleUI = ToggleUI
        Interface.ToggleInterface = ToggleUI
        getgenv().UIController = UIController

        pcall(function()
            if not isfile("fluent.lua") then
                writefile("fluent.lua", game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))
            end
            local Fluent = loadstring(readfile("fluent.lua"))()
            if Fluent then
                getgenv().alert = function(t1, t2)
                    pcall(function()
                        Fluent:Notify({
                            Title = t1 or "",
                            Content = t2 or "",
                            Duration = 5
                        })
                    end)
                end
            end
        end)

        if not getgenv().alert then
            getgenv().alert = function(...) end
        end

        local Animation = Instance.new('Animation')
        Animation.AnimationId = 'http://www.roblox.com/asset/?id=1elutruahuabuahd'
        
        StartTime = os.time()
        
        OldSessionTime = isfile(".tdif-" .. game.Players.LocalPlayer.Name) and
                            tonumber(readfile(".tdif-" .. game.Players.LocalPlayer.Name)) or 0
        if not OldSessionTime or OldSessionTime > 100000000 or OldSessionTime < 0 then
            OldSessionTime = 0
        end
        
        pcall(function()
            if not game.Players.LocalPlayer.Character then
                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", Config.Team or "Pirates")
            end
        end)

        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        
        spawn(function()
            pcall(function()
                local Lighting = game:GetService("Lighting")
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
                        v.Enabled = false
                    end
                end
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
                workspace.DescendantAdded:Connect(function(v)
                    pcall(function()
                        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                            v.Enabled = false
                        end
                    end)
                end)
            end)
        end)
 
        local Segmants = {"RawConstants", "Utilly", "QuestManager", "SpawnRegionLoader", "TweenController", "AttackController",
                        "CombatController", "FunctionsHandler", "Hooks", "Debug", "Hop", "Storage"}
        
        StartTick = tick()
        repeat
            task.wait()
        until SetText
        SetText("MainTextLabel", "Initalizing Script...")
        
        local FolderPath = "Rua_Hub/Blox_Fruit/Assets/"
        
        Storage = {
            WRITE_DELAY = 5,
            Data = {},
            Get = function(Self, Key)
                return Self.Data and Self.Data[Key]
            end,
            Set = function(Self, Key, Value)
                Self.Data = Self.Data or {}
                Self.Data[Key] = Value
            end,
            Save = function(Self)
                pcall(function()
                    local sp = ".storage_u_" .. tostring(game.Players.LocalPlayer)
                    writefile(sp, game:GetService("HttpService"):JSONEncode(Self.Data or {}))
                end)
            end
        }
        pcall(function()
            local sp = ".storage_u_" .. tostring(game.Players.LocalPlayer)
            if isfile(sp) then
                Storage.Data = game:GetService("HttpService"):JSONDecode(readfile(sp) or "{}") or {}
            end
        end)
        
        ScriptStorage = {
            IsInitalized = false,
            PlayerData = {},
            Melees = {},
            CurrentMeleeData = {},
            Enemies = {},
            Tools = {},
            Backpack = {},
            IgnoreStoreFruits = {},
            Connections = {
                LocalPlayer = {}
            },
            Task = {},
            Tracebacks = {},
            TaskController = {},
            TracebackUpdater = {},
            Interface = Interface,
            NPCs = {}
        }
        
        Players = game.Players
        LocalPlayer = Players.LocalPlayer
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        
        Humanoid = Character:WaitForChild("Humanoid", 15)
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 15)
        
        LocalPlayer.CharacterAdded:Connect(function(char)
            Character = char
            Humanoid = char:WaitForChild("Humanoid", 15)
            HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 15)
            -- MOV-02 fix: Reset tween state on respawn to prevent stuck
            pcall(function() if ActiveTween then ActiveTween:Cancel() end end)
            ActiveTween = nil
            TweenTargetPosition = nil
        end)
        
        PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
        Lighting = game:GetService("Lighting")
        
        Services = {}
        
        setmetatable(Services, {
            __index = function(_, Index)
                return game:GetService(Index)
            end
        });
        
        setmetatable(ScriptStorage.Enemies, {
            __index = function(_, Index)
                return Services.Workspace.Enemies:FindFirstChild(Index) or Services.ReplicatedStorage:FindFirstChild(Index)
            end
        })
        
        setmetatable(ScriptStorage.Tools, {
            __index = function(Self, Index)
                return LocalPlayer.Character:FindFirstChild(Index) or LocalPlayer.Backpack:FindFirstChild(Index)
            end
        })
        
        setmetatable(ScriptStorage.NPCs, {
            __index = function(_, Index)
                return workspace.NPCs:FindFirstChild(Index) or game.ReplicatedStorage.NPCs:FindFirstChild(Index)
            end
        })
        
        function CreateTraceback(Index, Value) -- i gave up 
        
            table.insert(ScriptStorage.Tracebacks,
                (GetCurrentDateTime() .. " ( " .. DispTime(os.time() - StartTime, true) .. " ) after execution | " .. Index ..
                    " | " .. Value))
        end
        
        function SetTask(Index, Value)
            if ScriptStorage.Task[Index] == Value then
                return
            end
            ScriptStorage.Task[Index] = Value
            ScriptStorage.Task[Index .. "-d"] = os.time()

            local Parser = {
                MainTask = "Task1",
                SubTask = "Task2",
                MiniTask = "Task3"
            }
            if Parser[Index] and SetText then
                SetText(Parser[Index], tostring(Value))
            end

            if UIController and UIController.Update then
                UIController:Update()
            end
        end
        
        Remotes = {}
        setmetatable(Remotes, {
            __index = function(_, Key)
                if Key ~= "CommF_" then
                     -- silenced print
                    return Services.ReplicatedStorage.Remotes[Key]
                end
                return {
                     InvokeServer = function(_, ...)
                        -- silenced print
                        return Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
                     end
                    }

                end

            })
        
        Tasks = {}
        
        function AwaitUntilPlayerLoaded(Player, Timeout)
            local start = os.time()
            local limit = Timeout or 15
            repeat
                task.wait(0.2)
            until Player.Character or (os.time() - start > limit)
        
            if Player.Character then
                Player.Character:WaitForChild("Humanoid", limit)
                repeat
                    task.wait(0.2)
                until not Player.Character or not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health > 0 or (os.time() - start > limit + 10)
            end
        end
        
        function AddPoint()
            local PointsValue = {}
            local Result
        
            for _, CInst in LocalPlayer.Data.Stats:GetChildren() do
                if CInst and CInst:FindFirstChild("Level") then
                    PointsValue[CInst.Name] = CInst.Level.Value
                end
            end
            if PointsValue.Defense < MaxLevel and
                (PointsValue.Defense < (ScriptStorage.PlayerData.Level / 80) or MaxLevel - PointsValue.Melee < 100) then
                Result = "Defense"
            elseif PointsValue.Melee < MaxLevel then
                Result = "Melee"
            else
                Result = "Sword"
            end
        
            Remotes.CommF_:InvokeServer("AddPoint", Result, 999)
        end
        
        local Colors = {
            Currencies = {
                Level = "#00FF40",
                Beli = "#FF7800",
                Fragments = "#6600FF"
            },
            Races = {}
        }
        function RefreshPlayerData()
            for _, ChildInstance in LocalPlayer.Data:GetChildren() do
                pcall(function()
                    ScriptStorage.PlayerData[ChildInstance.Name] = ChildInstance.Value
                end)
            end
        
            local Currencies = ""
            for Index, Value in ScriptStorage.PlayerData do
                local Color = Colors.Currencies[Index]
                if Color then
                    Currencies = Currencies .. '<font color="' .. Color .. '">' .. Index .. '</font>: ' .. Value .. ' '
                end
            end
        
            if UIController and UIController.Update then
                UIController:Update()
            end
            if ScriptStorage.Interface and SetText then
                SetText("Currencies", Currencies)
            end
        end
        
        function RefreshRace()
            local v27, v28 = Remotes.CommF_:InvokeServer("Alchemist", "1"), Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
            ScriptStorage.PlayerData.RaceLevel = 1
            if LocalPlayer.Character:FindFirstChild("RaceTransformed") then
                ScriptStorage.PlayerData.RaceLevel = 4
            elseif v28 == -2 then
                ScriptStorage.PlayerData.RaceLevel = 3
            elseif v27 == -2 then
                ScriptStorage.PlayerData.RaceLevel = 2
            end
        end
        
        function RefreshInventory()
            local ItemReplicationService = require(game:GetService("ReplicatedStorage").ItemReplicationService)
            local ItemConfig = require(game:GetService("ReplicatedStorage").ItemConfig)
            local KEYS = require(game:GetService("ReplicatedStorage").ItemReplicationService.KEYS)
        
            while ItemReplicationService.IsInitialized ~= true do task.wait() end
        
            local masteryMap = {}
            for _, item in pairs(ItemReplicationService:GetItems(KEYS.MASTERY)) do
                masteryMap[item.ItemId] = item.Value
            end
        
            ScriptStorage.Backpack2 = {}
        
            for _, item in pairs(ItemReplicationService:GetItems(KEYS.QUANTITY)) do
                local ok, data = pcall(function()
                    return ItemConfig.match(item.ItemId):unwrap()
                end)
                if ok and data and data.Index then
                    local idType = data.Index.IdType
                    local name = data.Index.StorageKey
                    ScriptStorage.Backpack2[name] = {
                        Name                = name,
                        Type                = idType == "PhysicalMoveset" and "Blox Fruit" or idType == "Moveset" and "Sword" or idType,
                        Count               = item.Value,
                        Value               = data.Quality and data.Quality.MoneyPrice or 0,
                        Mastery             = masteryMap[item.ItemId] or 0,
                        MasteryRequirements = data.Moveset and data.Moveset.MasteryRequirements or {},
                    }
                end
            end
        
            ScriptStorage.Backpack = ScriptStorage.Backpack2

            for _, item in pairs(ItemReplicationService:GetItems(KEYS.MASTERY)) do
                local ok, data = pcall(function() return ItemConfig.match(item.ItemId):unwrap() end)
                if ok and data and data.Index and data.Index.StorageKey then
                    local sKey = data.Index.StorageKey
                    for _, mName in ipairs(MeleesTable or {}) do
                        if sKey == mName or sKey:gsub("%s+", "") == mName:gsub("%s+", "") then
                            ScriptStorage.Melees[mName] = item.Value
                        end
                    end
                end
            end
            RefreshMelees()
        end
        
        function ResearchMoves(Child)
            if Child and tostring(Child) == "V" then
                if ScriptStorage.Connections.BurstCheck then
        
                    ScriptStorage.Connections.BurstCheck:Disconnect()
                    task.wait(1)
                end
                -- silenced print
                ScriptStorage.Connections.BurstCheck = Child.Cooldown:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        if EnablingBurstDebounce and os.time() - EnablingBurstDebounce < 10 then
                            return
                        end
                        local Value = Child.Cooldown.AbsoluteSize.X
                        if Value < 3 then
                            EnablingBurstDebounce = os.time()
        
                            task.wait(5)
                            SendKey("V", 0)
                        end
                    end)
            end
        end
        
        function CheckMeleeBurstMove(Child)
            if Child.Name == "Black Leg" or Child.Name == "Death Step" then
                local UI = PlayerGui.Main.Skills:WaitForChild(Child.Name, 9)
        
                ResearchMoves(UI:WaitForChild("V"))
        
            end
        end
        
        function RefreshMelees(ReturnOrSet)
            local Result = ""
        
            for MeleeName, Level in ScriptStorage.Melees do
                Result = Result .. MeleeName .. ": " .. Level .. " "
            end
            Result = Result == "" and "[0]" or Result
            if ReturnOrSet then
                return Result
            end
        
            if UIController and UIController.Update then
                UIController:Update()
            end
            if ScriptStorage.Interface and SetText then
                SetText("Melees", Result)
            end
        end
        function MeleeCheck(Child)
    -- silenced print

    if Child and typeof(Child) == "Instance" and Child:IsA("Tool") then
        if Child.ToolTip == "Melee" then
            if ScriptStorage.Connections.Melees then
                ScriptStorage.Connections.Melees:Disconnect()
            end

            ScriptStorage.CurrentMeleeData.Name = Child.Name
            pcall(function()
                ScriptStorage.Connections.Melees:Destroy()
            end)

            ScriptStorage.Connections.Melees = Child.Level.Changed:Connect(function(Value)
                ScriptStorage.Melees[Child.Name] = Value
                RefreshMelees()
            end)
            ScriptStorage.Melees[Child.Name] = Child.Level.Value
            RefreshMelees()

        elseif Child:GetAttribute("OriginalName") then
            task.spawn(function()
                local orig = Child:GetAttribute("OriginalName")
                local cname = Child.Name
                for _, ign in ipairs(ScriptStorage.IgnoreStoreFruits or {}) do
                    if ign == orig or ign == cname or string.find(tostring(orig), tostring(ign)) or string.find(tostring(cname), tostring(ign)) then
                        return
                    end
                end
                Remotes.CommF_:InvokeServer("StoreFruit", Child:GetAttribute("OriginalName"), Child)
            end)
        end
    end
end
        SetText("MainTextLabel", "Refreshing Player Data")
        
        MeleeCheck(LocalPlayer.Character:FindFirstChildOfClass("Tool"))
        
        RefreshPlayerData()
        
        function RegisterLocalPlayerEventsConnection()
        
            task.spawn(function()
                task.wait(6)
                if LocalPlayer.Character:FindFirstChild("HasBuso") then
                    return
                end
                Remotes.CommF_:InvokeServer("Buso")
            end)
        
            for _, Connection in ScriptStorage.Connections.LocalPlayer do
                pcall(function()
                    Connection:Disconnect()
                end)
            end
        
            AwaitUntilPlayerLoaded(LocalPlayer)
        
            LocalPlayer:SetAttribute("IsAvailable", true)
        
            ScriptStorage.Connections.LocalPlayer["HealthCheck"] = LocalPlayer.Character:WaitForChild("Humanoid")
                :GetPropertyChangedSignal("Health"):Connect(function()
        
                    local Health = LocalPlayer.Character.Humanoid.Health
        
                    LocalPlayer:SetAttribute("IsAvailable", Health > 10)
                    ScriptStorage.LocalPlayerHealth = Health
                end)
        
            ScriptStorage.Connections.LocalPlayer["Melee"] = LocalPlayer.Character.ChildAdded:Connect(MeleeCheck)
            ScriptStorage.Connections.LocalPlayer["Fruit"] = LocalPlayer.Backpack.ChildAdded:Connect(MeleeCheck)
        
            table.foreach(LocalPlayer.Backpack:GetChildren(), function(_, Melee)
                MeleeCheck(Melee)
            end)
        
            LastIdleCheck = os.time()
            ScriptStorage.Connections.LocalPlayer.PositionChecker =
                LocalPlayer.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
                    if os.time() == LastIdleCheck then return end 
                    LastIdleCheck = os.time()
                    if oldPos then 
                        if (LocalPlayer.Character.HumanoidRootPart.CFrame.p - oldPos).magnitude < 2 then 
                            return end 
                    end 
                    oldPos = (LocalPlayer.Character.HumanoidRootPart.CFrame.p) 
                    LastIdling = os.time()
                    
                end)
        
            local PointsInstance = LocalPlayer.Data:WaitForChild("Points")
            ScriptStorage.Connections.LocalPlayer.PointConnection = PointsInstance:GetPropertyChangedSignal("Value"):Connect(
                function()
        
                    local CurrentValue = LocalPlayer.Data:WaitForChild("Points")
                    if OldPointValue == CurrentValue then
                        return
                    end
        
                    OldPointValue = CurrentValue
        
                    AddPoint()
                end)
        end
        
        RegisterLocalPlayerEventsConnection(LocalPlayer)
        
        game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
        
            -- silenced print
            RegisterLocalPlayerEventsConnection(LocalPlayer)
        
        end)
        
        task.spawn(function()
            task.wait(3)
            if LocalPlayer.Character:FindFirstChild("HasBuso") then
                return
            end
            Remotes.CommF_:InvokeServer("Buso")
        end)
        
    -- silenced print
    MeleesTable = {
        "Black Leg",
        "Electro",
        "Fishman Karate",
        "Dragon Claw",
        "Superhuman",
        "Death Step",
        "Electric Claw",
        "Sharkman Karate",
        "Dragon Talon",
        "Godhuman",
        "SanguineArt"
    }

    MeleesId =  {
        "BlackLeg",
        "Electro",
        "FishmanKarate",
        "DragonClaw",
        "Superhuman",
        "DeathStep",
        "ElectricClaw",
        "SharkmanKarate",
        "DragonTalon",
        "Godhuman",
        "SanguineArt"
    } 


    MeleePrices = {
        ["Black Leg"] = {
            Price =
            {
                Beli = 150000,
            }, 
            Id = 'BlackLeg', 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true 
            end,
            Buy = function(Check) 
                return BuyMelee("BlackLeg", Check)
            end 
        }, 
        ["Electro"] = {
            Price = 
            {
                Beli = 500000
            },
            Id = 'Electro', 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true 
            end, 
            Buy = function(Check) 
                return BuyMelee("Electro", Check)
            end 
        }, 
        ["Fishman Karate"] = {
            Price = { 
                Beli = 750000 
            }, 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true 
            end, 
            Buy = function(Check) 
                return BuyMelee("FishmanKarate", Check)
            end 
        }, 
        ["Dragon Claw"] = {
            Price = { 
                Fragments = 1500 
            }, 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true 
            end, 
            Buy = function(Check) 
                if Check then 
                    return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1") == 1 
                end 
                return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
            end 
        }, 
        ["Superhuman"] = 
        {
            Price = 
            {
                Beli = 3000000
            }, 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true 
            end,
            Buy = function(Check) 
                return BuyMelee("Superhuman", Check)
            end 
        },
        ["Death Step"] = 
        {
            Price = 
            {
                Beli = 2500000, 
                Fragments = 5000
            }, 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true
            end, 
            Buy = function(Check) 
                return BuyMelee("DeathStep", Check)
            end 
        },
        ["Electric Claw"] = 
        {
            Price = 
            {
                Beli = 2500000, 
                Fragments = 5000
            }, 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true
            end, 
            Buy = function(Check) 
                return BuyMelee("ElectricClaw", Check)
            end 
        },
        ["Sharkman Karate"] = 
        {
            Price = 
            {
                Beli = 2500000, 
                Fragments = 5000
            }, 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true
            end, 
            Buy = function(Check) 
                return BuyMelee("SharkmanKarate", Check)
            end 
        }, 
        ["Dragon Talon"] = 
        {
            Price = 
            {
                Beli = 2500000, 
                Fragments = 5000
            }, 
            NextLevelRequirement = 400, 
            Requirements = function() 
                return true
            end, 
            Buy = function(Check) 
                return BuyMelee("DragonTalon", Check)
            end 
        }, 

        ["Godhuman"] = 
        {
            Price = 
            {
                Beli = 5000000, 
                Fragments = 5000
            }, 
            NextLevelRequirement = 350, 
            Requirements = function() 
                return true
            end, 
            Buy = function(Check) 
                return BuyMelee("Godhuman", Check)
            end 
        }
    }



    DropItemData = {
        ["Buddy Sword"] = {
            Sea = 3, 
            Level = 1500, 
            Boss = "Cake Queen"
        }, 
        ["Canvander"] = {
            Sea = 3, 
            Level = 1500, 
            Boss = "Beautiful Pirate"
        }, 
        ["Twin Hooks"] = {
            Sea = 3, 
            Level = 1500, 
            Boss = "Captain Elephant"
        }, 
        ["Venom Bow"] = {
            Sea = 3, 
            Level = 1500, 
            Boss = "Hydra Leader"
        }
    }
            
    GodhumanMaterials = {
        ["Fish Tail"] = {
            20,
            3,
            {
                "Fishman Raider",
                "Fishman Captain"
            }, 
            {
                "DeepForestIsland3", 
                1, 
                1775, 
                "Turtle Adventure Quest Giver"
            }
        },
        ["Dragon Scale"] = {
            10,
            3,
            {
                "Dragon Crew Warrior",
                "Dragon Crew Archer"
            }, 
            {
                "DragonCrewQuest", 
                1, 
                1575,
                "Dragon Crew Quest Giver"
            }
        },
        ["Magma Ore"] = {
            20,
            2,
            {
                "Magma Ninja"
            }, 
            {
                "FireSideQuest", 
                1, 
                1100, 
                "Fire Quest Giver"
            }
        },
        ["Mystic Droplet"] = {
            10,
            2,
            {
                "Sea Soldier",
                "Water Fighter"
            }, 
            {
                "ForgottenQuest", 
                2, 
                1425, 
                "Forgotten Quest Giver"
            }
        }
    }

    SeaIndexes = {"Main", "Dressrosa", "Zou"}

    TasksOrder = 
    {
        "SpecialBossesTask",
        "RaidController",
        "PirateRaid",
        "ThirdSeaPuzzle",
        "SecondSeaPuzzle",
        "ColosseumPuzzle", 
        "Trevor",
        "Wenlocktoad",
        "EvoRace",
        "Saber",
        "SoulGuitar",
        "Tushita",
        "Yama",
        "CursedDualKatana",
        "UtillyItemsActivitation",
        "BossesTask", 
        "MeleesController",
        "ExpRedeem",
        "LevelFarm"
    }

    MaxLevel = 2800

    placeId = game.PlaceId
    if placeId == 2753915549 or placeId == 85211729168715 then
        Sea = "Main"
        SeaIndex = 1
    elseif placeId == 4442272183 or placeId == 79091703265657 then
        Sea = "Dressrosa"
        SeaIndex = 2    
    elseif placeId == 7449423635 or placeId == 100117331123089 then
        Sea = "Zou"
        SeaIndex = 3
    end


    Portals = ({
        {
            Vector3.new(-7894.6201171875, 5545.49169921875, -380.246346191406),
            Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625),
            Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
            Vector3.new(3876.280517578125, 35.10614013671875, -1939.3201904296875)
        },
        {
            Vector3.new(-288.46246337890625, 306.130615234375, 597.9988403320312),
            Vector3.new(2284.912109375, 15.152046203613281, 905.48291015625),
            Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
            Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)
        },
        {
            Vector3.new(-5097.93164, 316.447021, -3142.66602),
            Vector3.new(5748.7587890625, 610.44982910156, -267.81704711914),
            Vector3.new(-5072.08984375, 314.5412902832, -3151.1098632812),
            Vector3.new(-9515.3720703125, 142.13061523438, 5535.0971679688),
            Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375),
            Vector3.new(28310.0234, 14895.1123, 109.456741)
        }
    })[SeaIndex]

    BossesOrder = {
        "Awakened Ice Admiral",
        "Tide Keeper",
        "Deandre",
        "Urban",
        "Diablo",
        "Soul Reaper",
        "Cake Prince"
    }
    BossesOrderLevel = {
        ["Awakened Ice Admiral"] = 700, 
        ["Tide Keeper"] = 700, 
        ["Deandre"] = 1500,
        ["Urban"] = 1500,
        ["Diablo"] = 1500,
        ["Cake Prince"] = 1500, 
        ["Soul Reaper"] = 1500
    }

    BossesOrderWL = {
        ["Deandre"] = 1500,
        ["Urban"] = 1500,
        ["Diablo"] = 1500,
        ["Cake Prince"] = 1500, 
        ["Don Swan"] = 1100,
        ["Awakened Ice Admiral"] = 700, 
        ["Tide Keeper"] = 700, 
    }


    SpecialBossesOrder = {
        ["Core"] = 700, 
        ["Darkbeard"] = 700, 
        ["rip_indra True Form"] = 1500, 
        ["Dough King"] = 1500, 
    }

    BlankTablets = {
        "Segment6",
        "Segment2",
        "Segment8",
        "Segment9",
        "Segment5"
    }

    Trophy = {
        ["Segment1"] = "Trophy1",
        ["Segment3"] = "Trophy2",
        ["Segment4"] = "Trophy3",
        ["Segment7"] = "Trophy4",
        ["Segment10"] = "Trophy5"
    }

    Pipes = {
        ["Part1"] = "Really black",
        ["Part2"] = "Really black",
        ["Part3"] = "Dusty Rose",
        ["Part4"] = "Storm blue",
        ["Part5"] = "Really black",
        ["Part6"] = "Parsley green",
        ["Part7"] = "Really black",
        ["Part8"] = "Dusty Rose",
        ["Part9"] = "Really black",
        ["Part10"] = "Storm blue"
    }



    function GenerateUUID()
        local Template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
        return string.gsub(Template, "[xy]", function(Idc)
            local V = (Idc == "x") and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format("%x", V)
        end)
    end

    function CheckIsPlayerAlive(Instance) 
        Instance = Instance or LocalPlayer 
        
        return Instance and Instance.Character and Instance.Character.Humanoid and Instance.Character.HumanoidRootPart and Instance.Character.Head and Instance.Character.Humanoid.Health > 0  -- nuh uh
    end 

    local function toVec3(val)
        if not val then return nil end
        if typeof(val) == "Vector3" then return val end
        if typeof(val) == "CFrame" then return val.Position end
        if typeof(val) == "Instance" then
            if val:IsA("BasePart") then return val.Position end
            if val:IsA("Model") then
                local prim = val.PrimaryPart or val:FindFirstChild("HumanoidRootPart") or val:FindFirstChildWhichIsA("BasePart")
                if prim then return prim.Position end
                local ok, cf = pcall(function() return val:GetPivot() end)
                if ok and cf then return cf.Position end
            end
        end
        if type(val) == "table" and val.X and val.Y and val.Z then
            return Vector3.new(tonumber(val.X) or 0, tonumber(val.Y) or 0, tonumber(val.Z) or 0)
        end
        return nil
    end

    function CaculateDistance(Origin, Destination)
        local oVec = toVec3(Origin)
        if not oVec then return 999999 end

        local dVec = toVec3(Destination)
        if not dVec then
            local lp = game:GetService("Players").LocalPlayer
            local hrp = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                dVec = hrp.Position
            else
                return 999999
            end
        end

        return (oVec - dVec).Magnitude
    end

    function CalculateDistance(Origin, Destination)
        return CaculateDistance(Origin, Destination)
    end  

    function DispTime(time, cc)
        time = math.max(0, math.floor(tonumber(time) or 0))
        local days = math.floor(time / 86400)
        local hours = math.floor((time % 86400) / 3600)
        local minutes = math.floor((time % 3600) / 60)
        local seconds = math.floor(time % 60)
        if cc then
            if days > 0 then
                return (days .. "d, " .. hours .. "h, " .. minutes .. "m, " .. seconds .. "s")
            else
                return (hours .. "h, " .. minutes .. "m, " .. seconds .. "s")
            end
        end
        return (days .. "day, " .. hours .. "hrs.")
    end

    function GetCurrentDateTime()
    local now = os.date("*t")  -- Get the current time as a table

    local hour = now.hour
    local minute = now.min
    local day = now.day
    local month = now.month
    local year = now.year
    local weekday = now.wday -- Day of the week (1 = Sunday, 7 = Saturday)

    local formattedTime = string.format("%02d:%02d ", hour, minute) -- Format time HH:MM

    local weekdays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    local formattedWeekday = weekdays[weekday]

    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    local formattedMonth = months[month]

    local formattedDate = string.format("%s, %s %d %d", formattedWeekday, formattedMonth, day, year)

    return formattedTime.. formattedDate -- Combine time and date
    end

    function RandomArguments(...) 
        local Table = {...} 
        if #Table == 0 then return nil end
        return Table[math.random(1, #Table)]
    end 

        
    function RoundVector3Down(vec)
        return Vector3.new(
            math.floor(vec.X / 10) * 10,
            math.floor(vec.Y / 10) * 10,
            math.floor(vec.Z / 10) * 10
        )
    end

    local Angle, lastChange = 30, tick()
    CaculateCircreDirection = function(Position)
        if Angle > 50000 then Angle = 60 end
        Angle = Angle + ((tick() - lastChange) > .4 and 80 or 0) 

        
         if tick() - lastChange > 0.4 then
            Angle = Angle + 80
            lastChange = tick()
        end
        
        local sum = Position + Vector3.new(math.cos(math.rad(Angle)) * 40, 0, math.sin(math.rad(Angle)) * 40)
        return CFrame.new(RoundVector3Down(sum))
    end

    function GetMonAsSortedRange() 
        local Result = {}
        
        table.foreach(Services.Workspace.Enemies:GetChildren(), function(_, Mon) 
            if Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 then 
                table.insert(Result, Mon)
            end 
        end)
        
        table.foreach(game.ReplicatedStorage:GetChildren(), function(_, Mon) 
            if Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 then 
                table.insert(Result, Mon)
            end
        end)
        
        table.sort(Result, function(C1, C2) return CaculateDistance(C1.HumanoidRootPart.CFrame) < CaculateDistance(C2.HumanoidRootPart.CFrame) end) 
        
        
        return Result
    end 
    -- silenced print
    function GetMeleeIdByName(MeleeName) 
        for Index, Melee in MeleesTable do 
            if Melee == MeleeName then 
                return MeleesId[Index] 
            end 
        end 
    end 

    function BuyMelee(M1, Check) 
        if Check then 
            
            local Response_ =  Remotes.CommF_:InvokeServer("Buy" .. M1, true) 
            -- silenced print)
            
            return Response_ == 1 
        end 
        return Remotes.CommF_:InvokeServer("Buy" .. M1) 
    end 

    function SendKey(key, hold)
        (
            function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
                task.wait(hold)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
            end
        )()
    end

    function FruitIdToName(FruitId)
        local ParserResult = string.match(FruitId or "", "(((%u)%-?)([^-.]+))$")
        return ParserResult and (ParserResult .. " Fruit") or "Unknown Fruit"
    end 

    function Split(inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t = {}
        for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
            table.insert(t, str)
        end
        return t
    end

    function FruitNameToId(FruitName) 
        local Id = Split(FruitName)[1]
        return Id .. "-" .. Id
    end 

    local okQ, loadedQuests = pcall(function() return require(game.ReplicatedStorage:WaitForChild("Quests", 5)) end)
    local QuestManager = {
        CurrentLevel = 2, 
        DoubleQuest = true, 
        Quests = (okQ and type(loadedQuests) == "table" and loadedQuests) or {},
        CurrentQuests = {},
        BlacklistedQuestIds = {
            BartiloQuest = 1, 
            CitizenQuest = 1, 
            Trainees = 1, 
            MarineQuest = 1, 
            ImpelQuest = 1
        }
    } 

    local okNpcList, guideData = pcall(function() return require(game.ReplicatedStorage.GuideModule).Data.NPCList end)
    local NpcList = (okNpcList and guideData) or {}

    local QuestNpcMap = {
        -- Sea 1
        ["BanditQuest1"] = "Bandit Quest Giver",
        ["JungleQuest"] = "Adventurer",
        ["BuggyQuest1"] = "Pirate Adventurer",
        ["DesertQuest"] = "Desert Adventurer",
        ["SnowQuest"] = "Snow Adventurer",
        ["MarineQuest2"] = "Marine Quest Giver",
        ["SkyQuest"] = "Sky Adventurer",
        ["SkyQuest2"] = "Master Sky Adventurer",
        ["PrisonerQuest"] = "Jailer",
        ["ColosseumQuest"] = "Colosseum Quest Giver",
        ["MagmaQuest"] = "Magma Quest Giver",
        ["FishmanQuest"] = "Fishman Quest Giver",
        ["FountainQuest"] = "Fountain Quest Giver",
        
        -- Sea 2
        ["Area1Quest"] = "Quest Giver",
        ["Area2Quest"] = "Quest Giver",
        ["MarineQuest"] = "Marine Quest Giver",
        ["SnowMountainQuest"] = "Snow Adventurer",
        ["IceSideQuest"] = "Ice Side Quest Giver",
        ["FireSideQuest"] = "Fire Side Quest Giver",
        ["ShipQuest1"] = "Ship Quest Giver 1",
        ["ShipQuest2"] = "Ship Quest Giver 2",
        ["FrostQuest"] = "Frost Quest Giver",
        ["ForgottenQuest"] = "Forgotten Quest Giver",

        -- Sea 3
        ["PiratePortQuest"] = "Pirate Port Quest Giver",
        ["MarineTreeIsland"] = "Marine Tree Quest Giver",
        ["DeepForestIsland"] = "Deep Forest Quest Giver",
        ["DeepForestIsland2"] = "Deep Forest Quest Giver",
        ["DeepForestIsland3"] = "Deep Forest Quest Giver",
        ["HydraTownQuest"] = "Hydra Town Quest Giver",
        ["TurtleAdventureQuest"] = "Turtle Adventure Quest Giver",
        ["HauntedQuest1"] = "Haunted Castle Quest Giver 1",
        ["HauntedQuest2"] = "Haunted Castle Quest Giver 2",
        ["IceCreamIslandQuest"] = "Ice Cream Quest Giver",
        ["PeanutQuest"] = "Peanut Quest Giver",
        ["CakeQuest1"] = "Cake Quest Giver 1",
        ["CakeQuest2"] = "Cake Quest Giver 2",
        ["CandyCaneQuest"] = "Candy Cane Quest Giver",
        ["ChocolateQuest1"] = "Chocolate Quest Giver 1",
        ["ChocolateQuest2"] = "Chocolate Quest Giver 2",
        ["TikiQuest1"] = "Tiki Quest Giver 1",
        ["TikiQuest2"] = "Tiki Quest Giver 2",
        ["TikiQuest3"] = "Tiki Quest Giver 3",
        ["SubmergedQuest1"] = "Submerged Quest Giver 1",
        ["SubmergedQuest2"] = "Submerged Quest Giver 2",
        ["SubmergedQuest3"] = "Submerged Quest Giver 3",
        ["DragonCrewQuest"] = "Dragon Crew Quest Giver"
    }

    local StaticQuestNpcPositions = {
        ["TikiQuest1"] = CFrame.new(-15915, 41, 1421),
        ["TikiQuest2"] = CFrame.new(-16450, 48, 590),
        ["TikiQuest3"] = CFrame.new(-16668.03, 105.32, 1568.60),
        ["SubmergedQuest1"] = CFrame.new(10778.875, -2087.72437, 9265.18359),
        ["SubmergedQuest2"] = CFrame.new(10880.6855, -2086.20044, 10032.624),
        ["SubmergedQuest3"] = CFrame.new(9640.08789, -1992.44507, 9613.65234),
    }

    local function ResolveNpcCFrame(questId, levelReq)
        if not questId then return nil end

        -- 1. Static known coordinates (Submerged Island & Tiki Outpost)
        if StaticQuestNpcPositions[questId] then
            return StaticQuestNpcPositions[questId]
        end

        -- 2. Check exact map
        local mappedName = QuestNpcMap[questId]
        if mappedName then
            local npc = (workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild(mappedName)) 
                or (game.ReplicatedStorage:FindFirstChild("NPCs") and game.ReplicatedStorage.NPCs:FindFirstChild(mappedName))
            if npc then
                local ok, cf = pcall(function() return npc:GetModelCFrame() end)
                if ok and cf then return cf end
                if npc.PrimaryPart then return npc.PrimaryPart.CFrame end
            end
        end

        -- 3. Check workspace.NPCs fuzzy search
        if workspace:FindFirstChild("NPCs") then
            local cleanQ = questId:lower():gsub("quest", ""):gsub("island", ""):gsub("%d+", "")
            for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                local cleanN = npc.Name:lower():gsub("%s+", "")
                if cleanN:find(cleanQ) or (cleanQ ~= "" and cleanQ:find(cleanN:gsub("questgiver", ""))) then
                    local ok, cf = pcall(function() return npc:GetModelCFrame() end)
                    if ok and cf then return cf end
                end
            end
        end

        -- 4. Check GuideModule.Data.NPCList
        local okGuide, guide = pcall(function() return require(game.ReplicatedStorage.GuideModule) end)
        if okGuide and guide and guide.Data and guide.Data.NPCList then
            for i, v in pairs(guide.Data.NPCList) do
                if v and v.Levels then
                    for _, lvl in ipairs(v.Levels) do
                        if lvl == levelReq then
                            if typeof(i) == "Instance" and i:IsA("BasePart") then
                                return i.CFrame
                            elseif typeof(i) == "CFrame" then
                                return i
                            end
                        end
                    end
                end
            end
        end

        return nil
    end

    function QuestManager.RefreshQuest(Self) 
        local pLevel = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or (LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") and LocalPlayer.Data.Level.Value) or 1
        
        local QuestLevelFlag = 0  
        local CurrentQuestData = nil
        local bestQuestId = nil
        
        local questsTable = QuestManager.Quests or (pcall(function() return require(game.ReplicatedStorage.Quests) end) and require(game.ReplicatedStorage.Quests)) or {}
        for QuestID, QuestDatas in pairs(questsTable) do 
            if not QuestManager.BlacklistedQuestIds[QuestID] and type(QuestDatas) == "table" and QuestDatas[1] then
                local req = QuestDatas[1].LevelReq or 0
                if req >= QuestLevelFlag and req <= pLevel then
                    QuestLevelFlag = req  
                    CurrentQuestData = QuestDatas
                    bestQuestId = QuestID
                    if pLevel >= 1500 and SeaIndex == 2 and QuestID == "ForgottenQuest" then 
                        break 
                    end 
                end
            end
        end
        
        if not CurrentQuestData then return end
        Self.CurrentQuestId = bestQuestId
        
        local cloneData = {}
        for idx, item in ipairs(CurrentQuestData) do
            table.insert(cloneData, item)
        end
        
        local LastQuest = cloneData[#cloneData] 
        if LastQuest and LastQuest.Task then
            for _, Count in pairs(LastQuest.Task) do 
                if Count == 1 and #cloneData > 1 then 
                    table.remove(cloneData, #cloneData)
                end 
            end 
        end
        
        local targetLevelReq = cloneData[#cloneData] and cloneData[#cloneData].LevelReq or QuestLevelFlag
        Self.CurrentNpc = ResolveNpcCFrame(bestQuestId, targetLevelReq)
        Self.CurrentQuests = cloneData 
    end

    function QuestManager.GetCurrentQuest(Self) 
        if not Self.CurrentQuests or #Self.CurrentQuests == 0 then
            Self:RefreshQuest()
        end
        if not Self.CurrentQuests or #Self.CurrentQuests == 0 then
            return nil, nil, nil, nil, nil
        end
        
        local pLevel = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 1
        local QuestIndex = Self.CurrentQuests[Self.CurrentLevel] and Self.CurrentQuests[Self.CurrentLevel].LevelReq <= pLevel and Self.CurrentLevel or 1 
        
        local qData = Self.CurrentQuests[QuestIndex]
        if qData and qData.Task then
            for Name in pairs(qData.Task) do 
                return Name, Self.CurrentNpc, Self.CurrentQuestId, QuestIndex, qData.Name
            end 
        end
        return nil, Self.CurrentNpc, Self.CurrentQuestId, QuestIndex, "Unknown"
    end 

    function QuestManager.MarkAsCompleted(Self)
        Self.CurrentLevel = Self.CurrentLevel == 2 and 1 or 2
    end  

    function QuestManager.AbandonQuest() 
        pcall(function()
            Remotes.CommF_:InvokeServer("AbandonQuest")
        end)
    end 

    function QuestManager.GetCurrentClaimQuest(RawResponse) 
        local main = game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main")
        local questFrame = main and main:FindFirstChild("Quest")
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            local titleObj = container and container:FindFirstChild("QuestTitle") and container.QuestTitle:FindFirstChild("Title")
            if not titleObj then
                for _, lbl in ipairs(questFrame:GetDescendants()) do
                    if lbl:IsA("TextLabel") and (lbl.Text:lower():find("defeat") or lbl.Text:find("%(%d+/%d+%)")) then
                        titleObj = lbl
                        break
                    end
                end
            end
            if titleObj and titleObj.Text and #titleObj.Text > 0 then
                local rawText = titleObj.Text
                local parsed = rawText:gsub("[Dd][Ee][Ff][Ee][Aa][Tt]%s*(%d*)%s*", ""):gsub("%s*%b()", ""):gsub("^%s+", ""):gsub("%s+$", "")
                parsed = string.gsub(parsed, "Military ", "Mil. ")
                if RawResponse then
                    return rawText, parsed
                end
                return parsed, rawText
            end
        end
        return nil, nil
    end 

    function QuestManager.StartQuest(QuestId, QuestLevel) 
        return Remotes.CommF_:InvokeServer("StartQuest", QuestId, QuestLevel) 
    end

    ScriptStorage.MobRegions = {
        -- Submerged Island & Tiki Outpost Mobs
        ["Reef Bandit"] = { Vector3.new(11019.13, -2146.07, 9342.39) },
        ["Coral Pirate"] = { Vector3.new(10808.60, -2030.36, 9364.23) },
        ["Sea Chanter"] = { Vector3.new(10671.27, -2057.59, 10047.26) },
        ["Ocean Prophet"] = { Vector3.new(11008.52, -2007.73, 10223.08) },
        ["High Disciple"] = { Vector3.new(9750.42, -1966.94, 9753.36) },
        ["Grand Devotee"] = { Vector3.new(9611.71, -1993.47, 9882.69) },
        ["Tyrant of the Skies"] = { Vector3.new(-16709.49, 419.68, 1751.09) },
        ["Skull Slayer"] = { Vector3.new(-16709.49, 419.68, 1751.09) },
        ["Isle Champion"] = { Vector3.new(-16450, 48, 590) },
        ["Sun-kissed Warrior"] = { Vector3.new(-15915, 41, 1421) },
        ["Isle Outlaw"] = { Vector3.new(-15915, 41, 1421) }
    } 
    local okMobs, RawMobRegions = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ninhcac/luaskid/refs/heads/main/map.lua")
    end)

    if okMobs and type(RawMobRegions) == "string" and #RawMobRegions > 10 then 
        local okDecode, decoded = pcall(function() return Services.HttpService:JSONDecode(RawMobRegions) end)
        if okDecode and type(decoded) == "table" then
            for Name, Positions in pairs(decoded) do 
                ScriptStorage.MobRegions[Name] = ScriptStorage.MobRegions[Name] or {} 
                for _, Position in ipairs(Positions) do 
                    table.insert(ScriptStorage.MobRegions[Name], Vector3.new(Position[1], Position[2], Position[3])) 
                end 
            end
        end
    end 

    TweenController = {} 


    local LastestTeleportToHomePoint = 0
    local Entries = {} 

    for _, NPC in game.ReplicatedStorage.NPCs:GetChildren() do 
        if NPC.Name == "Set Home Point" then 
            table.insert(Entries, NPC:GetModelCFrame())
        end 
    end 

    function TweenController.Update() 

        
        local Part = game.Players.LocalPlayer.Character.HumanoidRootPart
        
        
        HumanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart") 
        
        if CaculateDistance(Part.CFrame) > 250 then
            pcall(function() 
                TweenInstance:Cancel()
            end) 
            TweenDebounce = true
            
            Part.CFrame = HumanoidRootPart.CFrame
            
            
            TweenDebounce = false
        end
        
        HumanoidRootPart.CFrame = Part.CFrame+Vector3.new(0,3,0)
    end



    function GetPortal(Position) 
        if not Portals or #Portals == 0 then return end
        local targetPos = typeof(Position) == "CFrame" and Position.Position or Position
        local playerPos = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        if not playerPos then return end

        local curDist = (playerPos - targetPos).Magnitude
        local Nearest, Current = 9e9, nil
        for _, Portal in ipairs(Portals) do
            local pPos = typeof(Portal) == "CFrame" and Portal.Position or Portal
            local distPortalToTarget = (pPos - targetPos).Magnitude
            if distPortalToTarget < (curDist - 400) and distPortalToTarget < Nearest then 
                Nearest = distPortalToTarget 
                Current = Portal
            end 
        end 
        
        if Current then 
            pcall(function()
                Remotes.CommF_:InvokeServer("requestEntrance", Current)
            end)
            return task.wait(0.2)
        end 
    end 

    function GetEntries(Position) 
        local Nearest, Current = 9e9, nil
        for _, Entry in Entries do
            local Dist1 = CaculateDistance(Entry, Position)
            if Dist1 < ( CaculateDistance(Position) - 700 ) and Dist1 < Nearest then 
                Nearest = Dist1 
                Current = Entry
                
            end 
        end 
        
        if Current then 
            if os.time() - LastestTeleportToHomePoint > 30 then 
                for i=1,10,1 do 
                    task.wait() 
                    
                end 
            end 
        end 
    end 

    function TweenController.Tween2(ePart, Position) 
        local speed = (Config and (Config.TweenSpeed or (Config.Configuration and Config.Configuration.TweenSpeed))) or 270
        TweenInstance2 = Services.TweenService:Create(
                ePart,
                TweenInfo.new(CaculateDistance(ePart.CFrame, Position) / speed, Enum.EasingStyle.Linear),
                {CFrame = ConvertTo(CFrame, Position)-Vector3.new(0,0,0)}
            )
        TweenInstance2:Play()
    end

    TweenTargetPosition = nil
    local ActiveTween = nil
    local NoclipConn = nil

    local function EnableNoclip()
        if NoclipConn then return end
        NoclipConn = game:GetService("RunService").Stepped:Connect(function()
            pcall(function()
                if not ActiveTween then return end
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Velocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                    end
                end
            end)
        end)
    end

    function TweenController.Create(Position)
        if not Position or TweenDebounce then return end 
        local targetCF = typeof(Position) ~= "CFrame" and ConvertTo(CFrame, Position) or Position
        local targetPos = targetCF.Position

        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local dist = (hrp.Position - targetPos).Magnitude

        -- Combat hover / close range (< 45 studs): Set CFrame directly for instant zero-stutter response
        if dist < 45 then
            if ActiveTween then
                pcall(function() ActiveTween:Cancel() end)
                ActiveTween = nil
                TweenTargetPosition = nil
            end
            hrp.CFrame = targetCF
            return
        end

        -- Active tween already heading towards this destination: let it keep gliding smoothly!
        if ActiveTween and TweenTargetPosition and (targetPos - TweenTargetPosition).Magnitude < 40 then
            return
        end

        -- Portal gate check for long distances (> 600 studs)
        if dist > 600 then 
            GetPortal(targetCF)
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            dist = (char.HumanoidRootPart.Position - targetPos).Magnitude
        end

        TweenTargetPosition = targetPos

        if ActiveTween then
            pcall(function() ActiveTween:Cancel() end)
            ActiveTween = nil
        end

        EnableNoclip()

        local speed = (Config and (Config.TweenSpeed or (Config.Configuration and Config.Configuration.TweenSpeed))) or 270
        local duration = math.max(0.01, dist / speed)

        ActiveTween = Services.TweenService:Create(
            hrp,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = targetCF}
        )
        TweenInstance = ActiveTween

        ActiveTween:Play()
        ActiveTween.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed then
                TweenTargetPosition = nil
                ActiveTween = nil
                -- H-04 fix: Disconnect noclip when tween completes
                if NoclipConn then pcall(function() NoclipConn:Disconnect() end); NoclipConn = nil end
            end
        end)
    end

    local AttackController = {
        IsAttacking = false,
        LastAttack = 0,
        AttackRange = 75,
        AttackCooldown = 0.03
    } 

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Player = Players.LocalPlayer
    local Modules = ReplicatedStorage:WaitForChild("Modules")
    local Net = Modules:WaitForChild("Net")
    local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:WaitForChild("RE/RegisterAttack", 3)
    local RegisterHit = Net:FindFirstChild("RE/RegisterHit") or Net:WaitForChild("RE/RegisterHit", 3)
    local ShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent") or Net:WaitForChild("RE/ShootGunEvent", 3)
    local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

    local NetModule = nil
    pcall(function()
        NetModule = require(Net)
    end)

    local function ResolveAttackRemote()
        if RegisterAttack and RegisterAttack.Parent then return RegisterAttack end
        if NetModule and NetModule.RemoteEvent then
            local ok, rem = pcall(function() return NetModule:RemoteEvent("RegisterAttack", true) end)
            if ok and rem then RegisterAttack = rem return rem end
        end
        RegisterAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:WaitForChild("RE/RegisterAttack", 2)
        return RegisterAttack
    end

    local function ResolveHitRemote()
        if RegisterHit and RegisterHit.Parent then return RegisterHit end
        if NetModule and NetModule.RemoteEvent then
            local ok, rem = pcall(function() return NetModule:RemoteEvent("RegisterHit", true) end)
            if ok and rem then RegisterHit = rem return rem end
        end
        RegisterHit = Net:FindFirstChild("RE/RegisterHit") or Net:WaitForChild("RE/RegisterHit", 2)
        return RegisterHit
    end

    local function GetBladeHitTargets(originPos, range)
        local bladehits = {}
        local primaryPart = nil
        local char = Player.Character
        local distLimit = range or AttackController.AttackRange or 75

        local function scanFolder(folder)
            if not folder then return end
            for _, mob in ipairs(folder:GetChildren()) do
                if mob ~= char and mob:IsA("Model") then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head") or mob.PrimaryPart
                    if hum and hum.Health > 0 and hrp then
                        local d = (hrp.Position - originPos).Magnitude
                        if d <= distLimit then
                            local part = mob:FindFirstChild("Head") or mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("UpperTorso") or hrp
                            if not primaryPart then
                                primaryPart = part
                            end
                            table.insert(bladehits, { mob, part })
                        end
                    end
                end
            end
        end

        scanFolder(Workspace:FindFirstChild("Enemies"))
        scanFolder(Workspace:FindFirstChild("Characters"))

        return primaryPart, bladehits
    end

    function AttackController:PerformAttack()
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if not hrp then return end

        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then
            pcall(function()
                if FunctionsHandler and FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(ScriptStorage.ForceToUseSword and "Sword" or "Melee")
                end
            end)
            tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
        end

        -- Ensure Buso Haki (Aura) is active
        pcall(function()
            if not char:FindFirstChild("HasBuso") then
                if Remotes and Remotes.CommF_ then
                    Remotes.CommF_:InvokeServer("Buso")
                end
            end
        end)

        local primaryPart, bladehits = GetBladeHitTargets(hrp.Position, AttackController.AttackRange or 75)
        if not primaryPart or #bladehits == 0 then return end

        local toolTip = tool.ToolTip or ""
        local atkRemote = ResolveAttackRemote()
        local hitRemote = ResolveHitRemote()
        local coroutineId = tostring(Player.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)

        if toolTip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
            local dir = (primaryPart.Position - hrp.Position).Unit
            pcall(function()
                tool.LeftClickRemote:FireServer(dir, 1, true)
                tool.LeftClickRemote:FireServer(false)
            end)
        elseif toolTip == "Gun" and tool:FindFirstChild("Cooldown") then
            if ShootGunEvent then
                pcall(function()
                    ShootGunEvent:FireServer(primaryPart.Position)
                end)
            end
        end

        pcall(function()
            if atkRemote then
                atkRemote:FireServer(0)
            end
            if hitRemote then
                hitRemote:FireServer(primaryPart, bladehits, nil, nil, coroutineId)
            end
        end)
    end

    function AttackController.Attack(MonResult)
        AttackController.IsAttacking = true
        AttackController.LastAttack = tick()
        _G.FastAttack = true
        pcall(function()
            AttackController:PerformAttack()
        end)
    end

    function AttackController:Attack(MonResult)
        AttackController.IsAttacking = true
        AttackController.LastAttack = tick()
        _G.FastAttack = true
        pcall(function()
            AttackController:PerformAttack()
        end)
    end

    -- High-speed continuous background attack loop
    task.spawn(function()
        while task.wait(0.04) do
            if AttackController.IsAttacking or (tick() - (AttackController.LastAttack or 0)) < 1.5 or _G.FastAttack then
                pcall(function()
                    AttackController:PerformAttack()
                end)
            end
        end
    end) 

    CombatController = {
        GRAB = true, 
        GRAB_DISTANCE = SeaIndex == 1 and 250 or 350, 
        
        MAX_ATTACK_DURATION = 3, 
        MAX_ATTACK_DURATION_2 = 60, 
        LEVITATE_TIME = 1, 
        
        CurrentIndex = 1, 
    }

    LastFound = os.time()
    -- save center pos vao attribute cua con mob r set de cho do bi move idk

    _G.BringRange = 300
    _G.MobM = 15
    _B = true

    local function IsMatchingMob(mobName, target)
        if not target or target == "" then return true end
        if type(target) == "table" then
            for _, n in ipairs(target) do
                if tostring(mobName) == tostring(n) or string.find(tostring(mobName), tostring(n)) then
                    return true
                end
            end
            return false
        elseif type(target) == "string" then
            return tostring(mobName) == target or string.find(tostring(mobName), target) ~= nil
        end
        return false
    end

    function BringEnemy(PosMon, targetMobName)
        if not PosMon then return end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            end
        end)

        local enemiesFolder = workspace:FindFirstChild("Enemies") or (Services and Services.Workspace and Services.Workspace:FindFirstChild("Enemies"))
        if not enemiesFolder then return end

        local count = 0

        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            if count >= (_G.MobM or 15) then break end
            local hum = mob:FindFirstChildOfClass("Humanoid")
            local pp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            if hum and pp and hum.Health > 0 then
                local dist = (pp.Position - PosMon).Magnitude
                if dist <= (_G.BringRange or 300) and IsMatchingMob(mob.Name, targetMobName) then
                    count = count + 1
                    for _, p in ipairs(mob:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                    pcall(function()
                        pp.AssemblyLinearVelocity = Vector3.zero
                        pp.AssemblyAngularVelocity = Vector3.zero
                    end)

                    local offset = Vector3.new(
                        ((count - 1) % 5 - 2) * 3,
                        0,
                        math.floor((count - 1) / 5 - 2) * 3
                    )
                    local finalPos = PosMon + offset

                    if dist > 3 then
                        pp.CFrame = CFrame.new(finalPos)
                    end
                    
                    local bp = pp:FindFirstChild("BringBP")
                    if not bp then
                        bp = Instance.new("BodyPosition")
                        bp.Name = "BringBP"
                        bp.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                        bp.P = 500000
                        bp.D = 5000
                        bp.Parent = pp
                    end
                    bp.Position = finalPos

                    local bg = pp:FindFirstChild("BringBG")
                    if not bg then
                        bg = Instance.new("BodyGyro")
                        bg.Name = "BringBG"
                        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                        bg.P = 10000
                        bg.D = 1000
                        bg.Parent = pp
                    end
                    bg.CFrame = CFrame.new(finalPos)
                end
            end
        end
    end

    function CombatController.Grab(MobName) 
        local targetMob = MonResult or (typeof(MobName) == "Instance" and MobName) or (typeof(MobName) == "string" and workspace.Enemies:FindFirstChild(MobName))
        local targetPos = targetMob and targetMob:FindFirstChild("HumanoidRootPart") and targetMob.HumanoidRootPart.Position
        if targetPos then
            task.spawn(function() pcall(BringEnemy, targetPos, targetMob.Name) end)
        end
    end 

    function Sort1(N) 
        return N and N:FindFirstChild("HumanoidRootPart") and math.floor(CaculateDistance(N.HumanoidRootPart.CFrame))
    end 

    function CombatController.Search(MobTable) 
        
        local Lists = {}
        local Found = false
        for _, ChildInstance in GetMonAsSortedRange() do
            if table.find(MobTable, ChildInstance.Name) and ChildInstance:FindFirstChild("Humanoid") and ChildInstance.Humanoid.Health > 0 then 
                if (ChildInstance:GetAttribute("FailureCount") or 0) < 3 then 
                    Found = true
                    table.insert(Lists, ChildInstance) 
                end 
            end
        end
        
        table.sort(Lists, function(a, b) 
            return Sort1(a) < Sort1(b)
        end)
        
        if Found then 
            local Mon1 = Lists[1] 
            return Mon1
        end
        
        for _, ChildName in MobTable do 
            local MonResult2 = game.ReplicatedStorage:FindFirstChild(ChildName) 
            if MonResult2 then 
                return MonResult2
            end 
        end 
    end 

    function CombatController.Attack(MobTable, NearbyHit, Range, Callback)
        local inCombat = false
        pcall(function()
            local gm = getsenv and getsenv(game.ReplicatedStorage.GuideModule)
            if gm and gm._G and gm._G.InCombat then inCombat = true end
        end)
        
        if ScriptStorage.Tools["Sweet Chalice"] and inCombat then 
            TweenController.Create(Vector3.new(0,0,0)) 
            return
        end
        
        pcall(function() sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge) end)
        MobTable = type(MobTable) == "string" and {MobTable} or ( MobTable or {} ) 
        
        for _, Child in (MobTable) do
            local ChildName = tostring(Child)
            if ChildName == "Deandre" or ChildName == "Urban" or ChildName == "Diablo" and (os.time() - (LastFire12 or 0)) > 180 then 
                LastFire12 = os.time()
                Remotes.CommF_:InvokeServer("EliteHunter")
            end 
        end
        
        local MonResult = nil
        if NearbyHit then  
            local Mon = GetMonAsSortedRange()[1]
            local MonPosition = Mon and Mon:FindFirstChild("HumanoidRootPart") and Mon.HumanoidRootPart.Position 
            if MonPosition and CaculateDistance(MonPosition) < Range then 
                MonResult = Mon
            end 
        else 
            MonResult = CombatController.Search(MobTable)
        end 
        
        if MonResult then
            LastFound = os.time()
            local Count, Debounce = 0, os.time()
            local Count2, Debounce = 0, os.time()

            local InitMobHrp = MonResult:FindFirstChild("HumanoidRootPart")
            local FixedMobPos = (InitMobHrp and InitMobHrp.Position) or MonResult:GetPivot().Position
            local FixedFarmCF = CFrame.new(FixedMobPos + Vector3.new(0, 30, 0))

            while task.wait() do
                if _G.Stop then return end
                
                local inCombatLoop = false
                pcall(function()
                    local gm = getsenv and getsenv(game.ReplicatedStorage.GuideModule)
                    if gm and gm._G and gm._G.InCombat then inCombatLoop = true end
                end)
                if ScriptStorage.Tools["Sweet Chalice"] and inCombatLoop then 
                    TweenController.Create(Vector3.new(0,0,0)) 
                    return
                end 
                
                local MobHumanoid = MonResult:FindFirstChild("Humanoid")
                local MobHumanoidRootPart = MonResult:FindFirstChild("HumanoidRootPart")
                
                if not MobHumanoid or MobHumanoid.Health <= 0 then 
                    if MonResult.Name == "Don Swan" then 
                        Storage:Set("SwanDefeated", true)
                        Hop()
                    end 
                    break
                end 
                
                local hpPct = math.floor((MobHumanoid.Health / math.max(1, MobHumanoid.MaxHealth)) * 100)
                SetTask("MiniTask", "Attacking " .. tostring(MonResult.Name) .. " [HP: " .. hpPct .. "%]")

                local myChar = game.Players.LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

                if myHrp then
                    local curDist = (myHrp.Position - FixedFarmCF.Position).Magnitude
                    if curDist < 45 then
                        myHrp.CFrame = FixedFarmCF
                        pcall(function()
                            myHrp.AssemblyLinearVelocity = Vector3.zero
                            myHrp.AssemblyAngularVelocity = Vector3.zero
                        end)
                        BringEnemy(FixedMobPos, MobTable or MonResult.Name)
                    else
                        TweenController.Create(FixedFarmCF)
                    end
                end
                
                if CaculateDistance(FixedFarmCF.Position) < 150 then
                    _ = Callback and Callback()
                    BringEnemy(FixedMobPos, MobTable or MonResult.Name)
                    if MonResult.Name ~= "Core" then 
                        if ScriptStorage.PlayerData.Level > 100 and Count2 >= CombatController.MAX_ATTACK_DURATION_2 and MobHumanoid.Health - MobHumanoid.MaxHealth == 0 then 
                            SetTask("SubTask", "Hop Server - Mob Health Unchanged ( " .. MobHumanoid.Health .. " / " .. MobHumanoid.MaxHealth .. ")")
                            alert("Stuck", "Mob health unchanged")
                            _G.Stop = true
                            Hop("Mob Health Stuck")
                        end 
                        
                        if ( MonResult:GetAttribute("FailureCount") or 0 ) > 5 then 
                            Hop("Failed to attack")
                        end 
                        if Count >= CombatController.MAX_ATTACK_DURATION and MobHumanoid.Health - MobHumanoid.MaxHealth == 0 then 
                            Count = 0 
                            
                            local OldPosition = MonResult:GetAttribute("OldPosition") 
                            
                            if OldPosition then
                                MonResult:SetPrimaryPartCFrame(CFrame.new(OldPosition))
                                MonResult:SetAttribute("IgnoreGrab", true)
                                MonResult:SetAttribute("FailureCount", (MonResult:GetAttribute("FailureCount") or 0) + 1)
                                alert("Failed to attack", "Returning to the old position ( #" .. MonResult:GetAttribute("FailureCount") .. " )")
                                while CaculateDistance(MonResult.HumanoidRootPart.CFrame,OldPosition) > 6 and task.wait() do 
                                    MonResult.HumanoidRootPart.CFrame = (CFrame.new(OldPosition)) 
                                end 
                                
                                task.wait()
                                
                                return 
                            end 
                        end
                    end
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(ScriptStorage.ForceToUseSword and "Sword" or "Melee")
                    
                    
                    AttackController:Attack(MonResult)
                    if os.time() ~= Debounce then 
                        Debounce = os.time()
                        
                        Count = Count + 1
                        Count2 = Count2 + 1
                    end 
                    if Count > 30 and MonResult.Name ~= "Core" then
                        alert("Take more than 30s to attack, cancelling")
                        break
                    end
                    
                else 
                    
                    return
                end  
            end
        elseif not NearbyHit then 
            -- No alive mobs found from MobTable: Pick ONE primary mob to fly to and wait for!
            local primaryTarget = MobTable[1]
            local curQuest = QuestManager.GetCurrentClaimQuest and QuestManager.GetCurrentClaimQuest()
            if curQuest then
                for _, m in ipairs(MobTable) do
                    local mStr = tostring(m):lower()
                    if curQuest:lower():find(mStr) or mStr:find(curQuest:lower()) then
                        primaryTarget = m
                        break
                    end
                end
            end
            
            local Region = ScriptStorage.MobRegions and ScriptStorage.MobRegions[primaryTarget] 
            
            if not Region then 
                local Inst = Services.Workspace.Enemies:FindFirstChild(primaryTarget) or game.ReplicatedStorage:FindFirstChild(primaryTarget) 
                if Inst then
                    local okP, pcf = pcall(function() return Inst:GetPivot().Position end)
                    if okP and pcf then Region = { pcf } end
                end
            end 
            
            if not Region or #Region == 0 then 
                return 
            end
            
            -- Always wait at the primary central spawn position (Region[1])
            local rawPos = Region[1]
            local CurrentPosition = (typeof(rawPos) == "Vector3" and rawPos)
                or (typeof(rawPos) == "CFrame" and rawPos.Position)
                or (type(rawPos) == "table" and Vector3.new(rawPos[1] or rawPos.X or 0, rawPos[2] or rawPos.Y or 0, rawPos[3] or rawPos.Z or 0))
            
            if not CurrentPosition then
                return
            end
            
            local targetCF = CFrame.new(CurrentPosition + Vector3.new(0, 35, 0))
            SetTask("MiniTask", "Waiting for " .. tostring(primaryTarget) .. " to spawn...")
            
            local myChar = game.Players.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHrp then
                local dist = (myHrp.Position - targetCF.Position).Magnitude
                if dist > 25 then
                    TweenController.Create(targetCF)
                else
                    -- Already at spawn point: stay still and hover
                    myHrp.CFrame = targetCF
                    pcall(function()
                        myHrp.AssemblyLinearVelocity = Vector3.zero
                        myHrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
            end
            task.wait()
        end
    end 


    LevelFarmTTL = 0 
    LastTravel = os.time() 

    FunctionsHandler = {
        Initalized = false 
    }; 

    -- silenced print
    setmetatable(FunctionsHandler, {
        __index = function(Self, Index) 
            QueryResult = rawget(Self, Index) 
            
            if not QueryResult then 
                
                return {
                    Register = function(Coditional) 
                        if Coditional == false then return end 
                        
                        Result = {
                            CacheListener = {}, 
                            RealCache = {},
                            Methods = {}, 
                            Constants = {}, 
                            Events = {}, 
                            Initalized = true
                        } 
                        
                        function Result.RegisterMethod(Self, Name, Function) 
                            Self.Methods[Name] =
                            {
                                Name = Name, 
                                Callback = Function,
                                Call = function(Self, ...) 
                                    return Self.Callback(...) 
                                    
                                end, 
                                Events = {} 
                                
                            }
                            return true
                            
                        end 
                        
                        setmetatable(Result.Constants, {
                            __newindex = function() 
                                assert(false, "cannot change constant value!") 
                            end
                        })
                    
                        function Result.SaveConstant(Self, Key, Value) 
                            if Self.Constants[Key] then  
                                return assert(false, "constant name was used before!") 
                            end 
                            rawset(Self.Constants, Key, Value)
                        end 
                        
                        function Result.Set(Self, Key, Value) 
                            Self.CacheListener[Key] = Value 
                            return Value
                            
                        end
                        
                        function Result.Get(Self, Index) 
                            return Self.Constants[Index] or Self.RealCache[Index]
                            
                        end 
                        
                        function Result.AddVariableChangeListener(Self, Index, Callback) 
                            Self.Events[Index] = Callback
                            
                        end
                        
                        Result.CacheListener.__parent = Result; 
                        
                        setmetatable(Result.CacheListener, {
                            __newindex = function(Self, Key, Value) 
                                _ = Self.__parent.Events[Key] and Self.__parent.Events[Key](Key, Value)
                                
                                Self.__parent.RealCache[Key] = Value
                                
                            end 
                        })
                        
                        
                        
                        FunctionsHandler[Index] = Result
                        
                    end, 
                    Initalized = false
                }
            end 
            
            return QueryResult
            
        end 
    })

    function FunctionsHandler.SynchorizeUntilModuleLoaded(Self, Timeout) 
        local StartTime = os.time() 
        
        while not Self.Initalized do 
            task.wait() 
            local Difference = os.time() - StartTime 
            
            assert(not ( Timeout and Difference > Timeout ), "timed out")
        end 
        
    end 





    function GetCurrentClaimQuest(RawResponse) 
        return QuestManager.GetCurrentClaimQuest(RawResponse)
    end 

    -- LP Controller 

    FunctionsHandler.LocalPlayerController.Register()
    -- Exp Redeem 

    FunctionsHandler.ExpRedeem:Register() 

    -- Level Farm 

    FunctionsHandler.LevelFarm:Register() 

    -- Items / Sword

    FunctionsHandler.Saber:Register()
    FunctionsHandler.Rengoku:Register()
    FunctionsHandler.Yama:Register()
    FunctionsHandler.Tushita:Register()
    FunctionsHandler.SpikeyTrident:Register()
    FunctionsHandler.SharkAchor:Register()
    FunctionsHandler.Pole:Register()
    FunctionsHandler.FoxLamp:Register()
    FunctionsHandler.DarkDagger:Register()
    FunctionsHandler.Canvander:Register()
    FunctionsHandler.BuddySword:Register()
    FunctionsHandler.HallowScythe:Register()
    FunctionsHandler.CursedDualKatana:Register()

    -- Items / Guns 

    FunctionsHandler.AcidumRifle:Register()
    FunctionsHandler.Kabucha:Register()
    FunctionsHandler.VenomBow:Register()
    FunctionsHandler.SoulGuitar:Register()
    FunctionsHandler.DragonStorm:Register()

    -- Items / Etc

    FunctionsHandler.InsictV2:Register()
    FunctionsHandler.RainbowSaviour:Register()

    -- Puzzles / First Sea

    FunctionsHandler.DarkBladeV2:Register()
    FunctionsHandler.SecondSeaPuzzle:Register()

    -- Puzzles / Second Sea

    FunctionsHandler.ColosseumPuzzle:Register()
    FunctionsHandler.Trevor:Register()
    FunctionsHandler.EvoRace:Register()
    FunctionsHandler.Wenlocktoad:Register()
    FunctionsHandler.DarkBladeV3:Register()
    FunctionsHandler.ThirdSeaPuzzle:Register()

    -- Puzzles / Third Sea 

    FunctionsHandler.DojoQuest:Register()
    FunctionsHandler.RaceAwakening:Register()
    FunctionsHandler.PirateRaid:Register()

    -- Functions / Raid 

    FunctionsHandler.RaidController:Register() 

    -- Functions / Auto Melees 

    FunctionsHandler.MeleesController:Register() 

    FunctionsHandler.Superhuman:Register()
    FunctionsHandler.DeathStep:Register()
    FunctionsHandler.SharkmanKarate:Register()
    FunctionsHandler.ElectricClaw:Register()
    FunctionsHandler.DragonTalon:Register()
    FunctionsHandler.Godhuman:Register()

    -- Functions / Boss Task 

    FunctionsHandler.BossesTask:Register() 
    FunctionsHandler.SpecialBossesTask:Register() 
    -- Functions / CollectDrops
    FunctionsHandler.CollectDrops:Register() 

    -- Functions / UtillyItemsActivitation

    FunctionsHandler.UtillyItemsActivitation:Register() 

    -- Exp Redeem 

    FunctionsHandler.ExpRedeem:RegisterMethod("Refresh", function() 
        return false
    end)

    FunctionsHandler.ExpRedeem:RegisterMethod("Start", function() 
        local Code = ({
                "BANEXPLOIT",
                "NOMOREHACK",
                "WildDares",
                "BossBuild",
                "GetPranked",
                "EARN_FRUITS",
                "Sub2UncleKizaru",
                "FIGHT4FRUIT",
                "kittgaming",
                "TRIPLEABUSE",
                "Sub2CaptainMaui",
                "Sub2Fer999",
                "Enyu_is_Pro",
                "Magicbus",
                "JCWK",
                "Starcodeheo",
                "Bluxxy",
                "SUB2GAMERROBOT_EXP1",
                "Sub2NoobMaster123",
                "Sub2Daigrock",
                "Axiore",
                "TantaiGaming",
                "StrawHatMaine",
                "Sub2OfficialNoobie",
                "TheGreatAce",
                "SEATROLLING",
                "24NOADMIN",
                "ADMIN_TROLL",
                "NEWTROLL",
                "SECRET_ADMIN",
                "staffbattle",
                "NOEXPLOIT",
                "NOOB2ADMIN",
                "CODESLIDE",
                "fruitconcepts"
            })
        
        for Index, Promo in Code do
            
            SetTask("MainTask", "Code Redemption | " .. Promo .. " | Redeeming...")
            local Response = (Remotes.Redeem:InvokeServer(Promo))
            task.wait() 
            SetTask("MainTask", "Code Redemption | " .. Promo .. " | " .. (Response or "Failed"))
            if getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost == 0 then 
                
                if Response and string.find(Response, "SUCC") then 
                    return SetTask("MainTask", "Code Redemption | X2 Exp Boost Activated!") and task.wait(1)
                end 
                else 
                    return  
            end
        end
        
        Storage:Set("IsCodesRanOut", 1)
        Storage:Save()
    end)


    -- Level Farm 

    FunctionsHandler.LevelFarm:RegisterMethod("Refresh", function() 
        return 4
    end)

    FunctionsHandler.LevelFarm:RegisterMethod("Start", function(Level) 
        if SeaIndex == 3 then 
            if ( ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 50 and ( ScriptStorage.PlayerData.Level < MaxLevel or ForceToRollBone or ScriptStorage.PlayerData.Level >= MaxLevel ) then 
                
                if os.time() > (BonesCooldown or 0) then 
                    
                    local _, _, State, Message = Remotes.CommF_:InvokeServer("Bones", "Check") 
                    -- silenced print
                    if tonumber(State or 1) == 0 then 
                        local SplitedNum = Split(Message, ":")
                        local SecondsLeft = ((tonumber(SplitedNum[1]) * 60) + tonumber(SplitedNum[2])) * 60 
                        BonesCooldown = os.time() + SecondsLeft
                        -- silenced print
                    else 
                        -- silenced print
                        Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                    end
                end 
            end 
        end
        local currentClaim = QuestManager.GetCurrentClaimQuest and QuestManager.GetCurrentClaimQuest()
        if currentClaim then
            local lowClaim = tostring(currentClaim):lower()
            for _, eliteName in ipairs({"deandre", "urban", "diablo"}) do
                if lowClaim:find(eliteName) then
                    SetTask("MainTask", "Elite Hunter | Defeating " .. currentClaim)
                    SetTask("SubTask", "Target: " .. currentClaim)
                    CombatController.Attack(currentClaim)
                    return
                end
            end
        end
        
        local PlayerLevel = ScriptStorage.PlayerData.Level 
        if GodHumanFlag then 
        
            local Material, MaterialData = (function() 
                getgenv()["     mphm >< <3"] = {}
                for Material, MaterialData in GodhumanMaterials do 
                    if ( ScriptStorage.Backpack[Material] or {Count = 0} ).Count < MaterialData[1] then 
                        getgenv()["     mphm >< <3"] = {Material, MaterialData}
                    end
                end
                
                return unpack(getgenv()["     mphm >< <3"])
            end)() 
            
            if Material then
                if SeaIndex ~= MaterialData[2] then 
                    alert("Material - " .. Material, "Travelling sea " .. MaterialData[2])
                    SetTask("MainTask", "Sea Travel | Godhuman Materials | Travelling to Sea " .. MaterialData[2])
                    
                    Remotes.CommF_:InvokeServer("Travel" .. SeaIndexes[MaterialData[2]]) 
                    return 
                end 
                
                SetTask("MainTask", "Material Farming | Godhuman | " .. Material .. " | In Progress")
                
                if PlayerLevel >= MaterialData[4][3] then 
                    local QuestAvailable, CurrentClaimQuest = GetCurrentClaimQuest() 
                    if QuestAvailable then 
                        if not string.find(CurrentClaimQuest, MaterialData[3][1]) and not string.find(CurrentClaimQuest, MaterialData[3][2]) then
                            
                            QuestManager.AbandonQuest() 
                        else 
                            CombatController.Attack(MaterialData[3])
                            return
                        end
                    else
                                
                        local NpcPosition1 = ScriptStorage.NPCs[MaterialData[4][4]] 
                        NpcPosition1 = NpcPosition1 and NpcPosition1:GetModelCFrame() 
                        
                        if NpcPosition1 then
                            TweenController.Create(NpcPosition1 + Vector3.new(0,5,3)) 
                            if CaculateDistance(NpcPosition1) < 10 then 
                                task.wait(1) 
                            else 
                                return 
                            end
                        else 
                            Report("NPC HauntedQuest2 not found")
                        end 
                        QuestManager.StartQuest(MaterialData[4][1], MaterialData[4][2])
                        return
                    end
                end
                
                CombatController.Attack(MaterialData[3])

            end
            
            Remotes.CommF_:InvokeServer("BuyGodhuman", true)
            Remotes.CommF_:InvokeServer("BuyGodhuman")
            
            
            GodHumanFlag = false
            return true
        end
        
        if os.time() - LastTravel > 60 then 
            LastTravel = os.time()
            if PlayerLevel >= 1500 and SeaIndex == 2 then 
                if Config.Settings.StayInSea2UntilHaveDarkFragments and not ScriptStorage.Backpack["Dark Fragment"] then 
                elseif not Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor") then 
                    Remotes.CommF_:InvokeServer("TravelZou")
                    SetTask("MainTask", "Sea Travel | Teleporting to Third Sea")
                end 
            elseif PlayerLevel >= 700 and SeaIndex == 1 then 
                    SetTask("MainTask", "Sea Travel | Teleporting to Second Sea")
                    Remotes.CommF_:InvokeServer("TravelDressrosa")
            end
        end 
        
        if ScriptStorage.Tools["God's Chalice"] and not ScriptStorage.Tools["Mirror Fractal"] then 
            if (ScriptStorage.Backpack["Conjured Cocoa"] or {Count = 0}).Count < 10 then 
                SetTask("MainTask", "Material Farming | Conjured Cocoa | Need 10x | Farming...")
                CombatController.Attack({"Cocoa Warrior", "Chocolate Bar Battler"}) 
                return 
            end
            Remotes.CommF_:InvokeServer("SweetChaliceNpc")
        end 
            
        if ScriptStorage.Tools["Sweet Chalice"] or ( PlayerLevel == MaxLevel and ( ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 500 ) then 
            
            
            SetTask("MainTask", "Fragments Farming | Cake Prince | Dough King")
            
            
            if (ScriptStorage.Tools["Sweet Chalice"]) and ( not SpawnReflect or os.time() - SpawnReflect > 10 ) then 
                task.spawn(function() 
                    while not ScriptStorage.Enemies["Dough King"] and task.wait() and ScriptStorage.Tools["Sweet Chalice"] do 
                        SpawnReflect = os.time() 
                        Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                    end 
                end)
            end 
            
            
            CombatController.Attack({
                "Head Baker",
                "Baking Staff",
                "Cookie Crafter",
                "Cake Guard"
            }) 
        
            if PlayerLevel >= 2200 then
                local IsAvailabe, CurrentClaimQuest2 = GetCurrentClaimQuest() 
                
                
                if IsAvailabe then 
                    if not string.find(CurrentClaimQuest2, "Cookie") then
                        QuestManager.AbandonQuest() 
                    else 
                        
                        Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                        return
                    end 
                else 
                    local NpcPosition1 = (ScriptStorage.NPCs["Cake Quest Giver 1"] and ScriptStorage.NPCs["Cake Quest Giver 1"]:GetModelCFrame()) or CFrame.new(-2022.3, 37.8, -12031.0)
                    TweenController.Create(NpcPosition1 * CFrame.new(0, 5, 3)) 
                    if CaculateDistance(NpcPosition1) < 25 then 
                        task.wait(0.5) 
                        QuestManager.StartQuest("CakeQuest1", 1)
                    end
                    return
                end 
            end
            return 
        end
        
        local hasExpBoost = false
        pcall(function()
            local gm = getsenv and getsenv(game.ReplicatedStorage.GuideModule)
            if gm and gm._G and gm._G.ServerData and gm._G.ServerData.ExpBoost and gm._G.ServerData.ExpBoost > 0 then
                hasExpBoost = true
            end
        end)
        
        local bonesCount = (ScriptStorage.Backpack and ScriptStorage.Backpack.Bones and ScriptStorage.Backpack.Bones.Count) or 0
        local shouldFarmBones = (PlayerLevel >= 2025 and SeaIndex == 3 and not hasExpBoost and bonesCount < 500)
        
        if shouldFarmBones then
            SetTask("MainTask", "Resource Farming | Bones (" .. bonesCount .. "/500)")
            SetTask("SubTask", "Haunted Castle • Bones: " .. bonesCount .. " / 500")

            local CurrentClaimQuest3 = QuestManager.GetCurrentClaimQuest(true) 
            
            if CurrentClaimQuest3 then 
                local cleanClaim = string.lower(tostring(CurrentClaimQuest3))
                if not cleanClaim:find("demonic") and not cleanClaim:find("haunted") and not cleanClaim:find("posessed") and not cleanClaim:find("mummy") and not cleanClaim:find("reborn") and not cleanClaim:find("living") then
                    if cleanClaim:find("deandre") or cleanClaim:find("urban") or cleanClaim:find("diablo") then
                        SetTask("MainTask", "Elite Hunter | Defeating " .. tostring(CurrentClaimQuest3))
                        CombatController.Attack(tostring(CurrentClaimQuest3))
                        return
                    end
                    SetTask("MiniTask", "Switching to Haunted Castle Quest...")
                    QuestManager.AbandonQuest() 
                    task.wait(0.3)
                    return
                else 
                    SetTask("MiniTask", "Defeating Haunted Castle Mobs for Bones")
                    CombatController.Attack({
                        "Reborn Skeleton",
                        "Living Zombie",
                        "Demonic Soul",
                        "Posessed Mummy"
                    })
                    return 
                end
            else
                if (os.time() - (LastBonesQuestAttempt or 0)) < 2 then
                    return
                end
                
                SetTask("MiniTask", "Taking Haunted Castle Quest...")
                local NpcPosition1 = (ScriptStorage.NPCs["Haunted Castle Quest Giver 2"] and ScriptStorage.NPCs["Haunted Castle Quest Giver 2"]:GetModelCFrame()) or CFrame.new(-9517.1, 171.4, 6078.5)
                
                TweenController.Create(NpcPosition1 * CFrame.new(0, 5, 3))
                if CaculateDistance(NpcPosition1) < 25 then 
                    LastBonesQuestAttempt = os.time()
                    task.wait(0.3) 
                    QuestManager.StartQuest("HauntedQuest2", 1) 
                    task.wait(0.3)
                end 
                return
            end
        end 
        
        if Level == 1 then 
            SetTask("MainTask", "Level Farming | Floor " .. Level)
            SetTask("SubTask", "Target: Sky Bandit")
            SetTask("MiniTask", "Attacking Sky Bandit")
            CombatController.Attack("Sky Bandit")
        elseif Level == 2 then 
            SetTask("MainTask", "Level Farming | Floor " .. Level)
            SetTask("SubTask", "Target: God's Guard")
            SetTask("MiniTask", "Attacking God's Guard")
            CombatController.Attack("God's Guard")
        elseif Level == 3 then 
            SetTask("MainTask", "Level Farming | Floor " .. Level)
            SetTask("SubTask", "Target: Sky Mobs")
            SetTask("MiniTask", "Attacking Sky Mobs")
            CombatController.Attack({"God's Guard", "Shanda", "Royal Soldier", "Royal Squad"})
        elseif Level == 4 then
            local MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest() 
            
            if not MonName then
                QuestManager:RefreshQuest()
                MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
            end
            
            if not MonName then
                SetTask("MainTask", "Level Farming | Loading Quest Data...")
                return
            end
            
            local myChar = game.Players.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local isSubmerged = QuestId and tostring(QuestId):find("Submerged") ~= nil
            
            if isSubmerged and myHrp then
                local inSubmergedIsland = myHrp.Position.Y < -1000
                if not inSubmergedIsland then
                    -- Player is on surface: Must check Tyrant of the Skies and travel via Submarine Worker at Tiki Outpost Sub Port 01
                    local tyrant = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Tyrant of the Skies")
                    if tyrant and tyrant:FindFirstChild("Humanoid") and tyrant.Humanoid.Health > 0 then
                        SetTask("MainTask", "Unlocking Submerged Island | Defeating Tyrant of the Skies")
                        SetTask("SubTask", "Boss: Tyrant of the Skies")
                        SetTask("MiniTask", "Attacking Tyrant of the Skies...")
                        CombatController.Attack("Tyrant of the Skies")
                        return
                    end

                    local subPortCF = CFrame.new(-16269.7041, 25.2288494, 1373.65955)
                    local distToPort = (myHrp.Position - subPortCF.Position).Magnitude
                    if distToPort > 25 then
                        SetTask("MainTask", "Traveling to Submerged Island")
                        SetTask("SubTask", "Tiki Outpost - Sub Port 01")
                        SetTask("MiniTask", "Flying to Submarine Worker...")
                        TweenController.Create(subPortCF)
                        return
                    else
                        SetTask("MainTask", "Traveling to Submerged Island")
                        SetTask("SubTask", "Tiki Outpost - Sub Port 01")
                        SetTask("MiniTask", "Speaking to Submarine Worker...")
                        pcall(function()
                            local net = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net")
                            local subRemote = net:FindFirstChild("RF/SubmarineWorkerSpeak") or net:FindFirstChild("SubmarineWorkerSpeak")
                            if subRemote then
                                subRemote:InvokeServer("TravelToSubmergedIsland")
                            else
                                Remotes.CommF_:InvokeServer("SubmarineWorkerSpeak", "TravelToSubmergedIsland")
                            end
                        end)
                        pcall(function()
                            Remotes.CommF_:InvokeServer("SubmarineWorker", "TravelToSubmergedIsland")
                        end)
                        task.wait(1.5)
                        return
                    end
                end
            end

            local CurrentClaimQuest1 = QuestManager.GetCurrentClaimQuest()
            local prefixTask = hasExpBoost and "Level Farming (2x EXP) | " or "Level Farming | "
            
            if CurrentClaimQuest1 then 
                local cleanClaim = string.lower(tostring(CurrentClaimQuest1)):gsub("%W", "")
                local cleanMon = string.lower(tostring(MonName)):gsub("%W", "")
                local cleanTitle = string.lower(tostring(QuestTitle or "")):gsub("%W", "")
                
                local isMatch = (string.find(cleanClaim, cleanMon, 1, true) ~= nil)
                             or (string.find(cleanMon, cleanClaim, 1, true) ~= nil)
                             or (string.find(cleanClaim, cleanTitle, 1, true) ~= nil)
                             or (string.find(cleanTitle, cleanClaim, 1, true) ~= nil)
                             or (cleanClaim:gsub("s$", "") == cleanMon:gsub("s$", ""))
                             or (#cleanClaim >= 4 and #cleanMon >= 4 and cleanClaim:sub(1, 4) == cleanMon:sub(1, 4))
                
                if not isMatch then
                    if cleanClaim:find("deandre", 1, true) or cleanClaim:find("urban", 1, true) or cleanClaim:find("diablo", 1, true) then
                        SetTask("MainTask", "Elite Hunter | Defeating " .. tostring(CurrentClaimQuest1))
                        CombatController.Attack(tostring(CurrentClaimQuest1))
                        return
                    end
                    SetTask("SubTask", "Quest: " .. tostring(CurrentClaimQuest1))
                    SetTask("MiniTask", "Abandoning mismatch quest...")
                    QuestManager.AbandonQuest() 
                    task.wait(0.3)
                    return
                end 
                SetTask("MainTask", prefixTask .. MonName)
                SetTask("SubTask", "Quest: " .. tostring(CurrentClaimQuest1) .. " (" .. tostring(MonName) .. ")")
            else 
                if (os.time() - (LastLevelQuestAttempt or 0)) < 2 then
                    return
                end

                if not NpcPosition then 
                    QuestManager:RefreshQuest()
                    _, NpcPosition = QuestManager:GetCurrentQuest()
                end 
                if not NpcPosition then
                    SetTask("MainTask", prefixTask .. MonName)
                    SetTask("MiniTask", "Finding NPC for " .. MonName .. "...")
                    return
                end
                
                SetTask("MainTask", prefixTask .. MonName)
                SetTask("SubTask", "Quest: " .. tostring(QuestTitle or MonName))
                SetTask("MiniTask", "Flying to Quest NPC: " .. tostring(MonName))
                local targetCF = (typeof(NpcPosition) == "CFrame" and (NpcPosition * CFrame.new(0, 5, 3))) or CFrame.new(NpcPosition + Vector3.new(0, 5, 3))
                TweenController.Create(targetCF) 
                
                if CaculateDistance(NpcPosition) > 20 then 
                    return 
                end 
                
                SetTask("MiniTask", "Accepting Quest [" .. tostring(QuestTitle or MonName) .. "]")
                LastLevelQuestAttempt = os.time()
                task.wait(0.3)
                LevelFarmTTL = 0 
                QuestManager.StartQuest(QuestId, QuestIndex)
                task.wait(0.3)
                return
            end 

            SetTask("MainTask", prefixTask .. MonName)
            SetTask("MiniTask", "Attacking " .. tostring(MonName))
            local AttackTime1 = os.time()
            CombatController.Attack(MonName)
            LevelFarmTTL = LevelFarmTTL + os.time() - AttackTime1 
        end
    end)

    -- LP Controller 



    FunctionsHandler.LocalPlayerController:RegisterMethod("EquipTool", function(Tool) 
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end 
        
        local toolStr = tostring(Tool)
        local curTool = char:FindFirstChildOfClass("Tool")
        if curTool then
            if curTool.Name == toolStr or curTool.ToolTip == toolStr then
                return
            end
            if (toolStr == "Melee" or toolStr == "Sword") and (curTool.ToolTip == "Melee" or curTool.ToolTip == "Sword") then
                if not ScriptStorage.ForceToUseSword or curTool.ToolTip == "Sword" then
                    return
                end
            end
        end

        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then return end

        for _, Item in ipairs(bp:GetChildren()) do 
            if Item:IsA("Tool") and Item.Name ~= "Tool" and (Item.Name == toolStr or Item.ToolTip == toolStr) then 
                hum:EquipTool(Item)
                return
            end 
        end 

        -- Fallback if requested tool not found: equip any Melee, Sword or Fruit
        if toolStr == "Melee" or toolStr == "Sword" then
            for _, Item in ipairs(bp:GetChildren()) do
                if Item:IsA("Tool") and (Item.ToolTip == "Melee" or Item.ToolTip == "Sword") then
                    hum:EquipTool(Item)
                    return
                end
            end
            for _, Item in ipairs(bp:GetChildren()) do
                if Item:IsA("Tool") and Item.ToolTip == "Blox Fruit" then
                    hum:EquipTool(Item)
                    return
                end
            end
            for _, Item in ipairs(bp:GetChildren()) do
                if Item:IsA("Tool") and Item.ToolTip ~= "Gun" then
                    hum:EquipTool(Item)
                    return
                end
            end
        end
    end)

    FunctionsHandler.LocalPlayerController:RegisterMethod("ToggleAbilities", function(Ability, State) 
        
        if Ability == "Buso" then 
            if LocalPlayer:HasTag("Buso") and not State or State then 
                Remotes.CommF_:InvokeServer("Buso")
            end 
            
        elseif Ability == "Observation" then
            
        end 
    end)

    FunctionsHandler.LocalPlayerController:RegisterMethod("ConfigurationAbilitiesToggle", function() 
        FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call("Buso", SCRIPT_CONFIG.BUSO)
        FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call("Observation", SCRIPT_CONFIG.OBSERVATION)
    end)
    -- silenced print


    -- Items / Saber 




    FunctionsHandler.Saber:RegisterMethod("Refresh", function() 
        
        if not Config.Items.Saber then return end 
        
        if not Config.Items.Saber then 
            return 
        end 
        
        local Result 
        if ScriptStorage.Backpack.Saber then 
            return 
        end 
        
        if ScriptStorage.PlayerData.Level < 200 then 
            return
        end 
        
        
        local Tasks = Remotes.CommF_:InvokeServer("ProQuestProgress") 
        for _, Value in Tasks.Plates do
            if Value == false then
                Result = 1
                
            end
        end
        
        if not Result then 
            if not Tasks.UsedTorch then
            Result = 2
                
            elseif not Tasks.UsedCup then
                Result = 3
                
            elseif not Tasks.TalkedSon then
                Result = 4
                
            elseif not Tasks.KilledMob then
                Result = 5
                
            elseif not Tasks.UsedRelic then
                Result = 6
                
            elseif
                not Tasks.KilledShanks
                and ScriptStorage.Enemies["Saber Expert"]
            then
                Result = 7
                
            end
        end 
        
        FunctionsHandler.Saber:Set("CurrentProgressLevel", Result)
        FunctionsHandler.Saber:Set("LastestRefreshSenque", os.time()) 
        
        return Result
        
    end) 

    FunctionsHandler.Saber:RegisterMethod("GetQuestplates", function() 
        
        local CachedData = FunctionsHandler.Saber:Get("QuestplatesCache") 
        
        if CachedData then
            return CachedData 
            
        end 
        
        
        
        local Jungle = Services.Workspace.Map.Jungle 
        local Result = {}
        
        table.foreach(Jungle.QuestPlates:GetChildren(), function(_, Inst) 
            _ = Inst:FindFirstChild("Button") and table.insert(Result, Inst) 
            
        end)
        
        FunctionsHandler.Saber:Set("QuestplatesCache", Result)
        
        return Result 
        
    end)

    FunctionsHandler.Saber:RegisterMethod("Start", function() 
        local 
        Progress,
            LastestRefreshSenque = 
            FunctionsHandler.Saber:Get("CurrentProgressLevel"),
        FunctionsHandler.Saber:Get("LastestRefreshSenque") 
        
        -- silenced print
        if not Progress then
            FunctionsHandler.Saber.Methods.Refresh:Call()
            return FunctionsHandler.Saber.Methods.Start:Call()
        
        elseif Progress == 0 then 
            
        elseif os.time() - LastestRefreshSenque > 60 then 
            FunctionsHandler.Saber.Methods.Refresh:Call()
            
            return FunctionsHandler.Saber.Methods.Start:Call()
        
        else
            if Progress == 1 then 
                local Questplates = FunctionsHandler.Saber.Methods.GetQuestplates:Call()
                
                for Index, Questplate in Questplates do  
                    SetTask("MainTask", "Saber Quest | Quest Plates | Touching " .. Index .. "/5")
                    while CaculateDistance(Questplate.Button.CFrame) > 20 do 
                        task.wait() 
                        TweenController.Create(Questplate.Button.CFrame)
                    end
                    task.wait(1)
                end
            
            elseif Progress == 2 then 
                SetTask("MainTask", "Saber Quest | Torch Puzzle | Using Torch")
                Remotes.CommF_:InvokeServer("ProQuestProgress", "GetTorch")
                task.wait(1) 
                Remotes.CommF_:InvokeServer("ProQuestProgress", "DestroyTorch")
                
            elseif Progress == 3 then  
                SetTask("MainTask", "Saber Quest | Sick Man | Helping with Cup")
                Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup")
                
                if ScriptStorage.Tools.Cup then 
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Cup") 
                    task.wait(1)
                    Remotes.CommF_:InvokeServer( "ProQuestProgress", "FillCup", LocalPlayer.Character.Cup)
                end
                
                Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan")
                
            elseif Progress == 4 then 
                SetTask("MainTask", "Saber Quest | Rich Son | Getting Information")
                Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                
                
            elseif Progress == 5 then 
                SetTask("MainTask", "Saber Quest | Mob Leader | Defeating Boss")
                CombatController.Attack("Mob Leader")
                
            elseif Progress == 6 then 
                SetTask("MainTask", "Saber Quest | Relic | Placing at Location")
                Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
            
            elseif Progress == 7 then 
                SetTask("MainTask", "Saber Quest | Saber Expert | Final Battle")
                CombatController.Attack("Saber Expert")
                
            end
        end
    end)

    Remotes.RefreshQuestPro.OnClientEvent:Connect(FunctionsHandler.Saber.Methods.Refresh.Callback);


    -- Auto Melees

    MeleeLastCursor = 1
    FirstCall = true
    CanPurchase = {}
    BuyDebounce = {} 

    FunctionsHandler.MeleesController:RegisterMethod("Start", function()
        if not Config.Items.AutoFullyMelees then return end
        for Cursor, Melee in MeleesTable do
            if Melee ~= 'SanguineArt' then 
                
                
                if not Config.Items.AutoFullyMelees then
                    break 
                end 
                
                local Data = MeleePrices[Melee]
                local CanMeleePurchaseable = CanPurchase[Melee] 
                if not CanMeleePurchaseable then 
                    CanPurchase[Melee] = Data.Buy(1)
                    -- silenced print)
                end 
                local CanMeleePurchaseable = CanPurchase[Melee] 
                
                
                if not Data then 
                    -- silenced print
                    break 
                end
                
                if Melee == "Dragon Talon" then 
                    IsFireEssenceGave = (function()
                        if IsFireEssenceGave ~= nil then
                            return IsFireEssenceGave
                        end 
                        
                        local PurchaseTestResult = Remotes.CommF_:InvokeServer("BuyDragonTalon", true);
                        alert("Dragon Talon Purchased", tostring(typeof(PurchaseTestResult) ~= "string"))
                        return typeof(PurchaseTestResult) ~= "string" and true or false
                    end)()
                    
                    -- silenced print
                    
                    if not IsFireEssenceGave then
                        -- silenced print
                        break 
                    end 
                end 
                if Melee == "Godhuman" and not GodHumanFlag then 
                    
                    if (ScriptStorage.Melees["Dragon Talon"] or 0) > 399 then
                    
                        if not ScriptStorage.Melees.Godhuman then 
                            
                            Remotes.CommF_:InvokeServer("BuyGodhuman", true)
                            Remotes.CommF_:InvokeServer("BuyGodhuman")
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                            
                            if not ScriptStorage.Melees.Godhuman then 
                                
                                GodHumanFlag = true
                                return
                            end 
                        end 
                    end 
                end
                
                if not ScriptStorage.Melees[Melee] or ( ScriptStorage .Melees[Melee] or 0) < Data.NextLevelRequirement then 
                    
                    local MeleeId = GetMeleeIdByName(Melee)
                    local PlayerData = ScriptStorage.PlayerData 
                    local ValuementPassed = true 
                    
                    if not MeleeId then 
                        
                        return -- silenced print 
                    end 
                    
                    local MSet = false 
                    if not CanMeleePurchaseable then 
                        for Index, Value in Data.Price do 
                            if PlayerData[Index] < Value and not FirstCall then 
                                ValuementPassed = false 
                                if not ScriptStorage.Melees[Melee] and (CurrentTask == "MeleesController" or not CurrentTask) then 
                                    MSet = true
                                    SetTask("SubTask", "Farming Until Enough " .. Index .. " ( ".. Value .. " ) For " .. Melee)
                                end
                                return
                            end
                        end 
                    end 
                    
                    
                    if not MSet and ScriptStorage.Melees[Melee] and ScriptStorage.Melees[Melee] < Data.NextLevelRequirement then 
                        if CurrentTask == "MeleesController" or not CurrentTask then
                            SetTask("SubTask", "Farming Until Enough Mastery For " .. Melee .. " ( " .. ScriptStorage.Melees[Melee] .. " / " .. Data.NextLevelRequirement .. " ).") 
                        end
                        if not ScriptStorage.Tools[Melee] then 
                            if not BuyDebounce[Melee] or os.time() - BuyDebounce[Melee] > 30 then
                                BuyDebounce[Melee] = os.time()
                                Data.Buy() 
                            end
                        end 
                        return
                    end 
                    
                    
                    if not FirstCall then
                        if ValuementPassed and Data.Requirements() and not ScriptStorage.Tools[Melee] then
                            if Melee == "Dragon Talon" and not IsFireEssenceGave then 
                                alert("IsFireEssenceGave", tostring(IsFireEssenceGave))
                                return SetTask("SubTask", "Waiting until have fire essence for dragon talon.")
                            end 
                            
                            if BuyDebounce[Melee] and os.time() - BuyDebounce[Melee] < 30 then return end
                            BuyDebounce[Melee] = os.time()
                            Data.Buy() 
                            
                            
                    
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                            if not ScriptStorage.Tools[Melee] then
                                
                                
                                task.wait()
                                if not ScriptStorage.Tools[Melee] then 
                                    if ( Melee == "Death Step" or Melee == "Sharkman Karate" ) and SeaIndex == 1 then
                                    
                                        alert("Go Back To Second Sea", "Water Key / Library Key")
                                        Remotes.CommF_:InvokeServer("TravelDressrosa")
                                    end 
                                else 
                                    MeleeLastCursor = Cursor + 1
                                    
                                    return
                                end 
                            else 
                                MeleeLastCursor = Cursor + 1
                                return
                            end 
                        end
                    end
                    
                elseif not FirstCall then 
                    MeleeLastCursor = Cursor + 1
                end
            end 
        end
        
        if FirstCall then 
            FirstCall = false 
            return 
        end 
        
        FarmingItem = nil
        
        for ItemName, Item in ScriptStorage.Backpack do
            if Item.Type == "Sword" then 
                
                if Item.Name == "Yama" or Item.Name == "Tushita" then 
                    MasteryRequirement = 350 
                else 
                    for _, Value in Item.MasteryRequirements do 
                    
                        MasteryRequirement = Value
                    end
                end 
                
                if MasteryRequirement and Item.Mastery < MasteryRequirement then
                    FarmingItem = { Item.Name, Item.Mastery, MasteryRequirement }
                    if Item.Name == "Yama" or Item.Name == "Tushita" then break end 
                end 
            end 
        end 
        if FarmingItem then 
            SetTask('SubTask', 'Farming mastery for ' .. FarmingItem[1] .. ' ( ' .. FarmingItem[2] .. ' / ' .. FarmingItem[3] .. ' )')
            if not ScriptStorage.Tools[FarmingItem[1]] then 
                Remotes.CommF_:InvokeServer("LoadItem", FarmingItem[1])
            end 
            ScriptStorage.ForceToUseSword = FarmingItem
        end
    end) 


    -- Second Sea 

    FunctionsHandler.SecondSeaPuzzle:RegisterMethod("Refresh", function() 
        if ScriptStorage.PlayerData.Level < 700 or SeaIndex ~= 1 then return end 
        if FunctionsHandler.SecondSeaPuzzle:Get("IsCompleted") then return end 
        
        local Response = Remotes.CommF_:InvokeServer("DressrosaQuestProgress") 
        -- silenced print
        if not Response.TalkedDetective then 
            Result = 1 
        elseif not Response.KilledIceBoss then 
            Result = 2 
        else 
            FunctionsHandler.SecondSeaPuzzle:Set("IsCompleted", true) 
        end 
        
        FunctionsHandler.SecondSeaPuzzle:Set("CurrentProgressLevel", Result)
        FunctionsHandler.SecondSeaPuzzle:Set("LastestRefreshSenque", os.time()) 
        
        return Result 
    end)

    FunctionsHandler.SecondSeaPuzzle:RegisterMethod("Start", function() 
        local Progress, LastestRefreshSenque = FunctionsHandler.SecondSeaPuzzle:Get("CurrentProgressLevel"), FunctionsHandler.SecondSeaPuzzle:Get("LastestRefreshSenque") 
        
        FunctionsHandler.SecondSeaPuzzle:Set("CurrentProgressLevel", nil)
        if not Progress then
            FunctionsHandler.SecondSeaPuzzle.Methods.Refresh:Call()
            return FunctionsHandler.SecondSeaPuzzle.Methods.Start:Call()
        elseif Progress == 1 then 
            SetTask("MainTask", "Auto Second Sea - Talk To Detective")
            TweenController.Create(CFrame.new(4848, 5.65, 743))
            task.wait(0.5)
            Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
            task.wait(0.5)
            Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
        elseif Progress == 2 then 
            SetTask("MainTask", "Auto Second Sea - Defeating Ice Admiral")
            TweenController.Create(CFrame.new(1348, 37, -1325))
            task.wait(0.5)
            Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
            task.wait(0.5)
            CombatController.Attack("Ice Admiral") 
            task.wait(1)
            Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
            task.wait(0.5)
            Remotes.CommF_:InvokeServer("TravelDressrosa")
        end 
    end)


    -- Bartilo 


    FunctionsHandler.ColosseumPuzzle:RegisterMethod("Refresh", function() 
        if SeaIndex ~= 2 then return end
        
        if (ScriptStorage.PlayerData.Level or 0) < 850 or ScriptStorage.Backpack["Warrior Helmet"] then return end  
        
        local Response = Remotes.CommF_:InvokeServer("BartiloQuestProgress")
        local Result = nil
        if not Response.KilledBandits then 
            Result = 1 
        elseif not Response.KilledSpring then 
            if ScriptStorage.Enemies.Jeremy or workspace.Enemies:FindFirstChild("Jeremy") then 
                Result = 2 
            end 
        elseif not Response.DidPlates then 
            Result = 3 
        end
        
        FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", Result)
        FunctionsHandler.ColosseumPuzzle:Set("LastestRefreshSenque", os.time()) 
        return Result 
    end) 

    FunctionsHandler.ColosseumPuzzle:RegisterMethod("Start", function() 
        local Progress, LastestRefreshSenque = FunctionsHandler.ColosseumPuzzle:Get("CurrentProgressLevel"), FunctionsHandler.ColosseumPuzzle:Get("LastestRefreshSenque") 
        FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", nil)
        if not Progress then
            FunctionsHandler.ColosseumPuzzle.Methods.Refresh:Call()
            return FunctionsHandler.ColosseumPuzzle.Methods.Start:Call()
        elseif Progress == 1 then 
            SetTask("MainTask", "Auto Bartilo Quest - Defeating 50x Swan Pirate")
            local CurrentQuest, RawText = QuestManager:GetCurrentClaimQuest() 
            
            if CurrentQuest then 
                if not string.find(RawText or "", "50") and not string.find(CurrentQuest or "", "Swan") then
                    QuestManager.AbandonQuest()
                else 
                    CombatController.Attack("Swan Pirate")
                end
            else 
                TweenController.Create(CFrame.new(-461.53, 72.35, 300.31))
                task.wait(0.5)
                Remotes.CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
            end 
            
            
        elseif Progress == 2 then 
            SetTask("MainTask", "Auto Bartilo Quest - Defeating Jeremy")
            CombatController.Attack("Jeremy")
        elseif Progress == 3 then 
            SetTask("MainTask", "Auto Bartilo Quest - Doing Puzzle")
            if CaculateDistance(CFrame.new(
            -1837.46155, 44.2921753, 1656.1987, 
            0.999881566, -1.03885048e-22, -0.0153914848,
            1.07805858e-22, 1, 2.53909284e-22,
            0.0153914848, -2.55538502e-22, 0.999881566
            )) > 10 then
        alert("tween to")
            TweenController.Create(
                CFrame.new(
                    -1837.46155, 44.2921753, 1656.1987, 
                    0.999881566, -1.03885048e-22, -0.0153914848,
                    1.07805858e-22, 1, 2.53909284e-22,
                    0.0153914848, -2.55538502e-22, 0.999881566
                )
            )            
        else
            LocalPlayer = game.Players.LocalPlayer
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1836, 11, 1714)
            alert("1")
            task.wait(.5)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1850.49329, 13.1789551, 1750.89685)
            alert("2")
            task.wait(1)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.87305, 19.3777466, 1712.01807)
            alert("3")
            task.wait(1)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1803.94324, 16.5789185, 1750.89685)
            task.wait(1)
            alert("4")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.55835, 16.8604317, 1724.79541)
            task.wait(1)
            alert("5")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1869.54224, 15.987854, 1681.00659)
            task.wait(1)
            alert("6")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1800.0979, 16.4978027, 1684.52368)
            task.wait(1)
            alert("7")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1819.26343, 14.795166, 1717.90625)
            task.wait(1)
            alert("8")
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1813.51843, 14.8604736, 1724.79541)
        end
        end
    end) 


    -- Race v2 

    FunctionsHandler.EvoRace:RegisterMethod("Refresh", function() 
        
        if not Config.Items.RaceV2 then return end 
        if SeaIndex ~= 2 then return end 
        if getsenv(game.ReplicatedStorage.GuideModule)._G.ServerData.ExpBoost ~= 0 or ScriptStorage.PlayerData.Level < 900 or ScriptStorage.PlayerData.Beli < 1000000 or ScriptStorage.PlayerData.RaceLevel ~= 1 then return end 
        return true 
    end) 

    FunctionsHandler.EvoRace:RegisterMethod("Start", function() 
        Remotes.CommF_:InvokeServer("Alchemist", "1")
        Remotes.CommF_:InvokeServer("Alchemist", "2")
        
        for i = 1,2,1 do 
            local Check1 = ScriptStorage.Tools["Flower " .. i]
            local Check2 = Services.Workspace:FindFirstChild("Flower" .. i) 
            
            
            if not Check1 then
            
                if Check2 and Check2.Transparency == 0 then 
                
                    SetTask("MainTask", "Auto Race V2 - Collecting Flower " .. i)
                    while not ScriptStorage.Tools["Flower " .. i] do 
                        task.wait() 
                        TweenController.Create(Check2.CFrame + Vector3.new(0, math.random(-1,2), 0)) 
                    end
                end
            end 
        end 
        
        if not ScriptStorage.Tools["Flower 3"] then 
            SetTask("MainTask", "Auto Race V2 - Collecting Flower " .. 3)
            CombatController.Attack("Swan Pirate")
            
        else 
            
            SetTask("MainTask", "Auto Race V2 - Idling")
            if LocalPlayer.Character.HumanoidRootPart.CFrame.Y < 50000 then 
                TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 50, 0)) 
            end 
            
            Remotes.CommF_:InvokeServer("Alchemist", "3")
            RefreshRace()
        end
    end) 

    -- Race V3 (Arowe / Wenlocktoad)
    FunctionsHandler.Wenlocktoad:RegisterMethod("Refresh", function()
        if SeaIndex ~= 2 then return end
        if (ScriptStorage.PlayerData.Level or 0) < 1000 then return end
        if (ScriptStorage.PlayerData.RaceLevel or 1) ~= 2 then return end
        local isAlreadyV3 = (Remotes.CommF_:InvokeServer("Wenlocktoad", "1") == -2)
        if isAlreadyV3 then return end
        return true
    end)

    FunctionsHandler.Wenlocktoad:RegisterMethod("Start", function()
        local arowePos = Vector3.new(-1988.88, 124.84, -70.87)
        local aroweCF = CFrame.new(arowePos)
        
        local function GetPhysicalFruit()
            local function isFruitTool(t)
                if not t or not t:IsA("Tool") then return false end
                local tip = t.ToolTip or ""
                local name = t.Name
                if tip == "Sword" or tip == "Melee" or tip == "Gun" or name == "Tool" or name == "Energy Core" or name:find("Key") or name:find("Flower") then
                    return false
                end
                return tip == "Blox Fruit" or name:find("-") or name:lower():find("fruit") or t:FindFirstChild("EatRemote") or t:FindFirstChild("Handle")
            end
            if LocalPlayer.Backpack then
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if isFruitTool(tool) then return tool end
                end
            end
            if LocalPlayer.Character then
                for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                    if isFruitTool(tool) then return tool end
                end
            end
            return nil
        end

        local fruitTool = GetPhysicalFruit()
        if not fruitTool then
            SetTask("MainTask", "Race V3 - Unstoring Fruit from Storage")
            
            -- Check stored fruits in backpack inventory first
            if ScriptStorage.Backpack then
                for fKey, fData in pairs(ScriptStorage.Backpack) do
                    if fData and fData.Type == "Blox Fruit" and fData.Count and fData.Count > 0 then
                        local rawName = fData.Name or fKey
                        table.insert(ScriptStorage.IgnoreStoreFruits, rawName)
                        pcall(function() Remotes.CommF_:InvokeServer("LoadFruit", rawName) end)
                        task.wait(0.2)
                        fruitTool = GetPhysicalFruit()
                        if fruitTool then break end
                    end
                end
            end

            -- Fallback: iterate standard low-tier fruits
            if not fruitTool then
                local fruitNames = {
                    "Rocket-Rocket", "Rocket", "Spin-Spin", "Spin", "Blade-Blade", "Blade", "Chop-Chop", "Chop",
                    "Spring-Spring", "Spring", "Bomb-Bomb", "Bomb", "Smoke-Smoke", "Smoke", "Spike-Spike", "Spike",
                    "Flame-Flame", "Flame", "Falcon-Falcon", "Falcon", "Ice-Ice", "Ice", "Sand-Sand", "Sand"
                }
                for _, fName in ipairs(fruitNames) do
                    table.insert(ScriptStorage.IgnoreStoreFruits, fName)
                    pcall(function() Remotes.CommF_:InvokeServer("LoadFruit", fName) end)
                    task.wait(0.05)
                    fruitTool = GetPhysicalFruit()
                    if fruitTool then break end
                end
            end

            if not fruitTool and (ScriptStorage.PlayerData.Beli or 0) >= 2400000 then
                SetTask("MainTask", "Race V3 - Rolling Fruit from Gacha")
                Remotes.CommF_:InvokeServer("Cousin", "Buy")
                task.wait(1)
                fruitTool = GetPhysicalFruit()
            end
        end

        if (ScriptStorage.PlayerData.Beli or 0) < 2000000 then
            SetTask("MainTask", "Race V3 - Farming Beli ($" .. tostring(ScriptStorage.PlayerData.Beli or 0) .. "/$2,000,000)")
            CombatController.Attack("Swan Pirate")
            return
        end

        if not fruitTool then
            SetTask("MainTask", "Race V3 - Need 1 Fruit (Farming Beli for Gacha)")
            CombatController.Attack("Swan Pirate")
            return
        end

        SetTask("MainTask", "Race V3 - Submitting Fruit to Arowe")
        if fruitTool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            pcall(function() LocalPlayer.Character.Humanoid:EquipTool(fruitTool) end)
        end

        TweenController.Create(aroweCF * CFrame.new(0, 0, 4))
        task.wait(0.5)

        fruitTool = GetPhysicalFruit()
        if fruitTool and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and fruitTool.Parent ~= LocalPlayer.Character then
            pcall(function() LocalPlayer.Character.Humanoid:EquipTool(fruitTool) end)
        end

        Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
        task.wait(0.2)
        Remotes.CommF_:InvokeServer("Wenlocktoad", "2")
        task.wait(0.2)
        Remotes.CommF_:InvokeServer("Wenlocktoad", "3")
        task.wait(0.2)
        Remotes.CommF_:InvokeServer("Wenlocktoad", "2")
        task.wait(0.5)
        RefreshRace()
    end)

    -- BossesTask 

    FunctionsHandler.BossesTask:RegisterMethod("Refresh", function() 
        local curClaim = QuestManager.GetCurrentClaimQuest and QuestManager.GetCurrentClaimQuest()
        if curClaim then
            for _, eliteName in ipairs({"Deandre", "Urban", "Diablo"}) do
                if tostring(curClaim):lower():find(eliteName:lower()) then
                    local Result = ScriptStorage.Enemies[eliteName]
                    if Result and Result:FindFirstChild("Humanoid") and Result.Humanoid.Health > 0 then 
                        return Result
                    end
                    return eliteName
                end
            end
        end

        local Boss
        for _, BossName in ipairs(BossesOrder or {}) do
            local LevelReq = BossesOrderLevel[BossName] or 0
            if ScriptStorage.PlayerData.Level >= LevelReq then
                local Result = ScriptStorage.Enemies[BossName] 
                if Result and Result:FindFirstChild("Humanoid") and Result.Humanoid.Health > 0 then 
                    Boss = Result 
                    break
                end 
            end 
        end
        
        if Boss then
            local bName = tostring(typeof(Boss) == "Instance" and Boss.Name or Boss)
            if BossesOrderWL[bName] or ScriptStorage.PlayerData.Level == MaxLevel then
                return Boss
            end
            local bHrp = typeof(Boss) == "Instance" and Boss:FindFirstChild("HumanoidRootPart")
            if bHrp and CaculateDistance(bHrp.CFrame) < (SeaIndex == 2 and 3000 or 5000) then
                return Boss
            end
        end
    end) 

    FunctionsHandler.BossesTask:RegisterMethod("Start", function(Boss) 
        if Boss then 
            local bossName = (typeof(Boss) == "Instance" and Boss.Name) or tostring(Boss)
            SetTask("MainTask", "Elite Hunter | Defeating " .. bossName)
            SetTask("SubTask", "Target: " .. bossName)
            CombatController.Attack(bossName, nil, nil, function() SpecialItems = nil end)
            SpecialItems = nil
        end 
    end) 


    FunctionsHandler.SpecialBossesTask:RegisterMethod("Refresh", function() 
    local Boss2
    
        for BossName, LevelReq in SpecialBossesOrder do
            if ScriptStorage.PlayerData.Level >= LevelReq then
                local Result = ScriptStorage.Enemies[BossName] 
                if Result and Result:FindFirstChild("Humanoid") and Result.Humanoid.Health > 0 then 
                
                    Boss2 = Result 
                end 
            end 
        end 
        return Boss2
    end) 

    FunctionsHandler.SpecialBossesTask:RegisterMethod("Start", function(Boss) 
        
        if FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then 
            pcall(function() 
                LocalPlayer.Character.Humanoid.Health = 0
            end) 
        end 
        
        if Boss then 
            
            SetTask("MainTask", "Auto Farm Boss - Defeating " .. Boss.Name)
            CombatController.Attack(tostring(Boss))
        end 
    end) 

    -- RaidController

    FunctionsHandler.RaidController:RegisterMethod("RefreshRaidType", function() 
        FunctionsHandler.RaidController:Set("CurrentChip", "Flame")
    end)

    local function IsProtectedFruit(fruitName)
        if not fruitName or fruitName == "" then return false end
        local rawLower = string.lower(tostring(fruitName))
        local cleanLower = rawLower:gsub("fruit", ""):gsub("%s+", ""):gsub("%-.*", "")
        if cleanLower == "" then return false end

        -- 1. Check current eaten / equipped Devil Fruit
        local currentEaten = (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.DevilFruit) 
            or (LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("DevilFruit") and LocalPlayer.Data.DevilFruit.Value) or ""
        if currentEaten ~= "" and currentEaten ~= "None" then
            local cleanEaten = string.lower(tostring(currentEaten)):gsub("fruit", ""):gsub("%s+", ""):gsub("%-.*", "")
            if cleanEaten ~= "" and cleanEaten ~= "none" then
                if cleanLower == cleanEaten or string.find(rawLower, cleanEaten, 1, true) or string.find(string.lower(tostring(currentEaten)), cleanLower, 1, true) then
                    return true
                end
            end
        end

        -- 2. Check Config.Fruit.Fruit protected sniper list
        if Config and Config.Fruit and Config.Fruit.Fruit then
            for _, protected in ipairs(Config.Fruit.Fruit) do
                local cleanProt = string.lower(tostring(protected)):gsub("fruit", ""):gsub("%s+", ""):gsub("%-.*", "")
                if cleanProt ~= "" then
                    if cleanLower == cleanProt or string.find(rawLower, cleanProt, 1, true) or string.find(string.lower(tostring(protected)), cleanLower, 1, true) then
                        return true
                    end
                end
            end
        end

        return false
    end

    local function GetPhysicalRaidFruit()
        local function isPhysicalFruitTool(t)
            if not t or not t:IsA("Tool") then return false end
            local tName = t.Name
            if tName == "Special Microchip" or tName == "Tool" or tName == "Energy Core" or tName:find("Slingshot") or tName:find("Slingshot") then
                return false
            end
            if t.ToolTip == "Sword" or t.ToolTip == "Melee" or t.ToolTip == "Gun" then
                return false
            end
            if IsProtectedFruit(tName) then
                return false
            end

            -- Physical fruit tool has EatRemote, or has ToolTip == "Blox Fruit", or has OriginalName attribute, or name ends with "Fruit"
            local hasEat = t:FindFirstChild("EatRemote") ~= nil
            local isFruitTip = t.ToolTip == "Blox Fruit"
            local hasOrig = t:GetAttribute("OriginalName") ~= nil
            local nameEndsFruit = string.sub(tName, -5) == "Fruit" or tName:find(" Fruit") ~= nil

            if hasEat or isFruitTip or hasOrig or nameEndsFruit then
                local lower = tName:lower()
                if lower:find("kitsune") or lower:find("dragon") or lower:find("leopard") or lower:find("dough") or lower:find("trex") or lower:find("t-rex") or lower:find("mammoth") or lower:find("spirit") or lower:find("venom") or lower:find("shadow") or lower:find("control") or lower:find("buddha") or lower:find("portal") or lower:find("sound") or lower:find("rumble") or lower:find("blizzard") or lower:find("pain") or lower:find("phoenix") or lower:find("spider") or lower:find("love") or lower:find("quake") or lower:find("gravity") or lower:find("gas") or lower:find("yeti") or lower:find("creation") then
                    return false
                end
                return true
            end
            return false
        end

        if LocalPlayer.Character then
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if isPhysicalFruitTool(tool) then return tool end
            end
        end
        if LocalPlayer.Backpack then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if isPhysicalFruitTool(tool) then return tool end
            end
        end
        return nil
    end

    local function GetStoredFruitUnder1M()
        local ok, IRS = pcall(function() return require(game:GetService("ReplicatedStorage").ItemReplicationService) end)
        local ok2, ItemConfig = pcall(function() return require(game:GetService("ReplicatedStorage").ItemConfig) end)
        local ok3, KEYS = pcall(function() return require(game:GetService("ReplicatedStorage").ItemReplicationService.KEYS) end)

        if ok and ok2 and ok3 and IRS and ItemConfig and KEYS then
            local candidates = {}
            for _, item in pairs(IRS:GetItems(KEYS.QUANTITY)) do
                local okMatch, data = pcall(function() return ItemConfig.match(item.ItemId):unwrap() end)
                if okMatch and data and data.Index and data.Index.IdType == "PhysicalMoveset" and item.Value and item.Value > 0 then
                    local key = data.Index.StorageKey or ""
                    local price = (data.Quality and data.Quality.MoneyPrice) or 0
                    local dName = (data.Display and data.Display.Name) or key
                    if not IsProtectedFruit(key) and not IsProtectedFruit(dName) then
                        if price > 0 and price < 1000000 then
                            table.insert(candidates, {
                                StorageKey = key,
                                Price = price,
                                Name = dName
                            })
                        end
                    end
                end
            end
            if #candidates > 0 then
                table.sort(candidates, function(a, b) return a.Price < b.Price end)
                return candidates[1]
            end
        end

        -- Fallback to ScriptStorage.Backpack
        if ScriptStorage.Backpack then
            local candidates = {}
            for fKey, fData in pairs(ScriptStorage.Backpack) do
                if fData and (fData.Type == "Blox Fruit" or fKey:find("-")) then
                    local fName = fData.Name or fKey
                    local price = fData.Value or 0
                    if not IsProtectedFruit(fName) and (fData.Count or 1) > 0 and price > 0 and price < 1000000 then
                        table.insert(candidates, {
                            StorageKey = fName,
                            Price = price,
                            Name = fName
                        })
                    end
                end
            end
            if #candidates > 0 then
                table.sort(candidates, function(a, b) return a.Price < b.Price end)
                return candidates[1]
            end
        end

        return nil
    end

    FunctionsHandler.RaidController:RegisterMethod("GetRaidableFruit", function()
        local phys = GetPhysicalRaidFruit()
        if phys then return { Name = phys.Name, StorageKey = phys.Name, Price = 5000 } end
        return GetStoredFruitUnder1M()
    end)

    FunctionsHandler.RaidController:RegisterMethod("GetCurrentRaidIsland", function() 
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        
        local IslandsList = {{}, {}, {}, {}, {}} 
        local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
        if not locs then return nil end
        
        for _, Island in ipairs(locs:GetChildren()) do 
            if string.find(Island.Name, "Island ") and (Island.Position - Vector3.new(0,0,0)).Magnitude > 7000 then 
                local IslandIndex = tonumber(string.gsub(Island.Name, "Island ", ""))
                if IslandIndex and IslandsList[IslandIndex] then
                    table.insert(IslandsList[IslandIndex], Island)
                end
            end 
        end
        
        for Index = 5, 1, -1 do 
            for _, Island in ipairs(IslandsList[Index]) do 
                if (Island.Position - myRoot.Position).Magnitude < 2000 then 
                    return Island
                end 
            end 
        end 
        return nil
    end)

    function CheckSpecialMicrochip() 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Special Microchip") then
            return LocalPlayer.Character["Special Microchip"]
        end
        if LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Special Microchip") then
            return LocalPlayer.Backpack["Special Microchip"]
        end
        return nil
    end 

    local function GetRaidPodPos()
        if SeaIndex == 2 then
            return CFrame.new(-6520.12, 317.19, -4654.33)
        elseif SeaIndex == 3 then
            return CFrame.new(-5045, 314, -3181)
        end
        return nil
    end

    local function PressRaidStartButton()
        pcall(function()
            local btn = nil
            if SeaIndex == 2 then
                local cIsland = (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("CircleIsland")) or workspace:FindFirstChild("CircleIsland")
                btn = cIsland and cIsland:FindFirstChild("RaidSummon2") and cIsland.RaidSummon2:FindFirstChild("Button") and cIsland.RaidSummon2.Button:FindFirstChild("Main")
            elseif SeaIndex == 3 then
                local bCastle = (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Boat Castle")) or workspace:FindFirstChild("Boat Castle")
                btn = bCastle and bCastle:FindFirstChild("RaidSummon2") and bCastle.RaidSummon2:FindFirstChild("Button") and bCastle.RaidSummon2.Button:FindFirstChild("Main")
            end

            if not btn then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "RaidSummon2" or obj.Name == "RaidSummon" then
                        local b = obj:FindFirstChild("Button") and obj.Button:FindFirstChild("Main")
                        if b then
                            btn = b
                            break
                        end
                    end
                end
            end

            if btn then
                if btn:FindFirstChild("ClickDetector") and fireclickdetector then
                    fireclickdetector(btn.ClickDetector)
                elseif btn:FindFirstChild("ProximityPrompt") and fireproximityprompt then
                    fireproximityprompt(btn.ProximityPrompt)
                end
            end
        end)
    end

    FunctionsHandler.RaidController:RegisterMethod("Refresh", function() 
        local Level = ScriptStorage.PlayerData.Level or 0
        if Level < 1100 or SeaIndex == 1 then return false end
        
        -- 1. If currently inside a Raid island, ALWAYS run RaidController!
        local inRaidIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
        if inRaidIsland then 
            return { InRaid = true, Island = inRaidIsland }
        end
        
        -- 2. If holding Special Microchip, run RaidController to enter pod!
        local hasChip = CheckSpecialMicrochip()
        if hasChip then 
            return { HasChip = true, Chip = hasChip }
        end
        
        -- 3. Check fragments & AutoRaid setting
        if Config and Config.Items and Config.Items.AutoRaid == false then return false end
        
        local frags = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Fragments) or 0
        local targetFrags = (Config and Config.Items and Config.Items.TargetFragments) or 5000
        if frags >= targetFrags and not (Config and Config.Items and Config.Items.ForceRaid) then
            return false
        end
        
        -- 4. Check if player has physical fruit or stored fruit < 1M to exchange
        local hasPhysicalFruit = GetPhysicalRaidFruit()
        local storedFruit = GetStoredFruitUnder1M()
        
        if hasPhysicalFruit or storedFruit then
            return { NeedBuy = true, Stored = storedFruit, Physical = hasPhysicalFruit }
        end
        
        return false
    end)

    FunctionsHandler.RaidController:RegisterMethod("Start", function(RaidData)
        FunctionsHandler.RaidController:Set("CurrentChip", "Flame")
        local chipName = "Flame"
        local CurrentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() 
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        -- 1. INSIDE RAID ISLANDS
        if CurrentIsland then 
            SetTask("MainTask", "Auto Raid - Island " .. tostring(CurrentIsland.Name) .. " / 5")
            local raidMobs = {}
            local enemiesFolder = workspace:FindFirstChild("Enemies")
            if enemiesFolder then
                for _, mob in ipairs(enemiesFolder:GetChildren()) do
                    local mHum = mob:FindFirstChildOfClass("Humanoid")
                    local mHrp = mob:FindFirstChild("HumanoidRootPart")
                    if mHum and mHrp and mHum.Health > 0 and (mHrp.Position - CurrentIsland.Position).Magnitude < 1200 then
                        table.insert(raidMobs, mob)
                    end
                end
            end

            if #raidMobs > 0 then
                table.sort(raidMobs, function(a, b)
                    local aHrp = a:FindFirstChild("HumanoidRootPart")
                    local bHrp = b:FindFirstChild("HumanoidRootPart")
                    if aHrp and bHrp then
                        return (aHrp.Position - myRoot.Position).Magnitude < (bHrp.Position - myRoot.Position).Magnitude
                    end
                    return false
                end)
                SetTask("SubTask", "Defeating " .. tostring(raidMobs[1].Name) .. " (Remaining: " .. #raidMobs .. ")")
                CombatController.Attack(raidMobs[1].Name)
            else
                SetTask("SubTask", "Island Cleared - Flying to Center")
                TweenController.Create(CurrentIsland.CFrame * CFrame.new(0, 35, 0))
            end
            return
        end

        -- 2. OUTSIDE RAID - CHECK / BUY CHIP
        local microchip = CheckSpecialMicrochip()
        if not microchip then
            local physFruit = GetPhysicalRaidFruit()

            if not physFruit then
                -- Wait for Character to be alive before un-storing fruit
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") or char.Humanoid.Health <= 0 then
                    return
                end

                -- Step A: Unstore best fruit under 1M from ItemReplicationService
                local bestFruit = GetStoredFruitUnder1M()
                if bestFruit then
                    SetTask("MainTask", "Auto Raid - Unstoring " .. tostring(bestFruit.Name) .. " ($" .. tostring(bestFruit.Price) .. ")")
                    table.insert(ScriptStorage.IgnoreStoreFruits, bestFruit.StorageKey)
                    table.insert(ScriptStorage.IgnoreStoreFruits, bestFruit.Name)
                    table.insert(ScriptStorage.IgnoreStoreFruits, bestFruit.Name .. " Fruit")
                    table.insert(ScriptStorage.IgnoreStoreFruits, bestFruit.StorageKey:gsub("%-.*", ""))
                    
                    pcall(function() Remotes.CommF_:InvokeServer("LoadFruit", bestFruit.StorageKey) end)
                    task.wait(0.4)
                    physFruit = GetPhysicalRaidFruit()
                end

                -- Step B: Fallback search if needed
                if not physFruit then
                    local cheapKeys = {
                        "Rocket-Rocket", "Spin-Spin", "Blade-Blade", "Chop-Chop",
                        "Spring-Spring", "Bomb-Bomb", "Smoke-Smoke", "Spike-Spike",
                        "Flame-Flame", "Falcon-Falcon", "Ice-Ice", "Sand-Sand",
                        "Dark-Dark", "Diamond-Diamond", "Light-Light", "Rubber-Rubber",
                        "Barrier-Barrier", "Ghost-Ghost", "Magma-Magma"
                    }
                    for _, sKey in ipairs(cheapKeys) do
                        if not IsProtectedFruit(sKey) then
                            table.insert(ScriptStorage.IgnoreStoreFruits, sKey)
                            table.insert(ScriptStorage.IgnoreStoreFruits, sKey:gsub("%-.*", ""))
                            table.insert(ScriptStorage.IgnoreStoreFruits, sKey:gsub("%-.*", "") .. " Fruit")
                            pcall(function() Remotes.CommF_:InvokeServer("LoadFruit", sKey) end)
                            task.wait(0.15)
                            physFruit = GetPhysicalRaidFruit()
                            if physFruit then break end
                        end
                    end
                end
            end

            -- Step C: Equip fruit to hand so RaidsNpc detects it
            if physFruit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                pcall(function() LocalPlayer.Character.Humanoid:EquipTool(physFruit) end)
                task.wait(0.3)
            end

            -- Step D: Purchase Flame Chip from RaidsNpc
            SetTask("MainTask", "Auto Raid - Buying Flame Chip")
            pcall(function()
                Remotes.CommF_:InvokeServer("RaidsNpc", "Select", "Flame")
            end)
            task.wait(0.5)
            microchip = CheckSpecialMicrochip()
        end

        -- 3. ENTER RAID POD & START (ONLY IF WE ACTUALLY HAVE MICROCHIP)
        if microchip then
            local podCF = GetRaidPodPos()
            if podCF then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and microchip.Parent ~= LocalPlayer.Character then
                    pcall(function() LocalPlayer.Character.Humanoid:EquipTool(microchip) end)
                end

                local distToPod = (podCF.Position - myRoot.Position).Magnitude
                if distToPod > 15 then
                    SetTask("MainTask", "Auto Raid - Entering Raid Pod (" .. math.floor(distToPod) .. "m)")
                    TweenController.Create(podCF)
                else
                    SetTask("MainTask", "Auto Raid - Starting " .. chipName .. " Raid")
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and microchip.Parent ~= LocalPlayer.Character then
                        pcall(function() LocalPlayer.Character.Humanoid:EquipTool(microchip) end)
                    end
                    PressRaidStartButton()
                    task.wait(0.5)
                end
            end
        end
    end)

    -- CollectDrops

    FunctionsHandler.CollectDrops:RegisterMethod('Refresh', function() 
        
        local FruitNames = {} 
        
        for i in ScriptStorage.Backpack do 
            FruitNames[FruitIdToName(i)] = i
        end
        
        for _, Fruit in workspace:GetChildren() do 
            if string.find(Fruit.Name, "Fruit") and not Players:FindFirstChild(Fruit.Name) and Fruit:FindFirstChild("Handle") and not FruitNames[tostring(Fruit)] and not ScriptStorage.Backpack[FruitNameToId(tostring(Fruit))] then 
                
                FunctionsHandler.CollectDrops:Set("CurrentProgressLevel", Fruit) 
                return Fruit
            end 
        end
        
    end)

    FunctionsHandler.CollectDrops:RegisterMethod('Start', function() 
        local Fruit = FunctionsHandler.CollectDrops:Get("CurrentProgressLevel")
        FunctionsHandler.CollectDrops:Set("CurrentProgressLevel", nil) 
        if Fruit then 
            SetTask("MainTask", "Auto Collect Drop Items - " .. tostring(Fruit)) 
            TweenController.Create(Fruit:GetModelCFrame()) 
        end 
    end)

    FunctionsHandler.UtillyItemsActivitation:RegisterMethod("Refresh", function()
        if os.time() - StartTime < 20 then return end 
        if not SpecialItems then 
            SpecialItems = {} 
            local RemoveList = {} 
            IceAdmiralPassed = true 
            
            if not ScriptStorage.Backpack.Rengoku then 
                table.insert(SpecialItems, "Hidden Key") 
                IceAdmiralPassed = false
            end 
            if SeaIndex == 2 and Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor") then
                table.insert(SpecialItems, "Library Key") 
                IceAdmiralPassed = false 
            end

            if IceAdmiralPassed then 
                table.insert(RemoveList, "Awakened Ice Admiral") 
            end 
            local Response = not ScriptStorage.Melees["Sharkman Karate"] and Remotes.CommF_:InvokeServer("BuySharkmanKarate", true); 
            SharkmanPassed = typeof(Response) == "string"
            if typeof(Response) == "string" then
                table.insert(SpecialItems, "Water Key") 
            else 
                TidePassed = true
                table.insert(RemoveList, "Tide Keeper")
            end 
            if ScriptStorage.Backpack.Yama then 
                table.insert(RemoveList, "Deandre")
                table.insert(RemoveList, "Urban")
                table.insert(RemoveList, "Diablo")
            end 
            local function GetResult() 
                local Result = {} 
                for _, Value in BossesOrder do
                    local Passed = true 
                    for _, Name2 in RemoveList do
                        if Name2 == Value then 
                            Passed = false
                        end 
                    end 
                    if Passed then 
                        table.insert(Result, Value)
                    end 
                end
                
                local n = #Result
                for i = 1, n - 1 do
                    for j = 1, n - i do
                        local a = tostring(Result[j]):lower()
                        local b = tostring(Result[j + 1]):lower()
                        if a > b then
                            Result[j], Result[j + 1] = Result[j + 1], Result[j]
                        end
                    end
                end
                return Result
            end
            BossesOrder = GetResult()
            
            for ItemName, ItemData in DropItemData do 
                if not ScriptStorage.Backpack[ItemName] and SeaIndex == ItemData.Sea then
                    if ScriptStorage.PlayerData.Level >= ItemData.Level then 
                        BossesOrderLevel[ItemData.Boss] =  ItemData.Level
                        table.insert(BossesOrder, ItemData.Boss)
                    end 
                end 
            end 
            if FunctionsHandler.Trevor:Get("IsCompleted") and not Storage:Get("SwanDefeated") then
                BossesOrderLevel["Don Swan"] = 1100 
                table.insert(BossesOrder, "Don Swan")
                if SeaIndex == 2 and ScriptStorage.PlayerData.Level > 1500 and not ScriptStorage.Enemies["Don Swan"] then 
                    Hop("Hop for don swan")
                end 
            end 
        end
        for Index, Value in SpecialItems do 
            if ScriptStorage.Tools[Value] then 
                FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", Value)
                return Value 
            end 
        end 
        if SeaIndex == 3 and ( ScriptStorage.Melees["Death Step"] or 0 ) >= 400 and ( ScriptStorage.Melees["Black Leg"] or 0 ) >= 400 and ScriptStorage.PlayerData.Beli >= 2500000 and ScriptStorage.PlayerData.Fragments >= 5000 and not ScriptStorage.Melees["Electric Claw"] then 
            FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Previous Hero")
            return "Previous Hero"
        end 
        if ScriptStorage.Tools["Red Key"] then 
            FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Red Key")
            return "Red Key"
        end 
        if ScriptStorage.Tools["Hallow Essence"] then 
            FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Soul Reaper Spawner")
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Fire Essence")
            return "Soul Reaper Spawner"
        end 
        if ScriptStorage.Tools["Fire Essence"] then 
            FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Uzoth")
            return "Uzoth"
        end 
    end)

    FunctionsHandler.UtillyItemsActivitation:RegisterMethod("Start", function() 
        
        local Type = FunctionsHandler.UtillyItemsActivitation:Get("CurrentProgressLevel")
        if Type == "Hidden Key" then 
            Remotes.CommF_:InvokeServer("OpenRengoku")
        elseif Type == "Water Key" then 
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Water Key")
            Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
            Remotes.CommF_:InvokeServer("BuySharkmanKarate")
        elseif Type == "Library Key" then 
            Remotes.CommF_:InvokeServer("OpenLibrary")Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor"):Destroy()
        elseif Type == "Red Key" then 
            alert("Red key", "Sumbitting red key to the scienctist.")
            Remotes.CommF_:InvokeServer("CakeScientist", "Check")
            ScriptStorage.Tools["Red Key"]:Destroy()
        elseif Type == "Previous Hero" then 
            Remotes.CommF_:InvokeServer("BuyElectricClaw", "Start")
            task.wait(3)
            repeat
                task.wait()
                TweenController.Create(CFrame.new(-12548, 332.378 + math.random(-2, 2), -7617))
            until CaculateDistance(CFrame.new(-12548, 332.378, -7617)) < 30
            
            Remotes.CommF_:InvokeServer("BuyElectricClaw")
            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
        elseif Type == "Uzoth" then 
            
            -- silenced print
            Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
            Remotes.CommF_:InvokeServer("BuyDragonTalon")
            IsFireEssenceGave = true 
            Report('Fire Essence Used')
            
        elseif Type == "Soul Reaper Spawner" then 
            
            -- silenced print
            
            if CaculateDistance(workspace.Map["Haunted Castle"].Summoner.Detection.CFrame) < 100 then 
                SpecialItems = nil
            end 
            
            TweenController.Create(workspace.Map["Haunted Castle"].Summoner.Detection.CFrame)
        
        end
        
    end)

    -- Trevor 

    FunctionsHandler.Trevor:RegisterMethod("GetFruit", function() 
        for _, Fruit in ScriptStorage.Backpack do
            if string.find(FruitIdToName(Fruit.Name), " Fruit") then 
                if Fruit.Value and Fruit.Value > 1000000 then 
                
                    return Fruit
                end 
            end 
        end 
    end) 

    FunctionsHandler.Trevor:RegisterMethod("Refresh", function() 
        if FunctionsHandler.Trevor:Get("IsCompleted")  or os.time() - StartTime < 1 then return end 
        
        if ScriptStorage.PlayerData.Level < 1100 then return end 
        

        local Fruit = FunctionsHandler.Trevor.Methods.GetFruit:Call()
        
        if Fruit then 
            
            FunctionsHandler.Trevor:Set("Fruit", Fruit)
        end
        
        TrevorDebounce = os.time() 
        

        if not FunctionsHandler.Trevor:Get("IsCompleted") then
            -- silenced print
            FunctionsHandler.Trevor:Set("IsCompleted", ((Remotes.CommF_:InvokeServer("TalkTrevor", "1") == 0))) 
            -- silenced print, Remotes.CommF_:InvokeServer("TalkTrevor", "1"), Remotes.CommF_:InvokeServer("TalkTrevor", "1") == 0 )
        end
        
        return not FunctionsHandler.Trevor:Get("IsCompleted") and Fruit
    end) 

    FunctionsHandler.Trevor:RegisterMethod("Start", function() 
        
        alert("[ Cyndral ]", "Pulling fruit for trevor...")
        local Fruit = FunctionsHandler.Trevor:Get("Fruit") 
        FunctionsHandler.Trevor:Set("Fruit", nil) 
        table.insert(ScriptStorage.IgnoreStoreFruits, Fruit.Name) 
        Remotes.CommF_:InvokeServer("LoadFruit", Fruit.Name)
        task.wait()
        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(Fruit.Name))
        
        Remotes.CommF_:InvokeServer("TalkTrevor", "1")

        Remotes.CommF_:InvokeServer("TalkTrevor", "2")

        Remotes.CommF_:InvokeServer("TalkTrevor", "3")
        
        task.wait(1)
        FunctionsHandler.Trevor:Set("IsCompleted", true) 
    end)

    -- silenced print
    -- Third Sea Puzzle 
    FunctionsHandler.ThirdSeaPuzzle:RegisterMethod("Refresh", function() 
        
        if ScriptStorage.PlayerData.Level < 1500 or SeaIndex ~= 2 then
            return 
        end 
        
        
        
        if nil == FunctionsHandler.ThirdSeaPuzzle:Get("State") then 
            
            ZQuestProgress = Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")
            -- silenced print
            FunctionsHandler.ThirdSeaPuzzle:Set("State", ZQuestProgress == 0)
        end  
        
        return FunctionsHandler.ThirdSeaPuzzle:Get("State")
    end) 

    FunctionsHandler.ThirdSeaPuzzle:RegisterMethod("Start", function() 
        local State = FunctionsHandler.ThirdSeaPuzzle:Get("State") 
        if State then 
            SetTask("MainTask", "Third Sea Puzzle - Defeating rip_indra")
            pcall(function()
                Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")
                Remotes.CommF_:InvokeServer("ZQuestProgress", "Begin")
            end)
            
            if ScriptStorage.Enemies["rip_indra"] or workspace.Enemies:FindFirstChild("rip_indra") then
                CombatController.Attack("rip_indra")
            else
                TweenController.Create(CFrame.new(-1448.9, 7.3, -2784.8))
                task.wait(1)
                CombatController.Attack("rip_indra")
            end
            
            local res = Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")
            if res == 1 or res == -1 or res == 2 then
                SetTask("MainTask", "Traveling to Third Sea (Zou)...")
                Remotes.CommF_:InvokeServer("TravelZou")
            end
        end 
    end)


    FunctionsHandler.Yama:RegisterMethod("Refresh", function() 
        if SeaIndex ~= 3 then return end 
        
        local hasYama = false
        if ScriptStorage.Backpack and ScriptStorage.Backpack["Yama"] then hasYama = true end
        if LocalPlayer.Backpack:FindFirstChild("Yama") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Yama")) then hasYama = true end
        if hasYama then return end 
        
        if not FunctionsHandler.Yama:Get("EliteCount") then 
            local ok, count = pcall(function() return Remotes.CommF_:InvokeServer("EliteHunter", "Progress") end)
            if ok and type(count) == "number" then
                FunctionsHandler.Yama:Set("EliteCount", count)
            end
        end 
        
        if (FunctionsHandler.Yama:Get("EliteCount") or 0) >= 30 then 
            return true
        end 
    end)

    FunctionsHandler.Yama:RegisterMethod("Start", function() 
        SetTask("MainTask", "Yama Quest | Pulling Sealed Katana...")
        local targetCF = CFrame.new(5228.9, 10.3, 1073.4)
        
        local start = os.time()
        while (os.time() - start < 15) do
            TweenController.Create(targetCF)
            if CaculateDistance(targetCF) < 20 then
                break
            end
            task.wait()
        end
        
        local waterfall = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Waterfall")
        local sealed = (waterfall and waterfall:FindFirstChild("SealedKatana")) or workspace:FindFirstChild("SealedKatana", true)
        if sealed and sealed:FindFirstChild("Hitbox") and sealed.Hitbox:FindFirstChild("ClickDetector") then
            for i = 1, 4 do
                fireclickdetector(sealed.Hitbox.ClickDetector)
                task.wait(0.3)
            end
        end
    end)

    FunctionsHandler.PirateRaid:RegisterMethod("Refresh", function() 
        local Senque = FunctionsHandler.PirateRaid:Get("Senque") 
        
        return Senque and os.time() - Senque < 500
    end)

    FunctionsHandler.PirateRaid:RegisterMethod("Start", function() 
        local NearestMon = GetMonAsSortedRange()
        
        local SeaCastlePosition = Vector3.new(-5543.5327148438, 313.80062866211, -2964.2585449219) 
        
        if NearestMon[1] then 
            local MonHumanoid, MonHumanoidRootPart = NearestMon[1]:FindFirstChild("Humanoid"), NearestMon[1]:FindFirstChild("HumanoidRootPart")
            
            if MonHumanoidRootPart and MonHumanoid and MonHumanoid.Health > 0 and CaculateDistance(MonHumanoidRootPart.CFrame, SeaCastlePosition) < 500 then 
                CombatController.Attack(NearestMon[1].Name)
                return 
            end
        end 
        
        TweenController.Create(SeaCastlePosition)
    end)

    -- Soul guitar 

    function CheckFullMoon(NightForce)

        if Lighting.Sky.MoonTextureId ~= "http://www.roblox.com/asset/?id=9709149431" then

            return
        elseif NightForce then
            return true
        end
        return Lighting.ClockTime > 18 or Lighting.ClockTime < 5
    end

    FunctionsHandler.SoulGuitar:RegisterMethod("Refresh", function() 
        
        if not Config.Items.SoulGuitar then return end 
        
        if ScriptStorage.Backpack["Skull Guitar"] or not ScriptStorage.Backpack["Dark Fragment"] then 
            return 
        end 
        
        
        if ScriptStorage.PlayerData.Level < 2300 then return end 
        
        local EctoplasmCount = ( ScriptStorage.Backpack["Ectoplasm"] or { Count = 0 } )["Count"] 
        local BonesCount = ( ScriptStorage.Backpack["Bones"] or { Count = 0 } )["Count"] 
        
        if EctoplasmCount < 250 then 
            return 1 
        end 
        
        if SeaIndex ~= 3 then 
            return 
        end 
        
        SoulGuitarProcess = Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Check")
        
        if not SoulGuitarProcess then  
        Remotes.CommF_:InvokeServer("gravestoneEvent", 2)
            if not CheckFullMoon() then 
                SetTask("MainTask", "Hopping for full moon ( soul guitar )")
                Hop("Full Moon / SG")
            end 
            return 7
        end 
        
        if not SoulGuitarProcess.Swamp then 
            return 2 
        elseif not SoulGuitarProcess.Gravestones then 
            return 3 
        elseif not SoulGuitarProcess.Ghost then 
            return 4 
        elseif not SoulGuitarProcess.Trophies then 
            return 5 
        elseif not SoulGuitarProcess.Pipes then 
            return 6
        elseif BonesCount >= 500 and not ScriptStorage.Backpack["Skull Guitar"] then 
            return 8
        end 
    end) 

    FunctionsHandler.SoulGuitar:RegisterMethod("Start", function(State) 
        if State == 7 then 
            while CaculateDistance(CFrame.new(-8654, 140, 6167)) > 5 do

                task.wait()

                TweenController.Create(CFrame.new(-8654, 140, 6167))
            end
            SoulGuitarProcess = Remotes.CommF_:InvokeServer("gravestoneEvent", 2, true)
        elseif State == 1 then 
            if SeaIndex ~= 2 then 
                SetTask("MainTask", "Teleport to second sea to farm ectoplasm")
                return Remotes.CommF_:InvokeServer("TravelDressrosa")
            else 
                SetTask("MainTask", "Farming ectoplasms for soul guitar")
                CombatController.Attack({"Ship Deckhand","Ship Engineer", "Ship Steward","Ship Officer"})
                return
            end 
        elseif State == 2 then 
            
            TTL9 = TTL9 or 0 
            if os.time() ~= LastestTime1 then
                TTL9 = TTL9 + 1 
                LastestTime1 = os.time() 
            end 
            
            if TTL9 > 60 then 
                return Hop("LOMGGGGGGGG SG 1")
            end
            
            local Objects = {} 
            
            for _, Entity in Services.Workspace.Enemies:GetChildren() do 
                if Entity.name == "Living Zombie" then 
                    table.insert(Objects, Entity)
                end 
            end 
            
            if #Objects < 6 then 
                SetTask('MainTask', "Soul Guitar task 1 / 5: waiting until entity spawn") 
                TweenController.Create(ScriptStorage.MobRegions["Living Zombie"][1] + Vector3.new(0,30,0))
                
            else 
                
                local StartTime19 = os.time()
                for Idx, Object in Objects do 
                    while task.wait() and Object.Humanoid.Health > 7000 do
                        SetTask('MainTask', "Soul Guitar task 1 / 5: Hit mob " .. Idx .. " / 6" ) 
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                        if os.time() - StartTime19 > 60 then 
                            Hop("So long nerds")
                        end 
                        
                        TweenController.Create(Object.HumanoidRootPart.CFrame + Vector3.new(0,50,0)) 
                        AttackController:Attack() 
                    end 
                end
                SetTask('MainTask', "Soul Guitar task 1 / 5: Attack") 
                while workspace.Enemies:FindFirstChild("Living Zombie") and task.wait() do 
                    if os.time() - StartTime19 > 60 then 
                            Hop("So long nerds")
                        end 
                        
                    CombatController.Attack("Living Zombie")
                end 
            end 
        elseif State == 3 then 
            local HauntedIsland = workspace.Map["Haunted Castle"] 
            while CaculateDistance(CFrame.new(-8800, 178, 6033)) > 10 do
                task.wait()
                SetTask("MainTask", "Soul Guitar task 2 / 5: completing placards")
                TweenController.Create(CFrame.new(-8800, 178, 6033))
            end
            
            for Placard, Side in {

                Placard1 = "Right",

                Placard2 = "Right",
                Placard3 = "Left",
                Placard4 = "Right",
                Placard5 = "Left",
                Placard6 = "Left",
                Placard7 = "Left"
            } do
                fireclickdetector(HauntedIsland[Placard][Side].ClickDetector)
            end
        elseif State == 4 then 
            Remotes.CommF_:InvokeServer( "GuitarPuzzleProgress", "Ghost")
        elseif State == 5 then 
            if CaculateDistance(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375)) > 30 then
                TweenController.Create(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375))
            else
                local DepTraiv4 = workspace.Map["Haunted Castle"].Tablet
                for i, v in pairs(BlankTablets) do
                    local x = DepTraiv4[v]
                    if x.Line.Rotation.Z ~= 0 then
                        repeat
                            task.wait()
                            fireclickdetector(x.ClickDetector)
                        until x.Line.Rotation.Z == 0
                    end
                end
                for i, v in pairs(Trophy) do
                    local x = workspace.Map["Haunted Castle"].Trophies.Quest[v].Handle.CFrame
                    x = tostring(x)
                    x = x:split(", ")[4]
                    local c = "180"
                    if x == "1" or x == "-1" then
                        c = "90"
                    end
                    if not string.find(tostring(DepTraiv4[i].Line.Rotation.Z), c) then
                        repeat
                            task.wait()
                            fireclickdetector(DepTraiv4[i].ClickDetector)
                        until string.find(tostring(DepTraiv4[i].Line.Rotation.Z), c)
                    end
                end
            end
        elseif State == 6 then 
            for i, v in pairs(Pipes) do

                pcall(

                    function()
                        local x = workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model[i]
                        if x.BrickColor.Name ~= v then
                            repeat
                                task.wait()
                                fireclickdetector(x.ClickDetector)
                            until x.BrickColor.Name == v
                        end
                    end
                )
            end
            Remotes.CommF_:InvokeServer("soulGuitarBuy")
        elseif State == 8 then 
            Remotes.CommF_:InvokeServer("soulGuitarBuy")
            
        end
    end)

    FunctionsHandler.Tushita:RegisterMethod("Refresh", function() 
        if ScriptStorage.Backpack.Tushita then return end 
        
        
        if ScriptStorage.PlayerData.Level < 2000 then return end 
        
        if SeaIndex ~= 3 then return end 
        
        
        TushitaProgress = TushitaProgress or Remotes.CommF_:InvokeServer("TushitaProgress")
        
        if not TushitaProgress.OpenedDoor then 
            
            if ScriptStorage.Enemies["rip_indra True Form"] then 
                TushitaProgress = nil
                return 1
            end 
        else
            if ScriptStorage.Enemies["Longma"] then 
                TushitaProgress = nil
                return 2 
            end 
        end
        
    end)

    FunctionsHandler.Tushita:RegisterMethod("Start", function(State) 
        if State == 1 then
            alert("Auto Tushita", "Placing torches...")
            if not ScriptStorage.Tools["Holy Torch"] then
                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Holy Torch")
                TweenController.Create(CFrame.new(5714, math.random(19,21), 256)) -- Portal position
                return
            end 
            
            local TurtleMap = workspace.Map.Turtle.QuestTorches
            
            for TorchIndex = 1, 5, 1 do

                if TurtleMap:FindFirstChild("Torch" .. TorchIndex) then

                    repeat
                        task.wait()
                        TweenController.Create(TurtleMap:FindFirstChild("Torch" .. TorchIndex).CFrame)
                    until TurtleMap:FindFirstChild("Torch" .. TorchIndex).Particles.Main.Enabled
                end
            end
        
        elseif State == 2 then 
            alert("Auto Tushita", "Defeating Longma")
            CombatController.Attack("Longma")
        end 
    end)



    FunctionsHandler.CursedDualKatana:RegisterMethod("Refresh", function() 
        
        
        if not Config.Items.CursedDualKatana then return end 
        local Backpack = ScriptStorage.Backpack
        
        if ScriptStorage.PlayerData.Level < 2200 then return end
        if Backpack["Cursed Dual Katana"] 
        or not Backpack.Tushita 
        or Backpack.Tushita.Mastery < 350
        or not Backpack.Yama 
        or Backpack.Yama.Mastery < 350
        then
            return
        end 
        
        
        if SeaIndex ~= 3 then 
            return
        end 
        
        
        local CdkProgess = CdkProgess or Remotes.CommF_:InvokeServer("CDKQuest", "Progress") or "uwu"
        
        if not CdkProgess or CdkProgess == "uwu" then return end 
        
        if workspace.Map.Turtle.Cursed:FindFirstChild("Breakable") then

            alert("Cursed Dual Katana", "Open Door")

            
            return { "break" }
        end
        
        local ScrollSides = {
            Good = "Tushita", 
            Evil = "Yama"
        }
        
        if CdkProgess.Good == 4 and CdkProgess.Evil == 4 then 
            -- silenced print
            return { "burn 2" } 
        end 
        
        if CdkProgess.Good == 3 or CdkProgess.Evil == 3 then 
            -- silenced print
            return { "burn" } 
        end 
        
        
        if CdkProgess.Opened then 
            for Index, Value in CdkProgess do
                if Index ~= "Opened" and Index ~= "Finished" and Value < 3 then 
                    -- silenced print
                    ScriptStorage.CdkCache = {
                        Index, 
                        Value + 1
                    }
                    
                    if not ScriptStorage.Tools[ScrollSides[Index]] then 
                        Remotes.CommF_:InvokeServer("LoadItem", ScrollSides[Index])
                    end 
                    
                    alert(
                        "Cursed Dual Katana",
                        "Start " ..
                            tostring(ScrollSides[Index]) ..
                                " " .. tostring(Index)
                    )
                    Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", Index)
                    SetTask("MainTask", "Cursed Dual Katana - " .. tostring(ScrollSides[Index]) ..
                                " " .. tostring(Index)
                    )
                    return false 
                end 
            end
        end 
        
        local CachedValue = ScriptStorage.CdkCache 
        
        
        if not CachedValue then return end 
        
        local Name, Level = CachedValue[1], CachedValue[2] 
        
        if Name == "Evil" and Level == 3 then 
            if not ScriptStorage.Enemies["Soul Reaper"] then 
                ForceToRollBone = true
                return
            end 
        elseif Name == "Good" then 
            if Level == 2 then 
                SetTask("SubTask", "CDK Quest / Waiting until pirate raid started")
                return 
            elseif Level == 3 and not ScriptStorage.Enemies["Cake Queen"] then 
                Hop("Cake Queen Find")
                SetTask("SubTask", "CDK Quest / Waiting until Cake Queen boss spawned") 
                return 
            end 
        end
        return CachedValue
    end)

    FunctionsHandler.CursedDualKatana:RegisterMethod("GetHazeMon", function() 
        
        local Positions = {} 
        for _, Inst in LocalPlayer.QuestHaze:GetChildren() do 
            if Inst.Value > 0 then 
                table.insert(Positions, Inst) 
            end 
        end 
        table.sort(Positions, function(C1, C2) return CaculateDistance(C1:GetAttribute("Position")) < CaculateDistance(C2:GetAttribute("Position")) end) 
        return tostring(Positions[1])
    end)

    FunctionsHandler.CursedDualKatana:RegisterMethod("DoDimension", function(DimensionName)  
        local DimensionId = string.gsub(DimensionName, " ", "") 
        
        local VaiCaNgu1234 = os.time()
        repeat task.wait()
            TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame)
            if os.time() - VaiCaNgu1234 > 60 then 
                return 
            end 
        until os.time() - TorchEnabledTime < 10 
        
        repeat task.wait() 
            local OriginalIsland = workspace.Map:WaitForChild(DimensionId, 10)
            if OriginalIsland then 
                
                for _, Torch in OriginalIsland:GetChildren() do 
                    if Torch and string.find(Torch.Name, "Torch") and Torch:FindFirstChild("ProximityPrompt") and Torch.ProximityPrompt.Enabled then 
                        LocalPlayer.Character.HumanoidRootPart.CFrame = Torch.CFrame 
                        
                        Torch.ProximityPrompt.HoldDuration = 0
                        task.wait(1)
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendKeyEvent(true, "E", 0, game)    -- e vã lắm r T_T
                        vim:SendKeyEvent(false, "E", 0, game)    -- e vã lắm r T_T
                    
                        
                        fireproximityprompt(workspace.Map:WaitForChild(DimensionId, 10):FindFirstChild(tostring(Torch)).ProximityPrompt) 
                    
                    end 
                    for _, Mon in workspace.Enemies:GetChildren() do 
                        local MonHumanoidRootPart = Mon:FindFirstChild("HumanoidRootPart") 
                        local MonHumanoid = Mon:FindFirstChild("Humanoid") 
                        
                        if MonHumanoidRootPart and MonHumanoid and CaculateDistance(MonHumanoidRootPart.CFrame) < 1000 then 
                            
                            CombatController.Attack(Mon.Name)
                        end 
                    end
                end 
                ExitDoor = OriginalIsland:FindFirstChild("Exit") 
                -- silenced print
                if ExitDoor then 
                    PortalBrick = tostring(ExitDoor.BrickColor)
                    -- silenced print
                end 
            else 
                -- silenced print
            end
            -- silenced print
        until PortalBrick == "Olivine" or PortalBrick == "Cloudy grey" 
        -- silenced print
        while os.time() - DoneCdkTick > 15 do 
            TweenController.Create(ExitDoor.CFrame + Vector3.new(0, math.random(1,5), 0)) 
            task.wait() 
        end 
        
        Hop("Rejoin")
    end) 

    FunctionsHandler.CursedDualKatana:RegisterMethod("Start", function(CachedData) 
        local CursedTemple = workspace.Map.Turtle.Cursed
        if CachedData[1] == "break" then 
            TweenController.Create(workspace.Map.Turtle.Cursed.Breakable.CFrame)
            Remotes.CommF_:InvokeServer("CDKQuest", "OpenDoor")
            Remotes.CommF_:InvokeServer("CDKQuest", "OpenDoor", true)
            workspace.Map.Turtle.Cursed.Breakable:Destroy()
            CdkProgess = nil  
            return 
        end 
        if CachedData[1] == "burn 2" then
            if workspace.Map.Turtle.Cursed.Pedestal3.ProximityPrompt.Enabled then 
                fireproximityprompt(workspace.Map.Turtle.Cursed.Pedestal3.ProximityPrompt)
                task.wait(1) 
                pcall(function() 
                    LocalPlayer.Character.Humanoid.Health = 0
                end)
                task.wait(10)
            else
                CDKAttempts = ( CDKAttempts or 0 ) + 1
                TweenController.Create(CFrame.new(-12341.66796875, 603.3455810546875, -6550.6064453125)) 
                task.wait(5) 
                
                pcall(function() 
                    LocalPlayer.Character.Humanoid.Health = 0
                end)
                task.wait(5)
                if CDKAttempts > 5 then 
                    Hop("CDK Stuck")
                end
                
                CdkProgess = nil  
            end
        elseif CachedData[1] == "burn" then 
            for Index = 1, 3, 1 do
                local Pedestal = workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. Index) 
                
                if workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. Index) .ProximityPrompt.Enabled then 
                    repeat task.wait() 
                        TweenController.Create(workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. Index) .CFrame) 
                    until CaculateDistance(workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. Index) .CFrame) < 5
                    
                    fireproximityprompt(workspace.Map.Turtle.Cursed:FindFirstChild("Pedestal" .. Index) .ProximityPrompt) -- địt mẹ delta
                    task.wait(3) 
                    pcall(function() 
                        LocalPlayer.Character.Humanoid.Health = 0
                    end) 
                end 
                CdkProgess = nil  
            end 
            
        elseif CachedData[1] == "Evil" then 
            if CachedData[2] == 1 then 
                local Mob = ScriptStorage.Enemies["Forest Pirate"] 
                
                TweenController.Create((Mob and Mob.HumanoidRootPart.CFrame) or ScriptStorage.MobRegions["Forest Pirate"][0])
                CdkProgess = nil  
            elseif CachedData[2] == 2 then 
                CombatController.Attack(FunctionsHandler.CursedDualKatana.Methods.GetHazeMon:Call())
                CdkProgess = nil  
            elseif CachedData[2] == 3 then 
                Report("found cdk yama 3")
                while not ( os.time() - TorchEnabledTime < 100 or not ScriptStorage.Enemies["Soul Reaper"] )  do
                    -- silenced print
                    task.wait()
                                
                    if FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then 
                        pcall(function() 
                            LocalPlayer.Character.Humanoid.Health = 0
                        end) 
                    end 
                    
                    TweenController.Create(ScriptStorage.Enemies["Soul Reaper"]:GetModelCFrame())
                end  
                if not ScriptStorage.Enemies["Soul Reaper"] then return end
                FunctionsHandler.CursedDualKatana.Methods.DoDimension.Callback("Hell Dimension")
                CdkProgess = nil  
            end 
        else
            if CachedData[2] == 1 then 
                for _, NPC in game.ReplicatedStorage.NPCs:GetChildren() do 
                    if NPC.Name == "Luxury Boat Dealer" then 
                        repeat task.wait() 
                            if os.time() - DoneCdkTick < 15 then return end
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (NPC:GetModelCFrame()) 
                            RealNPC = nil
                            for _, npc in workspace.NPCs:GetChildren() do 
                                if CaculateDistance(npc:GetModelCFrame(), NPC:GetModelCFrame()) < 20 then 
                                    RealNPC = npc 
                                    break
                                end 
                            end 
                        until CaculateDistance(NPC:GetModelCFrame()) < 5 and RealNPC 
                        
                        Remotes.CommF_:InvokeServer("CDKQuest", "BoatQuest", RealNPC) 
                    end
                end
                CdkProgess = nil  
            elseif CachedData[2] == 3 then 
                repeat task.wait() 
                    -- silenced print
                    CombatController.Attack("Cake Queen")
                until os.time() - TorchEnabledTime < 10 or not ScriptStorage.Enemies["Cake Queen"]
                
                TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame)
                Report("Cake Queen")
                FunctionsHandler.CursedDualKatana.Methods.DoDimension.Callback("Heavenly Dimension")
                CdkProgess = nil  
            end 
        end
    end)

    local Hooks = {
        Listeners = {}
    } 

    TorchEnabledTime = 0 
    DoneCdkTick = 0 

    getgenv().NotificationCallBack = (function(Content)
        for ListenerContent, Callback in Hooks.Listeners do
            if string.find(string.lower(Content), string.lower(ListenerContent)) then 
                Callback(Content)
            end 
        end 
    end) 

    function Hooks:RegisterNotifyListener(Senque, Callback)
        Hooks.Listeners[Senque] = Callback
    end 
        
    Hooks:RegisterNotifyListener("go!", function() 
        LastRaidAlert = os.time()
    end) 
    Hooks:RegisterNotifyListener("oadi", function() 
        LastRaidAlert2 = os.time()
    end) 

    Hooks:RegisterNotifyListener("been spotted approaching", function() 
        FunctionsHandler.PirateRaid:Set("Senque", os.time())
    end) 

    Hooks:RegisterNotifyListener("job", function() 
        FunctionsHandler.PirateRaid:Set("Senque", 0)
    end) 

    Hooks:RegisterNotifyListener("level", function() 
        AddPoint() 
    end) 

    Hooks:RegisterNotifyListener("torch", function() 
        TorchEnabledTime = os.time()
    end) 

    Hooks:RegisterNotifyListener("scroll reacts", function() 
        DoneCdkTick = os.time()
    end) 

    Hooks:RegisterNotifyListener("elite", function() 
        FunctionsHandler.Yama:Set("EliteCount", Remotes.CommF_:InvokeServer("EliteHunter", "Progress"))
        
        alert("[ Bocchi Hub ] ", "Elite defeated: ".. tostring(FunctionsHandler.Yama:Get("EliteCount") or "n/a"))
    end) 

    Hooks:RegisterNotifyListener("the raid with", function() 
        if ScriptStorage.PlayerData.Level < MaxLevel then return end 
        Remotes.CommF_:InvokeServer("Awakener", "Awaken")
    end) 


    Hooks:RegisterNotifyListener("quest completed", function() 
        QuestManager:RefreshQuest()
        task.wait()
        if not  QuestManager:GetCurrentClaimQuest() then 
            
            QuestManager:MarkAsCompleted()
        end 
    end) 

        
    local old;

    old = hookfunction(
        require(game.ReplicatedStorage.Notification).new,
        function(a, b)
            
            v21 = tostring(tostring(a or "") .. tostring(b or "")) or ""
            
            getgenv().NotificationCallBack(v21)
            
            return old(a, b)
        end
    ) 


    --LogService.MessageOut:Connect(onMessageOut)


    --[[
    local fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()

    Window = fluent:CreateWindow{
        Title = "Cyndral | Blox Fruit",
        SubTitle = "Kaitun Version",
        TabWidth = 160,
        Size = UDim2.fromOffset(830, 525),
        Resize = true, 
        MinSize = Vector2.new(470, 380),
        Acrylic = false, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl 
    }


    Tabs = {}
    local RawTabs = {
        {
            Title = "Home", 
            Icon = "building"
        },
        {
            Title = "Debug", 
            Icon = "concierge-bell"
        }
    }


    for _, Tab in RawTabs do 
        -- silenced print
        Tabs[Tab.Title] = Window:CreateTab(Tab)
    end 

    Tabs.Home:CreateParagraph("Aligned Paragraph", {
        Title = "Cyndral | BF Kaitun",
        ContentAlignment = Enum.TextXAlignment.Center
    })]]

    local isHopping = false
    local visitedServers = {}
    visitedServers[game.JobId] = true

    local function DoTeleport(jobId)
        if not jobId or jobId == "" or jobId == game.JobId then return false end
        SetTask("MainTask", "Hopping Server: " .. tostring(jobId):sub(1, 8) .. "...")
        
        -- 1. Try __ServerBrowser remote
        local ok1 = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser", 5):InvokeServer("teleport", jobId)
        end)
        if ok1 then task.wait(2) end

        -- 2. Fallback to TeleportService
        local ok2 = pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, game.Players.LocalPlayer)
        end)
        
        return ok1 or ok2
    end

    function Hop(MaxPlayers, ForcedRegion)
        if isHopping then return end
        isHopping = true

        task.spawn(function()
            local targetMax = (type(MaxPlayers) == "number" and MaxPlayers) or 10

            -- Strategy 1: Fetch via Roblox Public Server API
            local successApi, serverList = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
                local raw = game:HttpGet(url)
                local json = game:GetService("HttpService"):JSONDecode(raw)
                return json and json.data
            end)

            if successApi and type(serverList) == "table" and #serverList > 0 then
                -- Shuffle
                for i = #serverList, 2, -1 do
                    local j = math.random(i)
                    serverList[i], serverList[j] = serverList[j], serverList[i]
                end

                for _, srv in ipairs(serverList) do
                    local jId = srv.id
                    local playing = tonumber(srv.playing) or 0
                    local maxP = tonumber(srv.maxPlayers) or 12
                    if jId and jId ~= game.JobId and not visitedServers[jId] and playing < maxP and playing <= targetMax then
                        visitedServers[jId] = true
                        DoTeleport(jId)
                        task.wait(4)
                    end
                end
            end

            -- Strategy 2: Fetch via Blox Fruits __ServerBrowser
            local successBrowser, browserList = pcall(function()
                local found = {}
                for i = 1, 10 do
                    local data = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser", 5):InvokeServer(i)
                    if data and type(data) == "table" then
                        for k, v in pairs(data) do
                            if k ~= game.JobId and not visitedServers[k] then
                                local pCount = (type(v) == "table" and v.Count) or 0
                                local reg = (type(v) == "table" and v.Region) or ""
                                if pCount <= targetMax and (not ForcedRegion or reg == ForcedRegion) then
                                    table.insert(found, k)
                                end
                            end
                        end
                        if #found > 0 then return found end
                    end
                    task.wait(0.1)
                end
                return found
            end)

            if successBrowser and type(browserList) == "table" and #browserList > 0 then
                for _, jId in ipairs(browserList) do
                    visitedServers[jId] = true
                    DoTeleport(jId)
                    task.wait(4)
                end
            end

            -- Strategy 3: Standard Teleport fallback
            pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)

            isHopping = false
        end)
    end

    function HopServer(_, p27, p28)
        return Hop(p27, p28)
    end

    LowHop = function(Reason, PlayerLimit)
        return Hop(PlayerLimit or 5)
    end

    pcall(function()
        game:GetService("TeleportService").TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
            warn("[Teleport Error] " .. tostring(errorMessage) .. " - Retrying Hop...")
            isHopping = false
            task.wait(2)
            Hop(10)
        end)
    end)

    pcall(function()
        local GuiService = game:GetService("GuiService")
        GuiService.ErrorMessageChanged:Connect(function()
            if GuiService:GetErrorType() == Enum.ConnectionError.DisconnectErrors then
                warn("[Disconnected] Auto Reconnecting...")
                isHopping = false
                Hop(10)
            end
        end)
    end) 


    Storage = {
        WRITE_DELAY = 5, 
        Data = {}, 
    } 

    Services = {}

    setmetatable(Services, {
        __index = function(_, Index)
            return game:GetService(Index)
        end
    });

    LocalPlayer = game.Players.LocalPlayer

    local StoragePath = ".storage_u_" .. tostring(LocalPlayer) 

    function Decode(Content) 
        return Services.HttpService:JSONDecode(Content) 
    end 

    function Encode(Content) 
        return Services.HttpService:JSONEncode(Content)  
    end 

    -- silenced print
    function Storage.Set(Self, Key, Value) 
        Self.Data[Key] = Value
    end 

    function Storage.Get(Self, Key) 
        --Report("Get: " .. tostring(Key or "n/a") .. " Value: " .. tostring(Self.Data[Key] or "n/") )
        return Self.Data[Key] 
    end 

    function Storage.Save(Self) 
        writefile(StoragePath, Encode(Self.Data)) 
    end 

    if not isfile(StoragePath) then 
        writefile(StoragePath, "{}")
        task.wait(1)
    end 

    --Report(readfile(StoragePath))
    Storage.Data = Decode(readfile(StoragePath) or "{}")  

    spawn(function() 
        while task.wait(Storage.WRITE_DELAY) do 
            Storage:Save() 
        end 
    end)
        pcall(function()
            local mainGui = game.Players.LocalPlayer:WaitForChild("PlayerGui", 3)
            local fastBtn = mainGui and mainGui:FindFirstChild("Main") and mainGui.Main:FindFirstChild("HUDButtonBar") and mainGui.Main.HUDButtonBar:FindFirstChild("Settings") and mainGui.Main.HUDButtonBar.Settings:FindFirstChild("Buttons") and mainGui.Main.HUDButtonBar.Settings.Buttons:FindFirstChild("FastModeButton")
            if fastBtn and getconnections then
                for _, Connection in getconnections(fastBtn.Activated) do
                    Connection.Function()
                end
            end
        end)
        
        local LogCache = {}
        SetTask("MainTask", "Starting Tasks...")
        SetTask("SubTask", "Auto Farm Progression")
        ParsingTimes = 100
        function RefreshTasksData()
            if _G.Stop then
                return
            end
            for _, TaskName in ipairs(TasksOrder) do
                local Task = FunctionsHandler[TaskName]
                if Task and Task.Initalized then
                    local Refresh = Task.Methods.Refresh
                    local Start = Task.Methods.Start
        
                    if Refresh and Start then
                        local okRef, RefreshValue = pcall(function() return Refresh:Call(ParsingTimes < 100) end)
                        if okRef and RefreshValue then
                            ParsingTimes = ParsingTimes + 1
                            CurrentTask = TaskName
                            local okStart, startErr = pcall(function()
                                Start:Call(RefreshValue)
                            end)
                            if not okStart then
                                warn("[Task Error in " .. tostring(TaskName) .. "] " .. tostring(startErr))
                            end
                            return
                        end
                    end
                end
            end
        end
        
        SetText("MainTextLabel", "Refreshing Player Items...")
        pcall(AddPoint)
        pcall(function() QuestManager:RefreshQuest() end)
        pcall(RefreshInventory)
        pcall(function()
            Remotes.CommE.OnClientEvent:Connect(function(...)
                local data = {...}
                if data and data[1] and string.find(tostring(data[1]), "Item") then
                    pcall(RefreshInventory)
                end
            end)
        end)
        pcall(RefreshRace)
        pcall(function()
            Players.LocalPlayer.Idled:Connect(function()
                pcall(function()
                    Services.VirtualUser:CaptureController()
                    Services.VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        end)
        SetText("MainTextLabel", "Loaded In " .. tick() - StartTick .. "ms!")
        
        QueueList = {}
        
        function NearbyHopHandler()
            if true then
                return
            end
            if NearbyHopHandlerDebounce and os.time() - NearbyHopHandlerDebounce < 10 then
                return
            end
        
            NearbyHopHandlerDebounce = os.time()
        
            for _, Player in Players:GetPlayers() do
                local Position = Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and
                                    Player.Character.HumanoidRootPart.Position
                if Position then
                    local NearbyRange = QueueList[Player.Name]
                    if not NearbyRange then
                        QueueList[Player.Name] = os.time()
                    else
                        if os.time() - NearbyRange > 30 then
                            if CaculateDistance(Position) < 100 then
                                Hop("Nearby plr");
                                task.wait(5)
        
                            else
                                QueueList[Player.Name] = nil
                            end
                        end
                    end
                end
            end
        end
        
        
        task.spawn(function()
            while task.wait() do
                if not _G.Stop then
                     if SeaIndex == 1 and #game.Players:GetPlayers() > 9 then 
                        while task.wait() do 
                            -- silenced print
                            Hop(9)
                            break -- toi bi ngu, toi biet
                        end 
                    end
                    NearbyHopHandler()
                    if LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Sit then
                        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
        
                    if RefreshDebounce ~= os.time() then
                        pcall(RefreshPlayerData)

                        if not MeleeRefreshDebounce or os.time() - MeleeRefreshDebounce > 30 then
                            MeleeRefreshDebounce = os.time()
                            FunctionsHandler.MeleesController.Methods.Start:Call()
                        end

                        local Elapsed = os.time() - StartTime
                        local TotalElapsed = Elapsed + OldSessionTime
        
                        writefile(".tdif-" .. game.Players.LocalPlayer.Name, tostring(TotalElapsed))
        
                        if ScriptStorage.Interface then
                            SetText("LiveTime", "Total Elapsed Time: " .. DispTime(TotalElapsed, true) .. " Elapsed Time: " ..
                                DispTime(Elapsed, true))
                        end
                        RefreshDebounce = os.time()
                    end
                end
            end
        end)
        
        pcall(AddPoint)
        -- pcall(function() Remotes.CommF_:InvokeServer("Cousin", "Buy") end) -- Disabled auto random fruit
        
        task.spawn(function()
            while task.wait(Config.Configuration.AutoHopDelay or 3600) do
                if Config.Configuration.AutoHop and not _G.Stop then
                    SetTask("MainTask", "AutoHop Timer Triggered - Hopping Server...")
                    Hop("AutoHop Delay")
                end
            end
        end)
        while task.wait() do
            --[[
            if not SendDataDelay or os.time() - SendDataDelay > Config.Authorize.SendDelay then 
                SendDataDelay = os.time() 
                pcall(SendData)
            end ]]
        
            if Config.Configuration.HopWhenIdle and LastIdling and os.time() - LastIdling > 600 then
                SetTask("MainTask", "Rejoining due to idle in 10 min!")
                task.wait(1)
                for i=1, 6, 1 do
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                    task.wait(5)
                end
                task.wait(1) -- Chờ 1 giây rồi tiếp tục vòng lặp chính
            end
        
            if not AnimationDelay or os.time() - AnimationDelay > 60 then
                AnimationDelay = os.time()
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid')
                    if hum and Animation then
                        hum:LoadAnimation(Animation):Play()
                    end
                end)
            end
            local success, response = xpcall(RefreshTasksData, debug.traceback)
            if not success then
                warn("[Main Loop Error] " .. tostring(response))
            end
        end
    end 

    local success2, response2 = xpcall(mmb, debug.traceback)
    if not success2 then
        print("FULL ERROR: ".. tostring(response2))
        --Report(response2)
    end
--end)()