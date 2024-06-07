# DataStoreLight is very very light DataModule!

데이터스토어라이트는 데이터를 저장할때 버퍼로 변환을 하고 그 변환한 데이터를 압축까지 하여 저장하기에 저장 속도 , 로드 속도가 빠른 장점이 있습니다!

# How To Use?

```lua
local DataStoreLight = require(path to)
```

Load
```lua
DataStoreLight:Load(Player:Player)
```

Save
```lua
DataStoreLight:Save(Player:Player)
```

Get
```lua
DataStoreLight:Get(Player:Player , DataName:string) : any
```

Set
```lua
DataStoreLight:Set<T>(Player:Player , DataName:string , Value:T)
```