#include "register_types.h"
#include <gdextension_interface.h>
#include <core/class_db.hpp>
#include <core/defs.hpp>
#include <godot.hpp>

#include "nodes/beehave_tree.h"
#include "nodes/beehave_tree_node.h"
#include "beehave_context.h"
#include "nodes/beehave_blackboard.h"

using namespace godot;

void initialize_beehave_types(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	ClassDB::register_class<BeehaveContext>();
    ClassDB::register_class<BeehaveTree>();
	ClassDB::register_class<BeehaveTreeNode>();
    ClassDB::register_class<BeehaveBlackboard>();
}

void uninitialize_beehave_types(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}

extern "C" {

	// Initialization.

	GDExtensionBool GDE_EXPORT
		beehave_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization* r_initialization) {
		GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

		init_obj.register_initializer(initialize_beehave_types);
		init_obj.register_terminator(uninitialize_beehave_types);
		init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_CORE);

		return init_obj.init();
	}
}