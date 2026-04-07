#!/usr/bin/env -S godot -s
@tool
extends SceneTree

const CmdConsole = preload("res://addons/gdUnit4/src/cmd/CmdConsole.gd")


func _initialize():
	set_auto_accept_quit(false)
	var scanner := SourceScanner.new(self)
	root.add_child(scanner)


# gdlint: disable=trailing-whitespace
class SourceScanner extends Node:
	
	enum {
		INIT,
		STARTUP,
		SCAN,
		QUIT,
		DONE
	}
	
	var _state = INIT
	var _console := CmdConsole.new()
	var _elapsed_time := 0.0
	var _plugin: EditorPlugin
	var _fs: EditorFileSystem
	var _scene: SceneTree
	
	
	func _init(scene :SceneTree) -> void:
		_scene = scene
		_console.prints_color("""
			========================================================================
			Running project scan:""".dedent(),
			Color.CORNFLOWER_BLUE
		)
		_state = INIT
	
	
	func _process(delta :float) -> void:
		_elapsed_time += delta
		set_process(false)
		await_inital_scan()
		await scan_project()
		set_process(true)
	
	
	# !! don't use any await in this phase otherwise the editor will be instable !!
	func await_inital_scan() -> void:
		if _state == INIT:
			_console.prints_color("Wait initial scanning ...", Color.DARK_GREEN)
			_plugin = EditorPlugin.new()
			_fs = _plugin.get_editor_interface().get_resource_filesystem()
			_plugin.get_editor_interface().set_plugin_enabled("gdUnit4", false)
			_state = STARTUP
		
		if _state == STARTUP:
			if _fs.is_scanning():
				_console.progressBar(_fs.get_scanning_progress() * 100 as int)
			# we wait 10s in addition to be on the save site the scanning is done
			if _elapsed_time > 10.0:
				_console.progressBar(100)
				_console.new_line()
				_console.prints_color("initial scanning ... done", Color.DARK_GREEN)
				_state = SCAN
	
	
	func scan_project() -> void:
		if _state != SCAN:
			return
		_console.prints_color("Scan project: ", Color.SANDY_BROWN)
		await get_tree().process_frame
		_fs.scan_sources()
		await get_tree().create_timer(5).timeout
		_console.prints_color("Scan: ", Color.SANDY_BROWN)
		_console.progressBar(0)
		await get_tree().process_frame
		_fs.scan()
		while _fs.is_scanning():
			await get_tree().process_frame
			_console.progressBar(_fs.get_scanning_progress() * 100 as int)
		await get_tree().create_timer(10).timeout
		_console.progressBar(100)
		_console.new_line()
		_plugin.free()
		_console.prints_color("""
			Scan project done.
			========================================================================""".dedent(),
			Color.CORNFLOWER_BLUE
		)
		await get_tree().process_frame
		await get_tree().physics_frame
		queue_free()
		# force quit editor
		_state = DONE
		_scene.quit(0)
