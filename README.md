# FreshCut Roblox SDK

The FreshCut Roblox SDK is a file that you can insert into your Roblox game. It acts as an interface, allowing your game to communicate with FreshCut's backend servers. With this SDK, you can access various types of information and services provided by FreshCut, such as account information, game stats, and more, all from within your Roblox game.

### Installation

---

Secret:

- You will need to contact a FreshCut team member to receive your FreshCut External API key, which will need to be placed into your app’s secret store.  Please reach out to `adrianhero` directly via discord or in your respective game’s discord channel inside of the [FreshCut Developer Discord server](https://discord.gg/BYdaS8pMHV).
- See [this Roblox Devforum article](https://devforum.roblox.com/t/secrets-store-general-availability/2892154) for a guide to setting up and using [Secrets](https://create.roblox.com/docs/reference/engine/datatypes/Secret)
- As this SDK requires a Secret, it will NOT work on local builds. You will be kindly served an error from the API

Files included:

- FreshCutSDK.lua
    - The base file used for communicating with FreshCut’s backend, and technically the only file needed from us for things to work. You will place this file into `ServerScriptService`
- FC_GetProfileDetailsEvent_Client_Example.lua
    - An example client script for interfacing with the SDK. There is a both an event dispatcher function and a listener function included. Place this file inside of `StarterPlayer/StarterPlayerScripts`.

### Usage

---

Detailed information is included in the example file above, but the basic use case is to dispatch the RemoteFunction in your app, then examine the user’s FreshCut account data (if it exists). The returned data is as follows:

```graphql
{
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
```
