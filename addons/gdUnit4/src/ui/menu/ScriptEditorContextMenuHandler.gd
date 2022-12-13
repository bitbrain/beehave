class_name ScriptEditorContextMenuHandler
extends Object

var _context_menus := Dictionary()


func _init(context_menus :Array[GdUnitContextMenuItem]):
	for menu in context_menus:
		_context_menus[menu.id] = menu


static func create(context_menus :Array[GdUnitContextMenuItem]) -> Callable:
	return Callable(ScriptEditorContextMenuHandler.new(context_menus), "on_script_changed")


func on_script_changed(script, editor :ScriptEditor):
	#prints("ContextMenuHandler:on_script_changed", script, editor)
	if script is GDScript:
		var current_editor := editor.get_current_editor()
		var popups := GdObjects.find_nodes_by_class(current_editor, "PopupMenu", true)
		for popup in popups:
			if not popup.is_connected("about_to_popup", Callable(self, 'on_context_menu_show')):
				popup.connect("about_to_popup", Callable(self, 'on_context_menu_show').bind(script, popup))
			if not popup.is_connected("id_pressed", Callable(self, 'on_context_menu_pressed')):
				popup.connect("id_pressed", Callable(self, "on_context_menu_pressed").bind(script, current_editor.get_base_editor()))


func on_context_menu_show(script :GDScript, context_menu :PopupMenu):
	#prints("on_context_menu_show", _context_menus.keys(), context_menu, self)
	context_menu.add_separator()
	var current_index := context_menu.get_item_count()
	for menu_id in _context_menus.keys():
		var menu_item :GdUnitContextMenuItem = _context_menus[menu_id]
		if menu_item.is_visible(script):
			context_menu.add_item(menu_item.name, menu_id)
			context_menu.set_item_disabled(current_index, !menu_item.is_enabled(script))
			current_index += 1


func on_context_menu_pressed(id :int, script :GDScript, text_edit :TextEdit):
	#prints("on_context_menu_pressed", id, script, text_edit)
	if !_context_menus.has(id):
		return
	var menu_item :GdUnitContextMenuItem = _context_menus[id]
	menu_item.execute([script, text_edit])
