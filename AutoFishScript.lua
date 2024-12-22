
--[[ 
    Optimized AutoFish Script with Enhanced GUI
    Original By: QUQ HUB
    GUI Theme: Red and Black
]]

local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

-- Function to Equip Item
local function equipItem(itemName)
    if LocalPlayer.Backpack:FindFirstChild(itemName) then
        local tool = LocalPlayer.Backpack:FindFirstChild(itemName)
        pcall(function()
            Humanoid:EquipTool(tool)
        end)
    else
        print("Item not found in Backpack:", itemName)
    end
end

-- ตัวแปรสำหรับเก็บตำแหน่ง Safe Point
local safePoint = nil

-- สร้างฟังก์ชันสำหรับการตั้ง Safe Point ใหม่ (บันทึกตำแหน่งปัจจุบัน)
local function setSafePoint()
    safePoint = Char.HumanoidRootPart.Position  -- เก็บตำแหน่งปัจจุบัน
    -- ให้ตัวละครหันหน้าไปทางตรงทันที
    Char:SetPrimaryPartCFrame(CFrame.new(safePoint, safePoint + Char.HumanoidRootPart.CFrame.LookVector))
    print("Safe Point set at:", safePoint)
end

-- สร้างฟังก์ชันสำหรับการรีเซ็ต Safe Point (รีเซ็ตตำแหน่งที่เคยเซฟและตั้งค่าตำแหน่งใหม่)
local function resetSafePoint()
    if safePoint then
        safePoint = Char.HumanoidRootPart.Position  -- รีเซ็ตตำแหน่งเดิมและตั้งค่าใหม่
        -- ให้ตัวละครหันหน้าไปทางตรงทันที
        Char:SetPrimaryPartCFrame(CFrame.new(safePoint, safePoint + Char.HumanoidRootPart.CFrame.LookVector))
        print("Safe Point reset and set to new position at:", safePoint)
    else
        print("No Safe Point set to reset. Setting new Safe Point...")
        setSafePoint()  -- หากไม่มี Safe Point ที่เซฟไว้ จะทำการเซฟใหม่
    end
end

-- Load GUI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("AutoFish Script", "BloodTheme") -- Red and Black Theme

-- Main Tab
local MainTab = Window:NewTab("Main")
local Section = MainTab:NewSection("Auto Farm Fish")

-- เพิ่มปุ่มใน GUI สำหรับการตั้ง Safe Point
local safePointSection = MainTab:NewSection("Safe Point")
safePointSection:NewButton("Set Safe Point", "Set your current position as a Safe Point", function()
    setSafePoint()
end)

-- เพิ่มปุ่มสำหรับการรีเซ็ต Safe Point
safePointSection:NewButton("Reset Safe Point", "Reset your Safe Point to a new position", function()
    resetSafePoint()
end)

-- Auto farm Fish Toggle
Section:NewToggle("Auto farm Fish", "Start or stop Auto farming for fish.", function(enabled)
    _G.AutoCast = enabled
    _G.AutoShake = enabled
    _G.AutoReel = enabled
    if enabled then
        equipItem("FishingRod") -- Equip Fishing Rod
        
        -- ถ้ามี Safe Point ให้เดินไปที่ตำแหน่งนั้น
        if safePoint then
            Char:SetPrimaryPartCFrame(CFrame.new(safePoint))
            print("Warping to Safe Point...")
        else
            print("No Safe Point set.")
        end

        -- Auto Cast
        spawn(function()
            while _G.AutoCast do
                task.wait(0.1)
                local rod = Char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChild("FishingRod")
                if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
                    rod.events.cast:FireServer(100, 1)
                end
            end
        end)

        -- Auto Shake
        spawn(function()
            while _G.AutoShake do
                task.wait(_G.AutoShakeTime or 0.1)  -- Adjust the wait time based on the slider value
                local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
                if playerGui then
                    local shakeUI = playerGui:FindFirstChild("shakeui")
                    if shakeUI and shakeUI.Enabled then
                        local safeZone = shakeUI:FindFirstChild("safezone")
                        if safeZone then
                            local button = safeZone:FindFirstChild("button")
                            if button and button:IsA("ImageButton") and button.Visible then
                                GuiService.SelectedObject = button
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            end
                        end
                    end
                end
            end
        end)

        -- Auto Reel
        spawn(function()
            while _G.AutoReel do
                task.wait(0.1)
                for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name == "reel" then
                        local bar = gui:FindFirstChild("bar")
                        if bar then
                            task.wait(0.15)
                            ReplicatedStorage.events.reelfinished:FireServer(100, true)
                        end
                    end
                end
            end
        end)
    else
        print("Auto Farm Fish is deactivated")
    end
end)

-- Slider for adjusting AutoShake Time
local shakeTimeLabel = Section:NewLabel("AutoShake Time: 0.1") -- Label to display the current AutoShake time
Section:NewSlider("AutoShake Time", "Adjust the AutoShake speed. Lower values mean faster shakes.", 1, 0.1, function(value)
    _G.AutoShakeTime = value
    shakeTimeLabel:Set("AutoShake Time: " .. string.format("%.1f", value))  -- Update the label text with the current value
end)

-- Backup Functions
Section:NewToggle("Backup Auto Cast", "Backup AutoCast function.", function(enabled)
    if enabled then
        equipItem("FishingRod")
        spawn(function()
            while enabled do
                task.wait(0.1)
                local rod = Char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChild("FishingRod")
                if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
                    rod.events.cast:FireServer(100, 1)
                end
            end
        end)
    else
        print("Backup AutoCast is deactivated")
    end
end)

Section:NewToggle("Backup Auto Shake", "Backup AutoShake function.", function(enabled)
    if enabled then
        equipItem("FishingRod")
        spawn(function()
            while enabled do
                task.wait(_G.AutoShakeTime or 0.1)  -- Use the AutoShakeTime from the slider
                local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
                if playerGui then
                    local shakeUI = playerGui:FindFirstChild("shakeui")
                    if shakeUI and shakeUI.Enabled then
                        local safeZone = shakeUI:FindFirstChild("safezone")
                        if safeZone then
                            local button = safeZone:FindFirstChild("button")
                            if button and button:IsA("ImageButton") and button.Visible then
                                GuiService.SelectedObject = button
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            end
                        end
                    end
                end
            end
        end)
    else
        print("Backup AutoShake is deactivated")
    end
end)

Section:NewToggle("Backup Auto Reel", "Backup AutoReel function.", function(enabled)
    if enabled then
        equipItem("FishingRod")
        spawn(function()
            while enabled do
                task.wait(0.1)
                for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name == "reel" then
                        local bar = gui:FindFirstChild("bar")
                        if bar then
                            task.wait(0.15)
                            ReplicatedStorage.events.reelfinished:FireServer(100, true)
                        end
                    end
                end
            end
        end)
    else
        print("Backup AutoReel is deactivated")
    end
end)

-- Credits Section
local CreditsTab = Window:NewTab("Credits")
local CreditsSection = CreditsTab:NewSection("Developed By Nes")
CreditsSection:NewLabel("Theme: Red & Black")
CreditsSection:NewLabel("Library: Kavo UI Library")

-- Keybind for Opening/Closing the Script (Ctrl by default)
local scriptEnabled = true  -- Flag to control whether the script is enabled or not
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    -- Define the key to open/close the script (Ctrl as default)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
        scriptEnabled = not scriptEnabled
        if scriptEnabled then
            Window:Toggle()  -- Open the script window
        else
            Window:Close()  -- Close the script window
        end
    end
end)
