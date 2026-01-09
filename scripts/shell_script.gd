@abstract
class_name ShellScript
extends ShellModule

class State extends Object:
	signal bgcolor_changed(value: Color)
	signal fgcolor_changed(value: Color)
	@export_storage var path_stack: Array[String] = []
	@export var path: String:
		get:
			return "/%s" % ["/".join(self.path_stack)]
	@export_storage var user: String = "$"
	@export_storage var username: String:
		get: return OS.get_environment("USER")
	@export_storage var hostname: String:
		get: return OS.get_environment("HOST")
	@export_storage var last_exit_code: int = 0
	
	@export_storage var bgcolor: Color = Color.BLACK:
		set(value):
			if value == bgcolor: return
			bgcolor_changed.emit(value)
			bgcolor = value
	@export_storage var fgcolor: Color = Color.WHITE:
		set(value):
			if value == fgcolor: return
			fgcolor_changed.emit(value)
			fgcolor = value
	
	func _init():
		self.cd(["~"])
		self.username = OS.get_environment("USER")
	func cd(_path: Array[String]):
		self.path_stack = ShellScript.cd(self.path_stack, _path)
	
static func cd(_path_stack: Array[String], _path: Array[String]):
	var path_stack = _path_stack.duplicate()
	for elem in _path:
		match elem:
			".": continue
			"..": path_stack.pop_back()
			"~":
				path_stack.push_back("home")
				path_stack.push_back(OS.get_environment("USER"))
			elem when elem.contains("/"): path_stack = cd(path_stack, elem.split("/", false))
			elem: path_stack.push_back(elem)
	return path_stack

@export_storage var state: State = State.new()

func init(_terminal: ColoredTerminal) -> ShellModule:
	super(_terminal)
	self.state = State.new()
	self.state.bgcolor_changed.connect(
		terminal.console.bgcolor_buffer.default_value
	)
	self.state.fgcolor_changed.connect(
		terminal.console.fgcolor_buffer.default_value
	)
	return self

@abstract func _run(_argv: Array[String]) -> int

func run(_argv: Array[String]) -> int:
	terminal.input_catcher.push_back(self._input)
	terminal.process_catcher.push_back(self._process)
	var status: int = await _run(_argv)
	terminal.input_catcher.pop_back()
	terminal.process_catcher.pop_back()
	return status

## passes input
func _input(_event: InputEvent) -> void:
	return

func _process(_delta: float) -> void:
	return
func _runtime() -> bool:
	return true
