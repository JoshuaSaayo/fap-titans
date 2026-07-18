extends Node

class DisposeBag:
	var _disposables: Array[Disposable] = []
	
	func add(disposable: Disposable):
		_disposables.append(disposable)
	
	func dispose():
		for disposable in _disposables:
			disposable.dispose()

class Disposable:
	var _dispose: Callable
	
	func _init(callable: Callable):
		_dispose = callable
	
	func dispose():
		_dispose.call();
	
	func addTo(bag: DisposeBag):
		bag.add(self)

class BehaviourSubject:
	var _signal: Signal
	var _value: Variant
	
	func _init(initialValue: Variant):
		_value = initialValue
		_signal = Signal(self, "signal")
		add_user_signal("signal")
	
	func listen(listener: Callable):
		_signal.connect(listener)
		listener.call(_value)
		return Disposable.new(func(): unlisten(listener))

	func unlisten(listener: Callable):
		_signal.disconnect(listener)
	
	func get_value():
		return _value
	
	func setValue(newValue: Variant):
		_value = newValue
		_signal.emit(newValue)

class ServerInfo:
	var name: String
	
	func _init(initialName: String):
		name = initialName
		
class LinkedDevice:
	var index: int
	var name: String
	
	func _init(initialIndex: int, initialName: String):
		index = initialIndex
		name = initialName

var isConnecting: BehaviourSubject
var isRequestingDeviceList: BehaviourSubject
var isTesting: BehaviourSubject
var connectedServer: BehaviourSubject
var connectedDevices: BehaviourSubject
var linkedDevices: BehaviourSubject
var did_call_devices_lambda: bool
var devices_labda: Callable
signal showError(message: String)

func _init():
	isConnecting = BehaviourSubject.new(false)
	isRequestingDeviceList = BehaviourSubject.new(false)
	isTesting = BehaviourSubject.new(false)
	connectedServer = BehaviourSubject.new(null)
	connectedDevices = BehaviourSubject.new([] as Array[GSDevice])
	linkedDevices = BehaviourSubject.new([] as Array[LinkedDevice])

func _ready():
	ProjectSettings.set_setting(GSConstants.PROJECT_SETTING_CLIENT_NAME, ProjectSettings.get_setting("application/config/name"))
	ProjectSettings.set_setting(GSConstants.PROJECT_SETTING_CLIENT_VERSION, ProjectSettings.get_setting("application/config/version"))
	
	GSClient.client_connection_changed.connect(
		func (isConnected: bool):
			if (isConnected):
				connectedServer.setValue(ServerInfo.new(GSClient.get_server_name()))
			else:
				connectedServer.setValue(null)
				connectedDevices.setValue([] as Array[GSDevice])
	)

func connect_server(host: String, port: int):
	isConnecting.setValue(true)
	await get_tree().create_timer(0.5).timeout
	
	GSClient.server_error.connect(on_server_error)
	
	var immediateError = GSClient.start(host, port, 10)
	if (immediateError != Error.OK):
		showError.emit("Failed to connect")
		isConnecting.setValue(false)
		return
	
	var connected = await GSClient.client_connection_changed
	GSClient.server_error.disconnect(on_server_error)
	isConnecting.setValue(false)
	if (!connected):
		showError.emit("Failed to connect")
	else:
		request_device_list()

func disconnect_server():
	GSClient.stop()

func request_device_list():
	isRequestingDeviceList.setValue(true)
	
	await get_tree().create_timer(0.5).timeout
	
	did_call_devices_lambda = false
	devices_labda = func (devices: Variant):
		if (did_call_devices_lambda):
			return
		
		did_call_devices_lambda = true
		GSClient.client_device_list_received.disconnect(devices_labda)
		
		if (devices == null):
			showError.emit("Failed to get devices list")
		else:
			connectedDevices.setValue(devices)
		
		isRequestingDeviceList.setValue(false)
	
	GSClient.client_device_list_received.connect(devices_labda)
	GSClient.request_device_list()
	await get_tree().create_timer(3.0).timeout
	devices_labda.call(null)

func on_server_error():
	showError.emit("Server error")

func link_device(device: GSDevice):
	var currentList: Array[LinkedDevice] = linkedDevices.get_value()
	if (currentList.any(
		func (linkedDevice: LinkedDevice):
			return linkedDevice.index == device.device_index
	)):
		return
	
	var newList = currentList.duplicate()
	newList.append(LinkedDevice.new(device.device_index, device.get_display_name()))
	linkedDevices.setValue(newList)
	
func unlink_device(device: LinkedDevice):
	var currentList: Array[LinkedDevice] = linkedDevices.get_value()
	var newList = currentList.filter(
		func (linkedDevice: LinkedDevice):
			return linkedDevice.index != device.index
	)
	linkedDevices.setValue(newList)

func test_device(linkedDevice: LinkedDevice):
	var device: GSDevice = GSClient.get_device(linkedDevice.index)
	if (!device):
		showError.emit("Device is not connected")
	
	isTesting.setValue(true)
	device.vibrate(1, 3)
	await get_tree().create_timer(3.0).timeout
	isTesting.setValue(false)
