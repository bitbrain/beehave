/**************************************************************************/
/*  beehave_blackboard_erase.cpp                                          */
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

#include "beehave_blackboard_erase.h"
#include "nodes/beehave_blackboard.h"

using namespace godot;

void BeehaveBlackboardErase::_bind_methods() {
    // methods
    ClassDB::bind_method(D_METHOD("set_key", "key"), &BeehaveBlackboardErase::set_key);
    ClassDB::bind_method(D_METHOD("get_key"), &BeehaveBlackboardErase::get_key);

    // exports
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "key", PropertyHint::PROPERTY_HINT_PLACEHOLDER_TEXT, "Insert a key name..."), "set_key", "get_key");
}

BeehaveBlackboardErase::BeehaveBlackboardErase() {

}

BeehaveBlackboardErase::~BeehaveBlackboardErase() {

}

void BeehaveBlackboardErase::set_key(String key) {
    this->key = key;
}

String BeehaveBlackboardErase::get_key() const {
    return this->key;
}

BeehaveTickStatus BeehaveBlackboardErase::tick(Ref<BeehaveContext> context) {
    bool success = context->get_blackboard()->erase_value(key);
    return success ? SUCCESS : FAILURE;
}