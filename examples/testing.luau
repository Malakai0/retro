local fs = require("@lune/fs")

local retro = require("../src/init")
local client = retro.Client.new()

local token = fs.readFile("testing_token.txt")

client.Events.Ready:Connect(function(event: retro.Ready)
	print(`Successfully connected as {event.User:GetTag()}`)
end)

client.Events.MessageReceived:Connect(function(message: retro.Message)
	if message.User.Bot then
		return
	end

	if message.Content == "!ping" then
		message:Reply("Pong!")
	elseif message.Content == "!me" then
		message:Reply(`You are \`{message.User:GetTag()}\`, welcome to \`{message.Guild.Name}\`!`)
	end
end)

client:ConnectAsync(token, retro.Intents.All())
