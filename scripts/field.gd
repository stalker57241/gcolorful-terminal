@abstract
class_name Field2D
extends Resource

signal updated

@export var width: int = 0
@export var height: int = 0

func _init(w: int, h: int):
	width = w
	height = h
	update_size()

@abstract func clone() -> Field2D

func get_size() -> Vector2i:
	return Vector2i(width, height)

func get_square():
	return width * height

func get_index(x: int, y: int) -> int:
	return x + y * width

@abstract func _update_size() -> void

@abstract func _get_default_value()
@abstract func _set_cell(x: int, y: int, value) -> void
@abstract func _get_cell(x: int, y: int)

func update_size() -> void:
	self._update_size()
	updated.emit()

func set_cell(x: int, y: int, value) -> void:
	self._set_cell(x, y, value)
	updated.emit()

func get_cell(x: int, y: int):
	return self._get_cell(x, y)
