@tool
class_name ColoredTerminal
extends RuntimeTerminal


func store_buffer() -> ConsoleData:
	return self.console.clone()

func set_cell(x: int, y: int, color: Color):
	self.console.bgcolor_buffer.set_cell(x, y, color)

func swap_buffers(buffer: ConsoleData) -> ConsoleData:
	var data: ConsoleData = self.store_buffer()
	clear()
	if buffer == null:
		if font_size == 0: return data
		char_size = font.get_char_size(ord(' '), font_size)
		canvas_size = Vector2i(self.get_rect().size) / char_size

		console = ConsoleData.new(canvas_size.x, canvas_size.y, Color.BLACK, Color.WHITE)
		
		console.updated.connect(self.queue_redraw)
	else:
		self.console = buffer
		
		self.console.updated.connect(self.queue_redraw)
	return data
