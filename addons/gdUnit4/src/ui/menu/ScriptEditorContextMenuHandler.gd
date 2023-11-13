class_name ScriptEditorContextMenuHandler
extends Control

var _context_menus := Dictionary()
var _editor :ScriptEditor


func _init(context_menus :Array[GdUnitContextMenuItem], p_editor :ScriptEditor):
	set_name("ScriptEditorContextMenuHandler")
	for menu in context_menus:
		_context_menus[menu.id] = menu
	_editor = p_editor
	p_editor.editor_script_changed.connect(on_script_changed)
	on_script_changed(active_script())


static func dispose(p_editor :ScriptEditor) -> void:
	var handler :ScriptEditorContextMenuHandler = Engine.get_main_loop().root.find_child("ScriptEditorContextMenuHandler*", false, false)
	if handler:
		if p_editor.editor_script_changed.is_connected(handler.on_script_changed):
			p_editor.editor_script_changed.disconnect(handler.on_script_changed)
		Engine.get_main_loop().root.call_deferred("remove_child", handler)
		handler.queue_free()


func _input(event):
	if event is InputEventKey and event.is_pressed():
		for shortcut_action in _context_menus.values():
			var action :GdUnitContextMenuItem =  shortcut_action
			if action.shortcut().matches_event(event) and action.is_visible(active_script()):
				#if not has_editor_focus():
				#	return
				action.execute()
				accept_event()
				return


func has_editor_focus() -> bool:
	return Engine.get_main_loop().root.gui_get_focus_owner() == active_base_editor()


func on_script_changed(script :Script):
	if script is Script:
		var popups :Array[Node] = GdObjects.find_nodes_by_class(active_editor(), "PopupMenu", true)
		for popup in popups:
			if not popup.about_to_popup.is_connected(on_context_menu_show):
				popup.about_to_popup.connect(on_context_menu_show.bind(script, popup))
			if not popup.id_pressed.is_connected(on_context_menu_pressed):
				popup.id_pressed.connect(on_context_menu_pressed)


func on_context_menu_show(script :Script, context_menu :PopupMenu):
	#prints("on_context_menu_show", _context_menus.keys(), context_menu, self)
	context_menu.add_separator()
	var current_index := context_menu.get_item_count()
	for menu_id in _context_menus.keys():
		var menu_item :GdUnitContextMenuItem = _context_menus[menu_id]
		if menu_item.is_visible(script):
			context_menu.add_item(menu_item.name, menu_id)
			context_menu.set_item_disabled(current_index, !menu_item.is_enabled(script))
			context_menu.set_item_shortcut(current_index, menu_item.shortcut(), true)
			current_index += 1


func on_context_menu_pressed(id :int):
	if !_context_menus.has(id):
		return
	var menu_item :GdUnitContextMenuItem = _context_menus[id]
	menu_item.execute()


func active_editor() -> ScriptEditorBase:
	return _editor.get_current_editor()


func active_base_editor() -> TextEdit:
	return active_editor().get_base_editor()


func active_script() -> Script:
	return _editor.get_current_script()
