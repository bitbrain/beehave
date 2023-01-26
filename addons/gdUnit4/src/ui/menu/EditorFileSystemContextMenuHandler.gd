class_name EditorFileSystemContextMenuHandler
extends Node


var _context_menus := Dictionary()


func _init(context_menus :Array[GdUnitContextMenuItem]):
	set_name("EditorFileSystemContextMenuHandler")
	for menu in context_menus:
		_context_menus[menu.id] = menu


static func create(file_tree :Tree, popup : PopupMenu, context_menus :Array[GdUnitContextMenuItem]) -> EditorFileSystemContextMenuHandler:
	var handler := EditorFileSystemContextMenuHandler.new(context_menus)
	popup.connect("about_to_popup", Callable(handler, "on_context_menu_show").bind(popup, file_tree))
	popup.connect("id_pressed", Callable(handler, "on_context_menu_pressed").bind(file_tree))
	Engine.get_main_loop().root.call_deferred("add_child", handler, true)
	return handler


static func release(popup : PopupMenu):
	var handler = Engine.get_main_loop().root.find_child("EditorFileSystemContextMenuHandler*", false, false)
	if handler:
		if popup.is_connected("about_to_popup", Callable(handler, "on_context_menu_show")):
			popup.disconnect("about_to_popup", Callable(handler, "on_context_menu_show"))
		if popup.is_connected("id_pressed", Callable(handler, "on_context_menu_pressed")):
			popup.disconnect("id_pressed", Callable(handler, "on_context_menu_pressed"))
		handler.queue_free()

func on_context_menu_show(context_menu :PopupMenu, file_tree :Tree) -> void:
	context_menu.add_separator()
	var current_index := context_menu.get_item_count()
	var selected_test_suites := collect_testsuites(_context_menus.values()[0], file_tree)
	
	for menu_id in _context_menus.keys():
		var menu_item :GdUnitContextMenuItem = _context_menus[menu_id]
		if selected_test_suites.size() != 0:
			context_menu.add_item(menu_item.name, menu_id)
			context_menu.set_item_disabled(current_index, !menu_item.is_enabled(null))
			current_index += 1


func on_context_menu_pressed(id :int, file_tree :Tree) -> void:
	#prints("on_context_menu_pressed", id)
	if !_context_menus.has(id):
		return
	var menu_item :GdUnitContextMenuItem = _context_menus[id]
	var selected_test_suites := collect_testsuites(menu_item, file_tree)
	menu_item.execute([selected_test_suites])


func collect_testsuites(menu_item :GdUnitContextMenuItem, file_tree :Tree) -> PackedStringArray:
	var file_system := editor_interface().get_resource_filesystem()
	var selected_item := file_tree.get_selected()
	var selected_test_suites := PackedStringArray()
	while selected_item:
		var resource_path :String = selected_item.get_metadata(0)
		var file_type := file_system.get_file_type(resource_path)
		var is_dir := DirAccess.dir_exists_absolute(resource_path)
		if is_dir:
			selected_test_suites.append(resource_path)
		elif is_dir or file_type == "GDScript":
			# find a performant way to check if the selected item a testsuite
			#var resource := ResourceLoader.load(resource_path, "GDScript", ResourceLoader.CACHE_MODE_REUSE)
			#prints("loaded", resource)
			#if resource is GDScript and menu_item.is_visible(resource):
			selected_test_suites.append(resource_path)
		selected_item = file_tree.get_next_selected(selected_item)
	return selected_test_suites


# Returns the EditorInterface instance
static func editor_interface() -> EditorInterface:
	if not Engine.has_meta("GdUnitEditorPlugin"):
		return null
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	return plugin.get_editor_interface()
