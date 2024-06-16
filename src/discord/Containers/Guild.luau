--[[
    @: Represents a guild in Discord
    @: https://discord.com/developers/docs/resources/guild#guild-object
]]

local Cache = require("Cache")

local Channel = require("Channel")
local Member = require("Member")
local Role = require("Role")

type GuildMeta = {
	__index: GuildMeta,

	GetIconURL: (self: Guild, size: number?, format: string?) -> string,
}

export type Guild = typeof(setmetatable(
	{} :: {
		Id: string,
		Name: string,
		Icon: string?,
		OwnerId: string,
		Permissions: string,
		Region: string,
		AfkChannelId: string?,
		AfkTimeout: number,
		EmbedEnabled: boolean,
		EmbedChannelId: string?,
		VerificationLevel: number,
		DefaultMessageNotifications: number,
		ExplicitContentFilter: number,
		Roles: { Role.RolePayload },
		MfaLevel: number,
		ApplicationId: string?,
		WidgetEnabled: boolean,
		WidgetChannelId: string?,
		SystemChannelId: string?,
		SystemChannelFlags: number,
		RulesChannelId: string?,
		JoinedAt: string,
		Large: boolean,
		Unavailable: boolean,
		MemberCount: number,
		VoiceStates: {},
		Members: { Member.Member },
		Channels: { Channel.Channel },
		Presences: {},
		MaxPresences: number?,
		MaxMembers: number,
		VanityUrlCode: string?,
		Description: string?,
		Banner: string?,
		PremiumTier: number,
		PreferredLocale: string,
		NSFWLevel: number,
		Stickers: {},
	},
	{} :: GuildMeta
))

type GuildPayload = {
	id: string,
	name: string,
	icon: string?,
	owner_id: string,
	permissions: string,
	region: string,
	afk_channel_id: string?,
	afk_timeout: number,
	embed_enabled: boolean,
	embed_channel_id: string?,
	verification_level: number,
	default_message_notifications: number,
	explicit_content_filter: number,
	roles: { Role.RolePayload },
	mfa_level: number,
	application_id: string?,
	widget_enabled: boolean,
	widget_channel_id: string?,
	system_channel_id: string?,
	system_channel_flags: number,
	rules_channel_id: string?,
	joined_at: string,
	large: boolean,
	unavailable: boolean,
	member_count: number,
	voice_states: {},
	presences: {},
	max_presences: number?,
	max_members: number,
	vanity_url_code: string?,
	description: string?,
	banner: string?,
	premium_tier: number,
	preferred_locale: string,
	nsfw_level: number,
	stickers: {},
}

type UnavailableGuildPayload = {
	id: string,
	unavailable: boolean,
}

local Guild = {}
local GuildInstance = {} :: GuildMeta
GuildInstance.__index = GuildInstance

function Guild.get(guildId: string): Guild?
	local fromCache = Cache.Guild:Get(guildId)
	if (not fromCache or fromCache.Unavailable) and Cache.API then
		local guildPayload = Cache.API:GetGuild(guildId)
		if guildPayload then
			return Guild.new(guildPayload)
		end
	end
	return fromCache
end

function Guild.new(payload: GuildPayload): Guild
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

	for _, rolePayload in payload.roles do
		local role = Role.get(rolePayload.id) or Role.new(rolePayload)
		self.Roles[role.Id] = role
	end

	local members = Cache.API:GetGuildMembers(payload.id)
	local channels = Cache.API:GetGuildChannels(payload.id)

	for _, memberPayload in members do
		local member = Member.get(payload.id, memberPayload.user.id)
		self.Members[member.Id] = member
	end

	for _, channelPayload in channels do
		local channel = Channel.get(channelPayload.id)
		self.Channels[channel.Id] = channel
	end

	Cache.Guild:Set(payload.id, self)

	return self
end

function Guild.newUnavailable(payload: UnavailableGuildPayload): Guild
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
