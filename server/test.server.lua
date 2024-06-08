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