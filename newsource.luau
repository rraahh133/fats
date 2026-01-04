local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.Flags = {}
Library.Theme = {
    Background = Color3.fromRGB(10, 10, 15),
    CardInfo = Color3.fromRGB(15, 15, 21),
    Accent = Color3.fromRGB(59, 130, 246), -- #3b82f6
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
    
    -- 1. Setup Blur
    local Lighting = game:GetService("Lighting")
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = Lighting
    
    TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 24}):Play()
    
    -- 2. Setup Gui
    local LoaderGui = Create("ScreenGui", {
        Name = "Loader",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true -- Covers topbar
    })
    
    local Background = Create("Frame", {
        Parent = LoaderGui,
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 1, -- Start transparent
        Size = UDim2.fromScale(1, 1),
        ZIndex = 0
    })
    
    local CenterText = Create("TextLabel", {
        Parent = LoaderGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 0.2), -- Wide container
        Font = Enum.Font.GothamBlack,
        Text = "", -- Start empty for typewriter
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 64, -- Large text
    })
    
    -- 3. Gradient for Text
    local Gradient = Create("UIGradient", {
        Parent = CenterText,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 255)) -- Lighter/Different shade
        }),
        Rotation = 45
    })
    
    -- Typewriter Effect
    TweenService:Create(Background, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    task.wait(0.5)
    
    for i = 1, #Name do
        CenterText.Text = Name:sub(1, i)
        -- Small random delay for realistic typing
        task.wait(math.random(5, 15) / 100) 
    end
    
    -- Wait for duration
    task.wait(Duration)
    
    -- 4. Fade Out
    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Blur, fadeInfo, {Size = 0}):Play()
    TweenService:Create(Background, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(CenterText, fadeInfo, {TextTransparency = 1}):Play()
    
    task.wait(0.8)
    
    LoaderGui:Destroy()
    Blur:Destroy()
end

function Library:Window(options)
    local ScreenGui = Create("ScreenGui", {
        Name = "Sim1X",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
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
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(12, 12, 18),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
    })
    
    local Logo = Create("TextLabel", {
        Name = "Logo",
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
    
    Create("Frame", { -- Accent square next to logo
        Parent = Logo,
        BackgroundColor3 = Library.Theme.Accent,
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, -15, 0.5, -4),
    })

    local TabContainer = Create("Frame", {
        Name = "Tabs",
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

    -- Update Game Name asynchronously
    task.spawn(function()
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

    --// Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 80),
        Size = UDim2.new(1, -40, 1, -110), -- Keeping space for footer
    })
    
    -- Split Content: Main (Left) and Sidebar (Right)
    local MainContent = Create("ScrollingFrame", {
        Name = "MainContent",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, -10, 1, 0),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0,0,0,0), -- Auto
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local SidebarContent = Create("Frame", {
        Name = "Sidebar",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 10, 0, 0),
        Size = UDim2.new(0.3, -10, 1, 0),
    })

    --// Footer
    local Footer = Create("Frame", {
        Name = "Footer",
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
    
    -- Stats Updater
    task.spawn(function()
        local RunService = game:GetService("RunService")
        local Stats = game:GetService("Stats")
        
        local lastTime = tick()
        local frames = 0
        
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
        end)
        
        while true do
            task.wait(1)
            local currentTime = tick()
            local fps = math.round(frames / (currentTime - lastTime))
            frames = 0
            lastTime = currentTime
            
            local pingStr = "0 ms"
            pcall(function()
                pingStr = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
            end)
            -- pingStr usually looks like "50.12 ms", let's clean it up slightly if needed or just use it
            -- Let's extract just the number
            local pingVal = pingStr:match("^(%d+)") or "0"
            
            StatsLabel.Text = string.format("FPS: %d   PING: %s ms", fps, pingVal)
        end
    end)

    --// Logic
    local WindowAPI = {}
    local Tabs = {}
    local CurrentTab = nil

    --// Input Handling (Toggle)
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.Insert then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    function WindowAPI:Tab(name, icon)
        local TabButton = Create("TextButton", {
            Name = name,
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 90, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = name:upper(),
            TextColor3 = Library.Theme.TextDark,
            TextSize = 11,
        })
        
        -- Tab Icon
        local Ico = Create("ImageLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -10, 0.2, 0),
            Size = UDim2.fromOffset(20, 20),
            Image = icon or "rbxassetid://10709762497", -- Box/Cube default
            ImageColor3 = Library.Theme.TextDark
        })
        TabButton.Text = "\n\n" .. name:upper() -- Push text down
        
        -- Active Indicator/Glow
        local Indicator = Create("Frame", {
            Parent = TabButton,
            BackgroundColor3 = Library.Theme.Accent,
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0,0,1,-2),
            BackgroundTransparency = 1
        })

        local TabPage = Create("Frame", {
            Name = name .. "_Page",
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
                
                -- Tween out?
            end
            
            TabButton.TextColor3 = Library.Theme.Text
            Ico.ImageColor3 = Library.Theme.Text
            Indicator.BackgroundTransparency = 0
            TabPage.Visible = true
            
            CurrentTab = {Button = TabButton, Icon = Ico, Indicator = Indicator, Page = TabPage}
        end

        TabButton.MouseButton1Click:Connect(Activate)
        
        if #Tabs == 0 then Activate() end -- Select first tab by default
        table.insert(Tabs, {Button = TabButton, Icon = Ico, Indicator = Indicator, Page = TabPage})

        local TabAPI = {}

        function TabAPI:Section(title)
            local SectionFrame = Create("Frame", {
                Name = "Section",
                Parent = TabPage,
                BackgroundColor3 = Library.Theme.CardInfo,
                Size = UDim2.new(1, 0, 0, 0), -- Auto scaled
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SectionFrame, Color = Library.Theme.Border, Thickness = 1})
            
            -- Section Title
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
            
            -- Accent line in title
            -- Actually the text has a | prefix, maybe style that blue?
            -- We can emulate it with RichText or a separate frame.
            
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
            
            -- Add padding at bottom
            Create("UIPadding", {Parent = SectionFrame, PaddingBottom = UDim.new(0, 15)})

            local SectionAPI = {}

            function SectionAPI:Toggle(cfg)
                local ToggleFrame = Create("Frame", {
                    Name = "Toggle",
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
                    if cfg.Callback then cfg.Callback(state) end
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
                    Name = "Slider",
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
                    Name = "SlidesBg",
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
                    if cfg.Callback then cfg.Callback(val) end
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
            end

            return SectionAPI
        end

        return TabAPI
    end

    function WindowAPI:AddSidebarSection(name, fixedScrollHeight)
          local isFill = (fixedScrollHeight == "Fill")
          
          local SectionFrame = Create("Frame", {
                Name = "SidebarSection",
                Parent = SidebarContent,
                BackgroundColor3 = Library.Theme.CardInfo,
                Position = UDim2.new(0,0,0,0), 
                Size = isFill and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 0), -- Fill or Auto
                AutomaticSize = isFill and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
            })
            
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SectionFrame, Color = Library.Theme.Border, Thickness = 1})
            
             -- Header area
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
                    ScrollBarThickness = 3, -- Make thicker to see
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
            
             -- Add padding at bottom
            Create("UIPadding", {Parent = SectionFrame, PaddingBottom = UDim.new(0, 10)})
            
            -- Sidebar API
            local SideAPI = {}
            
            function SideAPI:AddScriptCard(title, author, status, callback)
                local Card = Create("Frame", {
                    Name = "ScriptCard",
                    Parent = Container,
                    BackgroundColor3 = Library.Theme.Background,
                    Size = UDim2.new(1, 0, 0, 80)
                })
                Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0, 6)})
                
                Create("TextLabel", { -- Title
                    Parent = Card,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                Create("TextLabel", { -- Author
                    Parent = Card,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 25),
                    Size = UDim2.new(1, -20, 0, 15),
                    Font = Enum.Font.Gotham,
                    Text = "By " .. author,
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local StatusBadge = Create("TextLabel", {
                    Parent = Card,
                    BackgroundColor3 = Library.Theme.CardInfo,
                    Position = UDim2.new(1, -50, 0, 10),
                    Size = UDim2.fromOffset(40, 15),
                    Font = Enum.Font.GothamBold,
                    Text = status,
                    TextColor3 = (status == "READY" and Library.Theme.TextDark) or Library.Theme.Success,
                    TextSize = 9,
                })
                Create("UICorner", {Parent = StatusBadge, CornerRadius = UDim.new(0, 4)})
                
                local ExecBtn = Create("TextButton", {
                    Parent = Card,
                    BackgroundColor3 = Library.Theme.CardInfo, -- Darker btn
                    Position = UDim2.new(0, 10, 1, -30),
                    Size = UDim2.new(1, -20, 0, 25),
                    Font = Enum.Font.GothamBold,
                    Text = "EXECUTE",
                    TextColor3 = Library.Theme.Accent, -- Blue text
                    TextSize = 11,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = ExecBtn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = ExecBtn, Color = Library.Theme.Border, Thickness = 1})
                
                ExecBtn.MouseButton1Click:Connect(callback)
            end
            
            function SideAPI:AddLog(text, color)
                 -- Explicit Height Calculation to fix overlapping
                 local TextSvc = game:GetService("TextService")
                 local fSize = 12
                 local fFont = Enum.Font.GothamMedium
                 local cardWidth = Container.AbsoluteSize.X - 10 -- Approximate width
                 if cardWidth <= 0 then cardWidth = 200 end -- Fallback
                 
                 local bounds = TextSvc:GetTextSize(text, fSize, fFont, Vector2.new(cardWidth, 9999))
                 
                 local LogContainer = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1, -- Alternating backgrounds could be added here
                    Size = UDim2.new(1, 0, 0, bounds.Y + 4),
                 })
                 
                 local LogLbl = Create("TextLabel", {
                    Parent = LogContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = fFont,
                    Text = text,
                    TextColor3 = color or Library.Theme.TextDark,
                    TextSize = fSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    RichText = true
                })
            end

            return SideAPI
    end

    -- Setup Layout for sidebar
    Create("UIListLayout", {
        Parent = SidebarContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 15)
    })

    return WindowAPI
end

return Library
