local User = require("../Containers/User")
local Guild = require("../Containers/Guild")

export type Ready = {
	Version: number,
	User: User.User,
	Guilds: { Guild.Guild },
	SessionId: string,
	Shard: { id: number, total: number },
}

return {}
