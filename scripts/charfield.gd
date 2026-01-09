class_name CharField2D
extends Field2D

@export_storage var field: Array[int] = []
@export_storage var default_char: int

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

func default_value(value: int) -> CharField2D:
	self.default_char = value
	return self

func _get_default_value():
	return self.default_char

func _set_cell(x: int, y: int, value: int) -> void:
	var index: int = get_index(x, y)
	if index >= get_square() or x > width or y > height or x < 0 or y < 0:
		# push_error("Index out of bounds")
		return
	field[index] = value

func _get_cell(x: int, y: int) -> int:
	var index: int = get_index(x, y)
	if index >= get_square() or x > width or y > height or x < 0 or y < 0:
		return _get_default_value()
	if field.is_empty():
		return _get_default_value()
	return field[index]

func clone() -> CharField2D:
	var dup = CharField2D.new(width, height)
	dup.field = self.field.duplicate()
	dup.default_char = self.default_char
	return dup
