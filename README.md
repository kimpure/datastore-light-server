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
local data = {} :: { [Player]: datastorelight.DataStoreLight }

Players.PlayerAdded:Connect(function(player)
    local newDataStore=datastorelight.new(player.UserId)
    print(newDataStore:get('___coin'))
    newDataStore:set('___coin' , 300)
    data[player] = newDataStore
end)

Players.PlayerRemoving:Connect(function(player)
    data[player]:save()
end)
```
