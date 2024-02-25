/**************************************************************************/
/*  beehave_time_limiter.cpp                                              */
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

#include "beehave_time_limiter.h"

using namespace godot;

BeehaveTimeLimiter::BeehaveTimeLimiter():
	wait_time(1.0),
	passed_time(0) {

}

BeehaveTimeLimiter::~BeehaveTimeLimiter() {
}

void BeehaveTimeLimiter::_bind_methods() {
	// methods
	ClassDB::bind_method(D_METHOD("set_wait_time", "wait_time"), &BeehaveTimeLimiter::set_wait_time);
	ClassDB::bind_method(D_METHOD("get_wait_time"), &BeehaveTimeLimiter::get_wait_time);

	// exports
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "wait_time"), "set_wait_time", "get_wait_time");
}

void BeehaveTimeLimiter::set_wait_time(float wait_time) {
	this->wait_time = wait_time;
}

float BeehaveTimeLimiter::get_wait_time() const {
	return wait_time;
}

BeehaveTreeNode::TickStatus BeehaveTimeLimiter::tick(Ref<BeehaveContext> context) {
	BeehaveTreeNode *tree_node = get_wrapped_child();
	if (!tree_node) {
		return BeehaveTreeNode::FAILURE;
	}

	BeehaveTreeNode::TickStatus status = BeehaveTreeNode::FAILURE;

	passed_time += context->get_delta();

	// the wait time has been reached, time to reset
	if (passed_time >= wait_time * 1000.0) {
		status = tree_node->tick(context);
		// avoid time drift by carrying over miliseconds from previous iteration.
		passed_time -= wait_time * 1000.0;
	}

	return status;
}