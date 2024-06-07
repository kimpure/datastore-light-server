local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local base91 = require(ReplicatedStorage:WaitForChild('base91'))
local rbxzstd = require(ReplicatedStorage:WaitForChild('rbxzstd'))
local msgpack = require(ReplicatedStorage:WaitForChild('msgpack-luau'))

local PlayerData1 = {}
local PlayerData2 = {}

local DataStoreLight = {}
DataStoreLight.__index = DataStoreLight

--//Setting
DataStoreLight.DataTable = {
    qweqtetqe = 0;
}

DataStoreLight.Setting = {
    Debug = false;
}


--// Debug
function DataStoreLight:Debug(message , ...)
    if self.Setting.Debug then
        print(message , ...)
    end
end

function DataStoreLight:waitForRequest(requestType)
    local current = DataStoreService:GetRequestBudgetForRequestType(requestType)
	self:Debug(`남은 새션개수 : {current}`)
    while current < 1 do
        current = DataStoreService:GetRequestBudgetForRequestType(requestType)
        wait(1)
    end
end

function DataStoreLight.Load(Player:Player)
    for k,v in DataStoreLight.DataTable do
        DataStoreLight:Debug(`DataName : {k} , Player User Id : {Player.UserId}`)

        DataStoreLight:waitForRequest(Enum.DataStoreRequestType.GetAsync)
        
        PlayerData1[Player.UserId] = {}
        PlayerData2[Player.UserId] = {}

        local K1 = DataStoreService:GetDataStore(`{k}:1`):GetAsync(Player.UserId)
        local K2 = DataStoreService:GetDataStore(`{k}:2`):GetAsync(Player.UserId)

        if K1 then
            --// 버퍼화 해제 (K1)

           
            local _o = string.sub(K1 , 1 , 1)
            K1 = string.sub(K1 , 2)

            if _o == '' then
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
            --// 버퍼화 해제 (K2)


            local _o = string.sub(K2 , 1 , 1)
            K2 = string.sub(K2 , 2)

            if _o == '' then
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

function DataStoreLight.Get(Player:Player , DataName:string) : {any}
    if PlayerData1[Player.UserId] then
        if PlayerData1[Player.UserId][DataName] then
            return PlayerData1[Player.UserId][DataName] , PlayerData2[Player.UserId][DataName]
        end
    end
end

function DataStoreLight.Set<T>(Player:Player , DataName:string , Value:T)
    if PlayerData1[Player.UserId] then
        if PlayerData1[Player.UserId][DataName] then
            PlayerData2[Player.UserId][DataName] = PlayerData1[Player.UserId][DataName]
            PlayerData1[Player.UserId][DataName] = Value
        end
    end
end

function DataStoreLight.Save(Player:Player)
    for k,v in DataStoreLight.DataTable do
        
        local Data1 = PlayerData1[Player.UserId][k]
        local Data2 = PlayerData2[Player.UserId][k]
        DataStoreLight:Debug(Data1 , Data2)

        if Data1 then
            DataStoreLight:Debug(`Save for {Data1} ...`)

            local Buffer_Data1 = msgpack.utf8Encode(msgpack.encode(Data1))
            local Compress_Data1 = rbxzstd.compress(buffer.fromstring(Buffer_Data1))
            
            DataStoreLight:Debug(`Data1 : {Compress_Data1}`)
            
            if Compress_Data1 then
                DataStoreLight:Debug(`압축한 데이터 저장중 : {Data1} ...`)
                
                DataStoreLight:waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync)
                
                DataStoreService:GetDataStore(`{k}:1`):SetAsync(Player.UserId , `\30 {base91.encodeString(Compress_Data1)}`)
            else
                DataStoreLight:Debug(`압축하지 못한 데이터 저장중 : {Data1} ...`)
                
                DataStoreLight:waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync)
                
                DataStoreService:GetDataStore(`{k}:1`):SetAsync(Player.UserId , `\20{Buffer_Data1}`)
            end
        end

        if Data2 then
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


return DataStoreLight