--[[
    @: Represents a member of a guild
    @: https://discord.com/developers/docs/resources/guild#guild-member-object

    This is so that we can have an easy way to manage members in a guild
]]

local Cache = require("Cache")
local Interface = require("Interface")
local Types = require("Types")

type MemberMeta = Types.MemberMeta
type Member = Types.Member
type MemberPayload = Types.MemberPayload

local function keyed(guildId: string, memberId: string): string
	return `{guildId}-{memberId}`
end

local Member = {}
local MemberInstance = {} :: MemberMeta
MemberInstance.__index = MemberInstance

function Interface.GetMember(guildId: string, memberId: string): Member?
	local fromCache = Cache.Member:Get(keyed(guildId, memberId))
	if not fromCache and Cache.API then
		local member: Types.MemberPayload = Cache.API:GetGuildMember(guildId, memberId)
		return Interface.CreateMember(guildId, member)
	end
	return fromCache
end

function Interface.CreateMember(guildId: string, payload: MemberPayload): Member
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
		User = Interface.CreateUser(payload.user),
	}, MemberInstance) :: Member

	Cache.Member:Set(keyed(guildId, memberId), self)

	for _, roleId in payload.roles do
		table.insert(self.Roles, Interface.GetRole(guildId, roleId))
	end

	return self
end

return Member
