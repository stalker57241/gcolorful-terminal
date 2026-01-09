class_name Snake
extends ShellScript

signal update

var playing: bool = true
var timer: float = 0.125
var time = 0.0
var angle: float = 0.0

func init(_terminal: ColoredTerminal) -> ShellModule:
	return super(_terminal)

func _get_name() -> String:
	return "Snake"

func _run(_argv: Array[String]) -> int:
	terminal.next_line()
	var last_screen: ConsoleData = terminal.swap_buffers(null)
	terminal.cursor.is_blinking = false
	terminal.queue_redraw()
	# vvv CODE OF GAME vvv
	while playing:
		terminal.clear()
		terminal.set_cell(16 + roundi(cos(angle * 2) * 8), 16 + roundi(sin(angle * 2) * 8), Color.RED)
		terminal.queue_redraw()
		await update
	# ^^^ CODE OF GAME ^^^
	terminal.cursor.is_blinking = true
	terminal.queue_redraw()
	terminal.swap_buffers(last_screen)
	return 0

func _process(_delta: float):
	time += _delta
	angle += _delta
	if angle > TAU:
		angle -= TAU
	if time > timer:
		time = 0.0
		update.emit()

func _input(_event: InputEvent):
	if _event is InputEventKey:
		if _event.keycode == KEY_Q:
			playing = false
