/**************************************************************************/
/*  beehave_blackboard_compare.h                                          */
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

#ifndef BEEHAVE_BLACKBOARD_COMPARE
#define BEEHAVE_BLACKBOARD_COMPARE

#include "beehave_action.h"

namespace godot {

class BeehaveBlackboardCompare : public BeehaveAction {
	GDCLASS(BeehaveBlackboardCompare, BeehaveAction);

public:
    enum ComparisonOperator {
        EQUAL = 0,
        NOT_EQUAL = 1,
        GREATER = 2,
        LESS = 3,
        GREATER_EQUAL = 4,
        LESS_EQUAL = 5,
    };

    String left_operand;
    String right_operand;
    ComparisonOperator comparison_operator = ComparisonOperator::EQUAL;

protected:
		static void _bind_methods();

public:
		BeehaveBlackboardCompare();
		~BeehaveBlackboardCompare();

        void set_left_operand(String left_operand);
        String get_left_operand() const;

        void set_right_operand(String right_operand);
        String get_right_operand() const;

        void set_comparison_operator(BeehaveBlackboardCompare::ComparisonOperator comparison_operator);
        BeehaveBlackboardCompare::ComparisonOperator get_comparison_operator() const;

        BeehaveTickStatus tick(Ref<BeehaveContext> context);
};
}

VARIANT_ENUM_CAST(BeehaveBlackboardCompare::ComparisonOperator);

#endif //BEEHAVE_BLACKBOARD_COMPARE