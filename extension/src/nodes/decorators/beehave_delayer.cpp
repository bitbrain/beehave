/**************************************************************************/
/*  beehave_delayer.cpp                                                   */
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

#include "beehave_delayer.h"
#include <classes/time.hpp>

using namespace godot;

BeehaveDelayer::BeehaveDelayer():
wait_time(1),
previous_time(-1) {

}

BeehaveDelayer::~BeehaveDelayer() {

}

void BeehaveDelayer::_bind_methods() {
	// methods
	ClassDB::bind_method(D_METHOD("set_wait_time", "wait_time"), &BeehaveDelayer::set_wait_time);
	ClassDB::bind_method(D_METHOD("get_wait_time"), &BeehaveDelayer::get_wait_time);

	// exports
	ADD_PROPERTY(PropertyInfo(Variant::INT, "wait_time"), "set_wait_time", "get_wait_time");
}
	

void BeehaveDelayer::set_wait_time(float wait_time) {
	this->wait_time = wait_time;
	previous_time = -1;
}

float BeehaveDelayer::get_wait_time() const {
	return wait_time;
}

BeehaveTreeNode::TickStatus BeehaveDelayer::tick(Ref<BeehaveContext> context) {
	BeehaveTreeNode *tree_node = get_wrapped_child();
	if (!tree_node) {
		return BeehaveTreeNode::FAILURE;
	}

	uint64_t current_time = Time::get_singleton()->get_ticks_msec();

	if (previous_time == -1) {
		previous_time = current_time;
	}

	uint64_t passed_time = current_time - previous_time;

	// the wait time has been reached, time to reset
	if (passed_time >= wait_time * 1000.0) {
		// avoid time drift by carrying over miliseconds from previous iteration.
		previous_time = current_time - (passed_time - (wait_time * 1000.0));
		return tree_node->tick(context);
	}

	return BeehaveTreeNode::RUNNING;
}