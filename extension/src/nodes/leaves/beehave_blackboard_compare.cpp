/**************************************************************************/
/*  beehave_blackboard_compare.cpp                                        */
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

#include "beehave_blackboard_compare.h"
#include "nodes/beehave_blackboard.h"
#include <classes/expression.hpp>
#include <variant/utility_functions.hpp>

using namespace godot;

void BeehaveBlackboardCompare::_bind_methods() {
    // enums
    BIND_ENUM_CONSTANT(EQUAL);
    BIND_ENUM_CONSTANT(NOT_EQUAL);
    BIND_ENUM_CONSTANT(GREATER);
    BIND_ENUM_CONSTANT(LESS);
    BIND_ENUM_CONSTANT(GREATER_EQUAL);
    BIND_ENUM_CONSTANT(LESS_EQUAL);

    // methods
    ClassDB::bind_method(D_METHOD("set_left_operand", "left_operand"), &BeehaveBlackboardCompare::set_left_operand);
    ClassDB::bind_method(D_METHOD("get_left_operand"), &BeehaveBlackboardCompare::get_left_operand);
    ClassDB::bind_method(D_METHOD("set_right_operand", "right_operand"), &BeehaveBlackboardCompare::set_right_operand);
    ClassDB::bind_method(D_METHOD("get_right_operand"), &BeehaveBlackboardCompare::get_right_operand);
    ClassDB::bind_method(D_METHOD("set_comparison_operator", "comparison_operator"), &BeehaveBlackboardCompare::set_comparison_operator);
    ClassDB::bind_method(D_METHOD("get_comparison_operator"), &BeehaveBlackboardCompare::get_comparison_operator);

    // exports
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "left_operand", PropertyHint::PROPERTY_HINT_PLACEHOLDER_TEXT, "Insert an expression..."), "set_left_operand", "get_left_operand");
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "right_operand", PropertyHint::PROPERTY_HINT_PLACEHOLDER_TEXT, "Insert an expression..."), "set_right_operand", "get_right_operand");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "comparison_operator", PropertyHint::PROPERTY_HINT_ENUM, "==, !=, >, <, >=, <="), "set_comparison_operator", "get_comparison_operator");
}

BeehaveBlackboardCompare::BeehaveBlackboardCompare() {

}

BeehaveBlackboardCompare::~BeehaveBlackboardCompare() {

}

void BeehaveBlackboardCompare::set_left_operand(String left_operand) {
    this->left_operand = left_operand;
}

String BeehaveBlackboardCompare::get_left_operand() const {
    return this->left_operand;
}

void BeehaveBlackboardCompare::set_right_operand(String right_operand) {
    this->right_operand = right_operand;
}

String BeehaveBlackboardCompare::get_right_operand() const {
    return this->right_operand;
}

void BeehaveBlackboardCompare::set_comparison_operator(BeehaveBlackboardCompare::ComparisonOperator comparison_operator) {
    this->comparison_operator = comparison_operator;
}

BeehaveBlackboardCompare::ComparisonOperator BeehaveBlackboardCompare::get_comparison_operator() const {
    return this->comparison_operator;
}

BeehaveTickStatus BeehaveBlackboardCompare::tick(Ref<BeehaveContext> context) {
    Ref<Expression> left_expression;
    left_expression.instantiate();

    Error error = left_expression->parse(left_operand);
    if (error != Error::OK) {
        UtilityFunctions::push_error("[Leaf] Couldn't parse expression with source: `%s` Error text: `%s`", left_operand, left_expression->get_error_text());
        return BeehaveTickStatus::FAILURE;
    }

    Variant left = left_expression->execute(Array(), context->get_blackboard());
    if (left_expression->has_execute_failed()) {
        return BeehaveTickStatus::FAILURE;
    }

    Ref<Expression> right_expression;
    right_expression.instantiate();

    error = right_expression->parse(right_operand);
    if (error != Error::OK) {
        UtilityFunctions::push_error("[Leaf] Couldn't parse expression with source: `%s` Error text: `%s`", right_operand, right_expression->get_error_text());
        return BeehaveTickStatus::FAILURE;
    }

    Variant right = right_expression->execute(Array(), context->get_blackboard());
    if (right_expression->has_execute_failed()) {
        return BeehaveTickStatus::FAILURE;
    }

    Variant returned;
    bool valid;
    switch(comparison_operator) {
        case EQUAL:
            Variant::evaluate(Variant::Operator::OP_EQUAL, left, right, returned, valid);
            break;
        case NOT_EQUAL:
            Variant::evaluate(Variant::Operator::OP_NOT_EQUAL, left, right, returned, valid);
            break;
        case GREATER:
            Variant::evaluate(Variant::Operator::OP_GREATER, left, right, returned, valid);
            break;
        case LESS:
            Variant::evaluate(Variant::Operator::OP_LESS, left, right, returned, valid);
            break;
        case GREATER_EQUAL:
            Variant::evaluate(Variant::Operator::OP_GREATER_EQUAL, left, right, returned, valid);
            break;
        case LESS_EQUAL:
            Variant::evaluate(Variant::Operator::OP_LESS_EQUAL, left, right, returned, valid);
            break;
    }

    bool result = returned.booleanize();
    return valid && result ? SUCCESS : FAILURE;
}