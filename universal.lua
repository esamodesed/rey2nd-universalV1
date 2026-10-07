-- REY2ND-UNIVERSAL v4 | Full Feature Pack
-- Developer: Rey2nd
print("[REY] universal v4 loaded")

if _G.REY_UNIV_CLEANUP then pcall(_G.REY_UNIV_CLEANUP) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local state = { guis = {}, conns = {}, running = true }
_G.REY_UNIV_CLEANUP = function()
    state.running = false
    for _, g in ipairs(state.guis) do pcall(function() g:Destroy() end) end
    for _, c in ipairs(state.conns) do pcall(function() c:Disconnect() end) end
    state.guis = {}; state.conns = {}
end

local function getUI()
    if type(gethui) == "function" then
        local ok, h = pcall(gethui); if ok and h then return h end
    end
    local ok, c = pcall(function() return game:GetService("CoreGui") end)
    if ok and c then return c end
    return LP:WaitForChild("PlayerGui")
end
local uiParent = getUI()

local C = {
    bg = Color3.fromRGB(12,10,20),
    panel = Color3.fromRGB(20,16,32),
    panelAlt = Color3.fromRGB(30,24,48),
    accent = Color3.fromRGB(120,140,255),
    accent2 = Color3.fromRGB(80,220,255),
    gold = Color3.fromRGB(255,200,80),
    danger = Color3.fromRGB(255,70,90),
    success = Color3.fromRGB(80,230,140),
    text = Color3.fromRGB(235,235,250),
    dim = Color3.fromRGB(150,150,180),
}
local GRAD = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent),
    ColorSequenceKeypoint.new(1, C.accent2),
})

local S = {
    wallHop=false, wallHopPower=50,
    fly=false, flySpeed=100,
    invisible=false,
    hideFromOthers=false,
    infJump=false,
    speed=false, speedVal=1000,
    godMode=false,
    noclip=false,
    fullbright=false,
    antiAfk=true,
    espPlayer=false,
    hidePopups=false,
    hitboxExpand=false, hitboxSize=10,
    jesus=false,
    antiVoid=false,
    antiRagdoll=false,
    infYield=false,
    clickTP=false,
    autoRejoin=false,
    fpsBoost=false,
}
local stats = { uptime=os.time(), hops=0, jumps=0, tps=0 }

local function getChar() return LP.Character end
local function getHRP() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ============================================================
--              WALL HOP
-- ============================================================
table.insert(state.conns, RunService.RenderStepped:Connect(function()
    if not S.wallHop then return end
    local char = getChar()
    local hrp = getHRP()
    if not char or not hrp then return end

    local rayOrigin = hrp.Position
    local rayDir = hrp.CFrame.LookVector * 4
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(rayOrigin, rayDir, rp)

    if result and UIS:IsKeyDown(Enum.KeyCode.Space) then
        pcall(function()
            local h = getHRP()
            if h then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = Vector3.new(0, S.wallHopPower, 0) + h.CFrame.LookVector * 20
                bv.Parent = h
                game:GetService("Debris"):AddItem(bv, 0.2)
                stats.hops = stats.hops + 1
            end
        end)
    end
end))

-- ============================================================
--              FLY V3
-- ============================================================
local flyBV, flyBG, flyConn, flyGuard
local flyActive = false

local function stopFly()
    flyActive = false
    if flyConn then pcall(function() flyConn:Disconnect() end) flyConn = nil end
    if flyGuard then pcall(function() flyGuard:Disconnect() end) flyGuard = nil end
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    local h = getHum()
    if h then pcall(function() h.PlatformStand = false end) end
end

local function startFly()
    stopFly()
    flyActive = true
    local hrp = getHRP()
    local hum = getHum()
    if not hrp then
        task.spawn(function()
            for i = 1, 20 do
                task.wait(0.2)
                if not flyActive then return end
                if getHRP() then startFly(); return end
            end
        end)
        return
    end

    if hum then
        pcall(function()
            hum.PlatformStand = true
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end)
    end

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "REY_FLY_BV"
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.P = 12500
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "REY_FLY_BG"
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 12500
    flyBG.D = 500
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local h = getHRP()
        if not h then return end
        if not flyBV or not flyBV.Parent then
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "REY_FLY_BV"
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.P = 12500
            flyBV.Parent = h
        end
        if not flyBG or not flyBG.Parent then
            flyBG = Instance.new("BodyGyro")
            flyBG.Name = "REY_FLY_BG"
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.P = 12500
            flyBG.D = 500
            flyBG.Parent = h
        end

        local move = Vector3.zero
        local cam = Cam.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            flyBV.Velocity = move.Unit * S.flySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = CFrame.new(h.Position, h.Position + cam.LookVector)
    end)

    flyGuard = RunService.Heartbeat:Connect(function()
        if not flyActive then return end
        local h = getHum()
        if h and not h.PlatformStand then
            pcall(function() h.PlatformStand = true end)
        end
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if flyActive then startFly() end
end)

-- ============================================================
--              INVISIBLE (total, keliatan sendiri juga ilang)
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.invisible then return end
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function()
                p.Transparency = 1
                p.LocalTransparencyModifier = 0
            end)
        elseif p:IsA("Decal") or p:IsA("Texture") then
            pcall(function() p.Transparency = 1 end)
        end
    end
end))

-- ============================================================
--              HIDE FROM OTHERS (invisible di mata orang lain,
--              MASIH KELIATAN di mata sendiri)
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.hideFromOthers then return end
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function()
                p.Transparency = 1        -- replikasi ke server & client lain
                p.LocalTransparencyModifier = -1  -- balikin di client sendiri
            end)
        elseif p:IsA("Decal") or p:IsA("Texture") then
            pcall(function()
                p.Transparency = 1
                p.LocalTransparencyModifier = -1
            end)
        end
    end
end))

-- ============================================================
--              INFINITE JUMP
-- ============================================================
local infJumpConn1, infJumpConn2

local function setupInfJump()
    if infJumpConn1 then pcall(function() infJumpConn1:Disconnect() end) end
    if infJumpConn2 then pcall(function() infJumpConn2:Disconnect() end) end

    infJumpConn1 = UIS.JumpRequest:Connect(function()
        if not S.infJump then return end
        local h = getHum()
        if h then
            pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
            stats.jumps = stats.jumps + 1
        end
    end)

    infJumpConn2 = RunService.RenderStepped:Connect(function()
        if not S.infJump then return end
        local h = getHum()
        if h then
            local st = h:GetState()
            if (st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Landed) and UIS:IsKeyDown(Enum.KeyCode.Space) then
                pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end
    end)
end
setupInfJump()
LP.CharacterAdded:Connect(function() task.wait(1); setupInfJump() end)

-- ============================================================
--              SPEED
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.speed then return end
    local h = getHum()
    if h then pcall(function() h.WalkSpeed = S.speedVal end) end
end))

-- ============================================================
--              GOD MODE
-- ============================================================
local godConn
local function applyGod()
    local hum = getHum()
    if not hum then return end
    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.BreakJointsOnDeath = false
    end)
    if not godConn then
        godConn = hum.HealthChanged:Connect(function(h)
            if S.godMode and h < hum.MaxHealth then
                pcall(function() hum.Health = hum.MaxHealth end)
            end
        end)
    end
end
local function removeGod()
    if godConn then pcall(function() godConn:Disconnect() end) godConn = nil end
    local hum = getHum()
    if hum then pcall(function() hum.MaxHealth = 100; hum.Health = 100 end) end
end
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.godMode then return end
    local hum = getHum()
    if hum and hum.MaxHealth ~= math.huge then applyGod() end
end))
LP.CharacterAdded:Connect(function() task.wait(1); if S.godMode then applyGod() end end)

-- ============================================================
--              NOCLIP
-- ============================================================
table.insert(state.conns, RunService.Stepped:Connect(function()
    if not S.noclip then return end
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
    end
end))

-- ============================================================
--              JESUS (WALK ON WATER)
-- ============================================================
table.insert(state.conns, RunService.Stepped:Connect(function()
    if not S.jesus then return end
    local hrp = getHRP()
    if not hrp then return end
    local ray = Ray.new(hrp.Position, Vector3.new(0, -6, 0))
    local hit, pos = workspace:FindPartOnRay(ray, getChar())
    if hit and pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end))

-- ============================================================
--              ANTI VOID (auto TP kalau jatuh)
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.antiVoid then return end
    local hrp = getHRP()
    if not hrp then return end
    if hrp.Position.Y < -50 then
        pcall(function()
            hrp.CFrame = CFrame.new(0, 50, 0)
            hrp.Velocity = Vector3.zero
        end)
    end
end))

-- ============================================================
--              ANTI RAGDOLL
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.antiRagdoll then return end
    local hum = getHum()
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end
end))

-- ============================================================
--              INFINITE YIELD (no fall damage)
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.infYield then return end
    local hum = getHum()
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end
end))

-- ============================================================
--              CLICK TELEPORT (Ctrl + Click)
-- ============================================================
table.insert(state.conns, UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not S.clickTP then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LP:GetMouse()
        local target = mouse.Hit.Position
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
            stats.tps = stats.tps + 1
        end
    end
end))

-- ============================================================
--              FULLBRIGHT
-- ============================================================
local originalLighting = {}
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.fullbright then return end
    pcall(function()
        local L = game:GetService("Lighting")
        L.Ambient = Color3.fromRGB(255,255,255)
        L.OutdoorAmbient = Color3.fromRGB(255,255,255)
        L.Brightness = 2
        L.FogEnd = 100000
        L.GlobalShadows = false
        for _, e in ipairs(L:GetChildren()) do
            if e:IsA("Atmosphere") then e.Density = 0 end
        end
    end)
end))

-- ============================================================
--              HITBOX EXPANDER
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if S.hitboxExpand then
                    pcall(function()
                        hrp.Size = Vector3.new(S.hitboxSize, S.hitboxSize, S.hitboxSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                    end)
                else
                    pcall(function()
                        if hrp.Size ~= Vector3.new(2, 2, 1) then
                            hrp.Size = Vector3.new(2, 2, 1)
                            hrp.Transparency = 1
                        end
                    end)
                end
            end
        end
    end
end))

-- ============================================================
--              ESP PLAYER
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local old = plr.Character:FindFirstChild("REY_ESP")
            if old and not S.espPlayer then old:Destroy() end
            if S.espPlayer and not plr.Character:FindFirstChild("REY_ESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "REY_ESP"
                hl.FillColor = C.accent
                hl.OutlineColor = C.accent2
                hl.FillTransparency = 0.5
                hl.Parent = plr.Character
            end
        end
    end
end))

-- ============================================================
--              HIDE POPUPS
-- ============================================================
local HIDE_KW = {"popup","notification","notif","toast","banner"}
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.hidePopups then return end
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("Frame") or d:IsA("TextLabel") then
            local n = (d.Name or ""):lower()
            for _, kw in ipairs(HIDE_KW) do
                if n:find(kw, 1, true) then
                    pcall(function() d.Visible = false end)
                    break
                end
            end
        end
    end
end))

-- ============================================================
--              FPS BOOST
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.fpsBoost then return end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
    end)
end))

-- ============================================================
--              AUTO REJOIN
-- ============================================================
LP.AncestryChanged:Connect(function()
    if S.autoRejoin and not LP:IsDescendantOf(game) then
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end)
    end
end)

-- ============================================================
--              ANTI AFK
-- ============================================================
LP.Idled:Connect(function()
    if S.antiAfk then
        local VU = game:GetService("VirtualUser")
        VU:CaptureController(); VU:ClickButton2(Vector2.new())
    end
end)

-- ============================================================
--              UI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "REY_UNIVERSAL"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = uiParent
table.insert(state.guis, gui)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 500)
main.Position = UDim2.new(0.5, -170, 0.5, -250)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color = C.accent; ms.Thickness = 1.5; ms.Parent = main

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C.panelAlt
header.BorderSizePixel = 0
header.Parent = main
local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 12); hc.Parent = header
local hg = Instance.new("UIGradient"); hg.Color = GRAD; hg.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "REY2ND  ✦  UNIVERSAL v4"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -60, 0, 7)
minBtn.Text = "—"
minBtn.BackgroundColor3 = C.panel
minBtn.TextColor3 = C.text
minBtn.BorderSizePixel = 0
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.Parent = header
local mnc = Instance.new("UICorner"); mnc.CornerRadius = UDim.new(0, 6); mnc.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -30, 0, 7)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = C.danger
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = header
local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 6); cbc.Parent = closeBtn

local contentWrap = Instance.new("Frame")
contentWrap.Name = "ContentWrap"
contentWrap.Size = UDim2.new(1, 0, 1, -40)
contentWrap.Position = UDim2.new(0, 0, 0, 40)
contentWrap.BackgroundTransparency = 1
contentWrap.Parent = main

local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, -20, 1, -70)
sf.Position = UDim2.new(0, 10, 0, 5)
sf.BackgroundTransparency = 1
sf.BorderSizePixel = 0
sf.ScrollBarThickness = 5
sf.ScrollBarImageColor3 = C.accent2
sf.CanvasSize = UDim2.new(0, 0, 0, 0)
sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.ScrollingDirection = Enum.ScrollingDirection.Y
sf.Parent = contentWrap

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = sf

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 30)
pad.Parent = sf

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 1, -46)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = C.dim
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = contentWrap

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 20)
footer.Position = UDim2.new(0, 10, 1, -26)
footer.BackgroundTransparency = 1
footer.Text = "Developer: Rey2nd"
footer.TextColor3 = C.gold
footer.Font = Enum.Font.GothamBold
footer.TextSize = 11
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = contentWrap

local fBtn = Instance.new("TextButton")
fBtn.Size = UDim2.new(0, 50, 0, 50)
fBtn.Position = UDim2.new(0, 20, 0.5, -25)
fBtn.BackgroundColor3 = C.accent
fBtn.Text = "R"
fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fBtn.Font = Enum.Font.GothamBold
fBtn.TextSize = 18
fBtn.BorderSizePixel = 0
fBtn.Visible = false
fBtn.Active = true
fBtn.Draggable = true
fBtn.Parent = gui
local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 10); fc.Parent = fBtn
local fs = Instance.new("UIStroke"); fs.Color = C.accent2; fs.Thickness = 2; fs.Parent = fBtn

local isMin = false
local MAX_SIZE = UDim2.new(0, 340, 0, 500)
local MIN_SIZE = UDim2.new(0, 340, 0, 40)

minBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then
        main.Size = MIN_SIZE
        contentWrap.Visible = false
        minBtn.Text = "+"
    else
        main.Size = MAX_SIZE
        contentWrap.Visible = true
        minBtn.Text = "—"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    fBtn.Visible = true
end)

fBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    fBtn.Visible = false
    if isMin then
        isMin = false
        main.Size = MAX_SIZE
        contentWrap.Visible = true
        minBtn.Text = "—"
    end
end)

-- ============================================================
--              BUILDERS
-- ============================================================
local function section(t)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = "✦ " .. t .. " ✦"
    l.TextColor3 = C.accent2
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.Parent = sf
end

local function checkbox(name, default, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 40)
    row.BackgroundColor3 = C.panel
    row.BorderSizePixel = 0
    row.Parent = sf
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 8); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 26, 0, 26)
    box.Position = UDim2.new(1, -36, 0.5, -13)
    box.BackgroundColor3 = default and C.accent or C.panelAlt
    box.Text = default and "✓" or ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 14
    box.BorderSizePixel = 0
    box.Parent = row
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = box

    local st = default
    box.MouseButton1Click:Connect(function()
        st = not st
        box.BackgroundColor3 = st and C.accent or C.panelAlt
        box.Text = st and "✓" or ""
        if cb then cb(st) end
    end)
end

local function slider(name, minV, maxV, defV, cb, formatFn)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 58)
    row.BackgroundColor3 = C.panel
    row.BorderSizePixel = 0
    row.Parent = sf
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 8); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 18)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valDisplay = Instance.new("TextLabel")
    valDisplay.Size = UDim2.new(0, 70, 0, 18)
    valDisplay.Position = UDim2.new(1, -84, 0, 4)
    valDisplay.BackgroundTransparency = 1
    valDisplay.Text = formatFn and formatFn(defV) or tostring(defV)
    valDisplay.TextColor3 = C.accent2
    valDisplay.Font = Enum.Font.GothamBold
    valDisplay.TextSize = 12
    valDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valDisplay.Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -28, 0, 16)
    track.Position = UDim2.new(0, 14, 0, 34)
    track.BackgroundColor3 = C.bg
    track.Text = ""
    track.AutoButtonColor = false
    track.BorderSizePixel = 0
    track.Parent = row
    local trc = Instance.new("UICorner"); trc.CornerRadius = UDim.new(1, 0); trc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defV - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    local flc = Instance.new("UICorner"); flc.CornerRadius = UDim.new(1, 0); flc.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new((defV - minV) / (maxV - minV), 0, 0.5, -10)
    knob.AnchorPoint = Vector2.new(0.5, 0)
    knob.BackgroundColor3 = C.accent2
    knob.BorderSizePixel = 0
    knob.Parent = track
    local knc = Instance.new("UICorner"); knc.CornerRadius = UDim.new(1, 0); knc.Parent = knob

    local dragging = false
    local function updateFromX(absX)
        local trackAbs = track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        if trackWidth <= 0 then return end
        local rel = math.clamp((absX - trackAbs) / trackWidth, 0, 1)
        local val = math.floor(minV + rel * (maxV - minV))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, -10)
        valDisplay.Text = formatFn and formatFn(val) or tostring(val)
        if cb then cb(val) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
--              MENU CONTENT
-- ============================================================
section("MOVE")
checkbox("Wall Hop", false, function(v) S.wallHop = v end)
slider("Wall Hop Power", 10, 200, 50, function(v) S.wallHopPower = v end)

checkbox("Fly V3 (Fixed)", false, function(v)
    S.fly = v
    if v then startFly() else stopFly() end
end)
slider("Fly Speed", 20, 500, 100, function(v) S.flySpeed = v end)

checkbox("Infinite Jump", false, function(v) S.infJump = v end)

checkbox("Speed", false, function(v)
    S.speed = v
    local h = getHum()
    if h then h.WalkSpeed = v and S.speedVal or 16 end
end)
slider("Speed Value", 100, 100000000, 1000, function(v)
    S.speedVal = v
    if S.speed then
        local h = getHum()
        if h then h.WalkSpeed = v end
    end
end, function(v)
    if v >= 1000000 then return string.format("%.1fM", v / 1000000)
    elseif v >= 1000 then return string.format("%.1fK", v / 1000)
    end
    return tostring(v)
end)

checkbox("Click Teleport (Ctrl+Click)", false, function(v) S.clickTP = v end)

section("SURVIVAL")
checkbox("God Mode", false, function(v)
    S.godMode = v
    if v then applyGod() else removeGod() end
end)
checkbox("Noclip", false, function(v) S.noclip = v end)
checkbox("Jesus (Walk Water)", false, function(v) S.jesus = v end)
checkbox("Anti Void", false, function(v) S.antiVoid = v end)
checkbox("Anti Ragdoll", false, function(v) S.antiRagdoll = v end)
checkbox("Infinite Yield (No Fall Dmg)", false, function(v) S.infYield = v end)

section("HIDE")
checkbox("Invisible (Total)", false, function(v) S.invisible = v end)
checkbox("Hide From Others (Keliatan Sendiri)", false, function(v) S.hideFromOthers = v end)
checkbox("Hide Popups", false, function(v) S.hidePopups = v end)

section("COMBAT")
checkbox("Hitbox Expander", false, function(v) S.hitboxExpand = v end)
slider("Hitbox Size", 2, 30, 10, function(v) S.hitboxSize = v end)

section("VISUAL")
checkbox("ESP Player", false, function(v) S.espPlayer = v end)
checkbox("Fullbright", false, function(v) S.fullbright = v end)
checkbox("FPS Boost", false, function(v) S.fpsBoost = v end)

section("UTILITY")
checkbox("Anti AFK", true, function(v) S.antiAfk = v end)
checkbox("Auto Rejoin", false, function(v) S.autoRejoin = v end)

local destroyBtn = Instance.new("TextButton")
destroyBtn.Size = UDim2.new(1, -8, 0, 34)
destroyBtn.BackgroundColor3 = C.danger
destroyBtn.Text = "🗑️ HAPUS SCRIPT"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.TextSize = 12
destroyBtn.BorderSizePixel = 0
destroyBtn.Parent = sf
local dbc = Instance.new("UICorner"); dbc.CornerRadius = UDim.new(0, 8); dbc.Parent = destroyBtn
destroyBtn.MouseButton1Click:Connect(function()
    _G.REY_UNIV_CLEANUP()
    _G.REY_UNIV_CLEANUP = nil
end)

task.spawn(function()
    while state.running and gui.Parent do
        pcall(function()
            statusLabel.Text = string.format("Hops: %d | Jumps: %d | TPs: %d | %ds",
                stats.hops, stats.jumps, stats.tps, os.time() - stats.uptime)
        end)
        task.wait(0.5)
    end
end)

print("[REY] universal v4 ready")
