print("Hello world!")

-- !!!IMPORTANT!!! You must add a RemoteEvent with the name "FC_GetProfileDetailsEvent" into
-- ReplicatedStorage for this script to function properly


-- Wait for the FC_GetProfileDetailsEvent Instance to be replicated into the client
local RemoteEvent = game.ReplicatedStorage:WaitForChild("FC_GetProfileDetailsEvent")

-- print(RemoteEvent)
-- Dispatch the event here
RemoteEvent:FireServer()


-- Define a callback for server to client events to listen for an http response success or failure
-- On success, this will return the user's FreshCut account data
RemoteEvent.OnClientEvent:Connect(function(response)
  print('response received')
  print("client result: " .. response["username"])
end)