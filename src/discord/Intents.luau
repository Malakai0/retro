local Intents = {
	GUILDS = bit32.lshift(1, 0),
	GUILD_MEMBERS = bit32.lshift(1, 1),
	GUILD_MODERATION = bit32.lshift(1, 2),
	GUILD_EMOJIS_AND_STICKERS = bit32.lshift(1, 3),
	GUILD_INTEGRATIONS = bit32.lshift(1, 4),
	GUILD_WEBHOOKS = bit32.lshift(1, 5),
	GUILD_INVITES = bit32.lshift(1, 6),
	GUILD_VOICE_STATES = bit32.lshift(1, 7),
	GUILD_PRESENCES = bit32.lshift(1, 8),
	GUILD_MESSAGES = bit32.lshift(1, 9),
	GUILD_MESSAGE_REACTIONS = bit32.lshift(1, 10),
	GUILD_MESSAGE_TYPING = bit32.lshift(1, 11),
	DIRECT_MESSAGES = bit32.lshift(1, 12),
	DIRECT_MESSAGE_REACTIONS = bit32.lshift(1, 13),
	DIRECT_MESSAGE_TYPING = bit32.lshift(1, 14),
	MESSAGE_CONTENT = bit32.lshift(1, 15),
	GUILD_SCHEDULED_EVENTS = bit32.lshift(1, 16),
	AUTO_MODERATION_CONFIGURATION = bit32.lshift(1, 20),
	AUTO_MODERATION_EXECUTION = bit32.lshift(1, 21),
	GUILD_MESSAGE_POLLS = bit32.lshift(1, 24),
	DIRECT_MESSAGE_POLLS = bit32.lshift(1, 25),
}

function Intents.Build(...)
	local intents = 0
	for _, intent: number in { ... } do
		intents = bit32.bor(intents, intent)
	end
	return intents
end

function Intents.All()
	return Intents.Build(
		Intents.GUILDS,
		Intents.GUILD_MEMBERS,
		Intents.GUILD_MODERATION,
		Intents.GUILD_EMOJIS_AND_STICKERS,
		Intents.GUILD_INTEGRATIONS,
		Intents.GUILD_WEBHOOKS,
		Intents.GUILD_INVITES,
		Intents.GUILD_VOICE_STATES,
		Intents.GUILD_PRESENCES,
		Intents.GUILD_MESSAGES,
		Intents.GUILD_MESSAGE_REACTIONS,
		Intents.GUILD_MESSAGE_TYPING,
		Intents.DIRECT_MESSAGES,
		Intents.DIRECT_MESSAGE_REACTIONS,
		Intents.DIRECT_MESSAGE_TYPING,
		Intents.MESSAGE_CONTENT,
		Intents.GUILD_SCHEDULED_EVENTS,
		Intents.AUTO_MODERATION_CONFIGURATION,
		Intents.AUTO_MODERATION_EXECUTION,
		Intents.GUILD_MESSAGE_POLLS,
		Intents.DIRECT_MESSAGE_POLLS
	)
end

function Intents.None()
	return 0
end

return Intents
