@abstract
class_name ShellModule
extends Resource

var terminal: ColoredTerminal
@export var dependencies: Array[ShellModule] = []
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var name: String:
	get: return _get_name()
@export_custom(PROPERTY_HINT_MULTILINE_TEXT, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var description: String:
	get: return _get_description()

func init(_terminal: ColoredTerminal) -> ShellModule:
	self.terminal = _terminal
	return self


class Version:
	var major: int
	var minor: int
	var patch: int
	
	func _init(_major: int = 0, _minor: int = 0, _patch: int = 0):
		self.major = _major
		self.minor = _minor
		self.patch = _patch

func import(path: String) -> ShellModule:
	var object = load(path)
	if object is ShellModule:
		if not object._get_dependencies().is_empty():
			object.dependencies = object.import_dependencies()
		return object.init(self.terminal)
	return null

func import_dependencies() -> Array[ShellModule]:
	var modules: Array[ShellModule] = []
	for dep in _get_dependencies():
		var module = import(dep)
		if module == null: continue
		modules.push_back(module)
	return modules

## Returns name of module
@abstract func _get_name() -> String
func get_name_() -> String:
	return _get_name()

## Returns description of module
func _get_description() -> String:
	return ""
	
## Returns version of module
func _get_version() -> Version:
	return Version.new(1, 0, 0)

## Returns dependencies
func _get_dependencies() -> PackedStringArray:
	return []

## Returns true if script is runtime
func _runtime() -> bool:
	return false
