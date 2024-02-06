/**************************************************************************/
/*  beehave_tree_node.cpp                                                 */
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

#include "beehave_tree_node.h"
#include <core/class_db.hpp>
#include <variant/typed_array.hpp>
using namespace godot;

BeehaveTreeNode::BeehaveTreeNode() {
}

BeehaveTreeNode::~BeehaveTreeNode() {
}

PackedStringArray BeehaveTreeNode::_get_configuration_warnings() const {
	PackedStringArray warnings = Node::_get_configuration_warnings();

	TypedArray<Node> children = get_children();
	for (int i = 0; i < children.size(); i++) {
		Variant x = children[i];
		Node *child = Object::cast_to<Node>(x);

		if (child && !Object::cast_to<BeehaveTreeNode>(child)) {
			warnings.append("All children of this node should inherit from BeehaveNode class.");
			break;
		}
	}

	return warnings;
}

BeehaveTreeNode::TickStatus BeehaveTreeNode::tick(Ref<BeehaveContext> context) {
	return BeehaveTreeNode::SUCCESS;
}

void BeehaveTreeNode::_bind_methods() {

	ClassDB::bind_method(D_METHOD("tick"), &BeehaveTreeNode::tick);
	ClassDB::bind_method(D_METHOD("interrupt"), &BeehaveTreeNode::interrupt);
	ClassDB::bind_method(D_METHOD("before_run"), &BeehaveTreeNode::before_run);
	ClassDB::bind_method(D_METHOD("after_run"), &BeehaveTreeNode::after_run);
	ClassDB::bind_method(D_METHOD("get_class_name"), &BeehaveTreeNode::get_class_name);
	ClassDB::bind_method(D_METHOD("can_send_message"), &BeehaveTreeNode::can_send_message);

	BIND_ENUM_CONSTANT(SUCCESS);
	BIND_ENUM_CONSTANT(FAILURE);
	BIND_ENUM_CONSTANT(RUNNING);
}

void BeehaveTreeNode::interrupt(Ref<BeehaveContext> context) {
}

void BeehaveTreeNode::before_run(Ref<BeehaveContext> context) {
}

void BeehaveTreeNode::after_run(Ref<BeehaveContext> context) {
}

TypedArray<StringName> BeehaveTreeNode::get_class_name() {
	TypedArray<StringName> class_names;	
	class_names.push_back("BeehaveTreeNode");
	return class_names;
}

bool BeehaveTreeNode::can_send_message(Ref<BeehaveContext> context) {
	BeehaveBlackboard *blackboard = context->get_blackboard();

	return false; //TODO: Implement once blackboard is implemented
}