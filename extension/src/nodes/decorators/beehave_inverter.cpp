/**************************************************************************/
/*  beehave_inverter.cpp                                                  */
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

#include "beehave_inverter.h"

using namespace godot;

BeehaveInverter::BeehaveInverter() {

}

BeehaveInverter::~BeehaveInverter() {

}

void BeehaveInverter::_bind_methods() {

}

BeehaveTreeNode::TickStatus BeehaveInverter::tick(Ref<BeehaveContext> context) {

	if (get_child_count() != 1) {
		return BeehaveTreeNode::FAILURE;
	}

	Node* child = get_child(0);

	if (!child) {
		return BeehaveTreeNode::FAILURE;
	}

	BeehaveTreeNode *tree_node = cast_to<BeehaveTreeNode>(child);
	if (!tree_node) {
		return BeehaveTreeNode::FAILURE;
	}

	BeehaveTreeNode::TickStatus tick_status = tree_node->tick(context);

	if (tick_status == BeehaveTreeNode::FAILURE) {
		return BeehaveTreeNode::SUCCESS;
	} else if (tick_status == BeehaveTreeNode::SUCCESS) {
		return BeehaveTreeNode::FAILURE;
	}

	return tick_status;
}