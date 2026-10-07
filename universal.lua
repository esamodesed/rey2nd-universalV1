-- REY2ND-UNIVERSAL v2 | Fixed Fly + Working Slider
-- Developer: Rey2nd
print("[REY] universal v2 loaded")

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
    infJump=false,
    speed=false, speedVal=1000,
}
local stats = { uptime=os.time(), hops=0, jumps=0 }

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
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(rayOrigin, rayDir, rayParams)

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
--              FLY V2 — FIXED (bisa gerak, ga stuck)
-- ============================================================
local flyBV, flyBG, flyConn, flyLoop

local function stopFly()
    if flyConn then pcall(function() flyConn:Disconnect() end) flyConn = nil end
    if flyLoop then pcall(function() flyLoop:Disconnect() end) flyLoop = nil end
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    local h = getHum()
    if h then pcall(function() h.PlatformStand = false end) end
end

local function startFly()
    stopFly()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp then return end

    -- Set PlatformStand biar physics normal di-disable
    if hum then
        pcall(function()
            hum.PlatformStand = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end

    -- BodyVelocity — force besar biar lawan gravity
    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "REY_FLY_BV"
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.P = 1e4  -- P gede biar responsif
    flyBV.Parent = hrp

    -- BodyGyro — biar tetap tegak
    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "REY_FLY_BG"
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 1e4
    flyBG.D = 500
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    -- Loop utama
    flyConn = RunService.RenderStepped:Connect(function()
        if not S.fly then return end
        local h = getHRP()
        if not h or not flyBV or not flyBG then return end

        local moveDir = Vector3.zero
        local camCF = Cam.CFrame

        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            flyBV.Velocity = moveDir.Unit * S.flySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = camCF
    end)

    -- Loop guard — re-apply kalau flyBV/BG ke-hapus atau PlatformStand balik
    flyLoop = RunService.Heartbeat:Connect(function()
        if not S.fly then return end
        local h = getHRP()
        local hum = getHum()
        if not h then return end
        -- Re-parent kalau ke-hapus
        if not h:FindFirstChild("REY_FLY_BV") and flyBV then
            pcall(function() flyBV.Parent = h end)
        end
        if not h:FindFirstChild("REY_FLY_BG") and flyBG then
            pcall(function() flyBG.Parent = h end)
        end
        -- Re-platform stand
        if hum and not hum.PlatformStand then
            pcall(function() hum.PlatformStand = true end)
        end
    end)
end

-- Auto-restart fly kalau karakter respawn
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.fly then startFly() end
end)

-- ============================================================
--              INVISIBLE
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.invisible then return end
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function()
                p.Transparency = 1
                p.LocalTransparencyModifier = 1
            end)
        elseif p:IsA("Decal") or p:IsA("Texture") then
            pcall(function() p.Transparency = 1 end)
        end
    end
end))

-- ============================================================
--              INFINITE JUMP
-- ============================================================
table.insert(state.conns, UIS.JumpRequest:Connect(function()
    if S.infJump then
        local h = getHum()
        if h then
            pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
            stats.jumps = stats.jumps + 1
        end
    end
end))

table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.infJump then return end
    local h = getHum()
    if h then
        pcall(function()
            if h:GetState() == Enum.HumanoidStateType.Freefall then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end))

-- ============================================================
--              SPEED — FIXED (langsung apply)
-- ============================================================
table.insert(state.conns, RunService.Heartbeat:Connect(function()
    if not S.speed then return end
    local h = getHum()
    if h then
        pcall(function() h.WalkSpeed = S.speedVal end)
    end
end))

-- ============================================================
--              UI (FIXED MINIMIZE + SLIDER)
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
main.Size = UDim2.new(0, 320, 0, 460)
main.Position = UDim2.new(0, 20, 0.5, -230)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = main
local ms = Instance.new("UIStroke"); ms.Color = C.accent; ms.Thickness = 1.5; ms.Parent = main

-- HEADER
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
title.Text = "REY2ND  ✦  UNIVERSAL v2"
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

-- CONTENT WRAPPER (yang di-hide saat minimize)
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
sf.ScrollBarThickness = 4
sf.ScrollBarImageColor3 = C.accent
sf.CanvasSize = UDim2.new(0, 0, 0, 0)
sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.Parent = contentWrap
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = sf

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 20)
footer.Position = UDim2.new(0, 10, 1, -30)
footer.BackgroundTransparency = 1
footer.Text = "Developer: Rey2nd"
footer.TextColor3 = C.gold
footer.Font = Enum.Font.GothamBold
footer.TextSize = 11
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = contentWrap

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 1, -50)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = C.dim
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = contentWrap

-- FLOATING BTN
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

-- MINIMIZE LOGIC (FIXED — nggak nyampur)
local isMin = false
local MAX_SIZE = UDim2.new(0, 320, 0, 460)
local MIN_SIZE = UDim2.new(0, 320, 0, 40)

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
    -- reset ke full
    if isMin then
        isMin = false
        main.Size = MAX_SIZE
        contentWrap.Visible = true
        minBtn.Text = "—"
    end
end)

-- ============================================================
--              UI BUILDERS
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

-- SLIDER FIXED — bisa digeser + callback real-time
local function slider(name, minV, maxV, defV, cb, formatFn)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 58)
    row.BackgroundColor3 = C.panel
    row.BorderSizePixel = 0
    row.Parent = sf
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 8); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = name .. ": " .. (formatFn and formatFn(defV) or defV)
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- VALUE DISPLAY (kanan)
    local valDisplay = Instance.new("TextLabel")
    valDisplay.Size = UDim2.new(0, 60, 0, 18)
    valDisplay.Position = UDim2.new(1, -74, 0, 4)
    valDisplay.BackgroundTransparency = 1
    valDisplay.Text = tostring(defV)
    valDisplay.TextColor3 = C.accent
    valDisplay.Font = Enum.Font.GothamBold
    valDisplay.TextSize = 12
    valDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valDisplay.Parent = row

    -- TRACK
    local track = Instance.new("TextButton")  -- pakai TextButton biar capture input
    track.Size = UDim2.new(1, -28, 0, 16)
    track.Position = UDim2.new(0, 14, 0, 34)
    track.BackgroundColor3 = C.bg
    track.Text = ""
    track.AutoButtonColor = false
    track.BorderSizePixel = 0
    track.Parent = row
    local trc = Instance.new("UICorner"); trc.CornerRadius = UDim.new(1, 0); trc.Parent = track

    -- FILL
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defV - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    local flc = Instance.new("UICorner"); flc.CornerRadius = UDim.new(1, 0); flc.Parent = fill

    -- KNOB
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
        local val = minV + rel * (maxV - minV)
        val = math.floor(val)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, -10)
        valDisplay.Text = tostring(val)
        lbl.Text = name .. ": " .. (formatFn and formatFn(val) or val)
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

    -- support touch langsung di track
    track.MouseButton1Down:Connect(function()
        dragging = true
    end)
end

-- ============================================================
--              MENU CONTENT
-- ============================================================
section("MOVE")
checkbox("Wall Hop", false, function(v) S.wallHop = v end)
slider("Wall Hop Power", 10, 200, 50, function(v) S.wallHopPower = v end)

checkbox("Fly V2 (Fixed)", false, function(v)
    S.fly = v
    if v then
        startFly()
    else
        stopFly()
    end
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
    if v >= 1000000 then
        return string.format("%.1fM", v / 1000000)
    elseif v >= 1000 then
        return string.format("%.1fK", v / 1000)
    end
    return tostring(v)
end)

section("VISUAL")
checkbox("Invisible (No Visual)", false, function(v) S.invisible = v end)

-- Update status live
task.spawn(function()
    while state.running and gui.Parent do
        pcall(function()
            statusLabel.Text = string.format("Hops: %d | Jumps: %d | Uptime: %ds",
                stats.hops, stats.jumps, os.time() - stats.uptime)
        end)
        task.wait(0.5)
    end
end)

print("[REY] universal v2 ready")
