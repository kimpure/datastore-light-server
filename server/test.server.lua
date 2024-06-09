local Players = game:GetService("Players")
local DataStoreLight = require(script.Parent:WaitForChild('DataStoreLight'))
Players.PlayerAdded:Connect(function(player)
    DataStoreLight.load(player)
    print(DataStoreLight.get(player , 'eee'))
    local th = {}
	for i=1 , 50 do
		th[i] = {'arr 인대 string 으로 데이터를 뿔리기'}
	end
    DataStoreLight.set(player , 'eee' , th)
    print(DataStoreLight.get(player , 'eee'))
    DataStoreLight.discardChanges(player)
    print(DataStoreLight.get(player , 'eee'))
    DataStoreLight.save(player)
end)