extends Node2D

var hit: bool
var data: Dictionary

func _ready():
	Events.update_notespeed.connect(update_position)

func setup(note_data):
	data = note_data
	update_visual()
	update_position()

func update_position():
	position.x = -(data['timestamp'] * Global.note_speed)
	
func _process(_delta):
	visible = global_position.x >= Global.note_culling_bounds.x and global_position.x < Global.note_culling_bounds.y
	
	if global_position.x >= 960 and !hit:
		Events.emit_signal('hit_note', data)
		hit = true
	elif global_position.x < 960 and hit:
		hit = false
		
func update_visual():
	$Voice.visible = data.has('trigger_voice')
	if Clipboard.selected_notes.has(self):
		$Visual.self_modulate = Color.ANTIQUE_WHITE
	else:
		$Visual.self_modulate = Global.note_colors[data['input_type']]
	

func _on_input_handler_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if Global.current_tool == Enums.TOOL.SELECT:
						set_selected()
				MOUSE_BUTTON_MIDDLE:
					if data.has('trigger_voice'):
						data.erase('trigger_voice')
					else:
						data['trigger_voice'] = true
					print(data)
					update_visual()
				MOUSE_BUTTON_RIGHT:
					if Global.current_tool == Enums.TOOL.SELECT:
						Timeline.delete_note(self, Global.current_chart.find(data))

func set_selected():
	if Clipboard.selected_notes.has(self):
		Clipboard.selected_notes.erase(self)
	else:
		Clipboard.selected_notes.append(self)			
	update_visual()
	
	print(Clipboard.selected_notes)
	
