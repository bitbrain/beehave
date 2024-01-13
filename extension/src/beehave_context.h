/**************************************************************************/
/*  beehave_context.h                                                     */
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

#ifndef BEEHAVE_CONTEXT_H
#define BEEHAVE_CONTEXT_H

#include <classes/ref_counted.hpp>
#include <classes/node.hpp>
#include "nodes/beehave_blackboard.h"

namespace godot {

    class BeehaveContext : public RefCounted
    {
        GDCLASS(BeehaveContext, RefCounted);

        BeehaveBlackboard* blackboard;
        Node* actor;
        float delta;
    protected:
        static void _bind_methods();
    public:
        BeehaveBlackboard* get_blackboard() const;
        void set_blackboard(BeehaveBlackboard* blackboard);

        Node* get_actor() const;
        void set_actor(Node* actor);

        float get_delta() const;
        void set_delta(float delta);
    };

}

#endif // BEEHAVE_CONTEXT_H
