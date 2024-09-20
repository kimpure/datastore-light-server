--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local datastorelight = (require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('datastore-light')) :: any)('../init.luau')
Players.PlayerAdded:Connect(function(player)
    local newDataStore=datastorelight.new(player.UserId)
    print(newDataStore:get('___coin'))
    newDataStore:set('___coin' , 300)

    Players.PlayerRemoving:Connect(function(_player)
        newDataStore:save()
    end)
end)