extends Control

@onready var loading_overlay = %LoadingOverlay
@onready var loading_overlay_label = %LoadingOverlayLabel
@onready var host_line_edit: LineEdit = %HostLineEdit
@onready var port_line_edit: LineEdit = %PortLineEdit
@onready var connect_button = %ConnectButton
@onready var server_panel = %ServerPanel
@onready var server_name_label = %ServerNameLabel
@onready var available_devices_list = %AvailableDevicesList
@onready var linked_devices_list = %LinkedDevicesList
@onready var message_overlay = %MessageOverlay
@onready var message_label = %MessageLabel
@onready var test_button = %TestButton

var disposeBag: ToysManager.DisposeBag
var isConnecting: bool = false
var isRequestingDeviceList: bool = false
var isTesting: bool = false

signal onClosePress

func _ready():
	message_overlay.visible = false
	
	disposeBag = ToysManager.DisposeBag.new()
	
	ToysManager.isConnecting.listen(
		func (isToyManagerConnecting: bool):
			isConnecting = isToyManagerConnecting
			update_loading_overlay()
	).addTo(disposeBag)

	ToysManager.isRequestingDeviceList.listen(
		func (isToyManagerRequestingDeviceList: bool):
			isRequestingDeviceList = isToyManagerRequestingDeviceList
			update_loading_overlay()
	).addTo(disposeBag)

	ToysManager.isTesting.listen(
		func (isToyManagerTesting: bool):
			isTesting = isToyManagerTesting
			update_loading_overlay()
	).addTo(disposeBag)
	
	ToysManager.connectedServer.listen(
		func (connectedServer: ToysManager.ServerInfo):
			if (connectedServer == null):
				server_panel.visible = false
				host_line_edit.editable = true
				port_line_edit.editable = true
				connect_button.text = "Connect"
			else:
				server_panel.visible = true
				server_name_label.text = connectedServer.name
				host_line_edit.editable = false
				port_line_edit.editable = false
				connect_button.text = "Disconnect"
	).addTo(disposeBag)
	
	ToysManager.connectedDevices.listen(
		func (devices: Array[GSDevice]):
			available_devices_list.clear()
			for device in devices:
				available_devices_list.add_item("#%d %s" % [device.device_index, device.get_display_name()])
	).addTo(disposeBag)
	
	ToysManager.linkedDevices.listen(
		func (devices: Array[ToysManager.LinkedDevice]):
			linked_devices_list.clear()
			for device in devices:
				linked_devices_list.add_item("#%d %s" % [device.index, device.name])
	).addTo(disposeBag)
	
	ToysManager.showError.connect(show_error)

func _exit_tree():
	ToysManager.showError.disconnect(show_error)
	
	disposeBag.dispose()
	disposeBag = null
	
func show_error(message: String):
	message_label.text = message
	message_overlay.visible = true

func on_continue_press():
	message_overlay.visible = false

func update_loading_overlay():
	if (isConnecting):
		loading_overlay_label.text = "Connecting..."
		loading_overlay.visible = true
	elif (isRequestingDeviceList):
		loading_overlay_label.text = "Requesting device list..."
		loading_overlay.visible = true
	elif (isTesting):
		loading_overlay_label.text = "Sending vibes..."
		loading_overlay.visible = true
	else:
		loading_overlay.visible = false

func on_connect_press():
	connect_button.release_focus()
	if (ToysManager.connectedServer.get_value() == null):
		var host = host_line_edit.text.lstrip(" ").rstrip(" ")
		var port = port_line_edit.text.lstrip(" ").rstrip(" ")
		
		if (host.is_empty() || port.is_empty()):
			show_error("Host and port can't be empty")
			return
		
		ToysManager.connect_server(host, port.to_int())
	else:
		ToysManager.disconnect_server()

func on_link_press():
	var selectedIndices: PackedInt32Array = available_devices_list.get_selected_items()
	available_devices_list.deselect_all()
	for index in selectedIndices:
		ToysManager.link_device(ToysManager.connectedDevices.get_value()[index])

func on_unlink_press():
	var selectedIndices: PackedInt32Array = linked_devices_list.get_selected_items()
	linked_devices_list.deselect_all()
	for index in selectedIndices:
		ToysManager.unlink_device(ToysManager.linkedDevices.get_value()[index])

func on_test_press():
	test_button.release_focus()
	var selectedIndices: PackedInt32Array = linked_devices_list.get_selected_items()
	for index in selectedIndices:
		ToysManager.test_device(ToysManager.linkedDevices.get_value()[index])

func on_close_press():
	onClosePress.emit()
