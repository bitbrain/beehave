/**************************************************************************/
/*  beehave_simple_parallel.cpp                                           */
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

#include "beehave_simple_parallel.h"

using namespace godot;

BeehaveSimpleParallel::BeehaveSimpleParallel() {

}

BeehaveSimpleParallel::~BeehaveSimpleParallel() {

}

void BeehaveSimpleParallel::set_wait_for_secondary_node(bool wait) {
    wait_for_secondary_node = wait;
}

bool BeehaveSimpleParallel::get_wait_for_secondary_node() const {
    return wait_for_secondary_node;
}

void BeehaveSimpleParallel::_bind_methods() {
    // methods
    ClassDB::bind_method(D_METHOD("set_wait_for_secondary_node", "wait"), &BeehaveSimpleParallel::set_wait_for_secondary_node);
    ClassDB::bind_method(D_METHOD("get_wait_for_secondary_node"), &BeehaveSimpleParallel::get_wait_for_secondary_node);

    // exports
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "wait_for_secondary_node"), "set_wait_for_secondary_node", "get_wait_for_secondary_node");
}

BeehaveTickStatus BeehaveSimpleParallel::tick(Ref<BeehaveContext> context) {
    bool main_node_ticked = false;
    TypedArray<Node> children = get_children();

    for (int i = 0; i < children.size(); ++i) {
        BeehaveTreeNode *child = cast_node(Object::cast_to<Node>(children[i]));
        if (child == nullptr) {
            // skip anything that is not a valid beehave node
			continue;
        }
        
        // First valid node is considered "main" node.
        if (!main_node_ticked) {
            main_node_ticked = true;

            BeehaveTickStatus main_response = child->tick(context);
            delayed_result = main_response;

            switch(main_response) {
                case SUCCESS:
                case FAILURE:
                    main_task_finished = true;
                    if (!wait_for_secondary_node) {
                        // TODO: Interrupt secondary node
                        _reset();
                        return delayed_result;
                    }
                case RUNNING:
                    break;
            }
        }
        else {
            BeehaveTickStatus subtree_response = child->tick(context);

            if(subtree_response != BeehaveTickStatus::RUNNING) {
                secondary_node_running = false;
                // TODO: Add check for secondary node repeat count back in.
                _reset();
                return subtree_response;
            }
            else {
                secondary_node_running = true;
            }
        }
    }
    return BeehaveTickStatus::RUNNING;
}

void BeehaveSimpleParallel::_reset() {
    main_task_finished = false;
    secondary_node_running = false;
}