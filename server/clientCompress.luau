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

function unPack(data:any)
    return if (string.sub(data , 1 , 1) == '\30') then
        msgpack.decode( msgpack.utf8Decode( string.sub(data , 2) ) )
    else
        msgpack.decode( msgpack.utf8Decode( buffer.tostring( rbxzstd.decompress( base91.decodeString( string.sub(data , 2) ) ) ) ) )
end

function dataStoreLight.init(player:Player)
    playerDataTable[player.UserId] = {}
    for k,v in dataTable do
        for i=1, 2 do
            playerDataTable[player.UserId][tostring(k)][i] = unPack(if (DataStoreService:GetDataStore(`{k}:{i}`):GetAsync(player.UserId)) then
                DataStoreService:GetDataStore(`{k}:{i}`):GetAsync(player.UserId)
            else
                v
            )
        end
    end
end

function dataStoreLight.get(player:Player , dataName:string)
    return if (playerDataTable[player.UserId][dataName]) then
        table.unpack({playerDataTable[player.UserId][dataName][1] , playerDataTable[player.UserId][dataName][2]})
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
                DataStoreService:GetDataStore(`{k}:{i}`):SetAsync(playerDataTable[player.UserId][k][i])
            end
        end
    end
end

return dataStoreLight