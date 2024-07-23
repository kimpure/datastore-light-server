--!strict

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild('Packages')
local msgpack = require(Packages:WaitForChild('msgpack-luau'))
local rbxzstd = require(Packages:WaitForChild('rbxzstd'))
local base91 = require(Packages:WaitForChild('base91'))
local dataTable = require(script.Parent:WaitForChild("DATATABLE"))
local playerDataTable = {} :: {
    [number]: {
        [string]:{
            [number]: any
        }
    }
}

local dataStoreLight = {}

function waitForRequest(requestType:Enum.DataStoreRequestType , currentNum:number)
    local current = DataStoreService:GetRequestBudgetForRequestType(requestType)
    while current < currentNum do
        current = DataStoreService:GetRequestBudgetForRequestType(requestType)
        task.wait(1 * currentNum)
    end
end

function unPack(data:any): string
    return if (string.sub(data , 1 , 1) == '\30') then
        msgpack.decode(msgpack.utf8Decode(string.sub(data , 2)))
    else
        msgpack.decode(msgpack.utf8Decode(buffer.tostring(rbxzstd.decompress(base91.decodeString(string.sub(data , 2))))))
end

function pack(data:any): string
    return if rbxzstd.compress(buffer.fromstring(msgpack.utf8Encode(msgpack.encode(data)))) then
            '\20'..base91.encodeString(tostring(rbxzstd.compress(buffer.fromstring(msgpack.utf8Encode(msgpack.encode(data))))))
        else
            '\30'..msgpack.utf8Encode(msgpack.encode(data))
end

function dataStoreLight.init(player:Player)
    playerDataTable[player.UserId] = {}
    for k,v in dataTable do
        for i=1, 2 do
            waitForRequest(Enum.DataStoreRequestType.GetAsync , 2)
            playerDataTable[player.UserId][tostring(k)][i] = (if (DataStoreService:GetDataStore(`{k}:{i}`):GetAsync(player.UserId)) then
                DataStoreService:GetDataStore(`{k}:{i}`):GetAsync(player.UserId)
            else
                pack(v)
            )
        end
    end
end

function dataStoreLight.get(player:Player , dataName:string)
    return if (playerDataTable[player.UserId][dataName]) then
        table.unpack({ unPack(if (playerDataTable[player.UserId][dataName][1]) then 
            playerDataTable[player.UserId][dataName][1]
        else
            pack(dataTable[dataName])
        ) ,  unPack(if (playerDataTable[player.UserId][dataName][2]) then 
            playerDataTable[player.UserId][dataName][2]
        else
            nil
        ) })
    else
        error('this not Exist Data')
end

function dataStoreLight.set(player:Player , dataname:string , value:any)
    playerDataTable[player.UserId][dataname][2] = playerDataTable[player.UserId][dataname][1]
    playerDataTable[player.UserId][dataname][1] = value
end

function dataStoreLight.save(player:Player)
    for k,v in playerDataTable[player.UserId] do
        for i=1, 2 do
            if playerDataTable[player.UserId][k][i] then
                waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync , 2)
                DataStoreService:GetDataStore(`{k}:{i}`):SetAsync(v[i])
            end
        end
    end
end

return dataStoreLight