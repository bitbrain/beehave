#!/usr/bin/env -S godot -s
@tool
extends SceneTree

const CmdConsole = preload("res://addons/gdUnit4/src/cmd/CmdConsole.gd")

var scanner := SourceScanner.new()

func _initialize():
	set_auto_accept_quit(false)
	root.add_child(scanner)


func _finalize():
	prints("__finalize")



class SourceScanner extends Node:
	
	enum {
		INIT,
		SCAN,
		QUIT,
		DONE
	}
	
	
	var _counter = 0
	var WAIT_TIME_IN_MS = 5.000
	var _state = INIT
	var _console := CmdConsole.new()
	
	
	func _init():
		_state = SCAN
	
	
	func _process(delta):
		if _state != SCAN:
			return
		_counter += delta
		if _state == SCAN:
			set_process(false)
			_console.prints_color("======================================", Color.CORNFLOWER_BLUE)
			_console.prints_color("Running project scan:", Color.CORNFLOWER_BLUE)
			await scan_project()
			set_process(true)
			_state = QUIT
		if _state == QUIT or _counter >= WAIT_TIME_IN_MS:
			_state = DONE
			_console.prints_color("Scan project done.", Color.CORNFLOWER_BLUE)
			_console.prints_color("======================================", Color.CORNFLOWER_BLUE)
			_console.new_line()
			await get_tree().process_frame
			get_tree().quit(0)
	
	
	func scan_project() -> void:
		var plugin := EditorPlugin.new()
		var fs := plugin.get_editor_interface().get_resource_filesystem()
		
		if fs.has_method("reimport_files--"):
			_console.prints_color("Reimport images    :", Color.SANDY_BROWN)
			for source in ["res://addons/gdUnit4/src/ui/assets/orphan", "res://addons/gdUnit4/src/ui/assets/spinner", "res://addons/gdUnit4/src/ui/assets/"]:
				var image_files := Array(DirAccess.get_files_at(source))
				#_console.prints_color("%s" % image_files, Color.SANDY_BROWN)
				var files := image_files.map(func full_path(file_name):
					return "%s/%s" % [source, file_name] )\
					.filter(func filter_import_files(path :String):
						return path.get_extension() != "import")
				prints(files)
				fs.reimport_files(files)
				
		_console.prints_color("Scan sources: ", Color.SANDY_BROWN)
		fs.scan_sources()
		await get_tree().create_timer(5).timeout
		await get_tree().process_frame
	
		_console.prints_color("Scan: ", Color.SANDY_BROWN)
		fs.scan()
		await get_tree().process_frame
		while fs.is_scanning():
			await get_tree().process_frame
			_console.progressBar(fs.get_scanning_progress() * 100 as int)
		_console.progressBar(100)
		_console.new_line()
		await get_tree().process_frame
		plugin.queue_free()
		await get_tree().process_frame
