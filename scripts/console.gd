class_name ConsoleData
extends Resource

signal updated

class CellData:
	var chr: int
	var bg: Color
	var fg: Color
	func _init(_chr: int, _bg: Color, _fg: Color):
		self.chr = _chr
		self.bg = _bg
		self.fg = _fg

@export_storage var charbuffer: CharField2D
@export_storage var bgcolor_buffer: ColorField2D
@export_storage var fgcolor_buffer: ColorField2D

@export var size: Vector2i = Vector2i(0, 0)
@export var default_bg: Color
@export var default_fg: Color

func _init(width: int, height: int, _default_bg: Color, _default_fg: Color):
	self.size = Vector2i(width, height)
	self.default_bg = _default_bg
	self.default_fg = _default_fg
	self.charbuffer = CharField2D.new(width, height).default_value(ord(' '))
	self.charbuffer.update_size()
	
	self.bgcolor_buffer = ColorField2D.new(width, height).default_value(default_bg)
	self.bgcolor_buffer.update_size()

	self.fgcolor_buffer = ColorField2D.new(width, height).default_value(default_fg)
	self.fgcolor_buffer.update_size()

	self.charbuffer.updated.connect(updated.emit)
	self.bgcolor_buffer.updated.connect(updated.emit)
	self.fgcolor_buffer.updated.connect(updated.emit)

func clone():
	var data: ConsoleData = ConsoleData.new(
		size.x, size.y, default_bg, default_fg
	)
	data.charbuffer = self.charbuffer.clone()
	data.bgcolor_buffer = self.bgcolor_buffer.clone()
	data.fgcolor_buffer = self.fgcolor_buffer.clone()
	return data

func clear_top():
	self.charbuffer.clear_top()
	self.bgcolor_buffer.clear_top()
	self.fgcolor_buffer.clear_top()

func get_cell(x: int, y: int) -> CellData:
	return CellData.new(
		self.charbuffer.get_cell(x, y),
		self.bgcolor_buffer.get_cell(x, y),
		self.fgcolor_buffer.get_cell(x, y)
	)
