--!strict
local Players = game:GetService("Players")
local datastorelight = require(script.Parent)
Players.PlayerAdded:Connect(function(player)
    local newDataStore=datastorelight.new(player)
    print(newDataStore:get('___coin'))
    newDataStore:set('___coin' , 800)

    Players.PlayerRemoving:Connect(function(_player)
        newDataStore:save()
    end)
end)

