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
#include "variant/utility_functions.hpp"

using namespace godot;

BeehaveTreeNode::BeehaveTreeNode() {
}

BeehaveTreeNode::~BeehaveTreeNode() {
}

BeehaveTickStatus BeehaveTreeNode::tick(Ref<BeehaveContext> context) {
	BeehaveTickStatus status = BeehaveTickStatus::PENDING;
	GDVIRTUAL_CALL(_tick, context, status);
	return status;
}

void BeehaveTreeNode::interrupt(Ref<BeehaveContext> context) {
	GDVIRTUAL_CALL(_interrupt, context);
}

void BeehaveTreeNode::before_run(Ref<BeehaveContext> context) {
	GDVIRTUAL_CALL(_before_run, context);
}

void BeehaveTreeNode::after_run(Ref<BeehaveContext> context) {
	GDVIRTUAL_CALL(_after_run, context);
}

BeehaveTreeNode* BeehaveTreeNode::cast_node(Node* node) const {
	BeehaveTreeNode *tree_node = cast_to<BeehaveTreeNode>(node);
	if (!tree_node) {
		return nullptr;
	}
	return tree_node;
}

void BeehaveTreeNode::_bind_methods() {

	GDVIRTUAL_BIND(_tick, "context");
	GDVIRTUAL_BIND(_interrupt, "context");
	GDVIRTUAL_BIND(_before_run, "context");
	GDVIRTUAL_BIND(_after_run, "context");

	BIND_ENUM_CONSTANT(PENDING);
	BIND_ENUM_CONSTANT(SUCCESS);
	BIND_ENUM_CONSTANT(FAILURE);
	BIND_ENUM_CONSTANT(RUNNING);
}