--[[
    @: This is a container for a message object
    @: https://discord.com/developers/docs/resources/channel#message-object
]]

local Cache = require("Cache")

local User = require("User")
local Role = require("Role")
local Channel = require("Channel")

type MessageMeta = {
	__index: MessageMeta,

	Reply: (self: Message, content: string) -> (),
}

export type Message = typeof(setmetatable(
	{} :: {
		Id: string,
		Channel: Channel.Channel,
		User: User.User,
		Content: string,
		Timestamp: string,
		EditedTimestamp: string?,
		Tts: boolean,
		MentionEveryone: boolean,
		Mentions: { User.User },
		MentionRoles: { Role.Role },
		MentionChannels: { Channel.Channel },
		Attachments: {},
		Embeds: {},
		Reactions: {},
		Pinned: boolean,
		WebhookId: string?,
		Type: number,
		Activity: {}?,
		MessageReference: MessageReference?,
	},
	{} :: MessageMeta
))

export type MessageReference = {
	MessageId: string,
	ChannelId: string,
	GuildId: string?,
	FailIfNotExists: boolean?,
}

export type MessageReferencePayload = {
	message_id: string,
	channel_id: string,
	guild_id: string?,
	fail_if_not_exists: boolean?,
}

export type MessagePayload = {
	id: string,
	channel_id: string,
	author: User.UserPayload,
	content: string,
	timestamp: string,
	edited_timestamp: string?,
	tts: boolean,
	mention_everyone: boolean,
	mentions: { User.UserPayload },
	mention_roles: { string },
	mention_channels: { Channel.ChannelMention }?,
	attachments: {},
	embeds: {},
	reactions: {},
	pinned: boolean,
	webhook_id: string?,
	type: number,
	activity: {}?,
	message_reference: MessageReferencePayload?,
}

local Message = {}
local MessageInstance = {} :: MessageMeta
MessageInstance.__index = MessageInstance

local function keyed(channelId: string, messageId: string): string
	return `{channelId}:{messageId}`
end

function Message.get(channelId: string, messageId: string, raw: boolean?): Message?
	local cacheKey = keyed(channelId, messageId)

	local fromCache = Cache.Message:Get(cacheKey)
	if not fromCache and Cache.API and not raw then
		local messagePayload = Cache.API:GetMessage(channelId, messageId)
		if messagePayload then
			return Message.new(messagePayload)
		end
	end
	return fromCache
end

function Message.new(payload: MessagePayload): Message
	local channel = Channel.get(payload.channel_id)
	assert(channel, "Channel not found")

	local cacheKey = keyed(payload.channel_id, payload.id)

	local self = setmetatable({
		Id = payload.id,
		Channel = channel,
		User = User.new(payload.author),
		Content = payload.content,
		Timestamp = payload.timestamp,
		EditedTimestamp = payload.edited_timestamp,
		Tts = payload.tts,
		MentionEveryone = payload.mention_everyone,
		Mentions = {},
		MentionRoles = {},
		MentionChannels = {},
		Attachments = payload.attachments,
		Embeds = payload.embeds,
		Reactions = payload.reactions,
		Pinned = payload.pinned,
		WebhookId = payload.webhook_id,
		Type = payload.type,
		Activity = payload.activity,
		MessageReference = if payload.message_reference
			then {
				MessageId = payload.message_reference.message_id,
				ChannelId = payload.message_reference.channel_id,
				GuildId = payload.message_reference.guild_id,
				FailIfNotExists = payload.message_reference.fail_if_not_exists,
			}
			else nil,
	}, MessageInstance) :: Message

	for _, mention in payload.mentions do
		table.insert(self.Mentions, User.get(mention.id))
	end

	for _, mention in payload.mention_roles do
		table.insert(self.MentionRoles, Role.get(mention))
	end

	if payload.mention_channels then
		for _, mention in payload.mention_channels do
			table.insert(self.MentionChannels, Channel.fromChannelMention(mention))
		end
	end

	Cache.Message:Set(cacheKey, self)

	return self
end

function MessageInstance:Reply(content: string): ()
	Cache.API:PostMessage(self.Channel.Id, {
		content = content,
		message_reference = {
			message_id = self.Id,
			channel_id = self.Channel.Id,
			guild_id = self.Channel.GuildId,
			fail_if_not_exists = false,
		},
	})
end

return Message
