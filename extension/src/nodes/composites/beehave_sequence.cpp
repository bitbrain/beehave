/**************************************************************************/
/*  beehave_sequence.cpp                                                  */
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

#include "beehave_sequence.h"

using namespace godot;

BeehaveSequence::BeehaveSequence() {

}

BeehaveSequence::~BeehaveSequence() {

}

void BeehaveSequence::_bind_methods() {

}

BeehaveTickStatus BeehaveSequence::tick(Ref<BeehaveContext> context) {
    TypedArray<Node> children = get_children();
    for (int i = 0; i < children.size(); ++i) {
        if (i < successful_index) {
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

        switch(response) {
            case SUCCESS:
                // Do not interrupt as the child finishes running!
                running_child = nullptr;
                ++successful_index;
                break;
            case FAILURE:
                if (running_child) {
                    running_child->interrupt(context);
                    running_child = nullptr;
                }
                interrupt_children(context, i + 1, previous_success_or_running_index + 1);
                
                // Remember where we failed for next tick
                previous_success_or_running_index = i;
                successful_index = 0;

                // Interrupt any child that was RUNNING before, but do not reset!
                if (running_child) {
                    running_child->interrupt(context);
                    running_child = nullptr;
                }
                child->after_run(context);

                return FAILURE;
            case RUNNING:
                if (running_child && child != running_child) {
                    running_child->interrupt(context);
                    running_child = nullptr;
                }
                running_child = child;
                interrupt_children(context, i + 1, previous_success_or_running_index + 1);
                previous_success_or_running_index = i;
                return RUNNING;
        }
    }

    successful_index = 0;
    return BeehaveTickStatus::SUCCESS;
}

void BeehaveSequence::interrupt(Ref<BeehaveContext> context) {
    interrupt_children(context, successful_index, previous_success_or_running_index + 1);
    BeehaveComposite::interrupt(context);
}