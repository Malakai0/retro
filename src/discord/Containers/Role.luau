--[[
    @: Represents a role in a guild
    @: https://discord.com/developers/docs/topics/permissions#role-object
]]

local Cache = require("Cache")

type RoleMeta = {
	__index: RoleMeta,
}

export type Role = typeof(setmetatable(
	{} :: {
		Id: string,
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

local Role = {}
local RoleInstance = {} :: RoleMeta
RoleInstance.__index = RoleInstance

function Role.get(roleId: string): Role?
	return Cache.Role:Get(roleId)
end

function Role.new(payload: RolePayload)
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
		Name = payload.name,
		Color = payload.color,
		Hoist = payload.hoist,
		Position = payload.position,
		Permissions = payload.permissions,
		Managed = payload.managed,
		Mentionable = payload.mentionable,
		Tags = roleTags,
	}, RoleInstance) :: Role

	Cache.Role:Set(payload.id, self)

	return self
end

return Role
