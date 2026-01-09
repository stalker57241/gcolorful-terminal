class_name InternalShell
extends ShellModule

func _get_name() -> String:
	return "InternalShell"

func show_help(_cmd: String, brief: bool = false) -> int:
	match [_cmd, brief]:
		["exit", true]:
			terminal._print("Command to close terminal\n")
		["exit", false]:
			terminal._print("Command to close terminal\n")
	return 0

func exit(_argv: Array[String]) -> int:
	if terminal == null: return 1
	if _argv.has("--help") or _argv.has("-h"):
		return show_help("exit", _argv.has("--brief"))
	terminal.halt = true
	return 0

func dir(_argv: Array[String]) -> int:
	var path: String
	var tabsize = terminal.config.tab_size
	if _argv.size() > 0:
		path = _argv[_argv.size() - 1]
	else:
		path = "."
	path = "/%s" % ["/".join(ShellScript.cd(terminal.shell.state.path_stack, path.split("/", false)))]
	if _argv.has("--help") or _argv.has("-h"):
		return show_help("ls", _argv.has("--brief"))
	if not DirAccess.dir_exists_absolute(path):
		terminal._print("No such file or directory\n")
		return 1
	
	var files: Array = Array(DirAccess.get_files_at(path))
	var dirs: Array = Array(DirAccess.get_directories_at(path)).map(
		func (x: String): return "%s/" % x
	)
	var content: Array = [".", ".."]
	content.append_array(dirs.duplicate())
	content.append_array(files.duplicate())
	
	var sz = content.map(func(x: String): return x.length()).max()
	print("SZ: %d" % [sz])
	var newtabsize = (sz / tabsize + 1) * tabsize
	terminal.config.tab_size = newtabsize
	var idx = 0
	
	for element in content:
		idx += 1
		if terminal.cursor.position.x + element.length() > terminal.canvas_size.x:
			terminal.next_line()
		terminal._print("%s" % [element])
		if idx == content.size() - 1: break
		terminal.write(ord('\t'))
	
	terminal.next_line()
	terminal.config.tab_size = tabsize
	return 0

func clear(_argv: Array[String]) -> int:
	if _argv.has("--help") or _argv.has("-h"):
		return show_help("clear", _argv.has("--brief"))
	terminal.clear()
	return 0

func pwd(_argv: Array[String]) -> int:
	if _argv.has("--help") or _argv.has("-h"):
		return show_help("pwd", _argv.has("--brief"))
	terminal._print("%s\n" % terminal.shell.state.path)
	return 0

func cd(_argv: Array[String]) -> int:
	var path = _argv[_argv.size() - 1]
	var splitted = path.split("/")
	if _argv.has("--help") or _argv.has("-h"):
		return show_help("cd", _argv.has("--brief"))
	terminal.shell.state.cd(splitted)
	return 0

func echo(_argv: Array[String]) -> int:
	var msg = " ".join(_argv)
	terminal._print("%s\n" % msg)
	return 0

func try_run(_argv: Array[String]):
	var command = _argv.pop_front()
	
	match command:
		"exit", "quit": return exit(_argv)
		"dir", "ls": return dir(_argv)
		"cls", "clear": return clear(_argv)
		"pwd", "cd" when _argv.size() == 0: return pwd(_argv)
		"cd": return cd(_argv)
		"echo": return echo(_argv)
	return 1
