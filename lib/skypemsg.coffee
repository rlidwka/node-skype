SkypeChat = require('./skypechat').SkypeChat

keys =
	time: "TIMESTAMP"
	from_id: "FROM_HANDLE"
	from_name: "FROM_DISPNAME"
	type: "TYPE"
	status: "STATUS"
	chatname: "CHATNAME"
	leavereason: "LEAVEREASON"
	users: "USERS"
	is_editable: "IS_EDITABLE"
	edited_by: "EDITED_BY"
	edited_time: "EDITED_TIMESTAMP"
	options: "OPTIONS"
	role: "ROLE"
	body: "BODY"

class SkypeMessage
	constructor: (skype, id) ->
		@__defineGetter__("id", => id )
		for prop, value of keys then do (prop, value) =>
			@__defineGetter__(prop, =>
				arg = skype.invoke("GET CHATMESSAGE #{id} #{value}")
				return undefined if arg == ''
				m = arg.match(/^CHATMESSAGE\s\S+\s\S+\s([\s\S]*)$/)
				return m[1] if m?
				throw new Error(arg)
			)
		@__defineGetter__('chat', => new SkypeChat(skype, @chatname))

	dump: ->
		res = "=== Message id: #{@id} ===\n"
		for prop, value of keys
			try
				res += "#{prop}: #{@[prop]}\n"
			catch err
				res += "! #{prop}: ERROR #{err}\n"
		res += "=========================="
		return res

module.exports.SkypeMessage = SkypeMessage

