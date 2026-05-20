## UI element with selection, visual feedback, and controller/keyboard navigation support
@tool
extends SmoothUI
class_name SelectableUI

static var focused_element : SelectableUI = null

var _visual_tween : Tween
var _area : Area2D = null
var _collision_shape_node : CollisionShape2D = null

@export_group("Controller & Selection")
@export var is_selected : bool = false: ## Whether this element is currently highlighted/selected.
	set(val):
		if val == true and is_hidden: return
		if is_selected == val: return
		is_selected = val

		if is_selected:
			if focused_element and focused_element != self:
				focused_element.is_selected = false
			focused_element = self
		else:
			_on_deselected()
			if focused_element == self:
				focused_element = null

		_handle_selection_visuals()

@export var selected_scale : float = 1.1 ## Scale multiplier applied when this element is selected
@export var selected_color : Color = Color(1.2, 1.2, 1.2, 1.0) ## Color tint applied when this element is selected
@export var lerp_time : float = 0.15 ## Duration in seconds for selection scale and color transitions

func _ready() -> void:
	super._ready()
	add_to_group("selectable_ui")
	if not Engine.is_editor_hint():
		_area2D_creation()

func _get_collision_size() -> Vector2: ## Returns the collision rect size; override in subclasses to use a custom size
	return SpriteHelper.get_size(self)

func _area2D_creation() -> void:
	_area = Area2D.new()
	_area.input_pickable = true
	add_child(_area)
	_collision_shape_node = CollisionShape2D.new()
	_area.add_child(_collision_shape_node)
	var rect := RectangleShape2D.new()
	rect.size = _get_collision_size()
	_collision_shape_node.shape = rect
	_area.input_event.connect(_on_area_2d_input_event)
	_area.mouse_exited.connect(func(): if not is_hidden: is_selected = false)
	_area.mouse_entered.connect(func(): if not is_hidden: is_selected = true)

func _update_collision_size() -> void:
	if _collision_shape_node and _collision_shape_node.shape is RectangleShape2D:
		(_collision_shape_node.shape as RectangleShape2D).size = _get_collision_size()

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_on_accept_pressed()
		else:
			_on_accept_released()

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint(): return
	if focused_element == null: _check_for_initial_navigation()
	if is_selected and not is_hidden: _handle_controller_input()

func _handle_selection_visuals() -> void: ## Tweens scale and self_modulate to their selected/unselected targets; override to add extra visuals
	if _visual_tween: _visual_tween.kill()
	_visual_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var target_scale_val := selected_scale if is_selected else 1.0
	_visual_tween.tween_property(self, "scale", Vector2.ONE * target_scale_val, lerp_time)
	_visual_tween.tween_property(self, "self_modulate", selected_color if is_selected else Color.WHITE, lerp_time)

func _on_deselected() -> void:
	pass

func _on_accept_pressed() -> void:
	pass

func _on_accept_released() -> void:
	pass

func _handle_controller_input() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_on_accept_pressed()
	if Input.is_action_just_released("ui_accept"):
		_on_accept_released()
	var d_pad_dir := _get_dpad_direction()
	if d_pad_dir != Vector2.ZERO:
		_navigate_to_closest(d_pad_dir)
		get_viewport().set_input_as_handled()

func _get_dpad_direction() -> Vector2:
	if Input.is_action_just_pressed("ui_up"): return Vector2.UP
	elif Input.is_action_just_pressed("ui_down"): return Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"): return Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"): return Vector2.RIGHT
	return Vector2.ZERO

func _check_for_initial_navigation() -> void:
	if _get_dpad_direction() != Vector2.ZERO:
		for e in get_tree().get_nodes_in_group("selectable_ui"):
			if e is SelectableUI and not e.is_hidden:
				e.is_selected = true
				return

func _navigate_to_closest(dir: Vector2) -> void: ## Finds and selects the nearest SelectableUI in the given d-pad direction
	var best_candidate : SelectableUI = null
	var min_score := INF

	for e in get_tree().get_nodes_in_group("selectable_ui"):
		if e == self or not e is SelectableUI or e.is_hidden:
			continue

		var selectable := e as SelectableUI
		var vector_to_next := selectable.original_position - self.original_position
		var distance := vector_to_next.length()
		if distance < 0.1: continue

		var dot := vector_to_next.normalized().dot(dir)
		if dot > 0.5:
			var score := distance + ((1.0 - dot) * 10000.0)
			if score < min_score:
				min_score = score
				best_candidate = e

	if best_candidate:
		call_deferred("_change_selection", best_candidate)
		get_viewport().set_input_as_handled()

func _change_selection(target: SelectableUI) -> void:
	self.is_selected = false
	target.is_selected = true
