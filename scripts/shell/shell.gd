class_name Shell
extends ShellScript

signal entered

var input: String = ""
var write_end: Vector2i = Vector2i(0, 0)
var internal: InternalShell
var external: ExternalShell

func _run(_argv: Array[String]) -> int:
	internal = import("res://assets/internal.res")
	external = import("res://assets/external.res")
	while terminal.halt == false:
		input = ""
		prompt()
		write_end = terminal.cursor.position
		await entered
		print("Input: ", input)
		terminal.next_line()
		state.last_exit_code = await internal.try_run(input.split(" "))
		if state.last_exit_code != 0:
			state.last_exit_code = await external.try_whereis(input.split(" "))
		if state.last_exit_code != 0:
			terminal._print("No such command\nec")
	return 0

func _input(_event: InputEvent):
	if not _event is InputEventKey: return
	var keycode: Key = _event.keycode
	match keycode:
		KEY_ENTER, KEY_KP_ENTER:
			entered.emit()
		KEY_BACKSPACE when terminal.cursor.position.x > write_end.x and terminal.cursor.position.y == write_end.y:
			terminal.backspace()
			input = input.erase(input.length() - 1, 1)
		KEY_BACKSPACE when terminal.cursor.position.y > write_end.y:
			terminal.backspace()
			input = input.erase(input.length() - 1, 1)
		keycode when keycode >= 32 and keycode <= 126:
			var c = char(keycode).to_lower()
			terminal.write(ord(c))
			input += c
	
func prompt():
	if terminal.config.env.has("prompt"):
		terminal._print(terminal.config.env["prompt"].format(state))
	else:
		terminal._print("{path}{user} ".format(state))

func _get_name() -> String:
	return "Shell"

func _get_description() -> String:
	return "Basic shell"
