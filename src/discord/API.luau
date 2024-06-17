local serde = require("@lune/serde")
local net = require("@lune/net")

local Types = require("Containers/Types")

local routes = {
	GET_APPLICATION = "/applications/%s",
	GET_APPLICATION_BRANCHES = "/applications/%s/branches",
	GET_APPLICATION_BRANCH_BUILD = "/applications/%s/branches/%s/builds",
	GET_APPLICATION_BRANCH_BUILD_BY_ID = "/applications/%s/branches/%s/builds/%s",
	GET_APPLICATION_BRANCH_BUILD_LIVE = "/applications/%s/branches/%s/builds/live?locale=%s&platform=%s",
	GET_APPLICATION_COMMANDS = "/applications/%s/commands",
	GET_APPLICATION_COMMAND_BY_ID = "/applications/%s/commands/%s",
	GET_APPLICATION_GUILD_COMMAND_PERMISSIONS = "/applications/%s/guilds/%s/commands/permissions",
	GET_APPLICATION_SKUS = "/applications/%s/skus",
	GET_APPLICATION_PUBLIC = "/applications/%s/public",
	GET_APPLICATION_DETECTABLE = "/applications/detectable",

	GET_CHANNEL = "/channels/%s",
	GET_CHANNEL_CALL = "/channels/%s/call",
	GET_CHANNEL_FOLLOWER_STATS = "/channels/%s/follower-stats",
	GET_CHANNEL_FOLLOWER_MESSAGE_STATS = "/channels/%s/follower-message-stats",
	GET_CHANNEL_INVITES = "/channels/%s/invites",
	GET_CHANNEL_MESSAGES = "/channels/%s/messages",
	GET_CHANNEL_MESSAGES_SEARCH = "/channels/%s/messages/search",
	GET_CHANNEL_MESSAGE_BY_ID = "/channels/%s/messages/%s",
	GET_CHANNEL_MESSAGE_REACTIONS = "/channels/%s/messages/%s/reactions/%s",
	GET_CHANNEL_PINS = "/channels/%s/pins",
	GET_CHANNEL_STORE_LISTING = "/channels/%s/store-listing",
	GET_CHANNEL_STORE_LISTING_BY_SKU = "/channels/%s/store-listing/%s",
	GET_CHANNEL_USERS_THREADS_ARCHIVED_PRIVATE = "/channels/%s/users/@me/threads/archived/private",
	GET_CHANNEL_WEBHOOKS = "/channels/%s/webhooks",
	GET_CHANNEL_THREAD_MEMBERS = "/channels/%s/thread-members",
	GET_CHANNEL_THREADS_ACTIVE = "/channels/%s/threads/active",
	GET_CHANNEL_THREADS_ARCHIVED_PUBLIC = "/channels/%s/threads/archived/public",
	GET_CHANNEL_THREADS_ARCHIVED_PRIVATE = "/channels/%s/threads/archived/private",
	GET_CHANNEL_THREADS_SEARCH = "/channels/%s/threads/search",

	POST_CHANNEL_MESSAGE = "/channels/%s/messages",
	POST_GUILD_CHANNEL = "/guilds/%s/channels",
	POST_GUILD_ROLE = "/guilds/%s/roles",

	GET_GATEWAY = "/gateway",
	GET_GATEWAY_BOT = "/gateway/bot",

	GET_GIFS_SUGGEST = "/gifs/suggest?q=%s",
	GET_GIFS_TRENDING = "/gifs/trending",
	GET_GIFS_TRENDING_SEARCH = "/gifs/trending-search",

	GET_GUILD = "/guilds/%s",
	GET_GUILD_ACTIVE_CHANNELS = "/guilds/%s/active-channels",
	GET_GUILD_APPLICATIONS = "/guilds/%s/applications",
	GET_GUILD_AUDIT_LOGS = "/guilds/%s/audit-logs",
	GET_GUILD_BANS = "/guilds/%s/bans",
	GET_GUILD_BAN_BY_USER_ID = "/guilds/%s/bans/%s",
	GET_GUILD_CHANNELS = "/guilds/%s/channels",
	GET_GUILD_EMOJIS = "/guilds/%s/emojis",
	GET_GUILD_EMOJI_BY_ID = "/guilds/%s/emojis/%s",
	GET_GUILD_INTEGRATIONS = "/guilds/%s/integrations",
	GET_GUILD_INVITES = "/guilds/%s/invites",
	GET_GUILD_MEMBERS = "/guilds/%s/members",
	GET_GUILD_MEMBER_BY_USER_ID = "/guilds/%s/members/%s",
	GET_GUILD_MEMBER_VERIFICATION = "/guilds/%s/member-verification",
	GET_GUILD_REGIONS = "/guilds/%s/regions",
	GET_GUILD_REQUESTS = "/guilds/%s/requests",
	GET_GUILD_ROLES = "/guilds/%s/roles",
	GET_GUILD_STICKERS = "/guilds/%s/stickers",
	GET_GUILD_STICKER_BY_ID = "/guilds/%s/stickers/%s",
	GET_GUILD_VANITY_URL = "/guilds/%s/vanity-url",
	GET_GUILD_WEBHOOKS = "/guilds/%s/webhooks",

	GET_USER = "/users/%s",
	GET_USER_CHANNELS = "/users/%s/channels",
	GET_USER_PROFILE = "/users/%s/profile",

	GET_USER_ME = "/users/@me",
	GET_USER_ME_CHANNELS = "/users/@me/channels",
}

type APIMeta = {
	__index: APIMeta,

	Request: (self: API, method: string, route: string, body: any?) -> any,

	GetGuild: (self: API, guildId: string) -> Types.GuildPayload?,
	GetGuildMember: (self: API, guildId: string, memberId: string) -> Types.MemberPayload?,
	GetGuildMembers: (self: API, guildId: string) -> { Types.MemberPayload }?,
	GetGuildRoles: (self: API, guildId: string) -> { Types.RolePayload }?,
	GetGuildChannels: (self: API, guildId: string) -> { Types.ChannelPayload }?,

	GetChannel: (self: API, channelId: string) -> Types.ChannelPayload?,
	GetMessage: (self: API, channelId: string, messageId: string) -> Types.MessagePayload?,

	GetUser: (self: API, userId: string) -> Types.UserPayload?,

	PostMessage: (self: API, channelId: string, message: any) -> (),
}

export type API = typeof(setmetatable(
	{} :: {
		Token: string,
	},
	{} :: APIMeta
))

local API = {}
local APIInstance = {} :: APIMeta
APIInstance.__index = APIInstance

function API.new(token: string): API
	return setmetatable({
		Token = token,
	}, APIInstance)
end

function APIInstance:Request(method: string, route: string, body: any?): any
	local response = net.request({
		url = `https://discord.com/api/v10{route}`,
		method = method,
		headers = {
			["Authorization"] = `Bot {self.Token}`,
			["Content-Type"] = "application/json",
		},
		body = if body then serde.encode("json", body) else nil,
	})

	if response.ok then
		return serde.decode("json", response.body)
	end

	error(`{response.statusCode}: {response.statusMessage}`)
end

function APIInstance:GetGuild(guildId: string): Types.GuildPayload?
	return self:Request("GET", routes.GET_GUILD:format(guildId))
end

function APIInstance:GetGuildMember(guildId: string, memberId: string): Types.MemberPayload?
	return self:Request("GET", routes.GET_GUILD_MEMBER_BY_USER_ID:format(guildId, memberId))
end

function APIInstance:GetGuildMembers(guildId: string): { Types.MemberPayload }?
	return self:Request("GET", routes.GET_GUILD_MEMBERS:format(guildId))
end

function APIInstance:GetGuildRoles(guildId: string): { Types.RolePayload }?
	return self:Request("GET", routes.GET_GUILD_ROLES:format(guildId))
end

function APIInstance:GetGuildChannels(guildId: string): { Types.ChannelPayload }?
	return self:Request("GET", routes.GET_GUILD_CHANNELS:format(guildId))
end

function APIInstance:GetChannel(channelId: string): Types.ChannelPayload?
	return self:Request("GET", routes.GET_CHANNEL:format(channelId))
end

function APIInstance:GetMessage(channelId: string, messageId: string): Types.MessagePayload?
	return self:Request("GET", routes.GET_CHANNEL_MESSAGE_BY_ID:format(channelId, messageId))
end

function APIInstance:GetUser(userId: string): Types.UserPayload?
	return self:Request("GET", routes.GET_USER:format(userId))
end

function APIInstance:PostMessage(channelId: string, message: any): ()
	self:Request("POST", routes.POST_CHANNEL_MESSAGE:format(channelId), message)
end

return API
