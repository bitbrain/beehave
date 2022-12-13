# A tool to provide extended filesystem editor functionallity
class_name EditorFileSystemControls
extends RefCounted


# Returns the EditorInterface instance
static func editor_interface() -> EditorInterface:
	if not Engine.has_meta("GdUnitEditorPlugin"):
		return null
	var plugin :EditorPlugin = Engine.get_meta("GdUnitEditorPlugin")
	return plugin.get_editor_interface()


# Returns the FileSystemDock instance
static func filesystem_dock() -> FileSystemDock:
	return editor_interface().get_file_system_dock()


# Register the given context menu to the filesystem dock
# Is called when the plugin is activated
# The filesystem popup is connected to the EditorFileSystemContextMenuHandler
static func register_context_menu(menu :Array[GdUnitContextMenuItem]) -> void:
	EditorFileSystemContextMenuHandler.create(_file_tree(), _menu_popup(), menu)


# Unregisteres all registerend context menus and gives the EditorFileSystemContextMenuHandler> free
# Is called when the plugin is deactivated
static func unregister_context_menu() -> void:
	EditorFileSystemContextMenuHandler.release(_menu_popup())


static func _file_tree() -> Tree:
	return GdObjects.find_nodes_by_class(filesystem_dock(), "Tree", true)[-1]


static func _menu_popup() -> PopupMenu:
	return GdObjects.find_nodes_by_class(filesystem_dock(), "PopupMenu")[-1]


static func _print_menu(popup :PopupMenu):
	for itemIndex in popup.item_count:
		prints( "get_item_id", popup.get_item_id(itemIndex))
		prints( "get_item_accelerator", popup.get_item_accelerator(itemIndex))
		prints( "get_item_shortcut", popup.get_item_shortcut(itemIndex))
		prints( "get_item_text", popup.get_item_text(itemIndex))
		prints()
