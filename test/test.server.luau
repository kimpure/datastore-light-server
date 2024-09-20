--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local datastorelight = ReplicatedStorage:WaitForChild('Packages')
Players.PlayerAdded:Connect(function(player)
    local newDataStore=datastorelight.new(player)
    print(newDataStore:get('___coin'))
    newDataStore:set('___coin' , 300)

    Players.PlayerRemoving:Connect(function(_player)
        newDataStore:save()
    end)
end)