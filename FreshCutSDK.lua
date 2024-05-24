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

-- ** DOCUMENTATION **
--
--    Visit https://freshcut.notion.site/FreshCut-Roblox-API-405bcfbfc0b343e4b71b202d40f22001?pvs=4


--  ** REQUIREMENTS **
--
--    1. Place this file into ServerScriptService
--
--    2. Dispatch a remote function call to FC_GetProfileDetailsFunction for the data
--
--    3. The FC_GetProfileDetailsFunction will return the user's profile details if the user exists in the FreshCut database
--
--    4. That's it! Check the README for complete user data details

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local FC_GetProfileDetailsFunction = Instance.new("RemoteFunction")
FC_GetProfileDetailsFunction.Name = "FC_GetProfileDetailsFunction"
FC_GetProfileDetailsFunction.Parent = ReplicatedStorage

print("FreshCut SDK Loaded")

-- This is the DEV ENVIRONMENT URL
local url = 'https://graphql-gateway.api.dev-cloud.freshcut.gg'

-- This is the PRODUCTION ENVIRONMENT URL...use at your own risk when ready!
-- local url = 'https://graphql-gateway.api.cloud.freshcut.gg'

-- function get fetch the API key id and secret
local function getAPIKey() 
  warn('getting api key')
  local api_key = HttpService:GetSecret("freshcut_app_key")

  warn('secrets successfully fetched')
  local headers = {
    ["Content-Type"] = "application/json",
		["Authorization"] = api_key:AddPrefix("Basic ")
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

FC_GetProfileDetailsFunction.OnServerInvoke = function(player, text)
	if game:GetService("RunService"):IsStudio() then
		error("ERROR: Cannot run in Studio. Please run in a published instance.")
	end
	local status, result = pcall(handleGetUserDetails, player.UserId)
	if not status then 
		return "API Error" 
	end

	if result.errors then
		return result.errors[1].message
	else
		return result["data"]["userProfileBySocial"]["details"]
	end
end
