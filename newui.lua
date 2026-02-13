local Library = loadstring(game:HttpGet('https://2e8240f4dc86.ngrok-free.app/newsource.luau'))();

Library:Loader({
    Name = "Sim1X",
    Duration = 3
})

local Window = Library:Window({
    Name = "Sim1X"
})

--// LEGIT TAB
local LegitTab = Window:Tab("Legit", "rbxassetid://10709752906") -- Target icon

local Primary = LegitTab:Section("Primary Controls")

Primary:Toggle({
    Name = "Toggle Master",
    Default = false,
    Callback = function(val)
        print("Master:", val)
    end
})

-- Emulating Color Picker with a placeholder or simple toggle for now as library is WIP
Primary:Dropdown({
    Name = "Cast Method",
    Options = {"New", "Old", "Raycast", "Mouse", "Camera"},
    Default = "New",
    Callback = function(val)
        print("Selected:", val)
    end
})

Primary:Slider({
    Name = "Visibility",
    Min = 0,
    Max = 100,
    Default = 20,
    Suffix = "%",
    Callback = function(val)
        print("Visibility:", val)
    end
})

local Advanced = LegitTab:Section("Advanced Options")

Advanced:Toggle({
    Name = "Enable Labels",
    Default = false,
    Callback = function() end
})

local ShadeSlider -- Forward declare

Advanced:Toggle({
    Name = "Text Shade",
    Default = false,
    Callback = function(val)
        if ShadeSlider then ShadeSlider.Visible = val end
    end
})

ShadeSlider = Advanced:Slider({
    Name = "Shade Transparency",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Callback = function(val)
        -- Update transparency logic here
    end
})
ShadeSlider.Visible = false -- Hide initially

Advanced:Toggle({
    Name = "Outline High",
    Default = false,
    Callback = function() end
})

--// RAGE TAB (Placeholder)
local RageTab = Window:Tab("Rage", "rbxassetid://10709761629") -- Angry icon
RageTab:Section("Aimbot"):Toggle({Name = "Enable Aimbot", Default = false})

--// VISUALS TAB
local VisualsTab = Window:Tab("Visuals", "rbxassetid://10723346959") -- Eye icon
VisualsTab:Section("ESP"):Toggle({Name = "Box ESP", Default = false})

--// ETC TAB
local EtcTab = Window:Tab("Etc", "rbxassetid://10734950309") -- Settings Icon
local Settings = EtcTab:Section("UI Settings")

Settings:Keybind({
    Name = "Menu Toggle",
    Default = Enum.KeyCode.Insert,
    Callback = function(key)
        Library.ToggleKey = key
    end
})

Settings:Button({
    Name = "Unload Script",
    Text = "Unload",
    Callback = function()
        Window:Unload()
    end
})

Settings:Button({
    Name = "Test Log Error",
    Text = "Error",
    Callback = function()
        warn("This is a test warning!")
        error("This is a TEST ERROR! Click me to copy!")
    end
})

--// SIDEBAR
local Output = Window:AddSidebarSection("Live Output", "Fill")

local LogService = game:GetService("LogService")

-- Function to convert console message type to color and format
local function OnMessageAdded(message, messageType)
    local color = Color3.fromRGB(240, 240, 240) -- Default White
    
    if messageType == Enum.MessageType.MessageOutput then
        color = Color3.fromRGB(200, 200, 200)
    elseif messageType == Enum.MessageType.MessageInfo then
        color = Color3.fromRGB(100, 160, 255) -- Blue-ish
    elseif messageType == Enum.MessageType.MessageWarning then
        color = Color3.fromRGB(255, 200, 80) -- Yellow/Orange
    elseif messageType == Enum.MessageType.MessageError then
        color = Color3.fromRGB(255, 120, 120) -- Lighter Red/Salmon for better readability
    end
    
    -- Format timestamp [HH:MM:SS]
    local timestamp = os.date("%H:%M:%S")
    local prefix = string.format("[%s] ", timestamp)
    
    -- Add to UI log
    Output:AddLog(prefix .. message, color)
end

-- Connect to existing logs (optional, but good for context)
for _, msg in pairs(LogService:GetLogHistory()) do
    OnMessageAdded(msg.message, msg.messageType)
end

-- Listen for new logs
LogService.MessageOut:Connect(OnMessageAdded)

print("UI Loaded!")
