/**************************************************************************/
/*  beehave_context.cpp                                                   */
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

#include "beehave_context.h"

using namespace godot;

void BeehaveContext::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("set_tree", "tree"), &BeehaveContext::set_tree);
    ClassDB::bind_method(D_METHOD("get_tree"), &BeehaveContext::get_tree);
    ClassDB::bind_method(D_METHOD("set_blackboard", "blackboard"), &BeehaveContext::set_blackboard);
    ClassDB::bind_method(D_METHOD("get_blackboard"), &BeehaveContext::get_blackboard);
    ClassDB::bind_method(D_METHOD("set_actor", "actor"), &BeehaveContext::set_actor);
    ClassDB::bind_method(D_METHOD("get_actor"), &BeehaveContext::get_actor);
    ClassDB::bind_method(D_METHOD("set_delta", "delta"), &BeehaveContext::set_delta);
    ClassDB::bind_method(D_METHOD("get_delta"), &BeehaveContext::get_delta);
}

BeehaveTree* BeehaveContext::get_tree() const
{
    return this->tree;
}

void BeehaveContext::set_tree(BeehaveTree* tree)
{
    this->tree = tree;
}

BeehaveBlackboard* BeehaveContext::get_blackboard() const
{
    return this->blackboard;
}

void BeehaveContext::set_blackboard(BeehaveBlackboard* blackboard)
{
    this->blackboard = blackboard;
}

Node* BeehaveContext::get_actor() const
{
    return this->actor;
}

void BeehaveContext::set_actor(Node* actor)
{
    this->actor = actor;
}

float BeehaveContext::get_delta() const
{
    return delta;
}

void BeehaveContext::set_delta(float delta)
{
    this->delta = delta;
}