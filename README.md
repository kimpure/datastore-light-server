# DataStoreLight is very very light DataModule!

데이터스토어라이트는 데이터를 저장할때 버퍼로 변환을 하고 그 변환한 데이터를 압축까지 하여 저장하기에 저장 속도 , 로드 속도가 빠른 장점이 있습니다!

가장 최근 업데이트 : Client 컴프레스


# How To Use?

```lua
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


```

.new
```lua
newDataStore=datastorelight.new(player)
```

Save
```lua
newDataStore:save()
```

Get
```lua
 print(newDataStore:get('___coin'))
```

Set
```lua
newDataStore:set('___coin' , 800)
```