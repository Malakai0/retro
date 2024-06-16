--[[
    @: Represents a Discord user
    @: https://discord.com/developers/docs/resources/user#user-object
]]

local Cache = require("Cache")

export type AvatarDecorationData = {
	Asset: string,
	SkuId: string,
}

type UserMeta = {
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

local User = {}
local UserInstance = {} :: UserMeta
UserInstance.__index = UserInstance

function User.get(userId: string, raw: boolean?): User?
	local fromCache = Cache.User:Get(userId)
	if not fromCache and Cache.API and not raw then
		local userPayload = Cache.API:GetUser(userId)
		if userPayload then
			return User.new(userPayload)
		end
	end
	return fromCache
end

function User.new(payload: UserPayload)
	local self = setmetatable({
		Id = payload.id,
		Username = payload.username,
		Discriminator = payload.discriminator,
		DisplayName = payload.global_name,
		Avatar = payload.avatar,
		Bot = payload.bot,
		System = payload.system,
		MfaEnabled = payload.mfa_enabled,
		Locale = payload.locale,
		Verified = payload.verified,
		Email = payload.email,
		Flags = payload.flags,
		PremiumType = payload.premium_type,
		PublicFlags = payload.public_flags,
		AvatarDecoration = payload.avatar_decoration_data,
	}, UserInstance) :: User

	Cache.User:Set(payload.id, self)

	return self
end

function UserInstance:GetAvatarURL(size: number?, format: string?): string
	size = size or 128
	format = format or "webp"

	local avatar = self.Avatar or "6debd47ed13483642cf09e832ed0bc1b"

	return ("https://cdn.discordapp.com/avatars/%s/%s.%s?size=%d"):format(
		self.Id,
		avatar,
		format :: string,
		size :: number
	)
end

function UserInstance:GetTag(): string
	if self.Bot then
		return `{self.Username}#{self.Discriminator}`
	else
		return `@{self.Username}`
	end
end

return User
