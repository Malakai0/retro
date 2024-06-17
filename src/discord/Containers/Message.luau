--[[
    @: This is a container for a message object
    @: https://discord.com/developers/docs/resources/channel#message-object
]]

local Cache = require("Cache")
local Interface = require("Interface")
local Types = require("Types")

type MessageMeta = Types.MessageMeta
type Message = Types.Message
type MessagePayload = Types.MessagePayload

local Message = {}
local MessageInstance = {} :: MessageMeta
MessageInstance.__index = MessageInstance

local function keyed(channelId: string, messageId: string): string
	return `{channelId}:{messageId}`
end

function Interface.GetMessage(channelId: string, messageId: string, raw: boolean?): Message?
	local cacheKey = keyed(channelId, messageId)

	local fromCache = Cache.Message:Get(cacheKey)
	if not fromCache and Cache.API and not raw then
		local messagePayload: Types.MessagePayload = Cache.API:GetMessage(channelId, messageId)
		if messagePayload then
			return Interface.CreateMessage(messagePayload)
		end
	end
	return fromCache
end

function Interface.CreateMessage(payload: MessagePayload): Message
	local cacheKey = keyed(payload.channel_id, payload.id)

	local self = setmetatable({
		Id = payload.id,
		Guild = Interface.GetGuild(payload.guild_id, true),
		Channel = Interface.GetChannel(payload.channel_id, true),
		User = Interface.GetUser(payload.author.id, true),
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

	Cache.Message:Set(cacheKey, self)

	for _, mention in payload.mentions do
		table.insert(self.Mentions, Interface.GetUser(mention.id))
	end

	for _, mention in payload.mention_roles do
		table.insert(self.MentionRoles, Interface.GetRole(self.Guild.Id, mention))
	end

	if payload.mention_channels then
		for _, mention in payload.mention_channels do
			table.insert(self.MentionChannels, Interface.GetChannel(mention.id))
		end
	end

	if not self.User then
		self.User = Interface.CreateUser(payload.author)
	end

	if not self.Channel then
		self.Channel = Interface.GetChannel(payload.channel_id)
	end

	if not self.Guild then
		self.Guild = Interface.GetGuild(payload.guild_id)
	end

	return self
end

function MessageInstance:Reply(content: string): ()
	if not self.Channel then
		print(`Cannot reply to message {self.Id} as channel is not found`)
		return
	end

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
