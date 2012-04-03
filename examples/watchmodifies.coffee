Skype = require('../lib/skype').Skype

messages = []
skype = new Skype()
skype.on('message', (msg, arg) ->
	messages[msg.id] ?= msg.body
	if arg == 'EDITED_TIMESTAMP'
		console.log "====="
		console.log "Message from #{msg.from_name} modified by #{msg.edited_by}"
		console.log "Old: #{messages[msg.id]}"
		console.log "New: #{msg.body}"
)

skype.on('notify', (arg) ->
	console.log arg
)

