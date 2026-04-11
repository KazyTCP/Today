-- Complete Rewritten Code for 'Watch Number Go Up' Roblox Game --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local currentPlayer = Players.LocalPlayer
local numberDisplay = workspace.NumberDisplay -- Assuming there's a part named NumberDisplay in the workspace
local incrementButton = script.Parent.IncrementButton -- Assuming the button is a child of this script

local currentNumber = 0

-- Function to increment and update the display
local function incrementNumber()
    currentNumber = currentNumber + 1
    numberDisplay.Text = tostring(currentNumber)
end

-- Connect the button click event to the increment function
incrementButton.MouseButton1Click:Connect(incrementNumber)

-- Initialize display
numberDisplay.Text = tostring(currentNumber)