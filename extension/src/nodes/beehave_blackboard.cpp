/**************************************************************************/
/*  beehave_blackboard.cpp                                                */
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

#include "beehave_blackboard.h"
#include <core/class_db.hpp>

using namespace godot;

BeehaveBlackboard::BeehaveBlackboard() {
}

BeehaveBlackboard::~BeehaveBlackboard() {
	
}

void BeehaveBlackboard::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_value", "key", "value"), &BeehaveBlackboard::set_value);
	ClassDB::bind_method(D_METHOD("get_value", "key", "default_value"), &BeehaveBlackboard::get_value);
	ClassDB::bind_method(D_METHOD("has_value", "key"), &BeehaveBlackboard::has_value);
	ClassDB::bind_method(D_METHOD("erase_value", "key"), &BeehaveBlackboard::erase_value);
	ClassDB::bind_method(D_METHOD("get_size"), &BeehaveBlackboard::get_size);
}

void BeehaveBlackboard::set_value(const String &key, Variant value) {
	this->data[key] = value;
}

Variant BeehaveBlackboard::get_value(const String &key, Variant default_value) const {
	return data.get(key, default_value);
}

bool BeehaveBlackboard::has_value(const String &key) const {
	return data.has(key);
}

bool BeehaveBlackboard::erase_value(const String &key) {
	return data.erase(key);
}

int BeehaveBlackboard::get_size() const {
	return data.size();
}