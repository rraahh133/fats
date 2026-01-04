-- ============================================
-- UNDETECTED UI LIBRARY
-- ============================================
-- Anti-detection modifications:
-- 1. Uses gethui() or alternative parent instead of CoreGui
-- 2. Random naming to avoid pattern detection
-- 3. Removed/wrapped suspicious calls (Stats, MarketplaceService)
-- 4. All sensitive calls wrapped in pcall

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- ANTI-DETECTION: Function to get safe parent
local function getSafeGuiParent()
    -- Priority 1: gethui() - executor's hidden UI container
    if gethui then
        local success, result = pcall(gethui)
        if success and result then
            return result
        end
    end
    
    -- Priority 2: cloneref'd CoreGui (harder to detect)
    if cloneref then
        local success, result = pcall(function()
            return cloneref(game:GetService("CoreGui"))
        end)
        if success and result then
            return result
        end
    end
    
    -- Priority 3: PlayerGui (more detectable but works)
    local player = Players.LocalPlayer
    if player then
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            return playerGui
        end
    end
    
    -- Fallback: Standard CoreGui
    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if success then
        return coreGui
    end
    
    return nil
end

-- ANTI-DETECTION: Generate random names
local function generateRandomName(prefix)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local name = prefix or ""
    for i = 1, math.random(6, 10) do
        local idx = math.random(1, #chars)
        name = name .. chars:sub(idx, idx)
    end
    return name
end

local Library = {}
Library.Flags = {}
Library.Theme = {
    Background = Color3.fromRGB(10, 10, 15),
    CardInfo = Color3.fromRGB(15, 15, 21),
    Accent = Color3.fromRGB(59, 130, 246),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(120, 120, 140),
    Border = Color3.fromRGB(30, 30, 45),
    Success = Color3.fromRGB(50, 200, 100),
}

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(object, TweenInfo.new(0.05), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end

function Library:Loader(startConfig)
    local loadInfo = startConfig or {}
    local Name = loadInfo.Name or "Sim1X"
    local Duration = loadInfo.Duration or 2
    
    -- 1. Setup Blur (wrapped in pcall for safety)
    local Blur
    pcall(function()
        local Lighting = game:GetService("Lighting")
        Blur = Instance.new("BlurEffect")
        Blur.Size = 0
        Blur.Parent = Lighting
        TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 24}):Play()
    end)
    
    -- 2. Setup Gui
    local guiParent = getSafeGuiParent()
    if not guiParent then return end
    
    local LoaderGui = Create("ScreenGui", {
        Name = generateRandomName("L"),
        Parent = guiParent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    local Background = Create("Frame", {
        Parent = LoaderGui,
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 0
    })
    
    local CenterText = Create("TextLabel", {
        Parent = LoaderGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 0.2),
        Font = Enum.Font.GothamBlack,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 64,
    })
    
    -- 3. Gradient for Text
    local Gradient = Create("UIGradient", {
        Parent = CenterText,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 255))
        }),
        Rotation = 45
    })
    
    -- Typewriter Effect
    TweenService:Create(Background, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    task.wait(0.5)
    
    for i = 1, #Name do
        CenterText.Text = Name:sub(1, i)
        task.wait(math.random(5, 15) / 100) 
    end
    
    task.wait(Duration)
    
    -- 4. Fade Out
    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if Blur then
        TweenService:Create(Blur, fadeInfo, {Size = 0}):Play()
    end
    TweenService:Create(Background, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(CenterText, fadeInfo, {TextTransparency = 1}):Play()
    
    task.wait(0.8)
    
    LoaderGui:Destroy()
    if Blur then Blur:Destroy() end
end

function Library:Window(options)
    local UI_Name = options.Name or generateRandomName("UI")
    
    local guiParent = getSafeGuiParent()
    if not guiParent then
        warn("Could not find safe GUI parent")
        return nil
    end
    
    -- Prevent duplicates / cleanup old instances
    local existing = guiParent:FindFirstChild(UI_Name)
    if existing then
        existing:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {
        Name = UI_Name,
        Parent = guiParent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local MainFrame = Create("Frame", {
        Name = generateRandomName("M"),
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.2, 0.2),
        Size = UDim2.fromOffset(850, 550),
        ClipsDescendants = true
    })
    
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Library.Theme.Border, Thickness = 1})

    MakeDraggable(MainFrame, MainFrame)

    --// Header Area
    local Header = Create("Frame", {
        Name = generateRandomName("H"),
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(12, 12, 18),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
    })
    
    local Logo = Create("TextLabel", {
        Name = generateRandomName("Lo"),
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = options.Name or "Sim1X",
        TextColor3 = Color3.fromRGB(240, 240, 255),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("Frame", {
        Parent = Logo,
        BackgroundColor3 = Library.Theme.Accent,
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, -15, 0.5, -4),
    })

    local TabContainer = Create("Frame", {
        Name = generateRandomName("T"),
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0, 0),
        Size = UDim2.new(1, -350, 1, 0),
    })
    
    Create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    --// User Info / Status (Top Right)
    local UserInfo = Create("Frame", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -160, 0, 0),
        Size = UDim2.new(0, 150, 1, 0)
    })
    
    local UserID = Create("TextLabel", {
        Parent = UserInfo,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0,0,0.1,0),
        Font = Enum.Font.GothamMedium,
        Text = "USER: " .. Players.LocalPlayer.Name,
        TextColor3 = Library.Theme.TextDark,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local Status = Create("TextLabel", {
        Parent = UserInfo,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0,0,0.5,0),
        Font = Enum.Font.GothamBold,
        Text = "GAME: ...",
        TextColor3 = Library.Theme.Success,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    -- ANTI-DETECTION: Safely get game name with pcall
    task.spawn(function()
        pcall(function()
            local MarketplaceService = game:GetService("MarketplaceService")
            local success, info = pcall(function()
                return MarketplaceService:GetProductInfo(game.PlaceId)
            end)
            if success and info then
                Status.Text = "GAME: " .. info.Name
            else
                Status.Text = "GAME: Unknown"
            end
        end)
    end)

    --// Content Area
    local ContentArea = Create("Frame", {
        Name = generateRandomName("C"),
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 80),
        Size = UDim2.new(1, -40, 1, -110),
    })
    
    local MainContent = Create("ScrollingFrame", {
        Name = generateRandomName("MC"),
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, -10, 1, 0),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local SidebarContent = Create("Frame", {
        Name = generateRandomName("S"),
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 10, 0, 0),
        Size = UDim2.new(0.3, -10, 1, 0),
    })

    --// Footer
    local Footer = Create("Frame", {
        Name = generateRandomName("F"),
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(8, 8, 12),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -30),
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 2
    })
    
    local StatsLabel = Create("TextLabel", {
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "FPS: --   PING: --",
        TextColor3 = Library.Theme.Accent,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- ANTI-DETECTION: Stats Updater with safe access
    task.spawn(function()
        local lastTime = tick()
        local frames = 0
        
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
        end)
        
        while ScreenGui and ScreenGui:IsDescendantOf(game) do
            task.wait(1)
            local currentTime = tick()
            local fps = math.round(frames / (currentTime - lastTime))
            frames = 0
            lastTime = currentTime
            
            -- ANTI-DETECTION: Wrap Stats access in pcall
            local pingStr = "0"
            pcall(function()
                local Stats = game:GetService("Stats")
                if Stats and Stats.Network then
                    local serverStats = Stats.Network:FindFirstChild("ServerStatsItem")
                    if serverStats then
                        local dataPing = serverStats:FindFirstChild("Data Ping")
                        if dataPing then
                            pingStr = dataPing:GetValueString():match("^(%d+)") or "0"
                        end
                    end
                end
            end)
            
            StatsLabel.Text = string.format("FPS: %d   PING: %s ms", fps, pingStr)
        end
    end)

    --// Logic
    local WindowAPI = {}
    local Tabs = {}
    local CurrentTab = nil


    function WindowAPI:Tab(name, icon)
        local TabButton = Create("TextButton", {
            Name = generateRandomName("TB"),
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 90, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = name:upper(),
            TextColor3 = Library.Theme.TextDark,
            TextSize = 11,
        })
        
        local Ico = Create("ImageLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -10, 0.2, 0),
            Size = UDim2.fromOffset(20, 20),
            Image = icon or "rbxassetid://10709762497",
            ImageColor3 = Library.Theme.TextDark
        })
        TabButton.Text = "\n\n" .. name:upper()
        
        local Indicator = Create("Frame", {
            Parent = TabButton,
            BackgroundColor3 = Library.Theme.Accent,
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0,0,1,-2),
            BackgroundTransparency = 1
        })

        local TabPage = Create("Frame", {
            Name = generateRandomName("TP"),
            Parent = MainContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        })
        
        Create("UIListLayout", {
            Parent = TabPage,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 15)
        })

        local function Activate()
            if CurrentTab then
                CurrentTab.Button.TextColor3 = Library.Theme.TextDark
                CurrentTab.Icon.ImageColor3 = Library.Theme.TextDark
                CurrentTab.Indicator.BackgroundTransparency = 1
                CurrentTab.Page.Visible = false
            end
            
            TabButton.TextColor3 = Library.Theme.Text
            Ico.ImageColor3 = Library.Theme.Text
            Indicator.BackgroundTransparency = 0
            TabPage.Visible = true
            
            CurrentTab = {Button = TabButton, Icon = Ico, Indicator = Indicator, Page = TabPage}
        end

        TabButton.MouseButton1Click:Connect(Activate)
        
        if #Tabs == 0 then Activate() end
        table.insert(Tabs, {Button = TabButton, Icon = Ico, Indicator = Indicator, Page = TabPage})

        local TabAPI = {}

        function TabAPI:Section(title)
            local SectionFrame = Create("Frame", {
                Name = generateRandomName("Sec"),
                Parent = TabPage,
                BackgroundColor3 = Library.Theme.CardInfo,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SectionFrame, Color = Library.Theme.Border, Thickness = 1})
            
            local Title = Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = "|  " .. title:upper(),
                TextColor3 = Library.Theme.TextDark,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Container = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UIListLayout", {
                Parent = Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            Create("UIPadding", {Parent = SectionFrame, PaddingBottom = UDim.new(0, 15)})

            local SectionAPI = {}

            function SectionAPI:Toggle(cfg)
                local ToggleFrame = Create("Frame", {
                    Name = generateRandomName("Tog"),
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Button = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Library.Theme.Background,
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Size = UDim2.fromOffset(40, 20),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = Button, CornerRadius = UDim.new(1, 0)})
                
                local Circle = Create("Frame", {
                    Parent = Button,
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.new(0, 2, 0.5, -8)
                })
                Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
                
                local state = cfg.Default or false
                Library.Flags[cfg.Flag or cfg.Name] = state
                
                local function Update()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Background}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                    if cfg.Callback then 
                        pcall(cfg.Callback, state)
                    end
                end
                
                Button.MouseButton1Click:Connect(function()
                    state = not state
                    Library.Flags[cfg.Flag or cfg.Name] = state
                    Update()
                end)
                
                if state then Update() end
            end
            
            function SectionAPI:Slider(cfg)
                local SliderFrame = Create("Frame", {
                    Name = generateRandomName("Sli"),
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })

                local Label = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 55, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(cfg.Default or cfg.Min),
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SlidesBg = Create("TextButton", {
                    Name = generateRandomName("SB"),
                    Parent = SliderFrame,
                    BackgroundColor3 = Library.Theme.Background,
                    Position = UDim2.new(0, 5, 0, 25),
                    Size = UDim2.new(1, -10, 0, 8),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = SlidesBg, CornerRadius = UDim.new(1, 0)})

                local Fill = Create("Frame", {
                    Parent = SlidesBg,
                    BackgroundColor3 = Library.Theme.Accent,
                    Size = UDim2.new(0, 0, 1, 0),
                })
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

                local dragging = false
                local min, max = cfg.Min or 0, cfg.Max or 100
                local val = cfg.Default or min
                
                local function Set(v)
                    v = math.clamp(v, min, max)
                    val = v
                    Library.Flags[cfg.Flag or cfg.Name] = val
                    ValueLabel.Text = string.format("%d%s", math.floor(val), cfg.Suffix or "")
                    local p = (val - min) / (max - min)
                    TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(p, 0, 1, 0)}):Play()
                    if cfg.Callback then 
                        pcall(cfg.Callback, val)
                    end
                end

                SlidesBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local s = SlidesBg.AbsolutePosition.X
                        local e = s + SlidesBg.AbsoluteSize.X
                        local m = math.clamp(input.Position.X, s, e)
                        local p = (m - s) / (e - s)
                        Set(min + (p * (max - min)))
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                Set(val)
                
                return SliderFrame
            end

            function SectionAPI:Button(cfg)
                local ButtonContainer = Create("Frame", {
                    Name = generateRandomName("Btn"),
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40), 
                })
                
                local Label = Create("TextLabel", {
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Btn = Create("TextButton", {
                    Parent = ButtonContainer,
                    BackgroundColor3 = Library.Theme.CardInfo,
                    Position = UDim2.new(1, -5, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.new(0, 80, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "Interact",
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 12,
                    AutoButtonColor = true
                })
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Btn, Color = Library.Theme.Border, Thickness = 1})
                
                Btn.MouseButton1Click:Connect(function()
                     if cfg.Callback then 
                        pcall(cfg.Callback)
                    end
                end)
            end

            function SectionAPI:Keybind(cfg)
                local binding = cfg.Default
                local waiting = false
                
                local KeybindContainer = Create("Frame", {
                    Name = generateRandomName("KB"),
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    ZIndex = 5
                })
                
                local Label = Create("TextLabel", {
                    Parent = KeybindContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local btnText = "None"
                if binding then btnText = binding.Name end
                
                local Button = Create("TextButton", {
                    Parent = KeybindContainer,
                    BackgroundColor3 = Library.Theme.CardInfo,
                    Position = UDim2.new(1, -5, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.new(0, 80, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = btnText,
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Button, Color = Library.Theme.Border, Thickness = 1})
                
                Button.MouseButton1Click:Connect(function()
                    waiting = true
                    Button.Text = "..."
                    Button.TextColor3 = Library.Theme.Accent
                    
                    local con
                    con = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                             waiting = false
                             binding = input.KeyCode
                             if binding == Enum.KeyCode.Unknown then binding = input.UserInputType end
                             
                             Button.Text = binding.Name
                             Button.TextColor3 = Library.Theme.TextDark
                             
                             if cfg.Callback then pcall(cfg.Callback, binding) end
                             con:Disconnect()
                        end
                    end)
                end)
                
                function SectionAPI:SetKeybind(key)
                    binding = key
                    Button.Text = key.Name
                end
            end

            function SectionAPI:Dropdown(cfg)
                local isOpened = false
                local options = cfg.Options or {}
                local selected = cfg.Default or options[1] or "None"
            
                local DropdownContainer = Create("Frame", {
                    Name = generateRandomName("DD"),
                    Parent = Container, 
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40), 
                    ZIndex = 20
                })
            
                local Label = Create("TextLabel", {
                    Parent = DropdownContainer,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0), 
                    Font = Enum.Font.GothamMedium,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 20
                })
            
                local RightBox = Create("Frame", {
                    Parent = DropdownContainer,
                    BackgroundColor3 = Library.Theme.CardInfo, 
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -5, 0.5, 0), 
                    Size = UDim2.fromOffset(0, 24), 
                    AutomaticSize = Enum.AutomaticSize.X, 
                    ZIndex = 21
                })
                Create("UICorner", {Parent = RightBox, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = RightBox, Color = Library.Theme.Border, Thickness = 1})
                
                local RightContent = Create("Frame", {
                    Parent = RightBox,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(0, 1),
                    AutomaticSize = Enum.AutomaticSize.X
                })
                Create("UIPadding", {Parent = RightContent, PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)})
                Create("UIListLayout", {
                    Parent = RightContent, 
                    FillDirection = Enum.FillDirection.Horizontal, 
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 6)
                })
                
                local Input = Create("TextBox", {
                    Parent = RightContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(30, 24), 
                    AutomaticSize = Enum.AutomaticSize.X,
                    Font = Enum.Font.Gotham,
                    Text = selected,
                    PlaceholderText = "...",
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 22,
                    LayoutOrder = 1
                })
                
                local Arrow = Create("ImageLabel", {
                    Parent = RightContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(12, 12),
                    Image = "rbxassetid://10709790948",
                    ImageColor3 = Library.Theme.TextDark,
                    ZIndex = 22,
                    LayoutOrder = 2
                })
                
                local ToggleBtn = Create("TextButton", {
                    Parent = RightBox,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "",
                    ZIndex = 25
                })

                local ListOuter = Create("Frame", {
                    Parent = DropdownContainer, 
                    BackgroundColor3 = Library.Theme.CardInfo,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -5, 1, 5),
                    Size = UDim2.new(0, 0, 0, 0),
                    Visible = false,
                    ZIndex = 100,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = ListOuter, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = ListOuter, Color = Library.Theme.Border, Thickness = 1})
                
                local ListScroll = Create("ScrollingFrame", {
                    Parent = ListOuter,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    CanvasSize = UDim2.new(0,0,0,0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    ScrollingDirection = Enum.ScrollingDirection.Y
                })
                Create("UIListLayout", {Parent = ListScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

                local function Refresh(filter)
                    filter = filter and filter:lower() or ""
                    
                    for _, c in pairs(ListScroll:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    
                    local count = 0
                    local maxTextWidth = 0
                    
                    for _, opt in ipairs(options) do
                        if filter == "" or opt:lower():find(filter) then
                             local btn = Create("TextButton", {
                                 Parent = ListScroll,
                                 BackgroundTransparency = 1,
                                 Size = UDim2.new(1, 0, 0, 20),
                                 Font = Enum.Font.Gotham,
                                 Text = "  " .. opt,
                                 TextColor3 = (opt == selected) and Library.Theme.Accent or Library.Theme.Text,
                                 TextSize = 12,
                                 TextXAlignment = Enum.TextXAlignment.Left,
                                 AutoButtonColor = false,
                                 ZIndex = 102
                             })
                             
                             local bounds = TextService:GetTextSize("  " .. opt, 12, Enum.Font.Gotham, Vector2.new(1000, 20))
                             if bounds.X > maxTextWidth then maxTextWidth = bounds.X end
                             
                             btn.MouseButton1Click:Connect(function()
                                 selected = opt
                                 Input.Text = selected
                                 Input.TextColor3 = Library.Theme.Accent
                                 if cfg.Callback then pcall(cfg.Callback, selected) end
                                 
                                 isOpened = false
                                 ListOuter.Visible = false
                                 ToggleBtn.Visible = true
                                 TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                                 Input:ReleaseFocus()
                             end)
                             count = count + 1
                        end
                    end
                    
                    local headerWidth = RightBox.AbsoluteSize.X
                    local requiredWidth = math.max(headerWidth, maxTextWidth + 20)
                    ListOuter.Size = UDim2.fromOffset(requiredWidth, math.min(count * 22, 120) + 4)
                    
                    return count
                end
            
                local function Toggle()
                    isOpened = not isOpened
                    ListOuter.Visible = isOpened
                    ToggleBtn.Visible = not isOpened
                    
                    if isOpened then
                        Input.Text = "" 
                        Input.TextColor3 = Library.Theme.Text
                        Refresh("")
                        ListOuter.Position = UDim2.new(1, -5, 0, 35)
                        
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                        Input:CaptureFocus()
                    else
                        Input.Text = selected
                        Input.TextColor3 = Library.Theme.Accent
                        ListOuter.Size = UDim2.new(0, 0, 0, 0)
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    end
                end
                
                ToggleBtn.MouseButton1Click:Connect(Toggle)
                
                Input.Focused:Connect(function()
                     if not isOpened then Toggle() end
                end)
                
                Input.FocusLost:Connect(function(enter)
                    task.delay(0.1, function()
                        if isOpened then
                            Toggle()
                        end
                    end)
                end)
                
                Input:GetPropertyChangedSignal("Text"):Connect(function()
                    if isOpened then
                         Refresh(Input.Text)
                    end
                end)
            end

            return SectionAPI
        end

        return TabAPI
    end

    function WindowAPI:AddSidebarSection(name, fixedScrollHeight)
          local isFill = (fixedScrollHeight == "Fill")
          
          local SectionFrame = Create("Frame", {
                Name = generateRandomName("SS"),
                Parent = SidebarContent,
                BackgroundColor3 = Library.Theme.CardInfo,
                Position = UDim2.new(0,0,0,0), 
                Size = isFill and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 0),
                AutomaticSize = isFill and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
            })
            
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SectionFrame, Color = Library.Theme.Border, Thickness = 1})
            
             local Header = Create("Frame", {
                 Parent = SectionFrame,
                 BackgroundTransparency = 1,
                 Size = UDim2.new(1,0,0,30)
             })

             local Title = Create("TextLabel", {
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = name:upper(),
                TextColor3 = Library.Theme.Accent,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Container
            if isFill then
                 Container = Create("ScrollingFrame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 1, -35), 
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0
                })
            elseif fixedScrollHeight then
                Container = Create("ScrollingFrame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, fixedScrollHeight),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Library.Theme.Accent
                })
            else
                Container = Create("Frame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y
                })
            end
            
            Create("UIListLayout", {
                Parent = Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            Create("UIPadding", {Parent = SectionFrame, PaddingBottom = UDim.new(0, 10)})
            
            local SideAPI = {}
            
            function SideAPI:AddLog(text, color)
                 local TextSvc = game:GetService("TextService")
                 local fSize = 12
                 local fFont = Enum.Font.GothamMedium
                 local cardWidth = Container.AbsoluteSize.X - 10
                 if cardWidth <= 0 then cardWidth = 200 end
                 
                 local bounds = TextSvc:GetTextSize(text, fSize, fFont, Vector2.new(cardWidth, 9999))
                 
                 local LogContainer = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, bounds.Y + 4),
                 })
                 
                 local LogLbl = Create("TextButton", {
                    Parent = LogContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = fFont,
                    Text = text,
                    TextColor3 = color or Library.Theme.TextDark,
                    TextSize = fSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    RichText = true,
                    AutoButtonColor = false
                })
                
                LogLbl.MouseButton1Click:Connect(function()
                    pcall(function()
                        if setclipboard then
                            setclipboard(text)
                            local originalText = LogLbl.Text
                            local originalColor = LogLbl.TextColor3
                            LogLbl.Text = "[ COPIED ]"
                            LogLbl.TextColor3 = Library.Theme.Accent
                            task.wait(0.8)
                            if LogLbl and LogLbl.Parent then
                                LogLbl.Text = originalText
                                LogLbl.TextColor3 = originalColor
                            end
                        end
                    end)
                end)
                
                if Container:IsA("ScrollingFrame") then
                     task.spawn(function()
                         task.wait()
                         Container.CanvasPosition = Vector2.new(0, Container.AbsoluteCanvasSize.Y)
                     end)
                end
            end

            return SideAPI
    end

    Create("UIListLayout", {
        Parent = SidebarContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 15)
    })

    --// Toggle Logic - ANTI-DETECTION: Use random global key
    local globalKey = generateRandomName("_TC_")
    if getgenv()[globalKey] then
        if getgenv()[globalKey].Connected then
            getgenv()[globalKey]:Disconnect()
        end
        getgenv()[globalKey] = nil
    end

    Library.ToggleKey = options.ToggleKey or Enum.KeyCode.Insert
    
    local ToggleConnection
    ToggleConnection = UserInputService.InputBegan:Connect(function(input, gpe)
        if not ScreenGui or not ScreenGui:IsDescendantOf(game) then
             if ToggleConnection then ToggleConnection:Disconnect() end
             return
        end
        
        if gpe then return end
        
        local key = input.KeyCode
        if key == Enum.KeyCode.Unknown then
            key = input.UserInputType
        end
        
        if Library.ToggleKey and key == Library.ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    getgenv()[globalKey] = ToggleConnection
    
    function WindowAPI:Unload()
        if getgenv()[globalKey] then
            getgenv()[globalKey]:Disconnect()
            getgenv()[globalKey] = nil
        end
        ScreenGui:Destroy()
    end

    return WindowAPI
end

return Library
