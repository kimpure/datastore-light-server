local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local base91 = require(ReplicatedStorage:WaitForChild('base91'))
local rbxzstd = require(ReplicatedStorage:WaitForChild('rbxzstd'))
local msgpack = require(ReplicatedStorage:WaitForChild('msgpack-luau'))

local PlayerData1 = {}
local PlayerData2 = {}
local PlayerBeforeDataInServer = {}

local DataStoreLight = {}


--// DataTable
DataStoreLight.DataTable = {
    eee = 0;
}

--// Setting
DataStoreLight.Setting = {
    Debug = false;
}


--// DataStoreLight.Setting.Debug 가 true 일떄 파라미터들을 출력
function DataStoreLight:Debug(message , ...)
    if self.Setting.Debug then
        print(message , ...)
    end
end

--// 세션 회수가 초과했다면 기다림
function DataStoreLight:waitForRequest(requestType)
    local current = DataStoreService:GetRequestBudgetForRequestType(requestType)
	self:Debug(`남은 새션개수 : {current}`)
    while current < 1 do
        current = DataStoreService:GetRequestBudgetForRequestType(requestType)
        wait(1)
    end
end

--// Player 의 Data 를 DataStoreLight.DataTable 에 값에 있는 값들마다 로드
function DataStoreLight.Load(Player:Player)
    for k,v in DataStoreLight.DataTable do
        DataStoreLight:Debug(`DataName : {k} , Player User Id : {Player.UserId}`)
        
        PlayerData1[Player.UserId] = {}
        PlayerData2[Player.UserId] = {}
        PlayerBeforeDataInServer[Player.UserId] = {}

        DataStoreLight:waitForRequest(Enum.DataStoreRequestType.GetAsync)
        local K1 = DataStoreService:GetDataStore(`{k}:1`):GetAsync(Player.UserId)

        DataStoreLight:waitForRequest(Enum.DataStoreRequestType.GetAsync)
        local K2 = DataStoreService:GetDataStore(`{k}:2`):GetAsync(Player.UserId)

        
        if K1 then

           
            local _o = string.sub(K1 , 1 , 1)
            K1 = string.sub(K1 , 2)

            if _o == '\20' then
                DataStoreLight:Debug(`압축돼지 않은 데이터 : {K1}`)

                K1 = msgpack.decode(msgpack.utf8Decode(K1))
            else
                DataStoreLight:Debug(`압축돼어있는 데이터 : {K1}`)
                
                K1 = msgpack.decode(msgpack.utf8Decode(buffer.tostring(rbxzstd.decompress(base91.decodeString(K1)))))
            end

            PlayerData1[Player.UserId][k] = K1
        else

            PlayerData1[Player.UserId][k] = v
        end


        if K2 then


            local _o = string.sub(K2 , 1 , 1)
            K2 = string.sub(K2 , 2)

            if _o == '\20' then
                DataStoreLight:Debug(`압축돼지 않은 데이터 : {K2}`)

                K2 = msgpack.decode(msgpack.utf8Decode(K2))
            else
                DataStoreLight:Debug(`압축돼어있는 데이터 : {K2}`)

                K2 = msgpack.decode(msgpack.utf8Decode(buffer.tostring(rbxzstd.decompress(base91.decodeString(K2)))))
            end
            
            PlayerData2[Player.UserId][k] = K2
        end
    end
end

--// DataStoreLight 의 PlayerData 라는 저장돼어있는 테이블에서 Data 를 가져옴
function DataStoreLight.Get<T>(Player:Player , DataName:string) : {any}
    if PlayerData1[Player.UserId] then
        if PlayerData1[Player.UserId][DataName] ~= nil then
            return PlayerData1[Player.UserId][DataName] , PlayerData2[Player.UserId][DataName]
        end
    end
end

--// DataStoreLight 의 PlayerData 라는 저장돼는 테이블의 DataName 을 Value 의 값으로 변경
function DataStoreLight.Set<T>(Player:Player , DataName:string , Value:T)
    if PlayerData1[Player.UserId] then
        if PlayerData1[Player.UserId][DataName] ~= nil then
            PlayerBeforeDataInServer[Player.UserId][DataName] = PlayerData2[Player.UserId][DataName]
            PlayerData2[Player.UserId][DataName] = PlayerData1[Player.UserId][DataName]
            PlayerData1[Player.UserId][DataName] = Value
        end
    end
end

--// DataStoreLight.DataTable 에 있는 Data 들을 하나하나 모두 저장
function DataStoreLight.Save(Player:Player)
    for k,v in DataStoreLight.DataTable do
        
        local Data1 = PlayerData1[Player.UserId][k]
        local Data2 = PlayerData2[Player.UserId][k]
        DataStoreLight:Debug(Data1 , Data2)

        if Data1 ~= nil then
            DataStoreLight:Debug(`Save for {Data1} ...`)

            local Buffer_Data1 = msgpack.utf8Encode(msgpack.encode(Data1))
            local Compress_Data1 = rbxzstd.compress(buffer.fromstring(Buffer_Data1))
            


            DataStoreLight:Debug(`Data1 : {Compress_Data1}`)
            
            if Compress_Data1 then
                DataStoreLight:Debug(`압축한 데이터 저장중 : {Data1} ...`)
                
                DataStoreLight:waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync)
                
                DataStoreService:GetDataStore(`{k}:1`):SetAsync(Player.UserId , `\30{base91.encodeString(Compress_Data1)}`)
            else
                DataStoreLight:Debug(`압축하지 못한 데이터 저장중 : {Data1} ...`)
                
                DataStoreLight:waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync)
                
                DataStoreService:GetDataStore(`{k}:1`):SetAsync(Player.UserId , `\20{Buffer_Data1}`)
            end
        end

        if Data2 ~= nil then
            DataStoreLight:Debug(`Save for {Data2} ...`)

            local Buffer_Data2 = msgpack.utf8Encode(msgpack.encode(Data2))
            local Compress_Data2 = rbxzstd.compress(buffer.fromstring(Buffer_Data2))
            
            if Compress_Data2 then
                DataStoreLight:Debug(`압축한 데이터 저장중 : {Data2} ...`)
                
                DataStoreLight:waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync)
                
                DataStoreService:GetDataStore(`{k}:2`):SetAsync(Player.UserId , `\30{base91.encodeString(Compress_Data2)}`)
            else
                DataStoreLight:Debug(`압축하지 못한 데이터 저장중 : {Data2} ...`)
                
                DataStoreLight:waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync)
                
                DataStoreService:GetDataStore(`{k}:2`):SetAsync(Player.UserId , `\20{Buffer_Data2}`)
            end
        end
    end
end

--// DataName 파라미터가 존제한다면 그 데이터를 초기값으로 만약 존제하지 않는다면 모든 데이터를 초기값으로
function DataStoreLight.ClearData(Player:Player , DataName:string)
    if DataName then
        if DataStoreLight.DataTable[DataName] then
            if PlayerData1[Player.UserId] then
                if PlayerData1[Player.UserId][DataName] ~= nil then
                    DataStoreLight.Set(Player , DataName , DataStoreLight.DataTable[DataName])
                    DataStoreLight.Set(Player , DataName , DataStoreLight.DataTable[DataName])
                end
            end
        end
    else
        for k,v in DataStoreLight.DataTable do
            if PlayerData1[Player.UserId] then
                if PlayerData1[Player.UserId][k] ~= nil then
                    DataStoreLight.Set(Player , k , v)
                    DataStoreLight.Set(Player , k , v)
                end
            end
        end
    end
end

--// DataName 파라미터가 존제하면 그 값만 이전값으로 변경 없다면 모든값을 이전값으로 변경
function DataStoreLight.DiscardChanges(Player:Player , DataName:string)
    if DataName then
        if DataStoreLight.DataTable[DataName] then
            if PlayerData1[Player.UserId] then
                if PlayerData1[Player.UserId][DataName] ~= nil then
                    PlayerData1[Player.UserId][DataName] = PlayerData2[Player.UserId][DataName]
                    PlayerData2[Player.UserId][DataName] = PlayerBeforeDataInServer[Player.UserId][DataName]
                end
            end
        end
    else
        for k,_ in DataStoreLight.DataTable do
            if PlayerData1[Player.UserId] then
                if PlayerData1[Player.UserId][k] ~= nil then
                    PlayerData1[Player.UserId][k] = PlayerData2[Player.UserId][k]
                    PlayerData2[Player.UserId][k] = PlayerBeforeDataInServer[Player.UserId][k]
                end
            end
        end
    end
end

return DataStoreLight