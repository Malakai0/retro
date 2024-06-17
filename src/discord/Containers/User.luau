--[[
    @: Represents a Discord user
    @: https://discord.com/developers/docs/resources/user#user-object
]]

local Cache = require("Cache")
local Interface = require("Interface")
local Types = require("Types")

type UserMeta = Types.UserMeta
type User = Types.User
type UserPayload = Types.UserPayload

local User = {}
local UserInstance = {} :: UserMeta
UserInstance.__index = UserInstance

function Interface.GetUser(userId: string, raw: boolean?): User?
	local fromCache = Cache.User:Get(userId)
	if not fromCache and Cache.API and not raw then
		local userPayload = Cache.API:GetUser(userId)
		if userPayload then
			return Interface.CreateUser(userPayload)
		end
	end
	return fromCache
end

function Interface.CreateUser(payload: UserPayload)
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
