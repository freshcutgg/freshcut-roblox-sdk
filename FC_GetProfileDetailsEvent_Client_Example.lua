print("FreshCut Roblox SDK Example Loaded")

-- Wait for the FC_GetProfileDetailsEvent Instance to be replicated into the client
local RemoteFunction = game.ReplicatedStorage:WaitForChild("FC_GetProfileDetailsFunction")

local FC_Client_Data = RemoteFunction:InvokeServer()
if (FC_Client_Data["username"] ~= nil) then
    print("client data retrieved from: " .. FC_Client_Data["username"])
else
  error("ERROR: erroneous data returned from FreshCut")
end