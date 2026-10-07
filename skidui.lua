--[[
    =============================================================================
    SKIDHUB - BLOX FRUITS UI LIBRARY ADAPTER (v3.0 Production)
    Framework: NullUI Acrylic Glass (Vivid Neon Purple & High Contrast Theme)
    Compatibility: 100% Drop-In Replacement for BananaCat / 3nn_main / SkidHub
    
    API Features:
      - Library.CreateMain(options) -> MainWindow
      - MainWindow:CreatePage(pageOptions) -> Page
      - Page:CreateSection(sectionName) -> Section
      - Section:CreateToggle(toggleOptions, callback)
      - Section:CreateSlider(sliderOptions, callback)
      - Section:CreateDropdown(dropdownOptions, callback)
      - Section:CreateButton(buttonOptions, callback)
      - Section:CreateBox(boxOptions, callback)
      - Section:CreateLabel(labelOptions) -> { SetText = ..., Set = ... }
      - Section:CreateBind(bindOptions, callback)
      - Library.CreateNoti(notiOptions)
      - Library.Notify(title, text, duration)
      - Library.Options (Auto-indexed Flags & Controls)
      - Draggable Floating SkidHub Logo Toggle Button (Mobile & PC)
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
-- LOGO LOADER (Permanent Discord Icon + Executor Cache)
-- =============================================================================
local USER_LOGO_URL = "https://cdn.discordapp.com/icons/1538063104057938020/a4502d108136f8471889bd8542a3906f.png?size=512"
local FALLBACK_RBX_ASSET = "rbxassetid://8068653048"

local function LoadUniversalLogo()
    if getgenv().SkidHubLogoAsset and type(getgenv().SkidHubLogoAsset) == "string" and #getgenv().SkidHubLogoAsset > 0 then
        return getgenv().SkidHubLogoAsset
    end

    local getasset = getcustomasset or getsynasset
    if getasset and writefile and readfile and isfile then
        local ok, asset = pcall(function()
            if not isfolder("SkidHub") then pcall(makefolder, "SkidHub") end
            local fileName = "SkidHub/skidhub_logo_v3.png"
            if not isfile(fileName) or (readfile and #readfile(fileName) < 1000) then
                local fetchOk, imgData = pcall(function() return game:HttpGet(USER_LOGO_URL) end)
                if fetchOk and imgData and #imgData > 1000 then
                    pcall(writefile, fileName, imgData)
                end
            end
            if isfile(fileName) then
                local a = getasset(fileName)
                if a and type(a) == "string" and #a > 0 then return a end
            end
            return nil
        end)
        if ok and asset then
            getgenv().SkidHubLogoAsset = asset
            return asset
        end
    end

    if typeof(loadImage) == "function" then
        local ok, a = pcall(loadImage, USER_LOGO_URL)
        if ok and a then
            getgenv().SkidHubLogoAsset = a
            return a
        end
    end

    getgenv().SkidHubLogoAsset = USER_LOGO_URL
    return USER_LOGO_URL
end

local logoAsset = LoadUniversalLogo() or FALLBACK_RBX_ASSET

-- =============================================================================
-- LOAD & PATCH NULLUI (Acrylic Glass Vivid Neon Purple Theme)
-- =============================================================================
local uiRaw
local fetchSuccess, fetchResult = pcall(function()
    return game:HttpGet("https://pastefy.app/kmZUOJ1A/raw")
end)

if not fetchSuccess or not fetchResult or #fetchResult < 1000 then
    if isfile and isfile("nullui.lua") then
        pcall(function() fetchResult = readfile("nullui.lua") end)
    end
end

if not fetchResult or #fetchResult < 1000 then
    error("[SkidUI] Failed to load NullUI core framework.")
end

uiRaw = fetchResult

local function replaceExact(source, target, replacement)
    local p1, p2 = string.find(source, target, 1, true)
    if p1 and p2 then
        return string.sub(source, 1, p1 - 1) .. replacement .. string.sub(source, p2 + 1)
    end
    return source
end

-- 1. RealKid SAE / SkidHub High-Contrast Vibrant Purple Colors
uiRaw = uiRaw:gsub("Color3%.fromRGB%(29,%s*37,%s*54%)", "Color3.fromRGB(18, 14, 28)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(43,%s*55,%s*78%)", "Color3.fromRGB(26, 20, 38)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(24,%s*31,%s*46%)", "Color3.fromRGB(18, 14, 28)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(156,%s*205,%s*255%)", "Color3.fromRGB(168, 85, 247)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(196,%s*204,%s*220%)", "Color3.fromRGB(185, 170, 210)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(248,%s*250,%s*255%)", "Color3.fromRGB(255, 255, 255)")
uiRaw = uiRaw:gsub("Color3%.fromRGB%(255,%s*148,%s*166%)", "Color3.fromRGB(255, 95, 125)")

-- 2. Window Translucent Purple Acrylic Glass (RealKid SAE Style)
uiRaw = uiRaw:gsub("main%.BackgroundTransparency%s*=%s*1", "main.BackgroundTransparency = 0.05")
uiRaw = uiRaw:gsub("Stroke%(main,%s*Color3%.fromRGB%(238,%s*246,%s*255%),%s*1,%s*0%.64%)", "Stroke(main, Color3.fromRGB(168, 85, 247), 1.5, 0.2)")

-- 3. GlassLayer Rich Purple Tints
uiRaw = uiRaw:gsub("glass%.BackgroundColor3%s*=%s*Color3%.fromRGB%(218,%s*233,%s*255%)", "glass.BackgroundColor3 = Color3.fromRGB(24, 18, 36)")
uiRaw = uiRaw:gsub("prism%.BackgroundColor3%s*=%s*Color3%.fromRGB%(190,%s*220,%s*255%)", "prism.BackgroundColor3 = Color3.fromRGB(168, 85, 247)")

-- 4. LiquidToolbar: Translucent Dark Violet Glass with High Contrast
uiRaw = uiRaw:gsub("toolbar%.BackgroundColor3%s*=%s*Color3%.fromRGB%(221,%s*235,%s*255%)", "toolbar.BackgroundColor3 = Color3.fromRGB(28, 20, 42)")
uiRaw = uiRaw:gsub("toolbar%.BackgroundTransparency%s*=%s*0%.68", "toolbar.BackgroundTransparency = 0.25")
uiRaw = uiRaw:gsub("Stroke%(toolbar,%s*Color3%.fromRGB%(255,%s*255,%s*255%),%s*1,%s*0%.56%)", "Stroke(toolbar, Color3.fromRGB(168, 85, 247), 1, 0.35)")
uiRaw = uiRaw:gsub("toolbarGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(248,%s*252,%s*255%),%s*Color3%.fromRGB%(171,%s*204,%s*255%)%)", "toolbarGradient.Color = ColorSequence.new(Color3.fromRGB(36, 26, 52), Color3.fromRGB(22, 16, 34))")

-- 5. TabBar (Sidebar): Translucent Sleek Glass + Wider 165px for full tab names
uiRaw = uiRaw:gsub("tabBar%.BackgroundColor3%s*=%s*Color3%.fromRGB%(225,%s*238,%s*255%)", "tabBar.BackgroundColor3 = Color3.fromRGB(22, 16, 32)")
uiRaw = uiRaw:gsub("tabBar%.BackgroundTransparency%s*=%s*0%.8", "tabBar.BackgroundTransparency = 0.25")
uiRaw = uiRaw:gsub("Stroke%(tabBar,%s*Color3%.fromRGB%(255,%s*255,%s*255%),%s*1,%s*0%.7%)", "Stroke(tabBar, Color3.fromRGB(168, 85, 247), 1, 0.45)")
uiRaw = uiRaw:gsub("tabGlassGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(244,%s*249,%s*255%),%s*Color3%.fromRGB%(175,%s*205,%s*255%)%)", "tabGlassGradient.Color = ColorSequence.new(Color3.fromRGB(30, 22, 45), Color3.fromRGB(18, 13, 26))")
uiRaw = uiRaw:gsub("tabBar%.Size%s*=%s*UDim2%.new%(0,%s*130,%s*1,%s*%-%(70%s*%+%s*margin%)%)", "tabBar.Size = UDim2.new(0, 165, 1, -(70 + margin))")
uiRaw = uiRaw:gsub("divider%.Position%s*=%s*UDim2%.new%(0,%s*margin%s*%+%s*144,%s*0,%s*70%)", "divider.Position = UDim2.new(0, margin + 179, 0, 70)")
uiRaw = uiRaw:gsub("local%s+contentX%s*=%s*margin%s*%+%s*144%s*%+%s*16", "local contentX = margin + 179 + 16")
uiRaw = uiRaw:gsub("textLabel%.TextSize%s*=%s*14", "textLabel.TextSize = 13")

-- 6. Content Surface: Translucent Deep Purple Acrylic Glass
uiRaw = uiRaw:gsub("contentSurface%.BackgroundColor3%s*=%s*Color3%.fromRGB%(214,%s*230,%s*255%)", "contentSurface.BackgroundColor3 = Color3.fromRGB(20, 15, 30)")
uiRaw = uiRaw:gsub("contentSurface%.BackgroundTransparency%s*=%s*0%.92", "contentSurface.BackgroundTransparency = 0.3")
uiRaw = uiRaw:gsub("Stroke%(contentSurface,%s*Color3%.fromRGB%(255,%s*255,%s*255%),%s*1,%s*0%.84%)", "Stroke(contentSurface, Color3.fromRGB(168, 85, 247), 1, 0.5)")
uiRaw = uiRaw:gsub("contentGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(245,%s*250,%s*255%),%s*Color3%.fromRGB%(144,%s*183,%s*242%)%)", "contentGradient.Color = ColorSequence.new(Color3.fromRGB(28, 20, 42), Color3.fromRGB(18, 13, 28))")

-- 7. Cards: Translucent Elegant Purple Glass Containers
uiRaw = uiRaw:gsub("card%.BackgroundColor3%s*=%s*Color3%.new%(1,%s*1,%s*1%)", "card.BackgroundColor3 = Color3.fromRGB(26, 20, 38)")
uiRaw = uiRaw:gsub("card%.BackgroundTransparency%s*=%s*0%.76", "card.BackgroundTransparency = 0.15")
uiRaw = uiRaw:gsub("Stroke%(card,%s*Color3%.fromRGB%(235,%s*243,%s*255%),%s*1,%s*0%.76%)", "Stroke(card, Color3.fromRGB(75, 52, 105), 1, 0.3)")
uiRaw = uiRaw:gsub("cardGradient%.Color%s*=%s*ColorSequence%.new%(Color3%.fromRGB%(255,%s*255,%s*255%),%s*Color3%.fromRGB%(186,%s*213,%s*255%)%)", "cardGradient.Color = ColorSequence.new(Color3.fromRGB(32, 24, 46), Color3.fromRGB(24, 18, 35))")

-- 8. Toggles & Sliders: Vivid Neon Purple Accent
uiRaw = uiRaw:gsub("state and Color3%.fromRGB%(255,%s*255,%s*255%) or Color3%.fromRGB%(46,%s*50,%s*49%)", "state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(42, 32, 58)")
uiRaw = uiRaw:gsub("knob%.BackgroundColor3%s*=%s*state and Color3%.fromRGB%(18,%s*18,%s*18%) or Color3%.fromRGB%(226,%s*230,%s*228%)", "knob.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 195)")
uiRaw = uiRaw:gsub("knob%.BackgroundColor3%s*=%s*state and Color3%.fromRGB%(18,%s*18,%s*18%) or Color3%.fromRGB%(226,%s*232,%s*240%)", "knob.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 195)")
uiRaw = uiRaw:gsub("fill%.BackgroundColor3%s*=%s*Color3%.new%(1,%s*1,%s*1%)", "fill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)")
uiRaw = uiRaw:gsub("track%.BackgroundColor3%s*=%s*Color3%.new%(1,%s*1,%s*1%)", "track.BackgroundColor3 = Color3.fromRGB(38, 28, 54)")
uiRaw = uiRaw:gsub("track%.BackgroundTransparency%s*=%s*0%.91", "track.BackgroundTransparency = 0")

-- 9. Dropdown MultiSelect & Value Formatting Fix (No table: 0x... leaks)
uiRaw = uiRaw:gsub("local%s+isMulti%s*=%s*opts%.MultiSelect%s*==%s*true", "local isMulti = (opts.MultiSelect == true) or (opts.Multi == true)")
uiRaw = uiRaw:gsub("for%s+_,%s*v%s+in%s+ipairs%(opts%.Default%)%s+do%s+selected%[v%]%s*=%s*true%s+end", [[for k, v in pairs(opts.Default) do
			if v == true then selected[tostring(k)] = true
			elseif type(k) == "number" then selected[tostring(v)] = true end
		end]])
uiRaw = uiRaw:gsub("selected%s*=%s*opts%.Default%s+or%s+options%[1%]", [[if type(opts.Default) == "table" then
		selected = opts.Default[1] or options[1]
	else
		selected = opts.Default or options[1]
	end]])

local oldFmt = "\tlocal function formatValue()\n\t\tif isMulti then\n\t\t\tlocal list = getSelectedList()\n\t\t\tif #list == 0 then return \"None\" end\n\t\t\tif #list == 1 then return list[1] end\n\t\t\treturn #list .. \" selected\"\n\t\tend\n\t\treturn tostring(selected or \"None\")\n\tend"
local newFmt = "\tlocal function formatValue()\n\t\tif isMulti then\n\t\t\tlocal list = getSelectedList()\n\t\t\tif #list == 0 then return \"None\" end\n\t\t\tif #list <= 3 then return table.concat(list, \", \") end\n\t\t\treturn #list .. \" selected\"\n\t\tend\n\t\tif type(selected) == \"table\" then\n\t\t\tlocal list = {}\n\t\t\tfor k, v in pairs(selected) do\n\t\t\t\tif v == true then table.insert(list, tostring(k))\n\t\t\t\telseif type(k) == \"number\" then table.insert(list, tostring(v)) end\n\t\t\tend\n\t\t\tif #list == 0 then return \"None\" end\n\t\t\tif #list <= 3 then return table.concat(list, \", \") end\n\t\t\treturn #list .. \" selected\"\n\t\tend\n\t\treturn tostring(selected or \"None\")\n\tend"
uiRaw = replaceExact(uiRaw, oldFmt, newFmt)

local oldSet = "\t\tSet = function(_, v, silent)\n\t\tif isMulti then\n\t\t\tselected = {}\n\t\t\tif type(v) == \"table\" then\n\t\t\t\tfor _, name in ipairs(v) do selected[name] = true end\n\t\t\tend\n\t\telse\n\t\t\tselected = v\n\t\tend\n\t\tvalueLabel.Text = formatValue()"
local newSet = "\t\tSet = function(_, v, silent)\n\t\tif isMulti then\n\t\t\tselected = {}\n\t\t\tif type(v) == \"table\" then\n\t\t\t\tfor k, val in pairs(v) do\n\t\t\t\t\tif val == true then selected[tostring(k)] = true\n\t\t\t\t\telseif type(k) == \"number\" then selected[tostring(val)] = true end\n\t\t\t\tend\n\t\t\telseif v ~= nil then\n\t\t\t\tselected[tostring(v)] = true\n\t\t\tend\n\t\telse\n\t\t\tif type(v) == \"table\" then\n\t\t\t\tselected = v[1] or tostring(v)\n\t\t\telse\n\t\t\t\tselected = v\n\t\t\tend\n\t\tend\n\t\tvalueLabel.Text = formatValue()"
uiRaw = replaceExact(uiRaw, oldSet, newSet)

-- 10. SkidHub Floating Logo Button
local safeLogoStr = tostring(logoAsset)
uiRaw = uiRaw:gsub('mobileToggle%.Image%s*=%s*"rbxassetid://96220014754961"', function()
    return 'mobileToggle.Image = ' .. string.format("%q", safeLogoStr)
end)
uiRaw = uiRaw:gsub('mobileToggle%.BackgroundTransparency%s*=%s*1', function()
    return 'mobileToggle.BackgroundTransparency = 0.2\n\t\tmobileToggle.BackgroundColor3 = Color3.fromRGB(18, 14, 28)'
end)

local NullUI = loadstring(uiRaw)()

-- =============================================================================
-- LIBRARY ADAPTER EXPORT
-- =============================================================================
local Library = {}
Library.NullUI = NullUI
Library.LogoAsset = logoAsset

Library.Options = setmetatable({}, {
    __index = function(tbl, key)
        return {
            Value = nil,
            Set = function() end,
            SetValue = function() end,
            Get = function() return nil end,
        }
    end
})

function Library.Notify(title_or_opts, text, duration)
    pcall(function()
        if type(title_or_opts) == "table" then
            NullUI:Notify({
                Title = title_or_opts.Title or "SkidHub",
                Text = title_or_opts.Text or title_or_opts.Desc or "",
                Duration = title_or_opts.Duration or title_or_opts.ShowTime or 3,
                Type = "info"
            })
        else
            NullUI:Notify({
                Title = tostring(title_or_opts or "SkidHub"),
                Text = tostring(text or ""),
                Duration = tonumber(duration) or 3,
                Type = "info"
            })
        end
    end)
end

Library.CreateNoti = Library.Notify

local function getIconForTab(name)
    name = string.lower(tostring(name or ""))
    if name:find("shop") then return "shopping-cart"
    elseif name:find("status") or name:find("server") then return "server"
    elseif name:find("player") then return "user"
    elseif name:find("setting") and name:find("farm") then return "sliders"
    elseif name:find("skill") then return "zap"
    elseif name:find("farm") then return "sword"
    elseif name:find("stack") then return "layers"
    elseif name:find("fruit") or name:find("raid") or name:find("dungeon") then return "shield"
    elseif name:find("sea") then return "anchor"
    elseif name:find("race") then return "dna"
    elseif name:find("item") then return "package"
    elseif name:find("volcano") then return "flame"
    elseif name:find("esp") then return "eye"
    elseif name:find("pvp") then return "crosshair"
    elseif name:find("webhook") then return "send"
    elseif name:find("setting") then return "settings"
    else return "layout"
    end
end

function Library.CreateMain(options)
    options = options or {}
    local winTitle = options.Title or "SkidHub"
    local winSub = options.Desc or options.Subtitle or "Blox Fruits"

    local Window = NullUI:CreateWindow({
        Title = winTitle,
        Subtitle = winSub,
        Size = UDim2.fromOffset(685, 460),
        MinSize = Vector2.new(520, 370),
        Draggable = true,
        Resizable = true,
        UseBlur = true,
        DefaultTab = "Shop",
        ToggleKeybind = Enum.KeyCode.RightControl,
        TogglePosition = UDim2.fromOffset(20, 220),
    })

    -- 1. TopBar & Logo Decoration
    pcall(function()
        if Window and Window._gui then
            local win = Window._gui
            local topbar = win:FindFirstChild("TopBar")
            local toolbar = topbar and topbar:FindFirstChild("LiquidToolbar")
            if toolbar then
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
                    title.Text = "SkidHub"
                    title.TextColor3 = Color3.fromRGB(255, 255, 255)
                    pcall(function() title.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Bold) end)
                end

                local subtitle = toolbar:FindFirstChild("Subtitle")
                if subtitle then
                    subtitle.Position = UDim2.fromOffset(54, 27)
                    subtitle.Text = tostring(winSub)
                    subtitle.TextColor3 = Color3.fromRGB(216, 180, 254)
                end
            end
        end
    end)

    -- 2. Draggable Floating Logo Button (Mobile & PC)
    pcall(function()
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

        local pulse = TweenService:Create(btnStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Color = Color3.fromRGB(216, 180, 254),
            Transparency = 0.4
        })
        pulse:Play()

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
                if delta.Magnitude > 6 then hasMoved = true end
                toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        toggleBtn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            TweenService:Create(toggleBtn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(44, 44) }):Play()
            task.wait(0.08)
            TweenService:Create(toggleBtn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(50, 50) }):Play()

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
    end)

    -- Phím tắt RightControl
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            if Window and Window._gui then
                Window._gui.Visible = not Window._gui.Visible
            elseif Window and Window.Toggle then
                Window:Toggle()
            end
        end
    end)

    local function createSectionWrapper(Tab, secName)
        if secName and secName ~= "" then
            pcall(function() Tab:AddSection(tostring(secName)) end)
        end

        local SectionHandler = {}

        -- 1. CreateToggle
        local function CreateToggle(arg1, arg2, arg3)
            local cfg = (type(arg1) == "table" and arg1) or (type(arg2) == "table" and arg2) or {}
            local cb = (type(arg2) == "function" and arg2) or (type(arg3) == "function" and arg3) or cfg.Callback

            local title = cfg.Title or cfg.Text or cfg.Name or "Toggle"
            local defaultVal = cfg.Default or false

            local rawCtrl
            pcall(function()
                rawCtrl = Tab:AddToggle({
                    Text = title,
                    Default = defaultVal,
                    Callback = function(v)
                        if cb then
                            task.spawn(function()
                                local ok, err = pcall(cb, v)
                                if not ok then warn("[SkidUI Error] Toggle (" .. tostring(title) .. "):", err) end
                            end)
                        end
                    end
                })
            end)

            local ctrlObj = {
                Instance = rawCtrl and rawCtrl.Instance,
                Set = function(_, v, silent)
                    if rawCtrl and rawCtrl.Set then pcall(function() rawCtrl:Set(v, silent) end) end
                end,
                SetValue = function(self, v) self:Set(v) end,
                Get = function()
                    if rawCtrl and rawCtrl.Get then return rawCtrl:Get() end
                    return defaultVal
                end
            }

            if title then
                Library.Options[title] = ctrlObj
            end
            return ctrlObj
        end
        SectionHandler.CreateToggle = CreateToggle
        SectionHandler.AddToggle = CreateToggle

        -- 2. CreateSlider
        local function CreateSlider(arg1, arg2, arg3)
            local cfg = (type(arg1) == "table" and arg1) or (type(arg2) == "table" and arg2) or {}
            local cb = (type(arg2) == "function" and arg2) or (type(arg3) == "function" and arg3) or cfg.Callback

            local title = cfg.Title or cfg.Text or "Slider"
            local minVal = cfg.Min or cfg.MinValue or cfg.min or 0
            local maxVal = cfg.Max or cfg.MaxValue or cfg.max or 100
            local defVal = cfg.Default or cfg.Value or minVal
            local incVal = cfg.Increment or cfg.Rounding or 1

            local rawCtrl
            pcall(function()
                rawCtrl = Tab:AddSlider({
                    Text = title,
                    Min = minVal,
                    Max = maxVal,
                    Default = defVal,
                    Increment = incVal,
                    Callback = function(v)
                        if cb then
                            task.spawn(function()
                                local ok, err = pcall(cb, v)
                                if not ok then warn("[SkidUI Error] Slider (" .. tostring(title) .. "):", err) end
                            end)
                        end
                    end
                })
            end)

            local ctrlObj = {
                Instance = rawCtrl and rawCtrl.Instance,
                Set = function(_, v, silent)
                    if rawCtrl and rawCtrl.Set then pcall(function() rawCtrl:Set(v, silent) end) end
                end,
                SetValue = function(self, v) self:Set(v) end,
                Get = function()
                    if rawCtrl and rawCtrl.Get then return rawCtrl:Get() end
                    return defVal
                end
            }

            if title then
                Library.Options[title] = ctrlObj
            end
            return ctrlObj
        end
        SectionHandler.CreateSlider = CreateSlider
        SectionHandler.AddSlider = CreateSlider

        -- 3. CreateDropdown
        local function CreateDropdown(arg1, arg2, arg3)
            local cfg = (type(arg1) == "table" and arg1) or (type(arg2) == "table" and arg2) or {}
            local cb = (type(arg2) == "function" and arg2) or (type(arg3) == "function" and arg3) or cfg.Callback

            local title = cfg.Title or cfg.Text or "Dropdown"
            local rawList = cfg.List or cfg.Options or {}

            -- Special Handler for Slider-Dropdowns (e.g. Hold Skills Set Delay)
            if cfg.Slider == true and type(rawList) == "table" then
                local sliderMap = {}
                for k, v in pairs(rawList) do
                    if type(v) == "table" then
                        local keyName = tostring(v.KeyName or v.Title or k)
                        local sliderTitle = title .. " [" .. keyName .. "]"
                        local minVal = tonumber(v.Min) or 0
                        local maxVal = tonumber(v.Max) or 5
                        local defVal = tonumber(v.Default) or 0.5
                        local sCtrl = SectionHandler.CreateSlider({
                            Title = sliderTitle,
                            Min = minVal,
                            Max = maxVal,
                            Default = defVal,
                            Callback = function(num)
                                v.Default = num
                                if cb then
                                    task.spawn(function()
                                        pcall(cb, v, v)
                                    end)
                                end
                            end
                        })
                        sliderMap[keyName] = sCtrl
                    end
                end
                return {
                    Instance = nil,
                    Set = function(_, k, v) if sliderMap[k] and sliderMap[k].Set then sliderMap[k]:Set(v) end end,
                    Get = function() return nil end,
                    Refresh = function() end,
                }
            end

            local optList = {}
            local isMultiDict = false
            local defaultVal = cfg.Default

            if type(rawList) == "table" then
                for k, v in pairs(rawList) do
                    if type(k) ~= "number" then
                        table.insert(optList, tostring(k))
                        if type(v) == "boolean" then isMultiDict = true end
                    else
                        table.insert(optList, tostring(v))
                    end
                end
                table.sort(optList)
            end

            local isMulti = (cfg.Multi == true) or (cfg.MultiSelect == true) or (cfg.Selected == true) or (isMultiDict == true)
            local currentSelections = {}
            if type(defaultVal) == "table" then
                for k, v in pairs(defaultVal) do
                    if v == true or type(k) == "number" then
                        currentSelections[tostring(type(k) == "number" and v or k)] = true
                    end
                end
            elseif defaultVal ~= nil and defaultVal ~= "" then
                currentSelections[tostring(defaultVal)] = true
            end

            local initialDefault
            if isMulti then
                local t = {}
                for k, _ in pairs(currentSelections) do table.insert(t, k) end
                table.sort(t)
                initialDefault = t
            else
                if type(defaultVal) == "table" then
                    initialDefault = defaultVal[1] or optList[1]
                else
                    initialDefault = defaultVal or optList[1]
                end
            end

            local rawCtrl
            pcall(function()
                rawCtrl = Tab:AddDropdown({
                    Text = title,
                    Options = optList,
                    MultiSelect = isMulti,
                    Multi = isMulti,
                    Default = initialDefault,
                    Callback = function(newVal)
                        if cb then
                            task.spawn(function()
                                if isMulti then
                                    if type(newVal) == "table" then
                                        local newMap = {}
                                        for _, item in ipairs(newVal) do newMap[tostring(item)] = true end
                                        for _, opt in ipairs(optList) do
                                            local oldState = currentSelections[opt] == true
                                            local newState = newMap[opt] == true
                                            if oldState ~= newState then
                                                currentSelections[opt] = newState and true or nil
                                                pcall(cb, opt, newState)
                                            end
                                        end
                                    else
                                        pcall(cb, tostring(newVal), true)
                                    end
                                else
                                    pcall(cb, newVal)
                                end
                            end)
                        end
                    end
                })
            end)

            local ctrlObj = {
                Instance = rawCtrl and rawCtrl.Instance,
                Set = function(_, v, silent)
                    if rawCtrl and rawCtrl.Set then pcall(function() rawCtrl:Set(v, silent) end) end
                end,
                SetValue = function(self, v) self:Set(v) end,
                Refresh = function(_, newList)
                    local freshList = {}
                    if type(newList) == "table" then
                        for k, v in pairs(newList) do
                            table.insert(freshList, tostring(type(k) == "number" and v or k))
                        end
                        table.sort(freshList)
                    end
                    if rawCtrl and rawCtrl.Refresh then
                        pcall(function() rawCtrl:Refresh(freshList) end)
                    end
                end,
                Get = function()
                    if rawCtrl and rawCtrl.Get then return rawCtrl:Get() end
                    return defaultVal
                end
            }

            if title then
                Library.Options[title] = ctrlObj
            end
            return ctrlObj
        end
        SectionHandler.CreateDropdown = CreateDropdown
        SectionHandler.AddDropdown = CreateDropdown

        -- 4. CreateButton
        local function CreateButton(arg1, arg2, arg3)
            local cfg = (type(arg1) == "table" and arg1) or (type(arg2) == "table" and arg2) or {}
            local cb = (type(arg2) == "function" and arg2) or (type(arg3) == "function" and arg3) or cfg.Callback
            local title = cfg.Title or cfg.Text or "Button"

            local rawCtrl
            pcall(function()
                rawCtrl = Tab:AddButton({
                    Text = title,
                    Callback = function()
                        if cb then task.spawn(cb) end
                    end
                })
            end)

            return { Instance = rawCtrl and rawCtrl.Instance }
        end
        SectionHandler.CreateButton = CreateButton
        SectionHandler.AddButton = CreateButton

        -- 5. CreateLabel
        local function CreateLabel(arg1, arg2)
            local cfg = (type(arg1) == "table" and arg1) or { Title = tostring(arg1 or arg2 or "") }
            local title = cfg.Title or cfg.Text or ""

            local rawCtrl
            pcall(function()
                rawCtrl = Tab:AddLabel(title)
            end)

            local ctrlObj = {}
            function ctrlObj.SetText(text_or_self, text)
                local t = (type(text) == "string" and text) or (type(text_or_self) == "string" and text_or_self) or tostring(text or text_or_self or "")
                if rawCtrl and rawCtrl.Set then pcall(function() rawCtrl:Set(t) end) end
                if rawCtrl and rawCtrl.Instance then pcall(function() rawCtrl.Instance.Text = t end) end
            end
            ctrlObj.Set = ctrlObj.SetText

            return ctrlObj
        end
        SectionHandler.CreateLabel = CreateLabel
        SectionHandler.AddLabel = CreateLabel

        -- 6. CreateBox / CreateInput
        local function CreateBox(arg1, arg2, arg3)
            local cfg = (type(arg1) == "table" and arg1) or (type(arg2) == "table" and arg2) or {}
            local cb = (type(arg2) == "function" and arg2) or (type(arg3) == "function" and arg3) or cfg.Callback
            local title = cfg.Title or cfg.Text or "Input"
            local placeholder = cfg.Placeholder or "Type here..."

            local rawCtrl
            pcall(function()
                rawCtrl = Tab:AddTextbox({
                    Text = title,
                    Placeholder = placeholder,
                    ClearOnFocus = false,
                    Callback = function(v)
                        if cb then task.spawn(cb, v) end
                    end
                })
            end)

            return {
                Instance = rawCtrl and rawCtrl.Instance,
                Set = function(_, v)
                    if rawCtrl and rawCtrl.Set then pcall(function() rawCtrl:Set(v) end) end
                end
            }
        end
        SectionHandler.CreateBox = CreateBox
        SectionHandler.CreateInput = CreateBox
        SectionHandler.AddInput = CreateBox

        -- 7. CreateBind
        local function CreateBind(arg1, arg2, arg3)
            local cfg = (type(arg1) == "table" and arg1) or (type(arg2) == "table" and arg2) or {}
            local cb = (type(arg2) == "function" and arg2) or (type(arg3) == "function" and arg3) or cfg.Callback
            local title = cfg.Title or cfg.Text or "Keybind"
            local defKey = cfg.Default or Enum.KeyCode.E

            local rawCtrl
            pcall(function()
                rawCtrl = Tab:AddKeybind({
                    Text = title,
                    Default = defKey,
                    Callback = function(v)
                        if cb then task.spawn(cb, v) end
                    end
                })
            end)

            return { Instance = rawCtrl and rawCtrl.Instance }
        end
        SectionHandler.CreateBind = CreateBind
        SectionHandler.AddKeyBind = CreateBind

        -- Safety Stubs
        SectionHandler.FindFirstChild = function() return nil end
        SectionHandler.GetChildren = function() return {} end

        return SectionHandler
    end

    local MainHandler = {}

    local function CreatePage(self_or_cfg, cfg)
        local pageCfg = (type(self_or_cfg) == "table" and (self_or_cfg.Page_Name or self_or_cfg.Name or self_or_cfg.Title) and self_or_cfg) or cfg or {}
        local tabName = pageCfg.Page_Name or pageCfg.Name or pageCfg.Title or "Tab"
        local tabIcon = getIconForTab(tabName)

        local Tab = Window:AddTab({ Name = tabName, Icon = tabIcon })
        local defaultSec = createSectionWrapper(Tab, "")

        local PageHandler = {
            CreateSection = function(_, name) return createSectionWrapper(Tab, name) end,
            AddSection = function(_, name) return createSectionWrapper(Tab, name) end,
            CreateToggle = function(_, ...) return defaultSec.CreateToggle(...) end,
            CreateSlider = function(_, ...) return defaultSec.CreateSlider(...) end,
            CreateDropdown = function(_, ...) return defaultSec.CreateDropdown(...) end,
            CreateButton = function(_, ...) return defaultSec.CreateButton(...) end,
            CreateBox = function(_, ...) return defaultSec.CreateBox(...) end,
            CreateLabel = function(_, ...) return defaultSec.CreateLabel(...) end,
            CreateBind = function(_, ...) return defaultSec.CreateBind(...) end,
            FindFirstChild = function() return nil end,
            GetChildren = function() return {} end,
        }

        return PageHandler
    end

    MainHandler.CreatePage = CreatePage
    MainHandler.AddPage = CreatePage
    MainHandler.CreateSection = function(_, name) return MainHandler:CreatePage({ Page_Name = "Main" }):CreateSection(name) end
    MainHandler.FindFirstChild = function() return nil end
    MainHandler.GetChildren = function() return {} end
    MainHandler._window = Window

    return MainHandler
end

Library.CreateWindow = Library.CreateMain

return Library
