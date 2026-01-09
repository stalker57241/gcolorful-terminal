class_name TerminalConfig
extends Resource


#@export var 
@export var path_delimeter: String = ';'
@export var env: Dictionary[StringName, String] = {
	"path": "",
	"prompt": "> "
}
@export var tab_size: int = 4
@export_file_path("*.res", "*.tres") var shell: String

static func default() -> TerminalConfig:
	var config: TerminalConfig = TerminalConfig.new()
	config.prompt = "$ "
	config.env["path"] = ""
	config.tab_size = 4
	config.shell = "res://assets/shell.res"
	return config
