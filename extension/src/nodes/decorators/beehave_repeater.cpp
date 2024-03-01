/**************************************************************************/
/*  beehave_repeater.cpp                                                  */
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

#include "beehave_repeater.h"

using namespace godot;

BeehaveRepeater::BeehaveRepeater():
repetitions(1),
current_count(0) {

}


BeehaveRepeater::~BeehaveRepeater() {

}

void BeehaveRepeater::_bind_methods() {
	// methods
	ClassDB::bind_method(D_METHOD("set_repetitions", "repetitions"), &BeehaveRepeater::set_repetitions);
	ClassDB::bind_method(D_METHOD("get_repetitions"), &BeehaveRepeater::get_repetitions);

	// exports
	ADD_PROPERTY(PropertyInfo(Variant::INT, "repetitions"), "set_repetitions", "get_repetitions");
}


void BeehaveRepeater::set_repetitions(int repetitions) {
	this->repetitions = repetitions;
	current_count = 0;
}

int BeehaveRepeater::get_repetitions() const {
	return repetitions;
}

BeehaveTickStatus BeehaveRepeater::tick(Ref<BeehaveContext> context) {
	BeehaveTreeNode *tree_node = get_wrapped_child();
	if (!tree_node) {
		return BeehaveTickStatus::FAILURE;
	}

	if (current_count < repetitions) {
		++current_count;
		BeehaveTickStatus tick_status = tree_node->tick(context);
		return tick_status;
	}

	return BeehaveTickStatus::FAILURE;
}