/**************************************************************************/
/*  beehave_tree.cpp                                                      */
/**************************************************************************/
/*                         This file is part of:                          */
/*                               BEEHAVE                                  */
/*                      https://bitbra.in/beehave                         */
/**************************************************************************/
/* Copyright (c) 2024-present Beehave Contributors.                       */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#include "beehave_tree.h"
#include "beehave_blackboard.h"
#include <core/class_db.hpp>

using namespace godot;

BeehaveTree::BeehaveTree() :
	context(Ref<BeehaveContext>(memnew(BeehaveContext))),
	tick_status(BeehaveTreeNode::TickStatus::PENDING),
    tick_rate(1),
	blackboard(nullptr),
	actor(nullptr) {
}

BeehaveTree::~BeehaveTree() {
	_internal_blackboard = nullptr;
	blackboard = nullptr;
	actor = nullptr;
}

void BeehaveTree::_bind_methods() {
	// signals
	ADD_SIGNAL(MethodInfo("enabled"));
	ADD_SIGNAL(MethodInfo("disabled"));

	// enums
	BIND_ENUM_CONSTANT(IDLE);
	BIND_ENUM_CONSTANT(PHYSICS);

	// methods
	ClassDB::bind_method(D_METHOD("tick"), &BeehaveTree::tick);
	ClassDB::bind_method(D_METHOD("enable"), &BeehaveTree::enable);
	ClassDB::bind_method(D_METHOD("disable"), &BeehaveTree::disable);
	ClassDB::bind_method(D_METHOD("set_enabled", "enabled"), &BeehaveTree::set_enabled);
	ClassDB::bind_method(D_METHOD("is_enabled"), &BeehaveTree::is_enabled);
	ClassDB::bind_method(D_METHOD("get_tick_status"), &BeehaveTree::get_tick_status);
	ClassDB::bind_method(D_METHOD("set_tick_rate", "tick_rate"), &BeehaveTree::set_tick_rate);
	ClassDB::bind_method(D_METHOD("get_tick_rate"), &BeehaveTree::get_tick_rate);
	ClassDB::bind_method(D_METHOD("set_process_thread", "thread"), &BeehaveTree::set_process_thread);
	ClassDB::bind_method(D_METHOD("get_process_thread"), &BeehaveTree::get_process_thread);
	ClassDB::bind_method(D_METHOD("set_actor", "actor"), &BeehaveTree::set_actor);
	ClassDB::bind_method(D_METHOD("get_actor"), &BeehaveTree::get_actor);
	ClassDB::bind_method(D_METHOD("set_blackboard", "blackboard"), &BeehaveTree::set_blackboard);
	ClassDB::bind_method(D_METHOD("get_blackboard"), &BeehaveTree::get_blackboard);

	// exports
	ADD_PROPERTY(PropertyInfo(Variant::INT, "process_thread", PROPERTY_HINT_ENUM, "Idle,Physics"), "set_process_thread", "get_process_thread");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enabled"), "set_enabled", "is_enabled");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "tick_rate"), "set_tick_rate", "get_tick_rate");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "actor", PROPERTY_HINT_NODE_TYPE, "Node"), "set_actor", "get_actor");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "blackboard", PROPERTY_HINT_NODE_TYPE, "BeehaveBlackboard"), "set_blackboard", "get_blackboard");
}

void BeehaveTree::_ready() {
	this->_internal_blackboard = memnew(BeehaveBlackboard);
	add_child(_internal_blackboard, false, Node::INTERNAL_MODE_FRONT);

	set_physics_process(enabled && process_thread == ProcessThread::PHYSICS);
	set_process(enabled && process_thread == ProcessThread::IDLE);

	// Randomize at what frames tick() will happen to avoid stutters
	_last_tick = rand() % tick_rate;
}

void BeehaveTree::_process(double delta) {
	if (process_thread == BeehaveTree::ProcessThread::IDLE) {
		process_internally(delta);
	}
}

void BeehaveTree::_physics_process(double delta) {
	if (process_thread == BeehaveTree::ProcessThread::PHYSICS) {
		process_internally(delta);
	}
}

void BeehaveTree::set_actor(Node* actor) {
	this->actor = actor;
}

Node* BeehaveTree::get_actor() const {
	return actor;
}

void BeehaveTree::set_blackboard(BeehaveBlackboard *blackboard) {
	this->blackboard = blackboard;
	
}

BeehaveBlackboard *BeehaveTree::get_blackboard() const {
	return blackboard;
}

void BeehaveTree::enable() {
	enabled = true;
}

void BeehaveTree::disable() {
	enabled = false;
}

void BeehaveTree::set_enabled(bool enabled) {
	this->enabled = enabled;
}
bool BeehaveTree::is_enabled() const {
	return enabled;
}

void BeehaveTree::set_tick_rate(int tick_rate) {
	this->tick_rate = tick_rate;
}

int BeehaveTree::get_tick_rate() const {
	return tick_rate;
}

BeehaveTreeNode::TickStatus BeehaveTree::get_tick_status() const {
	return tick_status;
}

void BeehaveTree::set_process_thread(BeehaveTree::ProcessThread thread) {
	process_thread = thread;
}

BeehaveTree::ProcessThread BeehaveTree::get_process_thread() const {
	return process_thread;
}

void BeehaveTree::process_internally(double delta) {
	// ensure that we consider the current tick rate of the tree
	if (_last_tick < tick_rate - 1) {
		_last_tick += 1;
		return;
	}

	_last_tick = 0;

	context->set_delta(delta);

	tick();
}

BeehaveTreeNode::TickStatus BeehaveTree::tick() {
	context->set_tree(this);
	context->set_actor(actor ? actor : get_parent());
	context->set_blackboard(blackboard ? blackboard : _internal_blackboard);

	if (get_child_count() == 0) {
		tick_status = BeehaveTreeNode::FAILURE;
		return tick_status;
	}

	for (int i = 0; i < get_child_count(); i++) {
		Node *child = get_child(i);
		if (!child) {
			continue;
		}
		BeehaveTreeNode *tree_node = cast_to<BeehaveTreeNode>(child);
		if (tree_node) {
			tick_status = tree_node->tick(context);
		}
	}
	return tick_status;
}
