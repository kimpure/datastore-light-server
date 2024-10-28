--!strict
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local msgpack = require(script.Parent:WaitForChild('msgpack-luau')) :: typeof(require('./Packages/msgpack-luau'))
local rbxzstd = require(script.Parent:WaitForChild('rbxzstd')) :: typeof(require('./Packages/rbxzstd'))
local base91 = require(script.Parent:WaitForChild('base91')) :: typeof(require('./Packages/rbxzstd'))

function waitForRequest(requestType: Enum.DataStoreRequestType, num: number)
    local current = DataStoreService:GetRequestBudgetForRequestType(requestType)
    while current < num do
        current = DataStoreService:GetRequestBudgetForRequestType(requestType)
        task.wait(1 * num)
    end
end

type DataStoreLightImpl = {
	__index: DataStoreLightImpl,
	new: (key: string | number) -> (DataStoreLight),
    get: (self: DataStoreLight, dataname: string) -> (any, any),
    set: (self: DataStoreLight, dataname: string, value: any) -> (),
    save: (self: DataStoreLight) -> (),
}

export type DataStoreLight = typeof(setmetatable({} :: {
	key: number | string,
    data: { [string]: { [number]: any } },
    _onSet: boolean,
}, {} :: DataStoreLightImpl))


local datastorelight = {} :: DataStoreLightImpl
datastorelight.__index = datastorelight

function datastorelight.new(key: string | number)
    return setmetatable({
        key=key,
        data={},        
        _onSet=false,
    }, datastorelight)
end

function datastorelight.get(self, dataname)
    if self.data[dataname] == nil then
        waitForRequest(Enum.DataStoreRequestType.GetAsync, 4)
        local this = {
            DataStoreService:GetDataStore(`{dataname}:1`):GetAsync(self.key),
            DataStoreService:GetDataStore(`{dataname}:2`):GetAsync(self.key),
        }

        if not this[1] then
            this[1] = nil
        else
            this[1] = if (string.sub(this[1], 1, 1) == '\30') then
                    msgpack.decode(msgpack.utf8Decode(string.sub(this[1], 2)))
                else
                    msgpack.decode(msgpack.utf8Decode(buffer.tostring(rbxzstd.decompress(base91.decodeString(string.sub(this[1], 2))))))
        end

        if this[2] then
            this[2] = if (string.sub(this[2], 1, 1) == '\30') then
                msgpack.decode(msgpack.utf8Decode(string.sub(this[2], 2)))
            else
                msgpack.decode(msgpack.utf8Decode(buffer.tostring(rbxzstd.decompress(base91.decodeString(string.sub(this[2], 2))))))
        end

        self.data[dataname] = this
    end
    return self.data[dataname][1], self.data[dataname][2]
end

function datastorelight.set(self, dataname, value)
    self.data[dataname][2] = self.data[dataname][1]
    self.data[dataname][1] = value
    self._onSet = true
end

function datastorelight.save(self)
    for k, v in self.data do
        if v[1] == nil then
            if not self._onSet then
                return
            end
        end
        
        for i=1, 2 do
            local bufferData = msgpack.utf8Encode(msgpack.encode(v[i])) 
            local compressData = rbxzstd.compress(buffer.fromstring(bufferData))
            
            v[i] = if (compressData) then
                '\20'..base91.decodeString(compressData)
            else
                '\30'..bufferData
        end
            
        waitForRequest(Enum.DataStoreRequestType.SetIncrementAsync, 4)
        DataStoreService:GetDataStore(`{k}:1`):SetAsync(self.key, v[1])
        DataStoreService:GetDataStore(`{k}:2`):SetAsync(self.key, v[2])
    end
end

return datastorelight
