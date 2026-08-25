if not game:IsLoaded() then
	game.Loaded:Wait()
end

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
_G.TweenSpeed = _G.TweenSpeed or 280

local t1 = {
	Key = "",
	ExpiryTime = 0,
	IsAuthenticated = false,
}

local function v11()
	if writefile then
		pcall(function()
			writefile("MarisHub_KeyData.json", HttpService:JSONEncode(t1))
		end)
	end
end

(function()
	if writefile and readfile and isfile and isfile("MarisHub_KeyData.json") then
		local ok, result = pcall(function()
			local function v122(...)
				local t2 = { ... }
				t2.n = select("#", ...)
				return t2
			end
			local v124 = v122(readfile("MarisHub_KeyData.json"))
			local v127 = v122(HttpService:JSONDecode(unpack(v124, 1, v124.n)))
			return unpack(v127, 1, v127.n)
		end)

		if ok and result then
			t1 = result
		end
	end
end)()

local function u12()
	local function v37(...)
		local t3 = { ... }
		t3.n = select("#", ...)
		return t3
	end

	print("SUCCESS! Running Main Script...")

	local g39 = nil

	repeat
		task.wait(0.5)
	until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui")

	if getgenv().WARCLOADER then
		StarterGui:SetCore("SendNotification", {
			Title = "Execution Blocked",
			Text = "The script is already running. Please wait 10 seconds",
			Duration = 5,
		})
		return
	end

	getgenv().WARCLOADER = true
	task.delay(10, function()
		getgenv().WARCLOADER = nil
	end)

	cloneref = cloneref or (clonereference or function(p1) return p1 end)
	isnetworkowner = isnetworkowner or (isNetworkOwner or function() return true end)

	local v38 = cloneref(workspace)

	repeat
		repeat
			repeat
				repeat
					if g39 or (g39 or (g39 or (g39 or v38))) then
						g39 = false
						workspace = v38

						local PlaceId2 = game.PlaceId
						local JobId2 = game.JobId

						PlaceId = PlaceId2
						JobId = JobId2
						getfenv = getfenv or (_G or (_ENV or (shared or function() return {} end)))
						IsOnMobile = false

						local t4 = {
							__index = function(p2, p3)
								local u133 = p3
								local v134, v135 = pcall(function()
									return cloneref(game:GetService(u133))
								end)

								if not v134 then
									error("Invalid Roblox Service: " .. tostring(p3))
									return
								end

								rawset(p2, p3, v135)
								return v135
							end,
						}

						Services = setmetatable({}, t4)
						COREGUI = Services.CoreGui
						RunService = Services.RunService
						VirtualUser = Services.VirtualUser
						TweenService = Services.TweenService
						HttpService = Services.HttpService
						Players = Services.Players
						ReplicatedStorage = Services.ReplicatedStorage
						Lighting = Services.Lighting
						CollectionService = Services.CollectionService
						UserInputService = Services.UserInputService
						VirtualInputManager = Services.VirtualInputManager
						ReplicatedFirst = Services.ReplicatedFirst
						StarterGui = Services.StarterGui
						GuiService = Services.GuiService
						TeleportService = Services.TeleportService
						COMMF_ = ReplicatedStorage:WaitForChild("Remotes") and ReplicatedStorage.Remotes:WaitForChild("CommF_")
						LocalPlayer = Players.LocalPlayer

						LocalPlayer.CharacterAdded:Connect(function(character)
							Character = character
							Humanoid = character:WaitForChild("Humanoid")
							HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
						end)

						if LocalPlayer.Character then
							Character = LocalPlayer.Character
							Humanoid = Character:FindFirstChildWhichIsA("Humanoid") or Character:WaitForChild("Humanoid")
							HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
						end

						if not COMMF_ then
							repeat
								task.wait(1)
							until COMMF_
						end

						-- [REPAIR P2] GuideModule validation
						pcall(function()
							if ReplicatedStorage:FindFirstChild("GuideModule") then
								local _gOk, _gData = pcall(require, ReplicatedStorage.GuideModule)
								if _gOk and _gData and _gData.Data and _gData.Data.NPCList then
									warn("[BOOT] GuideModule OK, NPCList entries:", #_gData.Data.NPCList)
								else
									warn("[BOOT] GuideModule: require/Data/NPCList issue")
								end
							else
								warn("[BOOT] GuideModule not found")
							end
						end)

						task.spawn(function()
							xpcall(function()
								gethui().IgnoreGuiInset = true
							end, function(_)
								xpcall(function()
									local v396 = COREGUI:FindFirstChild("ScreenGUI") or Instance.new("ScreenGui", COREGUI)
									v396.Name = "ScreenGUI"
									v396.IgnoreGuiInset = true
									local u399 = v396

									hookfunction(gethui, function()
										return u399
									end)
									task.delay(5, function()
										StarterGui:SetCore("SendNotification", {
											Title = "Incompatible Executor",
											Text = "This executor may cause errors while running the script\n[ERROR CODE: UIGE]",
											Duration = 20,
										})
									end)
								end, function()
									warn("???")
								end)
							end)
						end)

						task.spawn(function()
							xpcall(function()
								local v314 = getgenv and (getgenv().Settings and getgenv().Settings.Team) or "Pirates"

								if not LocalPlayer.Team or v314 ~= LocalPlayer.Team.Name then
									if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") then
										repeat
											task.wait(1)
										until not LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen")
									end
									local u316 = v314
									local u317 = v314

									xpcall(function()
										COMMF_:InvokeServer("SetTeam", u316)
									end, function()
										firesignal(LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container[u317])
									end)
									task.wait(2)
								end
							end, function(err)
								warn("????", err)
							end)
						end)

						repeat
							task.wait(2)
						until Character
							and Character:FindFirstChild("HumanoidRootPart")
							and Character:FindFirstChildWhichIsA("Humanoid")
							and Character:IsDescendantOf(workspace.Characters)

						pcall(function()
							LocalPlayer.PlayerGui:FindFirstChild("Blank"):Destroy()
						end)

						-- [[ REAL-TIME DYNAMIC ISLAND UI ]]
						local TextService = game:GetService("TextService")
						local function InitDynamicIsland()
							local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

							local existing = PlayerGui:FindFirstChild("DynamicIslandGui")
							if existing then
								existing:Destroy()
							end

							local ScreenGui = Instance.new("ScreenGui")
							ScreenGui.Name = "DynamicIslandGui"
							ScreenGui.ResetOnSpawn = false
							ScreenGui.IgnoreGuiInset = true
							ScreenGui.Parent = PlayerGui

							local Island = Instance.new("Frame")
							Island.Name = "Island"
							Island.AnchorPoint = Vector2.new(0.5, 0)
							Island.Position = UDim2.new(0.5, 0, 0, 12)
							Island.Size = UDim2.new(0, 36, 0, 36)
							Island.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
							Island.BackgroundTransparency = 0.15
							Island.BorderSizePixel = 0
							Island.ClipsDescendants = true
							Island.Parent = ScreenGui

							local IslandCorner = Instance.new("UICorner")
							IslandCorner.CornerRadius = UDim.new(1, 0)
							IslandCorner.Parent = Island

							local IslandStroke = Instance.new("UIStroke")
							IslandStroke.Color = Color3.fromRGB(60, 60, 70)
							IslandStroke.Thickness = 1.2
							IslandStroke.Transparency = 0.3
							IslandStroke.Parent = Island

							local ColorRed = Color3.fromRGB(255, 69, 58)
							local ColorGreen = Color3.fromRGB(52, 199, 89)
							local ColorYellow = Color3.fromRGB(255, 204, 0)
							local ColorBlue = Color3.fromRGB(120, 180, 255)

							local StatusDot = Instance.new("Frame")
							StatusDot.Name = "StatusDot"
							StatusDot.AnchorPoint = Vector2.new(0, 0.5)
							StatusDot.Position = UDim2.new(0, 13, 0.5, 0)
							StatusDot.Size = UDim2.new(0, 10, 0, 10)
							StatusDot.BackgroundColor3 = ColorGreen
							StatusDot.BorderSizePixel = 0
							StatusDot.Parent = Island

							local DotCorner = Instance.new("UICorner")
							DotCorner.CornerRadius = UDim.new(1, 0)
							DotCorner.Parent = StatusDot

							local StatusLabel = Instance.new("TextLabel")
							StatusLabel.Name = "StatusLabel"
							StatusLabel.BackgroundTransparency = 1
							StatusLabel.Size = UDim2.new(1, -45, 1, 0)
							StatusLabel.Position = UDim2.new(0, 31, 0, 0)
							StatusLabel.Font = Enum.Font.GothamBold
							StatusLabel.TextSize = 15
							StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
							StatusLabel.TextTransparency = 1
							StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
							StatusLabel.Text = ""
							StatusLabel.Parent = Island

							local currentStatusText = ""
							local currentStatusColor = nil
							local statusUpdateId = 0

							local function SetStatus(text, color, duration)
								text = tostring(text or "")
								color = color or ColorGreen

								if text == currentStatusText and color == currentStatusColor then
									return
								end

								currentStatusText = text
								currentStatusColor = color
								statusUpdateId = statusUpdateId + 1
								local myId = statusUpdateId

								task.spawn(function()
									StatusLabel.Text = text
									StatusDot.BackgroundColor3 = color

									local textSize = TextService:GetTextSize(text, 15, Enum.Font.GothamBold, Vector2.new(1000, 36))
									local targetWidth = math.max(160, textSize.X + 54)

									local expandTween = TweenService:Create(Island, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										Size = UDim2.new(0, targetWidth, 0, 36)
									})
									local cornerTween = TweenService:Create(IslandCorner, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										CornerRadius = UDim.new(0, 18)
									})
									local textFadeIn = TweenService:Create(StatusLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										TextTransparency = 0
									})

									expandTween:Play()
									cornerTween:Play()
									textFadeIn:Play()

									if duration and duration > 0 then
										task.wait(duration)
										if statusUpdateId == myId then
											local textFadeOut = TweenService:Create(StatusLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
												TextTransparency = 1
											})
											local collapseTween = TweenService:Create(Island, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
												Size = UDim2.new(0, 36, 0, 36)
											})
											local cornerReset = TweenService:Create(IslandCorner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
												CornerRadius = UDim.new(1, 0)
											})

											textFadeOut:Play()
											task.wait(0.1)
											collapseTween:Play()
											cornerReset:Play()
											task.wait(0.2)
											if statusUpdateId == myId then
												StatusLabel.Text = ""
												currentStatusText = ""
											end
										end
									end
								end)
							end

							_G.SetStatus = SetStatus
							_G.popStatus = SetStatus
							_G.islandUI = Island

							return SetStatus
						end

						local u63 = InitDynamicIsland()
						local popStatus = u63

						-- [[ Thông báo khởi động & Mời tham gia server Discord (Song ngữ Anh - Việt) ]]
						task.spawn(function()
							pcall(function()
								if setclipboard then
									setclipboard("https://discord.gg/ZxpK2EcZ2G")
								end
							end)
							u63("SKID HUB - CYBORG A-Z LOADED!", Color3.fromRGB(52, 199, 89), 2.5)
							task.wait(2.6)
							u63("Join Discord for Updates: discord.gg/ZxpK2EcZ2G", Color3.fromRGB(120, 180, 255), 3)
							task.wait(3.1)
							u63("Tham gia Discord để nhận Update: discord.gg/ZxpK2EcZ2G", Color3.fromRGB(255, 204, 0), 3)
						end)

						local v64 = LocalPlayer.Name .. ".txt"
						if not isfile(v64) then
							writefile(v64, "NaN")
						end

						local function v65()
							if game.PlaceId ~= 2753915549 then
								if game.PlaceId ~= 4442272183 then
									if game.PlaceId ~= 7449423635 then
										local MAP = workspace:GetAttribute("MAP")
										if not MAP or not MAP:match("1") then
											if not MAP or not MAP:match("2") then
												if not MAP or not MAP:match("3") then
													return 2
												end
												return 3
											end
											return 2
										end
										return 1
									end
									return 3
								end
								return 2
							end
							return 1
						end

						local u66 = nil
						local u67 = nil
						local u68 = 0
						do
							local _seedOk, _seedVal = pcall(function()
								local netMod = ReplicatedStorage:FindFirstChild("Modules")
								if not netMod then return 0 end
								local net = netMod:FindFirstChild("Net")
								if not net then return 0 end
								local seed = net:FindFirstChild("seed")
								if not seed then return 0 end
								if seed:IsA("RemoteFunction") then
									return seed:InvokeServer()
								end
								return 0
							end)
							if _seedOk and type(_seedVal) == "number" then
								u68 = _seedVal
								warn("[BOOT] seed:InvokeServer OK =", u68)
							else
								warn("[BOOT] seed:InvokeServer FAILED, using fallback. Error:", tostring(_seedVal))
								u68 = 0
							end
						end

						-- [REPAIR P4] RE discovery with protected folder access + timeout validation
						task.spawn(function()
							local _reOk, _reErr = pcall(function()
								local _next = next
								local t5 = {}
								local function _safeChild(name)
									local c = ReplicatedStorage:FindFirstChild(name)
									if c then table.insert(t5, c) end
								end
								_safeChild("Util")
								_safeChild("Common")
								_safeChild("Remotes")
								_safeChild("Assets")
								_safeChild("FX")

								for _, v157 in _next, t5 do
									for _, v in next, v157:GetChildren() do
										if v:IsA("RemoteEvent") and v:GetAttribute("Id") then
											local Id = v:GetAttribute("Id")
											u66 = v
											u67 = Id
										end
									end

									v157.ChildAdded:Connect(function(child)
										if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
											local Id = child:GetAttribute("Id")
											u66 = child
											u67 = Id
										end
									end)
								end
							end)
							if not _reOk then
								warn("[BOOT] RE discovery error:", tostring(_reErr))
							end
							task.delay(10, function()
								if u66 and u67 then
									warn("[BOOT] Dynamic RE discovered:", u66.Name, "Id:", u67)
								else
									warn("[BOOT] WARNING: Dynamic RE (u66/u67) NOT found after 10s - secondary fire disabled")
								end
							end)
						end)

						function CheckLocation(p9)
							return p9 == LocalPlayer:GetAttribute("CurrentLocation")
						end

						function CheckMap(p10)
							return workspace.Map:FindFirstChild(p10) or false
						end

						-- [REPAIR P3] Safe workspace accessors
						function FindRaidButton()
							local ok, result = pcall(function()
								local m = workspace:FindFirstChild("Map")
								if not m then return nil end
								local ci = m:FindFirstChild("CircleIsland")
								if not ci then return nil end
								local rs = ci:FindFirstChild("RaidSummon")
								if not rs then return nil end
								local b = rs:FindFirstChild("Button")
								if not b then return nil end
								local mn = b:FindFirstChild("Main")
								if not mn then return nil end
								return mn:FindFirstChild("ClickDetector")
							end)
							return ok and result or nil
						end

						function SafeFireRaid()
							local cd = FindRaidButton()
							if cd then
								pcall(fireclickdetector, cd)
							else
								warn("[CYBORG] RaidSummon ClickDetector not found")
							end
						end

						function FindFlower(idx)
							local flowerName = "Flower" .. tostring(idx)
							local f = workspace:FindFirstChild(flowerName)
							if f and (f:IsA("BasePart") or f:IsA("Model")) then
								if f:IsA("BasePart") and f.Transparency >= 0.95 then
									return nil
								end
								return f
							end
							for _, v in ipairs(workspace:GetChildren()) do
								if v.Name == flowerName and (v:IsA("BasePart") or v:IsA("Model")) then
									if v:IsA("BasePart") and v.Transparency >= 0.95 then
										return nil
									end
									return v
								end
							end
							return nil
						end

						function CheckTool(p11)
							local target = tostring(p11):lower()
							local Backpack = LocalPlayer.Backpack
							if Backpack then
								for _, v in ipairs(Backpack:GetChildren()) do
									if v:IsA("Tool") then
										local nameLower = v.Name:lower()
										local tipLower = (v.ToolTip and v.ToolTip:lower()) or ""
										if nameLower == target or nameLower:find(target, 1, true) or tipLower:find(target, 1, true) then
											return true
										end
									end
								end
							end
							if Character then
								for _, v in ipairs(Character:GetChildren()) do
									if v:IsA("Tool") then
										local nameLower = v.Name:lower()
										local tipLower = (v.ToolTip and v.ToolTip:lower()) or ""
										if nameLower == target or nameLower:find(target, 1, true) or tipLower:find(target, 1, true) then
											return true
										end
									end
								end
							end
							return false
						end

						function CheckMaterial(p12)
							local ok, inv = pcall(function() return COMMF_:InvokeServer("getInventory") end)
							if ok and type(inv) == "table" then
								for _, v in pairs(inv) do
									if v.Type == "Material" and p12 == v.Name then
										return v.Count or 1
									end
								end
							end
							return 0
						end

						function CheckInventory(...)
							local names = { ... }
							local ok, inv = pcall(function() return COMMF_:InvokeServer("getInventory") end)
							if not ok or type(inv) ~= "table" then
								return false
							end
							for _, item in pairs(inv) do
								for _, n in ipairs(names) do
									if item.Name == n or (item.Name and item.Name:lower():find(tostring(n):lower(), 1, true)) then
										return true
									end
								end
							end
							return false
						end

						function KillAura(p17)
							pcall(function()
								setscriptable(LocalPlayer, "SimulationRadius", true)
							end)
							pcall(function()
								sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
							end)

							for _, v in next, workspace.Enemies:GetChildren() do
								pcall(function()
									local v328 = v:FindFirstChild("HumanoidRootPart")
									if v328 and HumanoidRootPart and (v328.Position - HumanoidRootPart.Position).Magnitude <= 1250 and (not p17 or v.Name == p17) then
										local hum = v:FindFirstChildOfClass("Humanoid")
										if hum then
											hum:ChangeState(Enum.HumanoidStateType.Dead)
										end
									end
								end)
							end
						end

						local u69 = v65

						function CheckMoon()
							local v190 = u69()
							local v191 = (
								v190 ~= 2
									and (game.Lighting:FindFirstChild("Sky") and game.Lighting.Sky.MoonTextureId or game.Lighting:FindFirstChild("Space_Skybox") and game.Lighting.Space_Skybox.MoonTextureId)
								or (v190 == 2 and (game.Lighting:FindFirstChild("FantasySky") and game.Lighting.FantasySky.MoonTextureId) or "")
							):gsub("rbxassetid://", "http://www.roblox.com/asset/?id=")

							return ({
								["http://www.roblox.com/asset/?id=15493317929"] = "Blue Moon",
								["http://www.roblox.com/asset/?id=9709149431"] = "8/8",
								["http://www.roblox.com/asset/?id=9709149052"] = "7/8",
								["http://www.roblox.com/asset/?id=9709143733"] = "6/8",
								["http://www.roblox.com/asset/?id=9709150401"] = "5/8",
								["http://www.roblox.com/asset/?id=9709135895"] = "4/8",
								["http://www.roblox.com/asset/?id=9709150086"] = "2/8",
								["http://www.roblox.com/asset/?id=9709139597"] = "1/8",
								["http://www.roblox.com/asset/?id=9709149680"] = "0/8",
							})[v191] or "nil"
						end

						function CheckMonster(...)
							local names = { ... }
							local enemies = workspace:FindFirstChild("Enemies")
							if enemies then
								for _, mob in ipairs(enemies:GetChildren()) do
									if mob:IsA("Model") and mob.Name ~= "Blank Buddy" then
										local hum = mob:FindFirstChildWhichIsA("Humanoid")
										local hrp = mob:FindFirstChild("HumanoidRootPart")
										if hum and hrp and hum.Health > 0 then
											for _, n in ipairs(names) do
												if mob.Name == n or mob.Name:lower():find(tostring(n):lower(), 1, true) then
													return mob
												end
											end
										end
									end
								end
							end
							local rep = ReplicatedStorage
							for _, mob in ipairs(rep:GetChildren()) do
								if mob:IsA("Model") and mob.Name ~= "Blank Buddy" then
									local hum = mob:FindFirstChildWhichIsA("Humanoid")
									local hrp = mob:FindFirstChild("HumanoidRootPart")
									if hum and hrp and hum.Health > 0 then
										for _, n in ipairs(names) do
											if mob.Name == n or mob.Name:lower():find(tostring(n):lower(), 1, true) then
												return mob
											end
										end
									end
								end
							end
							return false
						end

						function EquipWeapon(p22)
							if not Character then return end
							local targetType = tostring(p22)
							local currentTool = Character:FindFirstChildWhichIsA("Tool")
							if currentTool then
								local tip = currentTool.ToolTip or ""
								local wType = currentTool:GetAttribute("WeaponType") or ""
								if tip == targetType or wType == targetType or currentTool.Name:find(targetType) then
									return
								end
							end
							local Backpack = LocalPlayer:FindFirstChild("Backpack")
							if Backpack then
								for _, tool in ipairs(Backpack:GetChildren()) do
									if tool:IsA("Tool") then
										local tip = tool.ToolTip or ""
										local wType = tool:GetAttribute("WeaponType") or ""
										if tip == targetType or wType == targetType or tool.Name:find(targetType) or (targetType == "Melee" and (tip == "Melee" or wType == "Melee" or tool:FindFirstChild("Combat"))) then
											local hum = Character:FindFirstChildWhichIsA("Humanoid")
											if hum then
												hum:EquipTool(tool)
												return
											end
										end
									end
								end
							end
						end

						local timestamp = tick()

						function FastAttack(p23)
							local function v222(...)
								local t12 = { ... }
								t12.n = select("#", ...)
								return t12
							end

							if
								HumanoidRootPart
								and Character:FindFirstChildWhichIsA("Humanoid")
								and not (Character.Humanoid.Health <= 0)
								and Character:FindFirstChildWhichIsA("Tool")
							then
								if not (tick() - timestamp <= 0.01) then
									local t13 = {}

									for _, v in next, workspace.Enemies:GetChildren() do
										local Humanoid4 = v:FindFirstChildWhichIsA("Humanoid")
										local HumanoidRootPart4 = v:FindFirstChild("HumanoidRootPart")

										if
											v ~= Character
											and (
												(p23 and (p23 == v.Name or v.Name:find(p23)) or not p23)
												and Humanoid4
												and HumanoidRootPart4
												and Humanoid4.Health > 0
												and (HumanoidRootPart4.Position - HumanoidRootPart.Position).Magnitude <= 65
											)
										then
											t13[#t13 + 1] = v
										end
									end

									local _netOk, Net = pcall(function()
										return ReplicatedStorage.Modules.Net
									end)
									if not _netOk or not Net then
										return
									end

									local t14 = { [2] = {} }
									for i = 1, #t13 do
										local v231 = t13[i]
										local v232 = v231:FindFirstChild("Head") or v231:FindFirstChild("HumanoidRootPart")
										if not t14[1] then
											t14[1] = v232
										end
										t14[2][#t14[2] + 1] = { v231, v232 }
									end

									local _regAttack = Net:FindFirstChild("RE/RegisterAttack")
									if _regAttack then _regAttack:FireServer() end

									local v233 = Net:FindFirstChild("RE/RegisterHit")
									if v233 and #t14[2] > 0 then
										local v234 = v222(unpack(t14))
										v233:FireServer(unpack(v234, 1, v234.n))
									end

									if u66 and u67 and #t14[2] > 0 then
										local v243 = cloneref(u66)
										local v244 = string.gsub("RE/RegisterHit", ".", function(p24)
											local byte = string.byte(p24)
											local v339 = workspace:GetServerTimeNow() / 10 % 10
											local v340 = math.floor(v339) + 1
											local v341 = bit32.bxor(byte, v340)
											return (string.char(v341))
										end)
										local v245 = u67 + 909090
										local v246 = u68 * 2
										local v247 = bit32.bxor(v245, v246)
										local v248 = v222(unpack(t14))
										v243:FireServer(v244, v247, unpack(v248, 1, v248.n))
									end

									timestamp = tick()
									return
								end
								return
							end
						end

						function IfTableHaveIndex(p25)
							for _ in p25 do
								return true
							end
						end

						local timestamp2 = nil
						local u72 = nil

						function GetServers()
							if not timestamp2 or not (os.time() - timestamp2 < 60) then
								for i = 1, 100 do
									local v258 = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer(i)
									if IfTableHaveIndex(v258) then
										timestamp2 = os.time()
										u72 = v258
										return v258
									end
								end
								return
							end
							return u72
						end

						function HopServer(_, p27, p28)
							local t15 = {}
							for v263, v264 in (GetServers() or {}) do
								local t16 = {
									JobId = v263,
									Players = v264.Count,
									LastUpdate = v264.__LastUpdate,
									Region = v264.Region,
								}
								table.insert(t15, t16)
							end

							local v266 = nil
							for _ = 1, #t15 do
								while task.wait() do
									v266 = t15[math.random(1, #t15)]
									if v266 and (not p27 or v266.Players < 5) and (not p28 or p28 == v266.Regoin) then
										break
									end
								end
								ReplicatedStorage:WaitForChild("__ServerBrowser"):InvokeServer("teleport", v266.JobId)
							end
						end

						function Tween(p30, p31)
							if not p30 then return end
							local Character2 = LocalPlayer.Character
							if not Character2 then
								pcall(function()
									Character2 = LocalPlayer.CharacterAdded:Wait()
								end)
							end

							if Character2 then
								local HumanoidRootPart5 = Character2:WaitForChild("HumanoidRootPart", 10)
								local Humanoid5 = Character2:FindFirstChildOfClass("Humanoid")

								if HumanoidRootPart5 and Humanoid5 then
									Humanoid5.Sit = false

									local targetCFrame = (typeof(p30) == "CFrame" and p30) or CFrame.new(p30)
									local Magnitude = (targetCFrame.Position - HumanoidRootPart5.Position).Magnitude

									if Magnitude > 3000 then
										pcall(function()
											COMMF_:InvokeServer("requestEntrance", targetCFrame.Position)
										end)
										task.wait(0.5)
										HumanoidRootPart5 = Character2:FindFirstChild("HumanoidRootPart")
										if not HumanoidRootPart5 then return end
										Magnitude = (targetCFrame.Position - HumanoidRootPart5.Position).Magnitude
									end

									if not (Magnitude < 35) then
										local v275 = Magnitude / (p31 or _G.TweenSpeed or 280)
										local Part = Instance.new("Part")
										Part.Name = "TweenGhostFix"
										Part.Transparency = 1
										Part.Anchored = true
										Part.CanCollide = false
										Part.CFrame = HumanoidRootPart5.CFrame
										Part.Size = Vector3.new(2, 2, 2)
										Part.Parent = workspace

										local connection = RunService.Stepped:Connect(function()
											if Character2 then
												for _, descendant in ipairs(Character2:GetDescendants()) do
													if descendant:IsA("BasePart") then
														descendant.CanCollide = false
													end
												end
											end
										end)

										local Heartbeat = RunService.Heartbeat
										local u279 = HumanoidRootPart5
										local u280 = Part
										local connection2 = Heartbeat:Connect(function()
											if u279 and u280 then
												u279.CFrame = u280.CFrame
												u279.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
												u279.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
											end
										end)

										local tween = TweenService:Create(Part, TweenInfo.new(v275, Enum.EasingStyle.Linear), {
											CFrame = targetCFrame,
										})

										tween:Play()
										tween.Completed:Wait()

										if connection2 then connection2:Disconnect() end
										if connection then connection:Disconnect() end
										if Part then Part:Destroy() end

										HumanoidRootPart5.CFrame = targetCFrame
										return
									end

									HumanoidRootPart5.CFrame = targetCFrame
									return
								end
								return
							end
						end

						function BringMonster(p32, p33)
							local u285 = p33 or 3
							if u285 < 2 then return end

							pcall(function()
								setscriptable(LocalPlayer, "SimulationRadius", true)
							end)
							pcall(function()
								sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
							end)

							xpcall(function()
								local t17 = {}
								local v345 = nil

								for _, v in next, workspace.Enemies:GetChildren() do
									local Humanoid6 = v:FindFirstChildWhichIsA("Humanoid")
									local HumanoidRootPart6 = v:FindFirstChild("HumanoidRootPart")

									if
										Humanoid6
										and HumanoidRootPart6
										and Humanoid6.Health > 0
										and (
											(not p32 or v.Name == p32 or v.Name:find(p32))
											and (HumanoidRootPart.Position - HumanoidRootPart6.Position).Magnitude <= u285 * 250
										)
									then
										local find = table.find
										local u351 = HumanoidRootPart6

										if
											not find(t17, function(p34)
												local HumanoidRootPart7 = p34:FindFirstChild("HumanoidRootPart")
												return HumanoidRootPart7 and (u351.Position - HumanoidRootPart7.Position).Magnitude <= 5
											end)
										then
											v345 = v345 or HumanoidRootPart6.CFrame
											t17[#t17 + 1] = v
										end

										if #t17 >= u285 then
											break
										end
									end
								end

								if v345 then
									for i = 1, #t17 do
										local HumanoidRootPart8 = t17[i]:FindFirstChild("HumanoidRootPart")
										if HumanoidRootPart8 and (not isnetworkowner or isnetworkowner(HumanoidRootPart8)) then
											HumanoidRootPart8.AssemblyLinearVelocity = Vector3.zero
											HumanoidRootPart8.AssemblyAngularVelocity = Vector3.zero
											HumanoidRootPart8.CFrame = v345 * CFrame.new((i - 1) * 2, 0, 0)
										end
									end
								end
							end, function(p35)
								warn("Modules Error [BM]: " .. tostring(p35))
							end)
						end

						local timestamp3 = tick()

						function KillMonster(p36)
							local targetName = tostring(p36)
							xpcall(function()
								local enemies = workspace:FindFirstChild("Enemies")
								if enemies then
									for _, v in ipairs(enemies:GetChildren()) do
										local hum = v:FindFirstChildWhichIsA("Humanoid")
										local hrp = v:FindFirstChild("HumanoidRootPart")
										if hum and hum.Health > 0 and hrp and (v.Name == targetName or v.Name:find(targetName)) then
											local distSq = (HumanoidRootPart.Position - hrp.Position).Magnitude
											if distSq > 70 then
												Tween(hrp.CFrame * CFrame.new(0, 15, 0))
												return
											end

											BringMonster(targetName, 3)
											FastAttack(targetName)

											if tick() - timestamp3 >= 10 then
												timestamp3 = tick()
												pcall(function()
													ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
												end)
											end

											Tween(CFrame.new(hrp.Position + Vector3.new(0, 15, 0)))
											EquipWeapon("Melee")
											return
										end
									end
								end

								for _, v in next, ReplicatedStorage:GetChildren() do
									local hrp2 = v:FindFirstChild("HumanoidRootPart")
									if v:IsA("Model") and hrp2 and (v.Name == targetName or v.Name:find(targetName)) then
										Tween(hrp2.CFrame * CFrame.new(0, 15, 0))
										return
									end
								end
							end, function(p37)
								warn("Modules ERROR:", p37)
							end)
						end

						local t18 = {
							__index = function(_, p39)
								local HumanoidRootPartPosition = HumanoidRootPart.Position
								local v294 = nil
								local v295 = nil
								local NPCName = nil

								for _, v in next, require(ReplicatedStorage.GuideModule).Data.NPCList do
									if p39 == v.InternalQuestName then
										local vPosition = v.Position
										if typeof(vPosition) ~= "Vector3" then
											if typeof(vPosition) == "table" then
												for _, v2 in next, vPosition do
													if typeof(v2) == "Vector3" then
														local Magnitude = (v2 - HumanoidRootPartPosition).Magnitude
														if not v294 or Magnitude < v294 then
															v294 = Magnitude
															v295 = v2
															NPCName = v.NPCName
														end
													end
												end
											end
										else
											local Magnitude = (vPosition - HumanoidRootPartPosition).Magnitude
											if not v294 or Magnitude < v294 then
												v294 = Magnitude
												v295 = vPosition
												NPCName = v.NPCName
											end
										end
									end
								end

								return v295 and {
									Position = v295,
									Meters = v294,
									RawNPCName = NPCName,
								} or nil
							end,
						}

						TableQuests = setmetatable({}, t18)

						-- [REPAIR P2] Notification hook
						local u75 = nil
						local _notifOk, _notifMod = pcall(function()
							if ReplicatedStorage:FindFirstChild("Notification") then
								return require(ReplicatedStorage.Notification)
							end
							return nil
						end)
						local new = _notifOk and _notifMod and _notifMod.new or nil
						local u79 = v65
						local u80 = v64
						if new and hookfunction and newcclosure then
							local v81 = v37(newcclosure(function(...)
								local v304 = ({ ... })[1]
								if type(v304) == "string" and u79() == 2 then
									if v304:find("Microchip not found") then
										CyborgBlockPartUnlocked = "chest"
										writefile(u80, "chest")
									elseif v304:lower():find("core brain") or v304:lower():find("supply a <core brain>") then
										CyborgBlockPartUnlocked = "unlock"
										writefile(u80, "unlock")
									end
								end
								return u75(...)
							end))
							u75 = hookfunction(new, unpack(v81, 1, v81.n))
							warn("[BOOT] Notification hook active")
						else
							warn("[BOOT] Notification hook SKIPPED - module/hookfunction/newcclosure unavailable")
						end

						local chestCount = 0
						local spawn = task.spawn
						local u86 = v65

						warn("[BOOT] CYBORG MODULE READY")
						spawn(function()
							warn("[BOOT] CYBORG V1->V2->V3 LOOP STARTED")

							while task.wait(0.5) do
								xpcall(function()
									local seaNumber = u86()

									-- Check Sea
									if seaNumber ~= 2 then
										u63("Traveling to Sea 2 / Đang chuyển sang Sea 2...", Color3.fromRGB(120, 180, 255), 3)
										COMMF_:InvokeServer("TravelDressrosa")
										task.wait(2)
										return
									end

									local raceData = LocalPlayer.Data.Race
									local currentRace = tostring(raceData.Value)
									local raceEvolved = raceData:FindFirstChild("Evolved")
									local evolveLevel = (raceEvolved and tonumber(raceEvolved.Value)) or (raceEvolved and 2 or 1)

									-- =========================================================================
									-- CASE A: PLAYER ALREADY HAS CYBORG RACE -> AUTO UPGRADE V2 AND V3!
									-- =========================================================================
									if currentRace == "Cyborg" then
										-- 1. Check if V3 is ALREADY completed
										local wenlockTalk = COMMF_:InvokeServer("Wenlocktoad")
										if wenlockTalk == "You have already..." or (type(wenlockTalk) == "string" and (wenlockTalk:find("Complete") or wenlockTalk:find("already"))) or evolveLevel >= 3 then
											u63("CYBORG V3 COMPLETED! / ĐÃ HOÀN THÀNH CYBORG V3!", Color3.fromRGB(52, 199, 89), 5)
											task.wait(4)
											return
										end

										-- 2. Upgrade V1 -> V2 (Alchemist Quest)
										if not raceEvolved or evolveLevel < 2 then
											u63("Upgrading Cyborg V2 (Alchemist Quest) / Đang nâng cấp Cyborg V2", Color3.fromRGB(255, 204, 0), 3)

											local alchStatus = COMMF_:InvokeServer("Alchemist", "1")
											if alchStatus == 0 then
												u63("Accepting Alchemist Quest / Nhận nhiệm vụ Alchemist (V2)", Color3.fromRGB(255, 204, 0), 2.5)
												COMMF_:InvokeServer("Alchemist", "2")
												task.wait(0.5)
											end

											local hasF1 = CheckTool("Flower 1") or CheckInventory("Flower 1")
											local hasF2 = CheckTool("Flower 2") or CheckInventory("Flower 2")
											local hasF3 = CheckTool("Flower 3") or CheckInventory("Flower 3")

											-- Check if all 3 flowers are ready to turn in
											if alchStatus == 2 or (hasF1 and hasF2 and hasF3) then
												if LocalPlayer.Data.Beli.Value < 500000 then
													u63("Need 500,000 Beli to evolve V2 / Cần 500k Beli để lên V2", Color3.fromRGB(255, 204, 0), 2.5)
													task.wait(2)
												else
													u63("Turning in 3 Flowers to Alchemist / Nộp 3 Hoa cho Alchemist (V2)", Color3.fromRGB(52, 199, 89), 4)
													COMMF_:InvokeServer("Alchemist", "3")
													task.wait(1)
												end
												return
											end

											-- Missing Flower 3 (Yellow Flower) -> Farm Swan Pirates
											if not hasF3 then
												u63("Farming Swan Pirate for Yellow Flower / Đang đánh Swan Pirate tìm Hoa 3", Color3.fromRGB(255, 69, 58), 2)
												local mob = CheckMonster("Swan Pirate")
												if mob then
													KillMonster("Swan Pirate")
												else
													Tween(CFrame.new(980.0985107421875, 121.331298828125, 1287.2093505859375))
												end
												return
											end

											-- Missing Flower 1 (Blue Flower - spawns at night)
											if not hasF1 then
												local flower1 = FindFlower(1)
												if flower1 then
													u63("Collecting Blue Flower (Flower 1) / Đang nhặt Hoa Xanh (Hoa 1)", Color3.fromRGB(120, 180, 255), 2.5)
													local targetCF = (flower1:IsA("Model") and flower1:GetPivot()) or flower1.CFrame
													Tween(targetCF)
													return
												end
											end

											-- Missing Flower 2 (Red Flower - spawns at day)
											if not hasF2 then
												local flower2 = FindFlower(2)
												if flower2 then
													u63("Collecting Red Flower (Flower 2) / Đang nhặt Hoa Đỏ (Hoa 2)", Color3.fromRGB(255, 69, 58), 2.5)
													local targetCF = (flower2:IsA("Model") and flower2:GetPivot()) or flower2.CFrame
													Tween(targetCF)
													return
												end
											end

											-- Flower 3 is acquired, but Flower 1 / 2 not currently spawned
											u63("Waiting for Flowers to spawn (Blue/Red) / Chờ Hoa Xanh/Đỏ xuất hiện", Color3.fromRGB(255, 204, 0), 2.5)
											task.wait(2)
											return
										end

										-- 3. Upgrade V2 -> V3 (Arowe / Wenlocktoad Quest)
										u63("Upgrading Cyborg V3 (Arowe Quest) / Đang nâng cấp Cyborg V3", Color3.fromRGB(255, 204, 0), 3)

										local wenlockStatus = COMMF_:InvokeServer("Wenlocktoad", "1")
										if wenlockStatus == 0 or wenlockStatus == "0" then
											u63("Accepting Arowe Quest (V3) / Nhận nhiệm vụ Arowe (V3)", Color3.fromRGB(255, 204, 0), 2.5)
											COMMF_:InvokeServer("Wenlocktoad", "2")
											task.wait(0.5)
										end

										if LocalPlayer.Data.Beli.Value < 2000000 then
											u63("Need 2,000,000 Beli for Cyborg V3 / Cần 2,000,000 Beli để mua V3", Color3.fromRGB(255, 204, 0), 2.5)
											task.wait(2)
											return
										end

										-- Check physical Blox Fruit tool in inventory / character
										local fruitTool = nil
										if LocalPlayer.Backpack then
											for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
												if tool:IsA("Tool") and (tool.ToolTip == "Blox Fruit" or tool.Name:lower():find("fruit") or tool:GetAttribute("Fruit")) then
													fruitTool = tool
													break
												end
											end
										end
										if not fruitTool and Character then
											for _, tool in ipairs(Character:GetChildren()) do
												if tool:IsA("Tool") and (tool.ToolTip == "Blox Fruit" or tool.Name:lower():find("fruit") or tool:GetAttribute("Fruit")) then
													fruitTool = tool
													break
												end
											end
										end

										-- If no physical fruit tool in hand, unstore cheapest or roll from Cousin
										if not fruitTool then
											local cheapestName, cheapestVal = nil, math.huge
											local ok, inv = pcall(function() return COMMF_:InvokeServer("getInventory") end)
											if ok and type(inv) == "table" then
												for _, item in pairs(inv) do
													if item.Type == "Blox Fruit" and (item.Value or 0) < cheapestVal then
														cheapestVal = item.Value or 0
														cheapestName = item.Name
													end
												end
											end

											if cheapestName then
												u63("Unstoring Fruit: " .. cheapestName .. " for V3 / Đang lấy trái " .. cheapestName .. " để nộp V3", Color3.fromRGB(120, 180, 255), 2.5)
												COMMF_:InvokeServer("LoadFruit", cheapestName)
												task.wait(1)
												return
											else
												u63("Rolling Fruit for V3 / Mua trái ác quỷ từ Gacha để nộp V3", Color3.fromRGB(255, 204, 0), 2.5)
												COMMF_:InvokeServer("Cousin", "Buy")
												task.wait(1)
												return
											end
										end

										-- Holding/having fruit -> Go to Arowe cave and submit
										u63("Submitting Blox Fruit to Arowe / Đang nộp trái Blox Fruit cho Arowe (V3)", Color3.fromRGB(52, 199, 89), 4)
										if Character and Character:FindFirstChildOfClass("Humanoid") and fruitTool.Parent == LocalPlayer.Backpack then
											Character.Humanoid:EquipTool(fruitTool)
										end

										Tween(CFrame.new(-288.66571, 49.3383789, 5604.81445))
										task.wait(0.5)
										COMMF_:InvokeServer("Wenlocktoad", "3")
										task.wait(1)

										-- Store back any extra fruits
										pcall(function()
											for _, child in pairs(LocalPlayer.Backpack:GetChildren()) do
												if child:IsA("Tool") and (child.ToolTip == "Blox Fruit" or child.Name:lower():find("fruit")) then
													COMMF_:InvokeServer("StoreFruit", child.Name)
													task.wait(0.3)
												end
											end
											if Character then
												for _, child in pairs(Character:GetChildren()) do
													if child:IsA("Tool") and (child.ToolTip == "Blox Fruit" or child.Name:lower():find("fruit")) then
														COMMF_:InvokeServer("StoreFruit", child.Name)
														task.wait(0.3)
													end
												end
											end
										end)
										return
									end

									-- =========================================================================
									-- CASE B: PLAYER DOES NOT HAVE CYBORG RACE YET -> UNLOCK & BUY CYBORG V1!
									-- =========================================================================

									-- 1. Check if Cyborg Trainer is ready to buy
									local canBuyCyborg = (COMMF_:InvokeServer("CyborgTrainer", "Check") == true)
									if canBuyCyborg then
										if LocalPlayer.Data.Fragments.Value >= 2500 then
											u63("Buying Cyborg Race / Mua Tộc Cyborg (2500 Frags)", Color3.fromRGB(52, 199, 89), 3)
											COMMF_:InvokeServer("CyborgTrainer", "Buy")
											task.wait(1)
											return
										else
											u63("Need 2,500 Fragments for Cyborg / Cần 2,500 Frags để mua Cyborg", Color3.fromRGB(255, 204, 0), 2.5)
											task.wait(2)
											return
										end
									end

									-- 2. Check if player has Core Brain
									if CheckTool("Core Brain") or CheckInventory("Core Brain") then
										u63("Got Core Brain! Unlocking Cyborg / Đã có Core Brain! Đang mở khóa Cyborg", Color3.fromRGB(52, 199, 89), 4)
										EquipWeapon("Core Brain")
										SafeFireRaid()
										COMMF_:InvokeServer("CyborgTrainer", "Buy")
										task.wait(1)
										return
									end

									-- 3. Check if Order Boss (Law) is alive in workspace
									local orderBoss = nil
									if workspace:FindFirstChild("Enemies") then
										for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
											if enemy.Name == "Order" and enemy:FindFirstChildWhichIsA("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
												orderBoss = enemy
												break
											end
										end
									end

									if orderBoss then
										u63("Fighting Order Boss (Law) / Đang đánh Boss Law", Color3.fromRGB(255, 69, 58), 2)
										KillMonster("Order")
										return
									end

									-- 4. Check if Order Boss is in ReplicatedStorage arena
									if ReplicatedStorage:FindFirstChild("Order") then
										u63("Entering Order Raid Arena / Đang vào sàn đấu Law", Color3.fromRGB(255, 204, 0), 2)
										pcall(function()
											Tween(ReplicatedStorage.Order:GetPivot())
										end)
										return
									end

									-- 5. Order is not active -> Can we start Law Raid?
									if CheckTool("Microchip") or CheckInventory("Microchip") then
										u63("Starting Order Raid (Law) / Bắt đầu Raid Law", Color3.fromRGB(255, 204, 0), 2.5)
										SafeFireRaid()
										return
									end

									if LocalPlayer.Data.Fragments.Value >= 1000 then
										u63("Buying Law Microchip (1000 Frags) / Mua Chip Law (1000 Frags)", Color3.fromRGB(120, 180, 255), 2.5)
										COMMF_:InvokeServer("BlackbeardReward", "Microchip", "2")
										task.wait(0.5)
										SafeFireRaid()
										return
									end

									-- 6. Check Fist of Darkness
									if CheckTool("Fist of Darkness") or CheckInventory("Fist of Darkness") then
										u63("Inserting Fist of Darkness / Nạp Bàn Tay Bóng Tối vào máy", Color3.fromRGB(52, 199, 89), 4)
										EquipWeapon("Fist of Darkness")
										SafeFireRaid()
										task.wait(1)
										return
									end

									-- 7. No Fist of Darkness -> Farm Chests (1 by 1, non-blocking)
									local chests = {}
									for _, v in ipairs(CollectionService:GetTagged("_ChestTagged")) do
										if v and v:IsA("BasePart") and v.CanTouch and HumanoidRootPart then
											local dist = (v.Position - HumanoidRootPart.Position).Magnitude
											table.insert(chests, { obj = v, dist = dist })
										end
									end

									table.sort(chests, function(a, b)
										return a.dist < b.dist
									end)

									if #chests > 0 and chestCount < 30 then
										local targetChest = chests[1].obj
										chestCount = chestCount + 1
										u63(string.format("Farming Chests [%d/30] / Đang nhặt rương [%d/30]", chestCount, 30), Color3.fromRGB(255, 204, 0), 2)

										Tween(targetChest.CFrame)
										task.delay(1.5, function()
											pcall(function() targetChest.CanTouch = false end)
										end)
										task.wait(0.3)
										return
									end

									if chestCount >= 30 and not CheckTool("Fist of Darkness") then
										u63("Hop Server (Searching for Fist) / Đổi server tìm Bàn Tay Bóng Tối", Color3.fromRGB(255, 69, 58), 4)
										task.wait(2)
										HopServer()
										return
									end
								end, function(err)
									warn("[CYBORG CORE ERROR]:", tostring(err))
									warn("Stack:", debug.traceback())
								end)
							end
						end)

						task.spawn(function()
							while task.wait(4) do
								xpcall(function()
									if Character and Character.Humanoid and Character.Humanoid.Health > 0 then
										if not Character:FindFirstChild("HasBuso") then
											COMMF_:InvokeServer("Buso")
										end

										for _, v in next, { "Buso", "Geppo", "Soru" } do
											if not CollectionService:HasTag(Character, v) then
												local cost = (v == "Soru" and 100000) or (v == "Buso" and 25000) or 10000
												if LocalPlayer.Data.Beli.Value >= cost then
													u63("Auto Buy Haki (" .. v .. ") / Tự động mua " .. v, Color3.fromRGB(52, 199, 89), 2.5)
													COMMF_:InvokeServer("BuyHaki", v)
												end
											end
										end
									end
								end, function(err)
									warn("Haki Error: " .. tostring(err))
								end)
							end
						end)

						local ErrorMessageChanged = GuiService.ErrorMessageChanged
						local v89 = v37(newcclosure(function()
							if GuiService:GetErrorType() ~= Enum.ConnectionError.DisconnectErrors then
								return
							end

							while true do
								TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
								task.wait(5)
							end
						end))

						ErrorMessageChanged:Connect(unpack(v89, 1, v89.n))
						return
					end

					v38 = cloneref(Workspace)
					if v38 then g39 = true end
				until not g39

				if getrenv then
					v38 = getrenv().workspace
					if v38 then g39 = true end
					if not g39 then
						v38 = getrenv().Workspace
						if v38 then g39 = true end
					end
				end
			until not g39
		until not g39

		local v93 = v37(game:GetService("Workspace"))
		v38 = cloneref(unpack(v93, 1, v93.n))
		g39 = true
	until not g39
end

-- [[ Start Script directly with Dynamic Island UI ]]
u12()
