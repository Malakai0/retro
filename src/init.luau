local Client = require("discord/Client")
local Intents = require("discord/Intents")

local Types = require("discord/Containers/Types")

--// Preload Containers
require("discord/Containers/Channel")
require("discord/Containers/Guild")
require("discord/Containers/Member")
require("discord/Containers/Message")
require("discord/Containers/Role")
require("discord/Containers/User")

export type Client = Client.Client
export type Ready = Client.Ready

export type Channel = Types.Channel
export type Guild = Types.Guild
export type Member = Types.Member
export type Message = Types.Message
export type Role = Types.Role
export type User = Types.User

return {
	Client = Client,
	Intents = Intents,
}
