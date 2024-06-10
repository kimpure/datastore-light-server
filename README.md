# DataStoreLight is very very light DataModule!

데이터스토어라이트는 데이터를 저장할때 버퍼로 변환을 하고 그 변환한 데이터를 압축까지 하여 저장하기에 저장 속도 , 로드 속도가 빠른 장점이 있습니다!

가장 최근 업데이트 : Client 컴프레스


# How To Use?

```lua
local Players = game:GetService("Players")
local DataStoreLight = require(script.Parent:WaitForChild('DataStoreLight'))
Players.PlayerAdded:Connect(function(player)
    DataStoreLight.Load(player)
    print(DataStoreLight.Get(player , 'eee'))
    local th = {}
	for i=1 , 50 do
		th[i] = {'arr 인대 string 으로 데이터를 뿔리기'}
	end
    DataStoreLight.Set(player , 'eee' , th)
    print(DataStoreLight.Get(player , 'eee'))
    DataStoreLight.DiscardChanges(player)
    print(DataStoreLight.Get(player , 'eee'))
    DataStoreLight.Save(player)
end)
```

Load
```lua
DataStoreLight.Load(Player:Player)
```

Save
```lua
DataStoreLight.Save(Player:Player)
```

Get
```lua
DataStoreLight.Get(Player:Player , DataName:string) : any
```

Set
```lua
DataStoreLight.Set<T>(Player:Player , DataName:string , Value:T)
```

ClearData
```lua
--// DataName 이 없다면 모든값을 초기화
DataStoreLight.ClearData(Player:Player , DataName:string)
```

DiscardChanges
```lua
--// DataName 이 없다면 모든값을 이전으로
DataStoreLight.DiscardChanges(Player:Player , DataName:string)
```