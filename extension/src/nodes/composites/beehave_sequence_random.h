/**************************************************************************/
/*  beehave_sequence_random.h                                             */
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

#ifndef BEEHAVE_SEQUENCE_RANDOM_H
#define BEEHAVE_SEQUENCE_RANDOM_H

#include "nodes/composites/beehave_composite_random.h"
#include <classes/node.hpp>

namespace godot
{

class BeehaveSequenceRandom : public BeehaveCompositeRandom {
    GDCLASS(BeehaveSequenceRandom, BeehaveCompositeRandom);

    // Whether the sequence should start where it left off after a previous failure.
    bool resume_on_failure = false;
    // Whether the sequence should start where it left off after a previous interruption.
    bool resume_on_interrupt = false;

protected:
    static void _bind_methods();

public:
    BeehaveSequenceRandom();
    ~BeehaveSequenceRandom();

    void set_resume_on_failure(bool resume_on_failure);
    bool get_resume_on_failure() const;

    void set_resume_on_interrupt(bool resume_on_interrupt);
    bool get_resume_on_interrupt() const;

    BeehaveTickStatus tick(Ref<BeehaveContext> context);

    void after_run(Ref<BeehaveContext> context);

    void interrupt(Ref<BeehaveContext> context);

private:
	TypedArray<Node> _children_bag;
};
} // namespace godot

#endif // BEEHAVE_SEQUENCE_RANDOM_H