class_name ExternalShell
extends ShellModule

func _get_name() -> String:
	return "ExternalShell"

func try_whereis(_argv: Array[String]) -> int:
	if _argv.size() == 0: return 0
	var paths: Array = Array(
		terminal.config.env["path"].split(terminal.config.path_delimeter))
	paths.append(".")
	var exec = _argv[0]
	for path in paths:
		var file = "%s/%s" % [path.trim_suffix("/"), exec]
		if FileAccess.file_exists(file):
			var module = import(file)
			if module is ShellScript:
				if module._runtime():
					return await module.run(_argv)
			return 0
	return 1
