/**************************************************************************/
/*  beehave_sequence_random.cpp                                           */
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

#include "beehave_sequence_random.h"
#include <variant/utility_functions.hpp>

using namespace godot;

BeehaveSequenceRandom::BeehaveSequenceRandom() {
	if (random_seed == 0) {
		UtilityFunctions::randomize();
	}
}

BeehaveSequenceRandom::~BeehaveSequenceRandom() {

}

void BeehaveSequenceRandom::set_resume_on_failure(bool resume_on_failure) {
    this->resume_on_failure = resume_on_failure;
}

bool BeehaveSequenceRandom::get_resume_on_failure() const {
    return resume_on_failure;
}

void BeehaveSequenceRandom::set_resume_on_interrupt(bool resume_on_interrupt) {
    this->resume_on_interrupt = resume_on_interrupt;
}

bool BeehaveSequenceRandom::get_resume_on_interrupt() const {
    return resume_on_interrupt;
}

void BeehaveSequenceRandom::_bind_methods() {
    // methods
    ClassDB::bind_method(D_METHOD("set_resume_on_failure", "resume_on_failure"), &BeehaveSequenceRandom::set_resume_on_failure);
    ClassDB::bind_method(D_METHOD("get_resume_on_failure"), &BeehaveSequenceRandom::get_resume_on_failure);
    ClassDB::bind_method(D_METHOD("set_resume_on_interrupt", "resume_on_interrupt"), &BeehaveSequenceRandom::set_resume_on_interrupt);
    ClassDB::bind_method(D_METHOD("get_resume_on_interrupt"), &BeehaveSequenceRandom::get_resume_on_interrupt);

    // exports
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "resume_on_failure"), "set_resume_on_failure", "get_resume_on_failure");
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "resume_on_interrupt"), "set_resume_on_interrupt", "get_resume_on_interrupt");
}

BeehaveTickStatus BeehaveSequenceRandom::tick(Ref<BeehaveContext> context) {
    if (_children_bag.is_empty()) {
		_children_bag = get_shuffled_children();
	}

    // Since we're going to remove children from the array, iterate it in reverse order.
	for (int i = _children_bag.size() -1; i >= 0; --i) {
        BeehaveTreeNode *child = cast_node(Object::cast_to<Node>(_children_bag[i]));
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
                _children_bag.erase(child);
                child->after_run(context);
                break;
            case FAILURE:
                _children_bag.erase(child);
                // Interrupt any child that was RUNNING before, but do not reset!
                BeehaveCompositeRandom::interrupt(context);
                child->after_run(context);
                return FAILURE;
            case RUNNING:
                running_child = child;
                return RUNNING;
        }
    }
    return BeehaveTickStatus::SUCCESS;
}

void BeehaveSequenceRandom::after_run(Ref<BeehaveContext> context) {
    if (!resume_on_failure) {
        _children_bag = get_shuffled_children();
    }
    BeehaveCompositeRandom::after_run(context);
}

void BeehaveSequenceRandom::interrupt(Ref<BeehaveContext> context) {
    if (!resume_on_interrupt) {
        _children_bag = get_shuffled_children();
    }
    BeehaveCompositeRandom::interrupt(context);
}