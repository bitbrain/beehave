/**************************************************************************/
/*  beehave_simple_parallel.h                                             */
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

#ifndef BEEHAVE_SIMPLE_PARALLEL_H
#define BEEHAVE_SIMPLE_PARALLEL_H

#include "nodes/composites/beehave_composite.h"

namespace godot
{

class BeehaveSimpleParallel : public BeehaveComposite {
    GDCLASS(BeehaveSimpleParallel, BeehaveComposite);

    // TODO: add secondary node repeat count back in - needs something akin to before_run() hook for proper setup.

    // Whether to wait for the secondary node to finish after the primary node has finished.
    bool wait_for_secondary_node;

    BeehaveTickStatus delayed_result;
    bool main_task_finished;
    bool secondary_node_running;

protected:
    static void _bind_methods();

public:
    BeehaveSimpleParallel();
    ~BeehaveSimpleParallel();

    void set_wait_for_secondary_node(bool wait);
    bool get_wait_for_secondary_node() const;

    BeehaveTickStatus tick(Ref<BeehaveContext> context);

    void _reset();
};
} // namespace godot

#endif // BEEHAVE_SIMPLE_PARALLEL_H