local Signal = require("../../lib/Signal")
local Gateway = require("../Gateway")

local User = require("../Containers/User")
local Guild = require("../Containers/Guild")
local Message = require("../Containers/Message")

local SharedType = require("SharedType")

type EventsMeta = {
	__index: EventsMeta,
}

export type Events = typeof(setmetatable(
	{} :: {
		Ready: Signal.Signal<SharedType.Ready>,

		GuildCreate: Signal.Signal<Guild.Guild>,
		MessageReceived: Signal.Signal<Message.Message>,
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

			event.User = User.new(payload.d.user)
			event.Guilds = {}

			for _, guild in payload.d.guilds do
				table.insert(event.Guilds, Guild.newUnavailable(guild))
			end

			self.Ready:Fire(event)
		elseif payload.t == "GUILD_CREATE" then
			local existingGuild = Guild.get(payload.d.id)
			if not existingGuild or existingGuild.Unavailable then
				existingGuild = Guild.new(payload.d)
			end

			self.GuildCreate:Fire(existingGuild)
		elseif payload.t == "MESSAGE_CREATE" then
			local existingMessage = Message.get(payload.d.channel_id, payload.d.id, true)
			if not existingMessage then
				existingMessage = Message.new(payload.d)
			end

			self.MessageReceived:Fire(existingMessage)
		end
	end)

	return self
end

export type Ready = SharedType.Ready

return Events
