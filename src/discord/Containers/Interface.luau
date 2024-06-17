--[[
    The "Interface" will be the main container of all our other Containers!
    Due to limitations of the current Luau implementation, we can't have circular dependencies.
    This means that we can't have a Container that depends on another Container that depends on the first Container (which would be nice for Channel->Guild but Guild->Channel).

    Each container will implement their own Interface function.
]]

local Types = require("Types")

type Interface = {
	GetGuild: (guildId: string, raw: boolean?) -> Types.Guild?,
	GetChannel: (channelId: string, raw: boolean?) -> Types.Channel?,
	GetMember: (guildId: string, memberId: string, raw: boolean?) -> Types.Member?,
	GetMessage: (channelId: string, messageId: string, raw: boolean?) -> Types.Message?,
	GetUser: (userId: string, raw: boolean?) -> Types.User?,
	GetRole: (guildId: string, roleId: string, raw: boolean?) -> Types.Role?,

	CreateGuild: (payload: Types.GuildPayload) -> Types.Guild,
	CreateUnavailableGuild: (payload: Types.UnavailableGuildPayload) -> Types.Guild,

	CreateChannel: (payload: Types.ChannelPayload) -> Types.Channel,
	CreateMember: (guildId: string, payload: Types.MemberPayload) -> Types.Member,
	CreateMessage: (payload: Types.MessagePayload) -> Types.Message,
	CreateUser: (payload: Types.UserPayload) -> Types.User,
	CreateRole: (guildId: string, payload: Types.RolePayload) -> Types.Role,
}

return {} :: Interface
