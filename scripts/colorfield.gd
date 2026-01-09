class_name ColorField2D
extends Field2D

@export_storage var field: Array[Color] = []
@export var default_color: Color = Color.BLACK

func _update_size() -> void:
	field.clear()
	field.resize(get_square())
	for i in range(get_square()):
		field[i] = _get_default_value()

func clear_top():
	if self.width <= 0: return
	
	for x in range(self.width):
		field.pop_front()
	for x in range(self.width):
		field.push_back(_get_default_value())
	updated.emit()

func default_value(value: Color) -> ColorField2D:
	self.default_color = value
	return self

func _get_default_value():
	return self.default_color

func _set_cell(x: int, y: int, value: Color) -> void:
	var index: int = get_index(x, y)
	if index > get_square() or x > width or y > height or x < 0 or y < 0:
		push_error("Index out of bounds")
		return
	field[index] = value

func _get_cell(x: int, y: int) -> Color:
	var index: int = get_index(x, y)
	if index >= get_square() or x > width or y > height or x < 0 or y < 0:
		return _get_default_value()
	if field.is_empty():
		return _get_default_value()
	return field[index]

func clone() -> ColorField2D:
	var dup: ColorField2D = ColorField2D.new(width, height)
	dup.field = self.field.duplicate(true)
	dup.default_color = self.default_color
	return dup
