/**************************************************************************/
/*  beehave_selector.cpp                                                  */
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

#include "beehave_selector.h"

using namespace godot;

BeehaveSelector::BeehaveSelector() {

}

BeehaveSelector::~BeehaveSelector() {

}

void BeehaveSelector::_bind_methods() {

}

BeehaveTickStatus BeehaveSelector::tick(Ref<BeehaveContext> context) {
	TypedArray<Node> children = get_children();
	int processed_count = 0;

	for (int i = 0; i < children.size(); ++i) {
		if (i < last_execution_index) {
			// skip everything that was executed already
			++processed_count;
			continue;
		}
		BeehaveTreeNode *child = cast_node(Object::cast_to<Node>(children[i]));
		if (child == nullptr) {
			// skip anything that is not a valid beehave node
			continue;
		}

		if (child != running_child) {
			child->before_run(context);
		}

		BeehaveTickStatus response = child->tick(context);
		++processed_count;

		switch (response) {
			case SUCCESS:
				if (running_child) {
					if (running_child != child) {
						running_child->interrupt(context);
					}
					running_child = nullptr;
				}
				child->after_run(context);
				interrupt_children(context, i + 1, previous_success_or_running_index + 1);

				previous_success_or_running_index = i;
				ready_to_interrupt_all = false;
				return SUCCESS;
			case FAILURE:
				running_child = nullptr;
				child->after_run(context);
				++last_execution_index;
				break;
			case RUNNING:
				if (child != running_child) {
					if (running_child) {
						running_child->interrupt(context);
					}
					running_child = child;
				}
				interrupt_children(context, i + 1, previous_success_or_running_index + 1);
				previous_success_or_running_index = i;
				ready_to_interrupt_all = false;
				return RUNNING;
		}
	}

	// FIXME: this doesn't account for children that aren't Beehave nodes. In that case, processed_count will never reach children.size()!
	// All children failed
	ready_to_interrupt_all = (processed_count == children.size());
	last_execution_index = 0;
	return BeehaveTickStatus::FAILURE;
}

void BeehaveSelector::after_run(Ref<BeehaveContext> context) {
	last_execution_index = 0;
	BeehaveComposite::after_run(context);
}

void BeehaveSelector::interrupt(Ref<BeehaveContext> context) {
	if (ready_to_interrupt_all) {
		interrupt_children(context, 0, get_child_count());
		ready_to_interrupt_all = false;
	}
	else {
		interrupt_children(context, last_execution_index + 1, previous_success_or_running_index + 1);
	}

	last_execution_index = 0;
	previous_success_or_running_index = -1;

	BeehaveComposite::interrupt(context);
}