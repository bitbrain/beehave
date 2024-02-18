#include "register_types.h"
#include <gdextension_interface.h>
#include <core/class_db.hpp>
#include <core/defs.hpp>
#include <godot.hpp>

#include "beehave_context.h"
#include "nodes/beehave_blackboard.h"
#include "nodes/beehave_tree.h"
#include "nodes/beehave_tree_node.h"
#include "nodes/leaves/beehave_leaf.h"
#include "nodes/leaves/beehave_action.h"
#include "nodes/decorators/beehave_decorator.h"
#include "nodes/decorators/beehave_succeeder.h"
#include "nodes/decorators/beehave_failer.h"
#include "nodes/decorators/beehave_inverter.h"
#include "nodes/decorators/beehave_cooldown.h"
#include "nodes/decorators/beehave_limiter.h"
#include "nodes/decorators/beehave_delayer.h"
#include "nodes/decorators/beehave_repeater.h"

using namespace godot;

void initialize_beehave_types(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	// base nodes
	ClassDB::register_class<BeehaveContext>();
	ClassDB::register_class<BeehaveTree>();
	ClassDB::register_class<BeehaveTreeNode>();
	ClassDB::register_class<BeehaveBlackboard>();

	// leafs
	ClassDB::register_class<BeehaveLeaf>();
	ClassDB::register_class<BeehaveAction>();
	ClassDB::register_class<BeehaveDecorator>();

	// decorators
	ClassDB::register_class<BeehaveSucceeder>();
	ClassDB::register_class<BeehaveFailer>();
	ClassDB::register_class<BeehaveInverter>();
	ClassDB::register_class<BeehaveCooldown>();
	ClassDB::register_class<BeehaveLimiter>();
	ClassDB::register_class<BeehaveDelayer>();
	ClassDB::register_class<BeehaveRepeater>();
	//timelimiter

	// composites
	// TODO
}

void uninitialize_beehave_types(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}

extern "C" {

// Initialization.

GDExtensionBool GDE_EXPORT
beehave_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_beehave_types);
	init_obj.register_terminator(uninitialize_beehave_types);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_CORE);

	return init_obj.init();
}
}
