
module.exports = function(_dbus, _bus) {
	var self = this;
	var dbus = _dbus;
	var bus = _bus;
	var registerObject = {};

	var InternalEventDispatcher = function(interface, member, args) {
		for (var path in registerObject) {
			if (!(interface in registerObject[path]))
				continue;

			if (member in registerObject[path][interface]['Methods']) {
				return registerObject[path][interface]['Methods'][member].call(this, args);
			}
		}
	};

	this.createObjectPath = function(path) {
		/* Initializing */
		if (!(path in registerObject)) {
			registerObject[path] = {};

			/* Register a new object */
			dbus.registerObjectPath(bus, path, InternalEventDispatcher);
		}
	};

	this.createInterface = function(path, interface) {
		self.createObjectPath(path);

		if (!(interface in registerObject[path])) {
			registerObject[path][interface] = {
				Methods: {},
				Properties: {},
				Signals: {}
			};
		}
	};

	this.addMethod = function(path, interface, method, handler) {
		self.createInterface(path, interface);

		registerObject[path][interface]['Methods'][method] = handler;
	};

	this.addMethods = function(path, interface, methods) {
		for (var key in methods) {
			self.addMethod(path, interface, key, methods[key]);
		}
	};

  this.emitSignal = function(path, interface, signal, args) {
    dbus.emitSignal(bus, path, interface, signal, args);
  }
}
