--[[
    @: Represents a role in a guild
    @: https://discord.com/developers/docs/topics/permissions#role-object
]]

local Cache = require("Cache")
local Interface = require("Interface")
local Types = require("Types")

type RoleMeta = Types.RoleMeta
type Role = Types.Role
type RolePayload = Types.RolePayload
type RoleTag = Types.RoleTag

local Role = {}
local RoleInstance = {} :: RoleMeta
RoleInstance.__index = RoleInstance

local function keyed(guildId: string, roleId: string): string
	return `{guildId}:{roleId}`
end

function Interface.GetRole(guildId: string, roleId: string, raw: boolean?): Role?
	local cacheKey = keyed(guildId, roleId)

	local fromCache = Cache.Role:Get(cacheKey)
	if not fromCache and Cache.API and not raw then
		local rolesPayload = Cache.API:GetGuildRoles(guildId)
		if not rolesPayload then
			return
		end
		for _, rolePayload in rolesPayload do
			Interface.CreateRole(guildId, rolePayload)
		end
		fromCache = Cache.Role:Get(cacheKey)
	end
	return fromCache
end

function Interface.CreateRole(guildId: string, payload: RolePayload): Role
	local roleTags: { RoleTag } = {}
	if payload.tags then
		for _, tag in payload.tags do
			table.insert(roleTags, {
				BotId = tag.bot_id,
				IntegrationId = tag.integration_id,
				PremiumSubscriber = tag.premium_subscriber,
			})
		end
	end

	local self = setmetatable({
		Id = payload.id,
		Guild = Interface.GetGuild(guildId),
		Name = payload.name,
		Color = payload.color,
		Hoist = payload.hoist,
		Position = payload.position,
		Permissions = payload.permissions,
		Managed = payload.managed,
		Mentionable = payload.mentionable,
		Tags = roleTags,
	}, RoleInstance) :: Role

	Cache.Role:Set(keyed(guildId, payload.id), self)

	return self
end

return Role
