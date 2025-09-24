/**************************************************************************/
/*  beehave_composite_random.cpp                                          */
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

#include "beehave_composite_random.h"
#include <core/class_db.hpp>
#include <variant/utility_functions.hpp>

using namespace godot;

BeehaveCompositeRandom::BeehaveCompositeRandom():
random_seed(0) {

}

BeehaveCompositeRandom::~BeehaveCompositeRandom() {

}

void BeehaveCompositeRandom::set_random_seed(int random_seed) {
    this->random_seed = random_seed;
    if (random_seed != 0) UtilityFunctions::seed(random_seed);
    else UtilityFunctions::randomize();
}

int BeehaveCompositeRandom::get_random_seed() const {
    return random_seed;
}

void BeehaveCompositeRandom::_bind_methods() {
    // methods
    ClassDB::bind_method(D_METHOD("set_random_seed", "random_seed"), &BeehaveCompositeRandom::set_random_seed);
    ClassDB::bind_method(D_METHOD("get_random_seed"), &BeehaveCompositeRandom::get_random_seed);

    // exports
    ADD_PROPERTY(PropertyInfo(Variant::INT, "random_seed"), "set_random_seed", "get_random_seed");
}

TypedArray<Node> BeehaveCompositeRandom::get_shuffled_children() {
    TypedArray<Node> children_bag = get_children().duplicate();
    children_bag.shuffle();
    return children_bag;
}