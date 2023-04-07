#!/usr/bin/env -S godot -s
@tool
extends SceneTree

const CmdConsole = preload("res://addons/gdUnit4/src/cmd/CmdConsole.gd")

var scanner := ProjectScanner.new()

func _initialize():
	root.add_child(scanner)


func _finalize():
	prints("Finalize scanner ..")
	scanner.free()


class ProjectScanner extends Node:
	
	enum {
		INIT,
		SCAN,
		QUIT
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
		if _state == QUIT or _counter >= WAIT_TIME_IN_MS:
			_console.prints_color("Scan project done.", Color.CORNFLOWER_BLUE)
			_console.prints_color("======================================", Color.CORNFLOWER_BLUE)
			_console.new_line()
			await get_tree().process_frame
			get_tree().quit()
	
	
	func scan_project() -> void:
		var plugin := EditorPlugin.new()
		var fs := plugin.get_editor_interface().get_resource_filesystem()
		
		_console.prints_color("Scan        :", Color.SANDY_BROWN)
		_console.progressBar(0)
		fs.scan()
		await get_tree().process_frame
		while fs.is_scanning():
			await get_tree().process_frame
			_console.progressBar(fs.get_scanning_progress() * 100 as int)
		_console.progressBar(100)
		_console.new_line()
		
		_console.prints_color("Scan sources: ", Color.SANDY_BROWN)
		_console.progressBar(0)
		fs.scan_sources()
		await get_tree().process_frame
		while fs.is_scanning():
			await get_tree().process_frame
			_console.progressBar(fs.get_scanning_progress() * 100 as int)
		_console.progressBar(100)
		_console.new_line()
		plugin.free()
		_state = QUIT
