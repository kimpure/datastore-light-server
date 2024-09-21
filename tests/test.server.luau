--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local datastorelight = require('./init') --// path (Instance)
local data = {} :: { [Player]: datastorelight.DataStoreLight }

Players.PlayerAdded:Connect(function(player)
    local newDataStore=datastorelight.new(player.UserId)
    print(newDataStore:get('___coin'))
    newDataStore:set('___coin' , 300)
    data[player] = newDataStore
end)

Players.PlayerRemoving:Connect(function(player)
    data[player]:save()
    data[player] = nil
end)