local Gateway = require("./Gateway")
local Events = require("./Events")
local API = require("./API")

local Cache = require("Containers/Cache")

type ClientMeta = {
	__index: ClientMeta,

	ConnectAsync: (self: Client, token: string, intents: number) -> (),
}

export type Client = typeof(setmetatable(
	{} :: {
		Gateway: Gateway.Gateway,
		Events: Events.Events,
		API: API.API?,

		Token: string?,
		Intents: number?,
	},
	{} :: ClientMeta
))

local Client = {}
local ClientInstance = {} :: ClientMeta
ClientInstance.__index = ClientInstance

function Client.new()
	local gateway = Gateway.new()
	local self = setmetatable({
		Gateway = gateway,
		Events = Events.new(gateway.Received),
	}, ClientInstance) :: Client

	return self
end

function ClientInstance:ConnectAsync(token: string, intents: number): ()
	self.Gateway:Open()
	self.Gateway.Closed:Connect(function()
		print(`Gateway closed with code: {self.Gateway.Socket.closeCode}`)
	end)

	local success, err = pcall(function()
		self.Gateway:Send({
			op = 2,
			d = {
				token = token,
				intents = intents,
				properties = {
					os = "linux",
					browser = "retro",
					device = "retro",
				},
			},
		})
	end)

	if not success then
		print(`Could not send identify payload: {err}`)
	end

	self.Token = token
	self.Intents = intents

	local clientAPI = API.new(token)

	self.API = clientAPI
	Cache.API = clientAPI
end

export type Ready = Events.Ready

return Client
