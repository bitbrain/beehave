/**************************************************************************/
/*  beehave_blackboard_set.cpp                                            */
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

#include "beehave_blackboard_set.h"
#include "nodes/beehave_blackboard.h"
#include <classes/engine.hpp>
#include <variant/utility_functions.hpp>

using namespace godot;

void BeehaveBlackboardSet::_bind_methods() {
    // methods
    ClassDB::bind_method(D_METHOD("set_key", "key"), &BeehaveBlackboardSet::set_key);
    ClassDB::bind_method(D_METHOD("get_key"), &BeehaveBlackboardSet::get_key);
    ClassDB::bind_method(D_METHOD("set_value", "value"), &BeehaveBlackboardSet::set_value);
    ClassDB::bind_method(D_METHOD("get_value"), &BeehaveBlackboardSet::get_value);

    // exports
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "key", PropertyHint::PROPERTY_HINT_PLACEHOLDER_TEXT, "Insert a key name..."), "set_key", "get_key");
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "value", PropertyHint::PROPERTY_HINT_PLACEHOLDER_TEXT, "Insert a value expression..."), "set_value", "get_value");
}

BeehaveBlackboardSet::BeehaveBlackboardSet() {
    value_expression.instantiate();
}

BeehaveBlackboardSet::~BeehaveBlackboardSet() {

}

void BeehaveBlackboardSet::set_key(String key) {
    this->key = key;
}

String BeehaveBlackboardSet::get_key() const {
    return this->key;
}

void BeehaveBlackboardSet::set_value(String value) {
    this->value = value;

    Error error = value_expression->parse(value);
    if (error != Error::OK) {
        if (!Engine::get_singleton()->is_editor_hint()) {
            UtilityFunctions::push_error("[BlackboardSet] Couldn't parse expression with source: ", value, " Error text: ", value_expression->get_error_text());
        }
        is_expression_successfully_parsed = false;
    }
    else {
        execute_failure_printed = false;
        is_expression_successfully_parsed = true;
    }

    update_configuration_warnings();
}

String BeehaveBlackboardSet::get_value() const {
    return this->value;
}

BeehaveTickStatus BeehaveBlackboardSet::tick(Ref<BeehaveContext> context) {
    if (!is_expression_successfully_parsed) {
        return BeehaveTickStatus::FAILURE;
    }

    Variant final_value = value_expression->execute(Array(), context->get_blackboard(), false);

    if (value_expression->has_execute_failed()) {
        if (!execute_failure_printed && !Engine::get_singleton()->is_editor_hint()) {
            // Until the expression is changed, it will (likely) keep failing. Don't flood the output with errors.
            UtilityFunctions::push_error("[BlackboardSet] Couldn't execute expression with source: ", value, " Error text: ", value_expression->get_error_text());
            execute_failure_printed = true;
        }
        return BeehaveTickStatus::FAILURE;
    }

    context->get_blackboard()->set_value(key, final_value);
    return BeehaveTickStatus::SUCCESS;
}

PackedStringArray BeehaveBlackboardSet::_get_configuration_warnings() const {
    PackedStringArray warnings = BeehaveAction::_get_configuration_warnings();
    if (!is_expression_successfully_parsed) {
        warnings.push_back(vformat("Couldn't parse expression with source: %s Error text: %s", value, value_expression->get_error_text()));
    }
    return warnings;
}