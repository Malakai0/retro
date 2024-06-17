local Signal = require("../../lib/Signal")
local Gateway = require("../Gateway")

local Types = require("../Containers/Types")
local Interface = require("../Containers/Interface")

local SharedType = require("SharedType")

type EventsMeta = {
	__index: EventsMeta,
}

export type Events = typeof(setmetatable(
	{} :: {
		Ready: Signal.Signal<SharedType.Ready>,
		GuildCreate: Signal.Signal<Types.Guild>,
		MessageReceived: Signal.Signal<Types.Message>,
	},
	{} :: EventsMeta
))

local Events = {}
local EventsInstance = {} :: EventsMeta
EventsInstance.__index = EventsInstance

function Events.new(messageSignal: Signal.Signal<Gateway.DiscordGatewayPayload>)
	local self = setmetatable({
		Ready = Signal.new(),
		GuildCreate = Signal.new(),
		MessageReceived = Signal.new(),
	}, EventsInstance) :: Events

	messageSignal:Connect(function(payload: Gateway.DiscordGatewayPayload)
		if payload.t == "READY" then
			local event = {
				Version = payload.d.v,
				SessionId = payload.d.session_id,
				Shard = payload.d.shard,
			} :: SharedType.Ready

			event.User = Interface.CreateUser(payload.d.user)
			event.Guilds = {}

			for _, guild in payload.d.guilds do
				table.insert(event.Guilds, Interface.CreateUnavailableGuild(guild))
			end

			self.Ready:Fire(event)
		elseif payload.t == "GUILD_CREATE" then
			local existingGuild = Interface.GetGuild(payload.d.id, true)
			if not existingGuild or existingGuild.Unavailable then
				existingGuild = Interface.CreateGuild(payload.d)
			end

			self.GuildCreate:Fire(existingGuild)
		elseif payload.t == "MESSAGE_CREATE" then
			local existingMessage = Interface.GetMessage(payload.d.channel_id, payload.d.id, true)
			if not existingMessage then
				existingMessage = Interface.CreateMessage(payload.d)
			end

			self.MessageReceived:Fire(existingMessage)
		end
	end)

	return self
end

export type Ready = SharedType.Ready

return Events
