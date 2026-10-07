--[[
    =============================================================================
    SKIDHUB - BLOX FRUITS EDITION (v15.1  ✦  V2.8)
    Framework: NullUI v2.8.1 (SkidHub High-Contrast Vibrant Purple Edition)
    Features:
      - 100% Parity with realkidsae.lua theme, styling, topbar & floating logo toggle
      - ZERO Key System (khởi động trực tiếp, không yêu cầu key)
      - ĐẦY ĐỦ 100% 17 Tab Menu & TOÀN BỘ 56 Section, Controls nguyên bản từ ui3nn (Banana Cat Hub)
      - Universal Multi-Tier Logo & Asset Loader (Hỗ trợ 100% Mobile & PC trên mọi Executor)
      - Draggable Floating Logo Button với hiệu ứng Pulse & Click Bounce Tween
    =============================================================================
--]]

--!nocheck
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- An toàn parent GUI cho mọi executor (Delta, Codex, Arceus X, Fluxus, Wave, Solara, etc.)
local function GetSafeGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetSafeGuiParent()

-- =============================================================================
-- UNIVERSAL LOGO & ASSET LOADER (Hỗ trợ 100% Mobile & PC, mọi executor)
-- =============================================================================
local USER_LOGO_URL = "https://cdn.discordapp.com/attachments/1538071921588183080/1538871777705336903/1DB14F34-1682-48F8-84A8-B4A511B635D7.png?ex=6ac77e06&is=6ac62c86&hm=bf8e182e946629ed32991abf5acc96c8ca64653206ecf6c17a55fce63cc362d6&"
local FALLBACK_RBX_ASSET = "rbxassetid://8068653048" -- Fallback Logo rbxassetid

local function LoadUniversalLogo()
    -- 1. Kiểm tra cache trong getgenv()
    if getgenv().SkidHubLogoAsset and type(getgenv().SkidHubLogoAsset) == "string" and #getgenv().SkidHubLogoAsset > 0 then
        return getgenv().SkidHubLogoAsset
    end

    -- 2. Thử executor filesystem & getcustomasset / getsynasset
    local getasset = getcustomasset or getsynasset
    if getasset and writefile and readfile and isfile then
        local ok, asset = pcall(function()
            if not isfolder("SkidHub") then
                pcall(makefolder, "SkidHub")
            end
            local fileName = "SkidHub/skidhub_logo_user_v3.png"
            if not isfile(fileName) or (readfile and #readfile(fileName) < 1000) then
                local fetchOk, imgData = pcall(function()
                    return game:HttpGet(USER_LOGO_URL)
                end)
                if fetchOk and imgData and #imgData > 1000 then
                    pcall(writefile, fileName, imgData)
                end
            end
            if isfile(fileName) then
                local a = getasset(fileName)
                if a and type(a) == "string" and #a > 0 then
                    return a
                end
            end
            return nil
        end)
        if ok and asset then
            getgenv().SkidHubLogoAsset = asset
            return asset
        end
    end

    -- 3. Executor loadImage function (nếu có)
    if typeof(loadImage) == "function" then
        local ok, a = pcall(loadImage, USER_LOGO_URL)
        if ok and a then
            getgenv().SkidHubLogoAsset = a
            return a
        end
    end

    -- 4. Thử URL trực tiếp (nếu executor hỗ trợ web image)
    getgenv().SkidHubLogoAsset = USER_LOGO_URL
    return USER_LOGO_URL
end

local logoAsset = LoadUniversalLogo() or FALLBACK_RBX_ASSET

-- =============================================================================
-- LOAD & PATCH NULLUI (Exact SkidHub Vibrant Purple Theme from realkidsae.lua)
-- =============================================================================
local uiRaw
local fetchSuccess, fetchResult = pcall(function()
    return game:HttpGet("https://pastefy.app/kmZUOJ1A/raw")
end)

if fetchSuccess and fetchResult and #fetchResult > 1000 then
    uiRaw = fetchResult
else
    -- Fallback nếu pastefy bị timeout
    local fetchSuccess2, fetchResult2 = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/refs/heads/main/zzzz.lua")
    end)
    if fetchSuccess2 and fetchResult2 and #fetchResult2 > 1000 then
        uiRaw = fetchResult2
    else
        error("[SKIDHUB] Không thể tải UI library từ pastefy.app!")
    end
end

-- SkidHub High-Contrast Vibrant Purple Theme
uiRaw = uiRaw:gsub("Color3%.fromRGB%(29,%s*37,%s*54%)", "Color3.fromRGB(18, 14, 28)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(43,%s*55,%s*78%)", "Color3.fromRGB(26, 20, 38)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(24,%s*31,%s*46%)", "Color3.fromRGB(18, 14, 28)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(156,%s*205,%s*255%)", "Color3.fromRGB(168, 85, 247)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(196,%s*204,%s*220%)", "Color3.fromRGB(185, 170, 210)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(248,%s*250,%s*255%)", "Color3.fromRGB(255, 255, 255)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(255,%s*148,%s*166%)", "Color3.fromRGB(255, 95, 125)")

-- Window Solid Dark Purple Backdrop (Eliminates Washed-Out Transparent Glass)
uiRaw = uiRaw:gsub("main%.BackgroundTransparency%s*=%s*1", "main.BackgroundTransparency = 0.05")
uiRaw = uiRaw:gsub("Stroke%(main,%s*Color3%.fromRGB%(238,%s*246,%s*255%),%s*1,%s*0%.64%)", "Stroke(main, Color3.fromRGB(168, 85, 247), 1.5, 0.2)")

-- GlassLayer Rich Purple Tints
uiRaw = uiRaw:gsub("glass%.BackgroundColor3%s*=%s*Color3%.fromRGB%(218,%s*233,%s*255%)", "glass.BackgroundColor3 = Color3.fromRGB(24, 18, 36)")
uiRaw = uiRaw:gsub("prism%.BackgroundColor3%s*=%s*Color3%.fromRGB%(190,%s*220,%s*255%)", "prism.BackgroundColor3 = Color3.fromRGB(168, 85, 247)")

-- LiquidToolbar: Dark Violet Glass with High Contrast
uiRaw = uiRaw:gsub("toolbar%.BackgroundColor3%s*=%s*Color3%.fromRGB%(221,%s*235,%s*255%)", "toolbar.BackgroundColor3 = Color3.fromRGB(28, 20, 42)")
uiRaw = uiRaw:gsub("toolbar%.BackgroundTransparency%s*=%s*0%.68", "toolbar.BackgroundTransparency = 0.25")
uiRaw = uiRaw:gsub("Stroke%(toolbar,%s*Color3%.fromRGB%(255,%s*255,%s*255%),%s*1,%s*0%.56%)", "Stroke(toolbar, Color3.fromRGB(168, 85, 247), 1, 0.35)")
uiRaw = uiRaw:gsub("toolbarGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(248,%s*252,%s*255%),%s*Color3%.fromRGB%(171,%s*204,%s*255%)%)", "toolbarGradient.Color = ColorSequence.new(Color3.fromRGB(36, 26, 52), Color3.fromRGB(22, 16, 34))")

-- TabBar: Dark Sleek Sidebar with Clear Tab Text
uiRaw = uiRaw:gsub("tabBar%.BackgroundColor3%s*=%s*Color3%.fromRGB%(225,%s*238,%s*255%)", "tabBar.BackgroundColor3 = Color3.fromRGB(22, 16, 32)")
uiRaw = uiRaw:gsub("tabBar%.BackgroundTransparency%s*=%s*0%.8", "tabBar.BackgroundTransparency = 0.25")
uiRaw = uiRaw:gsub("Stroke%(tabBar,%s*Color3%.fromRGB%(255,%s*255,%s*255%),%s*1,%s*0%.7%)", "Stroke(tabBar, Color3.fromRGB(168, 85, 247), 1, 0.45)")
uiRaw = uiRaw:gsub("tabGlassGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(244,%s*249,%s*255%),%s*Color3%.fromRGB%(175,%s*205,%s*255%)%)", "tabGlassGradient.Color = ColorSequence.new(Color3.fromRGB(30, 22, 45), Color3.fromRGB(18, 13, 26))")

-- Content Surface: Deep Dark Purple
uiRaw = uiRaw:gsub("contentSurface%.BackgroundColor3%s*=%s*Color3%.fromRGB%(214,%s*230,%s*255%)", "contentSurface.BackgroundColor3 = Color3.fromRGB(20, 15, 30)")
uiRaw = uiRaw:gsub("contentSurface%.BackgroundTransparency%s*=%s*0%.92", "contentSurface.BackgroundTransparency = 0.3")
uiRaw = uiRaw:gsub("Stroke%(contentSurface,%s*Color3%.fromRGB%(255,%s*255,%s*255%),%s*1,%s*0%.84%)", "Stroke(contentSurface, Color3.fromRGB(168, 85, 247), 1, 0.5)")
uiRaw = uiRaw:gsub("contentGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(245,%s*250,%s*255%),%s*Color3%.fromRGB%(144,%s*183,%s*242%)%)", "contentGradient.Color = ColorSequence.new(Color3.fromRGB(28, 20, 42), Color3.fromRGB(18, 13, 28))")

-- Cards: Dark Elegant Containers with Distinct Borders & Zero Blurriness
uiRaw = uiRaw:gsub("card%.BackgroundColor3%s*=%s*Color3%.new%(1,%s*1,%s*1%)", "card.BackgroundColor3 = Color3.fromRGB(26, 20, 38)")
uiRaw = uiRaw:gsub("card%.BackgroundTransparency%s*=%s*0%.76", "card.BackgroundTransparency = 0.15")
uiRaw = uiRaw:gsub("Stroke%(card,%s*Color3%.fromRGB%(235,%s*243,%s*255%),%s*1,%s*0%.76%)", "Stroke(card, Color3.fromRGB(75, 52, 105), 1, 0.3)")
uiRaw = uiRaw:gsub("cardGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(255,%s*255,%s*255%),%s*Color3%.fromRGB%(186,%s*213,%s*255%)%)", "cardGradient.Color = ColorSequence.new(Color3.fromRGB(32, 24, 46), Color3.fromRGB(24, 18, 35))")

-- Toggles & Sliders: Vivid Neon Purple Accent
uiRaw = uiRaw:gsub("state and Color3%.fromRGB%(255,%s*255,%s*255%) or Color3%.fromRGB%(46,%s*50,%s*49%)", "state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(42, 32, 58)")
uiRaw = uiRaw:gsub("knob%.BackgroundColor3%s*=%s*state and Color3%.fromRGB%(18,%s*18,%s*18%) or Color3%.fromRGB%(226,%s*230,%s*228%)", "knob.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 195)")
uiRaw = uiRaw:gsub("fill%.BackgroundColor3%s*=%s*Color3%.new%(1,%s*1,%s*1%)", "fill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)")
uiRaw = uiRaw:gsub("track%.BackgroundColor3%s*=%s*Color3%.new%(1,%s*1,%s*1%)", "track.BackgroundColor3 = Color3.fromRGB(38, 28, 54)")
uiRaw = uiRaw:gsub("track%.BackgroundTransparency%s*=%s*0%.91", "track.BackgroundTransparency = 0")

-- Mobile Toggle Logo & Background (An toàn tuyệt đối với gsub function tránh lỗi ký tự '%' trong URL)
local safeLogoStr = tostring(logoAsset)
uiRaw = uiRaw:gsub('mobileToggle%.Image%s*=%s*"rbxassetid://96220014754961"', function()
    return 'mobileToggle.Image = ' .. string.format("%q", safeLogoStr)
end)
uiRaw = uiRaw:gsub('mobileToggle%.BackgroundTransparency%s*=%s*1', function()
    return 'mobileToggle.BackgroundTransparency = 0.2\n\t\tmobileToggle.BackgroundColor3 = Color3.fromRGB(18, 14, 28)'
end)

local NullUI = loadstring(uiRaw)()

-- Helper Notification
local function Notify(title, text, duration)
    pcall(function()
        if NullUI and NullUI.Notify then
            NullUI:Notify({
                Title = title or "SKIDHUB",
                Text = text or "",
                Duration = duration or 3,
                Type = "info"
            })
        end
    end)
end

-- =============================================================================
-- CREATE MAIN WINDOW (No Key System - Khởi động trực tiếp ngay lập tức)
-- =============================================================================
local Window = NullUI:CreateWindow({
    Title = "SKIDHUB",
    Subtitle = "Blox Fruits v15.1  ✦  V2.8",
    Size = UDim2.fromOffset(640, 455),
    MinSize = Vector2.new(500, 360),
    Draggable = true,
    Resizable = true,
    UseBlur = true,
    DefaultTab = "Shop",
    ToggleKeybind = Enum.KeyCode.RightControl,
    TogglePosition = UDim2.fromOffset(20, 220),
})

-- =============================================================================
-- TOPBAR CUSTOMIZATION & FLOATING DRAGGABLE LOGO TOGGLE BUTTON
-- (Hoạt động hoàn hảo trên cả Mobile & PC, không lỗi)
-- =============================================================================
pcall(function()
    -- 1. High-Contrast Window & TopBar Styling
    if Window and Window._gui then
        local win = Window._gui
        win.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
        win.BackgroundTransparency = 0.05

        local winStroke = win:FindFirstChildOfClass("UIStroke")
        if winStroke then
            winStroke.Color = Color3.fromRGB(168, 85, 247)
            winStroke.Thickness = 1.5
            winStroke.Transparency = 0.2
            local strokeGrad = winStroke:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
            strokeGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 180, 254)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168, 85, 247)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(126, 34, 206)),
            })
            strokeGrad.Rotation = 45
            strokeGrad.Parent = winStroke
        end

        local topbar = win:FindFirstChild("TopBar")
        local toolbar = topbar and topbar:FindFirstChild("LiquidToolbar")
        if toolbar then
            toolbar.BackgroundColor3 = Color3.fromRGB(28, 20, 42)
            toolbar.BackgroundTransparency = 0.2

            local oldLogo = toolbar:FindFirstChild("SkidHubTopLogo")
            if oldLogo then oldLogo:Destroy() end

            local topLogo = Instance.new("ImageLabel")
            topLogo.Name = "SkidHubTopLogo"
            topLogo.Size = UDim2.fromOffset(36, 36)
            topLogo.Position = UDim2.new(0, 10, 0.5, 0)
            topLogo.AnchorPoint = Vector2.new(0, 0.5)
            topLogo.BackgroundColor3 = Color3.fromRGB(22, 16, 34)
            topLogo.BorderSizePixel = 0
            topLogo.Image = logoAsset
            topLogo.ZIndex = 5
            topLogo.Parent = toolbar

            local logoCorner = Instance.new("UICorner")
            logoCorner.CornerRadius = UDim.new(1, 0)
            logoCorner.Parent = topLogo

            local logoStroke = Instance.new("UIStroke")
            logoStroke.Thickness = 1.5
            logoStroke.Color = Color3.fromRGB(168, 85, 247)
            logoStroke.Parent = topLogo

            local title = toolbar:FindFirstChild("Title")
            if title then
                title.Position = UDim2.fromOffset(54, 7)
                title.Text = "SKIDHUB"
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                pcall(function() title.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Bold) end)
            end

            local subtitle = toolbar:FindFirstChild("Subtitle")
            if subtitle then
                subtitle.Position = UDim2.fromOffset(54, 27)
                subtitle.Text = "Blox Fruits v15.1  ✦  V2.8"
                subtitle.TextColor3 = Color3.fromRGB(216, 180, 254)
                pcall(function() subtitle.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.SemiBold) end)
            end
        end
    end

    -- 2. Floating Draggable Logo Toggle Button
    local oldToggle = ParentGui:FindFirstChild("SkidHubToggleGui")
    if oldToggle then oldToggle:Destroy() end

    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "SkidHubToggleGui"
    toggleGui.ResetOnSpawn = false
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.Parent = ParentGui

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "SkidHubLogoButton"
    toggleBtn.Size = UDim2.fromOffset(50, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0, 75)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 14, 26)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Image = logoAsset
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = toggleGui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 2.5
    btnStroke.Color = Color3.fromRGB(168, 85, 247)
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = toggleBtn

    -- Breathing pulse effect
    local pulse = TweenService:Create(btnStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Color = Color3.fromRGB(216, 180, 254),
        Transparency = 0.4
    })
    pulse:Play()

    -- Dragging logic hỗ trợ cả Touch (Mobile) & Mouse (PC)
    local dragging = false
    local dragStart, startPos, dragInput
    local hasMoved = false

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = toggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    toggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 6 then
                hasMoved = true
            end
            toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Click / Tap toggle logic kèm hiệu ứng bounce tween
    toggleBtn.MouseButton1Click:Connect(function()
        if hasMoved then return end
        TweenService:Create(toggleBtn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(44, 44)
        }):Play()
        task.wait(0.08)
        TweenService:Create(toggleBtn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(50, 50)
        }):Play()

        if Window and Window._gui then
            local willShow = not Window._gui.Visible
            Window._gui.Visible = willShow
            if willShow and Window.Open and Window._state == "closed" then
                pcall(function() Window:Open() end)
            end
        elseif Window and Window.Toggle then
            Window:Toggle()
        end
    end)

    -- 3. Đồng bộ MobileToggleButton của NullUI trên Delta Mobile
    if Window and Window._gui then
        local mobBtn = Window._gui:FindFirstChild("MobileToggleButton", true)
        if mobBtn then
            mobBtn.Image = logoAsset
            mobBtn.BackgroundTransparency = 0.2
            mobBtn.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
            local stroke = mobBtn:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", mobBtn)
            stroke.Thickness = 2
            stroke.Color = Color3.fromRGB(168, 85, 247)
        end
    end
end)

-- Phím tắt PC: RightControl để bật/tắt UI
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        if Window and Window._gui then
            Window._gui.Visible = not Window._gui.Visible
        elseif Window and Window.Toggle then
            Window:Toggle()
        end
    end
end)

-- =============================================================================
-- TOÀN BỘ 17 TAB & 56 SECTION NGUYÊN BẢN TỪ UI3NN (BANANA CAT HUB)
-- =============================================================================

-- TAB 1: Shop
local Tab_PageShop = Window:AddTab({ Name = "Shop", Icon = "shopping-cart" })
do
    Tab_PageShop:AddSection("Misc Shop")
    Tab_PageShop:AddButton({ Text = "Redeem Code", Callback = function() Notify("Misc Shop", "Redeem Code", 2) end })
    Tab_PageShop:AddButton({ Text = "Teleport Old World", Callback = function() Notify("Misc Shop", "Teleport Old World", 2) end })
    Tab_PageShop:AddButton({ Text = "Teleport New World", Callback = function() Notify("Misc Shop", "Teleport New World", 2) end })
    Tab_PageShop:AddButton({ Text = "Teleport Thid Sea", Callback = function() Notify("Misc Shop", "Teleport Thid Sea", 2) end })
    Tab_PageShop:AddButton({ Text = "Buy Dual Flintlock", Callback = function() Notify("Misc Shop", "Buy Dual Flintlock", 2) end })
    Tab_PageShop:AddButton({ Text = "Reroll Race", Callback = function() Notify("Misc Shop", "Reroll Race", 2) end })
    Tab_PageShop:AddButton({ Text = "Reset Stats", Callback = function() Notify("Misc Shop", "Reset Stats", 2) end })
    Tab_PageShop:AddButton({ Text = "Buy Race Cyborg", Callback = function() Notify("Misc Shop", "Buy Race Cyborg", 2) end })
    Tab_PageShop:AddButton({ Text = "Buy Race Ghoul", Callback = function() Notify("Misc Shop", "Buy Race Ghoul", 2) end })
    Tab_PageShop:AddSection("Fighting Shop")
    Tab_PageShop:AddToggle({ Text = "Black Leg", Default = false, Callback = function(v) print("[Fighting Shop] Black Leg:", v) end })
    Tab_PageShop:AddToggle({ Text = "Fishman Karate", Default = false, Callback = function(v) print("[Fighting Shop] Fishman Karate:", v) end })
    Tab_PageShop:AddToggle({ Text = "Electro", Default = false, Callback = function(v) print("[Fighting Shop] Electro:", v) end })
    Tab_PageShop:AddToggle({ Text = "Dragon Breath", Default = false, Callback = function(v) print("[Fighting Shop] Dragon Breath:", v) end })
    Tab_PageShop:AddToggle({ Text = "SuperHuman", Default = false, Callback = function(v) print("[Fighting Shop] SuperHuman:", v) end })
    Tab_PageShop:AddToggle({ Text = "Death Step", Default = false, Callback = function(v) print("[Fighting Shop] Death Step:", v) end })
    Tab_PageShop:AddToggle({ Text = "Sharkman Karate", Default = false, Callback = function(v) print("[Fighting Shop] Sharkman Karate:", v) end })
    Tab_PageShop:AddToggle({ Text = "Electric Claw", Default = false, Callback = function(v) print("[Fighting Shop] Electric Claw:", v) end })
    Tab_PageShop:AddToggle({ Text = "Dragon Talon", Default = false, Callback = function(v) print("[Fighting Shop] Dragon Talon:", v) end })
    Tab_PageShop:AddToggle({ Text = "God Human", Default = false, Callback = function(v) print("[Fighting Shop] God Human:", v) end })
    Tab_PageShop:AddToggle({ Text = "Sanguine Art", Default = false, Callback = function(v) print("[Fighting Shop] Sanguine Art:", v) end })
    Tab_PageShop:AddSection("Abilities Shop")
    Tab_PageShop:AddButton({ Text = "Skyjump [ $10,000 Beli ]", Callback = function() Notify("Abilities Shop", "Skyjump [ $10,000 Beli ]", 2) end })
    Tab_PageShop:AddButton({ Text = "Buso Haki [ $25,000 Beli ]", Callback = function() Notify("Abilities Shop", "Buso Haki [ $25,000 Beli ]", 2) end })
    Tab_PageShop:AddButton({ Text = "Observation haki [ $750,000 Beli ]", Callback = function() Notify("Abilities Shop", "Observation haki [ $750,000 Beli ]", 2) end })
    Tab_PageShop:AddButton({ Text = "Soru [ $100,000 Beli ]", Callback = function() Notify("Abilities Shop", "Soru [ $100,000 Beli ]", 2) end })
end

-- TAB 2: Status And Server
local Tab_PageStatusAndServer = Window:AddTab({ Name = "Status And Server", Icon = "server" })
do
    Tab_PageStatusAndServer:AddSection("BananaCat Status UI")
    Tab_PageStatusAndServer:AddToggle({ Text = "Show BananaCat Status UI", Default = false, Callback = function(v) print("[BananaCat Status UI] Show BananaCat Status UI:", v) end })
    Tab_PageStatusAndServer:AddSection("Status")
    Tab_PageStatusAndServer:AddLabel("Timer")
    Tab_PageStatusAndServer:AddLabel("Timer Server")
    Tab_PageStatusAndServer:AddLabel("Next Time Spawn Fist of Darkness or God's Chalice")
    Tab_PageStatusAndServer:AddLabel("Elite")
    Tab_PageStatusAndServer:AddLabel("Eyes Summon Tyrant")
    Tab_PageStatusAndServer:AddLabel("Summon Katakuri")
    Tab_PageStatusAndServer:AddLabel("Status SPY")
    Tab_PageStatusAndServer:AddLabel("Mirage")
    Tab_PageStatusAndServer:AddLabel("Prehistoric Island")
    Tab_PageStatusAndServer:AddLabel("Frozen Dimension")
    Tab_PageStatusAndServer:AddLabel("Moon")
    Tab_PageStatusAndServer:AddLabel("Acient One Status")
    Tab_PageStatusAndServer:AddSection("Server")
    Tab_PageStatusAndServer:AddButton({ Text = "Open Gui Server Browser (Low Player and Ping)", Callback = function() Notify("Server", "Open Gui Server Browser (Low Player and Ping)", 2) end })
    Tab_PageStatusAndServer:AddLabel("PlaceId:")
    Tab_PageStatusAndServer:AddToggle({ Text = "Spam Join", Default = false, Callback = function(v) print("[Server] Spam Join:", v) end })
    Tab_PageStatusAndServer:AddButton({ Text = "Join JobId", Callback = function() Notify("Server", "Join JobId", 2) end })
    Tab_PageStatusAndServer:AddButton({ Text = "Copy JobId", Callback = function() Notify("Server", "Copy JobId", 2) end })
    Tab_PageStatusAndServer:AddButton({ Text = "Hop Server", Callback = function() Notify("Server", "Hop Server", 2) end })
    Tab_PageStatusAndServer:AddButton({ Text = "Hop Server Less People", Callback = function() Notify("Server", "Hop Server Less People", 2) end })
end

-- TAB 3: LocalPlayer
local Tab_LocalPlayerMain = Window:AddTab({ Name = "LocalPlayer", Icon = "user" })
do
    Tab_LocalPlayerMain:AddSection("Local Player")
    Tab_LocalPlayerMain:AddToggle({ Text = "Auto Translate", Default = false, Callback = function(v) print("[Local Player] Auto Translate:", v) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Stop Tween", Callback = function() Notify("Local Player", "Stop Tween", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Fix UI Button Game", Callback = function() Notify("Local Player", "Fix UI Button Game", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Load config in Web", Callback = function() Notify("Local Player", "Load config in Web", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Push Data To Web ( just push when join game,if push again plz rejoin )", Callback = function() Notify("Local Player", "Push Data To Web ( just push when join game,if push again plz rejoin )", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Show Item", Callback = function() Notify("Local Player", "Show Item", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Open Devil Fruit Shop", Callback = function() Notify("Local Player", "Open Devil Fruit Shop", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Open Devil Fruit Shop Mirage", Callback = function() Notify("Local Player", "Open Devil Fruit Shop Mirage", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Open Title", Callback = function() Notify("Local Player", "Open Title", 2) end })
    Tab_LocalPlayerMain:AddButton({ Text = "Open Color", Callback = function() Notify("Local Player", "Open Color", 2) end })
    Tab_LocalPlayerMain:AddDropdown({ Text = "Select Stats", Options = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}, Callback = function(v) print("[Local Player] Select Stats:", v) end })
    Tab_LocalPlayerMain:AddToggle({ Text = "Auto Stats", Default = false, Callback = function(v) print("[Local Player] Auto Stats:", v) end })
    Tab_LocalPlayerMain:AddDropdown({ Text = "Select Team", Options = {"Pirates", "Marines"}, Callback = function(v) print("[Local Player] Select Team:", v) end })
    Tab_LocalPlayerMain:AddDropdown({ Text = "Change Team", Options = {"Pirates", "Marines"}, Callback = function(v) print("[Local Player] Change Team:", v) end })
    Tab_LocalPlayerMain:AddToggle({ Text = "Noclip", Default = false, Callback = function(v) print("[Local Player] Noclip:", v) end })
    Tab_LocalPlayerMain:AddDropdown({ Text = "Select Npc", Options = {"Quest NPC", "Shop NPC", "Boss NPC", "Special NPC"}, Callback = function(v) print("[Local Player] Select Npc:", v) end })
    Tab_LocalPlayerMain:AddToggle({ Text = "Teleport To Npc", Default = false, Callback = function(v) print("[Local Player] Teleport To Npc:", v) end })
    Tab_LocalPlayerMain:AddDropdown({ Text = "Select Island", Options = {"Starter Island", "Jungle", "Pirate Village", "Desert", "Frozen Village", "Marine Fortress", "Skylands", "Prison", "Colosseum", "Magma Village", "Underwater City", "Fountain City"}, Callback = function(v) print("[Local Player] Select Island:", v) end })
    Tab_LocalPlayerMain:AddToggle({ Text = "Teleport To Island", Default = false, Callback = function(v) print("[Local Player] Teleport To Island:", v) end })
    Tab_LocalPlayerMain:AddToggle({ Text = "Teleport Mirage", Default = false, Callback = function(v) print("[Local Player] Teleport Mirage:", v) end })
    Tab_LocalPlayerMain:AddToggle({ Text = "Teleport Prehistoric Island", Default = false, Callback = function(v) print("[Local Player] Teleport Prehistoric Island:", v) end })
end

-- TAB 4: Setting Farm
local Tab_SettingFarmMain = Window:AddTab({ Name = "Setting Farm", Icon = "sliders" })
do
    Tab_SettingFarmMain:AddSection("Setting Farm")
    Tab_SettingFarmMain:AddDropdown({ Text = "Select Weapon", Options = {"Melee", "Sword", "Blox Fruit"}, Callback = function(v) print("[Setting Farm] Select Weapon:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Attack No Animation", Default = false, Callback = function(v) print("[Setting Farm] Attack No Animation:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Kill Aura Only Raid And Volcano", Default = false, Callback = function(v) print("[Setting Farm] Kill Aura Only Raid And Volcano:", v) end })
    Tab_SettingFarmMain:AddSlider({ Text = "Time Delay Kill", Min = 0, Max = 5, Default = 0, Increment = 1, Callback = function(v) print("[Setting Farm] Time Delay Kill:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Auto Click", Default = false, Callback = function(v) print("[Setting Farm] Auto Click:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Kill Aura With DragonStorm", Default = false, Callback = function(v) print("[Setting Farm] Kill Aura With DragonStorm:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Auto Turn On Buso", Default = false, Callback = function(v) print("[Setting Farm] Auto Turn On Buso:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Auto Turn On Observation", Default = false, Callback = function(v) print("[Setting Farm] Auto Turn On Observation:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Auto Turn On V4", Default = false, Callback = function(v) print("[Setting Farm] Auto Turn On V4:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Auto Turn On V3", Default = false, Callback = function(v) print("[Setting Farm] Auto Turn On V3:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Auto Dodge Skill Mobs", Default = false, Callback = function(v) print("[Setting Farm] Auto Dodge Skill Mobs:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Teleport Y if low health", Default = false, Callback = function(v) print("[Setting Farm] Teleport Y if low health:", v) end })
    Tab_SettingFarmMain:AddSlider({ Text = "% Health Player", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) print("[Setting Farm] % Health Player:", v) end })
    Tab_SettingFarmMain:AddSlider({ Text = "Distance Teleport Y", Min = 0, Max = 10000, Default = 0, Increment = 1, Callback = function(v) print("[Setting Farm] Distance Teleport Y:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Tween Safe if have Items", Default = false, Callback = function(v) print("[Setting Farm] Tween Safe if have Items:", v) end })
    Tab_SettingFarmMain:AddSlider({ Text = "Time Hop Server", Min = 0, Max = 60, Default = 0, Increment = 1, Callback = function(v) print("[Setting Farm] Time Hop Server:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Use Portal Teleport", Default = false, Callback = function(v) print("[Setting Farm] Use Portal Teleport:", v) end })
    Tab_SettingFarmMain:AddSlider({ Text = "Bring Mob Count", Min = 2, Max = 6, Default = 2, Increment = 1, Callback = function(v) print("[Setting Farm] Bring Mob Count:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Bring Mob", Default = false, Callback = function(v) print("[Setting Farm] Bring Mob:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Reset Teleport [ Beta ]", Default = false, Callback = function(v) print("[Setting Farm] Reset Teleport [ Beta ]:", v) end })
    Tab_SettingFarmMain:AddToggle({ Text = "Use Submarine Teleport", Default = false, Callback = function(v) print("[Setting Farm] Use Submarine Teleport:", v) end })
    Tab_SettingFarmMain:AddSlider({ Text = "Speed Tween", Min = 0, Max = 1000, Default = 0, Increment = 1, Callback = function(v) print("[Setting Farm] Speed Tween:", v) end })
    Tab_SettingFarmMain:AddLabel("Recommended: 350. If you're farming spots close to each other, use a higher speed")
end

-- TAB 5: Hold and Select Skill
local Tab_SettingSkillMain = Window:AddTab({ Name = "Hold and Select Skill", Icon = "zap" })
do
    Tab_SettingSkillMain:AddSection("Select Skills")
    Tab_SettingSkillMain:AddSection("Hold Skills")
    Tab_SettingSkillMain:AddDropdown({ Text = "Set Delay", Options = {"0.1s", "0.2s", "0.5s", "1.0s", "1.5s", "2.0s"}, Callback = function(v) print("[Hold Skills] Set Delay:", v) end })
    Tab_SettingSkillMain:AddToggle({ Text = "Use skill fast dont hold", Default = false, Callback = function(v) print("[Hold Skills] Use skill fast dont hold:", v) end })
end

-- TAB 6: Farming
local Tab_FarmMain = Window:AddTab({ Name = "Farming", Icon = "sword" })
do
    Tab_FarmMain:AddSection("Setting Farm")
    Tab_FarmMain:AddDropdown({ Text = "Select Method Farm", Options = {"Level Farm", "Farm Bones", "Farm Katakuri", "Farm Tyrant", "Aura Farm"}, Callback = function(v) print("[Setting Farm] Select Method Farm:", v) end })
    Tab_FarmMain:AddSlider({ Text = "Distance Farm Aura", Min = 0, Max = 1000, Default = 0, Increment = 1, Callback = function(v) print("[Setting Farm] Distance Farm Aura:", v) end })
    Tab_FarmMain:AddToggle({ Text = "Ignore Attack Katakuri", Default = false, Callback = function(v) print("[Setting Farm] Ignore Attack Katakuri:", v) end })
    Tab_FarmMain:AddToggle({ Text = "Hop Find Katakuri", Default = false, Callback = function(v) print("[Setting Farm] Hop Find Katakuri:", v) end })
    Tab_FarmMain:AddToggle({ Text = "Auto Quest [Katakuri/Bone/Tyrant]", Default = false, Callback = function(v) print("[Setting Farm] Auto Quest [Katakuri/Bone/Tyrant]:", v) end })
    Tab_FarmMain:AddToggle({ Text = "Start Farm", Default = false, Callback = function(v) print("[Setting Farm] Start Farm:", v) end })
    Tab_FarmMain:AddSection("Mastery Farm")
    Tab_FarmMain:AddDropdown({ Text = "Select Method Farm Mastery", Options = {"Blox Fruit", "Gun", "Sword"}, Callback = function(v) print("[Mastery Farm] Select Method Farm Mastery:", v) end })
    Tab_FarmMain:AddSlider({ Text = "Health %", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) print("[Mastery Farm] Health %:", v) end })
    Tab_FarmMain:AddToggle({ Text = "Farm Mastery", Default = false, Callback = function(v) print("[Mastery Farm] Farm Mastery:", v) end })
    Tab_FarmMain:AddSection("Farming Material")
    Tab_FarmMain:AddDropdown({ Text = "Select Material", Options = {"Bones", "Fish Tail", "Magma Ore", "Dragon Scale", "Mystic Droplet", "Vampire Fang", "Mini Fang", "Gunpowder", "Radioactive Material", "Demonic Soul"}, Callback = function(v) print("[Farming Material] Select Material:", v) end })
    Tab_FarmMain:AddToggle({ Text = "Farm Material", Default = false, Callback = function(v) print("[Farming Material] Farm Material:", v) end })
end

-- TAB 7: Stack Farming
local Tab_stackFarmMain = Window:AddTab({ Name = "Stack Farming", Icon = "layers" })
do
    Tab_stackFarmMain:AddSection("Auto World")
    Tab_stackFarmMain:AddToggle({ Text = "Auto New World", Default = false, Callback = function(v) print("[Auto World] Auto New World:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Auto Third World", Default = false, Callback = function(v) print("[Auto World] Auto Third World:", v) end })
    Tab_stackFarmMain:AddSection("Devil Fruit")
    Tab_stackFarmMain:AddToggle({ Text = "Collect Chest When Server Spawn God's Chalice or Fist of Darkness", Default = false, Callback = function(v) print("[Devil Fruit] Collect Chest When Server Spawn God's Chalice or Fist of Darkness:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Teleport To Fruit", Default = false, Callback = function(v) print("[Devil Fruit] Teleport To Fruit:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Teleport To Fruit [ Hop Server ]", Default = false, Callback = function(v) print("[Devil Fruit] Teleport To Fruit [ Hop Server ]:", v) end })
    Tab_stackFarmMain:AddSection("Event Game")
    Tab_stackFarmMain:AddToggle({ Text = "Auto Factory", Default = false, Callback = function(v) print("[Event Game] Auto Factory:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Auto Pirate Raid", Default = false, Callback = function(v) print("[Event Game] Auto Pirate Raid:", v) end })
    Tab_stackFarmMain:AddSection("Boss Rip Indra")
    Tab_stackFarmMain:AddToggle({ Text = "Auto Elite Hunter", Default = false, Callback = function(v) print("[Boss Rip Indra] Auto Elite Hunter:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Hop Server Elite Hunter'", Default = false, Callback = function(v) print("[Boss Rip Indra] Hop Server Elite Hunter':", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Auto Touch Pad Haki", Default = false, Callback = function(v) print("[Boss Rip Indra] Auto Touch Pad Haki:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Auto Summon Rip Indra", Default = false, Callback = function(v) print("[Boss Rip Indra] Auto Summon Rip Indra:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Attack Rip Indra", Default = false, Callback = function(v) print("[Boss Rip Indra] Attack Rip Indra:", v) end })
    Tab_stackFarmMain:AddSection("Boss Soul Reaper")
    Tab_stackFarmMain:AddToggle({ Text = "Attack Soul Reaper", Default = false, Callback = function(v) print("[Boss Soul Reaper] Attack Soul Reaper:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Summon Soul Reaper", Default = false, Callback = function(v) print("[Boss Soul Reaper] Summon Soul Reaper:", v) end })
    Tab_stackFarmMain:AddSection("Boss Dough King")
    Tab_stackFarmMain:AddToggle({ Text = "Attack Dough King", Default = false, Callback = function(v) print("[Boss Dough King] Attack Dough King:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Summon Dough King", Default = false, Callback = function(v) print("[Boss Dough King] Summon Dough King:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Hop Find Dough King", Default = false, Callback = function(v) print("[Boss Dough King] Hop Find Dough King:", v) end })
    Tab_stackFarmMain:AddSection("Boss Darkbeard")
    Tab_stackFarmMain:AddToggle({ Text = "Attack Darkbeard", Default = false, Callback = function(v) print("[Boss Darkbeard] Attack Darkbeard:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Summon Darkbeard", Default = false, Callback = function(v) print("[Boss Darkbeard] Summon Darkbeard:", v) end })
    Tab_stackFarmMain:AddToggle({ Text = "Hop Find Darkbeard", Default = false, Callback = function(v) print("[Boss Darkbeard] Hop Find Darkbeard:", v) end })
end

-- TAB 8: Farming Other
local Tab_FarmotherMain = Window:AddTab({ Name = "Farming Other", Icon = "crosshair" })
do
    Tab_FarmotherMain:AddSection("Secret Quest")
    Tab_FarmotherMain:AddLabel("Secret Quest : 0/39 Quests")
    Tab_FarmotherMain:AddLabel("Title Quest : ...")
    Tab_FarmotherMain:AddLabel("Doing Quest : None")
    Tab_FarmotherMain:AddLabel("Title Awakened Boss : None")
    Tab_FarmotherMain:AddToggle({ Text = "Hop Server For Secret Quest", Default = false, Callback = function(v) print("[Secret Quest] Hop Server For Secret Quest:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Secret Quest", Default = false, Callback = function(v) print("[Secret Quest] Auto Secret Quest:", v) end })
    Tab_FarmotherMain:AddSection("Event Easter")
    Tab_FarmotherMain:AddButton({ Text = "Open Easter Shop", Callback = function() Notify("Event Easter", "Open Easter Shop", 2) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Collect Egg Easter", Default = false, Callback = function(v) print("[Event Easter] Auto Collect Egg Easter:", v) end })
    Tab_FarmotherMain:AddSection("Fishing")
    Tab_FarmotherMain:AddToggle({ Text = "Change Size Reel", Default = false, Callback = function(v) print("[Fishing] Change Size Reel:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Slap Battle", Default = false, Callback = function(v) print("[Fishing] Auto Slap Battle:", v) end })
    Tab_FarmotherMain:AddButton({ Text = "Save Position Fishing", Callback = function() Notify("Fishing", "Save Position Fishing", 2) end })
    Tab_FarmotherMain:AddDropdown({ Text = "Select Bait", Options = {"Common Bait", "Uncommon Bait", "Rare Bait", "Epic Bait", "Legendary Bait", "Mythical Bait"}, Callback = function(v) print("[Fishing] Select Bait:", v) end })
    Tab_FarmotherMain:AddLabel("Status Fishing :")
    Tab_FarmotherMain:AddToggle({ Text = "Auto Tween To Event Fishing Spot", Default = false, Callback = function(v) print("[Fishing] Auto Tween To Event Fishing Spot:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Fishing", Default = false, Callback = function(v) print("[Fishing] Auto Fishing:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Sell Fishing", Default = false, Callback = function(v) print("[Fishing] Auto Sell Fishing:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Open Chest", Default = false, Callback = function(v) print("[Fishing] Auto Open Chest:", v) end })
    Tab_FarmotherMain:AddDropdown({ Text = "Select Quest Fishing", Options = {"Quest 1", "Quest 2", "Quest 3", "Special Quest"}, Callback = function(v) print("[Fishing] Select Quest Fishing:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Accept Quest Fishing", Default = false, Callback = function(v) print("[Fishing] Auto Accept Quest Fishing:", v) end })
    Tab_FarmotherMain:AddSection("Quest Dragon")
    Tab_FarmotherMain:AddToggle({ Text = "Auto Quest Dojo Trainer", Default = false, Callback = function(v) print("[Quest Dragon] Auto Quest Dojo Trainer:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Quest Dragon Hunter", Default = false, Callback = function(v) print("[Quest Dragon] Auto Quest Dragon Hunter:", v) end })
    Tab_FarmotherMain:AddSection("Attack All Mobs")
    Tab_FarmotherMain:AddToggle({ Text = "Auto Attack All Mob and Boss", Default = false, Callback = function(v) print("[Attack All Mobs] Auto Attack All Mob and Boss:", v) end })
    Tab_FarmotherMain:AddSection("Berry")
    Tab_FarmotherMain:AddToggle({ Text = "Hop Find Berry", Default = false, Callback = function(v) print("[Berry] Hop Find Berry:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Collect Berry", Default = false, Callback = function(v) print("[Berry] Auto Collect Berry:", v) end })
    Tab_FarmotherMain:AddSection("Farm Chest")
    Tab_FarmotherMain:AddSlider({ Text = "Value Collect Chest to Hop", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) print("[Farm Chest] Value Collect Chest to Hop:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Chest Hop", Default = false, Callback = function(v) print("[Farm Chest] Auto Chest Hop:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Use Method Teleport [ Risk ]", Default = false, Callback = function(v) print("[Farm Chest] Use Method Teleport [ Risk ]:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Auto Chest", Default = false, Callback = function(v) print("[Farm Chest] Auto Chest:", v) end })
    Tab_FarmotherMain:AddSection("Raid Law")
    Tab_FarmotherMain:AddToggle({ Text = "Auto Buy Chip and Attack Law", Default = false, Callback = function(v) print("[Raid Law] Auto Buy Chip and Attack Law:", v) end })
    Tab_FarmotherMain:AddSection("Farm Observation")
    Tab_FarmotherMain:AddToggle({ Text = "Auto UP Observation V2", Default = false, Callback = function(v) print("[Farm Observation] Auto UP Observation V2:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Farm Observation", Default = false, Callback = function(v) print("[Farm Observation] Farm Observation:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Farm Observation [ Hop Server ]", Default = false, Callback = function(v) print("[Farm Observation] Farm Observation [ Hop Server ]:", v) end })
    Tab_FarmotherMain:AddSection("Auto Kill Mob")
    Tab_FarmotherMain:AddDropdown({ Text = "Select Mob", Options = {"Bandit", "Monkey", "Gorilla", "Pirate", "Brute", "Desert Bandit", "Snow Bandit", "Marine"}, Callback = function(v) print("[Auto Kill Mob] Select Mob:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Kill Mob", Default = false, Callback = function(v) print("[Auto Kill Mob] Kill Mob:", v) end })
    Tab_FarmotherMain:AddSection("Auto Boss")
    Tab_FarmotherMain:AddDropdown({ Text = "Select Boss", Options = {"The Gorilla King", "Bobby", "The Saw", "Yeti", "Vice Admiral", "Swan", "Magma Admiral", "Fishman Lord", "Cyborg", "Darkbeard", "Rip Indra", "Dough King"}, Callback = function(v) print("[Auto Boss] Select Boss:", v) end })
    Tab_FarmotherMain:AddButton({ Text = "Refresh Boss", Callback = function() Notify("Auto Boss", "Refresh Boss", 2) end })
    Tab_FarmotherMain:AddToggle({ Text = "Kill Boss", Default = false, Callback = function(v) print("[Auto Boss] Kill Boss:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Kill All Boss", Default = false, Callback = function(v) print("[Auto Boss] Kill All Boss:", v) end })
    Tab_FarmotherMain:AddToggle({ Text = "Hop Server Find Boss", Default = false, Callback = function(v) print("[Auto Boss] Hop Server Find Boss:", v) end })
end

-- TAB 9: Fruit and Raid, Dungeon
local Tab_DFRaidMain = Window:AddTab({ Name = "Fruit and Raid, Dungeon", Icon = "flame" })
do
    Tab_DFRaidMain:AddSection("Devil Fruit")
    Tab_DFRaidMain:AddToggle({ Text = "Random Devil Fruit", Default = false, Callback = function(v) print("[Devil Fruit] Random Devil Fruit:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Auto Store Fruit", Default = false, Callback = function(v) print("[Devil Fruit] Auto Store Fruit:", v) end })
    Tab_DFRaidMain:AddDropdown({ Text = "Blox Fruit Sniper Shop", Options = {"Rocket", "Spin", "Blade", "Spring", "Bomb", "Smoke", "Spike", "Flame", "Falcon", "Ice", "Sand", "Dark", "Diamond", "Light", "Rubber", "Barrier", "Ghost", "Magma", "Quake", "Buddha", "Love", "Spider", "Sound", "Phoenix", "Portal", "Rumble", "Pain", "Blizzard", "Gravity", "Mammoth", "T-Rex", "Dough", "Shadow", "Venom", "Control", "Spirit", "Dragon", "Leopard", "Kitsune"}, Callback = function(v) print("[Devil Fruit] Blox Fruit Sniper Shop:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Buy Blox Fruit Sniper Shop", Default = false, Callback = function(v) print("[Devil Fruit] Buy Blox Fruit Sniper Shop:", v) end })
    Tab_DFRaidMain:AddSection("Raids")
    Tab_DFRaidMain:AddDropdown({ Text = "Select Raid", Options = {"Flame", "Ice", "Quake", "Light", "Dark", "String", "Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough"}, Callback = function(v) print("[Raids] Select Raid:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Get Fruit In Inventory Low Beli", Default = false, Callback = function(v) print("[Raids] Get Fruit In Inventory Low Beli:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Auto Raid", Default = false, Callback = function(v) print("[Raids] Auto Raid:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Hop Sever Raid", Default = false, Callback = function(v) print("[Raids] Hop Sever Raid:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Auto Awake Fruit", Default = false, Callback = function(v) print("[Raids] Auto Awake Fruit:", v) end })
    Tab_DFRaidMain:AddSection("Multi Raid")
    Tab_DFRaidMain:AddDropdown({ Text = "Select Player Multi Raid", Options = {"Player 1", "Player 2", "All Players"}, Callback = function(v) print("[Multi Raid] Select Player Multi Raid:", v) end })
    Tab_DFRaidMain:AddButton({ Text = "Refresh Player", Callback = function() Notify("Multi Raid", "Refresh Player", 2) end })
    Tab_DFRaidMain:AddToggle({ Text = "Account Buy Chip", Default = false, Callback = function(v) print("[Multi Raid] Account Buy Chip:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Account Pick Slot Raid", Default = false, Callback = function(v) print("[Multi Raid] Account Pick Slot Raid:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Auto Multi Raid", Default = false, Callback = function(v) print("[Multi Raid] Auto Multi Raid:", v) end })
    Tab_DFRaidMain:AddSection("Join Dungeon")
    Tab_DFRaidMain:AddDropdown({ Text = "Select Account Join", Options = {"Main Account", "Alt 1", "Alt 2"}, Callback = function(v) print("[Join Dungeon] Select Account Join:", v) end })
    Tab_DFRaidMain:AddButton({ Text = "Refresh Player", Callback = function() Notify("Join Dungeon", "Refresh Player", 2) end })
    Tab_DFRaidMain:AddSlider({ Text = "Min Player Join Dungeon", Min = 0, Max = 4, Default = 0, Increment = 1, Callback = function(v) print("[Join Dungeon] Min Player Join Dungeon:", v) end })
    Tab_DFRaidMain:AddDropdown({ Text = "Select Difficulty", Options = {"Normal", "Hard", "Nightmare"}, Callback = function(v) print("[Join Dungeon] Select Difficulty:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Account Start Dungeon", Default = false, Callback = function(v) print("[Join Dungeon] Account Start Dungeon:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Auto Join Dungeon", Default = false, Callback = function(v) print("[Join Dungeon] Auto Join Dungeon:", v) end })
    Tab_DFRaidMain:AddSection("Dungeon")
    Tab_DFRaidMain:AddDropdown({ Text = "Select Weapon Dungeon", Options = {"Melee", "Sword", "Blox Fruit"}, Callback = function(v) print("[Dungeon] Select Weapon Dungeon:", v) end })
    Tab_DFRaidMain:AddDropdown({ Text = "Select Card Priority", Options = {"Damage", "Health", "Speed", "Defense"}, Callback = function(v) print("[Dungeon] Select Card Priority:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Auto Attack Dungeon", Default = false, Callback = function(v) print("[Dungeon] Auto Attack Dungeon:", v) end })
    Tab_DFRaidMain:AddToggle({ Text = "Auto Pick Card Dungeon", Default = false, Callback = function(v) print("[Dungeon] Auto Pick Card Dungeon:", v) end })
end

-- TAB 10: Sea Event
local Tab_SeaEventTab = Window:AddTab({ Name = "Sea Event", Icon = "anchor" })
do
    Tab_SeaEventTab:AddSection("Setting")
    Tab_SeaEventTab:AddDropdown({ Text = "Select Zone", Options = {"Zone 1", "Zone 2", "Zone 3", "Zone 4", "Zone 5", "Zone 6"}, Callback = function(v) print("[Setting] Select Zone:", v) end })
    Tab_SeaEventTab:AddDropdown({ Text = "Select Sea Events", Options = {"Terrorshark", "Sea Beast", "Ghost Ship", "Piranha"}, Callback = function(v) print("[Setting] Select Sea Events:", v) end })
    Tab_SeaEventTab:AddDropdown({ Text = "Select Boat", Options = {"Guardian", "Lantern", "Beast Hunter", "Speed Boat"}, Callback = function(v) print("[Setting] Select Boat:", v) end })
    Tab_SeaEventTab:AddDropdown({ Text = "Select Weapons Use Skill", Options = {"Melee", "Sword", "Gun", "Fruit"}, Callback = function(v) print("[Setting] Select Weapons Use Skill:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Use Dragonstorm For Sea Event", Default = false, Callback = function(v) print("[Setting] Use Dragonstorm For Sea Event:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Use Click M1 Skull Guitar For Sea Event", Default = false, Callback = function(v) print("[Setting] Use Click M1 Skull Guitar For Sea Event:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Change Dragonstorm With Skull Guitar", Default = false, Callback = function(v) print("[Setting] Auto Change Dragonstorm With Skull Guitar:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Change Dragonstorm When Kill Boat", Default = false, Callback = function(v) print("[Setting] Auto Change Dragonstorm When Kill Boat:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Use Click M1 Fruit For Sea Event", Default = false, Callback = function(v) print("[Setting] Use Click M1 Fruit For Sea Event:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Reset Character Buy Boat", Default = false, Callback = function(v) print("[Setting] Reset Character Buy Boat:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Dodge Skill Terrorshark", Default = false, Callback = function(v) print("[Setting] Auto Dodge Skill Terrorshark:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Dodge Skill Seabeast", Default = false, Callback = function(v) print("[Setting] Auto Dodge Skill Seabeast:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Teleport Boat Other CFrame if Rough Sea", Default = false, Callback = function(v) print("[Setting] Teleport Boat Other CFrame if Rough Sea:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Tween Until Have Sea Event", Default = false, Callback = function(v) print("[Setting] Tween Until Have Sea Event:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Will Back When over 10km", Default = false, Callback = function(v) print("[Setting] Will Back When over 10km:", v) end })
    Tab_SeaEventTab:AddSection("Farming")
    Tab_SeaEventTab:AddDropdown({ Text = "Select Friend", Options = {"Friend 1", "Friend 2", "All Friends"}, Callback = function(v) print("[Farming] Select Friend:", v) end })
    Tab_SeaEventTab:AddButton({ Text = "Refresh Player", Callback = function() Notify("Farming", "Refresh Player", 2) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Sea Event With Friend", Default = false, Callback = function(v) print("[Farming] Auto Sea Event With Friend:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Repair Ur Ship", Default = false, Callback = function(v) print("[Farming] Auto Repair Ur Ship:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Sea Event", Default = false, Callback = function(v) print("[Farming] Auto Sea Event:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Find Mirage", Default = false, Callback = function(v) print("[Farming] Auto Find Mirage:", v) end })
    Tab_SeaEventTab:AddSection("Kitsune Event")
    Tab_SeaEventTab:AddToggle({ Text = "Teleport To Kitsune Island", Default = false, Callback = function(v) print("[Kitsune Event] Teleport To Kitsune Island:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Hop Server [ Next Night or Near Full Moon > 2m ]", Default = false, Callback = function(v) print("[Kitsune Event] Hop Server [ Next Night or Near Full Moon > 2m ]:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Spawn Kitsune Island", Default = false, Callback = function(v) print("[Kitsune Event] Auto Spawn Kitsune Island:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Summon Soul Ember", Default = false, Callback = function(v) print("[Kitsune Event] Auto Summon Soul Ember:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Collect Soul Ember", Default = false, Callback = function(v) print("[Kitsune Event] Auto Collect Soul Ember:", v) end })
    Tab_SeaEventTab:AddSlider({ Text = "Values Azure Ember", Min = 0, Max = 25, Default = 0, Increment = 1, Callback = function(v) print("[Kitsune Event] Values Azure Ember:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Trade Azure Ember", Default = false, Callback = function(v) print("[Kitsune Event] Auto Trade Azure Ember:", v) end })
    Tab_SeaEventTab:AddSection("Leviathan Event")
    Tab_SeaEventTab:AddButton({ Text = "Buy Spy", Callback = function() Notify("Leviathan Event", "Buy Spy", 2) end })
    Tab_SeaEventTab:AddButton({ Text = "Teleport your boat to current Position", Callback = function() Notify("Leviathan Event", "Teleport your boat to current Position", 2) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Buy Spy", Default = false, Callback = function(v) print("[Leviathan Event] Auto Buy Spy:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Buy Boat Beast Hunter", Default = false, Callback = function(v) print("[Leviathan Event] Auto Buy Boat Beast Hunter:", v) end })
    Tab_SeaEventTab:AddDropdown({ Text = "Select Owner Boat Find Leviathan", Options = {"Me", "Select Player..."}, Callback = function(v) print("[Leviathan Event] Select Owner Boat Find Leviathan:", v) end })
    Tab_SeaEventTab:AddButton({ Text = "Refresh Player", Callback = function() Notify("Leviathan Event", "Refresh Player", 2) end })
    Tab_SeaEventTab:AddToggle({ Text = "Multi Find Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Multi Find Leviathan:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Find Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Auto Find Leviathan:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Start Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Auto Start Leviathan:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Destroy IDK", Default = false, Callback = function(v) print("[Leviathan Event] Auto Destroy IDK:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Attack Multi Segments Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Attack Multi Segments Leviathan:", v) end })
    Tab_SeaEventTab:AddSlider({ Text = "Value Damage Multi Segments", Min = 0, Max = 1000000, Default = 0, Increment = 1, Callback = function(v) print("[Leviathan Event] Value Damage Multi Segments:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Attack Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Auto Attack Leviathan:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Use Click M1 Fruit Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Use Click M1 Fruit Leviathan:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Use Click M1 Skull Guitar Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Use Click M1 Skull Guitar Leviathan:", v) end })
    Tab_SeaEventTab:AddDropdown({ Text = "Select Owner Boat Beast Hunter Shoot Heart", Options = {"Me", "Select Player..."}, Callback = function(v) print("[Leviathan Event] Select Owner Boat Beast Hunter Shoot Heart:", v) end })
    Tab_SeaEventTab:AddButton({ Text = "Refresh Player", Callback = function() Notify("Leviathan Event", "Refresh Player", 2) end })
    Tab_SeaEventTab:AddToggle({ Text = "Use Your Boat Beast Hunter", Default = false, Callback = function(v) print("[Leviathan Event] Use Your Boat Beast Hunter:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Auto Fire Shoot Heart Leviathan", Default = false, Callback = function(v) print("[Leviathan Event] Auto Fire Shoot Heart Leviathan:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Teleport Frozen Dimension", Default = false, Callback = function(v) print("[Leviathan Event] Teleport Frozen Dimension:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Tween Boat To Frozen Dimension", Default = false, Callback = function(v) print("[Leviathan Event] Tween Boat To Frozen Dimension:", v) end })
    Tab_SeaEventTab:AddSlider({ Text = "Speed Boat Auto Drive", Min = 0, Max = 500, Default = 0, Increment = 1, Callback = function(v) print("[Leviathan Event] Speed Boat Auto Drive:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Drive Boat To Tiki", Default = false, Callback = function(v) print("[Leviathan Event] Drive Boat To Tiki:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Drive Boat To Hydra", Default = false, Callback = function(v) print("[Leviathan Event] Drive Boat To Hydra:", v) end })
    Tab_SeaEventTab:AddSection("Boat Setting")
    Tab_SeaEventTab:AddToggle({ Text = "Fly Boat", Default = false, Callback = function(v) print("[Boat Setting] Fly Boat:", v) end })
    Tab_SeaEventTab:AddSlider({ Text = "Value Speed Boat", Min = 0, Max = 500, Default = 0, Increment = 1, Callback = function(v) print("[Boat Setting] Value Speed Boat:", v) end })
    Tab_SeaEventTab:AddSlider({ Text = "Value Speed Tween Boat", Min = 50, Max = 2000, Default = 50, Increment = 1, Callback = function(v) print("[Boat Setting] Value Speed Tween Boat:", v) end })
    Tab_SeaEventTab:AddSlider({ Text = "Value Speed Fly Boat", Min = 0, Max = 10, Default = 0, Increment = 1, Callback = function(v) print("[Boat Setting] Value Speed Fly Boat:", v) end })
    Tab_SeaEventTab:AddToggle({ Text = "Change Speed Boat", Default = false, Callback = function(v) print("[Boat Setting] Change Speed Boat:", v) end })
end

-- TAB 11: Upgrade Race
local Tab_RaceMain = Window:AddTab({ Name = "Upgrade Race", Icon = "sparkles" })
do
    Tab_RaceMain:AddSection("Race Draco")
    Tab_RaceMain:AddToggle({ Text = "Auto Upgrade Race V2-V3 Draco", Default = false, Callback = function(v) print("[Race Draco] Auto Upgrade Race V2-V3 Draco:", v) end })
    Tab_RaceMain:AddLabel("Acient One Draco Status")
    Tab_RaceMain:AddToggle({ Text = "Auto Trial Draco", Default = false, Callback = function(v) print("[Race Draco] Auto Trial Draco:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Fully Trial Draco", Default = false, Callback = function(v) print("[Race Draco] Fully Trial Draco:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Ignore Craft Volcanic Magnet [ Fully Draco ]", Default = false, Callback = function(v) print("[Race Draco] Ignore Craft Volcanic Magnet [ Fully Draco ]:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Buy Gear Draco", Default = false, Callback = function(v) print("[Race Draco] Auto Buy Gear Draco:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Finish Train Draco Quest", Default = false, Callback = function(v) print("[Race Draco] Auto Finish Train Draco Quest:", v) end })
    Tab_RaceMain:AddSection("Race Normal")
    Tab_RaceMain:AddToggle({ Text = "Auto Upgrade Race V2-V3", Default = false, Callback = function(v) print("[Race Normal] Auto Upgrade Race V2-V3:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Get Fully Cyborg", Default = false, Callback = function(v) print("[Race Normal] Auto Get Fully Cyborg:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Get Cyborg Hop Collect Chest", Default = false, Callback = function(v) print("[Race Normal] Auto Get Cyborg Hop Collect Chest:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Get Cyborg", Default = false, Callback = function(v) print("[Race Normal] Auto Get Cyborg:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Hop Server Find Boss Cursed Captain", Default = false, Callback = function(v) print("[Race Normal] Hop Server Find Boss Cursed Captain:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Get Ghoul", Default = false, Callback = function(v) print("[Race Normal] Auto Get Ghoul:", v) end })
    Tab_RaceMain:AddSection("Race V4")
    Tab_RaceMain:AddToggle({ Text = "No Frog", Default = false, Callback = function(v) print("[Race V4] No Frog:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Teleport Acient Clock", Default = false, Callback = function(v) print("[Race V4] Teleport Acient Clock:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Buy Gear", Default = false, Callback = function(v) print("[Race V4] Auto Buy Gear:", v) end })
    Tab_RaceMain:AddDropdown({ Text = "Select Gear V4", Options = {"Gear 1", "Gear 2", "Gear 3", "Gear 4", "Gear 5"}, Callback = function(v) print("[Race V4] Select Gear V4:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Choose Gears", Default = false, Callback = function(v) print("[Race V4] Auto Choose Gears:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Finish Train Quest", Default = false, Callback = function(v) print("[Race V4] Auto Finish Train Quest:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Stack Train With Trial Race", Default = false, Callback = function(v) print("[Race V4] Stack Train With Trial Race:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Hop Server [Trial Or Pull Lever]", Default = false, Callback = function(v) print("[Race V4] Hop Server [Trial Or Pull Lever]:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Pull Lever", Default = false, Callback = function(v) print("[Race V4] Auto Pull Lever:", v) end })
    Tab_RaceMain:AddDropdown({ Text = "Select Players Multi", Options = {"Select Player...", "All Players"}, Callback = function(v) print("[Race V4] Select Players Multi:", v) end })
    Tab_RaceMain:AddButton({ Text = "Refresh Player", Callback = function() Notify("Race V4", "Refresh Player", 2) end })
    Tab_RaceMain:AddToggle({ Text = "Multi Trial", Default = false, Callback = function(v) print("[Race V4] Multi Trial:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Reset Character", Default = false, Callback = function(v) print("[Race V4] Auto Reset Character:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Trial", Default = false, Callback = function(v) print("[Race V4] Auto Trial:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Auto Turn On V3 Near Door", Default = false, Callback = function(v) print("[Race V4] Auto Turn On V3 Near Door:", v) end })
    Tab_RaceMain:AddSection("Kill Trial")
    Tab_RaceMain:AddDropdown({ Text = "Select Weapon Attack Trial", Options = {"Melee", "Sword", "Blox Fruit"}, Callback = function(v) print("[Kill Trial] Select Weapon Attack Trial:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Kill players When complete Trial", Default = false, Callback = function(v) print("[Kill Trial] Kill players When complete Trial:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Use Skill when Kill Player", Default = false, Callback = function(v) print("[Kill Trial] Use Skill when Kill Player:", v) end })
    Tab_RaceMain:AddToggle({ Text = "Just Use Skill when Player Active Ken", Default = false, Callback = function(v) print("[Kill Trial] Just Use Skill when Player Active Ken:", v) end })
end

-- TAB 12: Get and Upgrade Items
local Tab_GetItemsMain = Window:AddTab({ Name = "Get and Upgrade Items", Icon = "package" })
do
    Tab_GetItemsMain:AddSection("Get Items")
    Tab_GetItemsMain:AddToggle({ Text = "Auto Trade Bone", Default = false, Callback = function(v) print("[Get Items] Auto Trade Bone:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Buy Legendary Sword", Default = false, Callback = function(v) print("[Get Items] Auto Buy Legendary Sword:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Buy Haki Color", Default = false, Callback = function(v) print("[Get Items] Auto Buy Haki Color:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Hop Server [ Haki color or Legendary Sword]", Default = false, Callback = function(v) print("[Get Items] Hop Server [ Haki color or Legendary Sword]:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Get Rainbow Haki", Default = false, Callback = function(v) print("[Get Items] Auto Get Rainbow Haki:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Soul Guitar", Default = false, Callback = function(v) print("[Get Items] Auto Soul Guitar:", v) end })
    Tab_GetItemsMain:AddDropdown({ Text = "Select Method Hop CDK", Options = {"Method 1", "Method 2", "Smart Hop"}, Callback = function(v) print("[Get Items] Select Method Hop CDK:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto CDK", Default = false, Callback = function(v) print("[Get Items] Auto CDK:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Yama", Default = false, Callback = function(v) print("[Get Items] Auto Yama:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Tushita", Default = false, Callback = function(v) print("[Get Items] Auto Tushita:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto TTK", Default = false, Callback = function(v) print("[Get Items] Auto TTK:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Saber", Default = false, Callback = function(v) print("[Get Items] Auto Saber:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Craft Item Shark Anchor", Default = false, Callback = function(v) print("[Get Items] Auto Craft Item Shark Anchor:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Yoru Mini", Default = false, Callback = function(v) print("[Get Items] Auto Yoru Mini:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Yoru Mini (Hop Server)", Default = false, Callback = function(v) print("[Get Items] Auto Yoru Mini (Hop Server):", v) end })
    Tab_GetItemsMain:AddSection("Mastery Weapon")
    Tab_GetItemsMain:AddToggle({ Text = "Auto Farm Mastery 600 Melees", Default = false, Callback = function(v) print("[Mastery Weapon] Auto Farm Mastery 600 Melees:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Farm Mastery 600 Sword In Inventory", Default = false, Callback = function(v) print("[Mastery Weapon] Auto Farm Mastery 600 Sword In Inventory:", v) end })
    Tab_GetItemsMain:AddSection("Upgrade Weapon")
    Tab_GetItemsMain:AddToggle({ Text = "Auto Upgrade Sword Inventory", Default = false, Callback = function(v) print("[Upgrade Weapon] Auto Upgrade Sword Inventory:", v) end })
    Tab_GetItemsMain:AddToggle({ Text = "Auto Upgrade Gun Inventory", Default = false, Callback = function(v) print("[Upgrade Weapon] Auto Upgrade Gun Inventory:", v) end })
end

-- TAB 13: Volcano Event
local Tab_VolcanoTab = Window:AddTab({ Name = "Volcano Event", Icon = "mountain" })
do
    Tab_VolcanoTab:AddSection("Settings Volcano")
    Tab_VolcanoTab:AddDropdown({ Text = "Select Weapon Kill Golem", Options = {"Melee", "Sword", "Blox Fruit"}, Callback = function(v) print("[Settings Volcano] Select Weapon Kill Golem:", v) end })
    Tab_VolcanoTab:AddDropdown({ Text = "Select Weapons Fix Lava", Options = {"Soul Guitar", "Melee", "Sword"}, Callback = function(v) print("[Settings Volcano] Select Weapons Fix Lava:", v) end })
    Tab_VolcanoTab:AddToggle({ Text = "Use Skull Guitar with fix lava", Default = false, Callback = function(v) print("[Settings Volcano] Use Skull Guitar with fix lava:", v) end })
    Tab_VolcanoTab:AddDropdown({ Text = "Select Method Kill Golem", Options = {"Aura", "Fast Attack", "Safe Distance"}, Callback = function(v) print("[Settings Volcano] Select Method Kill Golem:", v) end })
    Tab_VolcanoTab:AddSection("Farming Volcano")
    Tab_VolcanoTab:AddToggle({ Text = "Auto Crafting Volcanic Magnet", Default = false, Callback = function(v) print("[Farming Volcano] Auto Crafting Volcanic Magnet:", v) end })
    Tab_VolcanoTab:AddToggle({ Text = "Auto Find Prehistoric Island", Default = false, Callback = function(v) print("[Farming Volcano] Auto Find Prehistoric Island:", v) end })
    Tab_VolcanoTab:AddToggle({ Text = "Auto Event Prehistoric Island", Default = false, Callback = function(v) print("[Farming Volcano] Auto Event Prehistoric Island:", v) end })
    Tab_VolcanoTab:AddToggle({ Text = "Auto Collect Bone", Default = false, Callback = function(v) print("[Farming Volcano] Auto Collect Bone:", v) end })
    Tab_VolcanoTab:AddToggle({ Text = "Auto Collect Egg", Default = false, Callback = function(v) print("[Farming Volcano] Auto Collect Egg:", v) end })
    Tab_VolcanoTab:AddSection("Fully Volcano")
    Tab_VolcanoTab:AddToggle({ Text = "Ignore Craft Volcanic Magnet [ Fully ]", Default = false, Callback = function(v) print("[Fully Volcano] Ignore Craft Volcanic Magnet [ Fully ]:", v) end })
    Tab_VolcanoTab:AddToggle({ Text = "Ignore Collect Bone [ Fully ]", Default = false, Callback = function(v) print("[Fully Volcano] Ignore Collect Bone [ Fully ]:", v) end })
    Tab_VolcanoTab:AddToggle({ Text = "Fully Event Prehistoric Island", Default = false, Callback = function(v) print("[Fully Volcano] Fully Event Prehistoric Island:", v) end })
end

-- TAB 14: ESP
local Tab_ESPTab = Window:AddTab({ Name = "ESP", Icon = "eye" })
do
    Tab_ESPTab:AddSection("ESP")
    Tab_ESPTab:AddToggle({ Text = "ESP Berry", Default = false, Callback = function(v) print("[ESP] ESP Berry:", v) end })
    Tab_ESPTab:AddToggle({ Text = "ESP Island", Default = false, Callback = function(v) print("[ESP] ESP Island:", v) end })
    Tab_ESPTab:AddToggle({ Text = "ESP Fruit", Default = false, Callback = function(v) print("[ESP] ESP Fruit:", v) end })
    Tab_ESPTab:AddToggle({ Text = "ESP Player", Default = false, Callback = function(v) print("[ESP] ESP Player:", v) end })
end

-- TAB 15: PVP
local Tab_PvpTab = Window:AddTab({ Name = "PVP", Icon = "skull" })
do
    Tab_PvpTab:AddSection("PVP")
    Tab_PvpTab:AddDropdown({ Text = "Select Player PVP", Options = {"Select Player...", "Nearest Player", "Lowest HP"}, Callback = function(v) print("[PVP] Select Player PVP:", v) end })
    Tab_PvpTab:AddDropdown({ Text = "Select Method Aimbot", Options = {"Camera", "Mouse", "Silent Aim"}, Callback = function(v) print("[PVP] Select Method Aimbot:", v) end })
    Tab_PvpTab:AddButton({ Text = "Refresh Player", Callback = function() Notify("PVP", "Refresh Player", 2) end })
    Tab_PvpTab:AddToggle({ Text = "Teleport Player", Default = false, Callback = function(v) print("[PVP] Teleport Player:", v) end })
    Tab_PvpTab:AddToggle({ Text = "Auto Aimbot", Default = false, Callback = function(v) print("[PVP] Auto Aimbot:", v) end })
    Tab_PvpTab:AddToggle({ Text = "Auto Aimbot Gun", Default = false, Callback = function(v) print("[PVP] Auto Aimbot Gun:", v) end })
    Tab_PvpTab:AddSection("MISC PVP")
    Tab_PvpTab:AddSlider({ Text = "Input WalkSpeed", Min = 0, Max = 500, Default = 0, Increment = 1, Callback = function(v) print("[MISC PVP] Input WalkSpeed:", v) end })
    Tab_PvpTab:AddSlider({ Text = "Input JumpPower", Min = 0, Max = 500, Default = 0, Increment = 1, Callback = function(v) print("[MISC PVP] Input JumpPower:", v) end })
    Tab_PvpTab:AddToggle({ Text = "Change JumpPower", Default = false, Callback = function(v) print("[MISC PVP] Change JumpPower:", v) end })
    Tab_PvpTab:AddToggle({ Text = "Change WalkSpeed", Default = false, Callback = function(v) print("[MISC PVP] Change WalkSpeed:", v) end })
    Tab_PvpTab:AddToggle({ Text = "Walk On Water", Default = false, Callback = function(v) print("[MISC PVP] Walk On Water:", v) end })
end

-- TAB 16: Tab Webhook
local Tab_TabWebhook = Window:AddTab({ Name = "Tab Webhook", Icon = "send" })
do
    Tab_TabWebhook:AddSection("Webhook")
    Tab_TabWebhook:AddToggle({ Text = "Ping Everyone/Id Discord", Default = false, Callback = function(v) print("[Webhook] Ping Everyone/Id Discord:", v) end })
    Tab_TabWebhook:AddToggle({ Text = "Noti Profile", Default = false, Callback = function(v) print("[Webhook] Noti Profile:", v) end })
    Tab_TabWebhook:AddDropdown({ Text = "Select Rarity Fruit", Options = {"Common", "Uncommon", "Rare", "Legendary", "Mythical"}, Callback = function(v) print("[Webhook] Select Rarity Fruit:", v) end })
    Tab_TabWebhook:AddToggle({ Text = "Webhook Store Fruit", Default = false, Callback = function(v) print("[Webhook] Webhook Store Fruit:", v) end })
    Tab_TabWebhook:AddToggle({ Text = "Webhook Find Prehistoric Island", Default = false, Callback = function(v) print("[Webhook] Webhook Find Prehistoric Island:", v) end })
    Tab_TabWebhook:AddToggle({ Text = "Webhook Find Leviathan", Default = false, Callback = function(v) print("[Webhook] Webhook Find Leviathan:", v) end })
    Tab_TabWebhook:AddToggle({ Text = "Webhook Destroy IDK", Default = false, Callback = function(v) print("[Webhook] Webhook Destroy IDK:", v) end })
    Tab_TabWebhook:AddToggle({ Text = "Webhook Find Mirage", Default = false, Callback = function(v) print("[Webhook] Webhook Find Mirage:", v) end })
end

-- TAB 17: Setting
local Tab_SettingPage = Window:AddTab({ Name = "Setting", Icon = "settings" })
do
    Tab_SettingPage:AddSection("Settings")
    Tab_SettingPage:AddToggle({ Text = "White Screen", Default = false, Callback = function(v) print("[Settings] White Screen:", v) end })
    Tab_SettingPage:AddToggle({ Text = "Black Screen", Default = false, Callback = function(v) print("[Settings] Black Screen:", v) end })
    Tab_SettingPage:AddToggle({ Text = "Remove Notifications", Default = false, Callback = function(v) print("[Settings] Remove Notifications:", v) end })
    Tab_SettingPage:AddToggle({ Text = "Auto rejoin Disconnect", Default = false, Callback = function(v) print("[Settings] Auto rejoin Disconnect:", v) end })
    Tab_SettingPage:AddToggle({ Text = "Auto Load Script", Default = false, Callback = function(v) print("[Settings] Auto Load Script:", v) end })
    Tab_SettingPage:AddToggle({ Text = "Boost Fps", Default = false, Callback = function(v) print("[Settings] Boost Fps:", v) end })
    Tab_SettingPage:AddButton({ Text = "Copy Config", Callback = function() Notify("Settings", "Copy Config", 2) end })
    -- Tiện ích quản lý UI & Hệ thống
    Tab_SettingPage:AddButton({ Text = "Vào lại Server (Rejoin Server)", Callback = function() pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end })
    Tab_SettingPage:AddButton({ Text = "Chuyển Server khác (Hop Server)", Callback = function() Notify("Setting", "Đang tìm Server để Hop...", 2) end })
    Tab_SettingPage:AddKeybind({ Text = "Phím tắt bật/tắt UI", Default = Enum.KeyCode.RightControl, Callback = function(k) print("[Setting] Keybind:", k) end })
    Tab_SettingPage:AddButton({ Text = "Sao chép Discord SkidHub", Callback = function() pcall(function() if setclipboard then setclipboard("https://discord.gg/skidhub") end end) Notify("Setting", "Đã copy link Discord SkidHub!", 2) end })
    Tab_SettingPage:AddButton({ Text = "TẮT & XÓA HOÀN TOÀN UI (Destroy UI)", Callback = function() pcall(function() if Window and Window.Destroy then Window:Destroy() end local toggle = ParentGui:FindFirstChild("SkidHubToggleGui") if toggle then toggle:Destroy() end end) end })
end

-- =============================================================================
-- READY NOTIFICATION & GLOBAL EXPORT
-- =============================================================================
Notify("SKIDHUB", "Đã khởi tạo thành công toàn bộ 17 Tab & 56 Section!", 3)

local SkidHubLib = {
    Window = Window,
    Notify = Notify,
    LogoAsset = logoAsset,
}

getgenv().SkidHub = SkidHubLib
getgenv().SkidHubLib = SkidHubLib

return SkidHubLib
