local net = require("@lune/net")
local task = require("@lune/task")
local serde = require("@lune/serde")

local Signal = require("../lib/Signal")

export type DiscordGatewayPayload = {
	op: number,
	d: any,
	s: number?,
	t: string?,
}

type GatewayMeta = {
	__index: GatewayMeta,

	Open: (self: Gateway) -> (),
	Close: (self: Gateway, closeCode: number?) -> (),
	Send: (self: Gateway, payload: DiscordGatewayPayload) -> (),
}

export type Gateway = typeof(setmetatable(
	{} :: {
		Socket: net.WebSocket?,

		Closed: Signal.Signal<()>,
		Received: Signal.Signal<DiscordGatewayPayload>,

		IsOpen: boolean,

		_sequenceNumber: number?,
	},
	{} :: GatewayMeta
))

local function sendHeartbeat(gateway: Gateway)
	gateway:Send({
		op = 1,
		d = gateway._sequenceNumber,
	})
end

local Gateway = {}
local GatewayInstance = {} :: GatewayMeta
GatewayInstance.__index = GatewayInstance

function Gateway.new()
	local self = setmetatable({
		Socket = nil,

		Closed = Signal.new(),
		Received = Signal.new(),

		IsOpen = false,

		_sequenceNumber = nil,
	}, GatewayInstance) :: Gateway

	return self
end

function GatewayInstance:Open()
	local socket: net.WebSocket?
	local success, err = pcall(function()
		socket = net.socket("wss://gateway.discord.gg/?v=10&encoding=json")
	end)

	if not success then
		error(`Could not connect to Discord Gateway: {err}`)
	end

	if not socket then
		error("Could not connect to Discord Gateway")
	end

	self.Socket = socket
	self.IsOpen = true

	local HEARTBEAT_INTERVAL = nil
	local LAST_HEARTBEAT = nil

	-- Handle incoming messages
	task.spawn(function()
		while true do
			local message = socket.next()
			if not message then
				self.IsOpen = false
				self.Closed:Fire()
				break
			end

			local data = serde.decode("json", message) :: DiscordGatewayPayload
			if data.op == 10 then -- HELLO
				HEARTBEAT_INTERVAL = data.d.heartbeat_interval / 1000
				LAST_HEARTBEAT = os.clock()
			elseif data.op == 1 then
				sendHeartbeat(self)
			elseif data.op == 0 then
				self._sequenceNumber = data.s
			end

			self.Received:Fire(data)
		end
	end)

	-- Heartbeat
	task.spawn(function()
		while true do
			if not self.IsOpen then
				break
			end

			if HEARTBEAT_INTERVAL and (os.clock() - LAST_HEARTBEAT > HEARTBEAT_INTERVAL) then
				sendHeartbeat(self)
				LAST_HEARTBEAT = os.clock()
			end

			task.wait()
		end
	end)
end

function GatewayInstance:Send(payload: DiscordGatewayPayload)
	local encoded = serde.encode("json", payload)
	self.Socket.send(encoded, true)
end

function GatewayInstance:Close(closeCode: number?)
	self.Socket.close(closeCode)
	self.IsOpen = false

	self.Closed:Fire()
end

return Gateway
