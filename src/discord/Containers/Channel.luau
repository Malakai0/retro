--[[
    @: This is a container for a channel object
    @: https://discord.com/developers/docs/resources/channel#channel-object
]]

local Cache = require("Cache")
local Interface = require("Interface")
local Types = require("Types")

type ChannelMeta = Types.ChannelMeta
type Channel = Types.Channel
type ChannelPayload = Types.ChannelPayload
type ChannelMention = Types.ChannelMention

local Channel = {}
local ChannelInstance = {} :: ChannelMeta
ChannelInstance.__index = ChannelInstance

function Interface.GetChannel(channelId: string): Channel?
	local fromCache = Cache.Channel:Get(channelId)
	if not fromCache and Cache.API then
		local channelPayload = Cache.API:GetChannel(channelId)
		if channelPayload then
			return Interface.CreateChannel(channelPayload)
		end
	end
	return fromCache
end

function Interface.CreateChannel(payload: ChannelPayload): Channel
	local self = setmetatable({
		Id = payload.id,
		Type = payload.type,
		Guild = if payload.guild_id then Interface.GetGuild(payload.guild_id) else nil,
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

	Cache.Channel:Set(payload.id, self)

	if payload.recipients then
		for _, userPayload in payload.recipients do
			local user = Interface.GetUser(userPayload.id, true)
			if not user then
				user = Interface.CreateUser(userPayload)
			end
			table.insert(self.Recipients, user)
		end
	end

	return self
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
