/**************************************************************************/
/*  beehave_tree.cpp                                                      */
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

#include "beehave_tree.h"
#include <core/class_db.hpp>

using namespace godot;

BeehaveTree::BeehaveTree()
{

}

BeehaveTree::~BeehaveTree()
{
    
}

void BeehaveTree::_bind_methods()
{
    // signals
    ADD_SIGNAL(MethodInfo("enabled"));
    ADD_SIGNAL(MethodInfo("disabled"));

    // enums
    BIND_ENUM_CONSTANT(IDLE);
    BIND_ENUM_CONSTANT(PHYSICS);

    // methods
    ClassDB::bind_method(D_METHOD("enable"), &BeehaveTree::enable);
    ClassDB::bind_method(D_METHOD("disable"), &BeehaveTree::disable);
}

void BeehaveTree::_ready()
{

}

void BeehaveTree::_process(double delta)
{

}

void BeehaveTree::_physics_process(double delta)
{

}

void BeehaveTree::enable()
{

}

void BeehaveTree::disable()
{

}
