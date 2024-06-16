--[[
Basic cache implementation for Retro.
]]

local API = require("../API")

type CacheMeta = {
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

local Cache = {}
local CacheInstance = {} :: CacheMeta
CacheInstance.__index = CacheInstance

function Cache.new()
	local self = setmetatable({
		_cache = {},
		_count = 0,
	}, CacheInstance) :: Cache

	return self
end

function CacheInstance:Get(key: string): any
	return self._cache[key]
end

function CacheInstance:Set(key: string, value: any): ()
	if self._cache[key] == nil then
		self._count += 1
	end
	self._cache[key] = value
end

function CacheInstance:Remove(key: string): ()
	if self._cache[key] ~= nil then
		self._cache[key] = nil
		self._count -= 1
	end
end

function CacheInstance:Count(): number
	return self._count
end

Cache.Role = Cache.new()
Cache.Member = Cache.new()
Cache.Guild = Cache.new()
Cache.User = Cache.new()
Cache.Channel = Cache.new()
Cache.Message = Cache.new()
Cache.API = nil :: API.API?

return Cache
