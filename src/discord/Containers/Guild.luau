--[[
    @: Represents a guild in Discord
    @: https://discord.com/developers/docs/resources/guild#guild-object
]]

local Cache = require("Cache")
local Interface = require("Interface")
local Types = require("Types")

type GuildMeta = Types.GuildMeta
type Guild = Types.Guild
type GuildPayload = Types.GuildPayload
type UnavailableGuildPayload = Types.UnavailableGuildPayload

local Guild = {}
local GuildInstance = {} :: GuildMeta
GuildInstance.__index = GuildInstance

function Interface.GetGuild(guildId: string, raw: boolean?): Guild?
	local fromCache = Cache.Guild:Get(guildId)
	if (not fromCache or fromCache.Unavailable) and Cache.API and not raw then
		local guildPayload = Cache.API:GetGuild(guildId)
		if guildPayload then
			return Interface.CreateGuild(guildPayload)
		end
	end
	return fromCache
end

function Interface.CreateGuild(payload: GuildPayload): Guild
	local self = setmetatable({
		Id = payload.id,
		Name = payload.name,
		Icon = payload.icon,
		OwnerId = payload.owner_id,
		Permissions = payload.permissions,
		Region = payload.region,
		AfkChannelId = payload.afk_channel_id,
		AfkTimeout = payload.afk_timeout,
		EmbedEnabled = payload.embed_enabled,
		EmbedChannelId = payload.embed_channel_id,
		VerificationLevel = payload.verification_level,
		DefaultMessageNotifications = payload.default_message_notifications,
		ExplicitContentFilter = payload.explicit_content_filter,
		MfaLevel = payload.mfa_level,
		ApplicationId = payload.application_id,
		WidgetEnabled = payload.widget_enabled,
		WidgetChannelId = payload.widget_channel_id,
		SystemChannelId = payload.system_channel_id,
		SystemChannelFlags = payload.system_channel_flags,
		RulesChannelId = payload.rules_channel_id,
		JoinedAt = payload.joined_at,
		Large = payload.large,
		Unavailable = payload.unavailable,
		MemberCount = payload.member_count,
		VoiceStates = payload.voice_states,
		Presences = payload.presences,
		MaxPresences = payload.max_presences,
		MaxMembers = payload.max_members,
		VanityUrlCode = payload.vanity_url_code,
		Description = payload.description,
		Banner = payload.banner,
		PremiumTier = payload.premium_tier,
		PreferredLocale = payload.preferred_locale,
		NSFWLevel = payload.nsfw_level,
		Stickers = payload.stickers,

		Roles = {},
		Members = {},
		Channels = {},
	}, GuildInstance)

	Cache.Guild:Set(payload.id, self)

	for _, rolePayload in payload.roles do
		local role = Interface.GetRole(self.Id, rolePayload.id, true) or Interface.CreateRole(self.Id, rolePayload)
		self.Roles[role.Id] = role
	end

	local members: { Types.MemberPayload } = Cache.API:GetGuildMembers(payload.id)
	local channels: { Types.ChannelPayload } = Cache.API:GetGuildChannels(payload.id)

	for _, memberPayload in members do
		local member = Interface.GetMember(self.Id, memberPayload.user.id)
		self.Members[member.Id] = member
	end

	for _, channelPayload in channels do
		local channel = Interface.GetChannel(channelPayload.id)
		self.Channels[channel.Id] = channel
	end

	return self
end

function Interface.CreateUnavailableGuild(payload: UnavailableGuildPayload): Guild
	local self = setmetatable({
		Id = payload.id,
		Unavailable = payload.unavailable,
	}, GuildInstance)

	Cache.Guild:Set(payload.id, self)

	return self
end

function GuildInstance:GetIconURL(size: number?, format: string?): string
	size = size or 128
	format = format or "webp"

	return `https://cdn.discordapp.com/icons/{self.Id}/{self.Icon}.{format}?size={size}`
end

return Guild
