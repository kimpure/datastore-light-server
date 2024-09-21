# DataStoreLight

## Install
wally.toml
```
datastore-light = "kimpure/datastore-light@^0.1.8"
```

## How To Use
```luau
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local datastorelight = require('./init') --// path (Instance)

Players.PlayerAdded:Connect(function(player)
    local newDataStore=datastorelight.new(player.UserId)
    print(newDataStore:get('___coin'))
    newDataStore:set('___coin' , 300)

    player.Destroying:Once(function()
        newDataStore:save()
    end)
end)
```
