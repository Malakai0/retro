--[[
    @: This is a container for a channel object
    @: https://discord.com/developers/docs/resources/channel#channel-object
]]

local Cache = require("Cache")

local User = require("User")

type ChannelMeta = {
	__index: ChannelMeta,

	Send: (self: Channel, content: string) -> (),
}

export type Channel = typeof(setmetatable(
	{} :: {
		Id: string,
		Type: number,
		GuildId: string?,
		Position: number,
		PermissionOverwrites: {},
		Name: string?,
		Topic: string?,
		Nsfw: boolean?,
		LastMessageId: string?,
		Bitrate: number?,
		UserLimit: number?,
		RateLimitPerUser: number?,
		Recipients: { User.User },
		con: string?,
		OwnerId: string?,
		ApplicationId: string?,
		ParentId: string?,
		LastPinTimestamp: string?,
		RtcRegion: string?,
		VideoQualityMode: number?,
		MessageCount: number?,
		MemberCount: number?,
		ThreadMetadata: {},
	},
	{} :: ChannelMeta
))

export type ChannelPayload = {
	id: string,
	type: number,
	guild_id: string?,
	position: number,
	permission_overwrites: {},
	name: string?,
	topic: string?,
	nsfw: boolean?,
	last_message_id: string?,
	bitrate: number?,
	user_limit: number?,
	rate_limit_per_user: number?,
	recipients: { User.UserPayload }?,
	con: string?,
	owner_id: string?,
	application_id: string?,
	parent_id: string?,
	last_pin_timestamp: string?,
	rtc_region: string?,
	video_quality_mode: number?,
	message_count: number?,
	member_count: number?,
	thread_metadata: {},
}

export type ChannelMention = {
	Id: string,
	GuildId: string?,
	Type: number,
	Name: string,
}

local Channel = {}
local ChannelInstance = {} :: ChannelMeta
ChannelInstance.__index = ChannelInstance

function Channel.get(channelId: string): Channel?
	local fromCache = Cache.Channel:Get(channelId)
	if not fromCache and Cache.API then
		local channelPayload = Cache.API:GetChannel(channelId)
		if channelPayload then
			return Channel.new(channelPayload)
		end
	end
	return fromCache
end

function Channel.new(payload: ChannelPayload): Channel
	local self = setmetatable({
		Id = payload.id,
		Type = payload.type,
		GuildId = payload.guild_id,
		Position = payload.position,
		PermissionOverwrites = payload.permission_overwrites,
		Name = payload.name,
		Topic = payload.topic,
		Nsfw = payload.nsfw,
		LastMessageId = payload.last_message_id,
		Bitrate = payload.bitrate,
		UserLimit = payload.user_limit,
		RateLimitPerUser = payload.rate_limit_per_user,
		Recipients = {},
		con = payload.con,
		OwnerId = payload.owner_id,
		ApplicationId = payload.application_id,
		ParentId = payload.parent_id,
		LastPinTimestamp = payload.last_pin_timestamp,
		RtcRegion = payload.rtc_region,
		VideoQualityMode = payload.video_quality_mode,
		MessageCount = payload.message_count,
		MemberCount = payload.member_count,
		ThreadMetadata = payload.thread_metadata,
	}, ChannelInstance)

	if payload.recipients then
		for _, userPayload in payload.recipients do
			local user = User.get(userPayload.id, true)
			if not user then
				user = User.new(userPayload)
			end
			table.insert(self.Recipients, user)
		end
	end

	Cache.Channel:Set(payload.id, self)

	return self
end

function Channel.fromChannelMention(mention: ChannelMention): Channel?
	if Channel.get(mention.Id) then
		return Channel.get(mention.Id)
	end

	if not Cache.API then
		print(`API not found in cache`)
		return
	end

	local channel = Cache.API:GetChannel(mention.Id)
	if not channel then
		return
	end

	return Channel.new(channel)
end

function ChannelInstance:Send(content: string): ()
	local api = Cache.API
	if not api then
		print(`API not found in cache`)
		return
	end

	api:PostMessage(self.Id, {
		content = content,
	})
end

return Channel
