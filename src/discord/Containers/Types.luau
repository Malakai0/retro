export type CacheMeta = {
	__index: CacheMeta,

	Get: (self: Cache, key: string) -> any,
	Set: (self: Cache, key: string, value: any) -> (),
	Remove: (self: Cache, key: string) -> (),
	Count: (self: Cache) -> number,
}

export type Cache = typeof(setmetatable(
	{} :: {
		_cache: { [string]: any },
		_count: number,
	},
	{} :: CacheMeta
))

export type ChannelMeta = {
	__index: ChannelMeta,

	Send: (self: Channel, content: string) -> (),
}

export type Channel = typeof(setmetatable(
	{} :: {
		Id: string,
		Type: number,
		Guild: Guild?,
		Position: number,
		PermissionOverwrites: {},
		Name: string?,
		Topic: string?,
		Nsfw: boolean?,
		LastMessageId: string?,
		Bitrate: number?,
		UserLimit: number?,
		RateLimitPerUser: number?,
		Recipients: { User },
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
	recipients: { UserPayload }?,
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
	id: string,
	guild_id: string?,
	type: number,
	name: string,
}

export type GuildMeta = {
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
		Roles: { RolePayload },
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
		Members: { Member },
		Channels: { Channel },
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

export type GuildPayload = {
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
	roles: { RolePayload },
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

export type UnavailableGuildPayload = {
	id: string,
	unavailable: boolean,
}

export type MemberMeta = {
	__index: MemberMeta,
}

export type Member = typeof(setmetatable(
	{} :: {
		Id: string,
		GuildId: string,
		Nickname: string?,
		Roles: { Role },
		JoinedAt: string,
		PremiumSince: string?,
		Deaf: boolean,
		Mute: boolean,
		Flags: number?,
		Pending: boolean,
		Permissions: string,
		User: User,
	},
	{} :: MemberMeta
))

export type MemberPayload = {
	user: UserPayload,
	nick: string?,
	roles: { string },
	joined_at: string,
	premium_since: string?,
	deaf: boolean,
	mute: boolean,
	pending: boolean,
	permissions: string,
	flags: number,
}

export type MessageMeta = {
	__index: MessageMeta,

	Reply: (self: Message, content: string) -> (),
}

export type Message = typeof(setmetatable(
	{} :: {
		Id: string,
		Guild: Guild,
		Channel: Channel,
		User: User,
		Content: string,
		Timestamp: string,
		EditedTimestamp: string?,
		Tts: boolean,
		MentionEveryone: boolean,
		Mentions: { User },
		MentionRoles: { Role },
		MentionChannels: { Channel },
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
	guild_id: string,
	channel_id: string,
	author: UserPayload,
	content: string,
	timestamp: string,
	edited_timestamp: string?,
	tts: boolean,
	mention_everyone: boolean,
	mentions: { UserPayload },
	mention_roles: { string },
	mention_channels: { ChannelMention }?,
	attachments: {},
	embeds: {},
	reactions: {},
	pinned: boolean,
	webhook_id: string?,
	type: number,
	activity: {}?,
	message_reference: MessageReferencePayload?,
}

export type RoleMeta = {
	__index: RoleMeta,
}

export type Role = typeof(setmetatable(
	{} :: {
		Id: string,
		Guild: Guild,
		Name: string,
		Color: number,
		Hoist: boolean,
		Position: number,
		Permissions: string,
		Managed: boolean,
		Mentionable: boolean,
		Tags: { RoleTag },
	},
	{} :: RoleMeta
))

export type RoleTag = {
	BotId: string?,
	IntegrationId: string?,
	PremiumSubscriber: boolean?,
}

export type RolePayload = {
	id: string,
	name: string,
	color: number,
	hoist: boolean,
	icon: string?,
	unicode_emoji: string?,
	position: number,
	permissions: string,
	managed: boolean,
	mentionable: boolean,
	tags: { RoleTagsPayload }?,
	flags: number,
}

export type RoleTagsPayload = {
	bot_id: string?,
	integration_id: string?,
	premium_subscriber: boolean?,
}

export type AvatarDecorationData = {
	Asset: string,
	SkuId: string,
}

export type UserMeta = {
	__index: UserMeta,

	GetAvatarURL: (self: User, size: number?, format: string?) -> string,
	GetTag: (self: User) -> string,
}

export type User = typeof(setmetatable(
	{} :: {
		Id: string,
		Username: string,
		Discriminator: string,
		DisplayName: string?,
		Avatar: string?,
		Bot: boolean?,
		System: boolean?,
		MfaEnabled: boolean?,
		Locale: string?,
		Verified: boolean?,
		Email: string?,
		Flags: number?,
		PremiumType: number?,
		PublicFlags: number?,
		AvatarDecoration: AvatarDecorationData?,
	},
	{} :: UserMeta
))

export type UserPayload = {
	id: string,
	username: string,
	discriminator: string,
	global_name: string?,
	avatar: string?,
	bot: boolean?,
	system: boolean?,
	mfa_enabled: boolean?,
	locale: string?,
	verified: boolean?,
	email: string?,
	flags: number?,
	premium_type: number?,
	public_flags: number?,
	avatar_decoration_data: AvatarDecorationData?,
}

return {}
