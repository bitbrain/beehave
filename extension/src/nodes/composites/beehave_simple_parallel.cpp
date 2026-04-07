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

void BeehaveSimpleParallel::set_secondary_node_repeat_count(int repeat_count) {
    secondary_node_repeat_count = repeat_count;
}

int BeehaveSimpleParallel::get_secondary_node_repeat_count() const {
    return secondary_node_repeat_count;
}

void BeehaveSimpleParallel::_bind_methods() {
    // methods
    ClassDB::bind_method(D_METHOD("set_wait_for_secondary_node", "wait"), &BeehaveSimpleParallel::set_wait_for_secondary_node);
    ClassDB::bind_method(D_METHOD("get_wait_for_secondary_node"), &BeehaveSimpleParallel::get_wait_for_secondary_node);
    ClassDB::bind_method(D_METHOD("set_secondary_node_repeat_count", "repeat_count"), &BeehaveSimpleParallel::set_secondary_node_repeat_count);
    ClassDB::bind_method(D_METHOD("get_secondary_node_repeat_count"), &BeehaveSimpleParallel::get_secondary_node_repeat_count);

    // exports
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "wait_for_secondary_node"), "set_wait_for_secondary_node", "get_wait_for_secondary_node");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "secondary_node_repeat_count"), "set_secondary_node_repeat_count", "get_secondary_node_repeat_count");
}

BeehaveTickStatus BeehaveSimpleParallel::tick(Ref<BeehaveContext> context) {
    bool main_node_ticked = false;
    bool secondary_node_ticked = false;
    TypedArray<Node> children = get_children();

    for (int i = 0; i < children.size(); ++i) {
        BeehaveTreeNode *child = cast_node(Object::cast_to<Node>(children[i]));
        if (child == nullptr) {
            // skip anything that is not a valid beehave node
			continue;
        }
        
        // First valid node is considered "main" node.
        if (!main_node_ticked && !main_task_finished) {
            main_node_ticked = true;

            if (child != running_child) {
                child->before_run(context);
            }

            BeehaveTickStatus main_response = child->tick(context);
            delayed_result = main_response;

            switch(main_response) {
                case SUCCESS:
                case FAILURE:
                    running_child = nullptr;
                    main_task_finished = true;
                    child->after_run(context);

                    if (!wait_for_secondary_node) {
                        if (secondary_node_running) {
                            // FIXME: assumes secondary node comes right after main node!
                            BeehaveTreeNode *secondary = cast_node(Object::cast_to<Node>(children[i + 1]));
                            if (secondary) {
                                secondary->interrupt(context);
                            }
                        }
                        _reset();
                        return delayed_result;
                    }
                case RUNNING:
                    running_child = child;
                    break;
            }
        }
        // Next valid node is considered secondary node.
        else if (!secondary_node_ticked) {
            secondary_node_ticked = true;
            
            if (secondary_node_repeat_count == 0 || secondary_node_repeat_left > 0) {
                if (!secondary_node_running) {
                    child->before_run(context);
                }

                BeehaveTickStatus subtree_response = child->tick(context);

                if(subtree_response != BeehaveTickStatus::RUNNING) {
                    secondary_node_running = false;
                    child->after_run(context);
                    
                    if (wait_for_secondary_node && main_task_finished) {
                        _reset();
                        return delayed_result;
                    }
                    else if (secondary_node_repeat_left > 0) {
                        --secondary_node_repeat_left;
                    }
                }
                else {
                    secondary_node_running = true;
                }
            }
        }
    }
    return BeehaveTickStatus::RUNNING;
}

void BeehaveSimpleParallel::before_run(Ref<BeehaveContext> context) {
    secondary_node_repeat_left = secondary_node_repeat_count;
    BeehaveComposite::before_run(context);
}

void BeehaveSimpleParallel::after_run(Ref<BeehaveContext> context) {
    _reset();
    BeehaveComposite::after_run(context);
}

void BeehaveSimpleParallel::interrupt(Ref<BeehaveContext> context) {
    TypedArray<Node> children = get_children();

    if (!main_task_finished) {
        // FIXME: assumes index 0 is main node
        BeehaveTreeNode *main = cast_node(Object::cast_to<Node>(children[0]));
        if (main) {
            main->interrupt(context);
        }
    }
    if (secondary_node_running) {
        // FIXME: assumes index 1 is main secondary
        BeehaveTreeNode *secondary = cast_node(Object::cast_to<Node>(children[1]));
        if (secondary) {
            secondary->interrupt(context);
        }
    }

    _reset();

    BeehaveComposite::interrupt(context);
}

void BeehaveSimpleParallel::_reset() {
    main_task_finished = false;
    secondary_node_running = false;
}