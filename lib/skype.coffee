dbus = require("./dbus")
EventEmitter = require('events').EventEmitter
SkypeMessage = require('./skypemsg').SkypeMessage

set_status = (arg) ->
	@__defineGetter__ "status", ->
		@invoke("GET USERSTATUS").replace(/^USERSTATUS /i, '').trim()
	@__defineSetter__("status", (to) -> @invoke("SET USERSTATUS #{to}") )
	@emit 'status', arg if arg?

set_connect = (arg) ->
	@__defineGetter__ "connect", ->
		@invoke("GET CONNSTATUS").replace(/^CONNSTATUS /i, '').trim()
	@emit 'connect', arg if arg?

set_user = (arg) ->
	@__defineGetter__("", -> arg )

chatmessage = (arg) ->
	[id, prop, value] = arg.split(/\s+/)
	@emit 'message', new SkypeMessage(@, id), prop, value

Notifies =
	USERSTATUS: set_status
	CURRENTUSERHANDLE: set_user
	CONNSTATUS: set_connect
	CHATMESSAGE: chatmessage

notify = (arg) ->
	@emit 'notify', arg
	if m = arg.match(/^([A-Za-z0-9]+) +(.*)$/)
		if Notifies[name = m[1].toUpperCase()]?
			Notifies[name].call(@, m[2])

class Skype extends EventEmitter
	constructor: (@program = "Node.js") ->
		dbus.init()
		session = dbus.session_bus()
		iface = dbus.get_interface(session, "com.Skype.API", "/com/Skype", "com.Skype.API")
		@invoke = -> iface.Invoke.apply(iface, arguments)
		set_status.call(@)
		set_connect.call(@)
		set_user.call(@, '')

		dbus.start =>
			dbusRegister = new dbus.DBusRegister(dbus, session)
			dbus.requestName(session, 'com.Skype.API')
			
			dbusRegister.addMethods('/com/Skype/Client', 'com.Skype.API.Client',
				Notify: notify.bind(@)
			)
			dbusRegister.addMethods('/com/Skype/Client', 'org.freedesktop.DBus.Introspectable',
				Introspect: => """
<?xml version="1.0" encoding="UTF-8" ?>
<node name="/com/Skype/Client">
	<interface name="com.Skype.API.Client">
		<method name="Notify">
		</method>
	<interface name="org.freedesktop.DBus.Introspectable">
		<method name="Introspect">
		</method>
	</interface>
</node>
"""
			)
			dbus.runListener()

			if @invoke("NAME #{@program}") isnt 'OK'
				return @emit 'error', 'protocol error'
			if @invoke("PROTOCOL 7") isnt 'PROTOCOL 7'
				return @emit 'error', 'protocol error'
			@emit 'start'

	status: (value) ->
		@invoke("USERSTATUS ONLINE")

module.exports.Skype = Skype

