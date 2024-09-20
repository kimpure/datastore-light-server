# DataStoreLight

## Install
wally.toml
```
datastore-light = "kimpure/datastore-light@0.1.3"
```

## How To Use
```luau
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local datastorelight = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('datastore-light'))
Players.PlayerAdded:Connect(function(player)
    local newDataStore=datastorelight.new(player.UserId)
    print(newDataStore:get('___coin'))
    newDataStore:set('___coin' , 300)

    Players.PlayerRemoving:Connect(function(_player)
        newDataStore:save()
    end)
end)
```
