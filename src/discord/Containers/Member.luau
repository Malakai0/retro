--[[
    @: Represents a member of a guild
    @: https://discord.com/developers/docs/resources/guild#guild-member-object

    This is so that we can have an easy way to manage members in a guild
]]

local Cache = require("Cache")

local User = require("User")
local Role = require("Role")

type MemberMeta = {
	__index: MemberMeta,
}

export type Member = typeof(setmetatable(
	{} :: {
		Id: string,
		GuildId: string,
		Nickname: string?,
		Roles: { Role.Role },
		JoinedAt: string,
		PremiumSince: string?,
		Deaf: boolean,
		Mute: boolean,
		Flags: number?,
		Pending: boolean,
		Permissions: string,
		User: User.User,
	},
	{} :: MemberMeta
))

export type MemberPayload = {
	user: User.UserPayload,
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

local function keyed(guildId: string, memberId: string): string
	return `{guildId}-{memberId}`
end

local Member = {}
local MemberInstance = {} :: MemberMeta
MemberInstance.__index = MemberInstance

function Member.get(guildId: string, memberId: string): Member?
	local fromCache = Cache.Member:Get(keyed(guildId, memberId))
	if not fromCache and Cache.API then
		local member = Cache.API:GetGuildMember(guildId, memberId)
		return Member.new(guildId, member)
	end
	return fromCache
end

function Member.new(guildId: string, payload: MemberPayload): Member
	local memberId = payload.user.id

	local self = setmetatable({
		Id = payload.user.id,
		GuildId = guildId,
		Nickname = payload.nick,
		Roles = {},
		JoinedAt = payload.joined_at,
		PremiumSince = payload.premium_since,
		Deaf = payload.deaf,
		Mute = payload.mute,
		Flags = payload.flags,
		Pending = payload.pending,
		Permissions = payload.permissions,
		User = User.new(payload.user),
	}, MemberInstance) :: Member

	for _, roleId in payload.roles do
		local role = Cache.Role:Get(roleId)
		if role then
			table.insert(self.Roles, role)
		else
			print(`Role {roleId} not found in cache`)
		end
	end

	Cache.Member:Set(keyed(guildId, memberId), self)

	return self
end

return Member
