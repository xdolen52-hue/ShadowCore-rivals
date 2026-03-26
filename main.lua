--[[
    ShadowCore v1.0 – Professional Rivals Script
    - Регулярные обновления в Discord
    - Читы на другие игры и плейсы
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

print("=== ShadowCore v1.0 – Professional Rivals Script ===")

-- ==================== ПРОВЕРКА API ====================
local hasDrawing = pcall(function() return Drawing.new("Circle") end)
local hasMouseMove = pcall(function() mousemoverel(0,0) end)
local hasMouseClick = pcall(function() mouse1click() end)
local hasSetClipboard = pcall(function() setclipboard("test") end)

-- ==================== НАСТРОЙКИ ====================
local Settings = {
    Aimbot = false,
    AimbotVisibleOnly = false,
    AimPart = "Head",
    AimSmoothness = 5,
    FovRadius = 300,
    FovCircle = false,
    ESP = false,
    ESPThickness = 2,
    ESPColor = "Green",
    Triggerbot = false,
    InfiniteJump = false,
    SpeedHack = false,
    SpeedValue = 50,
    Noclip = false
}

local lastNoclipState = nil
local lastSpeedState = nil

-- Бинд T
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        Settings.Aimbot = not Settings.Aimbot
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ShadowCore",
                Text = "Aimbot " .. (Settings.Aimbot and "Включен" or "Выключен"),
                Duration = 2
            })
        end)
    end
end)

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowCore"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 620)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(150, 50, 200)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "SHADOWCORE v1.0"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 1, 0)
minimizeBtn.Position = UDim2.new(1, -70, 0, 0)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 1, 0)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = titleBar

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -10, 1, -45)
contentFrame.Position = UDim2.new(0, 5, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = contentFrame

local function updateCanvas()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 380, 0, 35) or UDim2.new(0, 380, 0, 620)
    minimizeBtn.Text = minimized and "□" or "—"
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local dragging = false
local dragStart, frameStart
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = mainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

-- ==================== ЭЛЕМЕНТЫ GUI ====================

local function CreateToggle(parent, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 26)
    btn.Position = UDim2.new(1, -60, 0.5, -13)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(55, 55, 65)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = frame
    
    local state = defaultValue
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(55, 55, 65)
        callback(state)
    end)
    
    return frame
end

local function CreateSlider(parent, text, min, max, defaultValue, callback, format)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. (format and format(defaultValue) or tostring(math.floor(defaultValue)))
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 4)
    sliderBg.Position = UDim2.new(0, 0, 0, 28)
    sliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local fill = Instance.new("Frame")
    local percent = (defaultValue - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local value = defaultValue
    local dragging = false
    
    local function updateValue(inputPos)
        local percent = math.clamp((inputPos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = min + percent * (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. (format and format(value) or tostring(math.floor(value)))
        callback(value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position)
        end
    end)
    
    return frame
end

local function CreateRadioGroup(parent, text, options, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = frame
    
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, 0, 0, 26)
    btnContainer.Position = UDim2.new(0, 0, 0, 22)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = frame
    
    local currentValue = defaultValue
    local buttons = {}
    
    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 1, 0)
        btn.Position = UDim2.new(0, (i-1) * 82, 0, 0)
        btn.Text = opt
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = (opt == defaultValue) and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(45, 45, 55)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = btnContainer
        
        btn.MouseButton1Click:Connect(function()
            currentValue = opt
            for _, b in ipairs(buttons) do
                b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            end
            btn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
            callback(opt)
        end)
        
        table.insert(buttons, btn)
    end
    
    return frame
end

local function CreateFoldableSection(parent, title, icon)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 42)
    sectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    sectionFrame.BackgroundTransparency = 0.2
    sectionFrame.BorderSizePixel = 1
    sectionFrame.BorderColor3 = Color3.fromRGB(150, 50, 200)
    sectionFrame.ClipsDescendants = true
    sectionFrame.Parent = parent
    
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, -40, 0, 42)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    header.BackgroundTransparency = 0.4
    header.BorderSizePixel = 0
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = "  " .. icon .. " " .. title
    header.Parent = sectionFrame
    
    local arrowBtn = Instance.new("TextButton")
    arrowBtn.Size = UDim2.new(0, 35, 1, 0)
    arrowBtn.Position = UDim2.new(1, -35, 0, 0)
    arrowBtn.Text = "▼"
    arrowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrowBtn.BackgroundTransparency = 1
    arrowBtn.Font = Enum.Font.GothamBold
    arrowBtn.TextSize = 14
    arrowBtn.Parent = sectionFrame
    
    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 42)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = sectionFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.Parent = contentHolder
    
    local isOpen = false
    local contentHeight = 0
    
    local function updateHeight()
        if isOpen then
            contentHolder.Size = UDim2.new(1, 0, 0, contentHeight)
            sectionFrame.Size = UDim2.new(1, 0, 0, 42 + contentHeight)
            arrowBtn.Text = "▲"
        else
            contentHolder.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.Size = UDim2.new(1, 0, 0, 42)
            arrowBtn.Text = "▼"
        end
        updateCanvas()
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentHeight = contentLayout.AbsoluteContentSize.Y + 8
        if isOpen then
            contentHolder.Size = UDim2.new(1, 0, 0, contentHeight)
            sectionFrame.Size = UDim2.new(1, 0, 0, 42 + contentHeight)
            updateCanvas()
        end
    end)
    
    arrowBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        updateHeight()
    end)
    
    return contentHolder, header
end

-- ==================== INFO ОКНО (с прокруткой и шрифтом 24) ====================
local infoGui = nil
local function ShowInfoWindow()
    if infoGui then
        infoGui:Destroy()
        infoGui = nil
    end
    
    infoGui = Instance.new("ScreenGui")
    infoGui.Name = "InfoWindow"
    infoGui.ResetOnSpawn = false
    infoGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 800, 0, 700)
    frame.Position = UDim2.new(0.5, -400, 0.5, -350)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(150, 50, 200)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = infoGui
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Text = "SHADOWCORE v1.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.Parent = titleBar
    
    local closeInfo = Instance.new("TextButton")
    closeInfo.Size = UDim2.new(0, 55, 1, 0)
    closeInfo.Position = UDim2.new(1, -55, 0, 0)
    closeInfo.Text = "✕"
    closeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeInfo.BackgroundTransparency = 1
    closeInfo.Font = Enum.Font.GothamBold
    closeInfo.TextSize = 28
    closeInfo.Parent = titleBar
    closeInfo.MouseButton1Click:Connect(function()
        infoGui:Destroy()
        infoGui = nil
    end)
    
    -- Скроллинг фрейм для текста
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -70)
    scrollFrame.Position = UDim2.new(0, 10, 0, 65)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 12
    scrollFrame.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.Text = [[
╔══════════════════════════════════════════════════════════════════════════════╗
║                           SHADOWCORE v1.0                                    ║
║                     Professional Script for Rivals                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔥 ФУНКЦИИ:
   • Aimbot (бинт T) – наведение на голову/торс с плавностью
   • ESP – бокс, имя, HP, дистанция, оружие
   • Triggerbot – автоматический выстрел при наведении
   • Infinite Jump – бесконечные прыжки (зажми ПРОБЕЛ)
   • SpeedHack – ускорение передвижения (20-300%)
   • Noclip – проход сквозь стены и объекты
   • FOV Circle – визуальная зона действия аимбота

⚙️ НАСТРОЙКИ:
   • Каждая секция раскрывается по стрелочке ▶
   • Aimbot: выбор цели, плавность, радиус, видимость
   • ESP: толщина и цвет бокса

📢 ОБНОВЛЕНИЯ:
   Скрипт будет регулярно обновляться!
   Все новости, обновления и новые версии выходят в Discord.

🎮 ДРУГИЕ ПРОДУКТЫ:
   У нас есть читы на другие игры и плейсы Roblox!
   Следите за анонсами в Discord-сервере.

💬 DISCORD: https://discord.gg/zHBFvvH8f8
   • Поддержка 24/7
   • Новые версии первыми
   • Эксклюзивные функции
   • Читы на другие игры

⭐ ShadowCore – Ваш надёжный выбор для доминирования в Rivals!
]]
    textLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 24
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = scrollFrame
    
    -- Вычисляем высоту текста
    local function updateTextHeight()
        local textBounds = textLabel.TextBounds
        textLabel.Size = UDim2.new(1, -20, 0, textBounds.Y + 40)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 60)
    end
    updateTextHeight()
    textLabel:GetPropertyChangedSignal("Text"):Connect(updateTextHeight)
    
    local dragStart, frameStart
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            frameStart = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = nil
        end
    end)
end

-- ==================== СОЗДАНИЕ СЕКЦИЙ ====================

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 0, 28)
statusText.Text = "СТАТУС: ГОТОВ | БИНД T: AIMBOT"
statusText.TextColor3 = Color3.fromRGB(150, 50, 200)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 11
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = contentFrame
statusText.LayoutOrder = 0

-- Секция AIMBOT
local aimbotContent, aimbotHeader = CreateFoldableSection(contentFrame, "AIMBOT", "🎯")

local aimbotMainToggle = CreateToggle(aimbotContent, "Aimbot Enabled", false, function(v)
    Settings.Aimbot = v
    aimbotHeader.Text = v and "  🎯 AIMBOT [ON]" or "  🎯 AIMBOT"
    aimbotHeader.BackgroundTransparency = v and 0.2 or 0.4
end)
aimbotMainToggle.LayoutOrder = 1

CreateRadioGroup(aimbotContent, "Aim Part", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v) Settings.AimPart = v end).LayoutOrder = 2
CreateSlider(aimbotContent, "Smoothness", 1, 20, 5, function(v) Settings.AimSmoothness = v end, function(v) return tostring(math.floor(v)) end).LayoutOrder = 3
CreateSlider(aimbotContent, "FOV Radius", 50, 500, 300, function(v) Settings.FovRadius = v end, function(v) return tostring(math.floor(v)) .. " px" end).LayoutOrder = 4
CreateToggle(aimbotContent, "Visible Only", false, function(v) Settings.AimbotVisibleOnly = v end).LayoutOrder = 5
CreateToggle(aimbotContent, "FOV Circle", false, function(v) Settings.FovCircle = v end).LayoutOrder = 6

-- Секция ESP
local espContent, espHeader = CreateFoldableSection(contentFrame, "ESP", "👁️")

local espMainToggle = CreateToggle(espContent, "ESP Enabled", false, function(v)
    Settings.ESP = v
    espHeader.Text = v and "  👁️ ESP [ON]" or "  👁️ ESP"
    espHeader.BackgroundTransparency = v and 0.2 or 0.4
end)
espMainToggle.LayoutOrder = 1

CreateSlider(espContent, "Box Thickness", 1, 4, 2, function(v) Settings.ESPThickness = v end, function(v) return tostring(math.floor(v)) end).LayoutOrder = 2

local colorFrame = Instance.new("Frame")
colorFrame.Size = UDim2.new(1, 0, 0, 48)
colorFrame.BackgroundTransparency = 1
colorFrame.LayoutOrder = 3
colorFrame.Parent = espContent

local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, 0, 0, 20)
colorLabel.Text = "Box Color"
colorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.BackgroundTransparency = 1
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextSize = 11
colorLabel.Parent = colorFrame

local colorContainer = Instance.new("Frame")
colorContainer.Size = UDim2.new(1, 0, 0, 26)
colorContainer.Position = UDim2.new(0, 0, 0, 22)
colorContainer.BackgroundTransparency = 1
colorContainer.Parent = colorFrame

local colors = {"Green", "Red", "Blue", "Yellow", "White"}
local colorBtns = {}

for i, c in ipairs(colors) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 68, 1, 0)
    btn.Position = UDim2.new(0, (i-1) * 70, 0, 0)
    btn.Text = c
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = (c == "Green") and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(45, 45, 55)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.Parent = colorContainer
    
    btn.MouseButton1Click:Connect(function()
        Settings.ESPColor = c
        for _, b in ipairs(colorBtns) do
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
        btn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    end)
    table.insert(colorBtns, btn)
end

-- Секция TRIGGERBOT
local triggerContent, triggerHeader = CreateFoldableSection(contentFrame, "TRIGGERBOT", "⚡")

CreateToggle(triggerContent, "Triggerbot Enabled", false, function(v) Settings.Triggerbot = v end).LayoutOrder = 1

-- Секция INFINITE JUMP
local jumpContent, jumpHeader = CreateFoldableSection(contentFrame, "INFINITE JUMP", "🦅")

CreateToggle(jumpContent, "Infinite Jump (hold SPACE)", false, function(v) Settings.InfiniteJump = v end).LayoutOrder = 1

-- Секция SPEED HACK
local speedContent, speedHeader = CreateFoldableSection(contentFrame, "SPEED HACK", "⚡")

CreateToggle(speedContent, "Speed Hack Enabled", false, function(v) Settings.SpeedHack = v end).LayoutOrder = 1
CreateSlider(speedContent, "Speed Value", 20, 300, 50, function(v) Settings.SpeedValue = v end, function(v) return tostring(math.floor(v)) .. "%" end).LayoutOrder = 2

-- Секция NOCLIP
local noclipContent, noclipHeader = CreateFoldableSection(contentFrame, "NOCLIP", "🚪")

CreateToggle(noclipContent, "Noclip Enabled", false, function(v) Settings.Noclip = v end).LayoutOrder = 1

-- Кнопки Discord и Info
local bottomFrame = Instance.new("Frame")
bottomFrame.Size = UDim2.new(1, -10, 0, 44)
bottomFrame.BackgroundTransparency = 1
bottomFrame.Parent = contentFrame
bottomFrame.LayoutOrder = 999

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0.48, 0, 1, 0)
discordBtn.Position = UDim2.new(0, 0, 0, 0)
discordBtn.Text = "💬 DISCORD"
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.BackgroundTransparency = 0.2
discordBtn.BorderSizePixel = 1
discordBtn.BorderColor3 = Color3.fromRGB(150, 50, 200)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12
discordBtn.Parent = bottomFrame
discordBtn.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard("https://discord.gg/zHBFvvH8f8")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ShadowCore",
            Text = "Ссылка на Discord скопирована",
            Duration = 3
        })
    end)
end)

local infoBtn = Instance.new("TextButton")
infoBtn.Size = UDim2.new(0.48, 0, 1, 0)
infoBtn.Position = UDim2.new(0.52, 0, 0, 0)
infoBtn.Text = "ℹ️ INFO"
infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
infoBtn.BackgroundTransparency = 0.2
infoBtn.BorderSizePixel = 1
infoBtn.BorderColor3 = Color3.fromRGB(150, 50, 200)
infoBtn.Font = Enum.Font.GothamBold
infoBtn.TextSize = 12
infoBtn.Parent = bottomFrame
infoBtn.MouseButton1Click:Connect(function()
    ShowInfoWindow()
end)

updateCanvas()

-- ==================== ОСНОВНЫЕ ФУНКЦИИ ====================

local function IsVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

local function GetEnemies()
    local enemies = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    local tool = char:FindFirstChildOfClass("Tool")
                    if head and root then
                        table.insert(enemies, {
                            player = player,
                            char = char,
                            hum = hum,
                            head = head,
                            root = root,
                            upperTorso = upperTorso,
                            tool = tool
                        })
                    end
                end
            end
        end
    end
    return enemies
end

local function GetScreenPos(part)
    if not part then return nil end
    local pos, onScreen = Camera:WorldToScreenPoint(part.Position)
    if not onScreen then return nil end
    return Vector2.new(pos.X, pos.Y)
end

local function GetClosestToMouse()
    local enemies = GetEnemies()
    local closest, closestDist = nil, Settings.FovRadius
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, e in ipairs(enemies) do
        local aimPart = e[Settings.AimPart] or e.head
        if aimPart then
            local screenPos = GetScreenPos(aimPart)
            if screenPos then
                local dist = (screenPos - mousePos).Magnitude
                local visible = true
                if Settings.AimbotVisibleOnly then
                    visible = IsVisible(aimPart)
                end
                if dist < closestDist and visible then
                    closestDist = dist
                    closest = e
                end
            end
        end
    end
    return closest
end

local function DoAimbot()
    if not Settings.Aimbot or not hasMouseMove then return end
    local target = GetClosestToMouse()
    if not target then return end
    local aimPart = target[Settings.AimPart] or target.head
    local screenPos = GetScreenPos(aimPart)
    if screenPos then
        local delta = screenPos - Vector2.new(Mouse.X, Mouse.Y)
        if delta.Magnitude > 0.5 then
            local smoothFactor = 1 / Settings.AimSmoothness
            delta = delta * smoothFactor
            pcall(function() mousemoverel(delta.X, delta.Y) end)
        end
    end
end

local lastShot = 0
local function DoTriggerbot()
    if not Settings.Triggerbot or not hasMouseClick then return end
    local target = GetClosestToMouse()
    if target then
        local screenPos = GetScreenPos(target.head)
        if screenPos then
            local dist = (screenPos - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if dist < 150 and IsVisible(target.head) then
                if tick() - lastShot > 0.05 then
                    lastShot = tick()
                    pcall(function() mouse1click() end)
                end
            end
        end
    end
end

local espObjects = {}
local colorMap = {
    Green = Color3.fromRGB(0,255,0),
    Red = Color3.fromRGB(255,0,0),
    Blue = Color3.fromRGB(0,100,255),
    Yellow = Color3.fromRGB(255,255,0),
    White = Color3.fromRGB(255,255,255)
}

local function DoESP()
    if not Settings.ESP or not hasDrawing then return end
    local enemies = GetEnemies()
    local active = {}
    local boxColor = colorMap[Settings.ESPColor] or Color3.fromRGB(0,255,0)
    
    for _, e in ipairs(enemies) do
        local key = tostring(e.player.UserId)
        local headScreen = GetScreenPos(e.head)
        local rootScreen = GetScreenPos(e.root)
        if headScreen and rootScreen then
            active[key] = true
            if not espObjects[key] then
                espObjects[key] = {
                    box = Drawing.new("Square"),
                    text = Drawing.new("Text")
                }
                espObjects[key].text.Center = true
                espObjects[key].text.Outline = true
                espObjects[key].text.OutlineColor = Color3.fromRGB(0,0,0)
                espObjects[key].text.Size = 12
            end
            local isVisible = IsVisible(e.head)
            local color = isVisible and boxColor or Color3.fromRGB(255,120,0)
            local boxHeight = rootScreen.Y - headScreen.Y + 15
            local boxWidth = boxHeight * 0.45
            local boxPos = Vector2.new(headScreen.X - boxWidth/2, headScreen.Y - 5)
            espObjects[key].box.Visible = true
            espObjects[key].box.Size = Vector2.new(boxWidth, boxHeight)
            espObjects[key].box.Position = boxPos
            espObjects[key].box.Thickness = Settings.ESPThickness
            espObjects[key].box.Color = color
            espObjects[key].box.Filled = false
            local distance = (e.head.Position - Camera.CFrame.Position).Magnitude
            local weaponName = e.tool and e.tool.Name or "No weapon"
            local health = math.floor(e.hum.Health)
            local info = string.format("%s | %d HP | %.0fm | %s", e.player.Name, health, distance, weaponName)
            espObjects[key].text.Visible = true
            espObjects[key].text.Text = info
            espObjects[key].text.Position = Vector2.new(headScreen.X, headScreen.Y - 22)
            espObjects[key].text.Color = color
        else
            if espObjects[key] then
                espObjects[key].box.Visible = false
                espObjects[key].text.Visible = false
            end
        end
    end
    for key, obj in pairs(espObjects) do
        if not active[key] then
            obj.box.Visible = false
            obj.text.Visible = false
        end
    end
end

local function ApplyNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    if Settings.Noclip ~= lastNoclipState then
        lastNoclipState = Settings.Noclip
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not Settings.Noclip
            end
        end
    end
end

local spacePressed = false
local jumpTimer = 0
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space then spacePressed = true end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space then spacePressed = false end
end)

local function DoInfiniteJump()
    if not Settings.InfiniteJump then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if spacePressed then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
            if tick() - jumpTimer > 0.1 then
                jumpTimer = tick()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end

local function DoSpeedHack()
    if not Settings.SpeedHack then
        if lastSpeedState ~= false then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
            end
            lastSpeedState = false
        end
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local targetSpeed = 16 * (Settings.SpeedValue / 100)
    if hum.WalkSpeed ~= targetSpeed then
        hum.WalkSpeed = targetSpeed
    end
    lastSpeedState = true
end

local fovCircle = nil
if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(150, 50, 200)
    fovCircle.Filled = false
    fovCircle.NumSides = 64
    fovCircle.Transparency = 0.5
end

local function UpdateFovCircle()
    if not hasDrawing then return end
    if Settings.FovCircle then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        fovCircle.Radius = Settings.FovRadius
        fovCircle.Color = Settings.Aimbot and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(100, 100, 100)
    else
        fovCircle.Visible = false
    end
end

Workspace.Changed:Connect(function()
    Camera = workspace.CurrentCamera
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        DoAimbot()
        DoESP()
        DoTriggerbot()
        DoInfiniteJump()
        DoSpeedHack()
        UpdateFovCircle()
        ApplyNoclip()
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    print("[ShadowCore] v1.0 загружена")
    statusText.Text = "СТАТУС: В БОЮ | SHADOWCORE ACTIVE"
    lastNoclipState = nil
    lastSpeedState = nil
end)

print("")
print("╔═══════════════════════════════════════════════════════════════╗")
print("║              SHADOWCORE v1.0 – PROFESSIONAL                  ║")
print("╠═══════════════════════════════════════════════════════════════╣")
print("║  ✅ ShadowCore – Ваш выбор для доминирования в Rivals!       ║")
print("║  ✅ Регулярные обновления в Discord                          ║")
print("║  ✅ Читы на другие игры и плейсы                             ║")
print("║  📢 Discord: https://discord.gg/zHBFvvH8f8                   ║")
print("╚═══════════════════════════════════════════════════════════════╝")
