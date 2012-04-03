Skype = require('../lib/skype').Skype
log = new(require('bunyan'))({name: 'skype'})

log.info('ssssssss')
skype = new Skype()
skype.on('message', (msg) ->
#	console.log(msg.dump())
#	console.log(msg.chat.dump())
	setTimeout("", 1000)
)

