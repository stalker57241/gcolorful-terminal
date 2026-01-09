@tool
@abstract
class_name Terminal
extends Control

@export_storage var console: ConsoleData
@export_storage var char_size: Vector2i
@export_storage var canvas_size: Vector2i

@export var font: Font:
	set(value):
		font = value
		queue_redraw()

@export var font_size: int:
	set(value):
		font_size = value
		queue_redraw()

func clear():
	self.console = ConsoleData.new(canvas_size.x, canvas_size.y, Color.BLACK, Color.WHITE)

func _ready():
	if font_size == 0: return
	char_size = font.get_char_size(ord(' '), font_size)
	canvas_size = Vector2i(self.get_rect().size) / char_size

	console = ConsoleData.new(canvas_size.x, canvas_size.y, Color.BLACK, Color.WHITE)

func _draw():
	if self.font == null: return
	for y in range(canvas_size.y):
		for x in range(canvas_size.x):
			var cell_data: ConsoleData.CellData = console.get_cell(x, y)
			draw_rect(Rect2i(char_size * Vector2i(x, y), char_size), cell_data.bg)
			draw_char(self.font,
				char_size * Vector2i(x, y) + Vector2i(0, font_size),
				char(cell_data.chr),
				font_size,
				cell_data.fg)
