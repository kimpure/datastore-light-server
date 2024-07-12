--!strict

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local msgpack = require(ReplicatedStorage:WaitForChild('msgpack-luau'))
local rbxzstd = require(ReplicatedStorage:WaitForChild('rbxzstd'))
local base91 = require(ReplicatedStorage:WaitForChild('base91'))


--// DataStore 제한회수
function waitForRequest(requestType:Enum.DataStoreRequestType , num:number)
    local current = DataStoreService:GetRequestBudgetForRequestType(requestType)
    while current < num do
        current = DataStoreService:GetRequestBudgetForRequestType(requestType)
        task.wait(1 * num)
    end
end


local datatable = {
    ___coin = {1 , 2, 3 , 4,  5,  6};
}

local playerdatas = {} :: {
    [number]: {}
}

type DataTable = string 
type DataStoreLightImpl = {
	__index: DataStoreLightImpl;
	new: (player:Player)->(DataStoreLight);
    get: (self:DataStoreLight , dataname:DataTable)->();
    set: (self:DataStoreLight , dataname:DataTable , value:any)->();
    save: (self:DataStoreLight)->();
}

--// $Types
export type DataStoreLight = typeof(setmetatable({} :: {
	player: Player;
}, {} :: DataStoreLightImpl));


local datastorelight = {} :: DataStoreLightImpl
datastorelight.__index = datastorelight

--// \10 은 rbxzstd 으로 압축 안했을때 나오는 데이터
function datastorelight.new(player:Player)
    local self = {}
    for k,v in datatable do
        waitForRequest(Enum.DataStoreRequestType.GetAsync , 4)
        local this = {
            DataStoreService:GetDataStore(`{k}:1`):GetAsync(player.UserId);
            DataStoreService:GetDataStore(`{k}:2`):GetAsync(player.UserId);
        }

        if not this[1] then
            this[1] = v
        else
            this[1] = if (string.sub(this[1] , 1 , 1) == '\30') then
                    msgpack.decode( msgpack.utf8Decode( string.sub(this[1] , 2) ) )
                else
                    msgpack.decode( msgpack.utf8Decode( buffer.tostring( rbxzstd.decompress( base91.decodeString( string.sub(this[1] , 2) ) ) ) ) )
        end

        if this[2] then
            this[2] = if (string.sub(this[2] , 1 , 1) == '\30') then
                msgpack.decode( msgpack.utf8Decode( string.sub(this[2] , 2) ) )
            else
                msgpack.decode( msgpack.utf8Decode( buffer.tostring( rbxzstd.decompress( base91.decodeString( string.sub(this[2] , 2) ) ) ) ) )
        end

        self[k] = this
    end

    playerdatas[player.UserId] = self

    return setmetatable({player=player::Player} , datastorelight)
end

function datastorelight.get(self , dataname:string)
    local player = self.player :: Player;
    local this = playerdatas[player.UserId][dataname] :: {[number]: {any}};
    --// main
    return this[1] , this[2]
end

function datastorelight.set(self , dataname:string , value:any)
    local player = self.player :: Player;
    playerdatas[player.UserId][dataname][2] = playerdatas[player.UserId][dataname][1];
    --// main
    playerdatas[player.UserId][dataname][1] = value;
end

function datastorelight.save(self)
    local player = self.player :: Player
    --// main
    for k,_ in datatable do
        local this = {
            playerdatas[player.UserId][k][1];
            playerdatas[player.UserId][k][2];
        }
        
        if not this[1] then
            return
        end
        
        for i=1 , 2 do
            local temp = msgpack.utf8Encode( msgpack.encode( this[i] ) ) 
            local temp2 = rbxzstd.compress( buffer.fromstring( temp ) )
            
            this[i] = if (temp2) then
                '\20'..base91.decodeString( temp2 )
            else
                '\30'..temp
        end
            
        waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync , 4)
        DataStoreService:GetDataStore(`{k}:1`):SetAsync(player.UserId , this[1]);
        DataStoreService:GetDataStore(`{k}:2`):SetAsync(player.UserId , this[2]);
    end
end

return datastorelight