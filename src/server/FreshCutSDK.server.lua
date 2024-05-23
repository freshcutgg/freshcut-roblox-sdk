-- FreshCut API version 0.1
-- 
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@           @@@@@@@@@         @@        @@@@         @@@       @@@   @@@@@   @@@@@      @@@@   @@@@@   @          @@@
--@@@              @@@@@@@         @@         @@@         @@         @@   @@@@@   @@@@         @@   @@@@@   @          @@@
--@@               @@@@@@@         @@          @@         @@         @@   @@@@@   @@@          @@   @@@@@   @          @@@
--@                 @@@@@@   @@@@@@@@   @@@    @@   @@@@@@@    @@@@ @@@   @@@@@   @@@   @@@@   @@   @@@@@   @@@@@   @@@@@@
--@                 @@@@@@         @@   @@@    @@         @@      @@@@@           @@   @@@@@@@@@@   @@@@@   @@@@@   @@@@@@
--@@               @@@@@@@         @@          @@         @@        @@@           @@   @@@@@@@@@@   @@@@@   @@@@@   @@@@@@
--@@@             @@@@@@@@         @@         @@@         @@@        @@           @    @@@@@@@@@@   @@@@@   @@@@@   @@@@@@
--@@@@@          @@@@@@@@@   @@@@@@@@        @@@@   @@@@@@@@@@@@     @@   @@@@@  @@@   @@@@@@@@@@   @@@@@   @@@@@   @@@@@@
--@@@@@         @@@@@@@@@@   @@@@@@@@   @    @@@@   @@@@@@@@  @@@@    @   @@@@@  @@@    @@@@   @@    @@@    @@@@@   @@@@@@
--@@@@@@@@     @@@@@@@@@@@   @@@@@@@@   @@    @@@         @          @@   @@@@@ @@@@@          @@          @@@@@@   @@@@@@
--@@@@@@@     @@@@@@@@@@@@   @@@@@@@@   @@@    @@         @          @@   @@@@@@@@@@@          @@@         @@@@@@   @@@@@@
--@@@@@@@@@  @@@@@@@@@@@@@   @@@@@@@@   @@@    @@         @@@       @@@   @@@@@@@@@@@@@      @@@@@@      @@@@@@@@   @@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--
--  Copyright (C) 2022 FreshCut Interactive Inc - All Rights Reserved
--  Unauthorized copying of this file, via any medium is strictly prohibited
--  Proprietary and confidential
--

-- ** DOCUMENTATION **
--
--    Visit https://freshcut.notion.site/FreshCut-Roblox-API-405bcfbfc0b343e4b71b202d40f22001?pvs=4


--  ** REQUIREMENTS **
--
--    1. Place this file into ServerScriptService
--
--    2. Create a new Event named FC_GetProfileDetailsEvent inside of ReplicatedStorage
--
--    3. Code an event dispatch from your client script to trigger the FC_GetProfileEvent
--
--    4. Code a listener to consume the information returned from FreshCut
--
--
--    If you're using Rojo, you can just sync the entire src folder to your project!

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local url = 'https://graphql-gateway.api.cloud.freshcut.gg'

-- function get fetch the API key id and secret
local function getAPIKey() 
  warn('getting api key')
  local freshcut_app_key = HttpService:GetSecret("freshcut_app_key")
  warn('secrets successfully fetched')
  local headers = {
    ["Content-Type"] = "application/json",
		["Authorization"] = freshcut_app_key:AddPrefix("Basic ")
  }

  local getAPIKeyQuery = [[
    mutation {
      auth {
        accessToken {
          accessToken
          expiresIn
        }
      }
    }
  ]]

  local requestBody = {
    query = getAPIKeyQuery,
    variables = {}
  }

  local body = HttpService:JSONEncode(requestBody)
  local response = HttpService:RequestAsync({
    Url = url, 
    Method = "POST",
    Headers = headers,
    Body = body,
  })

  warn('statusCode: ' .. response.StatusCode)
  response = HttpService:JSONDecode(response.Body)
  warn("access token received")

  return response
  -- if not success then
  --   warn("PostAsync failed with error : ", result)
  --   return false
  -- end

  -- return result
end

local function getProfileDetailsBySocialID(id, accessToken)
	local getProfileDetailsBySocialIDQuery = [[
		query ($socialId: String!, $type: QueryableSocialType!) {
			userProfileBySocial(socialId: $socialId, type: $type) {
				details {
      		id
      		username
      		bio
      		role
      		isFeatured
      		firstVideoPublishedDate
      		profileImageUrl
      		backgroundImageUrl
      		videoCount
      		likesCount
      		viewsCount
      		followersCount
      		followingCount
      		socials {
      		  type
            url
          	count
          }
    		}
  		}
		}
	]]
	
	local headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. accessToken,
	}
	
	local requestBody = {
		query = getProfileDetailsBySocialIDQuery,
		variables = {
			socialId = tostring(id),
			type = "ROBLOX"
		}
	}
	
	local body = HttpService:JSONEncode(requestBody)
	local response = HttpService:RequestAsync({
		Url = url, 
		Method = "POST",
		Headers = headers,
		Body = body,
	})

  response = HttpService:JSONDecode(response.Body)
  print(response)
	return response
end

handleGetUserDetails = function (robloxUserId)
	local status, result = pcall(getAPIKey)

	if not status then return "Error retrieving API Key" end
	
	local status2, result2 = pcall(getProfileDetailsBySocialID, robloxUserId, result.data.auth.accessToken.accessToken)
	if not status2 then 
		return "API Error" 
	end
	if result2.errors then
		return result2.errors[1].message
	else
		return result2
	end
end


local remoteEvent = ReplicatedStorage:FindFirstChild("FC_GetProfileDetailsEvent")
	remoteEvent.OnServerEvent:Connect(function(player, text)
  local status, result = pcall(handleGetUserDetails, player.UserId)
  if not status then 
    return "API Error" 
  end

	remoteEvent:FireClient(player, result["data"]["userProfileBySocial"]["details"])
	return 
end)

local module =  {
  handleGetUserDetails = handleGetUserDetails
}

return module
