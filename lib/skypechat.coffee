
keys =
	name: 'NAME'
	time: 'TIMESTAMP'
	adder: 'ADDER'
	status: 'STATUS'
	posters: 'POSTERS'
	members: 'MEMBERS'
	topic: 'TOPIC'
	topicxml: 'TOPICXML'
	msgs: 'CHATMESSAGES'
	activemembers: 'ACTIVEMEMBERS'
	friendlyname: 'FRIENDLYNAME'
	recentmsgs: 'RECENTCHATMESSAGES'
	bookmarked: 'BOOKMARKED'
	memobj: 'MEMBEROBJECTS'

class SkypeChat
	constructor: (skype, id) ->
		@__defineGetter__("id", => id )
		for prop, value of keys then do (prop, value) =>
			@__defineGetter__(prop, =>
				arg = skype.invoke("GET CHAT #{id} #{value}")
				return undefined if arg == ''
				m = arg.match(/^CHAT\s\S+\s\S+\s([\s\S]*)$/)
				return m[1] if m?
				throw new Error(arg)
			)

	dump: ->
		res = "=== Chat id: #{@id} ===\n"
		for prop, value of keys
			try
				res += "#{prop}: #{@[prop]}\n"
			catch err
				res += "! #{prop}: ERROR #{err}\n"
		res += "=========================="
		return res

module.exports.SkypeChat = SkypeChat

