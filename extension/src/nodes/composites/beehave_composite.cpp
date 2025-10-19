/**************************************************************************/
/*  beehave_composite.cpp                                                 */
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

#include "beehave_composite.h"

using namespace godot;

BeehaveComposite::BeehaveComposite() {

}

BeehaveComposite::~BeehaveComposite() {

}

void BeehaveComposite::_bind_methods() {

}

void BeehaveComposite::after_run(Ref<BeehaveContext> context) {
    running_child = nullptr;
}

void BeehaveComposite::interrupt(Ref<BeehaveContext> context) {
    if (running_child) {
        running_child->interrupt(context);
        running_child = nullptr;
    }
    BeehaveTreeNode::interrupt(context);
}

void BeehaveComposite::interrupt_children(Ref<BeehaveContext> context, int from_index, int to_index) {
    if (from_index >= to_index) {
        return;
    }

    TypedArray<Node> children = get_children();

    for (int i = from_index; i < to_index; ++i) {
        BeehaveTreeNode *child = cast_node(Object::cast_to<Node>(children[i]));
        if (child == nullptr) {
            // Skip all children which aren't Beehave nodes
            continue;
        }

        child->interrupt(context);
    }
}