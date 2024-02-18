/**************************************************************************/
/*  beehave_limiter.h                                                     */
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

#include "beehave_limiter.h"

using namespace godot;

BeehaveLimiter::BeehaveLimiter():
max_count(1),
current_count(0) {

}

BeehaveLimiter::~BeehaveLimiter() {

}

void BeehaveLimiter::_bind_methods() {
	// methods
	ClassDB::bind_method(D_METHOD("set_max_count", "max_count"), &BeehaveLimiter::set_max_count);
	ClassDB::bind_method(D_METHOD("get_max_count"), &BeehaveLimiter::get_max_count);

	// exports
	ADD_PROPERTY(PropertyInfo(Variant::INT, "max_count"), "set_max_count", "get_max_count");
}

void BeehaveLimiter::set_max_count(int max_count) {
	this->max_count = max_count;
	current_count = 0;
}

int BeehaveLimiter::get_max_count() const {
	return max_count;
}

BeehaveTreeNode::TickStatus BeehaveLimiter::tick(Ref<BeehaveContext> context) {
	BeehaveTreeNode *tree_node = get_wrapped_child();
	if (!tree_node) {
		return BeehaveTreeNode::FAILURE;
	}

	if (current_count < max_count) {
		BeehaveTreeNode::TickStatus tick_status = tree_node->tick(context);
		++current_count;
		return tick_status;
	}

	return BeehaveTreeNode::FAILURE;
}