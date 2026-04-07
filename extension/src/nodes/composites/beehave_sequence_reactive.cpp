/**************************************************************************/
/*  beehave_sequence_reactive.cpp                                         */
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

#include "beehave_sequence_reactive.h"

using namespace godot;

BeehaveSequenceReactive::BeehaveSequenceReactive() {

}

BeehaveSequenceReactive::~BeehaveSequenceReactive() {

}

void BeehaveSequenceReactive::_bind_methods() {

}

BeehaveTickStatus BeehaveSequenceReactive::tick(Ref<BeehaveContext> context) {
    TypedArray<Node> children = get_children();
    for (int i = 0; i < children.size(); ++i) {
        BeehaveTreeNode *child = cast_node(Object::cast_to<Node>(children[i]));
        if (child == nullptr) {
            // skip anything that is not a valid beehave node
			continue;
        }

        if (child != running_child) {
            child->before_run(context);
        }

        BeehaveTickStatus response = child->tick(context);

        switch(response) {
            case SUCCESS:
                if (running_child && running_child == child) {
                    // Do not interrupt this child as it finishes running!
                    running_child = nullptr;
                }
                child->after_run(context);
                break;
            case FAILURE:
                interrupt_children(context, i + 1, previous_failure_index + 1);

                previous_failure_index = i;

                if (running_child) {
                    running_child->interrupt(context);
                    running_child = nullptr;
                }
                child->after_run(context);
                return FAILURE;
            case RUNNING:
                previous_failure_index = -1;
                previous_running_index = -1;

                if (running_child && running_child != child) {
                    running_child->interrupt(context);
                    running_child = nullptr;
                }
                running_child = child;
                interrupt_children(context, i + 1, previous_running_index + 1);
                previous_running_index = i;
                return RUNNING;
        }
    }
    return BeehaveTickStatus::SUCCESS;
}

void BeehaveSequenceReactive::interrupt(Ref<BeehaveContext> context) {
    int to_index = previous_running_index > previous_failure_index ? previous_running_index : previous_failure_index;
    interrupt_children(context, 0, to_index);

    previous_running_index = -1;
    previous_failure_index = -1;

    BeehaveComposite::interrupt(context);
}