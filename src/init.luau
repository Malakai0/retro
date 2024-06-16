local Client = require("discord/Client")
local Intents = require("discord/Intents")

local Channel = require("discord/Containers/Channel")
local Guild = require("discord/Containers/Guild")
local Member = require("discord/Containers/Member")
local Message = require("discord/Containers/Message")
local Role = require("discord/Containers/Role")
local User = require("discord/Containers/User")

export type Client = Client.Client
export type Ready = Client.Ready

export type Channel = Channel.Channel
export type Guild = Guild.Guild
export type Member = Member.Member
export type Message = Message.Message
export type Role = Role.Role
export type User = User.User

return {
	Client = Client,
	Intents = Intents,
}
