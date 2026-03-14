extends CanvasLayer

const WORLD_FOREST = preload("uid://yubh30707eb7")

@export_category("Multiplayer Peers")
@export var current_peer: Network.PEERS

@onready var select_peer: OptionButton = %SelectPeer
@onready var line_edit_session: LineEdit = %LineEditSession
@onready var line_edit_username: LineEdit = %LineEditUsername
@onready var button_join: Button = %ButtonJoin
@onready var button_host: Button = %ButtonHost
@onready var button_quit: Button = %ButtonQuit
@onready var label_error: Label = %LabelError
@onready var all_peers: VBoxContainer = %AllPeers
@onready var label_sessionid: Label = %LabelSessionid
@onready var label_username: Label = %LabelUsername

func _ready() -> void:
	if current_peer == Network.PEERS.None:
		all_peers.hide()
	else:
		on_peer_selected(current_peer)

	select_peer.item_selected.connect(on_peer_selected)
	for peer_option in Network.PEERS.keys():
		select_peer.add_item(peer_option)

	line_edit_session.text_changed.connect(update_session)
	line_edit_username.text_changed.connect(update_username)
	
	button_join.pressed.connect(on_join)
	button_host.pressed.connect(on_host)
	button_quit.pressed.connect(func(): get_tree().quit())

	Network.signal_error_raised.connect(on_error)
	label_error.hide()

	set_theme()


func on_host():
	Network.host()
	add_world()

func on_join():
	multiplayer.connected_to_server.connect(add_world)
	Network.join(line_edit_session.text)

func add_world():
	var new_world = WORLD_FOREST.instantiate()
	get_tree().current_scene.add_child(new_world)
	hide()

func update_session(new_text: String):
	if new_text != "":
		button_join.disabled = false

func update_username(new_text: String):
	Global.username = new_text

func on_error():
	if multiplayer.connected_to_server.is_connected(add_world):
		multiplayer.connected_to_server.disconnect(add_world)
	line_edit_session.text_changed.emit("")
	label_error.show()

func on_peer_selected(item_index): 
	all_peers.show()
	Network.set_peer(item_index)
	match item_index:
		Network.PEERS.EnetLocal:
			label_sessionid.hide()
			line_edit_session.text = Network.IP_ADDRESS
		Network.PEERS.EnetRelay:
			label_sessionid.hide()
			line_edit_session.text = Network.IP_ADDRESS
		_: 
			label_sessionid.show()

func set_theme():
	button_host.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button_join.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button_quit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var host_style_box := StyleBoxFlat.new()
	host_style_box.bg_color = Color.WEB_GREEN
	button_host.add_theme_stylebox_override("normal", host_style_box)

	var join_style_box := StyleBoxFlat.new()
	join_style_box.bg_color = Color.DARK_MAGENTA
	button_join.add_theme_stylebox_override("normal", join_style_box)
