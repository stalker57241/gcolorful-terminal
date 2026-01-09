@tool
class_name RuntimeTerminal
extends Terminal

signal newline

@export var config: TerminalConfig = null
var halt: bool = false

var input_catcher: Array[Callable] = []
var process_catcher: Array[Callable] = []

class Cursor:
	signal blinks
	
	@export var position: Vector2i = Vector2i(0, 0)
	@export_storage var blink_state: bool = false
	@export var is_blinking: bool = true
	@export var blink_timeout: float = 0.25
	@export_storage var blink_timer: float = 0.0
	
	func get_blink() -> bool:
		return blink_state
	
	func blink():
		self.blink_state = !blink_state

	func _process(_delta: float):
		if is_blinking:
			blink_timer += _delta
			if blink_timer >= blink_timeout:
				blink_timer = 0.0
				self.blink()
				blinks.emit()

var cursor: Cursor = Cursor.new()

var shell: ShellScript = null

func _ready():
	super()
	self.cursor.blinks.connect(self.queue_redraw)
	self.console.updated.connect(self.queue_redraw)
	print(config.shell)
	self.shell = load(config.shell) as ShellScript
	if not shell is ShellScript: return
	self.shell.init(self)
	var status = await self.shell.run([config.shell])
	
	get_tree().quit(status)

func clear():
	super()
	self.cursor.position = Vector2(0, 0)

func _process(_delta: float):
	cursor._process(_delta)
	if process_catcher.size() > 0:
		(process_catcher[process_catcher.size() - 1]).call(_delta)

func _input(event: InputEvent):
	if event.is_pressed():
		if input_catcher.size() > 0:
			(input_catcher[input_catcher.size() - 1]).call(event)

func write(symbol: int):
	match char(symbol):
		'\t':
			tab()
		'\r':
			self.cursor.position.x = 0
		'\n': next_line()
		_ when symbol >= 32 and symbol <= 126: write_visible(symbol)

func tab():
	write_visible(ord(' '))
	while self.cursor.position.x % config.tab_size > 0:
		write_visible(ord(' '))

func backspace():
	if self.cursor.position.x == 0:
		self.cursor.position.x = self.console.charfield.width 
		if self.cursor.position.y > 0:
			self.cursor.position.y -= 1
	self.cursor.position.x -= 1
	write_visible(ord(' '), false)

func next_line():
	self.cursor.position.x = 0
	if self.cursor.position.y + 1 >= self.canvas_size.y:
		self.console.clear_top()
	else:
		self.cursor.position.y += 1
		#self.cursor.position.y -= 1
	newline.emit()

func get_env() -> Dictionary[StringName, String]:
	return self.config.env

func write_visible(symbol: int, move_caret: bool = true):
	self.console.charbuffer.set_cell(self.cursor.position.x, self.cursor.position.y, symbol)
	if move_caret:
		self.cursor.position.x += 1
		if self.cursor.position.x > self.canvas_size.x:
			next_line()

func _print(line: String):
	for c in line:
		write(ord(c))

func _draw():
	super()

	if cursor.get_blink() and cursor.is_blinking:
		var pos = cursor.position
		var cell_data = console.get_cell(pos.x, pos.y)
		draw_rect(Rect2i(pos * self.char_size, self.char_size), cell_data.fg)
